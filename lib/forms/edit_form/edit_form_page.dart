import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart'; // Import this

import '../../components/custom_appBar.dart';
import '../../components/custom_dropdown.dart';
import '../../components/custom_labeltext.dart';
import '../../tourDetails/tour_controller.dart';
import '../school_facilities_&_mapping_form/SchoolFacilitiesForm.dart';
import '../school_facilities_&_mapping_form/school_facilities_modals.dart';
import '../school_staff_vec_form/school_vec_from.dart';
import '../school_staff_vec_form/school_vec_modals.dart';
import 'edit controller.dart';


class TourSchoolSelection extends StatefulWidget {
  const TourSchoolSelection({Key? key}) : super(key: key);

  @override
  _TourSchoolSelectionState createState() => _TourSchoolSelectionState();
}

class _TourSchoolSelectionState extends State<TourSchoolSelection> {
  Map<String, dynamic> schoolData = {};
  List<String> schoolNames = [];
  String? selectedSchool;
  String? selectedForm;
  List<dynamic> filteredData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEditPopupIfNeeded();
    });
  }

  // Check internet connection status
  Future<bool> hasInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  // Fetch data from API or local storage
  Future<void> fetchTourData(String tourId) async {
    setState(() {
      isLoading = true;
    });

    final bool isConnected = await hasInternetConnection();
    if (isConnected) {
      // Fetch data from API if online
      final url =
          'https://mis.17000ft.org/apis/fast_apis/pre-fill-data.php?id=$tourId';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          await saveDataLocally(tourId, data); // Save data locally
          setState(() {
            schoolData = data;
            schoolNames = data.keys.toList();
            selectedSchool = null;
            selectedForm = null;
            filteredData = [];
          });
        } else {
          Get.snackbar('Error', 'Failed to load tour data from API');
          loadTourData(tourId); // Load local cache in case API fails
        }
      } catch (e) {
        Get.snackbar('Error', 'An error occurred while fetching data from API');
        loadTourData(tourId); // Load local cache in case of an error
      }
    } else {
      // Load cached data when offline
      Get.snackbar('Offline', 'No internet connection, loading cached data');
      loadTourData(tourId);
    }

    setState(() {
      isLoading = false;
    });
  }

  // Save data to local storage using SharedPreferences
  Future<void> saveDataLocally(String tourId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('submitted_data_$tourId', json.encode(data));
    prefs.setString(
        'last_submitted_tour_id', tourId); // Save the last submitted tour ID
  }

  // Load data from local storage
  Future<void> loadTourData(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('submitted_data_$tourId');

    if (storedData != null) {
      final data = json.decode(storedData);
      setState(() {
        schoolData = data;
        schoolNames = data.keys.toList();
        selectedSchool = null;
        selectedForm = null;
        filteredData = [];
      });
    } else {
      Get.snackbar('Error', 'No cached data available for this tour');
    }
  }

  Future<void> _showEditPopupIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSubmittedTourId = prefs.getString('last_submitted_tour_id');

    if (lastSubmittedTourId != null) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Edit Your Previous Submission',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Text(
            'Do you want to edit data for tour ID $lastSubmittedTourId?',
            style: TextStyle(fontSize: 16),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    fetchTourData(lastSubmittedTourId);
                  },
                  child: Text(
                    'Edit',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  // Update school selection
  void onSchoolSelected(String? schoolName) {
    setState(() {
      selectedSchool = schoolName;
      filteredData = [];
      selectedForm = null; // Reset form selection
    });
  }

  // Update form selection and fetch data accordingly
  void onFormSelected(String? formType) {
    setState(() {
      selectedForm = formType;
    });

    if (selectedSchool != null && selectedForm != null) {
      final formData = schoolData[selectedSchool]?[selectedForm];
      setState(() {
        filteredData = formData != null && formData.isNotEmpty
            ? formData
            : []; // If empty, set as empty list
      });
    }
  }

  // Display snackbar on edit button press
  void onEditButtonPressed(int index) {
    Get.snackbar('Edit', 'Edit button pressed for index $index');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Edit Form',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GetBuilder<EditController>(
          init: EditController(),
          builder: (editController) {
            return Form(
              key: GlobalKey<FormState>(),
              child: GetBuilder<TourController>(
                init: TourController(),
                builder: (tourController) {
                  tourController.fetchTourDetails();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tour ID Dropdown
                      LabelText(
                        label: 'Tour ID',
                        astrick: true,
                      ),
                      const SizedBox(height: 12),
                      CustomDropdownFormField(
                        focusNode: editController.tourIdFocusNode,
                        options: tourController.getLocalTourList
                            .map((e) => e.tourId)
                            .toList(),
                        selectedOption: editController.tourValue,
                        onChanged: (value) {
                          setState(() {
                            editController.setTour(value);
                            fetchTourData(value!);
                          });
                        },
                        labelText: "Select Tour ID",
                      ),
                      const SizedBox(height: 20),

                      // School Dropdown
                      LabelText(
                        label: 'School',
                        astrick: true,
                      ),
                      const SizedBox(height: 12),
                      DropdownSearch<String>(
                        items: schoolNames,
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Select School",
                            hintText: "Select School",
                          ),
                        ),
                        onChanged: onSchoolSelected,
                        selectedItem: selectedSchool,
                      ),
                      const SizedBox(height: 20),

                      // Form Type Dropdown (facilities, enrollment, vec)
                      if (selectedSchool != null) ...[
                        LabelText(
                          label: 'Form Type',
                          astrick: true,
                        ),
                        const SizedBox(height: 12),
                        DropdownSearch<String>(
                          items: [
                            'facilities',
                            'enrollment',
                            'vec'
                          ], // The forms to choose
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Select Form",
                              hintText: "Select Form Type",
                            ),
                          ),
                          onChanged: onFormSelected,
                          selectedItem: selectedForm,
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Show loader while fetching data
                      if (isLoading)
                        const Center(child: CircularProgressIndicator()),

                      // Display selected form data or No Records message
                      if (selectedSchool != null && selectedForm != null)
                        Expanded(
                          child: ListView(children: [
                            if (filteredData.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                    'No records found for the selected form.'),
                              )
                            else ...[
                              // Enrollment Section
                              if (selectedForm == 'enrollment' &&
                                  filteredData.isNotEmpty)
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Enrollment:',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                        const NeverScrollableScrollPhysics(),
                                        itemCount: filteredData.length,
                                        itemBuilder: (context, index) {
                                          final item = filteredData[index];
                                          return ListTile(
                                            title: Text(
                                                'Boys Count: ${item['boysCount']}'),
                                            subtitle: Text(
                                                'Girls Count: ${item['girlsCount']}'),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                onEditButtonPressed(index);
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                              // Facilities Section
                              if (selectedForm == 'facilities' &&
                                  filteredData.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Facilities Data:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...List.generate(
                                        filteredData.length,
                                            (index) {
                                          final facility =
                                          filteredData[index];
                                          return Card(
                                            margin:
                                            const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: ListTile(
                                              title: Text(
                                                  'Tour ID: ${facility['tourId']}'),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      "Residential Value: ${facility['residentialValue']}"),
                                                  Text(
                                                      "Electricity Value: ${facility['electricityValue']}"),
                                                  Text(
                                                      "Internet Value: ${facility['internetValue']}"),
                                                  Text(
                                                      "School: ${facility['school']}"),
                                                ],
                                              ),
                                              trailing: IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SchoolFacilitiesForm(
                                                            userid:
                                                            'userid', // Pass necessary userId and office
                                                            existingRecord:
                                                            SchoolFacilitiesRecords(
                                                              residentialValue:
                                                              facility[
                                                              'residentialValue'],
                                                              electricityValue:
                                                              facility[
                                                              'electricityValue'],
                                                              internetValue: facility[
                                                              'internetValue'],
                                                              udiseCode: facility[
                                                              'udiseValue'],
                                                              correctUdise: facility[
                                                              'correctUdise'],
                                                              school: facility[
                                                              'school'],
                                                              projectorValue:
                                                              facility[
                                                              'projectorValue'],
                                                              smartClassValue:
                                                              facility[
                                                              'smartClassValue'],
                                                              numFunctionalClass:
                                                              facility[
                                                              'numFunctionalClass'],
                                                              playgroundValue:
                                                              facility[
                                                              'playgroundValue'],
                                                              libValue: facility[
                                                              'libValue'],
                                                              libLocation: facility[
                                                              'libLocation'],
                                                              librarianName: facility[
                                                              'librarianName'],
                                                              librarianTraining:
                                                              facility[
                                                              'librarianTraining'],
                                                              libRegisterValue:
                                                              facility[
                                                              'libRegisterValue'],
                                                              created_by: facility[
                                                              'created_by'],
                                                              created_at: facility[
                                                              'created_at'],
                                                            ),
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                            ],
                          ]),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
