import 'dart:async';
import 'dart:io' as io;
import 'package:app17000ft_new/forms/alfa_observation_form/alfa_obervation_modal.dart';
import 'package:app17000ft_new/forms/fln_observation_form/fln_observation_modal.dart';
import 'package:app17000ft_new/forms/in_person_quantitative/in_person_quantitative_modal.dart';
import 'package:app17000ft_new/forms/issue_tracker/issue_tracker_modal.dart';
import 'package:app17000ft_new/forms/school_recce_form/school_recce_modal.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:app17000ft_new/services/network_manager.dart';
import 'package:app17000ft_new/tourDetails/tour_model.dart';
import 'package:app17000ft_new/forms/school_enrolment/school_enrolment_model.dart';
import '../forms/cab_meter_tracking_form/cab_meter_tracing_modal.dart';
import '../forms/inPerson_qualitative_form/inPerson_qualitative_modal.dart';
import '../forms/issue_tracker/lib_issue_modal.dart';
import '../forms/school_facilities_&_mapping_form/school_facilities_modals.dart';
import '../forms/school_staff_vec_form/school_vec_modals.dart';

final NetworkManager networkManager = Get.put(NetworkManager());

class SqfliteDatabaseHelper {
  SqfliteDatabaseHelper.internal();
  static final SqfliteDatabaseHelper instance =
      SqfliteDatabaseHelper.internal();
  factory SqfliteDatabaseHelper() => instance;

  // Name of the tables
  static const tourDetails = 'tour_details';
  static const schoolEnrolment = 'schoolEnrolment';
  static const cabMeter_tracing = 'cabMeter_tracing';
  static const inPerson_quantitative = 'inPerson_quantitative';
  static const schoolFacilities = 'schoolFacilities';
  static const schoolStaffVec = 'schoolStaffVec';
  static const issueTracker = 'issueTracker';
  static const libIssueTable = 'libIssueTable';
  static const play_issue = 'play_issue';
  static const alfaObservation = 'alfaObservation';
  static const flnObservation = 'flnObservation';
  static const inPerson_qualitative = 'inPerson_qualitative';
  static const schoolRecce = 'schoolRecce';
  static const _dbName = "app17000ft_new.db";
  static const _dbVersion = 48; // Increment this when you make schema changes

  static Database? _db;

