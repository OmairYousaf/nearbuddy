class GroupMemberModel {
  String? id;
  String? username;
  String? groupId;
  String? name;
  String? image;
  bool isMember=false;

  GroupMemberModel(
      {this.id, this.username, this.groupId, this.name, this.image,this.isMember=false});

  GroupMemberModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    groupId = json['group_id'];
    name = json['name'];
    image = json['image'];
    isMember = json['is_member']=='1'?true:false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['group_id'] = groupId;
    data['name'] = name;
    data['image'] = image;
    return data;
  }

  @override
  String toString() {
    return 'GroupMemberModel{id: $id, username: $username, groupId: $groupId, name: $name, image: $image, isMember: $isMember}';
  }
}