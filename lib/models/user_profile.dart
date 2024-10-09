class UserProfile {
  String? uid;
  String? name;
  String? pfpURL;

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpURL,
  });

  // Constructor for creating a UserProfile from a JSON object
  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    pfpURL = json['pfpURL'];
  }

  // Method to convert UserProfile instance to a JSON object
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {}; // Corrected initialization
    data['uid'] = uid;
    data['name'] = name;
    data['pfpURL'] = pfpURL;
    return data;
  }
}
