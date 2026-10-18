package com.zunixe.zunixe_store.feature.orders.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zunixe.zunixe_store.core.failureOrNull
import com.zunixe.zunixe_store.core.valueOrNull
import com.zunixe.zunixe_store.feature.auth.domain.AuthRepository
import com.zunixe.zunixe_store.feature.orders.domain.Order
import com.zunixe.zunixe_store.feature.orders.domain.OrderConfirmation
import com.zunixe.zunixe_store.feature.orders.domain.OrderRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject
import kotlin.random.Random

/** State daftar pesanan. */
data class OrdersUiState(
    val orders: List<Order> = emptyList(),
    val loading: Boolean = true,
    val error: String? = null,
)

@HiltViewModel
class OrdersViewModel @Inject constructor(
    private val repository: OrderRepository,
    private val authRepository: AuthRepository,
) : ViewModel() {

    private val _state = MutableStateFlow(OrdersUiState())
    val state: StateFlow<OrdersUiState> = _state.asStateFlow()

    init {
        reload()
    }

    fun reload() {
        viewModelScope.launch {
            val userId = authRepository.currentUser?.id
            if (userId == null) {
                _state.value = OrdersUiState(loading = false)
                return@launch
            }
            _state.value = _state.value.copy(loading = true)
            val result = repository.getMyOrders(userId)
            _state.value = if (result.isOk) {
                OrdersUiState(orders = result.valueOrNull.orEmpty(), loading = false)
            } else {
                OrdersUiState(loading = false, error = "Gagal memuat pesanan")
            }
        }
    }

    fun cancelOrder(orderId: String, onResult: (Boolean, String?) -> Unit) {
        viewModelScope.launch {
            val result = repository.cancelOrder(orderId)
            if (result.isOk) {
                reload()
                onResult(true, null)
            } else {
                onResult(false, result.failureOrNull?.message)
            }
        }
    }
}
