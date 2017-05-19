
CREATE TABLE post (SELECT ID, post_date, post_title, post_content FROM wp_posts WHERE post_date >= '2017-01-01 00:00:00' AND post_type = 'post'  AND post_title <> 'Auto Draft' AND post_title <> '' AND post_content <> '');

ALTER TABLE post
ADD PRIMARY KEY (ID);

CREATE TABLE image (SELECT wp_posts.guid, wp_posts.post_parent, wp_posts.ID FROM wp_posts
WHERE post_date >= '2017-01-01 00:00:00' AND post_type = 'attachment' AND post_mime_type = 'image/jpeg'
AND post_parent IN (SELECT ID FROM post));

ALTER TABLE image
ADD PRIMARY KEY (ID);

CREATE TABLE tax (SELECT term_taxonomy_id, object_id FROM wp_term_relationships
WHERE object_id IN (SELECT ID FROM post));




CREATE TEMPORARY TABLE result (SELECT post.ID, post.post_date, post.post_title, post.post_content, image.guid FROM post, image WHERE post.ID = image.post_parent);

SELECT * FROM result;



CREATE TABLE tags (SELECT r.object_id, n.name FROM wp_term_relationships r, wp_term_taxonomy t, wp_terms n
WHERE object_id IN (SELECT ID FROM post) AND r.term_taxonomy_id = t.term_taxonomy_id AND r.term_taxonomy_id = n.term_id AND t.taxonomy = 'post_tag');

CREATE TABLE concat_tags (SELECT object_id as ID,GROUP_CONCAT(name SEPARATOR ', ')as tags
FROM tags
GROUP BY object_id);

ALTER TABLE concat_tags
ADD PRIMARY KEY (ID);

CREATE TABLE cat (SELECT r.object_id, n.name FROM wp_term_relationships r, wp_term_taxonomy t, wp_terms n
WHERE object_id IN (SELECT ID FROM post) AND r.term_taxonomy_id = t.term_taxonomy_id AND r.term_taxonomy_id = n.term_id AND t.taxonomy = 'category');

CREATE TABLE concat_cat (SELECT object_id as ID,GROUP_CONCAT(name SEPARATOR ', ')as category
FROM cat
GROUP BY object_id);

ALTER TABLE concat_cat
ADD PRIMARY KEY (ID);

CREATE TABLE result (SELECT p.ID as id, p.post_title as title, p.post_content as body, c.category as category, t.tags as tags,
p.post_date as date, i.guid as image FROM post p, concat_cat c, concat_tags t, image i
WHERE p.ID = c.ID AND p.ID = t.ID AND p.ID = i.post_parent GROUP BY id);


ALTER TABLE result
ADD PRIMARY KEY (id);