import 'dart:convert';

import 'lib_issue_modal.dart';

List<IssueTrackerRecords?>? issueTrackerRecordsFromJson(String str) =>
    str.isEmpty ? [] : List<IssueTrackerRecords?>.from(json.decode(str).map((x) => IssueTrackerRecords.fromJson(x)));
String issueTrackerRecordsToJson(List<IssueTrackerRecords?>? data) =>
    json.encode(data == null ? [] : List<dynamic>.from(data.map((x) => x!.toJson())));
class IssueTrackerRecords {
  // Existing fields
  String? tourId;
  String? school;
  String? udiseCode;
  String? correctUdise;
  String? uid;
  String? createdAt;

  String? office;
  String? version;
  String? uniqueId;
  int? id;

   // Add this field for LibIssue list
  // List<LibIssue?>? libIssueList;

  IssueTrackerRecords({
    this.tourId,
    this.school,
    this.udiseCode,
    this.correctUdise,
    this.uid,
    this.createdAt,

    this.office,
    this.version,
    this.uniqueId,
    this.id,
    // this.libIssueList, // Add the constructor parameter
  });

  // Update the fromJson and toJson methods to include libIssueList
  factory IssueTrackerRecords.fromJson(Map<String, dynamic> json) => IssueTrackerRecords(
    tourId: json["tourId"],
    school: json["school"],
    udiseCode: json["udiseCode"],
    correctUdise: json["correctUdise"],
    uid: json["uid"],
    createdAt: json["created_at"],

    office: json["office"],
    version: json["version"],
    uniqueId: json["uniqueId"],
    id: json["id"],
    // libIssueList: json["lib_issue_list"] != null
    //     ? List<LibIssue?>.from(json["lib_issue_list"].map((x) => LibIssue.fromJson(x)))
    //     : null,
  );

  Map<String, dynamic> toJson() => {
    "tourId": tourId,
    "school": school,
    "udiseCode": udiseCode,
    "correctUdise": correctUdise,
    "uid": uid,
    "created_at": createdAt,

    "office": office,
    "version": version,
    "uniqueId": uniqueId,
    "id": id,
    // "lib_issue_list": libIssueList != null
    //     ? List<dynamic>.from(libIssueList!.map((x) => x!.toJson()))
    //     : null,
  };
}

