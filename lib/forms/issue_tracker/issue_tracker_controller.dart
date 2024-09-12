import 'dart:io';
import 'dart:convert';
import 'package:app17000ft_new/constants/color_const.dart';
import 'package:app17000ft_new/forms/issue_tracker/issue_tracker_modal.dart';
import 'package:app17000ft_new/forms/issue_tracker/lib_issue_modal.dart';
import 'package:app17000ft_new/forms/issue_tracker/play_issue_modal.dart';
import 'package:app17000ft_new/forms/school_facilities_&_mapping_form/school_facilities_modals.dart';
import 'package:app17000ft_new/forms/school_staff_vec_form/school_vec_modals.dart';
import 'package:app17000ft_new/helper/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../base_client/baseClient_controller.dart';

class IssueTrackerController extends GetxController with BaseController {
  var counterText = ''.obs;

  String? _tourValue;
  String? get tourValue => _tourValue;

  String? _schoolValue;
  String? get schoolValue => _schoolValue;

  bool isLoading = false;

  final TextEditingController correctUdiseCodeController = TextEditingController();
  final TextEditingController libraryDescriptionController = TextEditingController();
  final TextEditingController playgroundDescriptionController = TextEditingController();
  final TextEditingController digiLabDescriptionController = TextEditingController();
  final TextEditingController classroomDescriptionController = TextEditingController();
  final TextEditingController alexaDescriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController dateController2 = TextEditingController();
  final TextEditingController dateController3 = TextEditingController();
  final TextEditingController dateController4 = TextEditingController();
  final TextEditingController dateController5 = TextEditingController();
  final TextEditingController dateController6 = TextEditingController();
  final TextEditingController dateController7 = TextEditingController();
  final TextEditingController dateController8 = TextEditingController();
  final TextEditingController dateController9 = TextEditingController();
  final TextEditingController dateController10 = TextEditingController();


  final FocusNode _tourIdFocusNode = FocusNode();
  FocusNode get tourIdFocusNode => _tourIdFocusNode;

  final FocusNode _schoolFocusNode = FocusNode();
  FocusNode get schoolFocusNode => _schoolFocusNode;

  List<IssueTrackerRecords> _issueTrackerList = [];
  List<IssueTrackerRecords> get issueTrackerList => _issueTrackerList;


  // List to store fetched LibIssue records
  List<LibIssue> _libIssueList = [];
  List<LibIssue> get libIssueList => _libIssueList;
  // List<LibIssue> _libIssueList = [];
  // List<LibIssue> get libIssueList => _libIssueList;
  //
  // List<PlayIssue> _playIssueList = [];
  // List<PlayIssue> get playIssueListList => _playIssueList;

  List<String> _staffNames = [];
  List<String> get staffNames => _staffNames;

  final List<XFile> _multipleImage = [];
  List<XFile> get multipleImage => _multipleImage;

  List<String> _imagePaths = [];
  List<String> get imagePaths => _imagePaths;

  final List<XFile> _multipleImage2 = [];
  List<XFile> get multipleImage2 => _multipleImage2;

  List<String> _imagePaths2 = [];
  List<String> get imagePaths2 => _imagePaths2;


  final List<XFile> _multipleImage3 = [];
  List<XFile> get multipleImage3 => _multipleImage3;

  List<String> _imagePaths3 = [];
  List<String> get imagePaths3 => _imagePaths3;

  final List<XFile> _multipleImage4 = [];
  List<XFile> get multipleImage4 => _multipleImage4;

  List<String> _imagePaths4 = [];
  List<String> get imagePaths4 => _imagePaths4;


  final List<XFile> _multipleImage5 = [];
  List<XFile> get multipleImage5 => _multipleImage5;

  List<String> _imagePaths5 = [];
  List<String> get imagePaths5 => _imagePaths5;

  void setSchool(String? value) {
    _schoolValue = value;
    update();
  }

  void setTour(String? value) {
    _tourValue = value;
    update();
  }


