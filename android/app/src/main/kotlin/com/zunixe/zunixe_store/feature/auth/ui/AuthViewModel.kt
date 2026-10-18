package com.zunixe.zunixe_store.feature.auth.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zunixe.zunixe_store.feature.auth.domain.AppUser
import com.zunixe.zunixe_store.feature.auth.domain.AuthMethod
import com.zunixe.zunixe_store.feature.auth.domain.AuthRepository
import com.zunixe.zunixe_store.feature.auth.domain.LoginOutcome
import com.zunixe.zunixe_store.feature.auth.domain.RegisterResult
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/** State sesi auth untuk UI. */
data class AuthUiState(
    val user: AppUser? = null,
    val loading: Boolean = false,
    val error: String? = null,
    val lastMethod: String? = null,
) {
    val isLoggedIn: Boolean get() = user != null
    val displayName: String get() = user?.displayName ?: "User"
}

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val repository: AuthRepository,
) : ViewModel() {

    private val _state = MutableStateFlow(AuthUiState(user = repository.currentUser))
    val state: StateFlow<AuthUiState> = _state.asStateFlow()

    init {
        // Ikuti perubahan sesi (login/logout/recovery dari deep link).
        viewModelScope.launch {
            repository.authChanges.collect { user ->
                if (user != null) _state.value = _state.value.copy(user = user)
            }
        }
    }

    fun login(email: String, password: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            _state.value = _state.value.copy(
                loading = true,
                error = null,
                lastMethod = AuthMethod.PASSWORD,
            )
            when (val result = repository.login(email, password)) {
                LoginOutcome.Success -> {
                    _state.value = _state.value.copy(
                        user = repository.currentUser,
                        loading = false,
                    )
                    onSuccess()
                }
                is LoginOutcome.Failure -> _state.value = _state.value.copy(
                    loading = false,
                    error = result.message,
                )
            }
        }
    }

    fun register(
        email: String,
        password: String,
        fullName: String,
        phone: String?,
        onResult: (RegisterResult) -> Unit,
    ) {
        viewModelScope.launch {
            _state.value = _state.value.copy(
                loading = true,
                error = null,
                lastMethod = AuthMethod.PASSWORD,
            )
            val result = repository.register(email, password, fullName, phone)
            _state.value = _state.value.copy(
                loading = false,
                user = repository.currentUser,
                error = if (result == RegisterResult.FAILED) "Pendaftaran gagal" else null,
            )
            onResult(result)
        }
    }

    fun signInWithGoogle(onLaunched: (Boolean) -> Unit) {
        viewModelScope.launch {
            _state.value = _state.value.copy(
                loading = true,
                error = null,
                lastMethod = AuthMethod.OAUTH_GOOGLE,
            )
            val ok = repository.signInWithGoogle()
            _state.value = _state.value.copy(
                loading = false,
                error = if (ok) null else "Login Google gagal. Tidak dapat membuka browser.",
            )
            onLaunched(ok)
        }
    }

    fun signInWithFacebook(onLaunched: (Boolean) -> Unit) {
        viewModelScope.launch {
            _state.value = _state.value.copy(
                loading = true,
                error = null,
                lastMethod = AuthMethod.OAUTH_FACEBOOK,
            )
            val ok = repository.signInWithFacebook()
            _state.value = _state.value.copy(
                loading = false,
                error = if (ok) null else "Login Facebook gagal. Tidak dapat membuka browser.",
            )
            onLaunched(ok)
        }
    }

    fun logout(onDone: () -> Unit = {}) {
        viewModelScope.launch {
            repository.logout()
            _state.value = AuthUiState()
            onDone()
        }
    }

    fun resetPassword(email: String, onDone: (Boolean, String?) -> Unit) {
        viewModelScope.launch {
            val result = repository.resetPassword(email)
            result.fold(
                onOk = { onDone(true, null) },
                onErr = { onDone(false, it.message) },
            )
        }
    }

    fun updatePassword(newPassword: String, onDone: (Boolean, String?) -> Unit) {
        viewModelScope.launch {
            val result = repository.updatePassword(newPassword)
            result.fold(
                onOk = {
                    _state.value = _state.value.copy(user = repository.currentUser)
                    onDone(true, null)
                },
                onErr = { onDone(false, it.message) },
            )
        }
    }

    fun clearError() {
        _state.value = _state.value.copy(error = null)
    }
}
