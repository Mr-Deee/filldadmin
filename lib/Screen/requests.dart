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

  @override
  void initState() {
    super.initState();
    fetchGasRequests();
    fetchRidersDeliveries();
    fetchOngoingRequests();
  }

  Future<void> fetchGasRequests() async {
    final databaseReference = FirebaseDatabase.instance.ref('gasRequests');
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
      setState(() {
        gasRequests = (snapshot.value as List).map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> fetchRidersDeliveries() async {
    final databaseReference = FirebaseDatabase.instance.ref('GasRequests');
    final snapshot = await databaseReference.get();

   

      if (snapshot.exists) {
      final List<Map<String, dynamic>> deliveries = [];
      (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
        if (value['status'] == 'ongoing') {
          deliveries.add({
            'driver_name': value['driver_name'],
            'client_name': value['client_name'],
            // 'completedDeliveries': value['completedDeliveries'],
            'fares': value['fares'],
          });
        }
      });
      setState(() {
        ridersDeliveries = deliveries;
        //(snapshot.value as List).map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> fetchOngoingRequests() async {
    final databaseReference = FirebaseDatabase.instance.ref('GasRequests').orderByChild('status').equalTo('ended');
    final snapshot = await databaseReference.get();

    if (snapshot.exists) {
       final List<Map<String, dynamic>> requests = [];
      (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
        requests.add({
          'id': key,
          'driver_name': value['driver_name'],
          'client_name': value['client_name'],
          'fare': value['fare'],
           'clientphone': value['client_phone'],
          // 'gasPrice': value['gasPrice'],
          // 'location': value['location'],
          // 'kilometers': value['kilometers'],
        });
      });
      setState(() {
        ongoingRequests = requests;
        
        //(snapshot.value as List).map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests"),
        actions: [
    
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  showGasRequests(context);
                },
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Gas Requests",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.local_gas_station, size: 50),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showRidersDeliveries(context);
                },
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Riders' Deliveries",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.delivery_dining, size: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          ongoingRequests.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : 
          Expanded(
            child: ListView.builder(
              itemCount: ongoingRequests.length,
              itemBuilder: (context, index) {
                final request = ongoingRequests[index];
                return ListTile(
                  title: Text("Client Name: ${request['client_name']}"),
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
      MaterialPageRoute(builder: (context) => GasRequestsScreen( filter: selectedFilter)),
    
    );
  }

  void showRidersDeliveries(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RidersDeliveriesScreen(filter: selectedFilter, ridersDeliveries: [],)),    );
  }
}




class GasRequestsScreen extends StatefulWidget {
  final String filter;

  GasRequestsScreen({required this.filter});

  @override
  _GasRequestsScreenState createState() => _GasRequestsScreenState();
}


class _GasRequestsScreenState extends State<GasRequestsScreen> {
  late String selectedFilter;
  late List<Map<String, dynamic>> gasRequests;
  late List<Map<String, dynamic>> filteredRequests;
  DateTime? selectedDate;
  bool isLoading = true;

 @override
  void initState() {
    super.initState();
    selectedFilter = widget.filter;
    gasRequests = [];
    filteredRequests = [];
    fetchGasRequests();
  }

  Future<void> fetchGasRequests() async {
    Query ref = FirebaseDatabase.instance.ref('GasRequests').orderByChild('status').equalTo('onride');
    DataSnapshot snapshot = await ref.get();
    // List<Map<String, dynamic>> requests = [];
    // for (var data in snapshot.children) {
    //   Map<String, dynamic> request = Map<String, dynamic>.from(data.value as Map);
    //   requests.add(request);
    // }

    if (snapshot.exists) {
      final List<Map<String, dynamic>> requests = [];
      (snapshot.value as Map<dynamic, dynamic>).forEach((key, value) {
     
          requests.add({
            'id': key,
            'driver_name': value['driver_name'],
            'client_name': value['client_name'],
            'fare': value['deliveryPrice'],
            // 'gasPrice': value['gasPrice'],
            // 'location': value['location'],
            // 'kilometers': value['kilometers'],
          });
      
      });
    setState(() {
      gasRequests = requests;
      filteredRequests = gasRequests;
      isLoading = false;
    });
  }
  }
  void filterRequests() {
    setState(() {
      if (selectedDate != null) {
        filteredRequests = gasRequests.where((request) {
          DateTime requestDate = DateTime.parse(request['date']);
          if (selectedFilter == 'Day') {
            return requestDate.year == selectedDate!.year &&
                requestDate.month == selectedDate!.month &&
                requestDate.day == selectedDate!.day;
          } else if (selectedFilter == 'Month') {
            return requestDate.year == selectedDate!.year &&
                requestDate.month == selectedDate!.month;
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
        title: Text('Client Requests'),
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
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                return ListTile(
                  title: Text("Request ID: ${request['id']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rider: ${request['driver_name']}"),
                      Text("Client: ${request['client_name']}"),
                      // Text("Delivery Price: ${request['deliveryPrice']}"),
                      // Text("Gas Price: ${request['gasPrice']}"),
                      // Text("Location: ${request['location']}"),
                      // Text("Kilometers: ${request['kilometers']}"),
                    ],
                  ),
                );
              },
            ),
    );
  }
  }
  





class RidersDeliveriesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> ridersDeliveries;
  final String filter;

  RidersDeliveriesScreen({required this.ridersDeliveries, required this.filter});

  @override
  _RidersDeliveriesScreenState createState() => _RidersDeliveriesScreenState();
}

class _RidersDeliveriesScreenState extends State<RidersDeliveriesScreen> {
  late String selectedFilter;
  late List<Map<String, dynamic>> filteredDeliveries;
  DateTime? selectedDate;

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riders Deliveries'),
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
            icon: Icon(Icons.calendar_today),
            onPressed: (){},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredDeliveries.length,
        itemBuilder: (context, index) {
          final delivery = filteredDeliveries[index];
          return ListTile(
            title: Text("Rider: ${delivery['rider']}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Client: ${delivery['client']}"),
                Text("Completed Deliveries: ${delivery['completedDeliveries']}"),
                Text("Fare: ${delivery['fare']}"),
              ],
            ),
          );
        },
      ),
    );
  }
}




 
  
