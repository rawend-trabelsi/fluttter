import 'package:flutter/material.dart';
import 'ProfileScreen.dart';

import 'user_screen.dart'; // Import de la page UserScreen

class Footer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Footer({Key? key, required this.currentIndex, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF00BCD0), // Couleur active
      unselectedItemColor: Colors.grey, // Couleur inactive
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);
        // Ajouter la logique de navigation ici
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => UserScreen(
                  username: '',
                )), // Navigation vers UserScreen
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen()), // Navigation vers ProfileScreen
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Acceuil'),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Aide & FAQ'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}
