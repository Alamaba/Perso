import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/security_service.dart';

class PinSetupScreen extends StatefulWidget {
  final bool isFirstSetup;
  final VoidCallback? onPinSetupComplete;

  const PinSetupScreen({
    Key? key,
    required this.isFirstSetup,
    this.onPinSetupComplete,
  }) : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen>
    with TickerProviderStateMixin {
  final SecurityService _securityService = Get.find<SecurityService>();
  String _pin = '';
  String _confirmPin = '';
  String _oldPin = '';

  // Étapes du processus: 'old_pin', 'new_pin', 'confirm_pin'
  String _currentStep = 'new_pin';
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();

    // Si ce n'est pas la première configuration, commencer par demander l'ancien PIN
    if (!widget.isFirstSetup) {
      _currentStep = 'old_pin';
    }
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
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    setState(() {
      switch (_currentStep) {
        case 'old_pin':
          if (_oldPin.length < 4) {
            _oldPin += number;
            if (_oldPin.length == 4) {
              _validateOldPin();
            }
          }
          break;
        case 'new_pin':
          if (_pin.length < 4) {
            _pin += number;
            if (_pin.length == 4) {
              _moveToConfirmStep();
            }
          }
          break;
        case 'confirm_pin':
          if (_confirmPin.length < 4) {
            _confirmPin += number;
            if (_confirmPin.length == 4) {
              _validateNewPin();
            }
          }
          break;
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      switch (_currentStep) {
        case 'old_pin':
          if (_oldPin.isNotEmpty) {
            _oldPin = _oldPin.substring(0, _oldPin.length - 1);
          }
          break;
        case 'new_pin':
          if (_pin.isNotEmpty) {
            _pin = _pin.substring(0, _pin.length - 1);
          }
          break;
        case 'confirm_pin':
          if (_confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
          break;
      }
    });
  }

  Future<void> _validateOldPin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await _securityService.validatePinCode(_oldPin);

      if (isValid) {
        setState(() {
          _currentStep = 'new_pin';
          _isLoading = false;
        });
      } else {
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });

        setState(() {
          _oldPin = '';
          _isLoading = false;
        });

        Get.snackbar(
          'Code incorrect',
          'L\'ancien code PIN est incorrect',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      setState(() {
        _oldPin = '';
        _isLoading = false;
      });

      Get.snackbar(
        'Erreur',
        'Impossible de valider l\'ancien PIN: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _moveToConfirmStep() {
    setState(() {
      _currentStep = 'confirm_pin';
    });
  }

  Future<void> _validateNewPin() async {
    if (_pin == _confirmPin) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _securityService.setPinCode(_pin);

        // Arrêter l'indicateur de chargement
        setState(() {
          _isLoading = false;
        });

        // Afficher le message de succès avec plus de visibilité
        Get.snackbar(
          widget.isFirstSetup ? 'PIN configuré ✓' : 'PIN modifié ✓',
          widget.isFirstSetup
              ? 'Votre code PIN a été configuré avec succès'
              : 'Votre code PIN a été modifié avec succès',
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Attendre un petit délai pour que l'utilisateur voie le message
        await Future.delayed(const Duration(milliseconds: 1500));

        // Appeler le callback s'il existe
        if (widget.onPinSetupComplete != null) {
          widget.onPinSetupComplete!();
        }

        // Retourner à l'écran précédent avec mise à jour
        // Si c'est une première configuration, rediriger vers l'écran principal
        if (widget.isFirstSetup) {
          print(
              '📍 PIN Setup: Première configuration terminée, redirection vers home');
          // Pour première configuration, aller à l'écran principal
          Get.offAllNamed('/home');
        } else {
          print('📍 PIN Setup: Modification terminée, retour à Settings');
          // Pour modification, retourner à Settings avec résultat
          // Utiliser Get.back avec un callback pour s'assurer du retour
          Get.back(result: {'success': true, 'modified': true});
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        Get.snackbar(
          'Erreur',
          'Impossible de configurer le PIN: $e',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          snackPosition: SnackPosition.TOP,
        );
      }
    } else {
      // Animation de secousse pour erreur
      _shakeController.forward().then((_) {
        _shakeController.reverse();
      });

      // Réinitialiser
      setState(() {
        _pin = '';
        _confirmPin = '';
        _currentStep = 'new_pin';
      });

      Get.snackbar(
        'Erreur',
        'Les codes PIN ne correspondent pas',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  String get _currentPin {
    switch (_currentStep) {
      case 'old_pin':
        return _oldPin;
      case 'new_pin':
        return _pin;
      case 'confirm_pin':
        return _confirmPin;
      default:
        return '';
    }
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 'old_pin':
        return 'Code PIN actuel';
      case 'new_pin':
        return widget.isFirstSetup ? 'Nouveau code PIN' : 'Nouveau code PIN';
      case 'confirm_pin':
        return 'Confirmer le code PIN';
      default:
        return '';
    }
  }

  String get _stepSubtitle {
    switch (_currentStep) {
      case 'old_pin':
        return 'Saisissez votre code PIN actuel';
      case 'new_pin':
        return widget.isFirstSetup
            ? 'Créez un code PIN à 4 chiffres'
            : 'Créez votre nouveau code PIN à 4 chiffres';
      case 'confirm_pin':
        return 'Saisissez à nouveau votre nouveau code PIN';
      default:
        return '';
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
              // Header avec bouton retour
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.isFirstSetup
                          ? 'Configuration PIN'
                          : 'Modifier PIN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Contenu principal
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icône selon l'étape
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
                          child: Icon(
                            _currentStep == 'old_pin'
                                ? Icons.lock_outline
                                : Icons.pin,
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
                                  Text(
                                    _stepTitle,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _stepSubtitle,
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),

                        // Indicateur d'étape pour modification
                        if (!widget.isFirstSetup) ...[
                          const SizedBox(height: 40),
                          _buildStepIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot('old_pin', 1),
        Container(
          width: 30,
          height: 2,
          color: _currentStep == 'confirm_pin'
              ? Colors.white
              : Colors.white.withOpacity(0.3),
        ),
        _buildStepDot('new_pin', 2),
        Container(
          width: 30,
          height: 2,
          color: _currentStep == 'confirm_pin'
              ? Colors.white
              : Colors.white.withOpacity(0.3),
        ),
        _buildStepDot('confirm_pin', 3),
      ],
    );
  }

  Widget _buildStepDot(String step, int number) {
    final isActive = _currentStep == step;
    final isCompleted = (_currentStep == 'new_pin' && step == 'old_pin') ||
        (_currentStep == 'confirm_pin' &&
            (step == 'old_pin' || step == 'new_pin'));

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? Colors.white
            : isActive
                ? Colors.white.withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.blue, size: 16)
            : Text(
                '$number',
                style: TextStyle(
                  color: isActive ? Colors.blue : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  Widget _buildPinIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index < _currentPin.length;
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
