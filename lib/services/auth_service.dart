import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'security_service.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Déclencher le flux d'authentification
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // L'utilisateur a annulé la connexion
      }

      // Obtenir les détails d'authentification de la demande
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer une nouvelle credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Une fois connecté, retourner le UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("------------------");
      print("Erreur de connexion: $e");

      // Filtrer l'erreur PigeonUserDetails qui n'est pas critique
      if (e.toString().contains('PigeonUserDetails')) {
        print("Erreur PigeonUserDetails ignorée (non critique)");
        // On peut essayer de vérifier si l'utilisateur est quand même connecté
        if (_auth.currentUser != null) {
          print("Utilisateur connecté malgré l'erreur PigeonUserDetails");
          return null; // Pas besoin de retourner UserCredential
        }
      } else {
        // Afficher seulement les vraies erreurs
        Get.snackbar(
          'Erreur de connexion',
          'Impossible de se connecter avec Google: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      Get.snackbar(
        'Erreur de déconnexion',
        'Impossible de se déconnecter: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Déconnexion complète avec nettoyage des données de sécurité
  Future<void> signOutCompletely() async {
    try {
      // Obtenir le SecurityService
      final securityService = Get.find<SecurityService>();

      // Vider complètement les données de sécurité
      await securityService.clearAllSecurityData();

      // Déconnexion Firebase et Google
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Rediriger vers l'écran de connexion
      Get.offAllNamed('/login');

      print('✅ Déconnexion complète effectuée');
    } catch (e) {
      print('❌ Erreur lors de la déconnexion complète: $e');
      Get.snackbar(
        'Erreur de déconnexion',
        'Impossible de se déconnecter complètement: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;
  String? get currentUserName => _auth.currentUser?.displayName;
  String? get currentUserPhoto => _auth.currentUser?.photoURL;

  bool get isLoggedIn => _auth.currentUser != null;
}
