part of 'hexa_api.dart';

mixin HexaApiAuthMethods on HexaApiBase {

  Future<({String access, String refresh})> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/auth/login',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );
    return _tokenPairFromResponse(res);
  }


  Future<({String access, String refresh})> register({
    required String username,
    required String email,
    required String password,
    String? name,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/auth/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      },
    );
    return _tokenPairFromResponse(res);
  }


  Future<({String access, String refresh})> loginWithGoogle(
      {required String idToken}) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v1/auth/google',
      data: {'id_token': idToken},
    );
    return _tokenPairFromResponse(res);
  }

  /// Request a password reset (no auth). In development the response may include `dev_reset_token`.

  /// Request a password reset (no auth). In development the response may include `dev_reset_token`.
  Future<Map<String, dynamic>> requestPasswordReset(
      {required String email}) async {
    final res = await _plain.post<Map<String, dynamic>>(
      '/v1/auth/forgot-password',
      data: {'email': email.trim().toLowerCase()},
    );
    return res.data ?? <String, dynamic>{};
  }

  /// Apply new password using the token from the reset link (no auth).

  /// Apply new password using the token from the reset link (no auth).
  Future<Map<String, dynamic>> resetPasswordWithToken({
    required String token,
    required String newPassword,
  }) async {
    final res = await _plain.post<Map<String, dynamic>>(
      '/v1/auth/reset-password',
      data: {
        'token': token,
        'new_password': newPassword,
      },
    );
    return res.data ?? <String, dynamic>{};
  }

  /// No Bearer header — uses body only. Kept on [_plain] so it never inherits [setAuthToken].

  /// No Bearer header — uses body only. Kept on [_plain] so it never inherits [setAuthToken].
  Future<({String access, String refresh})> refreshTokens(
      {required String refreshToken}) async {
    final res = await _plain.post<Map<String, dynamic>>(
      '/v1/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return _tokenPairFromResponse(res);
  }


  Future<List<BusinessBrief>> meBusinesses() async {
    final res = await _dio.get<dynamic>('/v1/me/businesses');
    final data = res.data;
    if (data is! List) return [];
    return data
        .map((e) => BusinessBrief.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }


  Future<Map<String, dynamic>> meProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('/v1/me/profile');
    return Map<String, dynamic>.from(res.data ?? const {});
  }

}
