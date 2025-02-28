import '../models/service.dart';

class Promotion {
  final int id;
  final bool actif;
  final String typeReduction;
  final double valeurReduction;
  final String dateDebut;
  final String dateFin;
  final List<Service> services;
  final String codePromo;

  Promotion({
    required this.id,
    required this.actif,
    required this.typeReduction,
    required this.valeurReduction,
    required this.dateDebut,
    required this.dateFin,
    required this.services,
    required this.codePromo,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    try {
      // Vérifier si "services" est une liste
      var servicesList = json['services'] as List<dynamic>? ?? [];
      List<Service> services =
          servicesList.map((service) => Service.fromJson(service)).toList();

      return Promotion(
        id: json['idPromotion'] ?? 0,
        actif: json['actif'] ?? false,
        typeReduction: json['typeReduction'] ?? 'Inconnu',
        valeurReduction: (json['valeurReduction'] ?? 0.0).toDouble(),
        dateDebut: json['dateDebut'] ?? '',
        dateFin: json['dateFin'] ?? '',
        services: services,
        codePromo: json['codePromo'] ?? '',
      );
    } catch (e) {
      throw Exception("Erreur lors de la conversion JSON -> Promotion : $e");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'idPromotion': id,
      'actif': actif,
      'typeReduction': typeReduction,
      'valeurReduction': valeurReduction,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'services': services.map((service) => service.toJson()).toList(),
      'codePromo': codePromo,
    };
  }
}
