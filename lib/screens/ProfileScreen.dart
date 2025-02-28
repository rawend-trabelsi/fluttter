import 'package:flutter/material.dart';

import 'package:projectlavage/screens/signin_screen.dart';

import '../services/auth_service.dart';
import 'AbonnementUserPage.dart';
import 'AboutUsScreen.dart';
import 'EditProfilePage.dart';
import 'Footer.dart'; // Assure-toi d'importer ton service d'authentification
// Assure-toi d'importer la page de connexion

class ProfileScreen extends StatelessWidget {
  final AuthService authService = AuthService(); // Instance de ton AuthService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Mon profil",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profil Section
            _buildProfileOption(
              Icons.person_outline,
              "Modifier Profil",
              context,
            ),
            _buildProfileOption(
              Icons.notifications_none,
              "Notifications",
              context,
            ),
            Divider(),
            // Commandes Section
            _buildProfileOption(
              Icons.shopping_cart_outlined,
              "Commandes",
              context,
            ),
            _buildProfileOption(
              Icons.location_on_outlined,
              "Localisation du technicien",
              context,
            ),
            Divider(),
            // About Us and Subscriptions Section
            _buildProfileOption(
              Icons.info_outline,
              "À propos de nous",
              context,
            ),
            _buildProfileOption(
              Icons.subscriptions_outlined,
              "Abonnements",
              context,
            ),
            Divider(),
// Déconnecter Section moved to the end
            _buildProfileOption(
              Icons.logout,
              "Déconnecter",
              context,
              isLogout:
                  true, // Ajouter un paramètre pour spécifier qu'il s'agit de la déconnexion
            ),
            ListTile(
              onTap: () async {
                // Appeler signOut() de AuthService pour déconnecter l'utilisateur
                await authService.signOut();

                // Rediriger vers la page de connexion
                var isDarkMode;
                var toggleTheme;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen(   isDarkMode: isDarkMode,
                      toggleTheme: toggleTheme,)),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        currentIndex: 2, // Met "Profile" en actif
        onTap: (index) {
          if (index != 2) {
            _navigateToScreen(context, index);
          }
        },
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, BuildContext context,
      {bool isLogout = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
          leading:
              Icon(icon, color: Color(0xFF00BCD0), size: 30), // Couleur cyan
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.black54,
          ),
          onTap: () {
            if (isLogout) {
              _handleLogout(context); // Appel à la méthode de déconnexion
            } else {
              // Navigation en fonction du titre
              if (title == "Modifier Profil") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              } else if (title == "À propos de nous") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsScreen()),
                );
              } else if (title == "Abonnements") {
                // Ajout pour naviguer vers AbonnementUserPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AbonnementUserPage()),
                );
              }
            }
          }),
    );
  }

  void _handleLogout(BuildContext context) async {
    await authService.signOut();
    var isDarkMode;
    var toggleTheme;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen(   isDarkMode: isDarkMode,
                      toggleTheme: toggleTheme,)),
    );
  }



  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/help');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

}
