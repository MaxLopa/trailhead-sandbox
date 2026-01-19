import 'package:sandbox_project/models/client.dart';
import 'package:sandbox_project/models/host.dart';
import 'package:sandbox_project/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sandbox_project/repos/serviceRepo.dart';

class Service {
  static final List<String> serviceStatus = [
    'Service Created'
    'Waiting for Host acceptance',
    'In Progress',
    'Finished',
    'Waiting for Client confirmation',
    'Confirmed by Client',
    'Cancelled',
  ];
  static ServiceRepo serviceRepo = ServiceRepo();

  final ClientOrder order;
  Client? client;
  Host? host;
  int status = 0;

  Service({required this.order, this.client, this.host});

  factory Service.fromMap(Map<String, dynamic> json) {
    return Service(
      order: ClientOrder.fromMap(json['order'] as Map<String, dynamic>),
      client: Client.fromMap(json['client'] as Map<String, dynamic>),
      host: Host.fromMap(json['host'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order.toMap(),
      'client': client!.toMap(),
      'host': host!.toMap(),
    };
  }

  void Progress() {
    if (status < serviceStatus.length - 1) {
      status += 1;
    } 
    else {
      status = 0;
    }
    
    // serviceRepo.updateService(serviceRef, service)
  }
}
