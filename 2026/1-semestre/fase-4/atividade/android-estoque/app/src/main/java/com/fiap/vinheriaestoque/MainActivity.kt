package com.fiap.vinheriaestoque

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.fiap.vinheriaestoque.data.AgnelloDatabase
import com.fiap.vinheriaestoque.data.Produto
import com.fiap.vinheriaestoque.data.ProdutoRepository
import com.fiap.vinheriaestoque.ui.ProdutoForm
import com.fiap.vinheriaestoque.ui.ProdutoViewModel
import kotlinx.coroutines.launch
import java.text.NumberFormat
import java.util.Locale

private val Bordo = Color(0xFF5C0A1E)
private val Dourado = Color(0xFFC5A059)

class MainActivity : ComponentActivity() {
    private val viewModel: ProdutoViewModel by viewModels {
        ProdutoViewModel.Factory(
            ProdutoRepository(AgnelloDatabase.getInstance(this).produtoDao()),
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MaterialTheme {
                EstoqueScreen(viewModel)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun EstoqueScreen(viewModel: ProdutoViewModel) {
    val produtos by viewModel.produtos.collectAsStateWithLifecycle()
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    var produtoEmEdicao by remember { mutableStateOf<Produto?>(null) }
    var mostrarFormulario by remember { mutableStateOf(false) }
    var produtoParaExcluir by remember { mutableStateOf<Produto?>(null) }

    fun notificar(mensagem: String) {
        scope.launch { snackbar.showSnackbar(mensagem) }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbar) },
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Estoque Agnello", fontWeight = FontWeight.Bold)
                        Text(
                            "${produtos.size} produto(s) cadastrado(s)",
                            style = MaterialTheme.typography.labelMedium,
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Bordo,
                    titleContentColor = Color.White,
                ),
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                containerColor = Dourado,
                onClick = {
                    produtoEmEdicao = null
                    mostrarFormulario = true
                },
            ) {
                Text("+", style = MaterialTheme.typography.headlineMedium)
            }
        },
    ) { padding ->
        if (produtos.isEmpty()) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .padding(32.dp),
                verticalArrangement = Arrangement.Center,
            ) {
                Text("Nenhum produto cadastrado.", style = MaterialTheme.typography.headlineSmall)
                Spacer(Modifier.height(8.dp))
                Text("Use o botão + para incluir o primeiro vinho no estoque.")
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(padding)
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                item { Spacer(Modifier.height(4.dp)) }
                items(produtos, key = { it.id }) { produto ->
                    ProdutoCard(
                        produto = produto,
                        editar = {
                            produtoEmEdicao = produto
                            mostrarFormulario = true
                        },
                        excluir = { produtoParaExcluir = produto },
                    )
                }
                item { Spacer(Modifier.height(88.dp)) }
            }
        }
    }

    if (mostrarFormulario) {
        ProdutoDialog(
            produto = produtoEmEdicao,
            fechar = { mostrarFormulario = false },
            salvar = { form ->
                viewModel.salvar(form, produtoEmEdicao) { mensagem, sucesso ->
                    if (sucesso) {
                        mostrarFormulario = false
                    }
                    notificar(mensagem)
                }
            },
        )
    }

    produtoParaExcluir?.let { produto ->
        AlertDialog(
            onDismissRequest = { produtoParaExcluir = null },
            title = { Text("Excluir produto") },
            text = { Text("Deseja remover “${produto.nome}” do estoque?") },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.excluir(produto, ::notificar)
                        produtoParaExcluir = null
                    },
                ) { Text("Excluir") }
            },
            dismissButton = {
                OutlinedButton(onClick = { produtoParaExcluir = null }) {
                    Text("Cancelar")
                }
            },
        )
    }
}

@Composable
private fun ProdutoCard(
    produto: Produto,
    editar: () -> Unit,
    excluir: () -> Unit,
) {
    val moeda = remember {
        NumberFormat.getCurrencyInstance(Locale.forLanguageTag("pt-BR"))
    }
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = Color(0xFFFFFBF5)),
    ) {
        Column(Modifier.padding(16.dp)) {
            Text(produto.nome, style = MaterialTheme.typography.titleLarge, color = Bordo)
            Text("${produto.tipo} • ${produto.origem} • Safra ${produto.safra}")
            Spacer(Modifier.height(8.dp))
            Text(
                "Quantidade: ${produto.quantidade} | ${moeda.format(produto.preco)}",
                fontWeight = FontWeight.Bold,
            )
            if (produto.descricao.isNotBlank()) {
                Spacer(Modifier.height(6.dp))
                Text(produto.descricao, style = MaterialTheme.typography.bodySmall)
            }
            Spacer(Modifier.height(12.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedButton(onClick = editar) { Text("Editar") }
                OutlinedButton(onClick = excluir) { Text("Excluir") }
            }
        }
    }
}

@Composable
private fun ProdutoDialog(
    produto: Produto?,
    fechar: () -> Unit,
    salvar: (ProdutoForm) -> Unit,
) {
    var form by remember(produto) {
        mutableStateOf(produto?.let(ProdutoForm::from) ?: ProdutoForm())
    }

    AlertDialog(
        onDismissRequest = fechar,
        title = { Text(if (produto == null) "Cadastrar produto" else "Editar produto") },
        text = {
            LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                item {
                    Campo("Nome", form.nome) { form = form.copy(nome = it) }
                }
                item {
                    Campo("Tipo", form.tipo) { form = form.copy(tipo = it) }
                }
                item {
                    Campo("Safra", form.safra, KeyboardType.Number) {
                        form = form.copy(safra = it)
                    }
                }
                item {
                    Campo("Quantidade", form.quantidade, KeyboardType.Number) {
                        form = form.copy(quantidade = it)
                    }
                }
                item {
                    Campo("Preço", form.preco, KeyboardType.Decimal) {
                        form = form.copy(preco = it)
                    }
                }
                item {
                    Campo("Origem", form.origem) { form = form.copy(origem = it) }
                }
                item {
                    Campo("Descrição", form.descricao) {
                        form = form.copy(descricao = it)
                    }
                }
            }
        },
        confirmButton = {
            Button(onClick = { salvar(form) }) { Text("Salvar") }
        },
        dismissButton = {
            OutlinedButton(onClick = fechar) { Text("Cancelar") }
        },
    )
}

@Composable
private fun Campo(
    rotulo: String,
    valor: String,
    teclado: KeyboardType = KeyboardType.Text,
    alterar: (String) -> Unit,
) {
    OutlinedTextField(
        value = valor,
        onValueChange = alterar,
        label = { Text(rotulo) },
        keyboardOptions = KeyboardOptions(keyboardType = teclado),
        singleLine = rotulo != "Descrição",
        modifier = Modifier.fillMaxWidth(),
    )
}
