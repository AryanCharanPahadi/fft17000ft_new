import 'dart:convert';
import 'package:http_parser/http_parser.dart'; // for MediaType
import 'package:app17000ft_new/base_client/base_client.dart';
import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_dialog.dart';
import 'package:app17000ft_new/components/custom_snackbar.dart';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment_controller.dart';
import 'package:app17000ft_new/forms/school_facilities_&_mapping_form/school_facilities_controller.dart';
import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:app17000ft_new/services/network_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'SchoolFacilitiesForm.dart';

class SchoolFacilitiesSync extends StatefulWidget {
  const SchoolFacilitiesSync({super.key});

  @override
  State<SchoolFacilitiesSync> createState() => _SchoolFacilitiesSyncState();
}

class _SchoolFacilitiesSyncState extends State<SchoolFacilitiesSync> {
  final _schoolFacilitiesController = Get.put(SchoolFacilitiesController());
  final NetworkManager _networkManager = Get.put(NetworkManager());
  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _schoolFacilitiesController.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop =
            await BaseClient().showLeaveConfirmationDialog(context);
        return shouldPop;
      },
      child: Scaffold(
        appBar: const CustomAppbar(title: 'School Facilities & Mapping Form'),
        body: GetBuilder<SchoolFacilitiesController>(
          builder: (schoolFacilitiesController) {
            return Obx(() => isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : schoolFacilitiesController.schoolFacilitiesList.isEmpty
                    ? const Center(
                        child: Text(
                          'No Records Found',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                      )
                    : Column(
                        children: [
                          schoolFacilitiesController
                                  .schoolFacilitiesList.isNotEmpty
                              ? Expanded(
                                  child: ListView.separated(
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            const Divider(),
                                    itemCount: schoolFacilitiesController
                                        .schoolFacilitiesList.length,
                                    itemBuilder: (context, index) {
                                      final item = schoolFacilitiesController
                                          .schoolFacilitiesList[index];
                                      return ListTile(
                                        title: Text(
                                            "${index + 1}. Tour ID: ${item.tourId!}\n    School ${item.school!}\n",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              color: AppColors.primary,
                                              icon: const Icon(Icons.edit),
                                              onPressed: () async {
                                                final existingRecord =
                                                schoolFacilitiesController
                                                    .schoolFacilitiesList[
                                                index];

                                                // Debug prints
                                                print(
                                                    'Navigating to Enrollment');
                                                print(
                                                    'Existing Record: $existingRecord');

                                                IconData icon = Icons.edit;

                                                // Show the confirmation dialog
                                                bool? shouldNavigate =
                                                await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => Confirmation(
                                                    iconname: icon,
                                                    title: 'Confirm Update',
                                                    yes: 'Confirm',
                                                    no: 'Cancel',
                                                    desc:
                                                    'Are you sure you want to Update this record?',
                                                    onPressed: () {
                                                      // Close the dialog and return true to indicate confirmation
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                  ),
                                                );

                                                // Check if the user confirmed the action
                                                if (shouldNavigate == true) {
                                                  // Debug print before navigation
                                                  print('Navigating now');

                                                  // Navigate to CabMeterTracingForm using Navigator.push
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SchoolFacilitiesForm(
                                                            userid: 'userid',

                                                            existingRecord:
                                                            existingRecord,
                                                          ),
                                                    ),
                                                  );

                                                  // Debug print after navigation
                                                  print('Navigation completed');
                                                } else {
                                                  // User canceled the action
                                                  print('Navigation canceled');
                                                }
                                              },
                                            ),
                                            IconButton(
                                              color: AppColors.primary,
                                              icon: const Icon(Icons.sync),
                                              onPressed: () async {
                                                IconData icon =
                                                    Icons.check_circle;
                                                showDialog(
                                                    context: context,
                                                    builder: (_) => Confirmation(
                                                        iconname: icon,
                                                        title: 'Confirm',
                                                        yes: 'Confirm',
                                                        no: 'Cancel',
                                                        desc: 'Are you sure you want to Sync?',
                                                        onPressed: () async {
                                                          setState(() {
                                                            // isLoadings= true;
                                                          });
                                                          if (_networkManager
                                                                  .connectionType
                                                                  .value ==
                                                              0) {
                                                            customSnackbar(
                                                                'Warning',
                                                                'You are offline please connect to the internet',
                                                                AppColors
                                                                    .secondary,
                                                                AppColors
                                                                    .onSecondary,
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
                                                              print(
                                                                  'ready to insert');
                                                              var rsp = await insertSchoolFacilities(
                                                                  item.tourId,
                                                                  item.school,
                                                                  item.udiseCode,
                                                                  item.correctUdise,
                                                                  item.playImg,
                                                                  item.residentialValue,
                                                                  item.electricityValue,
                                                                  item.internetValue,
                                                                  item.projectorValue,
                                                                  item.smartClassValue,
                                                                  item.numFunctionalClass,
                                                                  item.playgroundValue,
                                                                  item.playImg,
                                                                  item.libValue,
                                                                  item.libLocation,
                                                                  item.librarianName,
                                                                  item.librarianTraining,
                                                                  item.libRegisterValue,
                                                                  item.created_by,
                                                                  item.created_at,

                                                                  item.id);
                                                              if (rsp['status'] ==
                                                                  1) {
                                                                customSnackbar(
                                                                    'Successfully',
                                                                    "${rsp['message']}",
                                                                    AppColors
                                                                        .secondary,
                                                                    AppColors
                                                                        .onSecondary,
                                                                    Icons
                                                                        .check);
                                                              } else if (rsp[
                                                                      'status'] ==
                                                                  0) {
                                                                customSnackbar(
                                                                    "Error",
                                                                    "${rsp['message']}",
                                                                    AppColors
                                                                        .error,
                                                                    AppColors
                                                                        .onError,
                                                                    Icons
                                                                        .warning);
                                                              } else {
                                                                customSnackbar(
                                                                    "Error",
                                                                    "Something went wrong, Please contact Admin",
                                                                    AppColors
                                                                        .error,
                                                                    AppColors
                                                                        .onError,
                                                                    Icons
                                                                        .warning);
                                                              }
                                                            }
                                                          }
                                                        }));
                                              },
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          schoolFacilitiesController
                                              .schoolFacilitiesList[index]
                                              .tourId;
                                        },
                                      );
                                    },
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.only(top: 340.0),
                                  child: Center(
                                    child: Text(
                                      'No Data Found',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                        ],
                      ));
          },
        ),
      ),
    );
  }
}

