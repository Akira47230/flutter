class Invoice {
  final int? id;
  final String productName;
  final String? storeName;
  final double? amount;
  final DateTime purchaseDate;
  final String? invoiceNumber;
  final String? imagePath;
  final String? notes;
  final DateTime createdAt;

  Invoice({
    this.id,
    required this.productName,
    this.storeName,
    this.amount,
    required this.purchaseDate,
    this.invoiceNumber,
    this.imagePath,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'storeName': storeName,
      'amount': amount,
      'purchaseDate': purchaseDate.toIso8601String(),
      'invoiceNumber': invoiceNumber,
      'imagePath': imagePath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as int?,
      productName: map['productName'] as String,
      storeName: map['storeName'] as String?,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      invoiceNumber: map['invoiceNumber'] as String?,
      imagePath: map['imagePath'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Invoice copyWith({
    int? id,
    String? productName,
    String? storeName,
    double? amount,
    DateTime? purchaseDate,
    String? invoiceNumber,
    String? imagePath,
    String? notes,
    DateTime? createdAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      storeName: storeName ?? this.storeName,
      amount: amount ?? this.amount,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

