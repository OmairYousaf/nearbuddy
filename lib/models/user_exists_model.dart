import '../routes/api_service.dart';

class UserExistenceResult {
  final LoginType loginMethod;
  final bool userExists;

  UserExistenceResult(this.loginMethod, this.userExists);
}