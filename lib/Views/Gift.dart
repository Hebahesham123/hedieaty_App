import 'package:flutter/material.dart';
import 'package:hediaty_appp/Controllers/Gift_controller.dart';
import 'package:hediaty_appp/Classes/Gift.dart';

class GiftManagementScreen extends StatefulWidget {
  final String eventId;

  GiftManagementScreen({required this.eventId});

  @override
  _GiftManagementScreenState createState() => _GiftManagementScreenState();
}

class _GiftManagementScreenState extends State<GiftManagementScreen> {
  final GiftController _controller = GiftController();
  List<Gift> _gifts = [];
  final _formKey = GlobalKey<FormState>();

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

  Future<void> _deleteGift(String giftId) async {
    await _controller.deleteGift(giftId);
    _loadGifts();
  }

  Future<void> _toggleGiftPublished(String giftId, bool newStatus) async {
    await _controller.toggleGiftPublishedStatus(giftId, newStatus);
    _loadGifts();
  }

  Future<void> _showGiftDialog([Gift? gift]) async {
    final nameController = TextEditingController(text: gift?.name ?? '');
    final descriptionController =
    TextEditingController(text: gift?.description ?? '');
    final categoryController =
    TextEditingController(text: gift?.category ?? '');
    final priceController = TextEditingController(
        text: gift != null ? gift.price.toString() : '');
    final statusController =
    TextEditingController(text: gift?.status ?? 'available');
    final imageLinkController =
    TextEditingController(text: gift?.imageLink ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(gift == null ? "Create Gift" : "Update Gift"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(labelText: 'Category'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Category is required'
                        : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Enter a valid price greater than 0';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: statusController.text,
                    decoration: InputDecoration(labelText: 'Status'),
                    items: ['available', 'pledged', 'purchased']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) {
                      statusController.text = value!;
                    },
                  ),
                  TextFormField(
                    controller: imageLinkController,
                    decoration: InputDecoration(labelText: 'Image Link'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (gift == null) {
                    // Create new gift
                    await _controller.createGift(
                      Gift(
                        name: nameController.text,
                        description: descriptionController.text,
                        category: categoryController.text,
                        price: double.parse(priceController.text),
                        status: statusController.text,
                        eventId: widget.eventId,
                        imageLink: imageLinkController.text,
                      ),
                    );
                  } else {
                    // Update existing gift
                    await _controller.updateGift(
                      Gift(
                        id: gift.id,
                        name: nameController.text,
                        description: descriptionController.text,
                        category: categoryController.text,
                        price: double.parse(priceController.text),
                        status: statusController.text,
                        published: gift.published,
                        eventId: widget.eventId,
                        imageLink: imageLinkController.text,
                      ),
                    );
                  }
                  Navigator.pop(context);
                  _loadGifts();
                }
              },
              child: Text(gift == null ? "Create" : "Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Gifts"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showGiftDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _gifts.length,
        itemBuilder: (context, index) {
          final gift = _gifts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: gift.imageLink != null
                  ? Image.network(
                '${gift.imageLink!}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 50);
                },
              )
                  : Icon(Icons.image_not_supported, size: 50),
              title: Text(gift.name),
              subtitle: Text(
                "Category: ${gift.category} | Price: \$${gift.price.toStringAsFixed(2)} | Status: ${gift.status}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      gift.published ? Icons.check_box : Icons.check_box_outline_blank,
                    ),
                    onPressed: () => _toggleGiftPublished(gift.id!, !gift.published),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showGiftDialog(gift),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteGift(gift.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
