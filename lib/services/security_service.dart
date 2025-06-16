import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SecurityService extends GetxService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  SharedPreferences? _prefs;

  RxBool isSecurityEnabled = false.obs;
  RxBool isBiometricAvailable = false.obs;
  RxBool isBiometricEnabled = false.obs;
  RxBool isPinEnabled = false.obs;

  // Clés pour SharedPreferences
  static const String _keySecurityEnabled = 'security_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPinEnabled = 'pin_enabled';
  static const String _keyPinHash = 'pin_hash';

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _checkBiometricAvailability();
    await _loadSecuritySettings();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      isBiometricAvailable.value = isAvailable && isDeviceSupported;

      if (isBiometricAvailable.value) {
        final List<BiometricType> availableBiometrics =
            await _localAuth.getAvailableBiometrics();
        print('Biométrie disponible: $availableBiometrics');
      }
    } catch (e) {
      print('Erreur lors de la vérification de la biométrie: $e');
      isBiometricAvailable.value = false;
    }
  }

  Future<void> _loadSecuritySettings() async {
    if (_prefs != null) {
      isSecurityEnabled.value = _prefs!.getBool(_keySecurityEnabled) ?? false;
      isBiometricEnabled.value = _prefs!.getBool(_keyBiometricEnabled) ?? false;
      isPinEnabled.value = _prefs!.getBool(_keyPinEnabled) ?? false;
    }
  }

  Future<void> _saveSecuritySettings() async {
    if (_prefs != null) {
      await _prefs!.setBool(_keySecurityEnabled, isSecurityEnabled.value);
      await _prefs!.setBool(_keyBiometricEnabled, isBiometricEnabled.value);
      await _prefs!.setBool(_keyPinEnabled, isPinEnabled.value);
    }
  }

  // Méthodes pour la gestion du PIN
  Future<void> setPinCode(String pin) async {
    if (_prefs != null) {
      final hashedPin = _hashPin(pin);
      await _prefs!.setString(_keyPinHash, hashedPin);
      isPinEnabled.value = true;
      isSecurityEnabled.value = true;
      await _saveSecuritySettings();
    }
  }

  Future<bool> validatePinCode(String pin) async {
    if (_prefs != null) {
      final storedHash = _prefs!.getString(_keyPinHash);
      if (storedHash != null) {
        final inputHash = _hashPin(pin);
        return storedHash == inputHash;
      }
    }
    return false;
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Méthodes pour la biométrie
  Future<bool> authenticateWithBiometric({
    String reason = 'Veuillez vous authentifier pour accéder à l\'application',
  }) async {
    try {
      if (!isBiometricAvailable.value) {
        Get.snackbar(
          'Biométrie non disponible',
          'L\'authentification biométrique n\'est pas disponible sur cet appareil',
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Erreur authentification biométrique: ${e.code} - ${e.message}');

      String errorMessage;
      switch (e.code) {
        case auth_error.notAvailable:
          errorMessage =
              'L\'authentification biométrique n\'est pas disponible';
          break;
        case auth_error.notEnrolled:
          errorMessage = 'Aucune empreinte digitale n\'est enregistrée';
          break;
        case auth_error.lockedOut:
          errorMessage =
              'Trop de tentatives. Authentification temporairement bloquée';
          break;
        case auth_error.permanentlyLockedOut:
          errorMessage = 'Authentification biométrique définitivement bloquée';
          break;
        case 'no_fragment_activity':
          errorMessage =
              'Configuration Android incompatible. Redémarrez l\'application';
          break;
        default:
          errorMessage = 'Erreur d\'authentification biométrique';
      }

      Get.snackbar(
        'Erreur d\'authentification',
        errorMessage,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      return false;
    } catch (e) {
      print('Erreur inattendue: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur inattendue s\'est produite',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> enableBiometric() async {
    if (!isBiometricAvailable.value) {
      return false;
    }

    try {
      final bool authenticated = await authenticateWithBiometric(
        reason: 'Authentifiez-vous pour activer la biométrie',
      );

      if (authenticated) {
        isBiometricEnabled.value = true;
        isSecurityEnabled.value = true;
        await _saveSecuritySettings();
        return true;
      }
    } catch (e) {
      print('Erreur activation biométrie: $e');
    }

    return false;
  }

  Future<void> disableBiometric() async {
    isBiometricEnabled.value = false;

    // Si PIN n'est pas activé, désactiver complètement la sécurité
    if (!isPinEnabled.value) {
      isSecurityEnabled.value = false;
    }

    await _saveSecuritySettings();
  }

  // Méthodes héritées et améliorées
  Future<bool> authenticateWithBiometrics({
    String reason = 'Veuillez vous authentifier pour accéder à l\'application',
  }) async {
    return await authenticateWithBiometric(reason: reason);
  }

  Future<void> enableSecurity() async {
    if (isBiometricAvailable.value) {
      final bool authenticated = await authenticateWithBiometric(
        reason: 'Authentifiez-vous pour activer la sécurité',
      );

      if (authenticated) {
        isSecurityEnabled.value = true;
        isBiometricEnabled.value = true;
        await _saveSecuritySettings();

        Get.snackbar(
          'Sécurité activée',
          'La sécurité biométrique a été activée',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      // Rediriger vers la configuration PIN
      Get.toNamed('/pin-setup');
    }
  }

  Future<void> disableSecurity() async {
    if (isSecurityEnabled.value) {
      final bool shouldDisable = await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Désactiver la sécurité'),
              content: const Text(
                'Êtes-vous sûr de vouloir désactiver la sécurité ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Désactiver'),
                ),
              ],
            ),
          ) ??
          false;

      if (shouldDisable) {
        isSecurityEnabled.value = false;
        isBiometricEnabled.value = false;
        isPinEnabled.value = false;

        // Supprimer le PIN stocké
        if (_prefs != null) {
          await _prefs!.remove(_keyPinHash);
        }

        await _saveSecuritySettings();

        Get.snackbar(
          'Sécurité désactivée',
          'La sécurité a été désactivée',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<bool> requireAuthentication({
    String reason = 'Authentification requise',
  }) async {
    if (!isSecurityEnabled.value) {
      return true; // Pas de sécurité activée
    }

    if (isBiometricEnabled.value && isBiometricAvailable.value) {
      return await authenticateWithBiometric(reason: reason);
    }

    if (isPinEnabled.value) {
      return await _authenticateWithPin();
    }

    return true;
  }

  Future<bool> _authenticateWithPin() async {
    // Cette méthode sera appelée par l'écran d'authentification
    // Pour l'instant, on retourne true car l'authentification PIN
    // est gérée par l'AuthScreen
    return true;
  }

  // Méthodes utilitaires
  bool get hasSecurityConfigured =>
      isPinEnabled.value || isBiometricEnabled.value;

  bool get shouldShowAuthScreen =>
      isSecurityEnabled.value && hasSecurityConfigured;

  List<BiometricType> get availableBiometrics => [];

  String get biometricTypeString {
    return 'Empreinte digitale / Face ID';
  }

  // Méthode publique pour recharger les paramètres
  Future<void> reloadSecuritySettings() async {
    await _loadSecuritySettings();
  }

  /// Vider complètement toutes les données de sécurité (utilisé lors de la déconnexion)
  Future<void> clearAllSecurityData() async {
    try {
      if (_prefs != null) {
        // Supprimer toutes les clés de sécurité
        await _prefs!.remove(_keySecurityEnabled);
        await _prefs!.remove(_keyBiometricEnabled);
        await _prefs!.remove(_keyPinEnabled);
        await _prefs!.remove(_keyPinHash);
      }

      // Remettre à zéro tous les états
      isSecurityEnabled.value = false;
      isBiometricEnabled.value = false;
      isPinEnabled.value = false;

      print('✅ Toutes les données de sécurité ont été supprimées');
    } catch (e) {
      print('❌ Erreur lors de la suppression des données de sécurité: $e');
    }
  }
}
