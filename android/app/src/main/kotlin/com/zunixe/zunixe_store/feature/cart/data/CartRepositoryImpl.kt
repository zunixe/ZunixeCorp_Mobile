package com.zunixe.zunixe_store.feature.cart.data

import com.zunixe.zunixe_store.core.Failure
import com.zunixe.zunixe_store.core.Result
import com.zunixe.zunixe_store.feature.cart.domain.CartItem
import com.zunixe.zunixe_store.feature.cart.domain.CartRepository
import com.zunixe.zunixe_store.feature.catalog.data.JsonRowMapper
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.query.Columns
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.jsonObject
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CartRepositoryImpl @Inject constructor(
    private val client: SupabaseClient,
) : CartRepository {

    override suspend fun fetchCart(userId: String): Result<List<CartItem>> = try {
        val result = client.postgrest["cart_items"].select(Columns.raw("*, products(stock)")) {
            filter { eq("user_id", userId) }
        }
        val items = result.decodeList<JsonElement>()
            .map { CartItem.fromRow(JsonRowMapper.toRow(it.jsonObject)) }
        Result.ok(items)
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal memuat keranjang"))
    }

    override suspend fun addToCart(productId: String, quantity: Int): Result<Unit> = try {
        val params: JsonObject = buildJsonObject {
            put("p_product_id", JsonPrimitive(productId))
            put("p_qty", JsonPrimitive(quantity))
        }
        client.postgrest.rpc("cart_add", params)
        Result.ok(Unit)
    } catch (e: Exception) {
        // Pesan server (mis. stok) sudah ramah-pengguna.
        Result.err(Failure.from(e, fallback = "Gagal menambah ke keranjang"))
    }

    override suspend fun updateQuantity(itemId: String, quantity: Int): Result<Unit> = try {
        if (quantity <= 0) {
            client.postgrest["cart_items"].delete { filter { eq("id", itemId) } }
        } else {
            client.postgrest["cart_items"].update(
                { set("quantity", quantity) },
            ) { filter { eq("id", itemId) } }
        }
        Result.ok(Unit)
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal memperbarui jumlah"))
    }

    override suspend fun removeItem(itemId: String): Result<Unit> = try {
        client.postgrest["cart_items"].delete { filter { eq("id", itemId) } }
        Result.ok(Unit)
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal menghapus item"))
    }

    override suspend fun clearCart(userId: String): Result<Unit> = try {
        client.postgrest["cart_items"].delete { filter { eq("user_id", userId) } }
        Result.ok(Unit)
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal mengosongkan keranjang"))
    }
}
