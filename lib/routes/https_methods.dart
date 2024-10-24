import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:nearby_buddy_app/routes/service_exception.dart';

import 'dart:async';

import '../helper/utils.dart';



class Http {
  Future<dynamic> post(String url, dynamic jsonObj) async {
    Log.log('Api Post, url $url for $jsonObj');
    var responseJson;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {},
        body: jsonObj,
      );
      responseJson = _returnResponse(response);
    } catch(Exception) {
      Log.log('ExceptionThrownApi: $Exception');
    }
    return responseJson;
  }
  Future<dynamic> get(String url) async {
    Log.log('Api Get, url $url');
    int timeout = 5;
    var responseJson;
    try {
      final response = await http.post(
        Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
 

      }
      ).
      timeout(Duration(seconds: timeout));
      responseJson = _returnResponse(response);
    }  on TimeoutException {
      return false;
    } on SocketException {
      return false;
    } on Error {
      return false;
    }
    return responseJson;
  }
}

dynamic _returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      var responseJson = json.decode(response.body);
      log('response $responseJson');
      return responseJson;
    case 400:
      throw BadRequestException(response.body.toString());
    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 500:
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
  }
}
