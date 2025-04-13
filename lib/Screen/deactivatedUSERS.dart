import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../Models/Rider.dart';

class DeactivatedUsers extends StatefulWidget {
  const DeactivatedUsers({super.key});

  @override
  State<DeactivatedUsers> createState() => _DeactivatedUsersState();
}

class _DeactivatedUsersState extends State<DeactivatedUsers> {
  final DatabaseReference _ridersRef = FirebaseDatabase.instance.ref().child('Riders');
  List<Rider> _riders = [];
  bool _isLoading = true;
  bool _isSendingSMS = false;

  @override
  void initState() {
    super.initState();
    _loadRiders();
  }

  Future<void> _loadRiders() async {
    try {
      _ridersRef.onValue.listen((event) {
        final List<Rider> loadedRiders = [];
        final data = event.snapshot.value;

        if (data is Map) {
          data.forEach((key, value) {
            if (value is Map && value['status'] == 'deactivated') {
              final carDetails = value['car_details'] as Map?;
              loadedRiders.add(_createRiderFromData(key, value, carDetails));
            }
          });
        }

        if (mounted) {
          setState(() {
            _riders = loadedRiders;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Failed to load riders: ${e.toString()}');
      }
    }
  }

  Rider _createRiderFromData(String key, Map<dynamic, dynamic> value, Map? carDetails) {
    return Rider(
      key: key,
      name: value['FirstName']?.toString() ?? 'No Name',
      email: value['email']?.toString() ?? 'No Email',
      number: value['phoneNumber']?.toString() ?? '',
      numberPlate: value['numberPlate']?.toString() ?? '',
      earnings: value['earnings']?.toString() ?? '0',
      imageUrl: carDetails?['riderImageUrl']?.toString() ?? '',
      ghcardimageUrl: carDetails?['ghanaCardUrl']?.toString() ?? '',
      ghcard: carDetails?['ghanaCardNumber']?.toString() ?? '',
      licensePlate: carDetails?['licensePlateNumber']?.toString() ?? '',
    );
  }

  Future<void> _editRiderStatus(Rider rider) async {
    try {
      await _ridersRef.child(rider.key).update({'status': 'activated'});
      if (mounted) {
        _showSuccessSnackbar('Rider activated successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to activate rider: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deactivated Users",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_riders.isEmpty) {
      return const Center(
        child: Text('No deactivated riders found',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _riders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildRiderCard(_riders[index]),
    );
  }

  Widget _buildRiderCard(Rider rider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildRiderAvatar(rider.imageUrl),
        title: Text(
          rider.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          rider.email,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showRiderDetails(rider),
      ),
    );
  }

  Widget _buildRiderAvatar(String imageUrl) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.grey[200],
      child: ClipOval(
        child: _isValidImageUrl(imageUrl)
            ? CachedNetworkImage(
          imageUrl: imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.person,
            size: 30,
            color: Colors.white,
          ),
          httpHeaders: const {
            'Cache-Control': 'max-age=3600',
          },
          cacheKey: _generateCacheKey(imageUrl),
        )
            : const Icon(
          Icons.person,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute;
    } catch (e) {
      return false;
    }
  }

  String _generateCacheKey(String url) {
    return Uri.parse(url).path; // Use path as cache key to avoid token changes
  }
  void _showRiderDetails(Rider  rider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rider Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailSection('Profile Image', _buildImageContainer(rider.imageUrl)),
              _buildDetailSection('Ghana Card', _buildImageContainer(rider.ghcardimageUrl!)),
              const SizedBox(height: 16),
              _buildDetailRow('Name', rider.name),
              _buildDetailRow('Email', rider.email),
              _buildDetailRow('Phone', rider.number),
              _buildDetailRow('License Plate', rider.licensePlate),
              _buildDetailRow('Ghana Card No.', rider.ghcard!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          _isSendingSMS
              ? const CircularProgressIndicator()
              : TextButton(
            onPressed: () => _handleRiderActivation(rider),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        content,
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }


  Widget _buildImageContainer(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blue[400],
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 40, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        httpHeaders: {
          // Add any required headers here
          'Cache-Control': 'max-age=3600',
        },
      )
          : const Center(
        child: Icon(
          Icons.image,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _handleRiderActivation(Rider rider) async {
    setState(() => _isSendingSMS = true);

    try {
      await _sendActivationSMS(rider);
      await _editRiderStatus(rider);
      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackbar('Rider activated and notified');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Failed to activate rider: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingSMS = false);
      }
    }
  }

  Future<void> _sendActivationSMS(Rider rider) async {
    final message = "Dear ${rider.name}, your uploaded documents have been reviewed and approved. "
        "Welcome to a world of convenience, accept requests and earn as much you like. "
        "Thank you for delivering with Fill'D.";

    if (rider.number.isEmpty) {
      throw Exception('Phone number is missing');
    }

    final response = await http.post(
      Uri.parse('https://filldadmin.vercel.app/api/sendSms'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'phoneNumber': rider.number.trim(),
        'message': message,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send SMS: ${response.body}');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}