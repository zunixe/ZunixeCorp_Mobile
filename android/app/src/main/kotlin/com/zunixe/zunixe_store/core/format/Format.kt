package com.zunixe.zunixe_store.core.format

import java.util.Locale

/**
 * Format Rupiah: 1250500 -> "Rp1.250.500".
 * Nilai negatif -> "-Rp2.500".
 */
fun formatRupiah(value: Number): String {
    val rounded = Math.round(value.toDouble())
    val negative = rounded < 0
    val digits = Math.abs(rounded).toString()

    val grouped = buildString {
        digits.forEachIndexed { index, c ->
            if (index > 0 && (digits.length - index) % 3 == 0) append('.')
            append(c)
        }
    }
    return (if (negative) "-Rp" else "Rp") + grouped
}

/** 1250500 -> "1.250.500" (tanpa prefix). */
fun formatThousands(value: Number): String =
    formatRupiah(value).removePrefix("Rp").removePrefix("-Rp").let {
        if (value.toLong() < 0) "-$it" else it
    }

/** Format tanggal pesanan: "27/9/2026 20:35". */
fun formatOrderDate(day: Int, month: Int, year: Int, hour: Int, minute: Int): String =
    String.format(Locale.US, "%d/%d/%d %02d:%02d", day, month, year, hour, minute)
