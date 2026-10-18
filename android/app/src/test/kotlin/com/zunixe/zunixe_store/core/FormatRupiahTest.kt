package com.zunixe.zunixe_store.core

import com.zunixe.zunixe_store.core.format.formatRupiah
import org.junit.Assert.assertEquals
import org.junit.Test

/** Padanan `format_test.dart` (Flutter). */
class FormatRupiahTest {

    @Test
    fun `ribuan`() = assertEquals("Rp2.500", formatRupiah(2500))

    @Test
    fun `jutaan dengan pemisah benar`() = assertEquals("Rp1.250.500", formatRupiah(1_250_500))

    @Test
    fun `juta pas`() = assertEquals("Rp2.000.000", formatRupiah(2_000_000))

    @Test
    fun `di bawah seribu`() = assertEquals("Rp500", formatRupiah(500))

    @Test
    fun `nol`() = assertEquals("Rp0", formatRupiah(0))

    @Test
    fun `double dibulatkan ke atas`() = assertEquals("Rp1.000", formatRupiah(999.6))

    @Test
    fun `double dibulatkan ke bawah`() = assertEquals("Rp999", formatRupiah(999.4))

    @Test
    fun `tepat seribu`() = assertEquals("Rp1.000", formatRupiah(1000))

    @Test
    fun `puluh ribu`() = assertEquals("Rp10.000", formatRupiah(10_000))

    @Test
    fun `ratus ribu`() = assertEquals("Rp100.000", formatRupiah(100_000))

    @Test
    fun `miliar`() = assertEquals("Rp1.000.000.000", formatRupiah(1_000_000_000))

    @Test
    fun `triliun`() = assertEquals("Rp1.234.567.890.123", formatRupiah(1_234_567_890_123L))

    @Test
    fun `double utuh tanpa desimal`() = assertEquals("Rp1.250.500", formatRupiah(1_250_500.0))

    @Test
    fun `dua digit`() = assertEquals("Rp42", formatRupiah(42))

    @Test
    fun `satu digit`() = assertEquals("Rp7", formatRupiah(7))

    @Test
    fun `negatif diawali tanda minus`() = assertEquals("-Rp2.500", formatRupiah(-2500))
}
