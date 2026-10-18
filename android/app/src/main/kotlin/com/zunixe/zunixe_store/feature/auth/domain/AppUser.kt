package com.zunixe.zunixe_store.feature.auth.domain

/** User versi domain (terlepas dari SDK Supabase). */
data class AppUser(
    val id: String,
    val email: String? = null,
    val displayName: String = "User",
)

/** Hasil pendaftaran. */
enum class RegisterResult { LOGGED_IN, NEED_VERIFICATION, FAILED }

/** Metode login terakhir — dipakai membedakan alur email vs OAuth. */
object AuthMethod {
    const val PASSWORD = "password"
    const val OAUTH_GOOGLE = "oauth:google"
    const val OAUTH_FACEBOOK = "oauth:facebook"
}

/** Profil untuk prefill checkout. */
data class Profile(val fullName: String, val phone: String)

/** Nama tampil dari metadata/email. */
fun displayNameFrom(email: String?, metadata: Map<String, Any?>?): String {
    val meta = metadata
    val name = (meta?.get("full_name") as? String)?.takeIf { it.isNotBlank() }
        ?: (meta?.get("name") as? String)?.takeIf { it.isNotBlank() }
    if (name != null) return name.trim()
    return email?.substringBefore('@')?.takeIf { it.isNotBlank() } ?: "User"
}
