using System.Globalization;
using VinheriaEstoque.Models;
using VinheriaEstoque.Repositories;
using VinheriaEstoque.Services;

namespace VinheriaEstoque;

internal static class Program
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");

    private static int Main(string[] args)
    {
        if (args.Contains("--self-test"))
        {
            return ExecutarAutoteste();
        }

        var arquivo = Path.Combine(AppContext.BaseDirectory, "data", "produtos.json");

        try
        {
            IProdutoRepository repository = new JsonProdutoRepository(arquivo);
            ExecutarMenu(repository);
            return 0;
        }
        catch (Exception exception)
        {
            Console.Error.WriteLine($"Erro ao iniciar o sistema: {exception.Message}");
            return 1;
        }
    }

    private static void ExecutarMenu(IProdutoRepository repository)
    {
        while (true)
        {
            Console.WriteLine("\n=== ESTOQUE VINHERIA AGNELLO ===");
            Console.WriteLine("1. Cadastrar produto");
            Console.WriteLine("2. Listar produtos");
            Console.WriteLine("3. Consultar produto por ID");
            Console.WriteLine("4. Atualizar produto");
            Console.WriteLine("5. Excluir produto");
            Console.WriteLine("0. Sair");
            Console.Write("Opção: ");

            switch (Console.ReadLine())
            {
                case "1":
                    Cadastrar(repository);
                    break;
                case "2":
                    Listar(repository.Listar());
                    break;
                case "3":
                    Consultar(repository);
                    break;
                case "4":
                    Atualizar(repository);
                    break;
                case "5":
                    Excluir(repository);
                    break;
                case "0":
                    Console.WriteLine("Dados salvos. Até logo.");
                    return;
                default:
                    Console.WriteLine("Opção inválida.");
                    break;
            }
        }
    }

    private static void Cadastrar(IProdutoRepository repository)
    {
        Console.WriteLine("\n--- Cadastro ---");
        var produto = LerProduto();
        var erro = ProdutoValidator.Validar(produto);
        if (erro is not null)
        {
            Console.WriteLine($"Cadastro cancelado: {erro}");
            return;
        }

        var cadastrado = repository.Cadastrar(produto);
        Console.WriteLine($"Produto cadastrado com ID {cadastrado.Id}.");
    }

    private static void Consultar(IProdutoRepository repository)
    {
        var id = LerInteiro("ID: ");
        var produto = repository.BuscarPorId(id);
        if (produto is null)
        {
            Console.WriteLine("Produto não encontrado.");
            return;
        }

        Exibir(produto);
    }

    private static void Atualizar(IProdutoRepository repository)
    {
        var id = LerInteiro("ID do produto que será atualizado: ");
        var atual = repository.BuscarPorId(id);
        if (atual is null)
        {
            Console.WriteLine("Produto não encontrado.");
            return;
        }

        Console.WriteLine("Informe os novos dados.");
        var alterado = LerProduto();
        alterado.Id = id;

        var erro = ProdutoValidator.Validar(alterado);
        if (erro is not null)
        {
            Console.WriteLine($"Atualização cancelada: {erro}");
            return;
        }

        repository.Atualizar(alterado);
        Console.WriteLine("Produto atualizado.");
    }

    private static void Excluir(IProdutoRepository repository)
    {
        var id = LerInteiro("ID do produto que será excluído: ");
        var produto = repository.BuscarPorId(id);
        if (produto is null)
        {
            Console.WriteLine("Produto não encontrado.");
            return;
        }

        Console.Write($"Confirma a exclusão de “{produto.Nome}”? (s/N): ");
        if (!string.Equals(Console.ReadLine(), "s", StringComparison.OrdinalIgnoreCase))
        {
            Console.WriteLine("Exclusão cancelada.");
            return;
        }

        repository.Excluir(id);
        Console.WriteLine("Produto excluído.");
    }

    private static Produto LerProduto() => new()
    {
        Nome = LerTexto("Nome: "),
        Tipo = LerTexto("Tipo: "),
        Safra = LerInteiro("Safra: "),
        Quantidade = LerInteiro("Quantidade: "),
        Preco = LerDecimal("Preço: "),
        Origem = LerTexto("Origem: "),
        Descricao = LerTexto("Descrição: "),
    };

    private static string LerTexto(string rotulo)
    {
        Console.Write(rotulo);
        return Console.ReadLine()?.Trim() ?? string.Empty;
    }

    private static int LerInteiro(string rotulo)
    {
        while (true)
        {
            Console.Write(rotulo);
            if (int.TryParse(Console.ReadLine(), out var valor))
            {
                return valor;
            }

            Console.WriteLine("Digite um número inteiro válido.");
        }
    }

    private static decimal LerDecimal(string rotulo)
    {
        while (true)
        {
            Console.Write(rotulo);
            var entrada = Console.ReadLine();
            if (decimal.TryParse(entrada, NumberStyles.Number, PtBr, out var valor) ||
                decimal.TryParse(entrada, NumberStyles.Number, CultureInfo.InvariantCulture, out valor))
            {
                return valor;
            }

            Console.WriteLine("Digite um preço válido, por exemplo 180,00.");
        }
    }

    private static void Listar(IReadOnlyList<Produto> produtos)
    {
        if (produtos.Count == 0)
        {
            Console.WriteLine("Nenhum produto cadastrado.");
            return;
        }

        foreach (var produto in produtos)
        {
            Exibir(produto);
        }
    }

    private static void Exibir(Produto produto)
    {
        Console.WriteLine(
            $"#{produto.Id} | {produto.Nome} | {produto.Tipo} | Safra {produto.Safra} | " +
            $"Qtd. {produto.Quantidade} | {produto.Preco.ToString("C", PtBr)} | {produto.Origem}"
        );
        if (!string.IsNullOrWhiteSpace(produto.Descricao))
        {
            Console.WriteLine($"    {produto.Descricao}");
        }
    }

    private static int ExecutarAutoteste()
    {
        var raiz = Path.Combine(Path.GetTempPath(), $"agnello-test-{Guid.NewGuid():N}");
        var arquivo = Path.Combine(raiz, "produtos.json");

        try
        {
            var repository = new JsonProdutoRepository(arquivo);
            var produto = repository.Cadastrar(new Produto
            {
                Nome = "Barolo Riserva",
                Tipo = "Tinto",
                Safra = 2019,
                Quantidade = 8,
                Preco = 290m,
                Origem = "Itália",
                Descricao = "Piemonte",
            });

            Exigir(produto.Id == 1, "cadastro e geração de ID");
            Exigir(repository.Listar().Count == 1, "listagem");

            produto.Quantidade = 5;
            Exigir(repository.Atualizar(produto), "atualização");
            Exigir(repository.BuscarPorId(1)?.Quantidade == 5, "consulta");

            var reaberto = new JsonProdutoRepository(arquivo);
            Exigir(reaberto.BuscarPorId(1)?.Nome == "Barolo Riserva", "persistência após reabrir");

            Exigir(reaberto.Excluir(1), "exclusão");
            Exigir(reaberto.Listar().Count == 0, "lista vazia após exclusão");

            Console.WriteLine("Autoteste concluído: CRUD e persistência JSON funcionando.");
            return 0;
        }
        catch (Exception exception)
        {
            Console.Error.WriteLine($"Autoteste falhou: {exception.Message}");
            return 1;
        }
        finally
        {
            if (Directory.Exists(raiz))
            {
                Directory.Delete(raiz, recursive: true);
            }
        }
    }

    private static void Exigir(bool condicao, string etapa)
    {
        if (!condicao)
        {
            throw new InvalidOperationException($"Falha na etapa: {etapa}.");
        }
    }
}
