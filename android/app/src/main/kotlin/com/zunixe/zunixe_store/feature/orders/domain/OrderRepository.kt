package com.zunixe.zunixe_store.feature.orders.domain

import com.zunixe.zunixe_store.core.Result

/** Kontrak data pesanan. */
interface OrderRepository {
    suspend fun placeOrder(
        shippingAddress: String,
        customerName: String? = null,
        customerPhone: String? = null,
        notes: String? = null,
        idempotencyKey: String? = null,
    ): Result<OrderConfirmation>

    suspend fun getMyOrders(userId: String): Result<List<Order>>
    suspend fun getOrder(orderId: String): Result<Order?>
    suspend fun cancelOrder(orderId: String): Result<Unit>
}
