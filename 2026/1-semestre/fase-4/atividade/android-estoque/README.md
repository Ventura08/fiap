# Estoque Agnello — Android

Aplicativo Android independente para demonstrar persistência local com Room e
operações CRUD de produtos da Vinheria Agnello.

## Execução

Abra esta pasta no Android Studio e execute o módulo `app` em um emulador.

Pelo terminal:

```bash
chmod +x gradlew
./gradlew test
./gradlew assembleDebug
./gradlew connectedAndroidTest
```

O script `gradlew` reutiliza o Gradle Wrapper já versionado no projeto Android
da fase 1, evitando duplicar o arquivo binário do wrapper.

## Arquitetura

- `data/Produto.kt`: entidade Room.
- `data/ProdutoDao.kt`: operações CRUD.
- `data/AgnelloDatabase.kt`: banco local singleton.
- `data/ProdutoRepository.kt`: acesso ao DAO.
- `ui/ProdutoViewModel.kt`: estado e operações assíncronas.
- `MainActivity.kt`: interface Compose.

Os dados ficam no banco privado `agnello_estoque.db` e continuam disponíveis
após fechar e abrir o aplicativo.
