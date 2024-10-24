class ServiceException implements Exception {
  final _message;
  final _prefix;

  ServiceException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends ServiceException {
  FetchDataException(String message)
      : super(message, "Error During Communication: ");
}

class BadRequestException extends ServiceException {
  BadRequestException(message) : super(message, "Invalid Request: ");

}

class UnauthorisedException extends ServiceException {
  UnauthorisedException(message) : super(message, "Unauthorised: ");
}

class InvalidInputException extends ServiceException {
  InvalidInputException(String message) : super(message, "Invalid Input: ");
}


