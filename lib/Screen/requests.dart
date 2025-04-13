import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  String selectedFilter = 'Month'; // Default filter
  List<Map<String, dynamic>> gasRequests = [];
  List<Map<String, dynamic>> ridersDeliveries = [];
  List<Map<String, dynamic>> ongoingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.wait([
     fetchGasRequests(),
      fetchRidersDeliveries(),
      fetchOngoingRequests(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchGasRequests() async {
    final databaseReference = FirebaseDatabase.instance.ref('GasRequests');
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      final List<Map<String, dynamic>> requests = [];
      if (snapshot.value is Map) {
        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          final requestData = value is Map ? Map<String, dynamic>.from(value) : {};

          // Convert status to string and handle null case
          String status;
          if (requestData['status'] == null) {
            status = 'unknown';
          } else if (requestData['status'] is int) {
            // If status comes as int, convert to string representation
            status = requestData['status'].toString();
          } else {
            status = requestData['status'].toString();
          }

          requests.add({
            'id': key.toString(),
            'driver_name': requestData['driver_name']?.toString() ?? 'Unknown',
            'client_name': requestData['client_name']?.toString() ?? 'Unknown',
            'fare': _convertToDouble(requestData['fare']),
            'Gas Amount': _convertToDouble(requestData['Gas Amount']),
            'status': status,
          });
        });
      }
      setState(() {
        gasRequests = requests;
      });
    }
  }

  double _convertToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }


  Future<void> fetchRidersDeliveries() async {
    final databaseReference = FirebaseDatabase.instance.ref('GasRequests');
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      final List<Map<String, dynamic>> deliveries = [];
      if (snapshot.value is Map) {
        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          final deliveryData = value is Map ? Map<String, dynamic>.from(value) : {};

          // Handle status conversion
          final status = deliveryData['status']?.toString().toLowerCase() ?? '';
          if (status == 'ongoing') {
            deliveries.add({
              'id': key.toString(),
              'driver_name': deliveryData['driver_name']?.toString() ?? 'Unknown',
              'client_name': deliveryData['client_name']?.toString() ?? 'Unknown',
              'fare': _convertToDouble(deliveryData['fare']),
              'profilepicture': deliveryData['profilepicture']?.toString() ?? '',
            });
          }
        });
      }
      setState(() {
        ridersDeliveries = deliveries;
      });
    }
  }

  Future<void> fetchOngoingRequests() async {
    final databaseReference = FirebaseDatabase.instance.ref('GasRequests');
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      final List<Map<String, dynamic>> requests = [];
      if (snapshot.value is Map) {
        (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
          final requestData = value is Map ? Map<String, dynamic>.from(value) : {};

          // Handle status conversion
          final status = requestData['status']?.toString().toLowerCase() ?? '';
          if (status == 'ended') {
            requests.add({
              'id': key.toString(),
              'driver_name': requestData['driver_name']?.toString() ?? 'Unknown',
              'client_name': requestData['client_name']?.toString() ?? 'Unknown',
              'fare': _convertToDouble(requestData['fare']),
              'clientphone': requestData['client_phone']?.toString() ?? '',
            });
          }
        });
      }
      setState(() {
        ongoingRequests = requests;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requests"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    showGasRequests(context);
                  },
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            "Gas Requests",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.local_gas_station, size: 50),
                          Text("${gasRequests.length} requests"),
                        ],
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    showOngoingRequests(context);
                  },
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            "Completed",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.check_circle, size: 50),
                          Text("${ongoingRequests.length} completed"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: ongoingRequests.length,
              itemBuilder: (context, index) {
                final request = ongoingRequests[index];
                return ListTile(
                  title: Text(
                      "Client Name: ${request['client_name']}"),
                  subtitle: Text("Fare: ${request['fare']}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showGasRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GasRequestsScreen(filter: selectedFilter)),
    );
  }

  void showRidersDeliveries(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RidersDeliveriesScreen(
            filter: selectedFilter,
            ridersDeliveries: ridersDeliveries,
          )),
    );
  }

  void showOngoingRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OngoingRequestsScreen(
            filter: selectedFilter,
            requests: ongoingRequests,
          )),
    );
  }
}

class GasRequestsScreen extends StatefulWidget {
  final String filter;

  const GasRequestsScreen({required this.filter});

  @override
  _GasRequestsScreenState createState() => _GasRequestsScreenState();
}

