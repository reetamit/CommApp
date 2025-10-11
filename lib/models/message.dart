class Message {
  String sender;
  String text;
  String receiver;
  DateTime timestamp;

  Message({
    required this.sender,
    required this.text,
    required this.receiver,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'receiver': receiver,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: map['sender'],
      text: map['text'],
      receiver: map['receiver'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
