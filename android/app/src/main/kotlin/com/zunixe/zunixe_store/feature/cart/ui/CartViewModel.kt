package com.zunixe.zunixe_store.feature.cart.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zunixe.zunixe_store.core.failureOrNull
import com.zunixe.zunixe_store.core.valueOrNull
import com.zunixe.zunixe_store.feature.auth.domain.AuthRepository
import com.zunixe.zunixe_store.feature.cart.domain.CartItem
import com.zunixe.zunixe_store.feature.cart.domain.CartRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/** State keranjang untuk UI. */
data class CartUiState(
    val items: List<CartItem> = emptyList(),
    val loading: Boolean = false,
    val error: String? = null,
    val needsLogin: Boolean = false,
) {
    val itemCount: Int get() = items.sumOf { it.quantity }
    val totalPrice: Int get() = items.sumOf { it.subtotal }
}

@HiltViewModel
class CartViewModel @Inject constructor(
    private val repository: CartRepository,
    private val authRepository: AuthRepository,
) : ViewModel() {

    private val _state = MutableStateFlow(CartUiState())
    val state: StateFlow<CartUiState> = _state.asStateFlow()

    private var lastUserId: String? = null

    init {
        // Muat keranjang mengikuti sesi login.
        viewModelScope.launch {
            authRepository.authChanges.collect { user ->
                syncUser(user?.id)
            }
            syncUser(authRepository.currentUser?.id)
        }
    }

    /** Ganti user (login/logout) → muat ulang keranjang. */
    fun syncUser(userId: String?) {
        if (userId == lastUserId) return
        lastUserId = userId
        viewModelScope.launch { fetchCart() }
    }

    suspend fun fetchCart() {
        val userId = authRepository.currentUser?.id
        if (userId == null) {
            _state.value = _state.value.copy(items = emptyList())
            return
        }
        _state.value = _state.value.copy(loading = true)
        val result = repository.fetchCart(userId)
        if (result.isOk) {
            _state.value = _state.value.copy(
                items = result.valueOrNull.orEmpty(),
                loading = false,
                error = null,
            )
        } else {
            _state.value = _state.value.copy(
                loading = false,
                error = "Gagal memuat keranjang",
            )
        }
    }

    /** Tambah ke keranjang; mengembalikan `true` bila sukses. */
    suspend fun addToCart(productId: String, quantity: Int = 1): Boolean {
        _state.value = _state.value.copy(needsLogin = false)
        if (authRepository.currentUser == null) {
            _state.value = _state.value.copy(
                error = "Silakan login terlebih dahulu",
                needsLogin = true,
            )
            return false
        }

        val result = repository.addToCart(productId, quantity)
        return if (result.isOk) {
            _state.value = _state.value.copy(error = null)
            fetchCart()
            true
        } else {
            val msg = result.failureOrNull?.message.orEmpty()
            _state.value = if (msg == "Not authenticated") {
                _state.value.copy(
                    error = "Silakan login terlebih dahulu",
                    needsLogin = true,
                )
            } else {
                _state.value.copy(error = msg)
            }
            false
        }
    }

    fun updateQuantity(itemId: String, quantity: Int) {
        viewModelScope.launch {
            val result = repository.updateQuantity(itemId, quantity)
            if (result.isOk) {
                _state.value = _state.value.copy(error = null)
                fetchCart()
            } else {
                _state.value = _state.value.copy(error = "Gagal memperbarui jumlah")
            }
        }
    }

    fun removeItem(itemId: String) {
        viewModelScope.launch {
            val result = repository.removeItem(itemId)
            if (result.isOk) {
                _state.value = _state.value.copy(
                    items = _state.value.items.filterNot { it.id == itemId },
                    error = null,
                )
            } else {
                _state.value = _state.value.copy(error = "Gagal menghapus item")
            }
        }
    }

    fun clearError() {
        _state.value = _state.value.copy(error = null)
    }
}
