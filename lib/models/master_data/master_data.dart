// lib/models/master_data/master_data.dart

// Buyer / Customer
class MasterBuyer {
  final String id;
  final String name;

  MasterBuyer({required this.id, required this.name});

  factory MasterBuyer.fromJson(Map<String, dynamic> json) {
    return MasterBuyer(
      id: json['value'] as String,
      name: json['label'] as String,
    );
  }
}

// Customer PO
class MasterCustomerPo {
  final String poNumber;
  final int qtyOrder;
  final String skuId; // atau customerPo jika jadi kunci

  MasterCustomerPo({
    required this.poNumber,
    required this.qtyOrder,
    required this.skuId,
  });

  factory MasterCustomerPo.fromJson(Map<String, dynamic> json) {
    return MasterCustomerPo(
      poNumber: json['value'] as String,
      qtyOrder: json['qtyOrder'] as int? ?? 0,
      skuId: json['skuId'] as String? ?? json['customerPo'] as String? ?? '',
    );
  }
}

// SKU
class MasterSku {
  final String id;
  final String description;

  MasterSku({required this.id, required this.description});

  factory MasterSku.fromJson(Map<String, dynamic> json) {
    return MasterSku(
      id: json['value'] as String,
      description: json['label'] as String,
    );
  }

  @override
  String toString() => description;
}

// Opsional: Week & Remain Quantity (jika perlu sebagai model)
class MasterWeek {
  final String value;
  final String label;
  final String fCode;
  final List<SCode> sCodes;

  MasterWeek({
    required this.value,
    required this.label,
    required this.fCode,
    required this.sCodes,
  });

  factory MasterWeek.fromJson(Map<String, dynamic> json) {
    final sCodes = (json['s_codes'] as List?)
        ?.map((e) => SCode.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return MasterWeek(
      value: json['value'] as String,
      label: json['label'] as String,
      fCode: json['f_code'] as String,
      sCodes: sCodes,
    );
  }
}

class SCode {
  final String sCode;
  final String description;

  SCode({required this.sCode, required this.description});

  factory SCode.fromJson(Map<String, dynamic> json) {
    return SCode(
      sCode: json['s_code'] as String,
      description: json['description'] as String,
    );
  }
}