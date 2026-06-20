package com.fiap.vinheriaestoque.ui

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ProdutoValidatorTest {
    private val valido = ProdutoForm(
        nome = "Barolo Riserva",
        tipo = "Tinto",
        safra = "2019",
        quantidade = "8",
        preco = "290,00",
        origem = "Itália",
        descricao = "Vinho do Piemonte",
    )

    @Test
    fun `formulario valido aceita preco com virgula`() {
        assertNull(ProdutoValidator.validar(valido, anoAtual = 2026))
        assertEquals(290.0, ProdutoValidator.converter(valido).preco, 0.0)
    }

    @Test
    fun `quantidade negativa e rejeitada`() {
        val erro = ProdutoValidator.validar(
            valido.copy(quantidade = "-1"),
            anoAtual = 2026,
        )
        assertEquals("A quantidade não pode ser negativa.", erro)
    }

    @Test
    fun `safra futura e rejeitada`() {
        val erro = ProdutoValidator.validar(
            valido.copy(safra = "2027"),
            anoAtual = 2026,
        )
        assertEquals("A safra deve estar entre 1900 e 2026.", erro)
    }
}
