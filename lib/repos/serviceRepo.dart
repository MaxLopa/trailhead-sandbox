import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sandbox_project/models/client.dart';
import 'package:sandbox_project/models/service.dart';

class ServiceRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CHANGED: strongly typed collection
  late final CollectionReference<Map<String, dynamic>> services;

  ServiceRepo() {
    services = _db.collection('services');
  }

  Future<DocumentReference<Map<String, dynamic>>> createService(Service service) async {
    return services.add(service.toMap());
  }

  Future<void> updateService(
    DocumentReference<Map<String, dynamic>> serviceRef,
    Service service,
  ) async {
    await serviceRef.update(service.toMap());
  }

  Future<List<Service>> fetchAllServices() async {
    final snap = await services.get();

    // CHANGED: handle null/invalid docs safely
    final out = <Service>[];
    for (final doc in snap.docs) {
      final data = doc.data(); // Map<String, dynamic>
      // If you ever get an empty doc, skip it
      if (data.isEmpty) continue;

      try {
        out.add(Service.fromMap(data));
      } catch (_) {
        // optional: skip bad-shaped docs instead of crashing
        continue;
      }
    }
    return out;
  }

  Future<List<Service>> fetchServicesByClient(Client client) async {
    final snap = await services.where('client.id', isEqualTo: client.id).get();

    final out = <Service>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data.isEmpty) continue;

      try {
        out.add(Service.fromMap(data));
      } catch (_) {
        continue;
      }
    }
    return out;
  }
}
