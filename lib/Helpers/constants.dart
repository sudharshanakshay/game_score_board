// ignore_for_file: constant_identifier_names

class Constants {
  // Server key, code & values.

  //Server keys
  static const String SUCCESSKEY = "success";
  static const String DATAKEY = "data";
  static const String SESSIONIDKEY = "sessionId";
  static const String errorKey = "error";
  static const String SCOREBOARDKEY = "scoreBoard";
  static const String MESSAGEKEY = 'message';
  static const String codeKey = 'code';
  static const String playerKey = "player";

  // Server codes
  static const String codeValueInvalidSession = "INVALID_SESSION";
  static const String codeValueSessionNotFound = "SESSION_NOT_FOUND";
  static const String codeValueUnauthorised = "UNAUTHORIZED";
  static const String codeValueRateLimit = "RATE_LIMITED";

  // Internal key, code & values.

  // Internal key
  static const String internalColorIndexKey = 'colorIndex';
  static const String internalShowPreviousScoreKey = 'show';

  // Internal code
  static const String internalErrorSessionNull = "SESSION_NULL";

  // Internal message values
  static const String errorInternalText = "Internal error";
  static const String errorInvalidSessionText = "Error, Invalid Session";
}
