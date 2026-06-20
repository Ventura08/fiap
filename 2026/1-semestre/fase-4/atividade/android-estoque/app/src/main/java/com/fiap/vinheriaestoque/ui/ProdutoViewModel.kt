package com.fiap.vinheriaestoque.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.fiap.vinheriaestoque.data.Produto
import com.fiap.vinheriaestoque.data.ProdutoRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class ProdutoViewModel(
    private val repository: ProdutoRepository,
) : ViewModel() {
    val produtos = repository.produtos.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5_000),
        initialValue = emptyList(),
    )

    fun salvar(
        form: ProdutoForm,
        produtoEmEdicao: Produto?,
        resultado: (mensagem: String, sucesso: Boolean) -> Unit,
    ) {
        val erro = ProdutoValidator.validar(form)
        if (erro != null) {
            resultado(erro, false)
            return
        }

        viewModelScope.launch {
            runCatching {
                val produto = ProdutoValidator.converter(
                    form,
                    id = produtoEmEdicao?.id ?: 0,
                )
                if (produtoEmEdicao == null) {
                    repository.cadastrar(produto)
                    "Produto cadastrado."
                } else {
                    repository.atualizar(produto)
                    "Produto atualizado."
                }
            }.onSuccess { resultado(it, true) }
                .onFailure { resultado("Não foi possível salvar o produto.", false) }
        }
    }

    fun excluir(produto: Produto, resultado: (String) -> Unit) {
        viewModelScope.launch {
            runCatching { repository.excluir(produto) }
                .onSuccess { resultado("Produto excluído.") }
                .onFailure { resultado("Não foi possível excluir o produto.") }
        }
    }

    class Factory(
        private val repository: ProdutoRepository,
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return ProdutoViewModel(repository) as T
        }
    }
}
