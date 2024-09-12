// import 'dart:convert';
//
// List<LibIssue?>? libIssueFromJson(String str) =>
//     str.isEmpty ? [] : List<LibIssue?>.from(json.decode(str).map((x) => LibIssue.fromJson(x)));
// String libIssueToJson(List<LibIssue?>? data) =>
//     json.encode(data == null ? [] : List<dynamic>.from(data.map((x) => x!.toJson())));
//
// class LibIssue {
//   LibIssue({
//     this.id,
//     this.libIssue,
//     this.libIssueValue,
//     this.libDesc,
//     this.uniqueId,
//     this.libIssueImg,
//     this.reportedOn,
//     this.reportedBy,
//     this.issueStatus,
//     this.resolvedOn,
//     this.resolvedBy,
//   });
//
//   int? id;
//   String? libIssue;
//   String? libIssueValue;
//   String? libDesc;
//   String? uniqueId;
//   String? libIssueImg;
//   String? reportedOn;
//   String? reportedBy;
//   String? issueStatus;
//   String? resolvedOn;
//   String? resolvedBy;
//
//   factory LibIssue.fromJson(Map<String, dynamic> json) => LibIssue(
//     id: json["id"],
//     libIssue: json["lib_issue"],
//     libIssueValue: json["lib_issue_value"],
//     libDesc: json["lib_desc"],
//     uniqueId: json["unique_id"],
//     libIssueImg: json["lib_issue_img"],
//     reportedOn: json["reported_on"],
//     reportedBy: json["reported_by"],
//     issueStatus: json["issue_status"],
//     resolvedOn: json["resolved_on"],
//     resolvedBy: json["resolved_by"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "lib_issue": libIssue,
//     "lib_issue_value": libIssueValue,
//     "lib_desc": libDesc,
//     "unique_id": uniqueId,
//     "lib_issue_img": libIssueImg,
//     "reported_on": reportedOn,
//     "reported_by": reportedBy,
//     "issue_status": issueStatus,
//     "resolved_on": resolvedOn,
//     "resolved_by": resolvedBy,
//   };
// }




import 'dart:convert';

List<LibIssue?>? libIssueFromJson(String str) =>
    str.isEmpty ? [] : List<LibIssue?>.from(json.decode(str).map((x) => LibIssue.fromJson(x)));

String libIssueToJson(List<LibIssue?>? data) =>
    json.encode(data == null ? [] : List<dynamic>.from(data.map((x) => x!.toJson())));

class LibIssue {
  String? libIssue;
  String? libIssueValue;
  String? libDesc;
  String? reportedOn;
  String? resolvedOn;
  String? reportedBy;
  String? resolvedBy;
  String? issueStatus;
  String? libIssueImg;
  String? uniqueId;
  int? id;

  LibIssue({
    this.libIssue,
    this.libIssueValue,
    this.libDesc,
    this.reportedOn,
    this.resolvedOn,
    this.reportedBy,
    this.resolvedBy,
    this.issueStatus,
    this.libIssueImg,
    this.uniqueId,
    this.id,
  });

  factory LibIssue.fromJson(Map<String, dynamic> json) => LibIssue(
    libIssue: json["lib_issue"],
    libIssueValue: json["lib_issue_value"],
    libDesc: json["lib_desc"],
    reportedOn: json["reported_on"],
    resolvedOn: json["resolved_on"],
    reportedBy: json["reported_by"],
    resolvedBy: json["resolved_by"],
    issueStatus: json["issue_status"],
    libIssueImg: json["lib_issue_img"],
    uniqueId: json["unique_id"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "lib_issue": libIssue,
    "lib_issue_value": libIssueValue,
    "lib_desc": libDesc,
    "reported_on": reportedOn,
    "resolved_on": resolvedOn,
    "reported_by": reportedBy,
    "resolved_by": resolvedBy,
    "issue_status": issueStatus,
    "lib_issue_img": libIssueImg,
    "unique_id": uniqueId,
    "id": id,
  };
}
