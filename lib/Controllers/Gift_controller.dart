import 'package:hediaty_appp/Models/Gift_model.dart';
import 'package:uuid/uuid.dart';
import 'package:hediaty_appp/Classes/Gift.dart';
import 'package:hediaty_appp/Models/Event_model.dart';
class GiftController {
  final GiftModel _giftModel = GiftModel();
  final EventModel _eventModel = EventModel();
  // Create Gift
  final Uuid _uuid = Uuid();

  // Create Gift
  Future<void> createGift(Gift gift) async {
    // Generate a UUID for the new gift
    final String giftId = _uuid.v4();

    // Create a new gift with UUID
    Gift newGift = Gift(
      id: giftId,
      name: gift.name,
      description: gift.description,
      category: gift.category,
      price: gift.price,
      status: gift.status,
      published: gift.published,
      eventId: gift.eventId,
      imageLink: gift.imageLink,
    );

    await _giftModel.saveToLocal(newGift);
    if (newGift.published) {
      await _giftModel.saveToRemote(newGift);
    }
  }

  // Update Gift
  Future<void> updateGift(Gift gift) async {
    await _giftModel.updateGiftInLocal(gift);
    if (gift.published) {
      await _giftModel.saveToRemote(gift);
    }
  }

  // Delete Gift
  Future<void> deleteGift(String giftId) async {
    await _giftModel.deleteFromLocal(giftId);
    await _giftModel.deleteFromRemote(giftId);
  }

  // Fetch Gifts
  Future<List<Gift>> fetchGifts(String eventId) async {
    return await _giftModel.fetchGiftsByEvent(eventId);
  }

  // Sync Firestore gifts with local SQLite
  Future<void> syncGifts(String eventId) async {
    await _giftModel.syncGiftsWithLocal(eventId);
  }

  // Toggle Published Status for Gift
  Future<void> toggleGiftPublishedStatus(String giftId, bool newStatus) async {
    // Fetch the gift by ID
    final gift = await _giftModel.getGiftById(giftId);

    if (gift == null) {
      print("Error: Gift with ID $giftId not found.");
      return;
    }

    // Fetch the parent event
    final event = await _eventModel.getEventById(gift.eventId);

    if (event == null) {
      print("Error: Parent event not found for gift with ID $giftId.");
      return;
    }

    // Check if the parent event is published
    if (!event.published && newStatus) {
      // If the event is not published, prevent publishing the gift
      print("Error: Cannot publish gift. Parent event is not published.");
      return;
    }

    // Update the gift's published status
    final updatedGift = Gift(
      id: gift.id,
      name: gift.name,
      description: gift.description,
      category: gift.category,
      price: gift.price,
      status: gift.status,
      published: newStatus, // Set the new published status
      eventId: gift.eventId,
      imageLink: gift.imageLink,
    );

    // Update SQLite
    await _giftModel.updateGiftInLocal(updatedGift);

    // Update Firestore if published
    if (newStatus) {
      await _giftModel.saveToRemote(updatedGift);
      print("Gift with ID $giftId published.");
    } else {
      await _giftModel.deleteFromRemote(giftId);
      print("Gift with ID $giftId unpublished.");
    }
  }

  Future<List<Gift>> fetchPledgedGiftsByUser(String userId) async {
    return await _giftModel.fetchPledgedGiftsByUser(userId);
  }

}
