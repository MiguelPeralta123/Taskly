class Task {
  // Attributes
  String content;
  DateTime timestamp;
  bool done;

  // Constructor
  Task({
    required this.content,
    required this.timestamp,
    required this.done
  });

  // A factory method creates a new instance of a class
  factory Task.fromMap(Map task) {
    return Task(
      content: task["content"],
      timestamp: task["timestamp"],
      done: task["done"]
    );
  }

  // Method to return the task information as a map
  Map toMap() {
    return {
      "content": content,
      "timestamp": timestamp,
      "done": done,
    };
  }
}