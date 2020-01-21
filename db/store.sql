--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.6
-- Dumped by pg_dump version 9.6.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: store; Type: SCHEMA; Schema: -; Owner: gsip
--

CREATE SCHEMA store;


ALTER SCHEMA store OWNER TO gsip;

SET search_path = store, pg_catalog;

--
-- Name: insert_literal_triple(); Type: FUNCTION; Schema: store; Owner: gsip
--

CREATE FUNCTION insert_literal_triple() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE 

	v_s_id store.t_literal.r_id%TYPE;

	v_p_id store.t_literal.p_id%TYPE;

	v_c_id store.t_literal.ctx_id%TYPE;

	v_type_id store.t_literal.l_type%TYPE;

BEGIN

-- naive implementation, to be improved

-- get a s_id

	SELECT r_id into v_s_id from store.resources WHERE uri = NEW.subj;

	IF NOT(FOUND) THEN

		INSERT INTO store.resources (uri) VALUES (NEW.subj) RETURNING r_id INTO v_s_id;

	END IF;

-- get a p_id

	SELECT r_id into v_p_id from store.resources WHERE uri = NEW.pred;

	IF NOT(FOUND) THEN

		INSERT INTO store.resources (uri) VALUES (NEW.pred) RETURNING r_id INTO v_p_id;

	END IF;

		-- get a type

	SELECT l_type INTO v_type_id from store.lit_types WHERE type = NEW.type;

	IF NOT(FOUND) THEN

		INSERT INTO store.lit_types(type) VALUES(NEW.type) returning l_type INTO v_type_id;

	END IF;



	

-- get a context

select r_id into v_c_id from store.resources WHERE uri = NEW.ctx;

	IF NOT(FOUND) THEN

		INSERT INTO store.resources (uri) VALUES (NEW.ctx) RETURNING r_id INTO v_c_id;

	END IF;

	

-- INSERT this new entry

INSERT INTO store.t_literal (r_id,p_id,lit,lang,l_type,ctx_id) VALUES (v_s_id,v_p_id,NEW.lit,NEW.lang,v_type_id,v_c_id);



RETURN NEW;

END;

$$;


ALTER FUNCTION store.insert_literal_triple() OWNER TO gsip;

--
-- Name: insert_resource_triple(); Type: FUNCTION; Schema: store; Owner: gsip
--

CREATE FUNCTION insert_resource_triple() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE 

	v_s_id store.t_resource.r_id%TYPE;

	v_p_id store.t_resource.p_id%TYPE;

	v_o_id store.t_resource.o_id%TYPE;

	v_c_id store.t_resource.ctx_id%TYPE;

BEGIN

-- naive implementation, to be improved

-- get a s_id

	SELECT r_id into v_s_id from store.resources WHERE uri = NEW.subj;

	IF NOT(FOUND) THEN

		INSERT INTO store.resources (uri) VALUES (NEW.subj) RETURNING r_id INTO v_s_id;

	END IF;

-- get a p_id

	SELECT r_id into v_p_id from store.resources WHERE uri = NEW.pred;

	IF NOT(FOUND) THEN

		INSERT INTO store.resources (uri) VALUES (NEW.pred) RETURNING r_id INTO v_p_id;

	END IF;

		-- get a o_id



SELECT r_id into v_o_id from store.resources WHERE uri = NEW.obj;

	IF NOT(FOUND) THEN

		INSERT INTO store.resources (uri) VALUES (NEW.obj) RETURNING r_id INTO v_o_id;

	END IF;

	

-- get a context

select r_id into v_c_id from store.resources WHERE uri = NEW.ctx;

	IF NOT(FOUND) THEN

		INSERT INTO store.resources (uri) VALUES (NEW.ctx) RETURNING r_id INTO v_c_id;

	END IF;

	

-- INSERT this new entry

INSERT INTO store.t_resource (r_id,p_id,o_id,ctx_id) VALUES (v_s_id,v_p_id,v_o_id,v_c_id);



RETURN NEW;

END;

$$;


ALTER FUNCTION store.insert_resource_triple() OWNER TO gsip;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: lit_types; Type: TABLE; Schema: store; Owner: gsip
--

CREATE TABLE lit_types (
    l_type integer NOT NULL,
    type character varying(50)
);


ALTER TABLE lit_types OWNER TO gsip;

--
-- Name: TABLE lit_types; Type: COMMENT; Schema: store; Owner: gsip
--

COMMENT ON TABLE lit_types IS 'literal types (^^ stuff after the literal, default is ''string'')';


--
-- Name: COLUMN lit_types.type; Type: COMMENT; Schema: store; Owner: gsip
--