var baseurl = "https://mis.17000ft.org/apis/fast_apis/insert_school_facilities.php";

Future insertSchoolFacilities(
  String? tourId,
  String? school,
  String? udiseCode,
  String? correctUdise,
  String? playImg,
  String? residentialValue,
  String? electricityValue,
  String? internetValue,
  String? projectorValue,
  String? smartClassValue,
  String? numFunctionalClass,
  String? playgroundValue,
  String? imgRegister,
  String? libValue,
  String? libLocation,
  String? librarianName,
  String? librarianTraining,
  String? libRegisterValue,
  String? created_by,
  String? created_at,


  int? id,
) async {
  print('This is enrollment data');
  print('Tour ID: $tourId');
  print('School: $school');
  print(' udiseCode: $udiseCode');
  print('Correct UDISE: $correctUdise');
  print('Residential Value: $residentialValue');
  print('Electricity Value: $electricityValue');
  print('Internet Value: $internetValue');
  print('Projector Value: $projectorValue');
  print('Smart Class Value: $smartClassValue');
  print('Number of Functional Classrooms: $numFunctionalClass');
  print('Playground Value: $playgroundValue');
  print('Play Image: $playImg');
  print('Library Value: $libValue');
  print('Library Location: $libLocation');
  print('Librarian Name: $librarianName');
  print('Librarian Training: $librarianTraining');
  print('Library Register Value: $libRegisterValue');
  print('Image Register: $imgRegister');
  print('Created By: $created_by');
  print('Created At: $created_at');
  print(id);

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(baseurl),
  );
  request.headers["Accept"] = "Application/json";

  // Add text fields
  request.fields.addAll({
    'tourId': tourId ?? '',
    'school': school ?? '',
    'udiseCode': udiseCode ?? '',
    'correctUdise': correctUdise ?? '',
    'residentialValue': residentialValue ?? '',
    'electricityValue': electricityValue ?? '',
    'internetValue': internetValue ?? '',
    'projectorValue': projectorValue ?? '',
    'smartClassValue': smartClassValue ?? '',
    'numFunctionalClass': numFunctionalClass ?? '',
    'playgroundValue': playgroundValue ?? '',
    'libValue': libValue ?? '',
    'libLocation': libLocation ?? '',
    'librarianName': librarianName ?? '',
    'librarianTraining': librarianTraining ?? '',
    'libRegisterValue': libRegisterValue ?? '',
    'created_by': created_by ?? '',
    'created_at': created_at ?? '',
  });



  try {
    if (playImg != null && playImg.isNotEmpty) {
      // Convert Base64 image to Uint8List
      Uint8List imageBytes = base64Decode(playImg);

      // Create MultipartFile from the image bytes
      var multipartFile = http.MultipartFile.fromBytes(
        'playImg[]', // Name of the field in the server request
        imageBytes,
        filename: 'playImg${id ?? ''}.jpg', // Custom file name
        contentType: MediaType('image', 'jpeg'), // Specify the content type
      );

      // Add the image to the request
      request.files.add(multipartFile);
    }

    if (imgRegister != null && imgRegister.isNotEmpty) {
      // Convert Base64 image to Uint8List
      Uint8List imageBytes = base64Decode(imgRegister);

      // Create MultipartFile from the image bytes
      var multipartFile = http.MultipartFile.fromBytes(
        'imgRegister[]', // Name of the field in the server request
        imageBytes,
        filename: 'imgRegister${id ?? ''}.jpg', // Custom file name
        contentType: MediaType('image', 'jpeg'), // Specify the content type
      );

      // Add the image to the request
      request.files.add(multipartFile);
    }




    // Send the request to the server
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    print('Server Response Body: $responseBody'); // Print the raw response

    if (response.statusCode == 200) {
      if (responseBody.isEmpty) {
        return {"status": 0, "message": "Empty response from server"};
      }

      try {
        var parsedResponse = json.decode(responseBody);

        if (parsedResponse['status'] == 1) {
          // Remove record from local database
          await SqfliteDatabaseHelper().queryDelete(
            arg: id.toString(),
            table: 'schoolFacilities',
            field: 'id',
          );
          print("Record with id $id deleted from local database.");

          // Refresh data
          await Get.find<SchoolFacilitiesController>().fetchData();

          return parsedResponse;
        } else {
          print('Server Response Error: ${parsedResponse['message']}');
          return {"status": 0, "message": parsedResponse['message'] ?? 'Failed to insert data'};
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        return {"status": 0, "message": "Invalid response format"};
      }
    } else {
      print('Server Error Response Code: ${response.statusCode}');
      print('Server Error Response Body: $responseBody');
      return {"status": 0, "message": "Server returned an error"};
    }
  } catch (error) {
    print("Error: $error");
    return {"status": 0, "message": "Something went wrong, Please contact Admin"};
  }
}
