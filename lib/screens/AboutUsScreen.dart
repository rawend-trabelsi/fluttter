import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'footer.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "À propos de nous",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Flèche noire
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF00BCD0), // Fond de l'AppBar
        elevation: 5, // Légère élévation
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "AGHSALNIII LAVAGE SANS EAU",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    shadows: [
                      Shadow(
                        blurRadius: 12.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0.0, 4.0),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  "ÉCONOMIQUE DE 8H À 22H",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),
              Text(
                "N’hésitez pas à nous contacter !",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800]),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContactItem(Icons.call, "Appelez-nous",
                      "Mon-Fri • 9-17", Colors.green),
                  _buildContactItem(Icons.email, "Écrivez-nous",
                      "Mon-Fri • 9-17", Colors.yellow),
                ],
              ),
              SizedBox(height: 30),
              Text(
                "Suivez-nous sur les réseaux sociaux",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800]),
              ),
              SizedBox(height: 15),
              _buildSocialMediaItem(FontAwesomeIcons.instagram, "Instagram",
                  "4,6K Followers  •  118 Posts", Colors.pink),
              _buildSocialMediaItem(FontAwesomeIcons.facebook, "Facebook",
                  "3,8K Followers  •  136 Posts", Colors.blue),
              _buildSocialMediaItem(FontAwesomeIcons.whatsapp, "WhatsApp",
                  "Disponible Mon-Fri  •  9-17", Colors.green),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(
        currentIndex: 2, // Garde le bouton Profil sélectionné
        onTap: (index) {
          // Ajoute une logique si besoin
        },
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String title, String subtitle, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 45),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaItem(
      IconData icon, String title, String subtitle, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 8,
        margin: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: ListTile(
          leading: Icon(icon, color: color, size: 35),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        ),
      ),
    );
  }
}
