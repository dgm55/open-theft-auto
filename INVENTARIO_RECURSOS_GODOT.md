# Inventário de recursos Godot

Inventário do estado atual do repositório. Os plugins são isolados por projeto:
estar habilitado em um projeto aninhado não o habilita no jogo principal.

## Editor e jogo principal

- Godot 4.7.2 Standard; o jogo é GDScript puro, sem dependência de .NET.
- Renderização Forward+ no desktop, com renderer Mobile configurado para
  Android; física Jolt.
- Add-ons habilitados em `project.godot`:

| Add-on | Versão | Estado e uso |
|---|---:|---|
| Road Generator | 0.9.5 | Habilitado no editor para ferramentas de autoria. As ruas GMC em runtime vêm do OSM e são montadas pelo jogo, não pelo plugin. |
| EZTree | 0.2.0 | Habilitado e usado em runtime para árvores nos polígonos verdes OSM, em lotes MultiMesh com colisões de tronco no spatial hash. |

O mapa principal usa `GMC/map_expanded.osm` para ruas, hidrografia, áreas verdes
e footprints de edifícios; `GMC/elevation_srtm.csv` fornece o relevo. O
Ground037, licenciado sob CC0, fornece albedo, normal e roughness ao terreno
natural e às áreas verdes OSM. As ruas OSM usam `road.png` e `footpath.png`;
fachadas e coberturas procedurais reutilizam os materiais PBR de
`assets/textures/architecture/`.
O datum vertical do recorte SRTM usa referência local de 667 m; com a amostra
mínima de 671 m, isso mantém a malha mapeada acima do plano oceânico do jogo,
sem alterar o relevo relativo.
Os edifícios OSM, casas inferidas, árvores e props estáticos da vila têm
colisões de gameplay testadas por `CityWorld.collides_at`; são volumes
cinemáticos em spatial hash, não corpos rígidos individuais.
Casas inferidas ficam a pelo menos cinco unidades do jogo além da margem dos
cursos d'água mapeados; edifícios com footprint OSM permanecem na posição
original e são auditados para não cruzar a água visível. Trechos marcados como
`tunnel=culvert`/`covered=yes` não são desenhados como rios abertos na
superfície.

## Add-ons em projetos separados

### `maaack's-game-template`

Onze plugins estão habilitados **somente no `project.godot` desse template**:

| Plugin | Versão | Situação no jogo principal |
|---|---:|---|
| ProtoForge Kit Browser | 1.1.0 | Não integrado |
| Lowland Forge Map Baker | 2.1.0 | Não integrado; ferramenta de mapas low-poly, não substitui OSM/SRTM |
| Low Poly Terrain Builder | 1.1.2 | Não integrado |
| Maaack's Game Template | 1.8.0 | Não integrado |
| Music Controller | 1.8.0 | Não integrado; o jogo mantém seu autoload de áudio |
| Scene Loader | 1.8.0 | Não integrado |
| UI Sound Controller | 1.8.0 | Não integrado |
| Plugin Updater | 0.5.1 | Não integrado |
| Road Generator | 0.9.5 | Não integrado ao runtime OSM do jogo |
| RTS Camera 3D | 1.0 | Não integrado |
| Sky3D | 2.1 | Não integrado; o jogo principal conserva seu próprio ciclo de dia/noite |

O template também contém Godot AI 4.3.1 e Terrain3D 1.1.0, ambos desabilitados
na configuração examinada. Seus recursos e plugins não são carregados pelo
jogo principal.

### Outros diretórios Godot

- `3d-multiplayer-template/`: projeto-fonte separado; contém cópias de EZTree e
  Road Generator, sem configuração ativa desses plugins no jogo principal.
- `GMC/gmc/`: projeto Godot separado para o modelo/dados GMC; sem plugins
  habilitados para o jogo principal.
- `runtime-procedural-world-generation/`: demonstração C# de terreno procedural;
  não é dependência do jogo GDScript.
- Exemplos e utilitários encontrados dentro dos projetos aninhados permanecem
  isolados; não são plugins ativos do jogo principal.

## Assets do projeto principal

Contagem de arquivos-fonte/documentação/licenças em `assets/`, excluindo
metadados `.import` e `.uid`:

| Pasta | Arquivos-fonte | Conteúdo e uso |
|---|---:|---|
| `characters/` | 85 | Modelos de personagens usados pelos sistemas de jogador, NPCs, VIPs e guardas. |
| `vehicles/` | 30 | Modelos de carros, McLaren, helicóptero, Boeing 787, ônibus espacial e nave; usados pelos veículos correspondentes. |
| `audio/` | 24 | Efeitos sonoros amostrados e créditos; chamados pelo sistema de áudio do jogo. |
| `textures/` | 16 | Asfalto, passeio, materiais PBR de arquitetura, Ground037 e fundo do menu gerado a partir da captura do mapa. |
| `medieval_village/` | 48 | Kit glTF modular Quaternius, buffers, texturas e licença; quatro casas e props são montados pela cena da vila. |
| `shaders/` | 1 | Shader de vidro arquitetônico, usado nos edifícios. |
| `thumbs/` | 15 | Miniaturas dos catálogos de veículos e propriedades. |
| **Total** | **219** | Fontes e documentos, sem sidecars importados do Godot. |

O menu usa uma captura gerada do mapa como imagem de fundo e uma trilha
procedural original em loop, sintetizada pelo autoload `AudioFX`; não foi
adicionado áudio de terceiros. Os edifícios comerciais e casas suburbanas usam `Build.pbr()`/`Architecture`;
as casas residenciais inferidas e os edifícios OSM agora também usam materiais
PBR compartilhados. As texturas do solo usam UVs planos em coordenadas do
mundo, evitando o custo extra do triplanar nessa malha extensa.

## Origem e licenças

- O mapa OSM é distribuído sob ODbL; os dados de elevação são SRTM NASA/USGS.
- O kit Quaternius da vila inclui sua licença CC0 no diretório do asset.
- Ground037 é ambientCG, CC0 1.0; consulte
  [`assets/textures/ground/CREDITS.md`](assets/textures/ground/CREDITS.md).
- Os materiais PBR de arquitetura têm créditos/licenças em
  `assets/textures/architecture/CREDITS.md`.
- Google Maps/Street View foram referências qualitativas de escala e desenho
  urbano; imagens e geometria de satélite não foram copiadas. Somente os
  footprints presentes no OSM são mapeados; o restante das casas é infill
  procedural, não uma alegação de posição real verificada por satélite.

O inventário cobre os projetos e arquivos presentes neste repositório; não
representa uma varredura de extensões instaladas globalmente no editor Godot.
