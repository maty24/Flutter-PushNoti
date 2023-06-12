class PushMessage {
  final String messageId;
  final String title;
  final String body;
  final DateTime sentDate;
  final Map<String, dynamic>? data;
  final String? imageUrl;

  // Constructor de la clase PushMessage
  PushMessage(
      {required this.messageId,
      required this.title,
      required this.body,
      required this.sentDate,
      this.data,
      this.imageUrl
    });

// Método toString() para representar el objeto como una cadena de texto
  @override
  String toString() {
    return '''
PushMessage - 
  id:    $messageId
  title: $title
  body:  $body
  data:  $data
  imageUrl: $imageUrl
  sentDate: $sentDate
''';
  }
}