COMMENT ON COLUMN lit_types.type IS 'type (in the form ^^xsd:string)';


--
-- Name: lit_types_l_type_seq; Type: SEQUENCE; Schema: store; Owner: gsip
--

CREATE SEQUENCE lit_types_l_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lit_types_l_type_seq OWNER TO gsip;

--
-- Name: lit_types_l_type_seq; Type: SEQUENCE OWNED BY; Schema: store; Owner: gsip
--

ALTER SEQUENCE lit_types_l_type_seq OWNED BY lit_types.l_type;


--
-- Name: resources; Type: TABLE; Schema: store; Owner: gsip
--

CREATE TABLE resources (
    r_id integer NOT NULL,
    uri character varying(255)
);


ALTER TABLE resources OWNER TO gsip;

--
-- Name: TABLE resources; Type: COMMENT; Schema: store; Owner: gsip
--

COMMENT ON TABLE resources IS 'resource (URI) instances. can be either a resource or a predicate';


--
-- Name: COLUMN resources.uri; Type: COMMENT; Schema: store; Owner: gsip
--

COMMENT ON COLUMN resources.uri IS 'fully qualified URI (no prefix)';


--
-- Name: t_literal; Type: TABLE; Schema: store; Owner: gsip
--

CREATE TABLE t_literal (
    r_id integer,
    p_id integer,
    lit text,
    l_type integer DEFAULT 0,
    lang character varying(2) DEFAULT NULL::character varying,
    ctx_id integer
);


ALTER TABLE t_literal OWNER TO gsip;

--
-- Name: literal_triples; Type: VIEW; Schema: store; Owner: gsip
--

CREATE VIEW literal_triples AS
 SELECT rs.uri AS subj,
    rp.uri AS pred,
    tl.lit,
    tl.lang,
    lt.type,
    rc.uri AS ctx
   FROM ((((t_literal tl
     JOIN resources rs ON ((tl.r_id = rs.r_id)))
     JOIN resources rp ON ((tl.p_id = rp.r_id)))
     JOIN resources rc ON ((tl.ctx_id = rc.r_id)))
     JOIN lit_types lt ON ((tl.l_type = lt.l_type)));


ALTER TABLE literal_triples OWNER TO gsip;

--
-- Name: t_resource; Type: TABLE; Schema: store; Owner: gsip
--

CREATE TABLE t_resource (
    r_id integer,
    p_id integer,
    o_id integer,
    ctx_id integer
);


ALTER TABLE t_resource OWNER TO gsip;

--
-- Name: TABLE t_resource; Type: COMMENT; Schema: store; Owner: gsip
--

COMMENT ON TABLE t_resource IS 'a triple made of resource-predicate-resource (so, everything are resources)';


--
-- Name: resource_triples; Type: VIEW; Schema: store; Owner: gsip
--

CREATE VIEW resource_triples AS
 SELECT rs.uri AS subj,
    rp.uri AS pred,
    ro.uri AS obj,
    rc.uri AS ctx
   FROM ((((t_resource tr
     JOIN resources rs ON ((tr.r_id = rs.r_id)))
     JOIN resources rp ON ((tr.p_id = rp.r_id)))
     JOIN resources ro ON ((tr.o_id = ro.r_id)))
     JOIN resources rc ON ((tr.ctx_id = rc.r_id)));


ALTER TABLE resource_triples OWNER TO gsip;

--
-- Name: resources_r_id_seq; Type: SEQUENCE; Schema: store; Owner: gsip
--

CREATE SEQUENCE resources_r_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE resources_r_id_seq OWNER TO gsip;

--
-- Name: resources_r_id_seq; Type: SEQUENCE OWNED BY; Schema: store; Owner: gsip
--

ALTER SEQUENCE resources_r_id_seq OWNED BY resources.r_id;


--
-- Name: ttl_resources; Type: VIEW; Schema: store; Owner: gsip
--

CREATE VIEW ttl_resources AS
 SELECT (((((('<'::text || (rt.subj)::text) || '> <'::text) || (rt.pred)::text) || '> <'::text) || (rt.obj)::text) || '>.'::text) AS "# triples"
   FROM resource_triples rt;


ALTER TABLE ttl_resources OWNER TO gsip;

--
-- Name: lit_types l_type; Type: DEFAULT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY lit_types ALTER COLUMN l_type SET DEFAULT nextval('lit_types_l_type_seq'::regclass);


--
-- Name: resources r_id; Type: DEFAULT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY resources ALTER COLUMN r_id SET DEFAULT nextval('resources_r_id_seq'::regclass);


