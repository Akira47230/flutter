import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/warranty.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';

class AddWarrantyScreen extends StatefulWidget {
  final Warranty? warranty;

  const AddWarrantyScreen({super.key, this.warranty});

  @override
  State<AddWarrantyScreen> createState() => _AddWarrantyScreenState();
}

class _AddWarrantyScreenState extends State<AddWarrantyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _brandController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _warrantyNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  DateTime? _expiryDate;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.warranty != null) {
      _productNameController.text = widget.warranty!.productName;
      _brandController.text = widget.warranty!.brand ?? '';
      _storeNameController.text = widget.warranty!.storeName ?? '';
      _warrantyNumberController.text = widget.warranty!.warrantyNumber ?? '';
      _notesController.text = widget.warranty!.notes ?? '';
      _durationController.text = widget.warranty!.durationMonths.toString();
      _purchaseDate = widget.warranty!.purchaseDate;
      _expiryDate = widget.warranty!.expiryDate;
      _imagePath = widget.warranty!.imagePath;
    } else {
      _durationController.text = '24';
      _calculateExpiryDate();
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _brandController.dispose();
    _storeNameController.dispose();
    _warrantyNumberController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _calculateExpiryDate() {
    final duration = int.tryParse(_durationController.text) ?? 24;
    setState(() {
      _expiryDate = DateTime(
        _purchaseDate.year,
        _purchaseDate.month + duration,
        _purchaseDate.day,
      );
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _saveWarranty() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez calculer la date d\'expiration')),
      );
      return;
    }

    final duration = int.tryParse(_durationController.text) ?? 24;
    final warranty = Warranty(
      id: widget.warranty?.id,
      productName: _productNameController.text.trim(),
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      purchaseDate: _purchaseDate,
      expiryDate: _expiryDate!,
      durationMonths: duration,
      storeName: _storeNameController.text.trim().isEmpty
          ? null
          : _storeNameController.text.trim(),
      warrantyNumber: _warrantyNumberController.text.trim().isEmpty
          ? null
          : _warrantyNumberController.text.trim(),
      imagePath: _imagePath,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (widget.warranty == null) {
      await DatabaseHelper.instance.insertWarranty(warranty);
    } else {
      await DatabaseHelper.instance.updateWarranty(warranty);
    }

    // Planifier les notifications
    await NotificationService.instance.scheduleWarrantyNotifications();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.warranty == null
              ? 'Garantie ajoutée'
              : 'Garantie modifiée'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warranty == null
            ? 'Nouvelle garantie'
            : 'Modifier la garantie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWarranty,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_imagePath != null)
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            TextFormField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du produit *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom du produit est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(
                labelText: 'Marque',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                labelText: 'Magasin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _purchaseDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          _purchaseDate = date;
                          _calculateExpiryDate();
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date d\'achat *',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_purchaseDate),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: const InputDecoration(
                      labelText: 'Durée (mois) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateExpiryDate(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requis';
                      }
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Nombre valide requis';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 730)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) {
                  setState(() => _expiryDate = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date d\'expiration *',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _expiryDate != null
                      ? DateFormat('dd/MM/yyyy').format(_expiryDate!)
                      : 'Calculer ou sélectionner',
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculateExpiryDate,
              child: const Text('Calculer la date d\'expiration'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _warrantyNumberController,
              decoration: const InputDecoration(
                labelText: 'Numéro de garantie',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Ajouter une photo'),
            ),
          ],
        ),
      ),
    );
  }
}

