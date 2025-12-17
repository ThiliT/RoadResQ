import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Preset town centers used to describe user's location in a friendly way.
  ///
  /// These roughly match the service areas used elsewhere in the app.
static const List<_TownCenter> _townCenters = [
    _TownCenter('Adhikarigama', 7.213527699399971, 80.780556),
    _TownCenter('Agalawatta', 6.542344499420432, 80.157362),
    _TownCenter('Agarapathana', 6.864128399409243, 80.70555),
    _TownCenter('Ahangama', 5.97351629944621, 80.3622999),
    _TownCenter('Ahungalla', 6.313788999429888, 80.0351217),
    _TownCenter('Akkaraipattu', 7.2140575993999585, 81.8482489),
    _TownCenter('Akkarayan', 9.31272219941015, 80.3111737),
    _TownCenter('Akuressa', 6.100506999439809, 80.47750969999998),
    _TownCenter('Alawwa', 7.294015599398265, 80.2392415),
    _TownCenter('Aluthgama', 6.432649399424816, 79.9988986),
    _TownCenter('Ambalangoda', 6.238841599433256, 80.0542508),
    _TownCenter('Ambalantota', 6.12246269943874, 81.0238588),
    _TownCenter('Ambanpola', 7.920739099390663, 80.2393258),
    _TownCenter('Anamaduwa', 7.877636699390862, 80.0109366),
    _TownCenter('Andigama', 7.7763857993915195, 79.9491462),
    _TownCenter('Angoda', 6.936019199407085, 79.9257199),
    _TownCenter('Angunukolapelessa', 6.166917199436608, 80.8976582),
    _TownCenter('Ankumbura', 7.4392820993956095, 80.5709587),
    _TownCenter('Aralaganwila', 7.782606999391473, 81.184693),
    _TownCenter('Aranayake', 7.177586399400783, 80.4571784),
    _TownCenter('Ibbagamuwa', 7.547912799393974, 80.4496417),
    _TownCenter('Imaduwa', 6.035480799443041, 80.3888983),
    _TownCenter('Induruwa', 6.37397389942728, 80.0105559),
    _TownCenter('Ingiriya', 6.743756399413133, 80.1766773),
    _TownCenter('Ja‑ela', 7.07937749940317, 79.8907632),
    _TownCenter('Kadawatha', 7.001966099405221, 79.9512673),
    _TownCenter('Kadugannawa', 7.257279499399025, 80.5195206),
    _TownCenter('Kaduruwela', 7.930647399390623, 81.032735),
    _TownCenter('Kaduwela', 6.935702699407094, 79.9843311),
    _TownCenter('Hakmana', 6.083925999440627, 80.6449735),
    _TownCenter('Haldummulla', 6.760216299412561, 80.8808852),
    _TownCenter('Hali Ela', 6.955453799406525, 81.0313976),
    _TownCenter('Hanguranketha', 7.177471199400785, 80.7755269),
    _TownCenter('Hanwella', 6.908836299407885, 80.0817106),
    _TownCenter('Haputhale', 6.7681491994123135, 80.9585635),
    _TownCenter('Hasalaka', 7.35160589939715, 80.950097),
    _TownCenter('Hatharaliyadda', 7.332690599397507, 80.4689258),
    _TownCenter('Etampitiya', 6.936034399407085, 80.9892698),
    _TownCenter('Galagedara', 7.3729670993967575, 80.5246925),
    _TownCenter('Galaha', 7.197794899400323, 80.6696568),
    _TownCenter('Galapitamada', 7.139914599401668, 80.2347555),
    _TownCenter('Galenbindunuwewa', 8.292445399390948, 80.7189721),
    _TownCenter('Galewela', 7.759661399391654, 80.5710966),
    _TownCenter('Galgamuwa', 7.995608899390432, 80.2704885),
    _TownCenter('Galnewa', 8.03548319939037, 80.4802068),
    _TownCenter('Manampitiya', 7.908845499390712, 81.1119238),
    _TownCenter('Manipay', 9.724494499425434, 79.9960261),
    _TownCenter('Mankulam', 9.128352499404695, 80.4460374),
    _TownCenter('Mapalagama', 6.2219839994340305, 80.2856003),
    _TownCenter('Maradankadawala', 8.127130499390377, 80.5630768),
    _TownCenter('Maruthankerny', 9.61949549942113, 80.4015193),
    _TownCenter('Maskeliya', 6.833827999410187, 80.5720627),
    _TownCenter('Matugama', 6.522954199421187, 80.11426029999998),
        _TownCenter('Matale', 7.467529, 80.624894),
    _TownCenter('Matara', 5.954922, 80.554123),
    _TownCenter('Medawachchiya', 8.041203, 80.635219),
    _TownCenter('Melsiripura', 7.629471, 80.470098),
    _TownCenter('Milakandura', 7.030431, 80.009653),
    _TownCenter('Minuwangoda', 7.180215, 79.970212),
    _TownCenter('Monaragala', 6.873689, 81.341188),
    _TownCenter('Moraragolla', 7.192684, 80.597492),
    _TownCenter('Mullaitivu', 9.267879, 80.788414),
    _TownCenter('Murunkan', 9.869441, 79.871232),
    _TownCenter('Narangamuwa', 6.683174, 79.993772),
    _TownCenter('Nawalapitiya', 7.033525, 80.538398),
    _TownCenter('Nawalapitiya', 7.040416, 80.539153),
    _TownCenter('Negombo', 7.208350, 79.835823),
    _TownCenter('Nelliyadi', 9.251584, 80.189415),
    _TownCenter('Nikaweratiya', 7.800345, 80.090763),
    _TownCenter('Nuwara Eliya', 6.949661, 80.789368),
    _TownCenter('Omanthai', 9.600411, 80.350186),
    _TownCenter('Padaviya', 8.156378, 81.118894),
    _TownCenter('Padukka', 6.866328, 80.098326),
    _TownCenter('Palampitiya', 6.904421, 80.771524),
    _TownCenter('Pallewela', 6.799238, 80.059847),
    _TownCenter('Panadura', 6.716073, 79.944268),
    _TownCenter('Pannala', 7.393945, 79.980321),
    _TownCenter('Paranthan', 9.024536, 80.113118),
    _TownCenter('Paranugama', 7.313874, 79.883420),
    _TownCenter('Peliyagoda', 6.948868, 79.896137),
    _TownCenter('Pelmadulla', 6.647341, 80.625689),
    _TownCenter('Peradeniya', 7.259139, 80.594726),
    _TownCenter('Piliyandala', 6.841281, 79.950843),
    _TownCenter('Polonnaruwa', 7.940649, 81.000228),
    _TownCenter('Pothuvil', 7.285612, 81.808853),
    _TownCenter('Puttalam', 8.034460, 79.827812),
    _TownCenter('Radawana', 7.024682, 79.996472),
    _TownCenter('Ragama', 7.000585, 79.961472),
    _TownCenter('Ratnapura', 6.682786, 80.399452),
    _TownCenter('Ruwanwella', 6.980012, 80.480022),
    _TownCenter('Seethawaka', 6.949183, 80.116512),
    _TownCenter('Talawakele', 6.964187, 80.562828),
    _TownCenter('Tangalle', 6.012015, 80.781829),
    _TownCenter('Thambuttegama', 8.191592, 80.849496),
    _TownCenter('Thirukkovil', 6.359762, 81.869118),
    _TownCenter('Tissamaharama', 6.003970, 80.764890),
    _TownCenter('Trincomalee', 8.587620, 81.215241),
    _TownCenter('Valachchenai', 7.276438, 81.925632),
    _TownCenter('Vavuniya', 8.754000, 80.500000),
    _TownCenter('Wadduwa', 6.721471, 79.969772),
    _TownCenter('Watawala', 7.212933, 80.641254),
    _TownCenter('Weeraketiya', 6.014281, 81.094567),
    _TownCenter('Welimada', 6.843934, 80.955102),
    _TownCenter('Wennappuwa', 7.483624, 79.840863),
    _TownCenter('Weragantota', 6.904839, 80.788242),
    _TownCenter('Weligama', 5.975324, 80.431571),
    _TownCenter('Wattegama', 6.927639, 80.625048),
    _TownCenter('Wattegama', 7.294913, 80.624198),
    _TownCenter('Yakkalamulla', 6.176402, 80.091895),
    _TownCenter('Yapahuwa', 7.987874, 79.953142),
    _TownCenter('Yatinuwara', 7.256238, 80.613101),
];
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) + math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  String calculateETA(double distanceKm) {
    final minutes = (distanceKm / 10 * 60).clamp(5, 60).round();
    return '~$minutes mins';
  }

  double _deg2rad(double deg) => deg * (math.pi / 180.0);

  double _rad2deg(double rad) => rad * (180.0 / math.pi);

  /// Returns a human-friendly description like:
  /// "Colombo • 3.2 km NW of town center"
  /// for given user coordinates, based on the closest known town.
  String describeLocation(double lat, double lon) {
    if (_townCenters.isEmpty) {
      return 'Location detected';
    }

    // Find nearest town center
    _TownCenter? nearest;
    double? nearestDistanceKm;

    for (final town in _townCenters) {
      final d = calculateDistance(lat, lon, town.lat, town.lon);
      if (nearest == null || d < nearestDistanceKm!) {
        nearest = town;
        nearestDistanceKm = d;
      }
    }

    if (nearest == null || nearestDistanceKm == null) {
      return 'Location detected';
    }

    // If the user is extremely close, just show the town
    if (nearestDistanceKm < 0.3) {
      return nearest.name;
    }

    final direction =
        _bearingDirection(fromLat: nearest.lat, fromLon: nearest.lon, toLat: lat, toLon: lon);

    return '${nearest.name} • ${nearestDistanceKm.toStringAsFixed(1)} km $direction of town center';
  }

  /// Returns one of: N, NE, E, SE, S, SW, W, NW
  String _bearingDirection({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
  }) {
    final lat1 = _deg2rad(fromLat);
    final lat2 = _deg2rad(toLat);
    final dLon = _deg2rad(toLon - fromLon);

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    var brng = _rad2deg(math.atan2(y, x));

    // Normalize to 0-360
    brng = (brng + 360) % 360;

    if (brng >= 337.5 || brng < 22.5) return 'N';
    if (brng >= 22.5 && brng < 67.5) return 'NE';
    if (brng >= 67.5 && brng < 112.5) return 'E';
    if (brng >= 112.5 && brng < 157.5) return 'SE';
    if (brng >= 157.5 && brng < 202.5) return 'S';
    if (brng >= 202.5 && brng < 247.5) return 'SW';
    if (brng >= 247.5 && brng < 292.5) return 'W';
    return 'NW';
  }
}

class _TownCenter {
  final String name;
  final double lat;
  final double lon;

  const _TownCenter(this.name, this.lat, this.lon);
}


