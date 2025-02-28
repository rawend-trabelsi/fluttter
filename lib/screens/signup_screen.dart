import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectlavage/screens/signin_screen.dart';
import '../models/signup_request.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  SignUpScreen({required this.isDarkMode, required this.toggleTheme});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _showToast(String message, {Color? color}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color ?? Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: widget.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'S’inscrire',
                    style: GoogleFonts.robotoFlex(
                      fontSize: 48,
                      color:
                          widget.isDarkMode ? Colors.white : Color(0xFF00BCD0),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildInputField('Email Address', _emailController, (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter an email';
                    if (!RegExp(r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$')
                        .hasMatch(value)) return 'Invalid email';
                    return null;
                  }),
                  const SizedBox(height: 16),
                  _buildInputField('Username', _usernameController, (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter a username';
                    if (value.length < 3 || value.length > 50)
                      return 'Username must be 3-50 characters';
                    return null;
                  }),
                  const SizedBox(height: 16),
                  _buildInputField('Phone Number', _phoneController, (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter a phone number';
                    if (!RegExp(r"^\+?[0-9]{8}$").hasMatch(value))
                      return 'Invalid phone number';
                    return null;
                  }),
                  const SizedBox(height: 16),
                  _buildPasswordInputField('Password', _isPasswordVisible,
                      (isVisible) {
                    setState(() => _isPasswordVisible = isVisible);
                  }, _passwordController),
                  const SizedBox(height: 16),
                  _buildPasswordInputField(
                      'Confirm Password', _isConfirmPasswordVisible,
                      (isVisible) {
                    setState(() => _isConfirmPasswordVisible = isVisible);
                  }, _confirmPasswordController, isConfirmPassword: true),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_passwordController.text !=
                              _confirmPasswordController.text) {
                            _showToast('Passwords do not match!');
                            return;
                          }
                          bool emailExists = await _authService
                              .checkEmail(_emailController.text);
                          bool phoneExists = await _authService
                              .checkPhone(_phoneController.text);
                          if (phoneExists) {
                            _showToast('Phone number already exists.');
                          } else if (emailExists) {
                            _showToast('Email already exists.');
                          } else {
                            final signUpRequest = SignUpRequest(
                              email: _emailController.text,
                              username: _usernameController.text,
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                              phone: _phoneController.text,
                            );
                            final success =
                                await _authService.signUp(signUpRequest);
                            if (success) {
                              var isDarkMode;
                              var toggleTheme;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignInScreen(
                                    isDarkMode: widget.isDarkMode,
                                    toggleTheme: widget.toggleTheme,
                                  ),
                                ),
                              );
                            } else {
                              _showToast('An error occurred.');
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: Text('S\'INSCRIRE',
                          style: GoogleFonts.roboto(
                              fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Vous avez déjà un compte? ',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF808080))),
                      GestureDetector(
                        onTap: () {
                          var isDarkMode;
                          var toggleTheme;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(
                                isDarkMode: widget.isDarkMode,
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Se connecter.',
                          style: TextStyle(
                              color: Color(0xFF00BCD0),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: widget.isDarkMode ? Colors.white : Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: widget.isDarkMode ? Colors.white : Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00BCD0)),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordInputField(String label, bool isVisible,
      Function(bool) onVisibilityToggle, TextEditingController controller,
      {bool isConfirmPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: widget.isDarkMode ? Colors.white : Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: widget.isDarkMode ? Colors.white : Colors.grey),
        ),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0xFF00BCD0)),
          onPressed: () => onVisibilityToggle(!isVisible),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a password';
        if (isConfirmPassword && value != _passwordController.text)
          return 'Passwords do not match';
        return null;
      },
    );
  }
}
