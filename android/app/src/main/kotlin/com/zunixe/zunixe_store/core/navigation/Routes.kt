package com.zunixe.zunixe_store.core.navigation

/** Nama rute aplikasi — satu-satunya sumber kebenaran string rute. */
object Routes {
    const val HOME = "home"
    const val ABOUT = "about"
    const val PRODUCTS = "products"
    const val PRODUCT_DETAIL = "product/{productId}"
    const val CART = "cart"
    const val LOGIN = "login"
    const val REGISTER = "register"
    const val RESET_PASSWORD = "reset-password"
    const val ACCOUNT = "account"
    const val CHECKOUT = "checkout"
    const val ORDERS = "orders"
    const val ORDER_SUCCESS = "order-success/{orderCode}/{total}"
    const val CHAT = "chat"
    const val LEGAL = "legal/{slug}"

    // Pembuat path bertipe.
    fun productDetail(productId: String) = "product/$productId"
    fun orderSuccess(orderCode: String, total: Int) = "order-success/$orderCode/$total"
    fun legal(slug: String) = "legal/$slug"

    // Rute yang butuh login (dijaga guard).
    val guarded = setOf(CHECKOUT, ORDERS, ACCOUNT)
}
