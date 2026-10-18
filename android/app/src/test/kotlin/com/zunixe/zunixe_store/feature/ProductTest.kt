package com.zunixe.zunixe_store.feature.catalog

import com.zunixe.zunixe_store.feature.catalog.domain.Product
import com.zunixe.zunixe_store.feature.catalog.domain.ProductSort
import com.zunixe.zunixe_store.feature.catalog.domain.productFromRow
import com.zunixe.zunixe_store.feature.catalog.domain.productSortFromLabel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** Padanan `product_test.dart` + `product_sort_test.dart`. */
class ProductTest {

    // ---- discountPercent ----

    @Test
    fun `diskon nol saat originalPrice nol`() =
        assertEquals(0, Product(id = "1", name = "A", price = 100.0, originalPrice = 0.0).discountPercent)

    @Test
    fun `diskon nol saat originalPrice negatif`() =
        assertEquals(0, Product(id = "1", name = "A", price = 100.0, originalPrice = -5.0).discountPercent)

    @Test
    fun `diskon nol saat originalPrice sama dengan price`() =
        assertEquals(0, Product(id = "1", name = "A", price = 100.0, originalPrice = 100.0).discountPercent)

    @Test
    fun `diskon nol saat originalPrice lebih kecil`() =
        assertEquals(0, Product(id = "1", name = "A", price = 100.0, originalPrice = 90.0).discountPercent)

    @Test
    fun `hitung diskon 25 persen`() =
        assertEquals(25, Product(id = "1", name = "A", price = 75_000.0, originalPrice = 100_000.0).discountPercent)

    @Test
    fun `pembulatan diskon 10 persen`() =
        assertEquals(10, Product(id = "1", name = "A", price = 90.0, originalPrice = 100.0).discountPercent)

    @Test
    fun `pembulatan diskon 33 persen`() =
        assertEquals(33, Product(id = "1", name = "A", price = 2.0, originalPrice = 3.0).discountPercent)

    @Test
    fun `stok habis`() {
        assertTrue(Product(id = "1", name = "A", price = 1.0, stock = 0).stock <= 0)
        assertTrue(Product(id = "1", name = "A", price = 1.0, stock = 3).isInStock)
    }

    // ---- productFromRow ----

    @Test
    fun `parsing dasar`() {
        val product = productFromRow(
            mapOf(
                "id" to 7,
                "sku" to "SKU-7",
                "name" to "Sensor",
                "price" to 12_500,
                "original_price" to 15_000,
                "stock" to 4,
                "category" to "Sensor",
                "description" to "Deskripsi",
            ),
        )
        assertEquals("7", product.id)
        assertEquals("SKU-7", product.sku)
        assertEquals("Sensor", product.name)
        assertEquals(12_500.0, product.price, 0.001)
        assertEquals(15_000.0, product.originalPrice, 0.001)
        assertEquals(4, product.stock)
        assertEquals("Sensor", product.category)
        assertEquals("Deskripsi", product.description)
        assertEquals("", product.imageUrl)
        assertTrue(product.imageList.isEmpty())
    }

    @Test
    fun `field hilang memakai default aman`() {
        val product = productFromRow(emptyMap())
        assertEquals("", product.id)
        assertEquals("", product.name)
        assertEquals(0.0, product.price, 0.001)
        assertEquals(0, product.stock)
        assertEquals("", product.category)
        assertEquals(null, product.description)
    }

    @Test
    fun `harga string titik ribuan`() =
        assertEquals(12_500.0, productFromRow(mapOf("price" to "12.500")).price, 0.001)

    @Test
    fun `harga string dengan Rp`() =
        assertEquals(25_000.0, productFromRow(mapOf("price" to "Rp 25.000")).price, 0.001)

    @Test
    fun `harga string koma desimal`() =
        assertEquals(12.5, productFromRow(mapOf("price" to "12,500")).price, 0.001)

    @Test
    fun `harga null menjadi nol`() =
        assertEquals(0.0, productFromRow(mapOf("price" to null)).price, 0.001)

    @Test
    fun `image_urls list`() {
        val product = productFromRow(mapOf("image_urls" to listOf("a.png", "b.png", "")))
        assertEquals(listOf("a.png", "b.png"), product.imageList)
        assertEquals("a.png", product.imageUrl)
    }

    @Test
    fun `image_urls list kosong`() {
        val product = productFromRow(mapOf("image_urls" to emptyList<String>()))
        assertTrue(product.imageList.isEmpty())
        assertEquals("", product.imageUrl)
    }

    @Test
    fun `image_urls string json-ish`() {
        val product = productFromRow(mapOf("image_urls" to "[\"x.png\", \"y.png\"]"))
        assertEquals(listOf("x.png", "y.png"), product.imageList)
        assertEquals("x.png", product.imageUrl)
    }

    @Test
    fun `image_urls string tunggal`() {
        val product = productFromRow(mapOf("image_urls" to "solo.png"))
        assertEquals(listOf("solo.png"), product.imageList)
    }

    @Test
    fun `image_urls tipe lain diabaikan`() =
        assertTrue(productFromRow(mapOf("image_urls" to 42)).imageList.isEmpty())

    @Test
    fun `stok string dibulatkan`() =
        assertEquals(127, productFromRow(mapOf("stock" to "12.7")).stock)

    // ---- productSortFromLabel ----

    @Test
    fun `sort terbaru`() = assertEquals(ProductSort.NEWEST, productSortFromLabel("Terbaru"))

    @Test
    fun `sort termurah`() = assertEquals(ProductSort.CHEAPEST, productSortFromLabel("Termurah"))

    @Test
    fun `sort termahal`() = assertEquals(ProductSort.PRICIEST, productSortFromLabel("Termahal"))

    @Test
    fun `label tak dikenal jadi terbaru`() =
        assertEquals(ProductSort.NEWEST, productSortFromLabel("Terlaris"))

    @Test
    fun `label sort berisi tiga item`() {
        assertEquals(listOf("Terbaru", "Termurah", "Termahal"), com.zunixe.zunixe_store.feature.catalog.domain.productSortLabels)
    }
}
