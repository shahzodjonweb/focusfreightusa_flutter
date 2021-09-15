class PushNotification {
  var body;
  var title;
  PushNotification({
    this.title,
    this.body,
  }
  );
  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: json["notification"]["title"],
      body: json["notification"]["body"],
    );
  }
}