package com.zunixe.zunixe_store.feature.catalog.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zunixe.zunixe_store.core.failureOrNull
import com.zunixe.zunixe_store.core.valueOrNull
import com.zunixe.zunixe_store.feature.catalog.domain.Product
import com.zunixe.zunixe_store.core.failureOrNull
import com.zunixe.zunixe_store.core.valueOrNull
import com.zunixe.zunixe_store.feature.catalog.domain.ProductRepository
import com.zunixe.zunixe_store.core.failureOrNull
import com.zunixe.zunixe_store.core.valueOrNull
import com.zunixe.zunixe_store.feature.catalog.domain.ProductSort
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/** State daftar produk. */
data class ProductsUiState(
    val items: List<Product> = emptyList(),
    val categories: List<String> = emptyList(),
    val category: String = "",
    val search: String = "",
    val sortLabel: String = "Terbaru",
    val loading: Boolean = true,
    val loadingMore: Boolean = false,
    val error: String? = null,
    val hasMore: Boolean = true,
) {
    val isEmpty: Boolean get() = items.isEmpty() && !loading && error == null
}

@HiltViewModel
class ProductsViewModel @Inject constructor(
    private val repository: ProductRepository,
) : ViewModel() {

    private val _state = MutableStateFlow(ProductsUiState())
    val state: StateFlow<ProductsUiState> = _state.asStateFlow()

    init {
        reload()
        loadCategories()
    }

    fun reload() {
        viewModelScope.launch { load(reset = true) }
    }

    fun loadMore() {
        val s = _state.value
        if (s.loading || s.loadingMore || !s.hasMore || s.error != null) return
        viewModelScope.launch { load(reset = false) }
    }

    fun setCategory(category: String) {
        _state.value = _state.value.copy(category = category)
        reload()
    }

    fun setSearch(query: String) {
        _state.value = _state.value.copy(search = query.trim())
        reload()
    }

    fun setSort(label: String) {
        _state.value = _state.value.copy(sortLabel = label)
        reload()
    }

    private suspend fun load(reset: Boolean) {
        val s = _state.value
        _state.value = if (reset) {
            s.copy(loading = true, error = null, items = emptyList(), hasMore = true)
        } else {
            s.copy(loadingMore = true)
        }

        val offset = if (reset) 0 else _state.value.items.size
        val result = repository.getProducts(
            search = _state.value.search,
            category = _state.value.category.ifEmpty { null },
            offset = offset,
            sort = sortFromLabel(_state.value.sortLabel),
        )

        if (result.isOk) {
            val rows = result.valueOrNull.orEmpty()
            _state.value = _state.value.copy(
                items = if (reset) rows else _state.value.items + rows,
                hasMore = rows.size >= ProductRepository.PAGE_SIZE,
                loading = false,
                loadingMore = false,
            )
        } else {
            _state.value = _state.value.copy(
                loading = false,
                loadingMore = false,
                error = result.failureOrNull?.message ?: "Gagal memuat produk",
            )
        }
    }

    private fun loadCategories() {
        viewModelScope.launch {
            val result = repository.getCategories()
            if (result.isOk) {
                _state.value = _state.value.copy(categories = result.valueOrNull.orEmpty())
            }
        }
    }
}

/** Label dropdown → sort. Fungsi murni. */
fun sortFromLabel(label: String): ProductSort = when (label) {
    "Termurah" -> ProductSort.CHEAPEST
    "Termahal" -> ProductSort.PRICIEST
    else -> ProductSort.NEWEST
}

/** State detail produk. */
data class ProductDetailUiState(
    val product: Product? = null,
    val loading: Boolean = true,
    val notFound: Boolean = false,
    val imageIndex: Int = 0,
) {
    val gallery: List<String>
        get() = product?.imageList?.takeIf { it.isNotEmpty() }
            ?: product?.imageUrl?.takeIf { it.isNotEmpty() }?.let { listOf(it) }
            ?: emptyList()

    val currentImage: String
        get() = gallery.getOrNull(imageIndex.coerceIn(0, (gallery.size - 1).coerceAtLeast(0))) ?: ""
}

@HiltViewModel
class ProductDetailViewModel @Inject constructor(
    private val repository: ProductRepository,
) : ViewModel() {

    private val _state = MutableStateFlow(ProductDetailUiState())
    val state: StateFlow<ProductDetailUiState> = _state.asStateFlow()

    /** Muat produk dari id (deep link). */
    fun load(productId: String) {
        viewModelScope.launch {
            val result = repository.getProductById(productId)
            val product = result.valueOrNull
            _state.value = ProductDetailUiState(
                product = product,
                loading = false,
                notFound = product == null,
            )
        }
    }

    /** Pakai produk yang sudah ada (dari daftar) tanpa fetch. */
    fun setProduct(product: Product) {
        _state.value = ProductDetailUiState(product = product, loading = false)
    }

    fun selectImage(index: Int) {
        _state.value = _state.value.copy(imageIndex = index)
    }
}
