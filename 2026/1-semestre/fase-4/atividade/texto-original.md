Você é uma LLM especialista em desenvolvimento mobile, Android, persistência de dados, C#, documentação acadêmica e organização de entregáveis da FIAP.

Preciso realizar uma atividade avaliativa em equipe para o projeto da **Vinheria Agnello**. O objetivo é implementar funcionalidades de **persistência de dados** para um sistema de estoque da vinheria.

A entrega deve gerar um documento `.docx` com evidências, explicações, screenshots e códigos implementados. O arquivo final deve seguir o nome:

`NomeCompleto_RM_Fase4_Atividade.docx`

## Contexto do projeto

A Vinheria Agnello possui um sistema de estoque para controlar vinhos e produtos relacionados. Nesta fase, a atividade exige a criação de módulos de persistência de dados, tanto no app mobile quanto no servidor, aplicando conceitos de armazenamento local e CRUD.

## Objetivo principal

Criar uma solução documentada que demonstre:

1. Persistência local no Android usando a biblioteca **Room**.
2. Criação da entidade **Produto**.
3. Implementação das operações de **CRUD**:

   * Create: cadastrar produto.
   * Read: listar/consultar produtos.
   * Update: atualizar dados do produto.
   * Delete: remover produto.
4. Um módulo de persistência em **C#** para o sistema de estoque.
5. Evidências visuais e técnicas mostrando que o sistema funciona.

## Requisitos do módulo Android com Room

A solução deve explicar e/ou implementar:

* Configuração do projeto Android Studio para uso da biblioteca Room.
* Dependências necessárias no Gradle.
* Criação da entidade `Produto`.
* Criação do DAO com métodos de inserir, listar, atualizar e deletar.
* Criação do banco de dados Room.
* Integração básica com a aplicação.
* Exemplos de uso das operações CRUD.
* Screenshots mostrando:

  * Estrutura do projeto.
  * Código implementado.
  * Execução ou resultado das operações.
  * Dados sendo cadastrados/listados/alterados/removidos.

A entidade `Produto` deve representar itens do estoque da Vinheria Agnello, por exemplo:

* id
* nome
* tipo
* safra
* quantidade
* preço
* descrição ou origem

## Requisitos do módulo C#

Criar um módulo de persistência em C# para o sistema de estoque da Vinheria Agnello.

A LLM deve sugerir uma implementação simples e coerente, podendo usar:

* Classe `Produto`.
* Repositório de produtos.
* CRUD em memória, arquivo JSON, SQLite ou Entity Framework, conforme for mais adequado.
* Métodos para cadastrar, listar, atualizar e excluir produtos.
* Código comentado e organizado.

Caso exista ambiguidade entre Android Room e C#, trate como dois módulos separados da mesma entrega: um para app mobile Android e outro para persistência em C#.

## Estrutura esperada do documento

Criar o conteúdo do documento com a seguinte organização:

1. Capa

   * Nome completo dos integrantes.
   * RM dos integrantes.
   * Nome da atividade.
   * Fase.
   * Projeto: Vinheria Agnello.

2. Introdução

   * Explicar brevemente o objetivo da fase.
   * Explicar a importância da persistência de dados para um sistema de estoque.

3. Módulo Android com Room

   * Explicar o que é Room.
   * Mostrar dependências configuradas.
   * Mostrar entidade `Produto`.
   * Mostrar DAO.
   * Mostrar classe do banco de dados.
   * Mostrar exemplos das operações CRUD.
   * Inserir espaços indicados para screenshots.

4. Módulo de Persistência em C#

   * Explicar a escolha da abordagem.
   * Mostrar classe `Produto`.
   * Mostrar camada de persistência/repositório.
   * Mostrar métodos CRUD.
   * Inserir espaços indicados para screenshots.

5. Evidências

   * Indicar quais prints devem ser tirados.
   * Mostrar os resultados esperados.
   * Explicar cada evidência.

6. Conclusão

   * Resumir o que foi implementado.
   * Explicar como a solução ajuda a Vinheria Agnello a controlar o estoque.

7. Referências

   * Documentação oficial do Android Room.
   * Documentação Microsoft C#/.NET, se usada.
   * Outras referências técnicas necessárias.

## Regras importantes

* Não inventar screenshots.
* Não afirmar que algo foi executado se não houver evidência.
* Gerar código original, evitando plágio.
* Não copiar respostas prontas de outros alunos.
* Explicar o raciocínio de forma simples e objetiva.
* Adaptar o texto para linguagem acadêmica, mas sem ficar artificial.
* A entrega precisa ser clara o suficiente para o professor entender o que foi implementado.
* Incluir comentários no código quando isso ajudar na compreensão.
* Sinalizar ao aluno onde ele deve inserir prints reais do Android Studio, emulador, terminal ou Visual Studio.

## Resultado que espero da LLM

A LLM deve me ajudar a montar:

1. Um plano completo da atividade.
2. Os códigos necessários para Android Room.
3. Os códigos necessários para o módulo C#.
4. A estrutura do documento `.docx`.
5. Textos explicativos para cada seção.
6. Uma lista exata dos screenshots que preciso tirar.
7. Checklist final antes da entrega.
