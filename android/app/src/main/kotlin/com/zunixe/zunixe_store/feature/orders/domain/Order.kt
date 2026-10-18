package com.zunixe.zunixe_store.feature.orders.domain

import java.time.Instant

/** Satu item pesanan. */
data class OrderItem(
    val productName: String,
    val quantity: Int,
    val price: Int,
) {
    val subtotal: Int get() = price * quantity
}

/** Pesanan milik user. */
data class Order(
    val id: String,
    val orderCode: String,
    val status: String = "pending",
    val paymentStatus: String = "unpaid",
    val total: Int = 0,
    val createdAt: Instant? = null,
    val shippingAddress: String = "",
    val customerPhone: String = "",
    val notes: String = "",
    val items: List<OrderItem> = emptyList(),
) {
    val isPaid: Boolean get() = paymentStatus == "paid"

    /** Bisa dibatalkan: belum bayar & masih pending/processing. */
    val canCancel: Boolean
        get() = !isPaid && (status == "pending" || status == "processing")

    val itemCount: Int get() = items.size

    companion object {
        fun fromRow(row: Map<String, Any?>): Order {
            val rawItems = row["order_items"]
            val items = if (rawItems is List<*>) {
                rawItems.mapNotNull { it as? Map<*, *> }.map { m ->
                    OrderItem(
                        productName = m["product_name"]?.toString() ?: "",
                        quantity = (m["quantity"] as? Number)?.toInt() ?: 0,
                        price = (m["price"] as? Number)?.toInt() ?: 0,
                    )
                }
            } else emptyList()

            return Order(
                id = row["id"]?.toString() ?: "",
                orderCode = row["order_code"]?.toString() ?: "-",
                status = row["status"]?.toString() ?: "pending",
                paymentStatus = row["payment_status"]?.toString() ?: "unpaid",
                total = (row["total"] as? Number)?.toInt() ?: 0,
                createdAt = row["created_at"]?.toString()?.let {
                    runCatching { Instant.parse(it) }.getOrNull()
                },
                shippingAddress = row["shipping_address"]?.toString() ?: "",
                customerPhone = row["customer_phone"]?.toString() ?: "",
                notes = row["notes"]?.toString() ?: "",
                items = items,
            )
        }
    }
}

/** Hasil checkout sukses. */
data class OrderConfirmation(val orderCode: String, val total: Int) {
    companion object {
        fun fromMap(map: Map<String, Any?>): OrderConfirmation = OrderConfirmation(
            orderCode = map["order_code"]?.toString() ?: "-",
            total = (map["total"] as? Number)?.toInt() ?: 0,
        )
    }
}

/** Label status pesanan (Bahasa Indonesia). */
fun orderStatusLabel(status: String): String = when (status) {
    "pending" -> "Menunggu"
    "processing" -> "Diproses"
    "shipped" -> "Dikirim"
    "completed" -> "Selesai"
    "cancelled" -> "Dibatalkan"
    else -> status
}
