import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import '../models/promotion.dart';
import '../services/PromotionService.dart';
import '../services/ServiceService.dart';
import '../models/service.dart';
import '../services/auth_service.dart';
import 'PromotionListScreen.dart';
import 'admin_screen.dart';

class PromotionUpdateScreen extends StatefulWidget {
  final Promotion promotion;

  PromotionUpdateScreen({required this.promotion});

  @override
  _PromotionUpdateScreenState createState() => _PromotionUpdateScreenState();
}

class _PromotionUpdateScreenState extends State<PromotionUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _typeReduction;
  late double _valeurReduction;
  late String _codePromo;
  late String _dateDebut;
  late String _dateFin;
  List<Service> selectedServices = [];
  List<Service> availableServices = [];
  bool selectAll = false;

  final List<String> _typeReductionOptions = ['MONTANT_FIXE', 'POURCENTAGE']; // Options pour le type de réduction

  final PromotionService _promotionService = PromotionService();
  final ServiceService _serviceService = ServiceService();

  // Contrôleurs pour les champs de date
  late TextEditingController _dateDebutController;
  late TextEditingController _dateFinController;

  @override
  void initState() {
    super.initState();
    _typeReduction = widget.promotion.typeReduction;
    _valeurReduction = widget.promotion.valeurReduction;
    _dateDebut = widget.promotion.dateDebut;
    _dateFin = widget.promotion.dateFin;
    _codePromo = widget.promotion.codePromo ?? '';
    selectedServices = List.from(widget.promotion.services);

    // Initialiser les contrôleurs avec les dates formatées
    _dateDebutController = TextEditingController(text: formatDateTime(_dateDebut));
    _dateFinController = TextEditingController(text: formatDateTime(_dateFin));

    _fetchServices();
  }

  @override
  void dispose() {
    // Nettoyer les contrôleurs pour éviter les fuites de mémoire
    _dateDebutController.dispose();
    _dateFinController.dispose();
    super.dispose();
  }

  Future<void> _fetchServices() async {
    try {
      List<Service> services = await _serviceService.getServices();
      setState(() {
        availableServices = services;
      });
    } catch (e) {
      print("Erreur lors du chargement des services: $e");
    }
  }

  Future<String> _selectDateTime(BuildContext context, String initialDate) async {

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(initialDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF00BCD0), // Couleur principale (date sélectionnée)
              secondary: Color(0xFF00BCD0), // Couleur secondaire
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );


    if (pickedDate == null) return initialDate;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.parse(initialDate)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF00BCD0), // Couleur principale (heure sélectionnée)
              secondary: Color(0xFF00BCD0), // Couleur secondaire
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return initialDate;

    DateTime fullDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    return fullDateTime.toIso8601String();
  }

  // Méthode pour formater la date
  String formatDateTime(String isoDate) {
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      return formattedDate;
    } catch (e) {
      print("Erreur lors du formatage de la date : $e");
      return isoDate; // Retourne la date non formatée en cas d'erreur
    }
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        selectedServices = List.from(availableServices);
      } else {
        selectedServices.clear();
      }
    });
  }

  void _toggleService(Service service, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        if (!selectedServices.any((s) => s.id == service.id)) {
          selectedServices.add(service);
        }
      } else {
        selectedServices.removeWhere((s) => s.id == service.id);
      }
      selectAll = selectedServices.length == availableServices.length;
    });
  }
  void _showConfirmationDialog(String message) {
    showDialog(
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
                  Icons.check_circle_outline,
                  color: Color(0xFF00BCD0),
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Succès',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD0),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Ferme la boîte de dialogue
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PromotionListScreen()), // Redirige vers la liste des promotions
                    );
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

  void _showErrorDialog(String message) {
    showDialog(
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
                  Icons.error_outline,
                  color: Colors.red, // Icône d'erreur en rouge
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Erreur',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // Texte en rouge pour l'erreur
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  message, // Message d'erreur dynamique
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Ferme la boîte de dialogue
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Fond rouge pour l'erreur
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

  Future<void> _updatePromotion() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        // Convertir la date de fin en objet DateTime
        DateTime dateFin = DateTime.parse(_dateFin);

        // Obtenir la date actuelle en UTC+1 (Tunisie)
        DateTime currentDateTunisia = DateTime.now().toUtc().add(Duration(hours: 1)); // UTC+1

        // Vérifier si la date de fin est expirée ou égale à la date actuelle
        if (dateFin.isBefore(currentDateTunisia) || dateFin.isAtSameMomentAs(currentDateTunisia)) {
          // Afficher la boîte de dialogue d'erreur avec le design personnalisé
          _showErrorDialog('La date de fin de la promotion est expirée. Veuillez sélectionner une nouvelle date.');
          return; // Arrêter l'exécution si la date est expirée
        }

        // Créer l'objet promotion mis à jour
        Promotion updatedPromotion = Promotion(
          id: widget.promotion.id,
          typeReduction: _typeReduction,
          valeurReduction: _valeurReduction,
          dateDebut: _dateDebut,
          dateFin: _dateFin,
          codePromo: _codePromo,
          services: selectedServices,
          actif: true,
        );

        // Appeler la méthode pour mettre à jour la promotion
        await _promotionService.updatePromotion(updatedPromotion.id, updatedPromotion);

        // Afficher une boîte de dialogue de confirmation de mise à jour personnalisée
        _showConfirmationDialog('La promotion a été mise à jour avec succès.');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }


  void _showServiceSelectionDialog() async {
    final List<Service> tempSelectedServices = List.from(selectedServices);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Text(
                "Modifier les services",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BCD0), // Titre avec la couleur personnalisée
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sélectionner tous les services
                    CheckboxListTile(
                      title: Text(
                        "Tous les services",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: tempSelectedServices.length == availableServices.length,
                      onChanged: (value) {
                        setStateDialog(() {
                          if (value == true) {
                            tempSelectedServices.clear();
                            tempSelectedServices.addAll(availableServices);
                          } else {
                            tempSelectedServices.clear();
                          }
                        });
                      },
                      activeColor: Color(0xFF00BCD0), // Couleur de sélection
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    // Liste des services disponibles
                    ...availableServices.map((service) {
                      return CheckboxListTile(
                        title: Text(service.titre),
                        value: tempSelectedServices.any((s) => s.id == service.id),
                        onChanged: (isSelected) {
                          setStateDialog(() {
                            if (isSelected == true) {
                              if (!tempSelectedServices.any((s) => s.id == service.id)) {
                                tempSelectedServices.add(service);
                              }
                            } else {
                              tempSelectedServices.removeWhere((s) => s.id == service.id);
                            }
                          });
                        },
                        activeColor: Color(0xFF00BCD0), // Couleur de sélection
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                // Bouton Annuler
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey, // Couleur du texte
                  ),
                  child: Text("Annuler"),
                ),
                // Bouton Enregistrer
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedServices = List.from(tempSelectedServices);
                    });
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF00BCD0), // Couleur du fond
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Enregistrer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier promotion'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Champ pour sélectionner le type de réduction
              DropdownButtonFormField<String>(
                value: _typeReduction,
                decoration: InputDecoration(labelText: 'Type de réduction'),
                items: _typeReductionOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _typeReduction = newValue!;
                  });
                },
                validator: (value) => value == null ? 'Veuillez sélectionner un type de réduction' : null,
              ),
              // Champ pour la valeur de réduction (sans unité)
              TextFormField(
                initialValue: _valeurReduction == _valeurReduction.toInt()
                    ? _valeurReduction.toInt().toString()
                    : _valeurReduction.toStringAsFixed(2),
                decoration: InputDecoration(
                  labelText: 'Valeur de réduction',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _valeurReduction = double.parse(value ?? '0'),
                validator: (value) => value?.isEmpty ?? true
                    ? 'La valeur de réduction est requise'
                    : null,
              ),

              // Champ pour la date de début
              TextFormField(
                controller: _dateDebutController,
                decoration: InputDecoration(labelText: 'Date de début'),
                onTap: () async {
                  String selectedDateTime = await _selectDateTime(context, _dateDebut);
                  if (selectedDateTime.isNotEmpty) {
                    setState(() {
                      _dateDebut = selectedDateTime;
                      _dateDebutController.text = formatDateTime(_dateDebut);
                    });
                  }
                },
                readOnly: true,
                validator: (value) => value?.isEmpty ?? true ? 'La date de début est requise' : null,
              ),
              // Champ pour la date de fin
              TextFormField(
                controller: _dateFinController,
                decoration: InputDecoration(labelText: 'Date de fin'),
                onTap: () async {
                  String selectedDateTime = await _selectDateTime(context, _dateFin);
                  if (selectedDateTime.isNotEmpty) {
                    setState(() {
                      _dateFin = selectedDateTime;
                      _dateFinController.text = formatDateTime(_dateFin);
                    });
                  }
                },
                readOnly: true,
                validator: (value) => value?.isEmpty ?? true ? 'La date de fin est requise' : null,
              ),
              // Champ pour le code promo
              TextFormField(
                initialValue: _codePromo,
                decoration: InputDecoration(labelText: 'Code Promo'),
                onSaved: (value) => _codePromo = value ?? '',
              ),
              SizedBox(height: 20),
              Text(
                "Services sélectionnés :",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Column(
                children: selectedServices.map((service) {
                  return ListTile(
                    title: Text(service.titre),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _showServiceSelectionDialog,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF00BCD0), // text color
                ),
                child: Text("Modifier les services"),
              ),

              SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updatePromotion,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Color(0xFF00BCD0), // text color
            ),
            child: Text('Mettre à jour'),
          ),
          ],

        ),
        ),
      ),
    );
  }
}