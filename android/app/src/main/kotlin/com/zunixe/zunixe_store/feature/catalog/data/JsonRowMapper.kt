package com.zunixe.zunixe_store.feature.catalog.data

import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.longOrNull

/** Konversi [JsonObject] Supabase → Map Dart-style (Map<String, Any?>). */
object JsonRowMapper {

    fun toRow(obj: JsonObject): Map<String, Any?> =
        obj.entries.associate { (key, value) -> key to unwrap(value) }

    private fun unwrap(value: JsonElement): Any? = when (value) {
        is JsonNull -> null
        is JsonPrimitive -> when {
            value.isString -> value.content
            else -> value.booleanOrNull
                ?: value.longOrNull
                ?: value.doubleOrNull
                ?: value.content
        }
        is JsonArray -> value.map(::unwrap)
        is JsonObject -> toRow(value)
    }
}
