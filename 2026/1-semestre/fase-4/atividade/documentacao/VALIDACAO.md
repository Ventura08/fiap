# Registro de validação técnica

Data: 20 de junho de 2026.

## Android

Comando executado:

```bash
ANDROID_HOME="$HOME/Library/Android/sdk" ./gradlew test assembleDebug
```

Resultado: `BUILD SUCCESSFUL`.

- Testes unitários de validação executados.
- APK de debug compilado.
- O teste instrumentado do DAO foi criado, mas `connectedAndroidTest` não foi
  executado porque esta validação exige um emulador ou dispositivo conectado.
- O fluxo visual e a persistência após reinicialização ainda precisam ser
  exercitados no emulador para produzir as evidências do relatório.

## C#

Comandos executados com o SDK .NET 8:

```bash
dotnet build
dotnet run -- --self-test
```

Resultado:

- Compilação com 0 avisos e 0 erros.
- Mensagem final: `Autoteste concluído: CRUD e persistência JSON funcionando.`
- O autoteste cobriu cadastro, listagem, consulta, atualização, reabertura do
  repositório e exclusão.

## Documento

- O DOCX foi validado como arquivo Microsoft Word 2007+.
- A estrutura ZIP interna não apresentou erros.
- Foram confirmados 22 espaços de evidência.
- Screenshots não foram inventados nem inseridos.
