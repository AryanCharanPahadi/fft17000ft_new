import 'dart:convert';

import 'package:app17000ft_new/base_client/base_client.dart';
import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_dialog.dart';
import 'package:app17000ft_new/components/custom_snackbar.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/in_person_quantitative/in_person_quantitative_controller.dart';
import 'package:app17000ft_new/forms/issue_tracker/issue_tracker_controller.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment_controller.dart';
import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:app17000ft_new/services/network_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'lib_issue_modal.dart';

class IssueTrackerSync extends StatefulWidget {
  const IssueTrackerSync({super.key});

  @override
  State<IssueTrackerSync> createState() => _IssueTrackerSync();
}

class _IssueTrackerSync extends State<IssueTrackerSync> {
  final IssueTrackerController _issueTrackerController =
      Get.put(IssueTrackerController());
  final NetworkManager _networkManager = Get.put(NetworkManager());
  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _issueTrackerController.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop =
            await BaseClient().showLeaveConfirmationDialog(context);
        return shouldPop;
      },
      child: Scaffold(
        appBar: const CustomAppbar(title: 'Issue Tracker Sync'),
        body: GetBuilder<IssueTrackerController>(
          builder: (issueTrackerController) {
            if (issueTrackerController.issueTrackerList.isEmpty) {
              return const Center(
                child: Text(
                  'No Records Found',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              );
            }  if (issueTrackerController.libIssueList.isEmpty) {
              return const Center(
                child: Text(
                  'No Records Found',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              );
            }

            return Obx(() => isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          itemCount:
                              issueTrackerController.issueTrackerList.length,

                          itemBuilder: (context, index) {
                            final item =
                                issueTrackerController.issueTrackerList[index];
                            final item2 =
                                issueTrackerController.libIssueList[index];
                            return ListTile(
                              title: Text(
                                "${index + 1}. libIssue: ${item2.libIssue}\n      LibuniqueId:  ${item2.uniqueId}\n      BasicUniqueId:  ${item.uniqueId}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    color: AppColors.primary,
                                    icon: const Icon(Icons.sync),
                                    onPressed: () async {
                                      IconData icon = Icons.check_circle;
                                      showDialog(
                                          context: context,
                                          builder: (_) => Confirmation(
                                              iconname: icon,
                                              title: 'Confirm',
                                              yes: 'Confirm',
                                              no: 'Cancel',
                                              desc:
                                                  'Are you sure you want to Sync?',
                                              onPressed: () async {
                                                setState(() {
                                                  // isLoadings= true;
                                                });
                                                if (_networkManager
                                                        .connectionType.value ==
                                                    0) {
                                                  customSnackbar(
                                                      'Warning',
                                                      'You are offline please connect to the internet',
                                                      AppColors.secondary,
                                                      AppColors.onSecondary,
                                                      Icons.warning);
                                                } else {
                                                  if (_networkManager
                                                              .connectionType
                                                              .value ==
                                                          1 ||
                                                      _networkManager
                                                              .connectionType
                                                              .value ==
                                                          2) {
                                                    print('ready to insert');
                                                    var rsp =
                                                        await insertIssueTrackerRecords(
                                                      item.tourId,
                                                      item.school,
                                                      item.udiseCode,
                                                      item.correctUdise,
                                                      item.uid,
                                                      item.createdAt,
                                                      item.office,
                                                      item.version,
                                                      item.uniqueId,
                                                      item.id,
                                                      // item.libIssueList
                                                    ); // Pass LibIssue list here
                                                    if (rsp['status'] == 1) {
                                                      customSnackbar(
                                                          'Successfully',
                                                          "${rsp['message']}",
                                                          AppColors.secondary,
                                                          AppColors.onSecondary,
                                                          Icons.check);
                                                    } else if (rsp['status'] ==
                                                        0) {
                                                      customSnackbar(
                                                          "Error",
                                                          "${rsp['message']}",
                                                          AppColors.error,
                                                          AppColors.onError,
                                                          Icons.warning);
                                                    } else {
                                                      customSnackbar(
                                                          "Error",
                                                          "Something went wrong, Please contact Admin",
                                                          AppColors.error,
                                                          AppColors.onError,
                                                          Icons.warning);
                                                    }
                                                  }
                                                }
                                                if (_networkManager
                                                            .connectionType
                                                            .value ==
                                                        1 ||
                                                    _networkManager
                                                            .connectionType
                                                            .value ==
                                                        2) {
                                                  print('ready to insert');
                                                  var rspLib =
                                                      await insertLibIssue(
                                                    item2.libIssue,
                                                    item2.libIssueValue,
                                                    item2.libDesc,
                                                    item2.reportedOn,
                                                    item2.resolvedOn,
                                                    item2.reportedBy,
                                                    item2.resolvedBy,
                                                    item2.issueStatus,
                                                    item2.libIssueImg,
                                                    item2.uniqueId,
                                                    item2.id,
                                                    // item.libIssueList
                                                  ); // Pass LibIssue list here
                                                  if (rspLib['status'] == 1) {
                                                    customSnackbar(
                                                        'Successfully',
                                                        "${rspLib['message']}",
                                                        AppColors.secondary,
                                                        AppColors.onSecondary,
                                                        Icons.check);
                                                  } else if (rspLib['status'] ==
                                                      0) {
                                                    customSnackbar(
                                                        "Error",
                                                        "${rspLib['message']}",
                                                        AppColors.error,
                                                        AppColors.onError,
                                                        Icons.warning);
                                                  } else {
                                                    customSnackbar(
                                                        "Error",
                                                        "Something went wrong, Please contact Admin",
                                                        AppColors.error,
                                                        AppColors.onError,
                                                        Icons.warning);
                                                  }
                                                }
                                              }));
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                issueTrackerController
                                    .issueTrackerList[index].tourId;
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ));
          },
        ),
      ),
    );
  }
}

insertLibIssue(
    String? libIssue,
    String? libIssueValue,
    String? libDesc,
    String? reportedOn,
    String? resolvedOn,
    String? reportedBy,
    String? resolvedBy,
    String? issueStatus,
    String? libIssueImg,
    String? uniqueId,
    int? id)  {

}

var baseurl = "https://mis.17000ft.org/apis/fast_apis/";

Future insertIssueTrackerRecords(
  String? tourId,
  String? school,
  String? udiseCode,
  String? correctUdise,
  String? uid,
  String? createdAt,
  String? office,
  String? version,
  String? uniqueId,
  int? id,
  // List<LibIssue?>? libIssueList, // Add the LibIssue list parameter
) async {
  if (kDebugMode) {
    print('this is In issueTracker Data');
    print(tourId);
    print(school);
  }



    var request = http.MultipartRequest(
        'POST', Uri.parse('${baseurl}insert_cdpo_survey2024.php'));
    request.headers["Accept"] = "Application/json";
    //
    // // Add text fields
    // request.fields.addAll({
    //   "tour_id": tourId ?? "",
    //   "school": school ?? "",
    //   "udise_code": udiseCode ?? "",
    //   "correct_udise": correctUdise ?? "",
    //   "uid": uid ?? "",
    //   "created_at": createdAt ?? "",
    //   "office": office ?? "",
    //   "version": version ?? "",
    //   "unique_id": uniqueId ?? "",
    // });
    //
    // // Add the LibIssue data to the request
    // if (libIssueList != null && libIssueList.isNotEmpty) {
    //   request.fields['lib_issues'] = libIssueToJson(libIssueList);
    // }

    try {
      var response = await request.send();
      var parsedResponse;

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        parsedResponse = json.decode(responseBody);
        if (parsedResponse['status'] == 1) {
          await SqfliteDatabaseHelper().queryDelete(
            arg: id.toString(),
            table: 'inPerson_Qualitative',
            field: 'id',
          );

          await Get.find<IssueTrackerController>().fetchData();
        }
      } else {
        var responseBody = await response.stream.bytesToString();
        parsedResponse = json.decode(responseBody);
        print('this is by cdpo firm');
        print(responseBody);
      }
      return parsedResponse;
    } catch (error) {
      print("Error: $error");
      return {
        "status": 0,
        "message": "Something went wrong, Please contact Admin"
      };
    }
  }

