import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/warranty.dart';
import '../database/database_helper.dart';
import 'invoices_list_screen.dart';
import 'warranties_list_screen.dart';
import 'add_invoice_screen.dart';
import 'add_warranty_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Invoice> _recentInvoices = [];
  List<Warranty> _expiringWarranties = [];
  bool _isLoading = true;
  final GlobalKey _invoicesListKey = GlobalKey();
  final GlobalKey _warrantiesListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final invoices = await DatabaseHelper.instance.getAllInvoices();
    final warranties = await DatabaseHelper.instance.getExpiringWarranties(30);

    setState(() {
      _recentInvoices = invoices.take(5).toList();
      _expiringWarranties = warranties;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Factures & Garanties'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                _buildDashboard(),
                InvoicesListScreen(key: _invoicesListKey),
                WarrantiesListScreen(key: _warrantiesListKey),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _loadData();
          // Rafraîchir l'écran actif si nécessaire
          if (index == 1) {
            // Onglet Factures
            final invoicesState = _invoicesListKey.currentState;
            if (invoicesState != null) {
              try {
                (invoicesState as dynamic).refresh();
              } catch (e) {
                // Si la méthode n'existe pas, ignorer
              }
            }
          } else if (index == 2) {
            // Onglet Garanties
            final warrantiesState = _warrantiesListKey.currentState;
            if (warrantiesState != null) {
              try {
                (warrantiesState as dynamic).refresh();
              } catch (e) {
                // Si la méthode n'existe pas, ignorer
              }
            }
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Factures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Garanties',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? null
          : FloatingActionButton(
              onPressed: () async {
                if (_selectedIndex == 1) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddInvoiceScreen(),
                    ),
                  );
                  // Rafraîchir la liste des factures après l'ajout
                  final invoicesState = _invoicesListKey.currentState;
                  if (invoicesState != null) {
                    try {
                      (invoicesState as dynamic).refresh();
                    } catch (e) {
                      // Si la méthode n'existe pas, ignorer
                    }
                  }
                  _loadData();
                } else if (_selectedIndex == 2) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddWarrantyScreen(),
                    ),
                  );
                  // Rafraîchir la liste des garanties après l'ajout
                  final warrantiesState = _warrantiesListKey.currentState;
                  if (warrantiesState != null) {
                    try {
                      (warrantiesState as dynamic).refresh();
                    } catch (e) {
                      // Si la méthode n'existe pas, ignorer
                    }
                  }
                  _loadData();
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildExpiringWarrantiesSection(),
          const SizedBox(height: 24),
          _buildRecentInvoicesSection(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Factures',
            _recentInvoices.length.toString(),
            Icons.receipt,
            Colors.blue,
            () => setState(() => _selectedIndex = 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Garanties',
            _expiringWarranties.length.toString(),
            Icons.shield,
            Colors.orange,
            () => setState(() => _selectedIndex = 2),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpiringWarrantiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Garanties qui expirent bientôt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _expiringWarranties.isEmpty
            ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucune garantie n\'expire bientôt'),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _expiringWarranties.length > 5
                    ? 5
                    : _expiringWarranties.length,
                itemBuilder: (context, index) {
                  final warranty = _expiringWarranties[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: warranty.isExpired
                            ? Colors.red
                            : warranty.daysUntilExpiry <= 7
                                ? Colors.orange
                                : Colors.green,
                        child: const Icon(Icons.shield, color: Colors.white),
                      ),
                      title: Text(warranty.productName),
                      subtitle: Text(
                        warranty.isExpired
                            ? 'Expirée'
                            : 'Expire dans ${warranty.daysUntilExpiry} jours',
                      ),
                      trailing: Text(
                        DateFormat('dd/MM/yyyy').format(warranty.expiryDate),
                        style: TextStyle(
                          color: warranty.isExpired
                              ? Colors.red
                              : warranty.daysUntilExpiry <= 7
                                  ? Colors.orange
                                  : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildRecentInvoicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Factures récentes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _recentInvoices.isEmpty
            ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucune facture enregistrée'),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentInvoices.length,
                itemBuilder: (context, index) {
                  final invoice = _recentInvoices[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.receipt, color: Colors.white),
                      ),
                      title: Text(invoice.productName),
                      subtitle: Text(
                        invoice.storeName ?? 'Magasin non spécifié',
                      ),
                      trailing: invoice.amount != null
                          ? Text(
                              '${invoice.amount!.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
      ],
    );
  }
}

