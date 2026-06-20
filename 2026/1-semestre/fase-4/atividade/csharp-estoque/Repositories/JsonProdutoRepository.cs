using System.Text.Json;
using VinheriaEstoque.Models;

namespace VinheriaEstoque.Repositories;

public sealed class JsonProdutoRepository : IProdutoRepository
{
    private readonly string _arquivo;
    private readonly JsonSerializerOptions _opcoes = new()
    {
        WriteIndented = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    };
    private List<Produto> _produtos;

    public JsonProdutoRepository(string arquivo)
    {
        _arquivo = arquivo;
        _produtos = Carregar();
    }

    public IReadOnlyList<Produto> Listar() =>
        _produtos
            .OrderBy(produto => produto.Nome)
            .Select(Copiar)
            .ToList();

    public Produto? BuscarPorId(int id)
    {
        var produto = _produtos.FirstOrDefault(item => item.Id == id);
        return produto is null ? null : Copiar(produto);
    }

    public Produto Cadastrar(Produto produto)
    {
        var novoProduto = Copiar(produto);
        novoProduto.Id = _produtos.Count == 0 ? 1 : _produtos.Max(item => item.Id) + 1;
        _produtos.Add(novoProduto);
        Salvar();
        return Copiar(novoProduto);
    }

    public bool Atualizar(Produto produto)
    {
        var indice = _produtos.FindIndex(item => item.Id == produto.Id);
        if (indice < 0)
        {
            return false;
        }

        _produtos[indice] = Copiar(produto);
        Salvar();
        return true;
    }

    public bool Excluir(int id)
    {
        var removidos = _produtos.RemoveAll(item => item.Id == id);
        if (removidos == 0)
        {
            return false;
        }

        Salvar();
        return true;
    }

    private List<Produto> Carregar()
    {
        var diretorio = Path.GetDirectoryName(_arquivo);
        if (!string.IsNullOrWhiteSpace(diretorio))
        {
            Directory.CreateDirectory(diretorio);
        }

        if (!File.Exists(_arquivo))
        {
            File.WriteAllText(_arquivo, "[]");
            return [];
        }

        var conteudo = File.ReadAllText(_arquivo);
        if (string.IsNullOrWhiteSpace(conteudo))
        {
            return [];
        }

        try
        {
            return JsonSerializer.Deserialize<List<Produto>>(conteudo, _opcoes) ?? [];
        }
        catch (JsonException exception)
        {
            throw new InvalidDataException(
                $"O arquivo de dados '{_arquivo}' contém JSON inválido.",
                exception
            );
        }
    }

    private void Salvar()
    {
        var json = JsonSerializer.Serialize(_produtos, _opcoes);
        var temporario = $"{_arquivo}.tmp";
        File.WriteAllText(temporario, json);
        File.Move(temporario, _arquivo, overwrite: true);
    }

    private static Produto Copiar(Produto produto) => new()
    {
        Id = produto.Id,
        Nome = produto.Nome,
        Tipo = produto.Tipo,
        Safra = produto.Safra,
        Quantidade = produto.Quantidade,
        Preco = produto.Preco,
        Origem = produto.Origem,
        Descricao = produto.Descricao,
    };
}
