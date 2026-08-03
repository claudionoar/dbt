-- Camada STAGING: itens de pedido (order_reviews).
-- Esta é a tabela que define o GRÃO da nossa fato: 1 linha por item de pedido.
-- É aqui que vivem as medidas cruas (price, freight_value).
 
-- {{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'order_reviews') }}
),

limpo AS ( 
    SELECT
        review_id,
        order_id,
        review_score,
        review_creation_date,
        review_answer_timestamp,
 
        ----------------------------------------------------------------
        -- 1. LIMPEZA do texto cru (title e message)
        --    - vazio/whitespace -> NULL
        --    - remove quebras de linha internas (caso da linha 29 da planilha)
        ----------------------------------------------------------------
        nullif(trim(regexp_replace(review_comment_title,   '[\n\r]+', ' ')), '') AS titulo,
        nullif(trim(regexp_replace(review_comment_message, '[\n\r]+', ' ')), '') AS mensagem
 
    FROM source 
)
 
SELECT
    review_id,
    order_id,
    review_score,
    review_creation_date,
    review_answer_timestamp,
 
    -- seu rótulo original, baseado na NOTA (mantido)
    CASE
        WHEN review_score >= 4 THEN 'positivo'
        WHEN review_score <= 2 THEN 'negativo'
        ELSE 'neutro'
    END AS sentiment_label,
 
    titulo,
    mensagem,
 
    ----------------------------------------------------------------
    -- 2. TEXTO UNIFICADO: title + message se complementam.
    --    Ex.: título "Não chegou meu produto" + mensagem "Péssimo" (linha 21).
    --    Concatenamos para não perder informação em nenhum dos dois campos.
    ----------------------------------------------------------------
    trim(concat_ws('. ', titulo, mensagem)) AS texto_completo,
 
    ----------------------------------------------------------------
    -- 3. FLAGS de presença (muitas linhas têm um campo, outro, ou nenhum)
    ----------------------------------------------------------------
    (titulo   is not null)                     AS tem_titulo,
    (mensagem is not null)                      AS tem_mensagem,
    (titulo is not null or mensagem is not null) AS tem_comentario
 
FROM limpo