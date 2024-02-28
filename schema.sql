CREATE TABLE lists (
	id serial PRIMARY KEY,
	name text UNIQUE
);

CREATE TABLE todos (
	id serial PRIMARY KEY,
	name text,
	list_id integer UNIQUE NOT NULL,
	status boolean DEFAULT false,
  FOREIGN KEY (list_id) REFERENCES lists(id) 
);