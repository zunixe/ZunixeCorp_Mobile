package com.zunixe.zunixe_store.core

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

/** Padanan `result_test.dart` + `errors_test.dart`. */
class ResultTest {

    @Test
    fun `ok memiliki value dan fold memilih onOk`() {
        val result = Result.ok(41)
        assertTrue(result.isOk)
        assertFalse(result.isErr)
        assertEquals(41, result.valueOrNull)
        assertEquals(42, result.fold(onOk = { it + 1 }, onErr = { -1 }))
    }

    @Test
    fun `err membawa failure dan fold memilih onErr`() {
        val result: Result<Int> = Result.err(Failure.Server("boom"))
        assertTrue(result.isErr)
        assertEquals("boom", result.failureOrNull?.message)
        assertEquals("boom", result.fold(onOk = { "ok" }, onErr = { it.message }))
    }

    @Test
    fun `map mentransformasi ok`() {
        val mapped = Result.ok(10).map { "n$it" }
        assertEquals("n10", mapped.valueOrNull)
    }

    @Test
    fun `map meneruskan err`() {
        val mapped: Result<String> = Result.err<Int>(Failure.Server("x")).map { "y" }
        assertTrue(mapped.isErr)
    }

    @Test
    fun `Failure from mengembalikan Failure apa adanya`() {
        val network = Failure.Network("putus")
        assertSame(network, Failure.from(network))
    }

    @Test
    fun `Failure from memakai pesan exception`() {
        val failure = Failure.from(Exception("Stok habis"))
        assertEquals("Stok habis", failure.message)
        assertTrue(failure is Failure.Server)
    }

    @Test
    fun `Failure from menandai kegagalan jaringan`() {
        assertTrue(Failure.from(Exception("SocketException")) is Failure.Network)
        assertTrue(Failure.from(Exception("connection timeout")) is Failure.Network)
        assertTrue(Failure.from(Exception("Periksa koneksi")) is Failure.Network)
    }

    @Test
    fun `Failure from memakai fallback saat pesan null`() {
        val failure = Failure.from(Exception())
        assertEquals("Terjadi kesalahan.", failure.message)
        assertTrue(failure is Failure.Unknown)
    }

    @Test
    fun `Failure from fallback kustom`() {
        assertEquals("Gagal.", Failure.from(Exception(), fallback = "Gagal.").message)
    }
}