--
-- Name: lit_types pk_lit_types; Type: CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY lit_types
    ADD CONSTRAINT pk_lit_types PRIMARY KEY (l_type);


--
-- Name: resources pk_resources; Type: CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT pk_resources PRIMARY KEY (r_id);


--
-- Name: ixfk_t_literal_lit_types; Type: INDEX; Schema: store; Owner: gsip
--

CREATE INDEX ixfk_t_literal_lit_types ON t_literal USING btree (l_type);


--
-- Name: ixfk_t_literal_resources; Type: INDEX; Schema: store; Owner: gsip
--

CREATE INDEX ixfk_t_literal_resources ON t_literal USING btree (r_id);


--
-- Name: ixfk_t_literal_resources_02; Type: INDEX; Schema: store; Owner: gsip
--

CREATE INDEX ixfk_t_literal_resources_02 ON t_literal USING btree (p_id);


--
-- Name: ixfk_t_literal_resources_03; Type: INDEX; Schema: store; Owner: gsip
--

CREATE INDEX ixfk_t_literal_resources_03 ON t_literal USING btree (ctx_id);


--
-- Name: ixfk_t_resource_resources; Type: INDEX; Schema: store; Owner: gsip
--

CREATE INDEX ixfk_t_resource_resources ON t_resource USING btree (r_id);


--
-- Name: ixfk_t_resource_resources_02; Type: INDEX; Schema: store; Owner: gsip
--

CREATE INDEX ixfk_t_resource_resources_02 ON t_resource USING btree (p_id);


--
-- Name: ixfk_t_resource_resources_03; Type: INDEX; Schema: store; Owner: gsip
--

CREATE INDEX ixfk_t_resource_resources_03 ON t_resource USING btree (o_id);


--
-- Name: ixfk_t_resource_resources_04; Type: INDEX; Schema: store; Owner: gsip
--

CREATE INDEX ixfk_t_resource_resources_04 ON t_resource USING btree (ctx_id);


--
-- Name: uri_index; Type: INDEX; Schema: store; Owner: gsip
--

CREATE UNIQUE INDEX uri_index ON resources USING btree (uri);


--
-- Name: literal_triples literal_triple_insert; Type: TRIGGER; Schema: store; Owner: gsip
--

CREATE TRIGGER literal_triple_insert INSTEAD OF INSERT ON literal_triples FOR EACH ROW EXECUTE PROCEDURE insert_literal_triple();


--
-- Name: resource_triples resource_triple_insert; Type: TRIGGER; Schema: store; Owner: gsip
--

CREATE TRIGGER resource_triple_insert INSTEAD OF INSERT ON resource_triples FOR EACH ROW EXECUTE PROCEDURE insert_resource_triple();


--
-- Name: t_literal fk_t_literal_lit_types; Type: FK CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY t_literal
    ADD CONSTRAINT fk_t_literal_lit_types FOREIGN KEY (l_type) REFERENCES lit_types(l_type);


--
-- Name: t_literal fk_t_literal_resources; Type: FK CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY t_literal
    ADD CONSTRAINT fk_t_literal_resources FOREIGN KEY (r_id) REFERENCES resources(r_id);


--
-- Name: t_literal fk_t_literal_resources_02; Type: FK CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY t_literal
    ADD CONSTRAINT fk_t_literal_resources_02 FOREIGN KEY (p_id) REFERENCES resources(r_id);


--
-- Name: t_literal fk_t_literal_resources_03; Type: FK CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY t_literal
    ADD CONSTRAINT fk_t_literal_resources_03 FOREIGN KEY (ctx_id) REFERENCES resources(r_id);


--
-- Name: t_resource fk_t_resource_resources; Type: FK CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY t_resource
    ADD CONSTRAINT fk_t_resource_resources FOREIGN KEY (r_id) REFERENCES resources(r_id);


--
-- Name: t_resource fk_t_resource_resources_02; Type: FK CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY t_resource
    ADD CONSTRAINT fk_t_resource_resources_02 FOREIGN KEY (p_id) REFERENCES resources(r_id);


--
-- Name: t_resource fk_t_resource_resources_03; Type: FK CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY t_resource
    ADD CONSTRAINT fk_t_resource_resources_03 FOREIGN KEY (o_id) REFERENCES resources(r_id);


--
-- Name: t_resource fk_t_resource_resources_04; Type: FK CONSTRAINT; Schema: store; Owner: gsip
--

ALTER TABLE ONLY t_resource
    ADD CONSTRAINT fk_t_resource_resources_04 FOREIGN KEY (ctx_id) REFERENCES resources(r_id);


--
-- PostgreSQL database dump complete
--

