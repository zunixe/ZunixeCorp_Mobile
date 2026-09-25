/// Urutan server (jujur: tanpa kolom sold_count tak ada 'Terlaris').
enum ProductSort { newest, cheapest, priciest }

/// Label dropdown UI → [ProductSort]. Default 'Terbaru' (newest).
const List<String> kProductSortLabels = ['Terbaru', 'Termurah', 'Termahal'];

ProductSort productSortFromLabel(String label) => switch (label) {
      'Termurah' => ProductSort.cheapest,
      'Termahal' => ProductSort.priciest,
      _ => ProductSort.newest,
    };
