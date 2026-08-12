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

## Enquanto os arquivos não chegam

O header e o rodapé usam o monograma em SVG inline (aproximação do símbolo
da marca) e a assinatura usa o wordmark tipográfico `UMAN`. Nada quebra —
os arquivos apenas substituem esses padrões quando aparecem.
