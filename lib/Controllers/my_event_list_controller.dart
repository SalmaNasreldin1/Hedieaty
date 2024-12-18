import '../Models/event_model.dart';
import 'gift_controller.dart';

class EventController {
  final EventModel _eventModel = EventModel();
  final GiftController _giftController = GiftController();


  Future<List<Map<String, dynamic>>> fetchEvents() async {
    return await _eventModel.getEvents();
  }

  Future<int> createEvent(Map<String, dynamic> eventData) async {
    // Add the event to SQLite and retrieve the inserted ID
    int newId = await _eventModel.addEvent(eventData);
    eventData['id'] = newId; // Set the ID in the eventData map

    if (eventData['published'] == 1) {
      // If the event is marked as published, publish it to Firestore
      await _eventModel.publishEventToFirebase(eventData);

      // Update SQLite with the Firestore ID
      await _eventModel.updateEvent(newId, {
        'firebase_id': eventData['firebase_id'],
      });
    }

    // Return the new SQLite ID
    return newId;
  }




  Future<void> editEvent(int id, Map<String, dynamic> eventData) async {
    await _eventModel.updateEvent(id, eventData); // Update SQLite first
    // If the event is published, update Firebase
    if (eventData['published'] == 1 && eventData['firebase_id'] != null) {
      await _eventModel.publishEventToFirebase(eventData);
    }
  }


  Future<void> removeEvent(int id, Map<String, dynamic> eventData) async {
    await _giftController.deleteGiftsByEvent(eventData['firebaseId']);
    // Delete event
    await _eventModel.deleteEvent(id, eventData['firebaseId']);
  }

  Future<void> publishEvent(Map<String, dynamic> eventData) async {
    eventData['published'] = 1;
    await _eventModel.publishEventToFirebase(eventData);
  }

  Future<void> unpublishEvent(Map<String, dynamic> eventData) async {
    eventData['published'] = 0;
    await _eventModel.unpublishEventFromFirebase(eventData);
  }
}
