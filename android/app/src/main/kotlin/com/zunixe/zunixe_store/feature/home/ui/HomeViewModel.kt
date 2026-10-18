package com.zunixe.zunixe_store.feature.home.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zunixe.zunixe_store.core.valueOrNull
import com.zunixe.zunixe_store.feature.catalog.domain.Product
import com.zunixe.zunixe_store.feature.catalog.domain.ProductRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.time.Duration
import java.time.LocalDateTime
import javax.inject.Inject

/** Sisa waktu promo hingga akhir bulan. */
data class PromoCountdown(
    val days: Long = 0,
    val hours: Long = 0,
    val minutes: Long = 0,
    val seconds: Long = 0,
)

/** Hitung sisa waktu promo — fungsi murni agar dapat diuji. */
fun promoCountdown(now: LocalDateTime): PromoCountdown {
    val endOfMonth = now.toLocalDate()
        .withDayOfMonth(now.toLocalDate().lengthOfMonth())
        .plusDays(1)
        .atStartOfDay()
        .minusSeconds(1)
    val diff = Duration.between(now, endOfMonth)
    if (diff.isNegative) return PromoCountdown()
    return PromoCountdown(
        days = diff.toDays(),
        hours = diff.toHours() % 24,
        minutes = diff.toMinutes() % 60,
        seconds = diff.seconds % 60,
    )
}

/** State home. */
data class HomeUiState(
    val products: List<Product> = emptyList(),
    val loading: Boolean = true,
    val error: String? = null,
    val countdown: PromoCountdown = PromoCountdown(),
) {
    val recommendations: List<Product> get() = products.take(4)
}

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val repository: ProductRepository,
) : ViewModel() {

    private val _state = MutableStateFlow(HomeUiState())
    val state: StateFlow<HomeUiState> = _state.asStateFlow()

    init {
        loadProducts()
        startCountdown()
    }

    fun loadProducts() {
        viewModelScope.launch {
            _state.value = _state.value.copy(loading = true, error = null)
            val result = repository.getProducts(limit = 20)
            _state.value = if (result.isOk) {
                _state.value.copy(
                    products = result.valueOrNull.orEmpty(),
                    loading = false,
                )
            } else {
                _state.value.copy(
                    loading = false,
                    error = result.let {
                        (it as? com.zunixe.zunixe_store.core.Result.Err)?.failure?.message
                    } ?: "Gagal memuat produk. Periksa koneksi.",
                )
            }
        }
    }

    private fun startCountdown() {
        viewModelScope.launch {
            while (isActive) {
                _state.value = _state.value.copy(countdown = promoCountdown(LocalDateTime.now()))
                delay(1000)
            }
        }
    }
}
