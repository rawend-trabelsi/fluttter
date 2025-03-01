import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/AvisService.dart';
import '../models/Avis.dart';
import 'Footer.dart';

class AjouterAvisScreen extends StatefulWidget {
  final int serviceId;
  final String serviceTitre;

  const AjouterAvisScreen(
      {Key? key, required this.serviceId, required this.serviceTitre})
      : super(key: key);

  @override
  _AjouterAvisScreenState createState() => _AjouterAvisScreenState();
}

class _AjouterAvisScreenState extends State<AjouterAvisScreen> {
  int _selectedStars = 0;
  TextEditingController _commentaireController = TextEditingController();
  String? email;
  String? serviceTitre;

  @override
  void initState() {
    super.initState();
    AvisService().getEmailFromToken().then((userEmail) {
      setState(() {
        email = userEmail;
      });
    }).catchError((e) {
      setState(() {
        email = 'Email non disponible';
      });
    });

    AvisService().getTitreService(widget.serviceId).then((title) {
      setState(() {
        serviceTitre = title;
      });
    }).catchError((e) {
      setState(() {
        serviceTitre = 'Titre non disponible';
      });
    });
  }

  Future<void> _submitAvis() async {
    if (_commentaireController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Veuillez écrire un commentaire")));
      return;
    }

    Avis avis = Avis(
      etoile: _selectedStars,
      commentaire: _commentaireController.text,
      email: email ?? 'Email non disponible',
      serviceId: widget.serviceId,
      titreService: serviceTitre ?? 'Titre non disponible',
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt_token");

    if (token != null) {
      try {
        bool success = await AvisService().ajouterAvis(avis, token);

        if (success) {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erreur lors de l'ajout de l'avis")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Une erreur est survenue : $e")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Token non trouvé")));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
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
                  Icons.check_circle_outline,
                  color: Color(0xFF00BCD0),
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Merci',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD0),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Avis ajouté avec succès !',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00BCD0),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var isDarkMode;
    var toggleTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Donner Avis',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Le texte sera en gras
            fontSize: 22, // Taille du texte
            color: Colors.black, // Couleur du texte
          ),
        ),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF00BCD0))),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: email ?? 'Chargement...'),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            Text("Service:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF00BCD0))),
            TextField(
              readOnly: true,
              controller:
                  TextEditingController(text: serviceTitre ?? 'Chargement...'),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            Text("Score:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF00BCD0))),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedStars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedStars = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 10),
            Text("Commentaire:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF00BCD0))),
            TextField(
              controller: _commentaireController,
              maxLines: 4,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitAvis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00BCD0),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Envoyer",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        currentIndex: 0,
        isDarkMode: isDarkMode,
        toggleTheme: toggleTheme,
        onTap: (index) {
          if (index != 0) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      ),
    );
  }
}
