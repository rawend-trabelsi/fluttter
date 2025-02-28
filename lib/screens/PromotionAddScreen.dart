import 'package:flutter/material.dart';
import '../models/promotion.dart';
import '../services/PromotionService.dart';
import '../services/ServiceService.dart';
import '../models/service.dart';
import '../services/auth_service.dart';
import 'PromotionListScreen.dart';
import 'admin_screen.dart';

class PromotionAddScreen extends StatefulWidget {
  @override
  _PromotionAddScreenState createState() => _PromotionAddScreenState();
}

class _PromotionAddScreenState extends State<PromotionAddScreen> {
  final TextEditingController _dateDebutController = TextEditingController();
  final TextEditingController _dateFinController = TextEditingController();
  final TextEditingController _reductionValueController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();

  String reductionType = 'POURCENTAGE';
  List<Service> selectedServices = [];
  List<Service> availableServices = [];
  bool selectAll = false;

  final _serviceService = ServiceService();
  final _promotionService = PromotionService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchServices();
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

  Future<String> _selectDateTime(BuildContext context) async {
    DateTime now = DateTime.now().toUtc().add(Duration(hours: 1)); // Heure de Tunisie

    // Utiliser un Theme pour changer la couleur du showDatePicker
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
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

    if (pickedDate == null) return '';

    // Utiliser un Theme pour changer la couleur du showTimePicker
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
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

    if (pickedTime == null) return '';

    DateTime fullDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    return "${fullDateTime.toLocal()}".substring(0, 16);
  }


  DateTime? parseDateTime(String value) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
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
        selectedServices.add(service);
      } else {
        selectedServices.remove(service);
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

  Future<void> _submitPromotion() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Conversion des dates au format ISO 8601
        String dateDebutIso = DateTime.parse(_dateDebutController.text).toIso8601String();
        String dateFinIso = DateTime.parse(_dateFinController.text).toIso8601String();

        // Création de l'objet DateTime pour la date de fin
        DateTime dateFin = DateTime.parse(dateFinIso);

        // Récupération de la date actuelle avec l'heure correcte pour la Tunisie (UTC+1)
        DateTime currentDateTunisia = DateTime.now().toUtc().add(Duration(hours: 1));  // UTC+1

        // Comparaison des dates en prenant en compte le fuseau horaire de la Tunisie
        if (dateFin.isBefore(currentDateTunisia) || dateFin.isAtSameMomentAs(currentDateTunisia)) {
          // Afficher la boîte de dialogue d'erreur avec le design personnalisé
          _showErrorDialog('La date de fin de la promotion est expirée. Veuillez sélectionner une nouvelle date.');
          return; // Arrêter l'exécution si la date est expirée
        }

        // Si la date et l'heure sont valides, continuer l'ajout de la promotion
        Promotion newPromotion = Promotion(
          id: 0,
          actif: true,
          typeReduction: reductionType,
          valeurReduction: double.parse(_reductionValueController.text),
          dateDebut: dateDebutIso, // Utilisation du format ISO 8601
          dateFin: dateFinIso,
          services: selectedServices,
          codePromo: _promoCodeController.text.isNotEmpty ? _promoCodeController.text : '',
        );

        String message = await _promotionService.addPromotion(newPromotion);

        setState(() {
          _dateDebutController.clear();
          _dateFinController.clear();
          _reductionValueController.clear();
          _promoCodeController.clear();
          reductionType = 'POURCENTAGE';
          selectedServices.clear();
          selectAll = false;
        });

        // Afficher le message de confirmation
        _showConfirmationDialog('La promotion a été ajoutée avec succès !');

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    }
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
                  color: Colors.red, // Icone d'erreur en rouge
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
                    Navigator.pop(context); // Fermer la boîte de dialogue
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une promotion'),
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
              TextFormField(
                decoration: InputDecoration(labelText: 'Date Début'),

                controller: _dateDebutController,
                onTap: () async {
                  String selectedDateTime = await _selectDateTime(context);
                  if (selectedDateTime.isNotEmpty) {
                    setState(() {
                      _dateDebutController.text = selectedDateTime;
                    });
                  }
                },
                readOnly: true,
                validator: (value) => value == null || value.isEmpty ? 'La date de début est requise' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date Fin'),
                controller: _dateFinController,
                onTap: () async {
                  String selectedDateTime = await _selectDateTime(context);
                  if (selectedDateTime.isNotEmpty) {
                    setState(() {
                      _dateFinController.text = selectedDateTime;
                    });
                  }
                },
                readOnly: true,
                validator: (value) => value == null || value.isEmpty ? 'La date de fin est requise' : null,
              ),
              DropdownButtonFormField<String>(
                value: reductionType,
                decoration: InputDecoration(labelText: 'Type de Réduction'),
                items: ['POURCENTAGE', 'MONTANT_FIXE']
                    .map((value) => DropdownMenuItem(child: Text(value), value: value))
                    .toList(),
                onChanged: (newValue) => setState(() => reductionType = newValue!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Valeur de la Réduction'),
                keyboardType: TextInputType.number,
                controller: _reductionValueController,
                validator: (value) => value == null || value.isEmpty ? 'La valeur de la réduction est requise' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Code Promo (optionnel)'),
                controller: _promoCodeController,
              ),
              CheckboxListTile(
                title: Text(
                  "Tous les services",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                value: selectAll,
                onChanged: _toggleSelectAll,
                activeColor: Color(0xFF00BCD0), // Couleur de sélection
              ),

              Column(
                children: availableServices.map((service) => CheckboxListTile(
                  title: Text(service.titre),
                  value: selectedServices.contains(service),
                  onChanged: (isSelected) => _toggleService(service, isSelected),
                  activeColor: Color(0xFF00BCD0), // Définir la couleur ici
                )).toList(),
              ),

              ElevatedButton(
                onPressed: _submitPromotion,
                child: Text(
                  'Ajouter la Promotion',
                  style: TextStyle(color: Colors.white), // Set text color to white
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00BCD0),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