class _GasRequestsScreenState extends State<GasRequestsScreen> {
  late String selectedFilter;
  List<Map<String, dynamic>> gasRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];
  DateTime? selectedDate;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.filter;
    fetchGasRequests();
  }

  Future<void> fetchGasRequests() async {
    try {
      final ref = FirebaseDatabase.instance.ref('GasRequests');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        final List<Map<String, dynamic>> requests = [];

        if (snapshot.value is Map) {
          (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
            try {
              final requestData = value is Map ? Map<String, dynamic>.from(value) : {};

              requests.add({
                'id': key?.toString() ?? 'N/A',
                'driver_name': requestData['driver_name']?.toString() ?? 'Unknown',
                'client_name': requestData['client_name']?.toString() ?? 'Unknown',
                'fare': _parseDouble(requestData['fare']),
                'Gas Amount': _parseDouble(requestData['Gas Amount']),
                'date': _parseDate(requestData['date']),
                'status': requestData['status']?.toString()?.toLowerCase() ?? 'unknown',
              });
            } catch (e) {
              debugPrint('Error parsing request $key: $e');
            }
          });
        }

        setState(() {
          gasRequests = requests;
          filteredRequests = requests;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No requests found in database';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load requests: ${e.toString()}';
      });
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is String) return dateValue;
    if (dateValue is int) return DateTime.fromMillisecondsSinceEpoch(dateValue).toIso8601String();
    return null;
  }

  void filterRequests() {
    setState(() {
      if (selectedDate != null) {
        filteredRequests = gasRequests.where((request) {
          try {
            final dateString = request['date'];
            if (dateString == null) return false;

            final requestDate = DateTime.parse(dateString);

            if (selectedFilter == 'Day') {
              return requestDate.year == selectedDate!.year &&
                  requestDate.month == selectedDate!.month &&
                  requestDate.day == selectedDate!.day;
            } else if (selectedFilter == 'Month') {
              return requestDate.year == selectedDate!.year &&
                  requestDate.month == selectedDate!.month;
            }
          } catch (e) {
            debugPrint('Error filtering by date: $e');
            return false;
          }
          return false;
        }).toList();
      } else {
        filteredRequests = gasRequests;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        filterRequests();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Client Requests'),
        actions: [
          DropdownButton<String>(
            value: selectedFilter,
            items: <String>['Day', 'Month'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedFilter = newValue!;
                filterRequests();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchGasRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredRequests.isEmpty) {
      return const Center(
        child: Text(
          'No requests found for selected filter',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchGasRequests,
      child: ListView.builder(
        itemCount: filteredRequests.length,
        itemBuilder: (context, index) {
          final request = filteredRequests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header row with ID and status
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Request #${request['id']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(request['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                request['status'].toString().toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Gas icon and amount
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_gas_station,
                size: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${request['Gas Amount']} units',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Details in two columns
        Row(
          children: [
        Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person_outline, 'Client', request['client_name']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.directions_car, 'Driver', request['driver_name']),
          ],
        ),
      ),
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              _buildInfoRow(Icons.attach_money, 'Fare', 'GHS ${request['fare'].toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          if (request['date'] != null)
      _buildInfoRow(
      Icons.calendar_today,
      'Date',
      DateFormat('MMM dd, yyyy').format(DateTime.parse(request['date'])),
      )],
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
class RidersDeliveriesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> ridersDeliveries;
  final String filter;

  const RidersDeliveriesScreen({
    required this.ridersDeliveries,
    required this.filter,
  });

  @override
  _RidersDeliveriesScreenState createState() => _RidersDeliveriesScreenState();
}

class _RidersDeliveriesScreenState extends State<RidersDeliveriesScreen> {
  late String selectedFilter;
  late List<Map<String, dynamic>> filteredDeliveries;
  DateTime? selectedDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.filter;
    filteredDeliveries = widget.ridersDeliveries;
  }

  void filterDeliveries() {
    setState(() {
      if (selectedDate != null) {
        filteredDeliveries = widget.ridersDeliveries.where((delivery) {
          if (delivery['date'] == null) return false;
          DateTime deliveryDate = DateTime.parse(delivery['date']);
          if (selectedFilter == 'Day') {
            return deliveryDate.year == selectedDate!.year &&
                deliveryDate.month == selectedDate!.month &&
                deliveryDate.day == selectedDate!.day;
          } else if (selectedFilter == 'Month') {
            return deliveryDate.year == selectedDate!.year &&
                deliveryDate.month == selectedDate!.month;
          }
          return false;
        }).toList();
      } else {
        filteredDeliveries = widget.ridersDeliveries;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        filterDeliveries();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riders Deliveries'),
        actions: [
          DropdownButton<String>(
            value: selectedFilter,
            items: <String>['Day', 'Month'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedFilter = newValue!;
                filterDeliveries();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredDeliveries.isEmpty
          ? const Center(child: Text('No deliveries found'))
          : ListView.builder(
        itemCount: filteredDeliveries.length,
        itemBuilder: (context, index) {
          final delivery = filteredDeliveries[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Container(
                width: 60,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: delivery['profilepicture'] != null &&
                      delivery['profilepicture'].isNotEmpty
                      ? NetworkImage(delivery['profilepicture'])
                      : const AssetImage(
                      "assets/images/useri.png")
                  as ImageProvider,
                ),
              ),
              title: Text("Rider: ${delivery['driver_name']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("To Client: ${delivery['client_name']}"),
                  Text("Fare: GHS ${delivery['fare']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OngoingRequestsScreen extends StatelessWidget {
  final String filter;
  final List<Map<String, dynamic>> requests;

  const OngoingRequestsScreen({
    required this.filter,
    required this.requests,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Requests'),
      ),
      body: requests.isEmpty
          ? const Center(child: Text('No completed requests found'))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Client: ${request['client_name']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phone: ${request['clientphone']}"),
                  Text("Fare: GHS ${request['fare']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}