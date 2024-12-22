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
  String _currentSortOption = 'name'; // Default sorting option

  void _sortGifts(String option) {
    setState(() {
      _currentSortOption = option;

      _gifts.sort((a, b) {
        switch (option) {
          case 'name':
            final nameA = a.name ?? '';
            final nameB = b.name ?? '';
            return nameA.compareTo(nameB);
          case 'category':
            final categoryA = a.category ?? '';
            final categoryB = b.category ?? '';
            return categoryA.compareTo(categoryB);
          case 'status':
            final statusOrder = ['available', 'pledged', 'purchased'];
            final statusA = statusOrder.indexOf(a.status ?? '');
            final statusB = statusOrder.indexOf(b.status ?? '');
            return statusA.compareTo(statusB);
          default:
            return 0;
        }
      });
    });
  }


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

  Future<void> _updateGiftStatus(String giftId, String newStatus) async {
    final gift = _gifts.firstWhere((gift) => gift.id == giftId);
    final updatedGift = Gift(
      id: gift.id,
      name: gift.name,
      description: gift.description,
      category: gift.category,
      price: gift.price,
      status: newStatus,
      published: gift.published,
      eventId: gift.eventId,
      imageLink: gift.imageLink,
      pledgedBy: gift.pledgedBy
    );

    await _controller.updateGift(updatedGift);
    _loadGifts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gift status updated to $newStatus.")),
    );
  }

  Future<void> _showGiftDialog([Gift? gift]) async {
    final nameController = TextEditingController(text: gift?.name ?? '');
    final descriptionController =
    TextEditingController(text: gift?.description ?? '');
    final categoryController =
    TextEditingController(text: gift?.category ?? '');
    final priceController =
    TextEditingController(text: gift != null ? gift.price.toString() : '');
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
          DropdownButton<String>(
            value: _currentSortOption,
            onChanged: (value) {
              if (value != null) {
                _sortGifts(value);
              }
            },
            items: [
              DropdownMenuItem(
                value: 'name',
                child: Text("Sort by Name"),
              ),
              DropdownMenuItem(
                value: 'category',
                child: Text("Sort by Category"),
              ),
              DropdownMenuItem(
                value: 'status',
                child: Text("Sort by Status"),
              ),
            ],
            icon: Icon(Icons.sort, color: Colors.white),
            underline: Container(), // Remove default underline
            dropdownColor: Colors.blueGrey, // Dropdown background color
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showGiftDialog(),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadGifts(),
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
              leading: gift.imageLink != null && gift.imageLink!.isNotEmpty
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
              trailing: gift.status == 'pledged'
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateGiftStatus(gift.id!, 'purchased'),
                    child: Text("Accept"),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _updateGiftStatus(gift.id!, 'available'),
                    child: Text("Reject"),
                    style: ElevatedButton.styleFrom(iconColor: Colors.red),
                  ),
                ],
              )
                  : Row(
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
