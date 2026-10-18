package com.zunixe.zunixe_store.core.config

import com.zunixe.zunixe_store.core.format.formatRupiah

/**
 * Kontak & pembayaran toko — SATU sumber kebenaran.
 * Isi `bankName`/`accountNumber`/`accountHolder` agar blok rekening muncul.
 */
object StoreConfig {
    const val waNumber = "6287777711056"
    const val waDisplay = "0877-7771-1056"

    const val bankName = ""
    const val accountNumber = ""
    const val accountHolder = ""

    val hasBank: Boolean
        get() = bankName.isNotBlank() && accountNumber.isNotBlank()

    const val supportHours = "Senin - Sabtu, 08:00 - 17:00 WIB"
    const val address = "Jl. Mukodar Tengah No. 247, RT 05 RW 07, Cibeureum, Cimahi 40535"

    /** Link WA dengan pesan konfirmasi transfer terisi otomatis. */
    fun waConfirmUrl(orderCode: String, total: Int): String {
        val text = "Halo Zunixe, saya sudah transfer untuk pesanan $orderCode " +
            "sebesar ${formatRupiah(total)}. Terima kasih."
        return "https://wa.me/$waNumber?text=${encode(text)}"
    }

    /** Link WA dengan teks bebas (dipakai layar Chat). */
    fun waTextUrl(text: String): String =
        "https://wa.me/$waNumber?text=${encode(text)}"

    val waChatUrl: String get() = "https://wa.me/$waNumber"

    private fun encode(s: String): String = java.net.URLEncoder.encode(s, "UTF-8")
}
