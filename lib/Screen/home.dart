import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../Models/DatabaseService.dart';
import '../Models/Rider.dart';
import '../Models/adminusers.dart';
import '../main.dart';
import '../notifications/pushNotificationService.dart';
import 'addfacts.dart';
import 'deactivatedUSERS.dart';
import 'earningsScreen.dart';
import 'requests.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final DatabaseReference _ridersRef = FirebaseDatabase.instance.ref().child('Riders');
  List<Rider> _riders = [];
  List<Map<String, dynamic>> ongoingRequests = [];
  Users? riderinformation;

  @override
  void initState() {
    super.initState();
    _loadRiders();
    getCurrentArtisanInfo();
    fetchOngoingRequests();
  }

  @override
  Widget build(BuildContext context) {
    var databaseService = Provider.of<DatabaseService1>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCard(databaseService),
              const SizedBox(height: 24),
              _buildOngoingDeliveriesSection(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        "Dashboard",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: _showLogoutDialog,
        ),
      ],
    );
  }

  Widget _buildStatsCard(DatabaseService1 databaseService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: FutureBuilder<int?>(
                future: databaseService.fetchNumberOfGasRequests(),
                builder: (context, requestsSnapshot) {
                  if (requestsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return FutureBuilder<num?>(
                    future: databaseService.fetchTotalEarnings(),
                    builder: (context, earningsSnapshot) {
                      if (earningsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return FutureBuilder<int?>(
                        future: databaseService.fetchNumberOfDeactivated(),
                        builder: (context, deactivatedSnapshot) {
                          if (deactivatedSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final numberOfRequests = requestsSnapshot.data ?? 0;
                          final earnings = earningsSnapshot.data ?? 0;
                          final deactivatedUsers = deactivatedSnapshot.data ?? 0;

                          return Row(
                            children: [
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      _buildPieSection(
                                          Colors.blue,
                                          numberOfRequests.toDouble(),
                                          'Requests'
                                      ),
                                      _buildPieSection(
                                          Colors.teal,
                                          earnings.toDouble(),
                                          'Earnings'
                                      ),
                                      _buildPieSection(
                                          Colors.redAccent,
                                          deactivatedUsers.toDouble(),
                                          'Deactivated'
                                      ),
                                    ],
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 40,
                                    startDegreeOffset: -90,
                                  ),
                                ),
                              ),
                              _buildLegend(numberOfRequests, earnings, deactivatedUsers),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActionsRow(databaseService),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieSection(Color color, double value, String title) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '',
      radius: 20,
      showTitle: false,
    );
  }

  Widget _buildLegend(int requests, num earnings, int deactivated) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.blue, 'Requests ($requests)', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Requests()));
        }),
        const SizedBox(height: 8),
        _buildLegendItem(Colors.teal, 'Earnings (GHS${earnings.toStringAsFixed(2)})', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const EarningScreen()));
        }),
        const SizedBox(height: 8),
        _buildLegendItem(Colors.redAccent, 'Deactivated ($deactivated)', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const DeactivatedUsers()));
        }),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(DatabaseService1 databaseService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FutureBuilder<num?>(
          future: databaseService.fetchNumberOfGasStation(),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return _buildQuickAction(
              'Gas Stations ($count)',
              Icons.local_gas_station,
              Colors.blue,
            );
          },
        ),
        _buildQuickAction(
          'Add Fun Fact',
          Icons.comment,
          Colors.orange,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFacts()));
          },
        ),
      ],
    );
  }

  Widget _buildQuickAction(String text, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingDeliveriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ongoing Deliveries",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ongoingRequests.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ongoingRequests.length,
            itemBuilder: (context, index) {
              final delivery = ongoingRequests[index];
              return _buildDeliveryItem(delivery);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryItem(Map<String, dynamic> delivery) {
    return FutureBuilder<String?>(
      future: _getFreshDownloadUrl(delivery['profilepicture']),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildDeliveryAvatar(imageUrl),
          title: Text(
            delivery['driver_name'] ?? 'Unknown Driver',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Client: ${delivery['client_name'] ?? 'Unknown'}'),
              Text('Amount: GHS${delivery['fare']?.toStringAsFixed(2) ?? '0.00'}'),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gas_meter, size: 20),
              Text('${delivery['Gas Amount'] ?? '0'} units'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryAvatar(String? imageUrl) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: _isValidImageUrl(imageUrl)
            ? CachedNetworkImage(
          imageUrl: imageUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) {
            debugPrint('Image load error: $error\nURL: $url');
            return const Icon(Icons.person, color: Colors.white);
          },
          httpHeaders: const {
            'Cache-Control': 'max-age=3600',
          },
          cacheKey: _generateCacheKey(imageUrl),
        )
            : const Icon(Icons.person, color: Colors.white),
      ),
    );
  }

  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute;
    } catch (e) {
      debugPrint('Invalid image URL: $url\nError: $e');
      return false;
    }
  }

  String _generateCacheKey(String url) {
    try {
      final uri = Uri.parse(url);
      return '${uri.host}${uri.path}'; // Use host + path as cache key
    } catch (e) {
      return url;
    }
  }

  Future<String?> _getFreshDownloadUrl(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final ref = FirebaseStorage.instance.refFromURL(path);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Failed to refresh download URL: $e');
      return null;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/authpage",
                      (route) => false
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchOngoingRequests() async {
    final databaseReference = FirebaseDatabase.instance.ref('GasRequests').orderByChild('status').equalTo('onride');
    final snapshot = await databaseReference.get();

    databaseReference.onValue.listen((event) {
      if (snapshot.exists) {
        final List<Map<String, dynamic>> requests = [];
        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          requests.add({
            'id': key,
            'driver_name': value['driver_name'],
            'client_name': value['client_name'],
            'fare': value['fare'],
            'client_phone': value['client_phone'],
            'profilepicture': value['profilepicture'],
            'Gas Amount': value['Gas Amount'],
          });
        });
        setState(() => ongoingRequests = requests);
      }
    });
  }

  void _loadRiders() {
    _ridersRef
        .orderByChild('earnings')
        .limitToLast(1)
        .once()
        .then((DatabaseEvent event) {
      _riders.clear();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic>? map = event.snapshot.value as Map<dynamic, dynamic>?;

        map?.forEach((key, value) {
          var carDetails = value['car_details'] as Map<dynamic, dynamic>?;

          _riders.add(
            Rider(
              key: key,
              name: value['FirstName'] ?? '',
              email: value['email'] ?? '',
              numberPlate: value['numberPlate']?.toString() ?? '',
              earnings: value['earnings']?.toString() ?? '',
              number: value['phoneNumber']?.toString() ?? '',
              imageUrl: value['riderImageUrl'] ?? '',
              ghcardimageUrl: carDetails?['GhanaCardUrl'],
              ghcard: carDetails?['GhanaCardNumber'],
              licensePlate: carDetails?['licensePlateNumber']?.toString() ?? '',
            ),
          );
        });
      }
      setState(() {});
    }).catchError((error) {
      debugPrint('Error loading riders: $error');
    });
  }

  void getCurrentArtisanInfo() async {
    currentfirebaseUser = await FirebaseAuth.instance.currentUser;
    admin.child(currentfirebaseUser!.uid).once().then((event) {
      if (event.snapshot.value is Map<Object?, Object?>) {
        riderinformation = Users.fromMap((event.snapshot.value as Map<Object?, Object?>).cast<String, dynamic>());
      }

      PushNotificationService pushNotificationService = PushNotificationService();
      pushNotificationService.initialize(context);
      pushNotificationService.getToken();
    });
  }
}