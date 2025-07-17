class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final String? exceptionMessage;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.exceptionMessage,
    this.statusCode,
  });

  factory ApiResponse.success({
    String? message,
    dynamic data,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    String? message,
    String? exceptionMessage,
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      exceptionMessage: exceptionMessage,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, data: $data, exceptionMessage: $exceptionMessage, statusCode: $statusCode)';
  }
} 