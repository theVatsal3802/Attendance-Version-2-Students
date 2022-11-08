import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import './constants.dart';

class MongoDB {
  static dynamic db, collection, tempCollection, studentCollection;

  static Future<String> connect() async {
    try {
      db = await Db.create(MONGO_CONN_URL);
      await db.open();
      collection = db.collection(COLLECTIONS);
      tempCollection = db.collection(TEMP_COLLECTIONS);
      studentCollection = db.collection(STUDENTS);
      return "Success";
    } on SocketException catch (error) {
      await MongoDB.connect();
      return error.toString();
    }
  }

  static Future<String> insertUser(Map<String, dynamic> data) async {
    try {
      final result = await studentCollection.insertOne(data);
      if (result.isSuccess) {
        return "Success";
      }
      return "Failed";
    } catch (error) {
      return error.toString();
    }
  }

  static Future<Map<String, dynamic>?> teacherData(int code) async {
    try {
      Map<String, dynamic> data = await tempCollection.findOne(
        where.eq(
          "code",
          code,
        ),
      );
      return data;
    } catch (e) {
      return null;
    }
  }

  static Future<void> markAttendance(
      String batch, String subject, String rollno) async {
    await collection.updateOne(
      where
          .eq(
            "batch",
            batch,
          )
          .eq(
            "month",
            DateTime.now().month.toString(),
          )
          .eq(
            "day",
            DateTime.now().day.toString(),
          ),
      modify.push(
        "attendance",
        rollno,
      ),
    );
  }
}
