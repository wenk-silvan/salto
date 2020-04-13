class Secret {
  final String apiKey;
  final String googleAppID;
  final String projectID;
  final String storageBucket;
  Secret({this.apiKey = "", this.googleAppID = "", this.projectID = "", this.storageBucket = ""});

  factory Secret.googleServices(Map<String, dynamic> jsonMap) {
    return new Secret(apiKey: jsonMap["api_key"], googleAppID: jsonMap["google_app_id"], projectID: jsonMap["project_id"], storageBucket: jsonMap["storage_bucket"]);
  }
}