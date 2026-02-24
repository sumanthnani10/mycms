class App {
  String id, name, playStoreLink, image, serverType, serverDomain, serverPath;
  List collections;
  Map objects, apis;

  App(
      {required this.id,
      required this.name,
      required this.playStoreLink,
      required this.image,
      required this.serverType,
      required this.serverDomain,
      required this.serverPath,
      required this.collections,
      required this.objects,
      required this.apis});

  factory App.fromJson(Map<dynamic, dynamic> i) {
    return App(
      id: i["id"],
      name: i["name"],
      playStoreLink: i["play_store_link"],
      image: i["image"],
      serverType: i["server_type"],
      serverDomain: i["server_domain"],
      serverPath: i["server_path"],
      collections: i["collections"],
      objects: i["objects"],
      apis: i["apis"],
    );
  }

  Map<dynamic, dynamic> toJson() {
    return <dynamic, dynamic>{
      "id": id,
      "name": name,
      "play_store_link": playStoreLink,
      "image": image,
      "server_type": serverType,
      "server_domain": serverDomain,
      "server_path": serverPath,
      "collections": collections,
      "objects": objects,
      "apis": apis,
    };
  }
}
