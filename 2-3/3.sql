SET search_path TO resources;

-- википедия изменила домен для хранения картинок => надо везде поменять ссылки

select * from resources where image_url like $$%wikimedia.org%$$;

UPDATE resources
SET image_url = regexp_replace(image_url, 'wikimedia.org','wikipedia.org','i'); -- case-insensitive

select * from resources where image_url like $$%wikipedia.org%$$;