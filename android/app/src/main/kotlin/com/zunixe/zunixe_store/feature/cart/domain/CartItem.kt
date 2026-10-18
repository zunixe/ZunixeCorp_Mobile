package com.zunixe.zunixe_store.feature.cart.domain

/** Satu baris keranjang. */
data class CartItem(
    val id: String,
    val productId: String,
    val productName: String,
    val productImage: String,
    val price: Double,
    val quantity: Int,
    val stock: Int = UNLIMITED_STOCK,
) {
    val subtotal: Int get() = (price * quantity).toInt()

    fun copyWith(quantity: Int) = this.copy(quantity = quantity)

    companion object {
        const val UNLIMITED_STOCK = 1 shl 30

        fun fromRow(row: Map<String, Any?>): CartItem {
            val product = row["products"]
            val stock = if (product is Map<*, *>) {
                (product["stock"] as? Number)?.toInt()
            } else null

            return CartItem(
                id = row["id"]?.toString() ?: "",
                productId = row["product_id"]?.toString() ?: "",
                productName = row["product_name"]?.toString() ?: "",
                productImage = row["product_image"]?.toString() ?: "",
                price = (row["price"] as? Number)?.toDouble() ?: 0.0,
                quantity = (row["quantity"] as? Number)?.toInt() ?: 1,
                stock = stock ?: UNLIMITED_STOCK,
            )
        }
    }
}
