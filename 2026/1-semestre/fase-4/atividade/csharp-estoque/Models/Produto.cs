namespace VinheriaEstoque.Models;

public sealed class Produto
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Tipo { get; set; } = string.Empty;
    public int Safra { get; set; }
    public int Quantidade { get; set; }
    public decimal Preco { get; set; }
    public string Origem { get; set; } = string.Empty;
    public string Descricao { get; set; } = string.Empty;
}
