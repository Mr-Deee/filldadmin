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
        title: const Text(
          "Requests Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Stats Cards Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatCard(
                    context: context,
                    title: "Completed",
                    count: gasRequests.length,
                    icon: Icons.local_gas_station,
                    color: Colors.green,
                    onTap: () => showGasRequests(context),
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    context: context,
                    title: "Ongoing",
                    count: ongoingRequests.length,
                    icon: Icons.timer,
                    color: Colors.orange,
                    onTap: () => showOngoingRequests(context),
                  ),
                ],
              ),
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              height: 1,
              color: Colors.grey[300],
            ),
          ),

          // Requests List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: ongoingRequests.length,
              itemBuilder: (context, index) {
                final request = ongoingRequests[index];
                return _buildRequestItem(request);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "$count requests",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: Colors.blue[700],
          ),
        ),
        title: Text(
          request['client_name'] ?? 'Unknown Client',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Fare: GHS ${request['fare']?.toStringAsFixed(2) ?? '0.00'}",
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            if (request['date'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(request['date'])),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
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

  const GasRequestsScreen({required this.filter, Key? key}) : super(key: key);

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
          filteredRequests = requests.where((req) => req['status'] == 'completed').toList();
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
            if (request['status'] != 'completed') return false;

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
        filteredRequests = gasRequests.where((req) => req['status'] == 'completed').toList();
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
        title: const Text('Completed Requests'),
        elevation: 0,
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
          'No completed requests found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchGasRequests,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
        padding: const EdgeInsets.all(16),
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

class OngoingRequestsScreen extends StatefulWidget {
  final String filter;
  final List<Map<String, dynamic>> requests;

  const OngoingRequestsScreen({
    required this.filter,
    required this.requests,
    Key? key,
  }) : super(key: key);

  @override
  State<OngoingRequestsScreen> createState() => _OngoingRequestsScreenState();
}

class _OngoingRequestsScreenState extends State<OngoingRequestsScreen> {
  late List<Map<String, dynamic>> _requests;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('GasRequests');
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _requests = List.from(widget.requests);
  }

  Future<void> _deleteRequest(String requestId, int index) async {
    try {
      setState(() => _isDeleting = true);

      await _databaseRef.child(requestId).remove();

      setState(() {
        _requests.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request deleted successfully')),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete request: ${e.toString()}')),
      );
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue,
        ),
        const SizedBox(height: 4),
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
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default: // ongoing
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.filter} Requests'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[50],
      body: _requests.isEmpty
          ? Center(
        child: Text(
          'No ${widget.filter} requests found',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final request = _requests[index];
          return Dismissible(
            key: Key(request['id'] ?? UniqueKey().toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Are you sure you want to delete this request?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              _deleteRequest(request['id'], index);
            },
            child: _buildRequestCard(request, index),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, int index) {
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with client info
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['client_name'] ?? 'Unknown Client',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request['clientphone'] ?? 'No phone provided',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isDeleting && request['isDeleting'] == true)
                  const CircularProgressIndicator()
                else
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _deleteRequest(request['id'], index);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Details section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  icon: Icons.local_gas_station,
                  label: 'Fuel Type',
                  value: request['fuel_type'] ?? 'N/A',
                ),
                _buildDetailItem(
                  icon: Icons.attach_money,
                  label: 'Fare',
                  value: 'GHS ${request['fare']?.toStringAsFixed(2) ?? '0.00'}',
                ),
                _buildDetailItem(
                  icon: Icons.schedule,
                  label: 'Duration',
                  value: request['duration'] ?? 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status and action button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request['status']),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    (request['status'] ?? 'ongoing').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Add action for completing/cancelling request
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.filter == 'Ongoing' ? 'Complete' : 'View Details',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}