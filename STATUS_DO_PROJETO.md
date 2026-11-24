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
- Plugins ativos no jogo principal: Road Generator 0.9.5 (ferramentas de editor; não gera as vias OSM do runtime) e EZTree 0.2.0 (árvores de áreas verdes OSM). Lowland Forge e Sky3D estão ativos somente no projeto separado `maaack's-game-template`; não são carregados pelo jogo principal.
- O repositório inclui `assets/`, `scripts/`, `scenes/`, `tests/` e `tools/`. O inventário atual contabiliza 219 arquivos-fonte em `assets/`, excluindo metadados `.import`/`.uid`: 85 de personagens, 30 de veículos, 24 de áudio, 16 de texturas, 48 da vila medieval, 1 shader e 15 miniaturas.
- A licença do projeto é MIT. As licenças de terceiros permanecem junto aos assets. Ground037 foi reutilizado do template local e copiado para o projeto principal sob CC0 1.0; seus créditos estão em `assets/textures/ground/CREDITS.md`. Veja [INVENTARIO_RECURSOS_GODOT.md](INVENTARIO_RECURSOS_GODOT.md) para o inventário de plugins, projetos e assets.

## Arquivos de entrada

- Projeto: `project.godot`
- Cena principal: `scenes/main.tscn` (raiz `Node3D`, script principal `scripts/game.gd`)
- Instruções e especificação: `CODEX_PROMPT.md`, `REBUILD_SPEC.md` e `DEVIATIONS.md`
- Testes: `tests/world_collision_audit.tscn`, `tests/natural_world_audit.tscn`, `tests/movement_audit.tscn`, `tests/ragdoll_audit.tscn`, `tests/death_ragdoll_audit.tscn`, `tests/gmc_map_audit.tscn`, `tests/capybara_pet_audit.tscn`, `tests/boot_menu_audit.tscn` e `tests/visual_audit.tscn`.

## Funcionalidades verificadas

Os itens abaixo são verificações automatizadas/estruturais, não uma certificação de todos os recursos de gameplay.

- O clone foi obtido na branch `main` e o HEAD corresponde ao commit acima.
- Godot 4.7.2 importou os addons e scripts. `--headless --editor --quit` terminou com exit code `0`, sem vazamentos de RID/ObjectDB após a correção do Road Generator.
- A cena principal iniciou em headless com `--quit`, exit code `0`.
- `tests/world_collision_audit.tscn`: passou após o recuo de água e atualização das colisões, saída `WORLD_COLLISION_AUDIT_OK roads=1524 buildings=2116`, exit code `0`.
- `tests/movement_audit.tscn`: passou após o ajuste das alturas de spawn e terreno, saída `MOVEMENT_AUDIT_OK`, exit code `0`.
- `tests/natural_world_audit.tscn`: passou após a reconstrução, saída `NATURAL_WORLD_AUDIT_OK roads=1524`, exit code `0`.
- `tests/ragdoll_audit.tscn`: passou com o simulador físico e suporte de colisão local, saída `RAGDOLL_AUDIT_OK`, exit code `0`.
- `tests/death_ragdoll_audit.tscn`: passou, saída `DEATH_RAGDOLL_AUDIT_OK`, exit code `0`.
- `tests/gmc_map_audit.tscn`: passou com 1.524 segmentos de via, 1.600 casas inferidas, 70 blocos médios, 7 pontes, 65 trechos de água visível, 37 áreas verdes e 96 árvores; a contagem total de edifícios varia com o conteúdo procedural. A auditoria também verifica texturas/UVs de solo, parques e casas, ausência de segmentos de rua submersos, recuo dos infills em relação à água, footprints OSM sem sobreposição com cursos visíveis, pontes caminháveis e colisões da vila.
- `tests/capybara_pet_audit.tscn`: passou; iniciar uma partida cria a capivara procedural de 12 partes e o teste confirma que ela acompanha o jogador.
- `tests/death_ragdoll_audit.tscn`: passou nesta auditoria. O fixture foi corrigido para posicionar a morte em um spawn seguro, usando a elevação real do terreno.
- `tests/boot_menu_audit.tscn`: passou em headless e D3D12; confirma o fundo do mapa, título colorido MARYLAND CITY, fonte, música em loop e sua parada ao iniciar o jogo, foco da interface, mapeamento A/✕, conteúdo de teclado/controle, retorno por Escape/B/○ e captura da tela inicial e da página de controles.
- `tests/visual_audit.tscn`: passou com renderer gráfico D3D12/NVIDIA RTX 3060 após a aplicação de Ground037 e dos materiais PBR, exit code `0`; gerou `city.png`, `coast.png`, `street.png`, `facade.png` e `moon.png` na pasta `user://visual-audit`.
- Auditoria headless da cena principal: exit code `0`.

## Avisos, erros e correções

