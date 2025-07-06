DROP TABLE IF EXISTS establishment;
CREATE TABLE establishment (
  uid TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  address TEXT NOT NULL,
  lat REAL NOT NULL,
  lon REAL NOT NULL,
  geometry AS (
    json_object(
      'type', 'Point',
      'coordinates', json_array(lon, lat)
    )
  )
);
INSERT INTO establishment
SELECT
  properties->>'$.estId' establishment_id,
  properties->>'$.estName',
  properties->>'$.srvType',
  properties->>'$.addrFull',
  geometry->>'$.coordinates[0][1]',
  geometry->>'$.coordinates[0][0]'
FROM
  data.bodysafe
GROUP BY
  establishment_id
HAVING
  MAX(properties->>'$.insDate')
;
CREATE INDEX idx_establishment_type ON establishment (type);

DROP TABLE IF EXISTS establishment_fts;
CREATE VIRTUAL TABLE establishment_fts USING fts5 (name, address, content="establishment");
INSERT INTO establishment_fts (rowid, name, address) SELECT rowid, name, address FROM establishment;

DROP TABLE IF EXISTS inspection;
CREATE TABLE inspection (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  establishment_uid TEXT NOT NULL,
  date TEXT NOT NULL,
  status TEXT NOT NULL,
  UNIQUE (establishment_uid, date),
  FOREIGN KEY (establishment_uid) REFERENCES establishment (uid)
);
INSERT INTO inspection
SELECT
  NULL,
  properties->>'$.estId' establishment_uid,
  properties->>'$.insDate' date,
  properties->>'$.insStatus' status
FROM
  data.bodysafe
GROUP BY
  establishment_uid, date
HAVING
  MAX(date)
;

DROP TABLE IF EXISTS infraction;
CREATE TABLE infraction (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  establishment_uid TEXT NOT NULL,
  inspection_id INTEGER NOT NULL,
  type TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  FOREIGN KEY (establishment_uid) REFERENCES establishment (uid),
  FOREIGN KEY (inspection_id) REFERENCES inspection (id)
);
INSERT INTO infraction
WITH cte AS (
  SELECT
    properties->>'$.estId' establishment_uid,
    properties->>'$.insDate' inspection_date,
    properties->>'$.infType' type,
    properties->>'$.infCategory' category,
    properties->>'$.defDesc' description
  FROM
    data.bodysafe
  WHERE
    properties->>'$.infType' != 'None'
)
SELECT
  NULL,
  cte.establishment_uid,
  inspection.id,
  CASE cte.type WHEN 'None' THEN '' ELSE cte.type END,
  CASE cte.category WHEN 'None' THEN '' ELSE cte.category END,
  CASE cte.description WHEN 'None' THEN '' ELSE cte.description END
FROM
  cte
JOIN
  inspection
ON
  cte.establishment_uid = inspection.establishment_uid
  AND cte.inspection_date =  inspection.date
;
