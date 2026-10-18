package com.zunixe.zunixe_store.feature.cart.domain

import com.zunixe.zunixe_store.core.Result

/** Kontrak data keranjang (operasi tulis memakai sesi login aktif / RLS). */
interface CartRepository {
    suspend fun fetchCart(userId: String): Result<List<CartItem>>
    suspend fun addToCart(productId: String, quantity: Int = 1): Result<Unit>
    suspend fun updateQuantity(itemId: String, quantity: Int): Result<Unit>
    suspend fun removeItem(itemId: String): Result<Unit>
    suspend fun clearCart(userId: String): Result<Unit>
}
