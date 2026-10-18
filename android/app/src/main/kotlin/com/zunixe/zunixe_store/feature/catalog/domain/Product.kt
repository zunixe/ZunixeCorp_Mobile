package com.zunixe.zunixe_store.feature.catalog.domain

import kotlin.math.roundToInt

/** Produk katalog — padanan `Product` Flutter. */
data class Product(
    val id: String,
    val name: String,
    val price: Double,
    val description: String? = null,
    val originalPrice: Double = 0.0,
    val stock: Int = 0,
    val imageUrl: String = "",
    val imageList: List<String> = emptyList(),
    val category: String = "",
    val sku: String = "",
) {
    /** Persentase diskon (0 bila tak ada diskon). */
    val discountPercent: Int
        get() {
            if (originalPrice <= 0.0 || originalPrice <= price) return 0
            return ((originalPrice - price) / originalPrice * 100).roundToInt()
        }

    val isInStock: Boolean get() = stock > 0
}

/** Urutan server. */
enum class ProductSort { NEWEST, CHEAPEST, PRICIEST }

val productSortLabels = listOf("Terbaru", "Termurah", "Termahal")

fun productSortFromLabel(label: String): ProductSort = when (label) {
    "Termurah" -> ProductSort.CHEAPEST
    "Termahal" -> ProductSort.PRICIEST
    else -> ProductSort.NEWEST
}

/** Parser angka longgar: num, "12.500", "1.234,56", null → 0. */
internal fun toDoubleOrZero(value: Any?): Double = when (value) {
    is Number -> value.toDouble()
    is String -> {
        val cleaned = value
            .replace(Regex("[^0-9.,-]"), "")
            .replace(".", "")
            .replace(",", ".")
        cleaned.toDoubleOrNull() ?: 0.0
    }
    else -> 0.0
}

internal fun toIntOrZero(value: Any?): Int = toDoubleOrZero(value).roundToInt()

/**
 * Map baris tabel `products` (Supabase) → [Product].
 * `image_urls` bisa List atau String JSON-ish.
 */
fun productFromRow(row: Map<String, Any?>): Product {
    val images = parseImages(row["image_urls"])
    return Product(
        id = row["id"]?.toString() ?: "",
        sku = row["sku"]?.toString() ?: "",
        name = row["name"]?.toString() ?: "",
        price = toDoubleOrZero(row["price"]),
        originalPrice = toDoubleOrZero(row["original_price"]),
        stock = toIntOrZero(row["stock"]),
        imageUrl = images.firstOrNull() ?: "",
        imageList = images,
        category = row["category"]?.toString() ?: "",
        description = row["description"]?.toString(),
    )
}

private fun parseImages(raw: Any?): List<String> = when (raw) {
    is List<*> -> raw.mapNotNull { it?.toString()?.takeIf(String::isNotBlank) }
    is String -> raw
        .takeIf { it.isNotBlank() }
        ?.replace(Regex("^\\[|\\]$"), "")
        ?.split(',')
        ?.map { it.trim().trim('"') }
        ?.filter { it.isNotEmpty() }
        ?: emptyList()
    else -> emptyList()
}
