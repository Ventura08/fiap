# Estoque Agnello — C#

Aplicação console com CRUD de produtos e persistência local em JSON usando
`System.Text.Json`, sem banco externo ou pacote NuGet.

## Pré-requisito

Instale o SDK .NET 8 ou superior.

## Execução

```bash
dotnet build
dotnet run
```

O arquivo `data/produtos.json` é criado dentro da pasta de saída da aplicação.
Cada cadastro, atualização ou exclusão é salvo imediatamente.

## Autoteste

```bash
dotnet run -- --self-test
```

O autoteste cobre cadastro, listagem, consulta, atualização, reabertura do
repositório e exclusão usando um arquivo temporário.
