package com.zunixe.zunixe_store.feature.checkout.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zunixe.zunixe_store.core.failureOrNull
import com.zunixe.zunixe_store.core.valueOrNull
import com.zunixe.zunixe_store.feature.auth.domain.AuthRepository
import com.zunixe.zunixe_store.feature.orders.domain.OrderConfirmation
import com.zunixe.zunixe_store.feature.orders.domain.OrderRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject
import kotlin.random.Random

/** State checkout + form data penerima. */
data class CheckoutUiState(
    val submitting: Boolean = false,
    val error: String? = null,
)

@HiltViewModel
class CheckoutViewModel @Inject constructor(
    private val repository: OrderRepository,
    private val authRepository: AuthRepository,
) : ViewModel() {

    private val _state = MutableStateFlow(CheckoutUiState())
    val state: StateFlow<CheckoutUiState> = _state.asStateFlow()

    /** Unik per halaman checkout dibuka — retry key sama = order yang sama. */
    val idempotencyKey: String =
        "${System.currentTimeMillis()}-${Random.nextInt(1 shl 30)}"

    fun prefill(onLoaded: (String, String) -> Unit) {
        viewModelScope.launch {
            val userId = authRepository.currentUser?.id ?: return@launch
            authRepository.getProfile(userId)?.let { onLoaded(it.fullName, it.phone) }
        }
    }

    fun submit(
        name: String,
        phone: String,
        address: String,
        notes: String,
        onSuccess: (OrderConfirmation) -> Unit,
        onError: (String) -> Unit,
    ) {
        viewModelScope.launch {
            _state.value = CheckoutUiState(submitting = true)
            val result = repository.placeOrder(
                shippingAddress = address.trim(),
                customerName = name.trim(),
                customerPhone = phone.trim(),
                notes = notes.trim().ifEmpty { null },
                idempotencyKey = idempotencyKey,
            )
            _state.value = CheckoutUiState(submitting = false)

            if (result.isOk) {
                val confirmation = result.valueOrNull!!
                val userId = authRepository.currentUser?.id
                if (userId != null) {
                    authRepository.saveProfile(userId, name.trim(), phone.trim())
                }
                onSuccess(confirmation)
            } else {
                onError(result.failureOrNull?.message ?: "Gagal membuat pesanan.")
            }
        }
    }
}

/** Validasi form checkout — fungsi murni agar dapat diuji. */
fun validateCheckout(name: String, phone: String, address: String): String? = when {
    name.trim().isEmpty() -> "Nama wajib diisi"
    phone.trim().isEmpty() -> "Nomor wajib diisi"
    address.trim().isEmpty() -> "Alamat wajib diisi"
    else -> null
}
