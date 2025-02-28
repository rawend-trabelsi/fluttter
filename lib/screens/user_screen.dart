import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ServiceService.dart';
import '../models/service.dart';
import '../services/auth_service.dart';
import 'Footer.dart';
import 'ListeAvisScreen.dart';

class UserScreen extends StatefulWidget {
  final String username;
  const UserScreen({Key? key, required this.username}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final AuthService authService = AuthService();
  final _serviceService = ServiceService();
  late Future<List<Service>> _services;
  List<Service> _allServices = [];
  List<Service> _filteredServices = [];
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _services = _serviceService.getServices();
    _services.then((services) {
      setState(() {
        _allServices = services;
        _filteredServices = services;
      });
    });
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = query.isEmpty
          ? _allServices
          : _allServices
              .where((service) => service.titre.toLowerCase().contains(query))
              .toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home', arguments: widget.username);
        break;
      case 1:
        Navigator.pushNamed(context, '/help', arguments: widget.username);
        break;
      case 2:
        Navigator.pushNamed(context, '/profile', arguments: widget.username);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFF00BCD0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue sur Aghsalni App 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Découvrez nos services exceptionnels',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un service...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Titre "Les Services" centré
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Les Services',
                  style: GoogleFonts.rochester(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF00BCD0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _filteredServices.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun service trouvé',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          childAspectRatio: 0.52,
                        ),
                        itemCount: _filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = _filteredServices[index];
                          final hasPromotion = service.discountedPrice != null;

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: hasPromotion
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.transparent,
                                width: hasPromotion ? 1.5 : 0,
                              ),
                            ),
                            elevation: 4,
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                      child: Image.memory(
                                        base64Decode(service.imageUrl),
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Titre du service
                                          Text(
                                            service.titre,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF00BCD0),
                                              decorationColor:
                                                  Color(0xFF0097A7),
                                              decorationThickness: 2,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          // Description
                                          Text(
                                            service.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                          ),
                                          SizedBox(height: 6),
                                          // Durée
                                          Row(
                                            children: [
                                              Icon(Icons.timer,
                                                  size: 14,
                                                  color: Color(0xFF00BCD0)),
                                              SizedBox(width: 4),
                                              Text(
                                                '${service.duree}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Color(0xFF0097A7),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6),
                                          // Prix et bouton commentaire
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              if (service.discountedPrice !=
                                                  null)
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${service.prix == service.prix.toInt() ? service.prix.toInt() : service.prix.toStringAsFixed(2)} DT',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 12,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        decorationColor:
                                                            Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${service.discountedPrice != null ? (service.discountedPrice! % 1 == 0 ? service.discountedPrice!.toInt() : service.discountedPrice!.toStringAsFixed(3)) : 'N/A'} DT",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 14,
                                                      ),
                                                    )
                                                  ],
                                                )
                                              else
                                                Text(
                                                  '${service.prix == service.prix.toInt() ? service.prix.toInt() : service.prix.toStringAsFixed(2)} DT',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              // Icône de commentaire
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                                icon: Icon(
                                                  Icons.comment,
                                                  color: Color(0xFF00BCD0),
                                                  size: 24,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ListeAvisScreen(
                                                        idService: service.id,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                          // Bouton réserver
                                          SizedBox(height: 6),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xFF00BCD0),
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                minimumSize:
                                                    Size(double.infinity, 36),
                                              ),
                                              child: Text(
                                                'Réserver',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Badge de promotion en haut
                                if (service.promotion != null)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        "Remise ${service.promotion}",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          Footer(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
