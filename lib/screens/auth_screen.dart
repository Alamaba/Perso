import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/security_service.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final SecurityService _securityService = Get.find<SecurityService>();
  final AuthService _authService = Get.find<AuthService>();

  String _pin = '';
  bool _isLoading = false;
  String _currentMode = 'choice'; // 'choice', 'pin', 'biometric'

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    // Écouter les changements d'état du service de sécurité
    ever(_securityService.isBiometricEnabled, (_) => _determineInitialMode());
    ever(_securityService.isPinEnabled, (_) => _determineInitialMode());

    _determineInitialMode();
  }

  void _determineInitialMode() {
    // Attendre que les services soient complètement initialisés
    Future.delayed(const Duration(milliseconds: 100), () {
      final biometricEnabled = _securityService.isBiometricEnabled.value;
      final pinEnabled = _securityService.isPinEnabled.value;

      print('🔍 Détection des méthodes d\'authentification:');
      print('   - Biométrie activée: $biometricEnabled');
      print('   - PIN activé: $pinEnabled');

      if (biometricEnabled && pinEnabled) {
        print('   ✅ Les deux méthodes sont activées → Mode choix');
        setState(() {
          _currentMode = 'choice';
        });
      } else if (biometricEnabled && !pinEnabled) {
        print('   ✅ Seulement biométrie → Mode biométrique direct');
        setState(() {
          _currentMode = 'biometric';
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          _tryBiometricAuth();
        });
      } else if (pinEnabled && !biometricEnabled) {
        print('   ✅ Seulement PIN → Mode PIN direct');
        setState(() {
          _currentMode = 'pin';
        });
      } else {
        print('   ⚠️ Aucune méthode configurée → Redirection vers home');
        Get.offAllNamed('/home');
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricAuth() async {
    if (!_securityService.isBiometricEnabled.value) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _securityService.authenticateWithBiometric(
        reason: 'Authentifiez-vous pour accéder à l\'application',
      );

      if (success) {
        Get.offAllNamed('/home');
      } else {
        setState(() {
          _isLoading = false;
          if (_securityService.isPinEnabled.value) {
            _currentMode =
                'choice'; // Retourner au choix si les deux sont disponibles
          }
        });
      }
    } catch (e) {
      print('Erreur authentification biométrique: $e');
      setState(() {
        _isLoading = false;
        if (_securityService.isPinEnabled.value) {
          _currentMode = 'choice';
        }
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
      });

      if (_pin.length == 4) {
        _validatePin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _validatePin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await _securityService.validatePinCode(_pin);

      if (isValid) {
        Get.offAllNamed('/home');
      } else {
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });

        setState(() {
          _pin = '';
          _isLoading = false;
        });

        Get.snackbar(
          'Code incorrect',
          'Le code PIN saisi est incorrect',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de valider le PIN: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );

      setState(() {
        _pin = '';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade800,
              Colors.indigo.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec info utilisateur
              _buildHeader(),

              // Contenu principal selon le mode
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildMainContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: _authService.currentUserPhoto != null
                  ? NetworkImage(_authService.currentUserPhoto!)
                  : null,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: _authService.currentUserPhoto == null
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour,',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _authService.currentUserName?.split(' ').first ??
                        'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _authService.signOut();
                Get.offAllNamed('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      // Forcer la réévaluation du mode si nécessaire
      final biometricEnabled = _securityService.isBiometricEnabled.value;
      final pinEnabled = _securityService.isPinEnabled.value;

      // Vérifier si le mode actuel est cohérent avec l'état des services
      if (biometricEnabled &&
          pinEnabled &&
          _currentMode != 'choice' &&
          _currentMode != 'pin' &&
          _currentMode != 'biometric') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _currentMode = 'choice';
          });
        });
      }

      switch (_currentMode) {
        case 'choice':
          return _buildChoiceMode();
        case 'pin':
          return _buildPinMode();
        case 'biometric':
          return _buildBiometricMode();
        default:
          return _buildChoiceMode();
      }
    });
  }

  Widget _buildChoiceMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icône de sécurité
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.security,
            size: 60,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 40),

        const Text(
          'Authentification requise',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Choisissez votre méthode d\'authentification',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 60),

        // Boutons de choix
        Column(
          children: [
            if (_securityService.isBiometricEnabled.value)
              _buildChoiceButton(
                icon: Icons.fingerprint,
                title: 'Empreinte digitale',
                subtitle: 'Authentification biométrique',
                onTap: () {
                  setState(() {
                    _currentMode = 'biometric';
                  });
                  _tryBiometricAuth();
                },
              ),
            if (_securityService.isBiometricEnabled.value &&
                _securityService.isPinEnabled.value)
              const SizedBox(height: 20),
            if (_securityService.isPinEnabled.value)
              _buildChoiceButton(
                icon: Icons.pin,
                title: 'Code PIN',
                subtitle: 'Saisir le code à 4 chiffres',
                onTap: () {
                  setState(() {
                    _currentMode = 'pin';
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton retour si les deux modes sont disponibles
        if (_securityService.isBiometricEnabled.value &&
            _securityService.isPinEnabled.value)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _currentMode = 'choice';
                    _pin = '';
                  });
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ),

        // Icône PIN
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.pin,
            size: 50,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 40),

        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Column(
                children: [
                  const Text(
                    'Code PIN',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Saisissez votre code PIN à 4 chiffres',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 60),

        // Indicateurs PIN
        _buildPinIndicators(),

        const SizedBox(height: 60),

        // Clavier numérique ou indicateur de chargement
        if (!_isLoading)
          _buildNumericKeypad()
        else
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
      ],
    );
  }

  Widget _buildBiometricMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton retour si les deux modes sont disponibles
        if (_securityService.isBiometricEnabled.value &&
            _securityService.isPinEnabled.value)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _currentMode = 'choice';
                    _isLoading = false;
                  });
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ),

        // Icône biométrique avec animation
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        const Text(
          'Authentification biométrique',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isLoading
              ? 'Authentification en cours...'
              : 'Touchez le capteur d\'empreinte digitale',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 60),

        // Bouton pour relancer l'authentification
        if (!_isLoading)
          ElevatedButton.icon(
            onPressed: _tryBiometricAuth,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
          )
        else
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
      ],
    );
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index < _pin.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumericKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Rangée 1-2-3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('1'),
              _buildKeypadButton('2'),
              _buildKeypadButton('3'),
            ],
          ),
          const SizedBox(height: 20),

          // Rangée 4-5-6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('4'),
              _buildKeypadButton('5'),
              _buildKeypadButton('6'),
            ],
          ),
          const SizedBox(height: 20),

          // Rangée 7-8-9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('7'),
              _buildKeypadButton('8'),
              _buildKeypadButton('9'),
            ],
          ),
          const SizedBox(height: 20),

          // Rangée 0 et supprimer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 70), // Espacement
              _buildKeypadButton('0'),
              _buildDeleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String number) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: () => _onNumberPressed(number),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: _onDeletePressed,
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
