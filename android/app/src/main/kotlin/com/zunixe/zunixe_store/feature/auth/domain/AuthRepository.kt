package com.zunixe.zunixe_store.feature.auth.domain

import com.zunixe.zunixe_store.core.Result
import kotlinx.coroutines.flow.StateFlow

/** Hasil login email. */
sealed interface LoginOutcome {
    data object Success : LoginOutcome
    data class Failure(val message: String) : LoginOutcome
}

/** Kontrak operasi auth. Satu-satunya seam ke Supabase Auth. */
interface AuthRepository {
    /** User aktif saat ini (null = belum login). */
    val currentUser: AppUser?

    /** Stream perubahan sesi (login/logout/recovery). */
    val authChanges: StateFlow<AppUser?>

    suspend fun login(email: String, password: String): LoginOutcome

    suspend fun register(
        email: String,
        password: String,
        fullName: String,
        phone: String? = null,
    ): RegisterResult

    /** `true` bila browser OAuth berhasil dibuka. */
    suspend fun signInWithGoogle(): Boolean
    suspend fun signInWithFacebook(): Boolean

    suspend fun logout()
    suspend fun resetPassword(email: String): Result<Unit>
    suspend fun updatePassword(newPassword: String): Result<Unit>

    /** Profil (nama/telepon) untuk prefill checkout; null bila belum ada. */
    suspend fun getProfile(userId: String): Profile?
    suspend fun saveProfile(userId: String, fullName: String, phone: String)
}
