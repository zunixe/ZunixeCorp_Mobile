package com.zunixe.zunixe_store.feature.orders

import com.zunixe.zunixe_store.feature.auth.domain.AuthMethod
import com.zunixe.zunixe_store.feature.auth.domain.displayNameFrom
import com.zunixe.zunixe_store.feature.checkout.ui.validateCheckout
import com.zunixe.zunixe_store.feature.home.ui.promoCountdown
import com.zunixe.zunixe_store.feature.orders.domain.Order
import com.zunixe.zunixe_store.feature.orders.domain.OrderConfirmation
import com.zunixe.zunixe_store.feature.orders.domain.orderStatusLabel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.LocalDateTime

/** Padanan test Order/Status/Checkout/Promo/Auth (murni). */
class OrderAndValidationTest {

    private fun orderMap(
        id: String = "o1",
        code: String = "INV-1",
        status: String = "pending",
        payment: String = "unpaid",
    ): Map<String, Any?> = mapOf(
        "id" to id,
        "order_code" to code,
        "status" to status,
        "payment_status" to payment,
        "total" to 150_000,
        "created_at" to "2024-05-01T10:30:00Z",
        "shipping_address" to "Jl. Mawar 1",
        "customer_phone" to "0812",
        "notes" to "cepat",
        "order_items" to listOf(
            mapOf("product_name" to "Sensor", "quantity" to 2, "price" to 75_000),
        ),
    )

    // ---- Order ----

    @Test
    fun `parsing order lengkap`() {
        val order = Order.fromRow(orderMap())
        assertEquals("o1", order.id)
        assertEquals("INV-1", order.orderCode)
        assertEquals("pending", order.status)
        assertEquals("unpaid", order.paymentStatus)
        assertEquals(150_000, order.total)
        assertEquals("Jl. Mawar 1", order.shippingAddress)
        assertEquals(1, order.items.size)
        assertEquals(150_000, order.items.single().subtotal)
        assertEquals(2, order.items.single().quantity)
    }

    @Test
    fun `order map kosong memakai default`() {
        val order = Order.fromRow(emptyMap())
        assertEquals("", order.id)
        assertEquals("-", order.orderCode)
        assertEquals("pending", order.status)
        assertEquals(0, order.total)
        assertNull(order.createdAt)
        assertTrue(order.items.isEmpty())
    }

    @Test
    fun `canCancel saat pending dan belum bayar`() =
        assertTrue(Order.fromRow(orderMap()).canCancel)

    @Test
    fun `tidak bisa cancel saat sudah bayar`() =
        assertFalse(Order.fromRow(orderMap(payment = "paid")).canCancel)

    @Test
    fun `tidak bisa cancel saat dikirim`() =
        assertFalse(Order.fromRow(orderMap(status = "shipped")).canCancel)

    @Test
    fun `isPaid saat payment paid`() =
        assertTrue(Order.fromRow(orderMap(status = "completed", payment = "paid")).isPaid)

    // ---- OrderConfirmation ----

    @Test
    fun `confirmation parsing`() {
        val confirmation = OrderConfirmation.fromMap(mapOf("order_code" to "INV-9", "total" to 5_000))
        assertEquals("INV-9", confirmation.orderCode)
        assertEquals(5_000, confirmation.total)
    }

    @Test
    fun `confirmation default aman`() {
        val confirmation = OrderConfirmation.fromMap(emptyMap())
        assertEquals("-", confirmation.orderCode)
        assertEquals(0, confirmation.total)
    }

    // ---- Status label ----

    @Test
    fun `label status pesanan`() {
        assertEquals("Menunggu", orderStatusLabel("pending"))
        assertEquals("Diproses", orderStatusLabel("processing"))
        assertEquals("Dikirim", orderStatusLabel("shipped"))
        assertEquals("Selesai", orderStatusLabel("completed"))
        assertEquals("Dibatalkan", orderStatusLabel("cancelled"))
        assertEquals("aneh", orderStatusLabel("aneh"))
    }

    // ---- Validasi checkout ----

    @Test
    fun `checkout valid`() =
        assertNull(validateCheckout("Budi", "0812", "Jl. Mawar 1"))

    @Test
    fun `checkout nama kosong`() =
        assertEquals("Nama wajib diisi", validateCheckout("  ", "0812", "Alamat"))

    @Test
    fun `checkout nomor kosong`() =
        assertEquals("Nomor wajib diisi", validateCheckout("Budi", "", "Alamat"))

    @Test
    fun `checkout alamat kosong`() =
        assertEquals("Alamat wajib diisi", validateCheckout("Budi", "0812", " "))

    // ---- Promo countdown ----

    @Test
    fun `countdown awal bulan`() {
        val cd = promoCountdown(LocalDateTime.of(2024, 5, 1, 0, 0, 0))
        assertEquals(30, cd.days)
        assertEquals(23, cd.hours)
        assertEquals(59, cd.minutes)
        assertEquals(59, cd.seconds)
    }

    @Test
    fun `countdown akhir bulan satu detik`() {
        val cd = promoCountdown(LocalDateTime.of(2024, 5, 31, 23, 59, 58))
        assertEquals(0, cd.days)
        assertEquals(0, cd.hours)
        assertEquals(0, cd.minutes)
        assertEquals(1, cd.seconds)
    }

    @Test
    fun `countdown tepat di akhir`() {
        val cd = promoCountdown(LocalDateTime.of(2024, 5, 31, 23, 59, 59))
        assertEquals(0, cd.days)
        assertEquals(0, cd.hours)
        assertEquals(0, cd.minutes)
        assertEquals(0, cd.seconds)
    }

    @Test
    fun `countdown februari kabisat`() =
        assertEquals(28, promoCountdown(LocalDateTime.of(2024, 2, 1, 0, 0, 0)).days)

    @Test
    fun `countdown konsisten dengan total detik`() {
        val now = LocalDateTime.of(2024, 6, 15, 12, 30, 45)
        val cd = promoCountdown(now)
        val end = LocalDateTime.of(2024, 7, 1, 0, 0, 0).minusSeconds(1)
        val total = java.time.Duration.between(now, end).seconds
        assertEquals(total, cd.days * 86400 + cd.hours * 3600 + cd.minutes * 60 + cd.seconds)
    }

    // ---- Auth displayName ----

    @Test
    fun `displayName dari full_name`() =
        assertEquals("Budi Santoso", displayNameFrom("x@y.com", mapOf("full_name" to "Budi Santoso")))

    @Test
    fun `displayName fallback name`() =
        assertEquals("Ani", displayNameFrom("x@y.com", mapOf("name" to "Ani")))

    @Test
    fun `displayName fallback prefix email`() =
        assertEquals("zunixe", displayNameFrom("zunixe@mail.com", null))

    @Test
    fun `displayName fallback User`() =
        assertEquals("User", displayNameFrom(null, null))

    @Test
    fun `displayName whitespace diabaikan`() =
        assertEquals("abc", displayNameFrom("abc@mail.com", mapOf("full_name" to "   ")))

    @Test
    fun `konstanta metode auth`() {
        assertEquals("password", AuthMethod.PASSWORD)
        assertEquals("oauth:google", AuthMethod.OAUTH_GOOGLE)
        assertEquals("oauth:facebook", AuthMethod.OAUTH_FACEBOOK)
    }
}
