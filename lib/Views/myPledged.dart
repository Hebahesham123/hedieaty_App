import 'dart:convert'; // For base64 decoding
import 'package:flutter/material.dart';
import 'package:hediaty_appp/Controllers/Gift_controller.dart';
import 'package:hediaty_appp/Classes/Gift.dart';

class PledgedGiftsPage extends StatefulWidget {
  final String userId; // User ID for filtering pledged gifts

  PledgedGiftsPage({required this.userId});

  @override
  _PledgedGiftsPageState createState() => _PledgedGiftsPageState();
}

class _PledgedGiftsPageState extends State<PledgedGiftsPage> {
  final GiftController _controller = GiftController();
  List<Gift> _pledgedGifts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPledgedGifts();
  }

  Future<void> _loadPledgedGifts() async {
    try {
      final pledgedGifts = await _controller.fetchPledgedGiftsByUser(widget.userId);
      setState(() {
        _pledgedGifts = pledgedGifts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pledged gifts: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Pledged Gifts"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pledgedGifts.isEmpty
          ? Center(
        child: Text(
          "You haven't pledged any gifts yet.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: _pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = _pledgedGifts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: gift.imageLink != null
                  ? Image.network(
                gift.imageLink!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 50);
                },
              )
                  : Icon(Icons.image_not_supported, size: 50),
              title: Text(
                gift.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Category: ${gift.category} | Price: \$${gift.price.toStringAsFixed(2)}",
              ),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
