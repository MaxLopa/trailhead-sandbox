import 'package:flutter/material.dart';

class Client {
  final String id;
  final String name;

  Client({
    required this.id,
    required this.name,
  });

  factory Client.fromMap(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}