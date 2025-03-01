import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/signin_request.dart';
import '../models/signup_request.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.14:8085/api/v1/auth';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('jwt_token', token);
  }

  // Inscription
  Future<bool> signUp(SignUpRequest signUpRequest) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(signUpRequest.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Connexion
  Future<String?> signIn(SigninRequest signinRequest) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(signinRequest.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final token = responseData['token'];

      // Stocker le token dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      return token;
    } else {
      return null;
    }
  }

  Future<String> checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      // Vérification pour l'admin
      final adminResponse = await http.get(
        Uri.parse('$baseUrl/admin'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (adminResponse.statusCode == 200) {
        return 'ADMIN';
      }

      // Vérification pour le technicien
      final technicianResponse = await http.get(
        Uri.parse('$baseUrl/Technicien'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (technicianResponse.statusCode == 200) {
        return 'TECHNICIEN';
      }

      // Vérification pour l'utilisateur
      final userResponse = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (userResponse.statusCode == 200) {
        return 'USER';
      }
    }

    return 'UNKNOWN';
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    // Supprimer le JWT token
    await prefs.remove('jwt_token');
  }

// Vérifier si l'email existe déjà
  Future<bool> checkEmail(String email) async {
    final response = await http.get(
      Uri.parse('$baseUrl/check-email?email=$email'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // L'email n'existe pas
      return false;
    } else if (response.statusCode == 400) {
      // L'email existe déjà
      return true;
    } else {
      // Erreur dans la requête
      throw Exception('Failed to check email');
    }
  }

  Future<int> getUtilisateurCount() async {
    try {
      List<Map<String, dynamic>>? users =
          await getUsersWithUserRole(); // Récupérer les utilisateurs avec le rôle "USER"
      return users?.length ??
          0; // Retourner le nombre d'utilisateurs ou 0 si la liste est vide
    } catch (e) {
      print("Erreur lors de la récupération du nombre d'utilisateurs: $e");
      return 0; // Retourner 0 en cas d'erreur
    }
  }

  Future<bool> checkPhone(String phone) async {
    final response = await http.get(
      Uri.parse('$baseUrl/check-phone?phone=$phone'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Le numéro de téléphone n'existe pas
      return false;
    } else if (response.statusCode == 400) {
      // Le numéro de téléphone existe déjà
      return true;
    } else {
      // Erreur dans la requête
      throw Exception('Échec de la vérification du numéro de téléphone');
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    return response.statusCode == 200;
  }

  Future<bool> verifyResetCode(String email, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'token': token}),
    );

    return response.statusCode == 200;
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        return true; // Succès de la réinitialisation
      } else {
        // Retourner l'erreur retournée par le backend
        throw Exception('Erreur de réinitialisation : ${response.body}');
      }
    } catch (e) {
      // Gérer les erreurs réseau ou autres erreurs
      print('Exception lors de la réinitialisation : $e');
      return false;
    }
  }

  Future<bool> resendVerificationCode(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resend-verification-code'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    return response.statusCode == 200;
  }

  // Vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('jwt_token');
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      return null; // Aucun token stocké, donc pas d'utilisateur connecté
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.14:8085/api/v1/auth/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<bool> updateProfile(String username, String email, String phone,
      String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      return false; // Aucun token disponible
    }

    // Construire le corps de la requête dynamiquement
    Map<String, dynamic> body = {
      'username': username,
      'email': email,
      'phone': phone,
    };

    // Ajouter les mots de passe seulement s'ils sont remplis
    if (oldPassword.isNotEmpty && newPassword.isNotEmpty) {
      body['oldPassword'] = oldPassword;
      body['newPassword'] = newPassword;
    }

    final response = await http.put(
      Uri.parse('http://192.168.1.14:8085/api/v1/auth/user/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    return response.statusCode == 200;
  }

  // Nouvelle fonction pour récupérer les utilisateurs avec le rôle USER
  Future<List<Map<String, dynamic>>?> getUsersWithUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      return null; // Aucun token stocké, donc pas d'utilisateur connecté
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.14:8085/api/v1/auth/admin/users-role-user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Retourner la liste des utilisateurs au format JSON
      final List<dynamic> responseData = json.decode(response.body);
      return List<Map<String, dynamic>>.from(responseData);
    } else {
      return null;
    }
  }
}
