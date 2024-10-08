import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:app17000ft_new/components/custom_appBar.dart';
import 'package:app17000ft_new/components/custom_button.dart';
import 'package:app17000ft_new/components/custom_imagepreview.dart';
import 'package:app17000ft_new/components/custom_snackbar.dart';
import 'package:app17000ft_new/components/custom_textField.dart';
import 'package:app17000ft_new/components/error_text.dart';
import 'package:app17000ft_new/constants/color_const.dart';

import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:app17000ft_new/helper/responsive_helper.dart';
import 'package:app17000ft_new/tourDetails/tour_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:app17000ft_new/base_client/base_client.dart';
import 'package:app17000ft_new/components/custom_dropdown.dart';
import 'package:app17000ft_new/components/custom_labeltext.dart';
import 'package:app17000ft_new/components/custom_sizedBox.dart';

import 'package:app17000ft_new/home/home_screen.dart';
import 'package:image_picker/image_picker.dart';

import 'in_person_quantitative_controller.dart';
import 'in_person_quantitative_modal.dart';

class InPersonQuantitative extends StatefulWidget {
  String? userid;
  String? office;
  // final InPersonQuantitativeRecords? existingRecord;
  InPersonQuantitative({
    super.key,
    this.userid,
    String? office,
    // this.existingRecord,
  });

  @override
  State<InPersonQuantitative> createState() => _InPersonQuantitativeState();
}

class _InPersonQuantitativeState extends State<InPersonQuantitative> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // For managing issues and resolutions
  List<Issue> issues = [];

  void _addIssue() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddIssueBottomSheet(),
    );

    if (result != null && result is Issue) {
      setState(() {
        issues.add(result);
      });
    }
  }

  void _deleteIssue(int index) {
    setState(() {
      issues.removeAt(index);
    });
  }

  final InPersonQuantitativeController inPersonQuantitativeController =
      Get.put(InPersonQuantitativeController());
  List<Participants> participants = [];
  bool showError = false;
  String errorMessage = '';

  void _addParticipants() async {
    int staffAttended = int.tryParse(inPersonQuantitativeController
            .staafAttendedTrainingController.text) ??
        0;

    if (staffAttended <= 0) {
      setState(() {
        showError = true;
        errorMessage = '0 participants cannot be accepted';
      });
      return;
    }

    if (participants.length >= staffAttended) {
      setState(() {
        showError = true;
        errorMessage = 'The number of participants exceeds the staff attended';
      });
      return;
    }

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddParticipantsBottomSheet(
          existingRoles: participants.map((p) => p.designation).toList()),
    );

    if (result != null && result is Participants) {
      setState(() {
        int existingIndex =
            participants.indexWhere((p) => p.designation == result.designation);
        if (existingIndex >= 0) {
          participants[existingIndex] = result; // Update existing participant
        } else {
          participants.add(result); // Add new participant
        }
        showError =
            false; // Reset error if participants are added or updated successfully
        errorMessage = '';
      });
    }
  }

  void _handleStaffAttendedChange(String value) {
    int staffAttended = int.tryParse(value) ?? 0;
    setState(() {
      if (staffAttended == 0) {
        showError = true;
        errorMessage = '0 participants cannot be accepted';
      } else {
        showError = false;
        errorMessage = '';
      }
    });
  }

  void _deleteParticipants(int index) {
    setState(() {
      participants.removeAt(index);
    });
  }

