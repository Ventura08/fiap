package com.fiap.vinheriaestoque.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "produtos")
data class Produto(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val nome: String,
    val tipo: String,
    val safra: Int,
    val quantidade: Int,
    val preco: Double,
    val origem: String,
    val descricao: String,
)
