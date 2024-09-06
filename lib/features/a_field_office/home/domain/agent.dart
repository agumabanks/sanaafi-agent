class Agent {
  final String name;

  Agent({required this.name});

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(name: json['name']);
  }
}
