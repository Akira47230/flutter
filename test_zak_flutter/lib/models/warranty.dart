class Warranty {
  final int? id;
  final String productName;
  final String? brand;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final int durationMonths;
  final String? storeName;
  final String? warrantyNumber;
  final String? imagePath;
  final String? notes;
  final DateTime createdAt;
  final bool isExpired;
  final int daysUntilExpiry;

  Warranty({
    this.id,
    required this.productName,
    this.brand,
    required this.purchaseDate,
    required this.expiryDate,
    required this.durationMonths,
    this.storeName,
    this.warrantyNumber,
    this.imagePath,
    this.notes,
    DateTime? createdAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        isExpired = expiryDate.isBefore(DateTime.now()),
        daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'brand': brand,
      'purchaseDate': purchaseDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'durationMonths': durationMonths,
      'storeName': storeName,
      'warrantyNumber': warrantyNumber,
      'imagePath': imagePath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Warranty.fromMap(Map<String, dynamic> map) {
    final purchaseDate = DateTime.parse(map['purchaseDate'] as String);
    final expiryDate = DateTime.parse(map['expiryDate'] as String);

    return Warranty(
      id: map['id'] as int?,
      productName: map['productName'] as String,
      brand: map['brand'] as String?,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      durationMonths: map['durationMonths'] as int,
      storeName: map['storeName'] as String?,
      warrantyNumber: map['warrantyNumber'] as String?,
      imagePath: map['imagePath'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Warranty copyWith({
    int? id,
    String? productName,
    String? brand,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    int? durationMonths,
    String? storeName,
    String? warrantyNumber,
    String? imagePath,
    String? notes,
    DateTime? createdAt,
  }) {
    return Warranty(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      durationMonths: durationMonths ?? this.durationMonths,
      storeName: storeName ?? this.storeName,
      warrantyNumber: warrantyNumber ?? this.warrantyNumber,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

