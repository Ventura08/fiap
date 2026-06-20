using VinheriaEstoque.Models;

namespace VinheriaEstoque.Repositories;

public interface IProdutoRepository
{
    IReadOnlyList<Produto> Listar();
    Produto? BuscarPorId(int id);
    Produto Cadastrar(Produto produto);
    bool Atualizar(Produto produto);
    bool Excluir(int id);
}
