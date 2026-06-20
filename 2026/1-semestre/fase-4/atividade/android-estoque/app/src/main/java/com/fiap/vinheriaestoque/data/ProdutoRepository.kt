package com.fiap.vinheriaestoque.data

class ProdutoRepository(
    private val dao: ProdutoDao,
) {
    val produtos = dao.observarTodos()

    suspend fun cadastrar(produto: Produto) = dao.inserir(produto)

    suspend fun atualizar(produto: Produto) = dao.atualizar(produto)

    suspend fun excluir(produto: Produto) = dao.excluir(produto)
}
