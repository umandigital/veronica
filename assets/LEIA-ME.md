# Assets da marca

Coloque os arquivos nesta pasta com **exatamente** estes nomes. A página
detecta e aplica sozinha, sem precisar mexer no código:

| Arquivo | Onde aparece |
|---|---|
| `logo-veronica.svg` (ou `.png`, `.webp`, `.jpg`) | Header e rodapé, no lugar do monograma |
| `logo-uman.svg` (ou `.png`, `.webp`, `.jpg`) | Assinatura "Criado por" no rodapé |

A ordem de busca das extensões é: `.svg`, `.png`, `.webp`, `.jpg`.

## Recomendações

- **Fundo transparente.** Os dois logos aparecem sobre o vinho `#5A1124`
  (rodapé) e o logo da Verônica também sobre o marfim `#FBF7F0` (header
  rolado). Um PNG com fundo sólido criaria um retângulo visível.
- **SVG de preferência** — escala sem perda e pesa menos.
- Se usar PNG, exporte com pelo menos **2x** o tamanho de exibição:
  logo da Verônica com ~480px de largura, logo UMAN com ~360px.
- O logo da Verônica é usado nas duas posições. Se o header ficar melhor
  com uma versão horizontal e o rodapé com a empilhada, envie a horizontal
  aqui e a empilhada pelo painel (Configurações → Marca e assinatura),
  que tem prioridade sobre esta pasta.

## Alternativa sem commit

Configurações → Marca e assinatura, no painel administrativo, aceita upload
direto. Com o Supabase conectado, o arquivo vai para o bucket `midia`; sem
conexão, fica no navegador.

## O que já está aqui

| Arquivo | Origem |
|---|---|
| `logo-veronica.png` | Extraído do JPG enviado: fundo roxo removido, arte em ouro sobre transparência |
| `logo-veronica-escuro.png` | Mesma arte em ametista `#7A1A64`, para o header quando fica sólido sobre o marfim |
| `logo-uman.png` | Enviado, já com transparência; redimensionado para 760px |
| `originais/logo-veronica.jpg` | Arquivo original (CMYK, 2484px, 957 KB), guardado como material-fonte |

O logo em ouro tem só 2:1 de contraste sobre o marfim, daí a variante em
ametista — o site troca as duas conforme o header rola. Se tiver o logo
vetorial (`.svg` ou `.ai`/`.pdf`), envie: substitui os PNGs com nitidez
melhor em qualquer tela e arquivo menor.

## Enquanto os arquivos não chegam

O header e o rodapé usam o monograma em SVG inline (aproximação do símbolo
da marca) e a assinatura usa o wordmark tipográfico `UMAN`. Nada quebra —
os arquivos apenas substituem esses padrões quando aparecem.


## Vídeos das categorias

A vitrine de categorias mostra as peças apagadas e acende a coluna sob o
cursor. O vídeo é o recurso principal desse estado; a imagem serve de
reserva e é o que aparece enquanto o vídeo carrega.

Suba os arquivos aqui e informe o caminho em **Categorias → editar →
Vídeo da peça**, no painel. Um nome por categoria facilita:

| Categoria | Sugestão de arquivo | Movimento indicado |
|---|---|---|
| Anéis | `assets/cat-aneis.mp4` | rotação 360° |
| Brincos | `assets/cat-brincos.mp4` | rotação 360° |
| Colares | `assets/cat-colares.mp4` | orbital 3/4 com leve parallax |
| Pulseiras | `assets/cat-pulseiras.mp4` | orbital 3/4 com leve parallax |
| Braceletes | `assets/cat-braceletes.mp4` | rotação 360° |
| Broches | `assets/cat-broches.mp4` | rotação 360° |
| Conjuntos | `assets/cat-conjuntos.mp4` | orbital 3/4 com leve parallax |

Recomendações para os vídeos:

- **Enquadramento vertical**, perto de 3:4 — a coluna é um retrato. A peça
  precisa estar centralizada, porque as bordas são cortadas.
- **Curtos**, de 2 a 4 segundos, em looping que fecha sem salto visível.
- **Sem áudio** — ele entra mudo de qualquer forma, e a faixa só pesa.
- **Leves**, até cerca de 1 MB. São sete vídeos; o peso soma.
- H.264 em `.mp4` é o formato mais compatível.

Cada vídeo só é baixado quando o cursor chega na coluna, então os sete não
custam nada a quem apenas passa pela seção.
