import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/abonnement.dart';
import '../services/AbonnementService.dart';

import 'Footer.dart';

class AbonnementUserPage extends StatefulWidget {
  @override
  _AbonnementUserPageState createState() => _AbonnementUserPageState();
}

class _AbonnementUserPageState extends State<AbonnementUserPage> {
  late Future<List<Abonnement>> _abonnements;

  @override
  void initState() {
    super.initState();
    _abonnements = AbonnementService().getAbonnements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Abonnements',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10), // Espacement entre le titre et la liste
          Expanded(
            child: FutureBuilder<List<Abonnement>>(
              future: _abonnements,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erreur : ${snapshot.error}",
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun abonnement disponible.",
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final abonnement = snapshot.data![index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Color(0xFF2B2C2E), // Fond gris foncé
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: abonnement.imageUrl.isNotEmpty
                              ? Image.memory(
                            base64Decode(abonnement.imageUrl),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.image, size: 60, color: Colors.white),
                        ),
                        title: Text(
                          abonnement.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                            abonnement.prix == abonnement.prix.toInt()
                                ? '${abonnement.prix.toInt()} DT'
                                : '${abonnement.prix.toStringAsFixed(2)} DT',
                          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            // Action abonnement
                          },
                          child: const Text(
                            "Abonner",
                            style: TextStyle(
                              color: Color(0xFFE4F7FF), // Texte en bleu clair
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Footer(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
