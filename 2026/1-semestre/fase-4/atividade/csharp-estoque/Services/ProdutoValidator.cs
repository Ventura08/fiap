using VinheriaEstoque.Models;

namespace VinheriaEstoque.Services;

public static class ProdutoValidator
{
    public static string? Validar(Produto produto, int? anoAtual = null)
    {
        var limiteSafra = anoAtual ?? DateTime.Today.Year;

        if (string.IsNullOrWhiteSpace(produto.Nome))
        {
            return "Informe o nome do produto.";
        }

        if (string.IsNullOrWhiteSpace(produto.Tipo))
        {
            return "Informe o tipo do produto.";
        }

        if (produto.Safra < 1900 || produto.Safra > limiteSafra)
        {
            return $"A safra deve estar entre 1900 e {limiteSafra}.";
        }

        if (produto.Quantidade < 0)
        {
            return "A quantidade não pode ser negativa.";
        }

        if (produto.Preco <= 0)
        {
            return "O preço deve ser maior que zero.";
        }

        return null;
    }
}
