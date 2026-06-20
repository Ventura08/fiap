# Roteiro de evidências

Use dados consistentes nos dois módulos. Sugestão:

- Nome: Barolo Riserva
- Tipo: Tinto
- Safra: 2019
- Quantidade inicial: 8
- Preço: R$ 290,00
- Origem: Itália
- Descrição: Vinho do Piemonte selecionado pelo Sr. Giulio

## Android

1. **Estrutura do projeto:** Android Studio com os pacotes `data`, `ui`, a
   `MainActivity` e os testes visíveis.
2. **Dependências:** trecho do `app/build.gradle.kts` com Room, KSP e
   `room-ktx`.
3. **Entidade:** arquivo `Produto.kt` completo.
4. **DAO:** arquivo `ProdutoDao.kt` completo, mostrando Create, Read, Update e
   Delete.
5. **Banco:** arquivo `AgnelloDatabase.kt` mostrando `@Database` e o singleton.
6. **Estado inicial:** emulador exibindo “Nenhum produto cadastrado”.
7. **Create:** diálogo de cadastro preenchido antes de tocar em Salvar.
8. **Read:** lista exibindo o produto cadastrado.
9. **Update:** produto após alterar a quantidade de 8 para 5.
10. **Delete:** diálogo de confirmação de exclusão.
11. **Resultado do Delete:** lista vazia após a exclusão.
12. **Persistência:** cadastre novamente, feche o app, abra-o e fotografe o
    produto ainda presente.
13. **Testes/build:** terminal ou painel do Android Studio mostrando sucesso em
    `test` e `assembleDebug`.

## C#

14. **Estrutura do projeto:** editor mostrando `Models`, `Repositories`,
    `Services` e `Program.cs`.
15. **Modelo:** classe `Produto.cs`.
16. **Persistência:** `JsonProdutoRepository.cs`, incluindo carregar e salvar.
17. **Create e Read:** terminal após cadastrar e listar o Barolo.
18. **Update:** terminal exibindo o produto com quantidade alterada para 5.
19. **Arquivo persistido:** `produtos.json` aberto com os dados salvos.
20. **Reabertura:** nova execução do programa listando o produto anterior.
21. **Delete:** confirmação e listagem vazia após a exclusão.
22. **Build/autoteste:** terminal mostrando `dotnet build` e
    `dotnet run -- --self-test` concluídos sem erro.

## Qualidade das imagens

- Recorte somente a área relevante, mantendo nome do arquivo ou tela visível.
- Não exponha senhas, tokens, caminhos pessoais ou dados de terceiros.
- Use resolução legível e numeração igual à do relatório.
- Escreva abaixo de cada figura o que ela comprova.
- Não use imagens geradas ou simuladas como evidência de execução.
