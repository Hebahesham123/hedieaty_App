import 'package:flutter/material.dart';
import 'package:hediaty_appp/Controllers/Gift_controller.dart';
import 'package:hediaty_appp/Classes/Gift.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftListScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  GiftListScreen({required this.eventId, required this.eventName});

  @override
  _GiftListScreenState createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  final GiftController _controller = GiftController();
  List<Gift> _gifts = [];

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    await _syncGifts();
    final gifts = await _controller.fetchGifts(widget.eventId);
    setState(() {
      _gifts = gifts;
    });
  }

  Future<void> _syncGifts() async {
    await _controller.syncGifts(widget.eventId);
  }

  Future<void> _pledgeGift(Gift gift) async {
    final String currentUserId = (FirebaseAuth.instance.currentUser?.uid)!;

    final updatedGift = Gift(
      id: gift.id,
      name: gift.name,
      description: gift.description,
      category: gift.category,
      price: gift.price,
      status: 'pledged', // Update the status to 'pledged'
      published: gift.published,
      eventId: gift.eventId,
      imageLink: gift.imageLink,
      pledgedBy: currentUserId, // Set the pledgedBy field
    );

    await _controller.updateGift(updatedGift); // Update the gift in the database

    // Reload the gifts to reflect changes
    _loadGifts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${gift.name} has been pledged by you.")),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.eventName} Gifts"),
      ),
      body: _gifts.isEmpty
          ? Center(
        child: Text("No gifts found for this event."),
      )
          : ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: gift.imageLink != null && gift.imageLink!.isNotEmpty
                  ? Image.network(
                gift.imageLink!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 50); // Fallback for invalid URLs
                },
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : CircularProgressIndicator();
                },
              )
                  : Icon(Icons.image, size: 50), // Placeholder for no image
              title: Text(gift.name),
              subtitle: Text("Price: \$${gift.price} | Status: ${gift.status}"),
              trailing: gift.status != 'pledged'
                  ? ElevatedButton(
                onPressed: () => _pledgeGift(gift),
                child: Text("Pledge"),
              )
                  : Icon(Icons.done, color: Colors.green, size: 30), // Indicate already pledged
            ),
          );
        },
      ),
    );
  }
}
