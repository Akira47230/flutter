import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/warranty.dart';
import 'add_warranty_screen.dart';

class WarrantyDetailScreen extends StatelessWidget {
  final Warranty warranty;

  const WarrantyDetailScreen({super.key, required this.warranty});

  Color _getStatusColor() {
    if (warranty.isExpired) return Colors.red;
    if (warranty.daysUntilExpiry <= 7) return Colors.orange;
    if (warranty.daysUntilExpiry <= 30) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _getStatusText() {
    if (warranty.isExpired) return 'Expirée';
    if (warranty.daysUntilExpiry == 0) return 'Expire aujourd\'hui';
    if (warranty.daysUntilExpiry == 1) return 'Expire demain';
    return 'Expire dans ${warranty.daysUntilExpiry} jours';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la garantie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddWarrantyScreen(warranty: warranty),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, color: statusColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        'Expire le ${DateFormat('dd/MM/yyyy').format(warranty.expiryDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (warranty.imagePath != null)
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
                  File(warranty.imagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          _buildDetailCard(
            'Produit',
            warranty.productName,
            Icons.shopping_bag,
          ),
          if (warranty.brand != null)
            _buildDetailCard(
              'Marque',
              warranty.brand!,
              Icons.branding_watermark,
            ),
          if (warranty.storeName != null)
            _buildDetailCard(
              'Magasin',
              warranty.storeName!,
              Icons.store,
            ),
          _buildDetailCard(
            'Date d\'achat',
            DateFormat('dd/MM/yyyy').format(warranty.purchaseDate),
            Icons.calendar_today,
          ),
          _buildDetailCard(
            'Date d\'expiration',
            DateFormat('dd/MM/yyyy').format(warranty.expiryDate),
            Icons.event,
          ),
          _buildDetailCard(
            'Durée',
            '${warranty.durationMonths} mois',
            Icons.timer,
          ),
          if (warranty.warrantyNumber != null)
            _buildDetailCard(
              'Numéro de garantie',
              warranty.warrantyNumber!,
              Icons.confirmation_number,
            ),
          if (warranty.notes != null)
            _buildDetailCard(
              'Notes',
              warranty.notes!,
              Icons.note,
            ),
          _buildDetailCard(
            'Date de création',
            DateFormat('dd/MM/yyyy HH:mm').format(warranty.createdAt),
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

