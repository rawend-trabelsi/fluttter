import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater les dates
import '../models/promotion.dart';
import '../services/PromotionService.dart';
import '../services/auth_service.dart';
import 'PromotionAddScreen.dart';
import 'PromotionUpdateScreen.dart';
import 'admin_screen.dart';

class PromotionListScreen extends StatefulWidget {
  @override
  _PromotionListScreenState createState() => _PromotionListScreenState();
}

class _PromotionListScreenState extends State<PromotionListScreen> {
  late Future<List<Promotion>> _promotions;
  final PromotionService _promotionService = PromotionService();

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  void _fetchPromotions() {
    setState(() {
      _promotions = _promotionService.fetchPromotions();
    });
  }

  Future<void> _deletePromotion(int promotionId) async {
    try {
      await _promotionService.deletePromotion(promotionId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Promotion supprimée avec succès')),
      );
      _fetchPromotions(); // Rafraîchir la liste après suppression
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  // Fonction pour formater les dates
  String formatDateTime(String isoDate) {
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      print("Erreur lors du formatage de la date : $e");
      return isoDate; // Retourne la date non formatée en cas d'erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des promotions'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) =>
              IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () =>
                    Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: Sidebar(authService: AuthService(), onSelectPage: (index) {}),
      body: FutureBuilder<List<Promotion>>(
        future: _promotions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Promotion> promotions = snapshot.data!;

            return ListView.builder(
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                Promotion promotion = promotions[index];
                bool hasServices = promotion.services.isNotEmpty &&
                    promotion.services.any((service) =>
                    service != null && service.titre.isNotEmpty);

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xFF00BCD0), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4, // Légère ombre pour l'effet de profondeur
                    child: ListTile(
                      title: Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            promotion.typeReduction,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.money, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                promotion.valeurReduction == promotion.valeurReduction.toInt()
                                    ? 'Valeur de Réduction: ${promotion.valeurReduction.toInt()}'
                                    : 'Valeur de Réduction: ${promotion.valeurReduction.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.date_range, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Date Début: ${formatDateTime(promotion.dateDebut)}'),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.date_range, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Date Fin: ${formatDateTime(promotion.dateFin)}'),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.code, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                promotion.codePromo.isNotEmpty
                                    ? 'Code Promo: ${promotion.codePromo}'
                                    : 'Aucun code promo',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          // Ajouter un design pour les services associés
                          if (hasServices)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.build, color: Colors.blueAccent),
                                      SizedBox(width: 8),
                                      Text(
                                        'Services associés:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  ...promotion.services.map((service) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Color(0xFF00BCD0)),
                                          SizedBox(width: 8),
                                          Text(
                                            service.titre,
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          // Row pour afficher les boutons côte à côte
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end, // Aligne tout à droite
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PromotionUpdateScreen(promotion: promotion),
                                    ),
                                  );

                                  if (result == true) {
                                    // Rafraîchir la liste des promotions
                                    _fetchPromotions();
                                  }
                                },
                                icon: Icon(Icons.edit, color: Colors.white),
                                label: Text('Éditer', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                              SizedBox(width: 8), // Espace entre les deux boutons
                              ElevatedButton.icon(
                                onPressed: () async {
                                  // Afficher la boîte de dialogue de confirmation avant de supprimer
                                  bool? confirmDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        backgroundColor: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.redAccent,
                                                size: 80,
                                              ),
                                              SizedBox(height: 20),
                                              Text(
                                                'Confirmation de suppression',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.redAccent,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'Êtes-vous sûr de vouloir supprimer cette promotion ?',
                                                style: TextStyle(fontSize: 16),
                                                textAlign: TextAlign.center,
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(false); // Annuler
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.grey,
                                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Annuler',
                                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(true); // Supprimer
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.redAccent,
                                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Supprimer',
                                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  // Si la suppression est confirmée, appeler la méthode de suppression
                                  if (confirmDelete == true) {
                                    _deletePromotion(promotion.id);
                                  }
                                },
                                icon: Icon(Icons.delete, color: Colors.white),
                                label: Text('Supprimer', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Aucune promotion disponible.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PromotionAddScreen()),
          );

          if (result == true) {
            _fetchPromotions();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF00BCD0),
      ),
    );
  }
}
