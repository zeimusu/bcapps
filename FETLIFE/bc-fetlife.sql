-- schema for FetLife db (both MySQL and SQLite3)

-- jloc = dotted location for join to (not yet created) fetlife_places

CREATE TABLE kinksters (
 id INT, screenname TEXT, age INT, gender TEXT, role TEXT, city TEXT,
 state TEXT, country text, thumbnail TEXT, popnum INT, popnumtotal INT,
 source TEXT, jloc TEXT, mtime INT);

-- indexes for MySQL

CREATE UNIQUE INDEX i0 ON kinksters(id);
CREATE INDEX i1 ON kinksters(screenname(20));
CREATE INDEX i2 ON kinksters(age);
CREATE INDEX i3 ON kinksters(gender(10));
CREATE INDEX i4 ON kinksters(role(10));
CREATE INDEX i5 ON kinksters(city(10));
CREATE INDEX i6 ON kinksters(state(10));
CREATE INDEX i7 ON kinksters(country(10));
CREATE INDEX i8 ON kinksters(jloc(20));

-- thumbnail view (MySQL)

DROP VIEW IF EXISTS thumbs;
CREATE VIEW thumbs AS 
 SELECT CONCAT("<img src='",thumbnail,"'>") AS img,
 CONCAT("<a href='https://fetlife.com/users/",id,"' target='_blank'>",
  screenname,"</a>") as link,
age, gender, role, city, state, country, popnum, popnumtotal, id
FROM kinksters;

-- modified as fetlife changes things

DROP VIEW IF EXISTS thumbs2;
CREATE VIEW thumbs2 AS 
 SELECT CONCAT("<img src='",REPLACE(thumbnail,"https://","")
 ,"'>") AS img, screenname AS link,
age, gender, role, city, state, country, popnum, popnumtotal, id
FROM kinksters;



-- import for MySQL

LOAD DATA LOCAL INFILE 
'/mnt/extdrive2/FETLIFE-BY-REGION/20150713/kinksters-here.txt'
IGNORE INTO TABLE kinksters FIELDS TERMINATED BY ',';

-- placecounts for google maps stuff (created as table, not view, for speed)

DROP TABLE IF EXISTS placecounts;

CREATE TABLE placecounts AS SELECT COUNT(*) AS
count,city,state,country,latitude,longitude FROM kinksters GROUP BY
city,state,country,latitude,longitude;

-- did this on 22 Jul 2017 since I can't hit remotes anyway

UPDATE kinksters SET thumbnail = REPLACE(thumbnail,"https://","");

