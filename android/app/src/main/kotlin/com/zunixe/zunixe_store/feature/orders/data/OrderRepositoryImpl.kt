package com.zunixe.zunixe_store.feature.orders.data

import com.zunixe.zunixe_store.core.Failure
import com.zunixe.zunixe_store.core.Result
import com.zunixe.zunixe_store.feature.catalog.data.JsonRowMapper
import com.zunixe.zunixe_store.feature.orders.domain.Order
import com.zunixe.zunixe_store.feature.orders.domain.OrderConfirmation
import com.zunixe.zunixe_store.feature.orders.domain.OrderRepository
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.query.Columns
import io.github.jan.supabase.postgrest.query.Order as SortOrder
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.jsonObject
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class OrderRepositoryImpl @Inject constructor(
    private val client: SupabaseClient,
) : OrderRepository {

    override suspend fun placeOrder(
        shippingAddress: String,
        customerName: String?,
        customerPhone: String?,
        notes: String?,
        idempotencyKey: String?,
    ): Result<OrderConfirmation> = try {
        val params: JsonObject = buildJsonObject {
            put("p_shipping_address", JsonPrimitive(shippingAddress))
            put("p_customer_name", JsonPrimitive(customerName))
            put("p_customer_phone", JsonPrimitive(customerPhone))
            put("p_notes", JsonPrimitive(notes))
            put("p_idempotency_key", JsonPrimitive(idempotencyKey))
        }

        val result = client.postgrest.rpc("place_order", params)
        val map = result.decodeSingleOrNull()
            ?: result.decodeList<JsonElement>().firstOrNull()

        val row = map?.let { JsonRowMapper.toRow(it.jsonObject) } ?: emptyMap()
        Result.ok(OrderConfirmation.fromMap(row))
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal membuat pesanan."))
    }

    override suspend fun getMyOrders(userId: String): Result<List<Order>> = try {
        val result = client.postgrest["orders"].select(Columns.raw("*, order_items(*)")) {
            filter { eq("user_id", userId) }
            order("created_at", SortOrder.DESCENDING)
            limit(50)
        }

        val orders = result.decodeList<JsonElement>()
            .map { Order.fromRow(JsonRowMapper.toRow(it.jsonObject)) }
        Result.ok(orders)
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal memuat pesanan"))
    }

    override suspend fun getOrder(orderId: String): Result<Order?> = try {
        val result = client.postgrest["orders"].select(Columns.raw("*, order_items(*)")) {
            filter { eq("id", orderId) }
        }
        val row = result.decodeList<JsonElement>().firstOrNull()?.jsonObject
        Result.ok(row?.let { Order.fromRow(JsonRowMapper.toRow(it)) })
    } catch (_: Exception) {
        Result.ok(null)
    }

    override suspend fun cancelOrder(orderId: String): Result<Unit> = try {
        val params: JsonObject = buildJsonObject {
            put("p_order_id", JsonPrimitive(orderId))
        }
        client.postgrest.rpc("cancel_order", params)
        Result.ok(Unit)
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal membatalkan."))
    }
}

private fun io.github.jan.supabase.postgrest.result.PostgrestResult.decodeSingleOrNull(): JsonElement? =
    runCatching { decodeList<JsonElement>().firstOrNull() }.getOrNull()
