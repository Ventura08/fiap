package com.fiap.vinheriaestoque.data

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ProdutoDaoTest {
    private lateinit var database: AgnelloDatabase
    private lateinit var dao: ProdutoDao

    @Before
    fun criarBanco() {
        database = Room.inMemoryDatabaseBuilder(
            ApplicationProvider.getApplicationContext(),
            AgnelloDatabase::class.java,
        ).allowMainThreadQueries().build()
        dao = database.produtoDao()
    }

    @After
    fun fecharBanco() {
        database.close()
    }

    @Test
    fun crudCompleto() = runBlocking {
        val id = dao.inserir(
            Produto(
                nome = "Malbec Reserva",
                tipo = "Tinto",
                safra = 2021,
                quantidade = 10,
                preco = 180.0,
                origem = "Argentina",
                descricao = "Mendoza",
            ),
        ).toInt()

        val cadastrado = dao.buscarPorId(id)!!
        assertEquals(10, cadastrado.quantidade)

        dao.atualizar(cadastrado.copy(quantidade = 7))
        assertEquals(7, dao.buscarPorId(id)?.quantidade)

        dao.excluir(cadastrado.copy(quantidade = 7))
        assertEquals(emptyList<Produto>(), dao.observarTodos().first())
    }
}
