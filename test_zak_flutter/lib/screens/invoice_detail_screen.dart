import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/invoice.dart';
import 'add_invoice_screen.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la facture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddInvoiceScreen(invoice: invoice),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (invoice.imagePath != null)
            Container(
              height: 300,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(invoice.imagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          _buildDetailCard(
            'Produit',
            invoice.productName,
            Icons.shopping_bag,
          ),
          if (invoice.storeName != null)
            _buildDetailCard(
              'Magasin',
              invoice.storeName!,
              Icons.store,
            ),
          if (invoice.amount != null)
            _buildDetailCard(
              'Montant',
              '${invoice.amount!.toStringAsFixed(2)} €',
              Icons.euro,
            ),
          _buildDetailCard(
            'Date d\'achat',
            DateFormat('dd/MM/yyyy').format(invoice.purchaseDate),
            Icons.calendar_today,
          ),
          if (invoice.invoiceNumber != null)
            _buildDetailCard(
              'Numéro de facture',
              invoice.invoiceNumber!,
              Icons.confirmation_number,
            ),
          if (invoice.notes != null)
            _buildDetailCard(
              'Notes',
              invoice.notes!,
              Icons.note,
            ),
          _buildDetailCard(
            'Date de création',
            DateFormat('dd/MM/yyyy HH:mm').format(invoice.createdAt),
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

