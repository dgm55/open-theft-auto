# Status do Projeto — Open Theft Auto

## Cópia e origem

- Caminho: `C:\Users\doug-\OneDrive\Documents\projectbegins\open-theft-auto`
- Repositório: `https://github.com/mehulkapadia5/open-theft-auto`
- Branch clonada: `main`
- Commit utilizado (HEAD): `b37e7f3070501dd90353c250e9ad90dffdf4c8b2`
- Mensagem do commit: `wip: checkpoint before machine wipe (2026-09-09)`
- O projeto `sand-box-open-world` não foi alterado.

## Ambiente confirmado

- Godot `4.7.2.stable.official.ed1daf0bf`, Standard, sem .NET.
- Binário console usado: `D:\softwares\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`.
- Projeto em GDScript puro; cena principal configurada em `res://scenes/main.tscn`.
- Configuração declarada: Forward Plus, Jolt Physics, janela 1920×1080 e escala de UI `canvas_items/expand`.
- O repositório inclui `assets/`, `scripts/`, `scenes/`, `tests/` e `tools/`. A inspeção encontrou 310 arquivos em `assets/`, totalizando 326.920.722 bytes, incluindo áudio, texturas e modelos glTF/GLB; os assets citados pelo README estão presentes.
- A licença do projeto é MIT. Créditos/licenças de terceiros estão no README e em arquivos locais `license.txt`/`CREDITS.md`; mantenha-os com a distribuição. Não foram baixados assets ou dependências adicionais.

## Arquivos de entrada

- Projeto: `project.godot`
- Cena principal: `scenes/main.tscn` (raiz `Node3D`, script principal `scripts/game.gd`)
- Instruções e especificação: `CODEX_PROMPT.md`, `REBUILD_SPEC.md` e `DEVIATIONS.md`
- Testes fornecidos e acrescentados: `tests/world_collision_audit.tscn`, `tests/movement_audit.tscn`, `tests/natural_world_audit.tscn`, `tests/visual_audit.tscn`, `tests/ragdoll_audit.tscn` e `tests/death_ragdoll_audit.tscn`.

## Funcionalidades verificadas

Os itens abaixo são verificações automatizadas/estruturais, não uma certificação de todos os recursos de gameplay.

- O clone foi obtido na branch `main` e o HEAD corresponde ao commit acima.
- Godot 4.7.2 confirmou versão e executou a importação inicial dos assets. A repetição de `--headless --editor --quit` terminou com exit code `0`.
- A cena principal iniciou em headless com `--quit`, exit code `0`.
- `tests/world_collision_audit.tscn`: passou, saída `WORLD_COLLISION_AUDIT_OK buildings=489`, exit code `0`.
- `tests/movement_audit.tscn`: passou após restaurar caminhada/sprint documentados e expandir o audit, saída `MOVEMENT_AUDIT_OK`, exit code `0`.
- `tests/natural_world_audit.tscn`: passou, saída `NATURAL_WORLD_AUDIT_OK roads=52`, exit code `0`.
- `tests/ragdoll_audit.tscn`: passou com o simulador físico e suporte de colisão local, saída `RAGDOLL_AUDIT_OK`, exit code `0`.
- `tests/death_ragdoll_audit.tscn`: uma versão anterior passou após sincronizar o rig no respawn; após limitar o ragdoll às mortes a pé e refatorar o harness, a última execução não retornou saída observável e permanece pendente de confirmação.

## Avisos, erros e correções

- Nesta tarefa posterior foram alterados `scripts/game.gd` (velocidades, ativação/limpeza do ragdoll e sincronização do respawn), `scripts/human.gd` (simulador e colliders dos ossos), `tests/movement_audit.gd` e os novos testes `tests/ragdoll_audit.*` e `tests/death_ragdoll_audit.*`. A cena principal, `project.godot` e os assets originais não foram alterados.
- A queda física é habilitada somente em morte a pé (Terra ou Lua); mortes em veículo, traje ou paraquedas não usam esse ragdoll. O resto da movimentação, dos NPCs e dos veículos continua cinemático.
- O teste integrado de morte/respawn passou antes do ajuste final de escopo/camada, mas sua execução mais recente não retornou saída observável; não é declarado aprovado após esses ajustes. Os diagnósticos do VS Code não apontaram erros nos scripts consultados.
- Durante a importação, Godot emitiu um aviso glTF: `File uses different UV maps for metallic/roughness and base color`. A importação dos modelos continuou; não foi feita alteração para silenciar ou converter os assets.
- `tests/visual_audit.tscn` não passou no modo headless: o renderer dummy retornou textura nula ao tentar salvar screenshot em `tests/visual_audit.gd:51` (`Cannot call method 'save_png' on a null value`). Uma tentativa em modo desktop não produziu saída nem screenshots verificáveis; portanto, não é considerada aprovada.
- O log completo da primeira importação capturado pelo terminal termina durante a fase de reimportação; a repetição de `--headless --editor --quit` encerrou com exit code `0`. Não foi possível confirmar o código de saída da primeira chamada a partir da captura truncada.
- Uma tentativa de inicialização curta com `--quit-after 5` e a consulta final de `git status` não retornaram saída observável pelo terminal; nenhum resultado foi atribuído a essas chamadas. O estado Git foi confirmado limpo imediatamente após o clone, antes da importação.

## Testes ainda pendentes

- Iniciar manualmente uma partida em **NEW GAME** na tela inicial.
- Testar movimento, corrida, câmera com mouse e gamepad, combate e colisões em áreas diferentes da cidade.
- Confirmar visualmente a queda ragdoll após uma morte a pé e a limpeza ao respawn; cobrir também morte na Lua.
- Testar entrar/dirigir/sair de veículos, barcos, aeronaves e espaçonaves.
- Observar NPCs, polícia, áudio, ciclo dia/noite, menus, pausa e rebind dos controles.
- Testar autosave, fechar o jogo e carregar **CONTINUE**.
- Fazer validação visual em uma sessão de desktop com renderer ativo e registrar os screenshots do audit visual.

A presença de cenas/scripts e os audits automatizados não prova, por si só, cada comportamento descrito no README. A jogabilidade completa ainda requer smoke test manual.

## Problemas conhecidos e limitações

- O visual audit depende de renderização real e não pode confirmar imagens com o renderer dummy de `--headless`.
- O primeiro log de importação ficou incompleto na captura; apenas a repetição do comando teve exit code registrado.
- Não foi registrado um teste manual com teclado, mouse ou controle nesta preparação.
- O projeto é uma homenagem independente, não afiliada à Rockstar Games/Take-Two; o README e a licença devem acompanhar a cópia. Consulte as licenças específicas dos modelos antes de redistribuir builds.

## Como iniciar

1. Abra `C:\Users\doug-\OneDrive\Documents\projectbegins\open-theft-auto\project.godot` no Godot 4.7.2 Standard e aguarde a importação terminar.
2. Confirme que a cena principal é `res://scenes/main.tscn`.
3. Pressione **F5 / Run Project**.
4. Na tela inicial, escolha **NEW GAME** para começar ou **CONTINUE** se houver um save.

O comando headless de importação utilizado foi:

```powershell
& 'D:\softwares\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'C:\Users\doug-\OneDrive\Documents\projectbegins\open-theft-auto' --editor --quit
```
