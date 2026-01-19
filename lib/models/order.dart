class ClientOrder {
  static const List<String> orderTypes = ['SuperSimple', 'Simple', 'Complicated'];
  static const List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  static const List<String> conditions = ['Rough', 'Used', 'New'];


  String orderType;
  String difficulty;
  String condition;

  ClientOrder({
    required this.orderType,
    required this.difficulty,
    required this.condition,
  });

  factory ClientOrder.fromMap(Map<String, dynamic> json) {
    return ClientOrder(
      orderType: json['orderType'] as String,
      difficulty: json['difficulty'] as String,
      condition: json['condition'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderType': orderType,
      'difficulty': difficulty,
      'condition': condition,
    };
  } 
}