  // Function for initializing the database
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await init();
    return _db!;
  }

  // Perform tasks
  Future<Database> init() async {
    var dbPath = await getDatabasesPath();
    String dbPathHomeWorkout = path.join(dbPath, _dbName);

    bool dbExists = await io.File(dbPathHomeWorkout).exists();

    if (!dbExists) {
      ByteData data = await rootBundle.load(path.join("assets/", _dbName));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await io.File(dbPathHomeWorkout).writeAsBytes(bytes, flush: true);
    }
    return await openDatabase(
      dbPathHomeWorkout,
      version: _dbVersion,
      onUpgrade: _onUpgrade,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    print('oncreate is called $version');
    await _createTables(db);
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('onUpgrade is called from $oldVersion to $newVersion');
    if (oldVersion < newVersion) {
      if (oldVersion == 47 && newVersion == 48) {
        print("upgrade");
        await _createTables(db);
      }
      // Add more migration steps if needed for future versions
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $schoolEnrolment(
         id INTEGER PRIMARY KEY AUTOINCREMENT,
        tourId TEXT,
        school TEXT,
        registerImage TEXT,
        enrolmentData TEXT,
        remarks TEXT,
        createdAt TEXT,
        submittedBy TEXT,
        submittedAt TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tourDetails (
        id TEXT PRIMARY KEY,
        tourName TEXT,
        description TEXT,
        date TEXT
      );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $cabMeter_tracing(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tour_id TEXT,
    place_visit TEXT,
    vehicle_num TEXT,
    driver_name TEXT,
    meter_reading TEXT,
    image TEXT,
    status TEXT,
    remarks TEXT,
    user_id TEXT,
    created_at TEXT,
    office TEXT,
    uniqueId TEXT,
    version TEXT
    );
''');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS $inPerson_quantitative (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
tourId TEXT,
school TEXT,
udicevalue TEXT,
correct_udice TEXT,
imgpath TEXT,
no_enrolled TEXT,
timetable_available TEXT,
class_scheduled TEXT,

remarks_scheduling TEXT,
admin_appointed TEXT,
admin_trained TEXT,
admin_name TEXT,
admin_phone TEXT,
sub_teacher_trained TEXT,
teacher_ids TEXT,

no_staff TEXT,
training_pic TEXT,
specifyOtherTopics TEXT,
practical_demo TEXT,
reason_demo TEXT,
comments_capacity TEXT,
children_comfortable TEXT,
children_understand TEXT,
post_test TEXT,
resolved_doubts TEXT,
logs_filled TEXT,
filled_correctly TEXT,
send_report TEXT,
app_installed TEXT,
data_synced TEXT,
last_syncedDate TEXT,
lib_timetable TEXT,
timetable_followed TEXT,
registered_updated TEXT,
observation_comment TEXT,
topicsCoveredInTraining TEXT,
participant_name TEXT,
major_issue TEXT,
created_at TEXT,
submitted_by TEXT,
unique_id TEXT

   
    
    
);


''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $schoolFacilities(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
  tourId TEXT,
school TEXT,
udiseCode TEXT,
correctUdise TEXT,

residentialValue TEXT,
electricityValue TEXT,
internetValue TEXT,
projectorValue TEXT,
smartClassValue TEXT,
numFunctionalClass TEXT,
playgroundValue TEXT,
playImg TEXT,
libValue TEXT,
libLocation TEXT,
librarianName TEXT,
librarianTraining TEXT,
libRegisterValue TEXT,
imgRegister TEXT,
created_by TEXT,
created_at TEXT


    );
''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $schoolStaffVec(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
 tourId TEXT,
school TEXT,
udiseValue TEXT,
correctUdise TEXT,
headName TEXT,
headGender TEXT,
headMobile TEXT,
headEmail TEXT,
headDesignation TEXT,
totalTeachingStaff TEXT,
totalNonTeachingStaff TEXT,
totalStaff TEXT,
SmcVecName TEXT,
genderVec TEXT,
vecMobile TEXT,
vecEmail TEXT,
vecQualification TEXT,
vecTotal TEXT,
meetingDuration TEXT,
createdBy TEXT,
createdAt TEXT,
other TEXT,
otherQual TEXT
    );
''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $issueTracker(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tourId TEXT,
    school TEXT,
    udiseCode TEXT,
    correctUdise TEXT,
    submittedBy TEXT,
    uid TEXT,
    created_at TEXT,
    office TEXT,
    uniqueId TEXT,
    version TEXT
    );
''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $libIssueTable(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
      lib_issue TEXT,
      lib_issue_value TEXT,
      lib_desc TEXT,
      reported_on TEXT,
      resolved_on TEXT,
      reported_by TEXT,
      resolved_by TEXT,
      issue_status TEXT,
      lib_issue_img TEXT,
      unique_id TEXT
    );
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $alfaObservation(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tourId TEXT,
      school TEXT,
      udiseValue TEXT,
      correctUdise TEXT,
      noStaffTrained TEXT,
      imgNurTimeTable TEXT,
      imgLKGTimeTable TEXT,
      imgUKGTimeTable TEXT,
      bookletValue TEXT,
      moduleValue TEXT,
      numeracyBooklet TEXT,
      numeracyValue TEXT,
      pairValue TEXT,
      alfaActivityValue TEXT,
      alfaGradeReport TEXT,
      imgAlfa TEXT,
      refresherTrainingValue TEXT,
      noTrainedTeacher TEXT,
      imgTraining TEXT,
      readingValue TEXT,
      libGradeReport TEXT,
      imgLibrary TEXT,
      tlmKitValue TEXT,
      imgTlm TEXT,
      classObservation TEXT,
      createdAt TEXT,
      submittedAt TEXT,
      createdBy TEXT
    );
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $flnObservation(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
      tourId TEXT,
      school TEXT,
      udiseValue TEXT,
      correctUdise TEXT,
      noStaffTrained TEXT,
      imgNurTimeTable TEXT,
      imgLKGTimeTable TEXT,
      imgUKGTimeTable TEXT,
      lessonPlanValue TEXT,
      activityValue TEXT,
      imgActivity TEXT,
      imgTLM TEXT,
      baselineValue TEXT,
      baselineGradeReport TEXT,
      flnConductValue TEXT,
      flnGradeReport TEXT,
      imgFLN TEXT,
      refresherValue TEXT,
      numTrainedTeacher TEXT,
      imgTraining TEXT,
      readingValue TEXT,
      libGradeReport TEXT,
      imgLib TEXT,
      methodologyValue TEXT,
      imgClass TEXT,
      observation TEXT,
      created_by TEXT,
      createdAt TEXT,
      submittedAt TEXT
    );
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $inPerson_qualitative(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tourId TEXT,
      school TEXT,
      udicevalue TEXT,
      correct_udice TEXT,
      imgPath TEXT,
      school_digiLab TEXT,
      school_library TEXT,
      school_playground TEXT,
      hm_interview TEXT,
      hm_reason TEXT,
      hmques1 TEXT,
      hmques2 TEXT,
      hmques3 TEXT,
      hmques4 TEXT,
      hmques5 TEXT,
      hmques6 TEXT,
      hmques6_1 TEXT,
      hmques7 TEXT,
      hmques8 TEXT,
      hmques9 TEXT,
      hmques10 TEXT,
      steacher_interview TEXT,
      steacher_reason TEXT,
      stques1 TEXT,
      stques2 TEXT,
      stques3 TEXT,
      stques4 TEXT,
      stques5 TEXT,
      stques6 TEXT,
      stques6_1 TEXT,
      stques7 TEXT,
      stques7_1 TEXT,
      stques8 TEXT,
      stques8_1 TEXT,
      stques9 TEXT,
      student_interview TEXT,
      student_reason TEXT,
      stuques1 TEXT,
      stuques2 TEXT,
      stuques3 TEXT,
      stuques4 TEXT,
      stuques5 TEXT,
      stuques6 TEXT,
      stuques7 TEXT,
      stuques8 TEXT,
      stuques9 TEXT,
      stuques10 TEXT,
      stuques11 TEXT,
      stuques11_1 TEXT,
      stuques11_2 TEXT,
      stuques11_3 TEXT,
      stuques12 TEXT,
      smc_interview TEXT,
      smc_reason TEXT,
      smcques1 TEXT,
      smcques2 TEXT,
      smcques3 TEXT,
      smcques3_1 TEXT,
      smcques3_2 TEXT,
      smcques_4 TEXT,
      smcques4_1 TEXT,
      smcques_5 TEXT,
      smcques_6 TEXT,
      smcques_7 TEXT,
      created_at TEXT,
      submitted_at TEXT,
      submitted_by TEXT,
      unique_id TEXT
     
    );
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS $schoolRecce(
     id INTEGER PRIMARY KEY AUTOINCREMENT,
  tourId TEXT,
  school TEXT,
  udiseValue TEXT,
  udise_correct TEXT,
  boardImg TEXT,
  buildingImg TEXT,
  gradeTaught TEXT,
  instituteHead TEXT,
  headDesignation TEXT,
  headPhone TEXT,
  headEmail TEXT,
  appointedYear TEXT,
  noTeachingStaff TEXT,
  noNonTeachingStaff TEXT,
  totalStaff TEXT,
  registerImg TEXT,
  smcHeadName TEXT,
  smcPhone TEXT,
  smcQual TEXT,
  qualOther TEXT,
  totalSmc TEXT,
  meetingDuration TEXT,
  meetingOther TEXT,
  smcDesc TEXT,
  noUsableClass TEXT,
  electricityAvailability TEXT,
  networkAvailability TEXT,
  digitalLearning TEXT,
  smartClassImg TEXT,
  projectorImg TEXT,
  computerImg TEXT,
  libraryExisting TEXT,
  libImg TEXT,
  playGroundSpace TEXT,
  spaceImg TEXT,
  enrollmentReport TEXT,
  enrollmentImg TEXT,
  academicYear TEXT,
  gradeReportYear1 TEXT,
  gradeReportYear2 TEXT,
  gradeReportYear3 TEXT,
  DigiLabRoomImg TEXT,
  libRoomImg TEXT,
  remoteInfo TEXT,
  motorableRoad TEXT,
  languageSchool TEXT,
  languageOther TEXT,
  supportingNgo TEXT,
  otherNgo TEXT,
  observationPoint TEXT,
  submittedBy TEXT,
  createdAt TEXT
     
    );
  ''');
  }

  // Function to reset the database
  Future<void> resetDatabase() async {
    var dbPath = await getDatabasesPath();
    String dbPathHomeWorkout = path.join(dbPath, _dbName);
    await deleteDatabase(dbPathHomeWorkout);
    _db = await init();
  }

  // Delete function for deleting records from table
  Future<int> delete(String? tableName,
      {String? where, List<dynamic>? whereArgs}) async {
    final dbClient = await db;
    if (tableName == null) {
      throw ArgumentError("tableName cannot be null");
    }

    print('delete is called $tableName');

    String sql = "DELETE FROM $tableName";
    if (where != null) {
      sql += " WHERE $where";
    }

    try {
      return await dbClient.rawDelete(sql, whereArgs);
    } catch (e) {
      print('Error executing delete: $e');
      rethrow;
    }
  }

  // Delete function for deleting specific records from table
  Future<int> queryDelete({String? arg, String? table, String? field}) async {
    final dbClient = await db;
    if (table == null || field == null || arg == null) {
      throw ArgumentError("Arguments cannot be null");
    }

    print('query delete is called');

    try {
      return await dbClient
          .rawDelete('DELETE FROM $table WHERE $field = ?', [arg]);
    } catch (e) {
      print('Error executing query delete: $e');
      rethrow;
    }
  }
}

class LocalDbController {
  final conn = SqfliteDatabaseHelper.instance;

  // Check internet connectivity
  static Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return networkManager.connectionType.value == 1;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return networkManager.connectionType.value == 2;
    } else {
      return false;
    }
  }

  Future<int> addData({
    TourDetails? tourDetails,
    EnrolmentCollectionModel? enrolmentCollectionModel,
    CabMeterTracingRecords? cabMeterTracingRecords,
    InPersonQuantitativeRecords? inPersonQuantitativeRecords,
    SchoolFacilitiesRecords? schoolFacilitiesRecords,
    SchoolStaffVecRecords? schoolStaffVecRecords,
    IssueTrackerRecords? issueTrackerRecords,
    List<LibIssue>? libIssues, // Accept a list of LibIssue objects
    AlfaObservationModel? alfaObservationModel,
    FlnObservationModel? flnObservationModel,
    InPersonQualitativeRecords? inPersonQualitativeRecords,
    SchoolRecceModal? schoolRecceModal,
  }) async {
    var dbClient = await conn.db;
    int result = 1;

    try {
      // Insert TourDetails
      if (tourDetails != null) {
        print('tourDetails called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.tourDetails,
          tourDetails.toJson(),
        );
      }

      // Insert EnrolmentCollectionModel
      if (enrolmentCollectionModel != null) {
        print('enrolmentCollectionModel called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.schoolEnrolment,
          enrolmentCollectionModel.toJson(),
        );
      }

      // Insert CabMeterTracingRecords
      if (cabMeterTracingRecords != null) {
        print('cabMeterTracingRecords called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.cabMeter_tracing,
          cabMeterTracingRecords.toJson(),
        );
      }

      // Insert InPersonQuantitativeRecords
      if (inPersonQuantitativeRecords != null) {
        print('inPersonQuantitativeRecords called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.inPerson_quantitative,
          inPersonQuantitativeRecords.toJson(),
        );
      }

      // Insert SchoolFacilitiesRecords
      if (schoolFacilitiesRecords != null) {
        print('schoolFacilitiesRecords called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.schoolFacilities,
          schoolFacilitiesRecords.toJson(),
        );
      }

      // Insert SchoolStaffVecRecords
      if (schoolStaffVecRecords != null) {
        print('schoolStaffVecRecords called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.schoolStaffVec,
          schoolStaffVecRecords.toJson(),
        );
      }

      // Insert IssueTrackerRecords
      if (issueTrackerRecords != null) {
        print('issueTrackerRecords called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.issueTracker,
          issueTrackerRecords.toJson(),
        );
      }

      // Insert multiple LibIssue records
      if (libIssues != null && libIssues.isNotEmpty) {
        for (var issue in libIssues) {
          print('libIssue called to insert');
          await dbClient.insert(
            SqfliteDatabaseHelper
                .libIssueTable, // Adjust this table name accordingly
            issue.toJson(),
          );
        }
      }

      if (alfaObservationModel != null) {
        print('alfaObservationModel called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.alfaObservation,
          alfaObservationModel.toJson(),
        );
      }

      if (flnObservationModel != null) {
        print('flnObservationModel called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.flnObservation,
          flnObservationModel.toJson(),
        );
      }

      if (inPersonQualitativeRecords != null) {
        print('flnObservationModel called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.inPerson_qualitative,
          inPersonQualitativeRecords.toJson(),
        );
      }

      if (schoolRecceModal != null) {
        print('flnObservationModel called to insert');
        result = await dbClient.insert(
          SqfliteDatabaseHelper.schoolRecce,
          schoolRecceModal.toJson(),
        );
      }

      print('Insert successful: $result');
    } catch (e) {
      print('Error inserting record: $e');
      result = -1; // Return -1 on error
    }

    return result;
  }

  // Fetch CDPO form records from local db
  Future<List<TourDetails>> fetchLocalTourDetails() async {
    var dbClient = await conn.db;
    List<TourDetails> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.tourDetails}');
      for (var element in maps) {
        tourList.add(TourDetails.fromJson(element));
      }
    } catch (e) {
      print("Exception occurred while fetching tourDetails form records: $e");
    }
    return tourList;
  }

  //fetch Local Enrolment DATa

  // Fetch CDPO form records from local db
  Future<List<EnrolmentCollectionModel>> fetchLocalEnrolmentRecord() async {
    var dbClient = await conn.db;
    List<EnrolmentCollectionModel> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.schoolEnrolment}');
      for (var element in maps) {
        tourList.add(EnrolmentCollectionModel.fromJson(element));
      }
    } catch (e) {
      print(
          "Exception occurred while fetching enrolmentCollection form records: $e");
    }
    return tourList;
  }

  Future<List<CabMeterTracingRecords>> fetchLocalCabMeterTracingRecord() async {
    var dbClient = await conn.db;
    List<CabMeterTracingRecords> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.cabMeter_tracing}');
      for (var element in maps) {
        tourList.add(CabMeterTracingRecords.fromJson(element));
      }
      print('localcab meter reoord length us ${tourList.length}');
    } catch (e) {
      print(
          "Exception occurred while fetching CabMeterTracingRecords form records: $e");
    }
    return tourList;
  }

  Future<List<InPersonQuantitativeRecords>>
      fetchLocalInPersonQuantitativeRecords() async {
    var dbClient = await conn.db;
    List<InPersonQuantitativeRecords> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'SELECT * FROM ${SqfliteDatabaseHelper.inPerson_quantitative}');
      for (var element in maps) {
        tourList.add(InPersonQuantitativeRecords.fromJson(element));
      }
      print('localcab meter reoord length us ${tourList.length}');
    } catch (e) {
      print(
          "Exception occurred while fetching InPersonQuantitativeRecords form records: $e");
    }
    return tourList;
  }

  Future<List<SchoolFacilitiesRecords>>
      fetchLocalSchoolFacilitiesRecords() async {
    var dbClient = await conn.db;
    List<SchoolFacilitiesRecords> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.schoolFacilities}');
      for (var element in maps) {
        tourList.add(SchoolFacilitiesRecords.fromJson(element));
      }
      print('localcab meter reoord length us ${tourList.length}');
    } catch (e) {
      print(
          "Exception occurred while fetching SchoolFacilitiesRecords form records: $e");
    }
    return tourList;
  }

  Future<List<SchoolStaffVecRecords>> fetchLocalSchoolStaffVecRecords() async {
    var dbClient = await conn.db;
    List<SchoolStaffVecRecords> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.schoolStaffVec}');
      for (var element in maps) {
        tourList.add(SchoolStaffVecRecords.fromJson(element));
      }
      print('localcab meter reoord length us ${tourList.length}');
    } catch (e) {
      print(
          "Exception occurred while fetching SchoolStaffVecRecords form records: $e");
    }
    return tourList;
  }

  Future<List<IssueTrackerRecords>> fetchLocalIssueTrackerRecords() async {
    var dbClient = await conn.db;
    List<IssueTrackerRecords> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.issueTracker}');
      for (var element in maps) {
        tourList.add(IssueTrackerRecords.fromJson(element));
      }
      print('localcab meter reoord length us ${tourList.length}');
    } catch (e) {
      print(
          "Exception occurred while fetching IssueTrackerRecords form records: $e");
    }
    return tourList;
  }

  Future<List<LibIssue>> fetchLocalLibIssueRecords() async {
    var dbClient = await conn.db;
    List<LibIssue> libIssueList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.libIssueTable}');
      for (var element in maps) {
        libIssueList.add(LibIssue.fromJson(element));
      }
    } catch (e) {
      print("Exception occurred while fetching LibIssue records: $e");
    }
    return libIssueList;
  }

  Future<List<AlfaObservationModel>> fetchLocalAlfaObservationModel() async {
    var dbClient = await conn.db;
    List<AlfaObservationModel> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.alfaObservation}');
      for (var element in maps) {
        tourList.add(AlfaObservationModel.fromJson(element));
      }
      print('localcab meter reoord length us ${tourList.length}');
    } catch (e) {
      print(
          "Exception occurred while fetching AlfaObservationModel form records: $e");
    }
    return tourList;
  }

  Future<List<FlnObservationModel>> fetchLocalFlnObservationModel() async {
    var dbClient = await conn.db;
    List<FlnObservationModel> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.flnObservation}');
      for (var element in maps) {
        tourList.add(FlnObservationModel.fromJson(element));
      }
      print('localcab meter reoord length us ${tourList.length}');
    } catch (e) {
      print(
          "Exception occurred while fetching FlnObservationModel form records: $e");
    }
    return tourList;
  }

  Future<List<InPersonQualitativeRecords>>
      fetchLocalInPersonQualitativeRecords() async {
    var dbClient = await conn.db;
    List<InPersonQualitativeRecords> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient.rawQuery(
          'SELECT * FROM ${SqfliteDatabaseHelper.inPerson_qualitative}');
      for (var element in maps) {
        tourList.add(InPersonQualitativeRecords.fromJson(element));
      }
      print('localcab meter reoord length us ${tourList.length}');
    } catch (e) {
      print(
          "Exception occurred while fetching InPersonQualitativeRecords form records: $e");
    }
    return tourList;
  }

  Future<List<SchoolRecceModal>> fetchLocalSchoolRecceModal() async {
    var dbClient = await conn.db;
    List<SchoolRecceModal> tourList = [];
    try {
      List<Map<String, dynamic>> maps = await dbClient
          .rawQuery('SELECT * FROM ${SqfliteDatabaseHelper.schoolRecce}');
      for (var element in maps) {
        tourList.add(SchoolRecceModal.fromJson(element));
      }
      print('localcab meter reoord length us ${tourList.length}');
    } catch (e) {
      print(
          "Exception occurred while fetching SchoolRecceModal form records: $e");
    }
    return tourList;
  }
}
