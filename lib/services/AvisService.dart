import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Avis.dart';

class AvisService {
  final String apiUrl = "http:///192.168.1.14:8080/api/avis";

  // Méthode pour récupérer les avis d'un service
  Future<List<Avis>> fetchAvis(int idService) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("Token JWT introuvable. Veuillez vous reconnecter.");
      }

      final response = await http.get(
        Uri.parse('$apiUrl/service/$idService'),
        headers: {
          "Authorization": "Bearer $token", // Ajout du JWT
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Avis.fromJson(e)).toList();
      } else {
        throw Exception(
            "Échec du chargement des avis : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur lors du chargement des avis : $e");
    }
  }

  // Méthode pour récupérer l'email de l'utilisateur à partir du token JWT
  Future<String> getEmailFromToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("Token JWT introuvable.");
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.14:8085/api/avis/email'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return response.body; // Email renvoyé depuis le backend
      } else {
        throw Exception(
            "Échec de la récupération de l'email : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur lors de la récupération de l'email : $e");
    }
  }

  // Méthode pour récupérer le titre du service par ID
  Future<String> getTitreService(int serviceId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("Token JWT introuvable.");
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.14:8085/api/avis/service/$serviceId/titre'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return response.body; // Titre du service renvoyé depuis le backend
      } else {
        throw Exception(
            "Échec de la récupération du titre du service : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(
          "Erreur lors de la récupération du titre du service : $e");
    }
  }

  Future<int> getAvisCount(int idService) async {
    try {
      // Récupérer la liste des avis pour le service donné
      List<Avis> avisList = await fetchAvis(idService);

      // Retourner le nombre d'avis
      return avisList.length; // Compte le nombre d'éléments dans la liste
    } catch (e) {
      throw Exception("Erreur lors du comptage des avis : $e");
    }
  }

  Future<bool> ajouterAvis(Avis avis, String token) async {
    final response = await http.post(
      Uri.parse('$apiUrl/ajouter'), // Remplacez par votre endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'service': {
          'id': avis.serviceId,
        },
        'commentaire': avis.commentaire,
        'etoile': avis.etoile,
        'email': avis.email,
        'titreService': avis.titreService,
      }),
    );

    if (response.statusCode == 200) {
      // Si la requête est réussie, renvoyer true
      return true;
    } else {
      // Si la requête échoue, renvoyer false
      return false;
    }
  }

  Future<List<Avis>> getAllAvis() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("Token JWT introuvable. Veuillez vous reconnecter.");
      }

      final response = await http.get(
        Uri.parse('$apiUrl/all'),
        headers: {
          "Authorization": "Bearer $token", // Ajout du JWT
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Avis.fromJson(e)).toList();
      } else {
        throw Exception(
            "Échec du chargement des avis : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur lors du chargement des avis : $e");
    }
  }

  Future<List<double>> calculerPourcentagesAvis(int idService) async {
    try {
      // Récupérer les avis pour ce service
      List<Avis> avisList = await fetchAvis(idService);

      // Variables pour compter les avis positifs, neutres, et négatifs
      int countPositifs = 0;
      int countNeutres = 0;
      int countNegatifs = 0;

      // Calculer les avis positifs, neutres, négatifs en fonction des étoiles
      for (Avis avis in avisList) {
        if (avis.etoile >= 4.0) {
          countPositifs++;
        } else if (avis.etoile == 3.0) {
          countNeutres++;
        } else if (avis.etoile < 3.0) {
          countNegatifs++;
        }
      }

      // Calculer les pourcentages
      double totalAvis = avisList.length.toDouble();
      double pourcentagePositifs = (countPositifs / totalAvis) * 100;
      double pourcentageNeutres = (countNeutres / totalAvis) * 100;
      double pourcentageNegatifs = (countNegatifs / totalAvis) * 100;

      // Retourner les résultats sous forme de liste
      return [pourcentagePositifs, pourcentageNeutres, pourcentageNegatifs];
    } catch (e) {
      throw Exception("Erreur lors du calcul des pourcentages d'avis : $e");
    }
  }
}
