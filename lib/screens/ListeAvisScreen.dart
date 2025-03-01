import 'package:flutter/material.dart';
import '../models/Avis.dart';
import '../services/AvisService.dart';
import 'AjouterAvisScreen.dart'; // Assurez-vous d'importer l'écran AjouterAvisScreen
import 'Footer.dart'; // Importation du Footer





class ListeAvisScreen extends StatefulWidget {
final int idService;

ListeAvisScreen({required this.idService});

@override
_ListeAvisScreenState createState() => _ListeAvisScreenState();
}


class _ListeAvisScreenState extends State<ListeAvisScreen> {
  late Future<List<Avis>> avisFuture;
  final AvisService avisService = AvisService();

  @override
  void initState() {
    super.initState();
    avisFuture = avisService.fetchAvis(widget.idService);
  }

  Widget buildStars(int etoiles) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < etoiles ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isDarkMode;
    var toggleTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des avis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Avis>>(
              future: avisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Soyez les premiers à laisser votre avis !",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Avis avis = snapshot.data![index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row pour l'email et les étoiles
                              Row(
                                children: [
                                  Text(
                                    avis.email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Spacer(), // Espace flexible entre l'email et les étoiles
                                  buildStars(avis.etoile), // Etoiles alignées à droite
                                ],
                              ),
                              SizedBox(height: 10), // Espacement entre les étoiles et le commentaire
                              Text(
                                avis.commentaire, // Affichage du commentaire
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AjouterAvisScreen(
                        serviceId: widget.idService,
                        serviceTitre: "Nom du service",
                      ),
                    ),
                  ).then((_) {
                    setState(() {
                      avisFuture = avisService.fetchAvis(widget.idService);
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                ),
                child: Text(
                  "Donner Avis",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Footer(
            currentIndex: 0,
              isDarkMode: isDarkMode,
  toggleTheme: toggleTheme,
            onTap: (index) {
              if (index != 0) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
        ],
      ),
    );
  }
}