// make this code that if user fill 0 in the staff attendend in the training then show error
  bool _isImageUploaded = false;
  bool validateRegister = false;
  final ImagePicker _picker = ImagePicker();
  List<File> _imageFiles = [];

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
        _isImageUploaded = true;
        validateRegister = false; // Reset error state
      });
    }
  }

  bool _isImageUploaded2 = false;
  bool validateRegister2 = false;
  final ImagePicker _picker2 = ImagePicker();
  List<File> _imageFiles2 = [];

  Future<void> _pickImageFromCamera2() async {
    final pickedFile = await _picker2.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFiles2.add(File(pickedFile.path));
        _isImageUploaded2 = true;
        validateRegister2 = false; // Reset error state
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        inPersonQuantitativeController.dateController.text =
            "${picked.toLocal()}".split(' ')[0];
        inPersonQuantitativeController.dateFieldError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return WillPopScope(
        onWillPop: () async {
          bool shouldPop =
              await BaseClient().showLeaveConfirmationDialog(context);
          return shouldPop;
        },
        child: Scaffold(
          appBar: const CustomAppbar(
            title: 'In-Person Quantitative',
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  GetBuilder<InPersonQuantitativeController>(
                      init: InPersonQuantitativeController(),
                      builder: (inPersonQuantitativeController) {
                        return Form(
                            key: _formKey,
                            child: GetBuilder<TourController>(
                                init: TourController(),
                                builder: (tourController) {
                                  tourController.fetchTourDetails();
                                  return Column(children: [
                                    if (inPersonQuantitativeController
                                        .showBasicDetails) ...[
                                      LabelText(
                                        label: 'Basic Details',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label: 'Tour ID',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      CustomDropdownFormField(
                                        focusNode:
                                            inPersonQuantitativeController
                                                .tourIdFocusNode,
                                        options: tourController.getLocalTourList
                                            .map((e) => e.tourId)
                                            .toList(),
                                        selectedOption:
                                            inPersonQuantitativeController
                                                .tourValue,
                                        onChanged: (value) {
                                          inPersonQuantitativeController
                                                  .splitSchoolLists =
                                              tourController.getLocalTourList
                                                  .where(
                                                      (e) => e.tourId == value)
                                                  .map((e) => e.allSchool
                                                      .split('|')
                                                      .toList())
                                                  .expand((x) => x)
                                                  .toList();
                                          setState(() {
                                            inPersonQuantitativeController
                                                .setSchool(null);
                                            inPersonQuantitativeController
                                                .setTour(value);
                                          });
                                        },
                                        labelText: "Select Tour ID",
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label: 'School',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      DropdownSearch<String>(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Select School";
                                          }
                                          return null;
                                        },
                                        popupProps: PopupProps.menu(
                                          showSelectedItems: true,
                                          showSearchBox: true,
                                          disabledItemFn: (String s) =>
                                              s.startsWith('I'),
                                        ),
                                        items: inPersonQuantitativeController
                                            .splitSchoolLists,
                                        dropdownDecoratorProps:
                                            const DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            labelText: "Select School",
                                            hintText: "Select School ",
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .setSchool(value);
                                          });
                                        },
                                        selectedItem:
                                            inPersonQuantitativeController
                                                .schoolValue,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label: 'Is this UDISE code is correct?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'udiCode'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'udiCode', value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'udiCode'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'udiCode', value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('udiCode'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                              .getSelectedValue('udiCode') ==
                                          'No') ...[
                                        LabelText(
                                          label:
                                              'Write Correct UDISE school code',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .correctUdiseCodeController,
                                          textInputType: TextInputType.number,
                                          labelText: 'Enter correct UDISE code',
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please fill this field';
                                            }
                                            if (!RegExp(r'^[0-9]+$')
                                                .hasMatch(value)) {
                                              return 'Please enter a valid number';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                      ],
                                      LabelText(
                                        label: 'Click Image of School Board',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            width: 2,
                                            color: _isImageUploaded
                                                ? AppColors.primary
                                                : AppColors.error,
                                          ),
                                        ),
                                        child: ListTile(
                                          title: _isImageUploaded
                                              ? const Text(
                                                  'Click or Upload Image')
                                              : const Text(
                                                  'Click Supporting Images'),
                                          trailing: const Icon(Icons.camera_alt,
                                              color: AppColors.onBackground),
                                          onTap: _pickImageFromCamera,
                                        ),
                                      ),
                                      ErrorText(
                                        isVisible: validateRegister,
                                        message: 'Register Image Required',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (_imageFiles.isNotEmpty)
                                        Container(
                                          width: responsive.responsiveValue(
                                            small: 600.0,
                                            medium: 900.0,
                                            large: 1400.0,
                                          ),
                                          height: responsive.responsiveValue(
                                            small: 170.0,
                                            medium: 170.0,
                                            large: 170.0,
                                          ),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _imageFiles.length,
                                            itemBuilder: (context, index) {
                                              return SizedBox(
                                                height: 200,
                                                width: 200,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          CustomImagePreview
                                                              .showImagePreview(
                                                            _imageFiles[index]
                                                                .path,
                                                            context,
                                                          );
                                                        },
                                                        child: Image.file(
                                                          _imageFiles[index],
                                                          width: 190,
                                                          height: 120,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _imageFiles
                                                              .removeAt(index);
                                                          _isImageUploaded =
                                                              _imageFiles
                                                                  .isNotEmpty;
                                                        });
                                                      },
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            'No of Enrolled Students as of date',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .noOfEnrolledStudentAsOnDateController,
                                        labelText: 'Enter Enrolled number',
                                        textInputType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(3),
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please fill this field';
                                          }
                                          if (!RegExp(r'^[0-9]+$')
                                              .hasMatch(value)) {
                                            return 'Please enter a valid number';
                                          }
                                          return null;
                                        },
                                        showCharacterCount: true,
                                      ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      CustomButton(
                                        title: 'Next',
                                        onPressedButton: () {
                                          final isRadioValid1 =
                                              inPersonQuantitativeController
                                                  .validateRadioSelection(
                                                      'udiCode');
                                          setState(() {
                                            validateRegister =
                                                _imageFiles.isEmpty;
                                          });

                                          if (_formKey.currentState!
                                                  .validate() &&
                                              isRadioValid1 &&
                                              _isImageUploaded) {
                                            setState(() {
                                              inPersonQuantitativeController
                                                  .showBasicDetails = false;
                                              inPersonQuantitativeController
                                                  .showBasicDetails = false;
                                              inPersonQuantitativeController
                                                  .showDigiLabSchedule = true;
                                            });
                                          }
                                        },
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],
                                    // Ends of Add Basic Details
                                    if (inPersonQuantitativeController
                                        .showDigiLabSchedule) ...[
                                      LabelText(
                                        // Start of DigiLab Schedule
                                        label: 'DigiLab Schedule',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '1. Is DigiLab Schedule/timetable available?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabSchedule'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'digiLabSchedule',
                                                        value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabSchedule'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'digiLabSchedule',
                                                        value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'digiLabSchedule'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'digiLabSchedule') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '1.1. Each class scheduled for 2 hours per week?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'class2Hours'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'class2Hours', value);
                                                },
                                              ),
                                              const Text('Yes'),
                                            ],
                                          ),
                                        ),
                                        CustomSizedBox(
                                          value: 150,
                                          side: 'width',
                                        ),
                                        // make it that user can also edit the tourId and school
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'class2Hours'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'class2Hours', value);
                                                },
                                              ),
                                              const Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError('class2Hours'))
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                      ],

                                      LabelText(
                                        label:
                                            '1.1.1 Describe in brief instructions provided regarding class scheduling',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .instructionProvidedRegardingClassSchedulingController,
                                        maxlines: 2,
                                        labelText: 'Write Description',
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please fill this field';
                                          }

                                          if (value.length < 25) {
                                            return 'Description must be at least 25 characters long';
                                          }
                                          return null;
                                        },
                                        showCharacterCount: true,
                                      ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      Row(
                                        children: [
                                          CustomButton(
                                              title: 'Back',
                                              onPressedButton: () {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                      .showBasicDetails = true;
                                                  inPersonQuantitativeController
                                                          .showDigiLabSchedule =
                                                      false;
                                                });
                                              }),
                                          const Spacer(),
                                          CustomButton(
                                            title: 'Next',
                                            onPressedButton: () {
                                              // Get the value of the 'digiLabSchedule' radio button
                                              final digiLabScheduleValue =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'digiLabSchedule');

                                              bool isRadioValid3 =
                                                  true; // Default to true

                                              // Only validate 'class2Hours' if 'digiLabSchedule' is 'yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabSchedule') ==
                                                  'Yes') {
                                                isRadioValid3 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'class2Hours');
                                              }

                                              // Validate form and radio button conditions
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  digiLabScheduleValue !=
                                                      null &&
                                                  isRadioValid3) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showDigiLabSchedule =
                                                      false;
                                                  inPersonQuantitativeController
                                                          .showTeacherCapacity =
                                                      true;
                                                });
                                              }
                                            },
                                          )
                                        ],
                                      ),

                                      // Ends of DigiLab Schedule
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],
                                    // Start of Teacher Capacity
                                    if (inPersonQuantitativeController
                                        .showTeacherCapacity) ...[
                                      LabelText(
                                        label: 'Teacher Capacity',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label: '1. Is DigiLab admin appointed?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'isDigiLabAdminAppointed'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'isDigiLabAdminAppointed',
                                                        value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'isDigiLabAdminAppointed'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'isDigiLabAdminAppointed',
                                                        value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'isDigiLabAdminAppointed'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'isDigiLabAdminAppointed') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '1.1. Is Digilab admin trained?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'isDigiLabAdminTrained'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'isDigiLabAdminTrained',
                                                          value);
                                                },
                                              ),
                                              const Text('Yes'),
                                            ],
                                          ),
                                        ),
                                        CustomSizedBox(
                                          value: 150,
                                          side: 'width',
                                        ),
                                        // make it that user can also edit the tourId and school
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'isDigiLabAdminTrained'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'isDigiLabAdminTrained',
                                                          value);
                                                },
                                              ),
                                              const Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError(
                                                'isDigiLabAdminTrained'))
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '1.1.1 Name of DigiLab admin?',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .digiLabAdminNameController,
                                          labelText: 'Name of admin',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Write Admin Name';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label: '1.1.2 Phone number of admin?',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .digiLabAdminPhoneNumberController,
                                          labelText: 'Phone number of admin',
                                          textInputType: TextInputType.number,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Write Admin Name';
                                            }

                                            // Regex for validating Indian phone number
                                            String pattern = r'^[6-9]\d{9}$';
                                            RegExp regex = RegExp(pattern);

                                            if (!regex.hasMatch(value)) {
                                              return 'Enter a valid phone number';
                                            }

                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '2. Are all the subject teacher trained?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'areAllTeacherTrained'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'areAllTeacherTrained',
                                                        value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'areAllTeacherTrained'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'areAllTeacherTrained',
                                                        value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'areAllTeacherTrained'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '3. Have teacher Ids been created and used on the tabs?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'idHasBeenCreated'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'idHasBeenCreated',
                                                        value);
                                                setState(() {}); // Triggers UI update
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'idHasBeenCreated'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'idHasBeenCreated',
                                                        value);
                                                setState(() {}); // Triggers UI update
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'idHasBeenCreated'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'idHasBeenCreated') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '3.1. Are the teachers comfortable using the tabs and navigating the content?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'teacherUsingTablet'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'teacherUsingTablet',
                                                          value);
                                                  setState(() {}); // Triggers UI update
                                                },
                                              ),
                                              const Text('Yes'),
                                            ],
                                          ),
                                        ),
                                        CustomSizedBox(
                                          value: 150,
                                          side: 'width',
                                        ),
                                        // make it that user can also edit the tourId and school
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'teacherUsingTablet'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'teacherUsingTablet',
                                                          value);
                                                  setState(() {}); // Triggers UI update
                                                },
                                              ),
                                              const Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError(
                                                'teacherUsingTablet'))
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),

                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Row(
                                        children: [
                                          CustomButton(
                                            title: 'Back',
                                            onPressedButton: () {
                                              setState(() {
                                                inPersonQuantitativeController
                                                    .showDigiLabSchedule = true;
                                                inPersonQuantitativeController
                                                        .showTeacherCapacity =
                                                    false;
                                              });
                                            },
                                          ),
                                          const Spacer(),
                                          CustomButton(
                                            title: 'Next',
                                            onPressedButton: () {
                                              final isRadioValid4 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'isDigiLabAdminAppointed');

                                              bool isRadioValid5 =
                                                  true; // Default to true

                                              // Only validate 'class2Hours' if 'digiLabSchedule' is 'yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'isDigiLabAdminAppointed') ==
                                                  'Yes') {
                                                isRadioValid5 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'isDigiLabAdminTrained');
                                              }

                                              final isRadioValid6 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'areAllTeacherTrained');

                                              final isRadioValid7 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'idHasBeenCreated');

                                              bool isRadioValid8 =
                                                  true; // Default to true

                                              // Only validate 'class2Hours' if 'digiLabSchedule' is 'yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'idHasBeenCreated') ==
                                                  'Yes') {
                                                isRadioValid8 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'teacherUsingTablet');
                                              }

                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  isRadioValid4 &&
                                                  isRadioValid5 &&
                                                  isRadioValid6 &&
                                                  isRadioValid7 &&
                                                  isRadioValid8) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showTeacherCapacity =
                                                      false;
                                                  inPersonQuantitativeController
                                                          .showSchoolRefresherTraining =
                                                      true;
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],

                                    // Start of In School Refresher Training
                                    if (inPersonQuantitativeController
                                        .showSchoolRefresherTraining) ...[
                                      LabelText(
                                          label:
                                              'In School Refresher Training'),
                                      CustomSizedBox(value: 20, side: 'height'),
                                      LabelText(
                                          label:
                                              '1. How many staff attended the training?',
                                          astrick: true),
                                      CustomSizedBox(value: 20, side: 'height'),
                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .staafAttendedTrainingController,
                                        labelText: 'Number of Staffs',
                                        textInputType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(3),
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please fill this field';
                                          }
                                          if (!RegExp(r'^[0-9]+$')
                                              .hasMatch(value)) {
                                            return 'Please enter a valid number';
                                          }

                                          return null;
                                        },
                                        onChanged: _handleStaffAttendedChange,
                                        showCharacterCount: true,
                                      ),
                                      CustomSizedBox(value: 20, side: 'height'),

                                      if (inPersonQuantitativeController
                                          .staafAttendedTrainingController
                                          .text
                                          .isNotEmpty) ...[
                                        Row(
                                          children: [
                                            LabelText(
                                                label:
                                                    '1.1 Add Participants Details'),
                                            CustomSizedBox(
                                                value: 10, side: 'width'),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              iconSize: 40,
                                              color: Color.fromARGB(
                                                  255, 141, 13, 21),
                                              onPressed: _addParticipants,
                                            ),
                                          ],
                                        ),
                                        CustomSizedBox(
                                            value: 20, side: 'height'),
                                        participants.isEmpty
                                            ? const Center(
                                                child: Text('No records'))
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: participants.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(
                                                        '${index + 1}. Name: ${participants[index].nameOfParticipants}\n    Designation: ${participants[index].designation}'),
                                                    trailing: IconButton(
                                                      icon: const Icon(
                                                          Icons.delete),
                                                      onPressed: () =>
                                                          _deleteParticipants(
                                                              index),
                                                    ),
                                                  );
                                                },
                                              ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        if (showError)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: const Text(
                                                'Please add details for the Participants',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            'Click Image of Refresher Training?',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Container(
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            width: 2,
                                            color: _isImageUploaded2
                                                ? AppColors.primary
                                                : AppColors.error,
                                          ),
                                        ),
                                        child: ListTile(
                                          title: _isImageUploaded2
                                              ? const Text(
                                                  'Click or Upload Image')
                                              : const Text(
                                                  'Click Supporting Images'),
                                          trailing: const Icon(Icons.camera_alt,
                                              color: AppColors.onBackground),
                                          onTap: _pickImageFromCamera2,
                                        ),
                                      ),
                                      ErrorText(
                                        isVisible: validateRegister2,
                                        message: 'Register Image Required',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (_imageFiles2.isNotEmpty)
                                        Container(
                                          width: responsive.responsiveValue(
                                            small: 600.0,
                                            medium: 900.0,
                                            large: 1400.0,
                                          ),
                                          height: responsive.responsiveValue(
                                            small: 170.0,
                                            medium: 170.0,
                                            large: 170.0,
                                          ),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _imageFiles2.length,
                                            itemBuilder: (context, index) {
                                              return SizedBox(
                                                height: 200,
                                                width: 200,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          CustomImagePreview
                                                              .showImagePreview(
                                                            _imageFiles2[index]
                                                                .path,
                                                            context,
                                                          );
                                                        },
                                                        child: Image.file(
                                                          _imageFiles2[index],
                                                          width: 190,
                                                          height: 120,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _imageFiles2
                                                              .removeAt(index);
                                                          _isImageUploaded2 =
                                                              _imageFiles2
                                                                  .isNotEmpty;
                                                        });
                                                      },
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '2. What were the topics covered in the refresher training?',
                                        astrick: true,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue1,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue1 = value!;
                                          });
                                        },
                                        title: const Text('Operating DigiLab'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue2,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue2 = value!;
                                          });
                                        },
                                        title: const Text('Operating tablets'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue3,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue3 = value!;
                                          });
                                        },
                                        title:
                                            const Text('Creating students IDs'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue4,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue4 = value!;
                                          });
                                        },
                                        title: const Text(
                                            'Grade Wise DigiLab subjects & Chapters'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue5,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue5 = value!;
                                          });
                                        },
                                        title: const Text(
                                            'Importance of completing post test'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue6,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue6 = value!;
                                          });
                                        },
                                        title: const Text(
                                            'Saving and submitting data(Send Report)'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue7,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue7 = value!;
                                          });
                                        },
                                        title:
                                            const Text('Syncing data with Pi'),
                                        activeColor: Colors.green,
                                      ),
                                      CheckboxListTile(
                                        value: inPersonQuantitativeController
                                            .checkboxValue8,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            inPersonQuantitativeController
                                                .checkboxValue8 = value!;
                                            // Update the visibility of the text field
                                          });
                                        },
                                        title: const Text('Any other'),
                                        activeColor: Colors.green,
                                      ),
                                      if (inPersonQuantitativeController
                                          .checkBoxError)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: const Text(
                                              'Please select at least one topic',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),

                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                          .checkboxValue8) ...[
                                        // Conditionally show the text field
                                        LabelText(
                                          label:
                                              '2.1 Please specify what the other topics',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .otherTopicsController,
                                          labelText:
                                              'Please Specify what the other topics',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please fill this field';
                                            }
                                            // Regex pattern for validating Indian vehicle number plate

                                            if (value.length < 25) {
                                              return 'Please enter at least 25 characters';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                      ],
                                      // Give me complete code only for the selectbox error field and the onpressed on next for the selectbox
                                      LabelText(
                                        label: '3. Was a practical demo given?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'practicalDemo'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'practicalDemo', value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'practicalDemo'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'practicalDemo', value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('practicalDemo'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'practicalDemo') ==
                                          'No') ...[
                                        // Conditionally show the text field
                                        LabelText(
                                          label:
                                              '3.1 Give the reason for not providing demo',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .reasonForNotGivenpracticalDemoController,
                                          labelText: 'Give Reason',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please fill this field';
                                            }
                                            // Regex pattern for validating Indian vehicle number plate

                                            if (value.length < 25) {
                                              return 'Please enter at least 25 characters';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                      ],

// Section for adding issues and resolutions
                                      Row(
                                        children: [
                                          LabelText(
                                            label:
                                                '4. Add Major Issues and Resolution',
                                          ),
                                          CustomSizedBox(
                                            value: 10,
                                            side: 'width',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            iconSize: 40,
                                            color: Color.fromARGB(
                                                255, 141, 13, 21),
                                            onPressed: _addIssue,
                                          ),
                                        ],
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      issues.isEmpty
                                          ? const Center(
                                              child: Text('No records'))
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: issues.length,
                                              itemBuilder: (context, index) {
                                                return ListTile(
                                                  title: Text(
                                                      '${index + 1}. Issue: ${issues[index].issue}\n    Resolution: ${issues[index].resolution}'),
                                                  trailing: IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    onPressed: () =>
                                                        _deleteIssue(index),
                                                  ),
                                                );
                                              },
                                            ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                          label:
                                              '5. Additional comments on teacher capacity'),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),

                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .additionalCommentOnteacherCapacityController,
                                        labelText: 'Write your comments if any',
                                        showCharacterCount: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Row(
                                        children: [
                                          CustomButton(
                                              title: 'Back',
                                              onPressedButton: () {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showTeacherCapacity =
                                                      true;
                                                  inPersonQuantitativeController
                                                          .showSchoolRefresherTraining =
                                                      false;
                                                });
                                              }),
                                          const Spacer(),
                                          CustomButton(
                                            title: 'Next',
                                            onPressedButton: () {
                                              // Check if staff attended is 0
                                              int staffAttended = int.tryParse(
                                                      inPersonQuantitativeController
                                                          .staafAttendedTrainingController
                                                          .text) ??
                                                  0;

                                              if (staffAttended == 0) {
                                                setState(() {
                                                  showError = true;
                                                  errorMessage =
                                                      '0 participants cannot be accepted';
                                                });
                                                return;
                                              }
                                              // Check if at least one checkbox is selected
                                              bool isCheckboxSelected = inPersonQuantitativeController.checkboxValue1 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue2 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue3 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue4 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue5 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue6 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue7 ||
                                                  inPersonQuantitativeController
                                                      .checkboxValue8;

                                              if (!isCheckboxSelected) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                      .checkBoxError = true;
                                                });
                                              } else {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                      .checkBoxError = false;
                                                });
                                              }
                                              // Check if a value for _selectedValue9 is selected
                                              final isRadioValid9 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'practicalDemo');

                                              if (participants.length !=
                                                      staffAttended ||
                                                  staffAttended == 0) {
                                                setState(() {
                                                  showError = true;
                                                });
                                              } else {
                                                setState(() {
                                                  showError = false;
                                                });
                                              }

                                              // Validate the form and other conditions
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  isRadioValid9 &&
                                                  !inPersonQuantitativeController
                                                      .checkBoxError &&
                                                  _isImageUploaded2 && // This line ensures the error is bypassed if the image is uploaded
                                                  !showError) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showSchoolRefresherTraining =
                                                      false;
                                                  inPersonQuantitativeController
                                                          .showDigiLabClasses =
                                                      true;
                                                });
                                              } else {
                                                setState(() {
                                                  validateRegister2 =
                                                      !_isImageUploaded2; // Only show the image error if no image is uploaded
                                                });
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],

                                    // Starting of digilab classes
                                    if (inPersonQuantitativeController
                                        .showDigiLabClasses) ...[
                                      LabelText(
                                        label: 'DigiLab Classes',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '1. Are the children comfortable using the tabs and navigating the content?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'childrenComfortable'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'childrenComfortable',
                                                        value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'childrenComfortable'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'childrenComfortable',
                                                        value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'childrenComfortable'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '2. Are the children able to understand the content?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'childrenContent'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'childrenContent',
                                                        value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'childrenContent'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'childrenContent',
                                                        value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError(
                                              'childrenContent'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '3. Are post-tests being completed by children at the end of each chapter?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'postTeacher'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'postTeacher', value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'postTeacher'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'postTeacher', value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('postTeacher'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '4. Are the teachers able to help children resolve doubts or issues during the DigiLab classes?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'teacherHelp'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'teacherHelp', value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'teacherHelp'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'teacherHelp', value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('teacherHelp'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '5.  Are the digiLab logs being filled?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabLog'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'digiLabLog', value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabLog'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'digiLabLog', value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('digiLabLog'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                              .getSelectedValue('digiLabLog') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '5.1  If yes,are the logs being filled correctly?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'logFilled'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'logFilled', value);
                                                },
                                              ),
                                              const Text('Yes'),
                                            ],
                                          ),
                                        ),
                                        CustomSizedBox(
                                          value: 150,
                                          side: 'width',
                                        ),
                                        // make it that user can also edit the tourId and school
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'logFilled'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'logFilled', value);
                                                },
                                              ),
                                              const Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError('logFilled'))
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '6. Is "Send Report" being done on each used tab at the end of the day?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'sendReport'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'sendReport', value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'sendReport'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'sendReport', value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('sendReport'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '7. Is Facilitator App installed and functioning on HMs/Admins phone?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'facilatorApp'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'facilatorApp', value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'facilatorApp'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'facilatorApp', value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('facilatorApp'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'facilatorApp') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '7.1 How often is the data being synced?',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        CustomTextFormField(
                                          textController:
                                              inPersonQuantitativeController
                                                  .howOftenDataBeingSyncedController,
                                          labelText: 'Number of Days',
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(2),
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          textInputType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please fill this field';
                                            }
                                            if (!RegExp(r'^[0-9]+$')
                                                .hasMatch(value)) {
                                              return 'Please enter a valid number';
                                            }
                                            return null;
                                          },
                                          showCharacterCount: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        LabelText(
                                          label:
                                              '7.2 When was the data last synced on the Facilitator App?',
                                          astrick: true,
                                        ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                        TextField(
                                          controller:
                                              inPersonQuantitativeController
                                                  .dateController,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            labelText: 'Select Date',
                                            errorText:
                                                inPersonQuantitativeController
                                                        .dateFieldError
                                                    ? 'Date is required'
                                                    : null,
                                            suffixIcon: IconButton(
                                              icon: const Icon(
                                                  Icons.calendar_today),
                                              onPressed: () {
                                                _selectDate(context);
                                              },
                                            ),
                                          ),
                                          onTap: () {
                                            _selectDate(context);
                                          },
                                        ),
                                      ],
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Row(
                                        children: [
                                          CustomButton(
                                              title: 'Back',
                                              onPressedButton: () {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showSchoolRefresherTraining =
                                                      true;
                                                  inPersonQuantitativeController
                                                          .showDigiLabClasses =
                                                      false;
                                                });
                                              }),
                                          const Spacer(),
                                          CustomButton(
                                            title: 'Next',
                                            onPressedButton: () {
                                              // Validate radio selections
                                              final isRadioValid10 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'childrenComfortable');
                                              final isRadioValid11 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'childrenContent');
                                              final isRadioValid12 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'postTeacher');
                                              final isRadioValid13 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'teacherHelp');
                                              final isRadioValid14 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'digiLabLog');

                                              bool isRadioValid15 =
                                                  true; // Default to true
                                              // Only validate 'logFilled' if 'digiLabLog' is 'Yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'digiLabLog') ==
                                                  'Yes') {
                                                isRadioValid15 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'logFilled');
                                              }

                                              final isRadioValid16 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'sendReport');
                                              final isRadioValid17 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'facilatorApp');

                                              // Conditionally validate the date field if 'facilatorApp' is 'Yes'
                                              bool _dateFieldError = false;
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'facilatorApp') ==
                                                  'Yes') {
                                                _dateFieldError =
                                                    inPersonQuantitativeController
                                                        .dateController
                                                        .text
                                                        .isEmpty;
                                              }

                                              setState(() {
                                                // Update the state to reflect whether the date field has an error
                                                this
                                                        .inPersonQuantitativeController
                                                        .dateFieldError =
                                                    _dateFieldError;
                                              });

                                              // Validate form and all conditions
                                              if (_formKey.currentState!
                                                      .validate() &&
                                                  isRadioValid10 &&
                                                  isRadioValid11 &&
                                                  isRadioValid12 &&
                                                  isRadioValid13 &&
                                                  isRadioValid14 &&
                                                  isRadioValid15 &&
                                                  isRadioValid16 &&
                                                  isRadioValid17 &&
                                                  !_dateFieldError) {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showDigiLabClasses =
                                                      false;
                                                  inPersonQuantitativeController
                                                      .showLibrary = true;
                                                });
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                    ],
                                    //   Ending of DigiLab Classes
                                    // Starting of library
                                    if (inPersonQuantitativeController
                                        .showLibrary) ...[
                                      LabelText(
                                        label: 'Library',
                                        astrick: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '1. Is a Library timetable available?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'libTmeTable'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'libTmeTable', value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'libTmeTable'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'libTmeTable', value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('libTmeTable'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      if (inPersonQuantitativeController
                                              .getSelectedValue(
                                                  'libTmeTable') ==
                                          'Yes') ...[
                                        LabelText(
                                          label:
                                              '1.1 is the timetable being followed?',
                                          astrick: true,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'Yes',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'followedTimeTable'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'followedTimeTable',
                                                          value);
                                                },
                                              ),
                                              const Text('Yes'),
                                            ],
                                          ),
                                        ),
                                        CustomSizedBox(
                                          value: 150,
                                          side: 'width',
                                        ),
                                        // make it that user can also edit the tourId and school
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 300),
                                          child: Row(
                                            children: [
                                              Radio(
                                                value: 'No',
                                                groupValue:
                                                    inPersonQuantitativeController
                                                        .getSelectedValue(
                                                            'followedTimeTable'),
                                                onChanged: (value) {
                                                  inPersonQuantitativeController
                                                      .setRadioValue(
                                                          'followedTimeTable',
                                                          value);
                                                },
                                              ),
                                              const Text('No'),
                                            ],
                                          ),
                                        ),
                                        if (inPersonQuantitativeController
                                            .getRadioFieldError(
                                                'followedTimeTable'))
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 16.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Please select an option',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        CustomSizedBox(
                                          value: 20,
                                          side: 'height',
                                        ),
                                      ],
                                      LabelText(
                                        label:
                                            '2. Is the Library register updated?',
                                        astrick: true,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'Yes',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'updatedLibrary'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'updatedLibrary',
                                                        value);
                                              },
                                            ),
                                            const Text('Yes'),
                                          ],
                                        ),
                                      ),
                                      CustomSizedBox(
                                        value: 150,
                                        side: 'width',
                                      ),
                                      // make it that user can also edit the tourId and school
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 300),
                                        child: Row(
                                          children: [
                                            Radio(
                                              value: 'No',
                                              groupValue:
                                                  inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'updatedLibrary'),
                                              onChanged: (value) {
                                                inPersonQuantitativeController
                                                    .setRadioValue(
                                                        'updatedLibrary',
                                                        value);
                                              },
                                            ),
                                            const Text('No'),
                                          ],
                                        ),
                                      ),
                                      if (inPersonQuantitativeController
                                          .getRadioFieldError('updatedLibrary'))
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please select an option',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      LabelText(
                                        label:
                                            '3. Additional observations on Library',
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      CustomTextFormField(
                                        textController:
                                            inPersonQuantitativeController
                                                .additionalObservationOnLibraryController,
                                        labelText: 'Write Comments if any',
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please fill this field';
                                          }
                                          return null;
                                        },
                                        showCharacterCount: true,
                                      ),
                                      CustomSizedBox(
                                        value: 20,
                                        side: 'height',
                                      ),
                                      Row(
                                        children: [
                                          CustomButton(
                                              title: 'Back',
                                              onPressedButton: () {
                                                setState(() {
                                                  inPersonQuantitativeController
                                                          .showDigiLabClasses =
                                                      true;
                                                  inPersonQuantitativeController
                                                      .showLibrary = false;
                                                });
                                              }),
                                          const Spacer(),
                                          CustomButton(
                                            title: 'Submit',
                                            onPressedButton: () async {
                                              final isRadioValid18 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'libTmeTable');

                                              bool isRadioValid19 =
                                                  true; // Default to true
                                              // Only validate 'logFilled' if 'digiLabLog' is 'Yes'
                                              if (inPersonQuantitativeController
                                                      .getSelectedValue(
                                                          'libTmeTable') ==
                                                  'Yes') {
                                                isRadioValid19 =
                                                    inPersonQuantitativeController
                                                        .validateRadioSelection(
                                                            'followedTimeTable');
                                              }

                                              final isRadioValid20 =
                                                  inPersonQuantitativeController
                                                      .validateRadioSelection(
                                                          'updatedLibrary');

                                              setState(() {
                                                inPersonQuantitativeController
                                                    .checkBoxError = !(inPersonQuantitativeController
                                                        .checkboxValue1 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue2 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue3 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue4 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue5 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue6 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue7 ||
                                                    inPersonQuantitativeController
                                                        .checkboxValue8);

                                                validateRegister =
                                                    !_isImageUploaded;
                                              });

                                              if (!inPersonQuantitativeController
                                                  .checkBoxError) {
                                                // Combine all checkbox values into a single string
                                                String refresherTrainingTopic =
                                                    [
                                                  inPersonQuantitativeController
                                                          .checkboxValue1
                                                      ? 'Operating DigiLab'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue2
                                                      ? 'Operating tablets'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue3
                                                      ? 'Creating students IDs'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue4
                                                      ? 'Grade Wise DigiLab subjects & Chapters'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue5
                                                      ? 'Importance of completing post test'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue6
                                                      ? 'Saving and submitting data(Send Report)'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue7
                                                      ? 'Syncing data with Pi'
                                                      : null,
                                                  inPersonQuantitativeController
                                                          .checkboxValue8
                                                      ? 'Any other'
                                                      : null,
                                                ]
                                                        .where((value) =>
                                                            value != null)
                                                        .join(', ');

                                                if (_formKey.currentState!
                                                        .validate() &&
                                                    isRadioValid18 &&
                                                    isRadioValid19 &&
                                                    isRadioValid20) {
                                                  // Combine participants data into a single string
                                                  String participantsDataJson = jsonEncode(participants.map((participant) {
                                                    return {
                                                      'Name': participant.nameOfParticipants,
                                                      'Designation': participant.designation,
                                                    };
                                                  }).toList());

                                                  // Convert issues data to JSON
                                                  String issueAndResolutionJson = jsonEncode(issues.map((issue) {
                                                    return {
                                                      'Issue': issue.issue,
                                                      'Resolution': issue.resolution,
                                                      'IsResolved': issue.isResolved ? "Yes" : "No",
                                                    };
                                                  }).toList());

                                                  DateTime now = DateTime.now();
                                                  String formattedDate =
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(now);

                                                  String generateUniqueId(int length) {
                                                    const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                                                    Random _rnd = Random();
                                                    return String.fromCharCodes(Iterable.generate(
                                                        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
                                                  }

                                                  String uniqueId = generateUniqueId(6);

                                                  // Concatenate values if "Yes" is selected for teacher IDs
                                                  String teacherIdsCreatedValue = inPersonQuantitativeController.getSelectedValue('idHasBeenCreated') ?? '';
                                                  String teacherComfortableValue = teacherIdsCreatedValue == 'Yes'
                                                      ? (inPersonQuantitativeController.getSelectedValue('teacherUsingTablet') ?? '')
                                                      : '';

                                                  String concatenatedValue = '$teacherIdsCreatedValue $teacherComfortableValue';

                                                  List<String> base64Images = [];
                                                  for (var file in _imageFiles) {
                                                    List<int> imageBytes = await file.readAsBytes();
                                                    String base64Image = base64Encode(imageBytes);
                                                    base64Images.add(base64Image);
                                                  }

                                                  List<String> base642Images = [];
                                                  for (var file in _imageFiles2) {
                                                    List<int> imageBytes = await file.readAsBytes();
                                                    String base642Image = base64Encode(imageBytes);
                                                    base642Images.add(base642Image);
                                                  }

                                                  // Create enrolment collection object
                                                  InPersonQuantitativeRecords
                                                      enrolmentCollectionObj =
                                                      InPersonQuantitativeRecords(
                                                    tourId:
                                                        inPersonQuantitativeController
                                                                .tourValue ??
                                                            '',
                                                    school:
                                                        inPersonQuantitativeController
                                                                .schoolValue ??
                                                            '',
                                                    udicevalue:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'udiCode') ??
                                                            '',
                                                    correct_udice:
                                                        inPersonQuantitativeController
                                                            .correctUdiseCodeController
                                                            .text,
                                                    imgpath:base64Images.join(","),
                                                    no_enrolled:
                                                        inPersonQuantitativeController
                                                            .noOfEnrolledStudentAsOnDateController
                                                            .text,
                                                    timetable_available:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'digiLabSchedule') ??
                                                            '',
                                                    class_scheduled:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'class2Hours') ??
                                                            '',
                                                        remarks_scheduling:
                                                        inPersonQuantitativeController
                                                            .instructionProvidedRegardingClassSchedulingController
                                                            .text,

                                                    admin_appointed:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'isDigiLabAdminAppointed') ??
                                                            '',
                                                    admin_trained:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'isDigiLabAdminTrained') ??
                                                            '',
                                                    admin_name:
                                                        inPersonQuantitativeController
                                                            .digiLabAdminNameController
                                                            .text,
                                                    admin_phone:
                                                        inPersonQuantitativeController
                                                            .digiLabAdminPhoneNumberController
                                                            .text,
                                                    sub_teacher_trained:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'areAllTeacherTrained') ??
                                                            '',
                                                    teacher_ids:
                                                    concatenatedValue, // Use the concatenated value here

                                                    no_staff:
                                                        inPersonQuantitativeController
                                                            .staafAttendedTrainingController
                                                            .text,
                                                    training_pic: base642Images.join(","),
                                                    specifyOtherTopics:
                                                        inPersonQuantitativeController
                                                            .otherTopicsController
                                                            .text,
                                                    practical_demo:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'practicalDemo') ??
                                                            '',
                                                    reason_demo:
                                                        inPersonQuantitativeController
                                                            .reasonForNotGivenpracticalDemoController
                                                            .text,
                                                    comments_capacity:
                                                        inPersonQuantitativeController
                                                            .additionalCommentOnteacherCapacityController
                                                            .text,
                                                    children_comfortable:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'teacherUsingTablet') ??
                                                            '',
                                                    children_understand:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'childrenContent') ??
                                                            '',
                                                    post_test:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'postTeacher') ??
                                                            '',
                                                    resolved_doubts:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'teacherHelp') ??
                                                            '',
                                                    logs_filled:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'digiLabLog') ??
                                                            '',
                                                    filled_correctly:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'logFilled') ??
                                                            '',
                                                    send_report:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'sendReport') ??
                                                            '',
                                                    app_installed:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'facilatorApp') ??
                                                            '',
                                                    data_synced:
                                                        inPersonQuantitativeController
                                                            .howOftenDataBeingSyncedController
                                                            .text,
                                                    last_syncedDate:
                                                        inPersonQuantitativeController
                                                            .dateController
                                                            .text,
                                                    lib_timetable:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'libTmeTable') ??
                                                            '',
                                                    timetable_followed:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'followedTimeTable') ??
                                                            '',
                                                    registered_updated:
                                                        inPersonQuantitativeController
                                                                .getSelectedValue(
                                                                    'updatedLibrary') ??
                                                            '',
                                                    observation_comment:
                                                        inPersonQuantitativeController
                                                            .additionalObservationOnLibraryController
                                                            .text,
                                                    topicsCoveredInTraining:
                                                        refresherTrainingTopic,
                                                    submitted_by: widget.userid
                                                        .toString(),
                                                    participant_name:
                                                    participantsDataJson,
                                                    major_issue:
                                                    issueAndResolutionJson,
                                                    created_at: formattedDate
                                                        .toString(),
                                                        unique_id: uniqueId,
                                                  );

                                                  // Save data to local database
                                                  int result = await LocalDbController()
                                                      .addData(
                                                          inPersonQuantitativeRecords:
                                                              enrolmentCollectionObj);
                                                  print(result);
                                                  if (result > 0) {
                                                    inPersonQuantitativeController
                                                        .clearFields();
                                                    setState(() {
                                                      _imageFiles =
                                                          []; // Clear the image list
                                                    });

                                                    customSnackbar(
                                                      'Submitted Successfully',
                                                      'submitted',
                                                      AppColors.primary,
                                                      AppColors.onPrimary,
                                                      Icons.verified,
                                                    );
                                                    // Navigate to HomeScreen
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              HomeScreen()),
                                                    );
                                                  } else {
                                                    customSnackbar(
                                                      'Error',
                                                      'Something went wrong',
                                                      AppColors.primary,
                                                      AppColors.onPrimary,
                                                      Icons.error,
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ]
                                  ] // End of main Column
                                      );
                                }));
                      }),
                ],
              ),
            ),
          ),
        ));
  }
}

