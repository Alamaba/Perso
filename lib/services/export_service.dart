import 'dart:io';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/debt_credit_item.dart';

class ExportService extends GetxService {
  final _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FDJ',
    decimalDigits: 0,
  );

  final _dateFormat = DateFormat('dd/MM/yyyy');

  // Export en PDF
  Future<void> exportToPdf(List<DebtCreditItem> items, String type) async {
    try {
      // Créer un nouveau document PDF
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      PdfGraphics graphics = page.graphics;

      // Configuration des polices et styles
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 18,
          style: PdfFontStyle.bold);
      final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold);
      final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 10);

      // Couleurs
      final PdfColor titleColor =
          type == 'debt' ? PdfColor(244, 67, 54) : PdfColor(76, 175, 80);
      final PdfColor headerColor = PdfColor(33, 150, 243);

      double yPosition = 50;

      // Titre
      final String title = type == 'debt' ? 'Mes Dettes 🟥' : 'Mes Crédits 🟩';
      graphics.drawString(title, titleFont,
          brush: PdfSolidBrush(titleColor),
          bounds: Rect.fromLTWH(50, yPosition, 0, 0));
      yPosition += 40;

      // Date de génération
      graphics.drawString(
          'Généré le: ${_dateFormat.format(DateTime.now())}', contentFont,
          bounds: Rect.fromLTWH(50, yPosition, 0, 0));
      yPosition += 30;

      // Calcul des totaux
      double totalAmount = items.fold(0, (sum, item) => sum + item.amount);
      double paidAmount = items
          .where((item) => item.isRepaid)
          .fold(0, (sum, item) => sum + item.amount);
      double pendingAmount = totalAmount - paidAmount;

      // Résumé
      graphics.drawString('RÉSUMÉ', headerFont,
          brush: PdfSolidBrush(headerColor),
          bounds: Rect.fromLTWH(50, yPosition, 0, 0));
      yPosition += 25;

      graphics.drawString(
          'Total: ${_currencyFormat.format(totalAmount)}', contentFont,
          bounds: Rect.fromLTWH(70, yPosition, 0, 0));
      yPosition += 20;

      graphics.drawString(
          'Payé: ${_currencyFormat.format(paidAmount)}', contentFont,
          bounds: Rect.fromLTWH(70, yPosition, 0, 0));
      yPosition += 20;

      graphics.drawString(
          'En attente: ${_currencyFormat.format(pendingAmount)}', contentFont,
          bounds: Rect.fromLTWH(70, yPosition, 0, 0));
      yPosition += 30;

      // En-têtes du tableau
      graphics.drawString('DÉTAILS', headerFont,
          brush: PdfSolidBrush(headerColor),
          bounds: Rect.fromLTWH(50, yPosition, 0, 0));
      yPosition += 25;

      // Ligne d'en-tête
      graphics.drawString('Personne', headerFont,
          bounds: Rect.fromLTWH(50, yPosition, 0, 0));
      graphics.drawString('Montant', headerFont,
          bounds: Rect.fromLTWH(150, yPosition, 0, 0));
      graphics.drawString('Date', headerFont,
          bounds: Rect.fromLTWH(250, yPosition, 0, 0));
      graphics.drawString('Statut', headerFont,
          bounds: Rect.fromLTWH(350, yPosition, 0, 0));
      graphics.drawString('Notes', headerFont,
          bounds: Rect.fromLTWH(420, yPosition, 0, 0));
      yPosition += 20;

      // Ligne de séparation
      graphics.drawLine(PdfPen(PdfColor(200, 200, 200)), Offset(50, yPosition),
          Offset(550, yPosition));
      yPosition += 10;

      // Données
      for (final item in items) {
        if (yPosition > 700) {
          // Nouvelle page si nécessaire
          final PdfPage newPage = document.pages.add();
          graphics = newPage.graphics;
          yPosition = 50;
        }

        graphics.drawString(item.personName, contentFont,
            bounds: Rect.fromLTWH(50, yPosition, 0, 0));
        graphics.drawString(_currencyFormat.format(item.amount), contentFont,
            bounds: Rect.fromLTWH(150, yPosition, 0, 0));
        graphics.drawString(_dateFormat.format(item.date), contentFont,
            bounds: Rect.fromLTWH(250, yPosition, 0, 0));

        final String statusText = item.isRepaid ? 'Payé ✅' : 'En attente ⏳';
        final PdfColor statusColor =
            item.isRepaid ? PdfColor(76, 175, 80) : PdfColor(255, 152, 0);
        graphics.drawString(statusText, contentFont,
            brush: PdfSolidBrush(statusColor),
            bounds: Rect.fromLTWH(350, yPosition, 0, 0));

        final String notes = item.notes?.isNotEmpty == true ? item.notes! : '-';
        graphics.drawString(
            notes.length > 20 ? '${notes.substring(0, 20)}...' : notes,
            contentFont,
            bounds: Rect.fromLTWH(420, yPosition, 0, 0));

        yPosition += 20;
      }

      // Pied de page
      yPosition = 750;
      graphics.drawString('Généré par l\'application Gestion de Dettes',
          PdfStandardFont(PdfFontFamily.helvetica, 8),
          brush: PdfSolidBrush(PdfColor(128, 128, 128)),
          bounds: Rect.fromLTWH(50, yPosition, 0, 0));

      // Sauvegarder le document
      final List<int> bytes = await document.save();
      document.dispose();

      // Obtenir le répertoire de téléchargement
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          '${type}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = '${directory.path}/$fileName';

      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      // Partager le fichier
      await Share.shareXFiles([XFile(filePath)], text: 'Export $title');

      Get.snackbar(
        'Export réussi',
        'Le fichier PDF a été créé et partagé',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur d\'export',
        'Impossible de créer le PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Export en Excel
  Future<void> exportToExcel(List<DebtCreditItem> items, String type) async {
    try {
      // Créer un nouveau classeur Excel
      final excel = Excel.createExcel();
      final String sheetName = type == 'debt' ? 'Mes Dettes' : 'Mes Crédits';

      // Supprimer la feuille par défaut et créer la nôtre
      excel.delete('Sheet1');
      final sheet = excel[sheetName];

      // En-têtes
      sheet.cell(CellIndex.indexByString('A1')).value = 'Personne';
      sheet.cell(CellIndex.indexByString('B1')).value =
          type == 'debt' ? 'Montant dû (FDJ)' : 'Montant prêté (FDJ)';
      sheet.cell(CellIndex.indexByString('C1')).value = 'Date';
      sheet.cell(CellIndex.indexByString('D1')).value = 'Statut';
      sheet.cell(CellIndex.indexByString('E1')).value = 'Notes';

      // Données
      int row = 2;
      for (final item in items) {
        sheet.cell(CellIndex.indexByString('A$row')).value = item.personName;
        sheet.cell(CellIndex.indexByString('B$row')).value = item.amount;
        sheet.cell(CellIndex.indexByString('C$row')).value =
            _dateFormat.format(item.date);
        sheet.cell(CellIndex.indexByString('D$row')).value =
            item.isRepaid ? 'Payé' : 'En attente';
        sheet.cell(CellIndex.indexByString('E$row')).value =
            item.notes?.isNotEmpty == true ? item.notes! : '-';
        row++;
      }

      // Feuille de résumé
      final summarySheet = excel['Résumé'];

      // Titre
      summarySheet.cell(CellIndex.indexByString('A1')).value =
          type == 'debt' ? 'RÉSUMÉ - MES DETTES' : 'RÉSUMÉ - MES CRÉDITS';
      summarySheet.cell(CellIndex.indexByString('A2')).value =
          'Généré le: ${_dateFormat.format(DateTime.now())}';

      // Calculs
      double totalAmount = items.fold(0, (sum, item) => sum + item.amount);
      double paidAmount = items
          .where((item) => item.isRepaid)
          .fold(0, (sum, item) => sum + item.amount);
      double pendingAmount = totalAmount - paidAmount;

      summarySheet.cell(CellIndex.indexByString('A4')).value = 'Total:';
      summarySheet.cell(CellIndex.indexByString('B4')).value = totalAmount;

      summarySheet.cell(CellIndex.indexByString('A5')).value = 'Payé:';
      summarySheet.cell(CellIndex.indexByString('B5')).value = paidAmount;

      summarySheet.cell(CellIndex.indexByString('A6')).value = 'Balance:';
      summarySheet.cell(CellIndex.indexByString('B6')).value = pendingAmount;

      summarySheet.cell(CellIndex.indexByString('A8')).value =
          'Nombre total d\'entrées:';
      summarySheet.cell(CellIndex.indexByString('B8')).value = items.length;

      summarySheet.cell(CellIndex.indexByString('A9')).value =
          'Entrées payées:';
      summarySheet.cell(CellIndex.indexByString('B9')).value =
          items.where((item) => item.isRepaid).length;

      // Sauvegarder le fichier
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          '${type}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String filePath = '${directory.path}/$fileName';

      final List<int>? bytes = excel.save();
      if (bytes != null) {
        final File file = File(filePath);
        await file.writeAsBytes(bytes);

        // Partager le fichier
        await Share.shareXFiles([XFile(filePath)],
            text: 'Export ${type == 'debt' ? 'Dettes' : 'Crédits'}');

        Get.snackbar(
          'Export réussi',
          'Le fichier Excel a été créé et partagé',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception('Impossible de sauvegarder le fichier Excel');
      }
    } catch (e) {
      Get.snackbar(
        'Erreur d\'export',
        'Impossible de créer le fichier Excel: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Export combiné (dettes + crédits)
  Future<void> exportCombined(
      List<DebtCreditItem> debts, List<DebtCreditItem> credits) async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1');

      // Feuille des dettes
      final debtSheet = excel['Mes Dettes'];
      _fillSheet(debtSheet, debts, 'debt');

      // Feuille des crédits
      final creditSheet = excel['Mes Crédits'];
      _fillSheet(creditSheet, credits, 'credit');

      // Feuille de résumé global
      final summarySheet = excel['Résumé Global'];
      _fillSummarySheet(summarySheet, debts, credits);

      // Sauvegarder
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'rapport_complet_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final String filePath = '${directory.path}/$fileName';

      final List<int>? bytes = excel.save();
      if (bytes != null) {
        final File file = File(filePath);
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([XFile(filePath)],
            text: 'Rapport complet - Dettes et Crédits');

        Get.snackbar(
          'Export réussi',
          'Le rapport complet a été créé et partagé',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur d\'export',
        'Impossible de créer le rapport: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _fillSheet(Sheet sheet, List<DebtCreditItem> items, String type) {
    // En-têtes
    sheet.cell(CellIndex.indexByString('A1')).value = 'Personne';
    sheet.cell(CellIndex.indexByString('B1')).value = 'Montant (FDJ)';
    sheet.cell(CellIndex.indexByString('C1')).value = 'Date';
    sheet.cell(CellIndex.indexByString('D1')).value = 'Statut';
    sheet.cell(CellIndex.indexByString('E1')).value = 'Notes';

    // Données
    int row = 2;
    for (final item in items) {
      sheet.cell(CellIndex.indexByString('A$row')).value = item.personName;
      sheet.cell(CellIndex.indexByString('B$row')).value = item.amount;
      sheet.cell(CellIndex.indexByString('C$row')).value =
          _dateFormat.format(item.date);
      sheet.cell(CellIndex.indexByString('D$row')).value =
          item.isRepaid ? 'Payé' : 'En attente';
      sheet.cell(CellIndex.indexByString('E$row')).value =
          item.notes?.isNotEmpty == true ? item.notes! : '-';
      row++;
    }
  }

  void _fillSummarySheet(
      Sheet sheet, List<DebtCreditItem> debts, List<DebtCreditItem> credits) {
    sheet.cell(CellIndex.indexByString('A1')).value =
        'RAPPORT COMPLET - DETTES ET CRÉDITS';
    sheet.cell(CellIndex.indexByString('A2')).value =
        'Généré le: ${_dateFormat.format(DateTime.now())}';

    // Résumé des dettes
    double totalDebts = debts.fold(0, (sum, item) => sum + item.amount);
    double paidDebts = debts
        .where((item) => item.isRepaid)
        .fold(0, (sum, item) => sum + item.amount);

    sheet.cell(CellIndex.indexByString('A4')).value = 'DETTES:';
    sheet.cell(CellIndex.indexByString('A5')).value = 'Total dettes:';
    sheet.cell(CellIndex.indexByString('B5')).value = totalDebts;
    sheet.cell(CellIndex.indexByString('A6')).value = 'Dettes payées:';
    sheet.cell(CellIndex.indexByString('B6')).value = paidDebts;
    sheet.cell(CellIndex.indexByString('A7')).value = 'Dettes restantes:';
    sheet.cell(CellIndex.indexByString('B7')).value = totalDebts - paidDebts;

    // Résumé des crédits
    double totalCredits = credits.fold(0, (sum, item) => sum + item.amount);
    double paidCredits = credits
        .where((item) => item.isRepaid)
        .fold(0, (sum, item) => sum + item.amount);

    sheet.cell(CellIndex.indexByString('A9')).value = 'CRÉDITS:';
    sheet.cell(CellIndex.indexByString('A10')).value = 'Total crédits:';
    sheet.cell(CellIndex.indexByString('B10')).value = totalCredits;
    sheet.cell(CellIndex.indexByString('A11')).value = 'Crédits remboursés:';
    sheet.cell(CellIndex.indexByString('B11')).value = paidCredits;
    sheet.cell(CellIndex.indexByString('A12')).value = 'Crédits en attente:';
    sheet.cell(CellIndex.indexByString('B12')).value =
        totalCredits - paidCredits;

    // Balance globale
    double balance = totalCredits - totalDebts;
    sheet.cell(CellIndex.indexByString('A14')).value = 'BALANCE GLOBALE:';
    sheet.cell(CellIndex.indexByString('B14')).value = balance;
    sheet.cell(CellIndex.indexByString('C14')).value =
        balance >= 0 ? 'Positif ✅' : 'Négatif ❌';
  }
}
