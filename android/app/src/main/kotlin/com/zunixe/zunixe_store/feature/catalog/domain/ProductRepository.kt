package com.zunixe.zunixe_store.feature.catalog.domain

import com.zunixe.zunixe_store.core.Result

/** Kontrak data katalog. */
interface ProductRepository {
    companion object {
        const val PAGE_SIZE = 20
    }

    suspend fun getProducts(
        search: String? = null,
        category: String? = null,
        offset: Int = 0,
        limit: Int = PAGE_SIZE,
        sort: ProductSort = ProductSort.NEWEST,
    ): Result<List<Product>>

    suspend fun getCategories(): Result<List<String>>

    /** Satu produk; `Ok(null)` bila tidak ditemukan. */
    suspend fun getProductById(id: String): Result<Product?>
}
