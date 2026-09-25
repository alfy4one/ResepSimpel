class Resep {
  final String nama;
  final List<String> bahan;
  final List<String> langkah;
  final String? fotoPath;

  Resep({
    required this.nama,
    required this.bahan,
    required this.langkah,
    this.fotoPath,
  });

  // Kategori logic: Sehat → Simpel → Sayuran → Protein
  String get kategori {
    final namaLower = nama.toLowerCase();
    
    // Sehat: kukus, rebus, salad
    if (namaLower.contains('kukus') || 
        namaLower.contains('rebus') || 
        namaLower.contains('salad')) {
      return 'Sehat';
    }
    
    // Simpel: goreng, orek, bacem (mudah dimasak)
    if (namaLower.contains('goreng') || 
        namaLower.contains('orek') || 
        namaLower.contains('bacem')) {
      return 'Simpel';
    }
    
    // Sayuran: tumis, lodeh, kangkung, wortel, dll
    if (namaLower.contains('tumis') || 
        namaLower.contains('lodeh') || 
        namaLower.contains('kangkung') || 
        namaLower.contains('wortel')) {
      return 'Sayuran';
    }
    
    // Protein: tempe, tahu, telur
    if (namaLower.contains('tempe') || 
        namaLower.contains('tahu') || 
        namaLower.contains('telur')) {
      return 'Protein';
    }
    
    // Default fallback
    return 'Sayuran';
  }
}
