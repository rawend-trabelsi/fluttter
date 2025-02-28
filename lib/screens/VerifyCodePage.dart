import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'ForgotPasswordPage.dart';
import 'ResetPasswordPage.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;

  VerifyCodePage({required this.email});

  @override
  _VerifyCodePageState createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final List<TextEditingController> codeControllers =
      List.generate(6, (_) => TextEditingController());
  final AuthService authService = AuthService();
  int attemptCount = 0;
  bool canResend = true;
  late Timer resendTimer;
  int countdown = 120;
  bool isCodeExpired = false;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  bool isCodeValid() {
    return codeControllers.every((controller) => controller.text.isNotEmpty);
  }

  void startResendTimer() {
    setState(() {
      canResend = false;
      countdown = 120;
      isCodeExpired = false;
    });

    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        setState(() {
          canResend = true;
          isCodeExpired = true;
        });
        resendTimer.cancel();
      }
    });
  }

  void resendCode() async {
    if (attemptCount < 3 && canResend) {
      bool codeSent = await authService.resendVerificationCode(widget.email);
      if (codeSent) {
        setState(() {
          attemptCount++;
          isCodeExpired = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Un nouveau code a été envoyé à ${widget.email}.')),
        );
        startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'envoi du code.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Vous avez atteint le nombre de tentatives. Veuillez répéter le processus.')),
      );
      var isDarkMode;
      var toggleTheme;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ForgotPasswordPage(
                  isDarkMode: isDarkMode,
                  toggleTheme: toggleTheme,
                )),
      );
    }
  }

  @override
  void dispose() {
    resendTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond général blanc
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Entrez le code de confirmation',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Entrez le code à 6 chiffres',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: codeControllers[index],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor:
                          Colors.grey[200], // Garde la même couleur des cases
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (isCodeExpired) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Le code est expiré. Veuillez en demander un nouveau.')),
                  );
                  return;
                }
                if (!isCodeValid()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Veuillez entrer le code complet.')),
                  );
                  return;
                }
                String fullCode = codeControllers.map((c) => c.text).join();
                bool success =
                    await authService.verifyResetCode(widget.email, fullCode);
                if (success) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPasswordPage(
                        email: widget.email,
                        oldPassword: '',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Code invalide. Veuillez réessayer.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD0),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Vérifier le code',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 13),
            ElevatedButton(
              onPressed: canResend ? resendCode : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF999EA1),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                canResend
                    ? 'Renvoyer le code'
                    : 'Réessayez dans $countdown sec',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