- A queda física continua restrita a mortes a pé (Terra ou Lua); mortes em veículo, traje ou paraquedas não usam esse ragdoll. Movimento normal, NPCs e veículos permanecem cinemáticos.
- `scripts/world.gd` lê `GMC/map_expanded.osm` e `GMC/elevation_srtm.csv`, substitui as superfícies planas/linhas antigas do GLB por vias e áreas reconstruídas sobre o SRTM, marca cruzamentos de vias/água como pontes e alinha os elementos de gameplay à altura do terreno.
- Ground037 (ambientCG, CC0) agora texturiza terreno natural e polígonos verdes OSM com UVs planos; casas inferidas e prédios OSM usam fachadas/telhados PBR compartilhados. O datum SRTM foi deslocado para que a menor amostra (671 m) permaneça acima do oceano virtual, preservando a variação do relevo.
- Casas inferidas e suburbanas, incluindo garagens, respeitam um recuo de cinco unidades do jogo além dos cursos d'água. Edifícios OSM permanecem nas posições mapeadas; `tunnel=culvert`/`covered=yes` não é desenhado como água superficial. Árvores, cercas, carroça e caixas da vila têm colisão de gameplay.
- A medição local encontrou uma edificação OSM sobre um dreno subterrâneo (`tunnel=culvert`, `layer=-1`), que antes aparecia como água superficial; esse trecho agora fica oculto. O footprint mapeado mais próximo do Rio Paraibuna mantém cerca de 11,6 unidades de jogo de distância da margem visível e não foi deslocado.
- Até 1.600 casas e 70 blocos comerciais são infill procedural porque o extract OSM contém somente 12 ways de edifícios; não representam footprints residenciais pesquisados. Street View foi usado apenas como referência qualitativa de escala de rua, passeio, praça e edifícios em Av. Gov. Valadares, R. Ewbanck da Câmara e R. Américo Lôbo. Nenhuma imagem foi copiada.
- O addon EZTree preenche polígonos verdes fechados do OSM com distribuição determinística, limitada e que evita vias, edifícios e água.
- `scripts/game.gd` cria um pet capivara procedural que acompanha o jogador a pé e fica oculto em veículos, voo, paraquedas, traje e interiores elevados.
- A tela inicial usa a estrutura centralizada de título e botões do Maaack's Game Template, com fundo de uma captura gerada do próprio mapa, título multicolorido, fonte de sistema suave, música procedural original que respeita mute e CONTROLS para teclado/joystick. “Maryland City” é apenas o título; o mapa jogável continua sendo Manoel Honório. O template segue isolado como projeto separado; o menu do jogo principal é autocontido.
- O Road Generator tinha nós e um helper `Object` sem liberação no encerramento do plugin. O teardown agora desconecta sinais, libera os widgets/objetos e o teste do editor headless termina sem vazamentos de RID/ObjectDB.
- O editor informa que ignora `3d-multiplayer-template/project.godot` durante a varredura; esse diretório é um projeto separado preservado como fonte, não parte do jogo principal.
- `tests/visual_audit.tscn` detecta o renderer headless e encerra explicitamente com erro informando que requer a versão gráfica; na execução gráfica, os cinco enquadramentos foram capturados e o teste passou.

## Testes ainda pendentes

- Iniciar manualmente uma partida em **NEW GAME** na tela inicial.
- Testar movimento, corrida, câmera com mouse e gamepad, combate e colisões em áreas diferentes da cidade.
- Confirmar manualmente em jogo a queda ragdoll e o comportamento da capivara em movimento/entrada e saída de veículos.
- Testar entrar/dirigir/sair de veículos, barcos, aeronaves e espaçonaves.
- Observar NPCs, polícia, áudio, ciclo dia/noite, menus, pausa e rebind dos controles.
- Testar autosave, fechar o jogo e carregar **CONTINUE**.

A presença de cenas/scripts e os audits automatizados não prova, por si só, cada comportamento descrito no README. A jogabilidade completa ainda requer smoke test manual.

## Problemas conhecidos e limitações

- O visual audit requer renderer gráfico; em `--headless` ele encerra com erro explícito, e a execução gráfica já foi aprovada.
- Não foi registrado um teste manual com teclado, mouse ou controle nesta preparação.
- O projeto é uma homenagem independente, não afiliada à Rockstar Games/Take-Two; o README e a licença devem acompanhar a cópia. Consulte as licenças específicas dos modelos antes de redistribuir builds.

## Matriz de `GMCespecs.txt`

| Pedido | Situação |
|---|---|
| Capivara / pets | Capivara companheira implementada e auditada; sistema genérico de pets pendente. |
| Mapa Maryland City | Não implementado; “Maryland City” é o título do menu. O mapa GMC atual é Manoel Honório, Juiz de Fora. |
| Veículos aleatórios | Tráfego aleatório de 54 carros implementado; espécies/props listados abaixo pendentes. |
| Pônei, carrinho de supermercado, touro mecânico | Não implementados. |
| Magia / “livroPAD” | Não implementados; “livroPAD” ainda precisa de definição. |
| Interiores | Parcial: há espaços e terminais internos, mas não um sistema geral de interiores. |
| NPCs / pontos de interesse | Pedestres, polícia, VIPs, Presidente e POIs implementados. |
| Eventos | Parcial: eventos da economia, corridas e milestones; não há sistema geral de eventos do mundo. |
| Ticket de estacionamento | Não implementado. |
| Controles | Teclado/mouse e joystick mapeados; tela inicial mostra o esquema e pausa permite rebind. |

## Como iniciar

1. Abra `C:\Users\doug-\OneDrive\Documents\projectbegins\open-theft-auto\project.godot` no Godot 4.7.2 Standard e aguarde a importação terminar.
2. Confirme que a cena principal é `res://scenes/main.tscn`.
3. Pressione **F5 / Run Project**.
4. Na tela inicial, escolha **START GAME** ou **CONTINUE / NEW GAME** conforme o save; **CONTROLS** mostra os mapeamentos e **EXIT** encerra.

O comando headless de importação utilizado foi:

```powershell
& 'D:\softwares\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --headless --path 'C:\Users\doug-\OneDrive\Documents\projectbegins\open-theft-auto' --editor --quit
```
