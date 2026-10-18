package com.zunixe.zunixe_store.feature.auth.data

import com.zunixe.zunixe_store.core.Failure
import com.zunixe.zunixe_store.core.Result
import com.zunixe.zunixe_store.di.SupabaseConfig
import com.zunixe.zunixe_store.feature.auth.domain.AppUser
import com.zunixe.zunixe_store.feature.auth.domain.AuthRepository
import com.zunixe.zunixe_store.feature.auth.domain.LoginOutcome
import com.zunixe.zunixe_store.feature.auth.domain.Profile
import com.zunixe.zunixe_store.feature.auth.domain.RegisterResult
import com.zunixe.zunixe_store.feature.auth.domain.displayNameFrom
import com.zunixe.zunixe_store.feature.catalog.data.JsonRowMapper
import io.github.jan.supabase.SupabaseClient
import io.github.jan.supabase.auth.auth
import io.github.jan.supabase.auth.providers.builtin.Email
import io.github.jan.supabase.auth.status.SessionStatus
import io.github.jan.supabase.postgrest.postgrest
import io.github.jan.supabase.postgrest.query.Columns
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepositoryImpl @Inject constructor(
    private val client: SupabaseClient,
) : AuthRepository {

    private val _authChanges = MutableStateFlow<AppUser?>(null)
    override val authChanges: StateFlow<AppUser?> = _authChanges.asStateFlow()

    override val currentUser: AppUser?
        get() = runCatching { client.auth.currentSessionOrNull() }
            .getOrNull()
            ?.user
            ?.let { info ->
                AppUser(
                    id = info.id,
                    email = info.email,
                    displayName = displayNameFrom(info.email, info.userMetadata),
                )
            }

    /** Dipanggil dari ViewModel untuk mulai mengamati status sesi. */
    fun observeSession(onUser: (AppUser?) -> Unit) = runCatching {
        onUser(currentUser)
    }

    override suspend fun login(email: String, password: String): LoginOutcome = try {
        client.auth.signInWith(Email) {
            this.email = email
            this.password = password
        }
        LoginOutcome.Success
    } catch (e: Exception) {
        LoginOutcome.Failure(e.message ?: "Login gagal. Periksa koneksi.")
    }

    override suspend fun register(
        email: String,
        password: String,
        fullName: String,
        phone: String?,
    ): RegisterResult = try {
        client.auth.signUpWith(Email) {
            this.email = email
            this.password = password
            data = buildJsonObject {
                put("full_name", JsonPrimitive(fullName))
                if (phone != null) put("phone", JsonPrimitive(phone))
            }
        }
        // Email confirmation ON → sesi null (belum verifikasi).
        if (client.auth.currentSessionOrNull() == null) {
            RegisterResult.NEED_VERIFICATION
        } else {
            RegisterResult.LOGGED_IN
        }
    } catch (_: Exception) {
        RegisterResult.FAILED
    }

    override suspend fun signInWithGoogle(): Boolean = signInWithOAuth(
        io.github.jan.supabase.auth.providers.Google,
    )

    override suspend fun signInWithFacebook(): Boolean = signInWithOAuth(
        io.github.jan.supabase.auth.providers.Facebook,
    )

    private suspend fun signInWithOAuth(
        provider: io.github.jan.supabase.auth.providers.OAuthProvider,
    ): Boolean = try {
        client.auth.signInWith(provider, redirectUrl = SupabaseConfig.OAUTH_REDIRECT)
        true
    } catch (_: Exception) {
        false
    }

    override suspend fun logout() {
        runCatching { client.auth.signOut() }
        _authChanges.value = null
    }

    override suspend fun resetPassword(email: String): Result<Unit> = try {
        client.auth.resetPasswordForEmail(email, redirectUrl = SupabaseConfig.OAUTH_REDIRECT)
        Result.ok(Unit)
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal mengirim email reset. Periksa koneksi."))
    }

    override suspend fun updatePassword(newPassword: String): Result<Unit> = try {
        client.auth.updateUser { password = newPassword }
        _authChanges.value = currentUser
        Result.ok(Unit)
    } catch (e: Exception) {
        Result.err(Failure.from(e, fallback = "Gagal menyimpan password. Periksa koneksi."))
    }

    override suspend fun getProfile(userId: String): Profile? = try {
        val result = client.postgrest["profiles"].select(Columns.list("full_name", "phone")) {
            filter { eq("id", userId) }
        }
        val row = result.decodeList<JsonElement>().firstOrNull()?.jsonObject
        row?.let {
            Profile(
                fullName = it["full_name"]?.jsonPrimitive?.content ?: "",
                phone = it["phone"]?.jsonPrimitive?.content ?: "",
            )
        }
    } catch (_: Exception) {
        null
    }

    override suspend fun saveProfile(userId: String, fullName: String, phone: String) {
        runCatching {
            client.postgrest["profiles"].update({
                set("full_name", fullName)
                set("phone", phone)
            }) { filter { eq("id", userId) } }
        }
    }

    /** Petakan status sesi Supabase → [AppUser] (dipakai stream observer). */
    internal fun userFromStatus(status: SessionStatus): AppUser? = when (status) {
        is SessionStatus.Authenticated -> status.session.user?.let { info ->
            AppUser(
                id = info.id,
                email = info.email,
                displayName = displayNameFrom(info.email, info.userMetadata),
            )
        }
        else -> null
    }
}
