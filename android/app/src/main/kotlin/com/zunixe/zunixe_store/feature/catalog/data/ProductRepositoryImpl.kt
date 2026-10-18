package com.zunixe.zunixe_store.feature.catalog.data

import com.zunixe.zunixe_store.core.Failure
import com.zunixe.zunixe_store.core.Result
import com.zunixe.zunixe_store.feature.catalog.domain.Product
import com.zunixe.zunixe_store.feature.catalog.domain.ProductRepository
import com.zunixe.zunixe_store.feature.catalog.domain.ProductSort
import com.zunixe.zunixe_store.feature.catalog.domain.productFromRow
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.query.Columns
import io.github.jan.supabase.postgrest.query.Order
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.jsonObject
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ProductRepositoryImpl @Inject constructor(
    private val client: SupabaseClient,
) : ProductRepository {

    override suspend fun getProducts(
        search: String?,
        category: String?,
        offset: Int,
        limit: Int,
        sort: ProductSort,
    ): Result<List<Product>> = try {
        val keyword = search?.trim().orEmpty()

        val result = client.postgrest["products"].select {
            filter {
                eq("is_active", true)
                gt("stock", 0)
                if (keyword.isNotEmpty()) ilike("name", "%${escapeLike(keyword)}%")
                if (!category.isNullOrEmpty()) eq("category", category)
            }
            when (sort) {
                ProductSort.CHEAPEST -> order("price", Order.ASCENDING)
                ProductSort.PRICIEST -> order("price", Order.DESCENDING)
                ProductSort.NEWEST -> order("updated_at", Order.DESCENDING)
            }
            range(offset.toLong(), (offset + limit - 1).toLong())
        }

        val rows = result.decodeList<JsonElement>()
            .map { JsonRowMapper.toRow(it.jsonObject) }
        Result.ok(rows.map(::productFromRow))
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal memuat produk. Periksa koneksi."))
    }

    override suspend fun getCategories(): Result<List<String>> = try {
        val result = client.postgrest["products"].select(Columns.list("category")) {
            filter {
                eq("is_active", true)
                gt("stock", 0)
            }
            order("category", Order.ASCENDING)
            limit(200)
        }

        val categories = result.decodeList<JsonElement>()
            .mapNotNull { it.jsonObject["category"]?.toString()?.trim()?.trim('"') }
            .filter { it.isNotEmpty() }
            .distinct()

        Result.ok(categories)
    } catch (e: Exception) {
        Result.err(Failure.Network("Gagal memuat kategori. Periksa koneksi."))
    }

    override suspend fun getProductById(id: String): Result<Product?> = try {
        val result = client.postgrest["products"].select {
            filter { eq("id", id) }
        }
        val row = result.decodeList<JsonElement>().firstOrNull()?.jsonObject
        Result.ok(row?.let { productFromRow(JsonRowMapper.toRow(it)) })
    } catch (_: Exception) {
        Result.ok(null)
    }

    /** Escape wildcard LIKE agar '%', '_' literal aman. */
    internal fun escapeLike(s: String): String = s
        .replace("\\", "\\\\")
        .replace("%", "\\%")
        .replace("_", "\\_")
}
