package com.zunixe.zunixe_store.core

/**
 * Hasil operasi domain: [Ok] atau [Err] — padanan `Result<T>` versi Flutter.
 */
sealed interface Result<out T> {
    data class Ok<T>(val value: T) : Result<T>
    data class Err(val failure: Failure) : Result<Nothing>

    val isOk: Boolean get() = this is Ok
    val isErr: Boolean get() = this is Err

    fun <R> fold(onOk: (T) -> R, onErr: (Failure) -> R): R = when (this) {
        is Ok -> onOk(value)
        is Err -> onErr(failure)
    }

    fun <R> map(transform: (T) -> R): Result<R> = when (this) {
        is Ok -> Ok(transform(value))
        is Err -> this
    }

    companion object {
        fun <T> ok(value: T): Result<T> = Ok(value)
        fun <T> err(failure: Failure): Result<T> = Err(failure)
    }
}

// Akses cepat (dipakai di UI saat yakin sukses).
val <T> Result<T>.valueOrNull: T?
    get() = (this as? Result.Ok)?.value

val <T> Result<T>.failureOrNull: Failure?
    get() = (this as? Result.Err)?.failure
