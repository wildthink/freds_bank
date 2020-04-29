/*
 Branch {
     _id: String
     name: String
     phone_number: String
     hours: [String]
     notes: [String]
     address: {
        street_number: String
        street_name: String
        city: String
        state: String
        zip: String
     }
     geocode: { lat, lng }
 }
 */

DROP TABLE IF EXISTS _branches;

CREATE TABLE IF NOT EXISTS _branches (
    id INTEGER PRIMARY KEY,
    _id TEXT,
    name TEXT,
    phone_number TEXT,
    hours JSON,
    notes JSON,
    address JSON,
    geocode JSON
);

DROP VIEW IF EXISTS branches;

CREATE VIEW IF NOT EXISTS branches AS
    SELECT rowid as rowid, *,
        printf('%s %s',
           json_extract(address, '$.street_number'),
           json_extract(address, '$.street_name'))
        as street,
        json_extract(address, '$.city') as city,
        json_extract(address, '$.state') as state,
        json_extract(address, '$.zip') as zipcode,
        json_extract(geocode, '$.lat') as lat,
        json_extract(geocode, '$.lng') as lon

    FROM _branches
;

DROP TABLE IF EXISTS _atms;

    CREATE TABLE IF NOT EXISTS _atms (
        id INTEGER PRIMARY KEY,
        _id TEXT,
        name TEXT,
        geocode JSON,
        accessibility BOOL,
        hours JSON,
        address JSON,
        language_list JSON,
        amount_left INTEGER
    );

--- Adaptor Views

DROP VIEW IF EXISTS atms;

     CREATE VIEW IF NOT EXISTS atms AS
         SELECT  rowid as rowid, id,
                 name,
                 address,
                 printf('%s %s',
                    json_extract(address, '$.street_number'),
                    json_extract(address, '$.street_name'))
                 as street,
                 json_extract(address, '$.city') as city,
                 json_extract(address, '$.state') as state,
                 json_extract(address, '$.zip') as zipcode,
                 json_extract(geocode, '$.lat') as lat,
                 json_extract(geocode, '$.lng') as lon

         FROM _atms;

---
--- Map Annotations

DROP VIEW IF EXISTS locations;

    CREATE VIEW IF NOT EXISTS locations AS
        SELECT  rowid as rowid, id,
                name, street, city, state, zipcode,
                name as title,
                street as subtitle,
                lat, lon
        FROM atms
        UNION
        SELECT  rowid as rowid, id,
                name, street, city, state, zipcode,
                name as title,
                street as subtitle,
                lat, lon
        FROM branches
    ;
--        WHERE title like (select '%' ||
--            (select value from app where key = "search") || '%');

---
