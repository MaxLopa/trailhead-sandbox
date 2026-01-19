import 'package:flutter/material.dart';

class Host {
  String id;
  String name;
  

  Host({
    required this.id,
    required this.name,
  });
  
  factory Host.fromMap(Map<String, dynamic> json) {
    return Host(
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