  Future<String> takePhoto(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    List<XFile> selectedImages = [];

    _imagePaths = [];
    if (source == ImageSource.gallery) {
      selectedImages = await picker.pickMultiImage();
      _multipleImage.addAll(selectedImages);
      for (var image in _multipleImage) {
        _imagePaths.add(image.path);
      }
    } else if (source == ImageSource.camera) {
      XFile? pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        _multipleImage.add(pickedImage);
        _imagePaths.add(pickedImage.path);
      }
    }
    update();
    return _imagePaths.toString();
  }

  Future<String> takePhoto2(ImageSource source) async {
    final ImagePicker picker2 = ImagePicker();
    List<XFile> selectedImages2 = [];

    _imagePaths2 = [];
    if (source == ImageSource.gallery) {
      selectedImages2 = await picker2.pickMultiImage();
      _multipleImage2.addAll(selectedImages2);
      for (var image in _multipleImage2) {
        _imagePaths2.add(image.path);
      }
    } else if (source == ImageSource.camera) {
      XFile? pickedImage2 = await picker2.pickImage(source: source);
      if (pickedImage2 != null) {
        _multipleImage2.add(pickedImage2);
        _imagePaths2.add(pickedImage2.path);
      }
    }
    update();
    return _imagePaths2.toString();
  }


  Future<String> takePhoto3(ImageSource source) async {
    final ImagePicker picker3 = ImagePicker();
    List<XFile> selectedImages3 = [];

    _imagePaths3 = [];
    if (source == ImageSource.gallery) {
      selectedImages3 = await picker3.pickMultiImage();
      _multipleImage3.addAll(selectedImages3);
      for (var image in _multipleImage3) {
        _imagePaths3.add(image.path);
      }
    } else if (source == ImageSource.camera) {
      XFile? pickedImage3 = await picker3.pickImage(source: source);
      if (pickedImage3 != null) {
        _multipleImage3.add(pickedImage3);
        _imagePaths3.add(pickedImage3.path);
      }
    }
    update();
    return _imagePaths3.toString();
  }

  Future<String> takePhoto4(ImageSource source) async {
    final ImagePicker picker4 = ImagePicker();
    List<XFile> selectedImages4 = [];

    _imagePaths3 = [];
    if (source == ImageSource.gallery) {
      selectedImages4 = await picker4.pickMultiImage();
      _multipleImage4.addAll(selectedImages4);
      for (var image in _multipleImage4) {
        _imagePaths4.add(image.path);
      }
    } else if (source == ImageSource.camera) {
      XFile? pickedImage4 = await picker4.pickImage(source: source);
      if (pickedImage4 != null) {
        _multipleImage4.add(pickedImage4);
        _imagePaths4.add(pickedImage4.path);
      }
    }
    update();
    return _imagePaths4.toString();
  }


  Future<String> takePhoto5(ImageSource source) async {
    final ImagePicker picker5 = ImagePicker();
    List<XFile> selectedImages5 = [];

    _imagePaths3 = [];
    if (source == ImageSource.gallery) {
      selectedImages5 = await picker5.pickMultiImage();
      _multipleImage5.addAll(selectedImages5);
      for (var image in _multipleImage5) {
        _imagePaths5.add(image.path);
      }
    } else if (source == ImageSource.camera) {
      XFile? pickedImage5 = await picker5.pickImage(source: source);
      if (pickedImage5 != null) {
        _multipleImage5.add(pickedImage5);
        _imagePaths5.add(pickedImage5.path);
      }
    }
    update();
    return _imagePaths5.toString();
  }



  Widget bottomSheet(BuildContext context) {
    return Container(
      color: AppColors.primary,
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text("Select Image", style: TextStyle(fontSize: 20.0, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto(ImageSource.camera);
                  Get.back();
                },
                child: const Text('Camera', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto(ImageSource.gallery);
                  Get.back();
                },
                child: const Text('Gallery', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomSheet2(BuildContext context) {
    return Container(
      color: AppColors.primary,
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text("Select Image", style: TextStyle(fontSize: 20.0, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto2(ImageSource.camera);
                  Get.back();
                },
                child: const Text('Camera', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto2(ImageSource.gallery);
                  Get.back();
                },
                child: const Text('Gallery', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomSheet3(BuildContext context) {
    return Container(
      color: AppColors.primary,
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text("Select Image", style: TextStyle(fontSize: 20.0, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto3(ImageSource.camera);
                  Get.back();
                },
                child: const Text('Camera', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto3(ImageSource.gallery);
                  Get.back();
                },
                child: const Text('Gallery', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomSheet4(BuildContext context) {
    return Container(
      color: AppColors.primary,
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text("Select Image", style: TextStyle(fontSize: 20.0, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto4(ImageSource.camera);
                  Get.back();
                },
                child: const Text('Camera', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto4(ImageSource.gallery);
                  Get.back();
                },
                child: const Text('Gallery', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomSheet5(BuildContext context) {
    return Container(
      color: AppColors.primary,
      height: 100,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: <Widget>[
          const Text("Select Image", style: TextStyle(fontSize: 20.0, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto5(ImageSource.camera);
                  Get.back();
                },
                child: const Text('Camera', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
              const SizedBox(width: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () async {
                  await takePhoto5(ImageSource.gallery);
                  Get.back();
                },
                child: const Text('Gallery', style: TextStyle(fontSize: 20.0, color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showImagePreview(String imagePath, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.file(File(imagePath), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  void showImagePreview2(String imagePath2, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.file(File(imagePath2), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  void showImagePreview3(String imagePath3, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.file(File(imagePath3), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }


  void showImagePreview4(String imagePath4, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.file(File(imagePath4), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }


  void showImagePreview5(String imagePath5, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.file(File(imagePath5), fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  void clearFields() {
    _tourValue = null;
    _schoolValue = null;
    correctUdiseCodeController.clear();
    libraryDescriptionController.clear();
    dateController.clear();
    dateController2.clear();
    _multipleImage.clear();
    _imagePaths.clear();
    _multipleImage2.clear();
    _imagePaths2.clear();
    update();
  }

  Future<void> fetchData() async {
    isLoading = true;
    update();
    _issueTrackerList = await LocalDbController().fetchLocalIssueTrackerRecords();

    // Fetch LibIssue records (assuming you have a method to fetch them)
    _libIssueList = await LocalDbController().fetchLocalLibIssueRecords();

    // _libIssueList = await LocalDbController().fetchLocalLibIssue();
    // _playIssueList = await LocalDbController().fetchLocalPlayIssue();
    isLoading = false;
    update();
  }



}

