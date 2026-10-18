package com.zunixe.zunixe_store.core

/** Kegagalan domain dengan pesan siap tampil (Bahasa Indonesia). */
sealed class Failure(message: String) : Exception(message) {

    data class Network(override val message: String) : Failure(message)
    data class Server(override val message: String) : Failure(message)
    data class Auth(override val message: String) : Failure(message)
    data class Validation(override val message: String) : Failure(message)
    data class Unknown(override val message: String) : Failure(message)

    companion object {
        /**
         * Petakan exception apa pun (Supabase/IO/dll) menjadi [Failure].
         * Pesan `raise EXCEPTION` server dipertahankan.
         */
        fun from(e: Throwable, fallback: String = "Terjadi kesalahan."): Failure {
            if (e is Failure) return e

            val raw = e.message?.takeIf { it.isNotBlank() }
                ?: e.toString()
                    .removePrefix("Exception: ")
                    .removePrefix("Function call error: ")
                    .takeIf { it.isNotBlank() && it != "null" }

            if (raw == null) return Unknown(fallback)

            val lower = raw.lowercase()
            return when {
                listOf("socket", "network", "connection", "timeout", "koneksi")
                    .any { lower.contains(it) } -> Network(raw)
                else -> Server(raw)
            }
        }
    }
}
