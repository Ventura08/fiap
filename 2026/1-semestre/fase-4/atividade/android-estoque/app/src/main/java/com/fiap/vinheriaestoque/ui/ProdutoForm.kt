package com.fiap.vinheriaestoque.ui

import com.fiap.vinheriaestoque.data.Produto
import java.util.Calendar

data class ProdutoForm(
    val nome: String = "",
    val tipo: String = "",
    val safra: String = "",
    val quantidade: String = "",
    val preco: String = "",
    val origem: String = "",
    val descricao: String = "",
) {
    companion object {
        fun from(produto: Produto) = ProdutoForm(
            nome = produto.nome,
            tipo = produto.tipo,
            safra = produto.safra.toString(),
            quantidade = produto.quantidade.toString(),
            preco = "%.2f".format(produto.preco),
            origem = produto.origem,
            descricao = produto.descricao,
        )
    }
}

object ProdutoValidator {
    fun validar(
        form: ProdutoForm,
        anoAtual: Int = Calendar.getInstance().get(Calendar.YEAR),
    ): String? {
        if (form.nome.isBlank()) return "Informe o nome do produto."
        if (form.tipo.isBlank()) return "Informe o tipo do produto."

        val safra = form.safra.toIntOrNull()
            ?: return "Informe uma safra válida."
        if (safra !in 1900..anoAtual) {
            return "A safra deve estar entre 1900 e $anoAtual."
        }

        val quantidade = form.quantidade.toIntOrNull()
            ?: return "Informe uma quantidade válida."
        if (quantidade < 0) return "A quantidade não pode ser negativa."

        val preco = form.preco.replace(",", ".").toDoubleOrNull()
            ?: return "Informe um preço válido."
        if (preco <= 0) return "O preço deve ser maior que zero."

        return null
    }

    fun converter(form: ProdutoForm, id: Int = 0) = Produto(
        id = id,
        nome = form.nome.trim(),
        tipo = form.tipo.trim(),
        safra = form.safra.toInt(),
        quantidade = form.quantidade.toInt(),
        preco = form.preco.replace(",", ".").toDouble(),
        origem = form.origem.trim(),
        descricao = form.descricao.trim(),
    )
}
