package com.fiap.vinheriaestoque.data

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface ProdutoDao {
    @Query("SELECT * FROM produtos ORDER BY nome ASC")
    fun observarTodos(): Flow<List<Produto>>

    @Query("SELECT * FROM produtos WHERE id = :id LIMIT 1")
    suspend fun buscarPorId(id: Int): Produto?

    @Insert(onConflict = OnConflictStrategy.ABORT)
    suspend fun inserir(produto: Produto): Long

    @Update
    suspend fun atualizar(produto: Produto): Int

    @Delete
    suspend fun excluir(produto: Produto): Int
}
