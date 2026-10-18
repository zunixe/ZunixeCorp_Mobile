package com.zunixe.zunixe_store.feature.cart

import com.zunixe.zunixe_store.feature.cart.domain.CartItem
import com.zunixe.zunixe_store.feature.cart.ui.CartUiState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

/** Padanan `cart_item_test.dart` + logika CartUiState. */
class CartItemTest {

    @Test
    fun `parsing lengkap dengan nested stock`() {
        val item = CartItem.fromRow(
            mapOf(
                "id" to "ci1",
                "product_id" to "p1",
                "product_name" to "Sensor",
                "product_image" to "a.png",
                "price" to 12_500,
                "quantity" to 3,
                "products" to mapOf("stock" to 7),
            ),
        )
        assertEquals("ci1", item.id)
        assertEquals("p1", item.productId)
        assertEquals("Sensor", item.productName)
        assertEquals("a.png", item.productImage)
        assertEquals(12_500.0, item.price, 0.001)
        assertEquals(3, item.quantity)
        assertEquals(7, item.stock)
    }

    @Test
    fun `tanpa nested produk stok tak terbatas`() {
        val item = CartItem.fromRow(mapOf("id" to "c", "product_id" to "p", "price" to 100, "quantity" to 1))
        assertEquals(CartItem.UNLIMITED_STOCK, item.stock)
    }

    @Test
    fun `nested produk bukan map stok tak terbatas`() {
        val item = CartItem.fromRow(mapOf("id" to "c", "product_id" to "p", "products" to "oops"))
        assertEquals(CartItem.UNLIMITED_STOCK, item.stock)
    }

    @Test
    fun `quantity null default 1`() =
        assertEquals(1, CartItem.fromRow(mapOf("id" to "x", "product_id" to "p")).quantity)

    @Test
    fun `price null default 0`() =
        assertEquals(0.0, CartItem.fromRow(mapOf("id" to "x", "product_id" to "p")).price, 0.001)

    @Test
    fun `nama dan gambar null jadi string kosong`() {
        val item = CartItem.fromRow(mapOf("id" to "x", "product_id" to "p"))
        assertEquals("", item.productName)
        assertEquals("", item.productImage)
    }

    @Test
    fun `id numerik jadi string`() {
        val item = CartItem.fromRow(mapOf("id" to 99, "product_id" to 42))
        assertEquals("99", item.id)
        assertEquals("42", item.productId)
    }

    @Test
    fun `subtotal dihitung`() {
        val item = CartItem.fromRow(mapOf("id" to "x", "product_id" to "p", "price" to 1_000.0, "quantity" to 3))
        assertEquals(3_000, item.subtotal)
    }

    @Test
    fun `copyWith mengganti quantity`() {
        val item = CartItem.fromRow(mapOf("id" to "x", "product_id" to "p", "quantity" to 2))
        assertEquals(5, item.copyWith(5).quantity)
    }

    // ---- CartUiState ----

    @Test
    fun `itemCount dan totalPrice`() {
        val state = CartUiState(
            items = listOf(
                CartItem(id = "a", productId = "p1", productName = "A", productImage = "", price = 10_000.0, quantity = 2),
                CartItem(id = "b", productId = "p2", productName = "B", productImage = "", price = 5_000.0, quantity = 3),
            ),
        )
        assertEquals(5, state.itemCount)
        assertEquals(35_000, state.totalPrice)
    }

    @Test
    fun `keranjang kosong`() {
        val state = CartUiState()
        assertEquals(0, state.itemCount)
        assertEquals(0, state.totalPrice)
        assertTrue(state.items.isEmpty())
    }
}
