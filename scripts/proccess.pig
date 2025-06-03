Cargar el archivo CSV
datos = LOAD '/data/data.csv' USING PigStorage(',')
    AS (uuid:chararray, tipo:chararray, ciudad:chararray, timestamp:long, calle:chararray, x:double, y:double);

Eliminar registros incompletos
limpios = FILTER datos BY 
    uuid IS NOT NULL AND 
    tipo IS NOT NULL AND 
    ciudad IS NOT NULL AND 
    x IS NOT NULL AND 
    y IS NOT NULL;

Pasar nombres de comuna a minúsculas y quitar espacios (homogeneización)
homogeneizados = FOREACH limpios GENERATE 
    uuid, 
    tipo, 
    LOWER(TRIM(ciudad)) AS ciudad, 
    timestamp, 
    TRIM(calle) AS calle,
    x, y;

Agrupar por UUID y tomar solo uno
agrupados_uuid = GROUP homogeneizados BY uuid;
sin_duplicados = FOREACH agrupados_uuid {
    uno = LIMIT homogeneizados 1;
    GENERATE FLATTEN(uno);
};

Agrupar por comuna
por_comuna = GROUP sin_duplicados BY ciudad;
conteo_comuna = FOREACH por_comuna GENERATE 
    group AS comuna, 
    COUNT(sin_duplicados) AS total_incidentes;

Agrupar por tipo
por_tipo = GROUP sin_duplicados BY tipo;
conteo_tipo = FOREACH por_tipo GENERATE 
    group AS tipo_incidente, 
    COUNT(sin_duplicados) AS total_tipo;

Resultados
STORE conteo_comuna INTO '/data/resultados_comuna' USING PigStorage(',');
STORE conteo_tipo INTO '/data/resultados_tipo' USING PigStorage(',');