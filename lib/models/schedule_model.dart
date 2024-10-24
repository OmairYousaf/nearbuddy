
import 'buddy_model.dart';

class ScheduleModel {
  final String id;
  final String username;
  final String interestId;
  final String days;
  final String time;
  String switchValue; // 1 for on and 2 for off
  final InterestModel interest; //On which the schedule is made
  List<BuddyModel> persons=[];
  String scheduleWith="";// if the keyword says all or specific
  

  @override
  String toString() {
    return 'ScheduleModel{id: $id, username: $username, interestId: $interestId, days: $days, time: $time, switchValue: $switchValue, interest: $interest}';
  }

  ScheduleModel({
    required this.id,
    required this.username,
    required this.interestId,
    required this.days,
    required this.time,
    required this.switchValue,
    required this.interest,
    this.scheduleWith="",
    required this.persons,

  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    List<BuddyModel> persons=[];
    String scheduleWith=json['scheduled_with'];
    if(scheduleWith.contains("specific")){
      // Parse the "persons" list
      final List<dynamic> personsJson = json['persons'];
      persons  = personsJson
          .map((personJson) => BuddyModel.fromJson(personJson))
          .toList();
    }
    return ScheduleModel(
      id: json['id'],
      username: json['username'],
      interestId: json['interest_id'],
      days: json['days'],
      time: json['time'],
      switchValue: json['switch'],
      interest: InterestModel.fromJson(json['interest']),
      scheduleWith: scheduleWith,
      persons: persons
      

    );
  }
}

class InterestModel {
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;

  InterestModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String toString() {
    return 'InterestModel{id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
