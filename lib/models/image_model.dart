
class ImageModel {
  String id = "";
  String image = "";
  String username = "";
  String timeStamp = "";
  bool isNetworkImage=false;
  dynamic localImageFile;

  ImageModel({
   required this.id,
   required this.image,
   required this.username,
   required this.timeStamp});

  ImageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    username = json['username'];
    timeStamp = json['time_stemp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['username'] = username;
    data['time_stemp'] = timeStamp;
    return data;
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          image == other.image &&
          username == other.username &&
          timeStamp == other.timeStamp &&
          isNetworkImage == other.isNetworkImage &&
          localImageFile == other.localImageFile;

  @override
  int get hashCode =>
      id.hashCode ^
      image.hashCode ^
      username.hashCode ^
      timeStamp.hashCode ^
      isNetworkImage.hashCode ^
      localImageFile.hashCode;

  @override
  String toString() {
   // return 'ImageModel{id: $id, image: $image, username: $username, timeStamp: $timeStamp, isNetworkImage: $isNetworkImage, localImageFile: $localImageFile}';
  return 'ImageModel no $id and has username $username and isNetworkImage : $isNetworkImage and localfile: localImageFile: ${localImageFile?.isAbsolute}';
  }
}
