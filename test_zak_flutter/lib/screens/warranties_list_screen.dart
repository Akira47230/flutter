import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/warranty.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import 'warranty_detail_screen.dart';

class WarrantiesListScreen extends StatefulWidget {
  const WarrantiesListScreen({super.key});

  @override
  State<WarrantiesListScreen> createState() => _WarrantiesListScreenState();
}

class _WarrantiesListScreenState extends State<WarrantiesListScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Warranty> _warranties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWarranties();
  }

  // Méthode publique pour rafraîchir depuis l'extérieur
  void refresh() {
    _loadWarranties();
  }

  Future<void> _loadWarranties() async {
    setState(() => _isLoading = true);
    final warranties = await DatabaseHelper.instance.getAllWarranties();
    setState(() {
      _warranties = warranties;
      _isLoading = false;
    });
  }

  Future<void> _deleteWarranty(int id) async {
    await DatabaseHelper.instance.deleteWarranty(id);
    // Mettre à jour les notifications
    await NotificationService.instance.scheduleWarrantyNotifications();
    _loadWarranties();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Garantie supprimée')),
      );
    }
  }

  Color _getStatusColor(Warranty warranty) {
    if (warranty.isExpired) return Colors.red;
    if (warranty.daysUntilExpiry <= 7) return Colors.orange;
    if (warranty.daysUntilExpiry <= 30) return Colors.yellow[700]!;
    return Colors.green;
  }

  String _getStatusText(Warranty warranty) {
    if (warranty.isExpired) return 'Expirée';
    if (warranty.daysUntilExpiry == 0) return 'Expire aujourd\'hui';
    if (warranty.daysUntilExpiry == 1) return 'Expire demain';
    return 'Expire dans ${warranty.daysUntilExpiry} jours';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Nécessaire pour AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Garanties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _warranties.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune garantie',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Appuyez sur + pour ajouter une garantie',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadWarranties,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _warranties.length,
                    itemBuilder: (context, index) {
                      final warranty = _warranties[index];
                      final statusColor = _getStatusColor(warranty);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => _deleteWarranty(warranty.id!),
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                label: 'Supprimer',
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: statusColor,
                              child: const Icon(Icons.shield, color: Colors.white),
                            ),
                            title: Text(
                              warranty.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (warranty.brand != null)
                                  Text('Marque: ${warranty.brand}'),
                                Text(
                                  _getStatusText(warranty),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Achat: ${DateFormat('dd/MM/yyyy').format(warranty.purchaseDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(warranty.expiryDate),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Expiration',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      WarrantyDetailScreen(warranty: warranty),
                                ),
                              );
                              _loadWarranties();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

