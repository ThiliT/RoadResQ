import 'dotenv/config';
import express from 'express';
import mysql from 'mysql2/promise';
import adb from 'adbkit';

const app = express();
app.use(express.json());

const {
DB_HOST = 'localhost',
DB_PORT = '3306',
DB_NAME,
DB_USER,
DB_PASSWORD,
MAX_RADIUS_KM = '1',
PORT = 3000,
} = process.env;

// MySQL connection pool
const pool = mysql.createPool({
host: DB_HOST,
port: DB_PORT,
database: DB_NAME || 'roadresq',
user: DB_USER || 'root',
password: DB_PASSWORD || 'db_password',
waitForConnections: true,
connectionLimit: 10,
});

// Test DB connection
pool.getConnection()
.then(conn => { console.log('✅ Connected to MySQL'); conn.release(); })
.catch(err => console.error('❌ Failed to connect:', err));

// ADB client
const client = adb.createClient();

const RADIUS_KM = Number(MAX_RADIUS_KM) || 1;

const QUERY = `SELECT id, name, phone, latitude, longitude, area, available, rating,  
(6371 * acos(  
  cos(radians(?)) * cos(radians(latitude)) *  
  cos(radians(longitude) - radians(?)) +  
  sin(radians(?)) * sin(radians(latitude))  
)) AS distance  
FROM mechanics  
WHERE latitude IS NOT NULL AND longitude IS NOT NULL  
ORDER BY distance ASC  
LIMIT 10;`;

// Parse HELP message with LAT and LNG only
const smsPattern = /HELP\s+LAT:([-\d.]+)\s+LNG:([-\d.]+)/i;

const formatResponse = rows => {
if (!rows.length) return 'Nearest Mechanics (within 1 km):\nNo mechanics found nearby.';
const lines = rows.slice(0,5).map((row,idx) =>
`${idx+1}. ${row.name} - ${row.phone} (${Number(row.distance).toFixed(1)} km)`
);
return ['Nearest Mechanics (within 1 km):', ...lines].join('\n');
};

// Open SMS app and automatically send message
async function sendSMSAuto(phoneNumber, message) {
try {
const devices = await client.listDevices();
if (!devices.length) throw new Error('No Android device connected.');
const deviceId = devices[0].id;


console.log(`📱 Sending SMS to ${phoneNumber} via device ${deviceId}...`);  

// Open SMS chat with prefilled message  
const openCmd = `am start -a android.intent.action.SENDTO -d "smsto:${phoneNumber}" --es sms_body "${message}"`;  
await client.shell(deviceId, openCmd);  

// Wait a bit to ensure SMS app opens  
await new Promise(r => setTimeout(r, 1000));  

// Press "Enter" to send  
const sendCmd = `input keyevent 66`;  
await client.shell(deviceId, sendCmd);  

console.log(`✅ Message sent automatically to ${phoneNumber}`);  


} catch (err) {
console.error('❌ Failed to send SMS automatically:', err);
throw err;
}
}

// POST /sms endpoint
app.post('/sms', async (req, res) => {
try {
const incomingBody = (req.body.message || '').trim();
const userPhone = req.body.from; // sender's number


if (!userPhone) return res.status(400).json({ status:'error', message:'Sender phone number not provided.' });  

const match = incomingBody.match(smsPattern);  
if (!match) return res.json({ status:'error', message:'Invalid format. Use: HELP LAT:<lat> LNG:<lng>' });  

const [, latStr, lngStr] = match;  
const latitude = Number(latStr);  
const longitude = Number(lngStr);  

if (Number.isNaN(latitude) || Number.isNaN(longitude))  
  return res.json({ status:'error', message:'Invalid coordinates. Please send numeric latitude/longitude.' });  

const [rows] = await pool.execute(QUERY, [latitude, longitude, latitude]);  
const nearby = rows.filter(row => Number(row.distance) <= RADIUS_KM);  

const responseMessage = formatResponse(nearby);  
console.log('💬 Prepared SMS:\n', responseMessage);  

await sendSMSAuto(userPhone, responseMessage);  

res.json({ status:'success', message:`Mechanics list sent to ${userPhone}` });  


} catch(err) {
console.error('❌ [SMS Handler] Failed:', err);
res.status(500).json({ status:'error', message:'Unable to process your request right now.' });
}
});

// GET /mechanics - Fetch all mechanics from database
app.get('/mechanics', async (req, res) => {
  try {
    const [rows] = await pool.execute(
      `SELECT id, name, phone, latitude, longitude, area, available, rating 
       FROM mechanics 
       WHERE latitude IS NOT NULL AND longitude IS NOT NULL 
       ORDER BY name ASC`
    );
    
    res.json({
      status: 'success',
      mechanics: rows,
      count: rows.length
    });
  } catch (err) {
    console.error('❌ [GET /mechanics] Failed:', err);
    res.status(500).json({
      status: 'error',
      message: 'Unable to fetch mechanics from database.'
    });
  }
});

// Health check
app.get('/health', (_req,res) => res.json({ ok:true, uptime: process.uptime() }));

// Start server
app.listen(PORT, () => console.log(`🚀 RoadResQ SMS backend listening on port ${PORT}`));
