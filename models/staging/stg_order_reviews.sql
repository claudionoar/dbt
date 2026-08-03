-- Camada STAGING: itens de pedido (order_reviews).
-- Esta é a tabela que define o GRÃO da nossa fato: 1 linha por item de pedido.
-- É aqui que vivem as medidas cruas (price, freight_value).
 
-- {{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'order_reviews') }}
)

SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    CASE
        WHEN review_score >= 4 THEN 'positivo'
        WHEN review_score <= 2 THEN 'negativo'
        ELSE 'neutro'
    END AS sentiment_label
FROM source
