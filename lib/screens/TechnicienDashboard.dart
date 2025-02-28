import 'package:flutter/material.dart';
import 'package:projectlavage/screens/signin_screen.dart';
import 'package:projectlavage/services/auth_service.dart';
import 'EditProfilePageTechnicien.dart';
import 'EquipeListScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TechnicienDashboard(),
      routes: {
        '/EditProfilePageTechnicien': (context) => EditProfilePageTechnicien(),
      },
    );
  }
}

class TechnicienDashboard extends StatefulWidget {
  @override
  _TechnicienDashboardState createState() => _TechnicienDashboardState();
}

class _TechnicienDashboardState extends State<TechnicienDashboard> {
  int _selectedPageIndex = 0;
  final AuthService authService = AuthService();

  final List<Widget> _pages = [
    Center(child: Text('Accueil')),
    Center(child: Text('Réservations')),
    EditProfilePageTechnicien(), // Profil
    Center(child: Text('Notifications')),
    EquipeListScreen(), // Liste des équipes
  ];

  void _onSelectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: TechnicienSidebar(
          authService: authService, onSelectPage: _onSelectPage),
      body: _pages[_selectedPageIndex],
    );
  }
}

class TechnicienSidebar extends StatelessWidget {
  final AuthService authService;
  final Function(int) onSelectPage;

  TechnicienSidebar({required this.authService, required this.onSelectPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.cyan[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.cyan[300],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technicien', // Correction du rôle affiché
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Welcome to Technicien Dashboard',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, 'assets/images/home.png', 'Accueil', 0),
            _buildDrawerItem(
                context, 'assets/images/reservations.png', 'Réservations', 1),
            _buildDrawerItem(
                context, 'assets/images/notifications.png', 'Notifications', 2),

            _buildDrawerItem(
                context, 'assets/images/profile.png', 'Profile', 3),
            _buildDrawerItem(
                context, 'assets/images/logout.png', 'Se déconnecter', 4),

            // Correction de l'index
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String iconPath, String title, int index) {
    return ListTile(
      leading: Image.asset(
        iconPath,
        width: 30,
        height: 30,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16),
      ),
      onTap: () async {
        if (index == 4) {
          // Déconnexion
          await authService.signOut();
          var isDarkMode;
          var toggleTheme;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SignInScreen(
                      isDarkMode: isDarkMode,
                      toggleTheme: toggleTheme,
                    )),
          );
        } else if (index == 3) {
          // Ajout d'un nouvel index pour la page Profil
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditProfilePageTechnicien()), // Remplace par ta page de profil
          );
        } else {
          Navigator.pop(context);
          onSelectPage(index);
        }
      },
    );
  }
}
