{{
    config(
        materialized='incremental',
        unique_key='id',
        partition_by={
          "field": "created_at",
          "data_type": "TIMESTAMP",
          "granularity": "day"
        },
        cluster_by=['id']
    )
}}

SELECT id, name, created_at
FROM {{ source('temp_benoit_airbyte', 'cities') }}

{% if is_incremental() %}

  WHERE DATE(_airbyte_extracted_at) >= DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY)

{% endif %}