-- Agrega a granularidade original de raw.geolocation (várias lat/lng por prefixo de CEP,
-- vindas de GPS de usuários distintos) para uma linha por zip_code_prefix - grão necessário
-- para servir de dimensão de localização de clientes/vendedores em mart_late_delivery_features.

with geolocation as (
    select * from {{ ref('stg_geolocation') }}
)

select
    zip_code_prefix,
    avg(latitude) as latitude,
    avg(longitude) as longitude,
    mode(cidade) as cidade,
    mode(estado) as estado
from geolocation
group by zip_code_prefix
