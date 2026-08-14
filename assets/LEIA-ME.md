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
| `apple-touch-icon.png` | Ícone de 180px para a tela de início do iPhone — símbolo do logo sobre o ametista |
| `../favicon.ico` | Ícone da aba, na raiz do site, com 16, 32 e 48px desenhados um a um |

Os dois ícones saem do mesmo símbolo do logo, recortado do JPG original em
alta resolução — não é uma redesenhada. Para trocá-los, mande o logo novo e
eu regero: em 16px o símbolo precisa de mais preenchimento e menos folga
que em 48px, senão vira um borrão na aba.

O logo em ouro tem só 2:1 de contraste sobre o marfim, daí a variante em
ametista — o site troca as duas conforme o header rola. Se tiver o logo
vetorial (`.svg` ou `.ai`/`.pdf`), envie: substitui os PNGs com nitidez
melhor em qualquer tela e arquivo menor.

## Enquanto os arquivos não chegam

O header e o rodapé usam o monograma em SVG inline (aproximação do símbolo
da marca) e a assinatura usa o wordmark tipográfico `UMAN`. Nada quebra —
os arquivos apenas substituem esses padrões quando aparecem.


## Vídeos das categorias

A vitrine de categorias mostra os sete vídeos parados no primeiro quadro,
em preto e branco. A coluna sob o cursor ganha cor e o vídeo roda em
looping; ao sair, ele volta ao quadro inicial. A imagem cadastrada serve de
reserva: é o que aparece se o vídeo faltar ou não carregar.

Os sete arquivos já estão aqui, e a página os aplica sozinha: uma categoria
sem vídeo cadastrado usa o arquivo de `assets/` correspondente ao nome dela.
Preencher **Categorias → editar → Vídeo da peça** no painel só é necessário
para apontar outro arquivo — o que estiver lá vence este padrão.

| Categoria | Arquivo | Movimento indicado |
|---|---|---|
| Anéis | `assets/anel.mp4` | rotação 360° |
| Brincos | `assets/brincos.mp4` | rotação 360° |
| Colares | `assets/colar.mp4` | orbital 3/4 com leve parallax |
| Pulseiras | `assets/pulseiras.mp4` | orbital 3/4 com leve parallax |
| Braceletes | `assets/bracelete.mp4` | rotação 360° |
| Broches | `assets/broche.mp4` | rotação 360° |
| Conjuntos | `assets/conjunto.mp4` | orbital 3/4 com leve parallax |

Para trocar um deles, basta commitar um arquivo novo com o mesmo nome.

Recomendações para os vídeos:

- **Enquadramento vertical**, perto de 3:4 — a coluna é um retrato. A peça
  precisa estar centralizada, porque as bordas são cortadas. Os arquivos
  atuais são 9:16, mais estreitos que a coluna: cerca de 17% da altura fica
  de fora, 9% em cima e 9% embaixo. Como a peça está no centro, ela aparece
  inteira; um recorte mais próximo de 3:4 aproveitaria o quadro todo.
- **Curtos**, de 2 a 4 segundos, em looping que fecha sem salto visível.
- **Sem áudio** — ele entra mudo de qualquer forma, e a faixa só pesa.
- **Leves**, até cerca de 1 MB. São sete vídeos; o peso soma.
- H.264 em `.mp4` é o formato mais compatível.

Para o quadro inicial estar à vista antes do hover, os arquivos começam a
ser buscados quando a seção se aproxima da tela — não no carregamento da
página, e só o suficiente para desenhar um quadro. Quem nunca rola até as
categorias não baixa nenhum deles.