class Issue {
  String issue;
  String resolution;
  bool isResolved;

  Issue({
    required this.issue,
    required this.resolution,
    required this.isResolved,
  });
}

class AddIssueBottomSheet extends StatefulWidget {
  @override
  _AddIssueBottomSheetState createState() => _AddIssueBottomSheetState();
}

class _AddIssueBottomSheetState extends State<AddIssueBottomSheet> {
  final TextEditingController writeIssueController = TextEditingController();
  final TextEditingController writeResolutionController =
      TextEditingController();
  String? isResolved;

  // Key to manage the state of the form
  final _formKey = GlobalKey<FormState>();

  // Variable to track if an error should be shown for the radio buttons
  bool showRadioError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  LabelText(
                    label: 'Write issue',
                    astrick: true,
                  ),
                  CustomSizedBox(
                    value: 20,
                    side: 'height',
                  ),
                  CustomTextFormField(
                    textController: writeIssueController,
                    labelText: 'Write your issue',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the issue';
                      }
                      return null;
                    },
                  ),
                  CustomSizedBox(
                    value: 20,
                    side: 'height',
                  ),
                  LabelText(
                    label: 'Write your resolution',
                    astrick: true,
                  ),
                  CustomSizedBox(
                    value: 20,
                    side: 'height',
                  ),
                  CustomTextFormField(
                    textController: writeResolutionController,
                    labelText: 'Write your resolution',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the resolution';
                      }
                      return null;
                    },
                  ),
                  CustomSizedBox(
                    value: 20,
                    side: 'height',
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 80),
                    child: Column(
                      children: [
                        LabelText(
                          label: 'Is the issue resolved or not?',
                          astrick: true,
                        ),
                        ListTile(
                          title: const Text('Yes'),
                          leading: Radio<String>(
                            value: 'Yes',
                            groupValue: isResolved,
                            onChanged: (String? value) {
                              setState(() {
                                isResolved = value;
                                showRadioError =
                                    false; // Reset the error display
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('No'),
                          leading: Radio<String>(
                            value: 'No',
                            groupValue: isResolved,
                            onChanged: (String? value) {
                              setState(() {
                                isResolved = value;
                                showRadioError =
                                    false; // Reset the error display
                              });
                            },
                          ),
                        ),
                        if (showRadioError) // Show error only after submission attempt
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Please select if the issue is resolved or not',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    title: 'Cancel',
                    onPressedButton: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Spacer(),
                  CustomButton(
                    title: 'Add',
                    onPressedButton: () {
                      // Validate the form fields
                      bool isValid = _formKey.currentState!.validate();

                      // Check if the radio button is selected
                      if (isResolved == null) {
                        setState(() {
                          showRadioError = true;
                        });
                        isValid = false;
                      }

                      if (isValid) {
                        final issue = Issue(
                          issue: writeIssueController.text,
                          resolution: writeResolutionController.text,
                          isResolved: isResolved == 'Yes',
                        );

                        // Clear the fields after adding the issue
                        setState(() {
                          writeIssueController.clear();
                          writeResolutionController.clear();
                          isResolved = null;
                          showRadioError = false;
                        });

                        Navigator.of(context).pop(issue);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Participants {
  String nameOfParticipants;
  String designation;

  Participants({required this.nameOfParticipants, required this.designation});
}

class AddParticipantsBottomSheet extends StatefulWidget {
  final List<String> existingRoles;

  AddParticipantsBottomSheet({required this.existingRoles});

  @override
  _AddParticipantsBottomSheetState createState() =>
      _AddParticipantsBottomSheetState();
}

class _AddParticipantsBottomSheetState
    extends State<AddParticipantsBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final InPersonQuantitativeController inPersonQuantitativeController =
      Get.put(InPersonQuantitativeController());
  String? _selectedDesignation;

  @override
  void initState() {
    super.initState();
    if (widget.existingRoles.isNotEmpty) {
      _selectedDesignation =
          widget.existingRoles.first; // Default to the first role for editing
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid'),
          iconColor: Color(0xffffffff),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LabelText(label: 'Participants Name', astrick: true),
              CustomSizedBox(value: 20, side: 'height'),
              CustomTextFormField(
                textController:
                    inPersonQuantitativeController.participantsNameController,
                labelText: 'Participants Name',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter participant name';
                  }
                  return null;
                },
              ),
              CustomSizedBox(value: 20, side: 'height'),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Participants Designation',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDesignation,
                items: [
                  DropdownMenuItem(
                      value: 'DigiLab Admin', child: Text('DigiLab Admin')),
                  DropdownMenuItem(
                      value: 'HeadMaster', child: Text('HeadMaster')),
                  DropdownMenuItem(
                      value: 'In Charge', child: Text('In Charge')),
                  DropdownMenuItem(value: 'Teacher', child: Text('Teacher')),
                  DropdownMenuItem(
                      value: 'Temporary Teacher',
                      child: Text('Temporary Teacher')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDesignation = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a designation';
                  }
                  return null;
                },
              ),
              CustomSizedBox(value: 20, side: 'height'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    title: 'Cancel',
                    onPressedButton: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Spacer(),
                  CustomButton(
                    title: 'Add',
                    onPressedButton: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.existingRoles
                            .contains(_selectedDesignation)) {
                          _showErrorDialog(
                              'The selected role is already assigned to another participant.');
                        } else {
                          final participants = Participants(
                            nameOfParticipants: inPersonQuantitativeController
                                .participantsNameController.text,
                            designation: _selectedDesignation!,
                          );
                          // Clear the participant name
                          inPersonQuantitativeController
                              .participantsNameController
                              .clear();
                          setState(() {
                            _selectedDesignation =
                                null; // Clear the dropdown selection
                          });
                          Navigator.of(context).pop(participants);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
