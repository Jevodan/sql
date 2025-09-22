--
-- PostgreSQL database dump
--

-- Dumped from database version 11.22 (Debian 11.22-0+deb10u2)
-- Dumped by pg_dump version 11.22 (Debian 11.22-0+deb10u2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: get_cumulative_work_data(date, date, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
-- сводные данные с фильтром по входным параметрам и группировкой по году/месяцу, с  накопительным итогом.
--


CREATE FUNCTION public.get_cumulative_work_data(p_start_date date, p_end_date date, p_obj character varying, p_work_type character varying) RETURNS TABLE(month_year text, cumulative_planned_amount numeric, cumulative_actual_amount numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH monthly_summary AS (
        SELECT
            TO_CHAR(work_date, 'YYYY-MM') AS month_year_summary,
            SUM(planned_amount) AS planned_amount,
            SUM(actual_amount) AS actual_amount
        FROM work_data
        WHERE work_date BETWEEN p_start_date AND p_end_date
          AND object ILIKE p_obj
          AND work_type ILIKE p_work_type
        GROUP BY month_year_summary
        ORDER BY month_year_summary
    )
    SELECT 
        month_year_summary AS month_year,
        SUM(planned_amount) OVER (ORDER BY month_year_summary) AS cumulative_planned_amount,
        SUM(actual_amount) OVER (ORDER BY month_year_summary) AS cumulative_actual_amount
    FROM monthly_summary;
END;
$$;


ALTER FUNCTION public.get_cumulative_work_data(p_start_date date, p_end_date date, p_obj character varying, p_work_type character varying) OWNER TO postgres;

--
-- Name: get_not_cumulative_work_data(date, date, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--
-- сводные данные с фильтром по входным параметрам и группировкой по году/месяцу, без  накопительного итога.

CREATE FUNCTION public.get_not_cumulative_work_data(p_start_date date, p_end_date date, p_obj character varying, p_work_type character varying) RETURNS TABLE(month_year text, plan_amount numeric, act_amount numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY  
        SELECT
            TO_CHAR(work_date, 'YYYY-MM') AS month_year,
            SUM(planned_amount) AS planned_amount,
            SUM(actual_amount) AS actual_amount
        FROM work_data
        WHERE work_date BETWEEN p_start_date AND p_end_date
          AND object ILIKE p_obj
          AND work_type ILIKE p_work_type
        GROUP BY month_year
        ORDER BY month_year;  
END;
$$;


ALTER FUNCTION public.get_not_cumulative_work_data(p_start_date date, p_end_date date, p_obj character varying, p_work_type character varying) OWNER TO postgres;

--
-- Name: load_work_data_from_csv(text); Type: PROCEDURE; Schema: public; Owner: postgres
-- Процедура загрузки данных в таблицу из файла 

CREATE PROCEDURE public.load_work_data_from_csv(file_path text)
    LANGUAGE plpgsql
    AS $$
BEGIN  
    EXECUTE format('COPY work_data (object, work_type, work_date, planned_amount, actual_amount) FROM %L WITH (FORMAT csv, DELIMITER '';'', HEADER true)', file_path);
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error loading data from file: %, Error: %', file_path, SQLERRM;
END;
$$;


ALTER PROCEDURE public.load_work_data_from_csv(file_path text) OWNER TO postgres;


--
-- Name: get_list_data(); Type: FUNCTION; Schema: public; Owner: postgres
-- список сгрупированных дат (год месяц) - для выпадающего списка

CREATE FUNCTION public.get_list_data() RETURNS TABLE(month_year text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY   
         SELECT TO_CHAR(work_date, 'YYYY-MM')
   FROM work_data 
   GROUP BY TO_CHAR(work_date, 'YYYY-MM') 
   ORDER BY TO_CHAR(work_date, 'YYYY-MM');
END;
$$;


ALTER FUNCTION public.get_list_data() OWNER TO postgres;

--
-- Name: get_list_object(); Type: FUNCTION; Schema: public; Owner: postgres
--
-- список объектов - для выпадающего списка

CREATE FUNCTION public.get_list_object() RETURNS TABLE(obj character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY   
        SELECT object 
  FROM work_data 
  GROUP BY object  
  ORDER BY object;
END;
$$;


ALTER FUNCTION public.get_list_object() OWNER TO postgres;

--
-- Name: get_list_types(); Type: FUNCTION; Schema: public; Owner: postgres
--
-- список работ - для выпадающего списка

CREATE FUNCTION public.get_list_types() RETURNS TABLE(job character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY   
        SELECT work_type 
  FROM work_data 
  GROUP BY work_type  
  ORDER BY work_type;
END;
$$;


ALTER FUNCTION public.get_list_types() OWNER TO postgres;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: work; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work (
    id integer NOT NULL,
    object character varying(255),
    work_type character varying(255),
    work_date date,
    planned_amount numeric,
    actual_amount numeric
);


ALTER TABLE public.work OWNER TO postgres;

--
-- Name: work_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_data (
    id integer NOT NULL,
    object character varying(255),
    work_type character varying(255),
    work_date date,
    planned_amount numeric,
    actual_amount numeric
);


ALTER TABLE public.work_data OWNER TO postgres;

--
-- Name: work_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.work_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.work_data_id_seq OWNER TO postgres;

--
-- Name: work_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.work_data_id_seq OWNED BY public.work_data.id;


--
-- Name: work_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.work_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.work_id_seq OWNER TO postgres;

--
-- Name: work_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.work_id_seq OWNED BY public.work.id;


--
-- Name: work id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work ALTER COLUMN id SET DEFAULT nextval('public.work_id_seq'::regclass);


--
-- Name: work_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_data ALTER COLUMN id SET DEFAULT nextval('public.work_data_id_seq'::regclass);


--
-- Data for Name: work; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work (id, object, work_type, work_date, planned_amount, actual_amount) FROM stdin;
\.


--
-- Data for Name: work_data; Type: TABLE DATA; Schema: public; Owner: postgres
-- актуальные данные

COPY public.work_data (id, object, work_type, work_date, planned_amount, actual_amount) FROM stdin;
31	Airport	foundation	2023-01-20	1000	1300
32	Airport	floors	2023-01-21	1000	1300
33	Airport	facing	2023-01-22	1000	1300
34	TETRA	facing	2023-07-23	1000	1300
35	TETRA	foundation	2023-01-24	1000	1300
36	TETRA	foundation	2023-01-25	1000	1300
37	Quartet	foundation	2023-04-26	1000	1300
38	Quartet	foundation	2022-01-27	1000	1300
39	Quartet	floors	2023-01-28	1000	1300
40	Quartet	floors	2023-02-25	1000	1300
41	Quartet	facing	2023-01-30	1000	1300
42	Airport	foundation	2023-01-15	1000	1300
47	Airport	foundation	2023-01-20	1000	1300
48	Airport	floors	2023-01-21	1000	1300
49	Airport	facing	2023-01-22	1000	1300
50	TETRA	facing	2023-07-23	1000	1300
51	TETRA	foundation	2023-01-24	1000	1300
52	TETRA	foundation	2023-01-25	1000	1300
53	Quartet	foundation	2023-04-26	1000	1300
54	Quartet	foundation	2022-01-27	1000	1300
55	Quartet	floors	2023-01-28	1000	1300
56	Quartet	floors	2023-02-23	1000	1300
57	Quartet	facing	2023-01-30	1000	1300
62	Airport	foundation	2022-01-20	1000	1300
63	Airport	floors	2021-03-21	1000	1300
64	Airport	facing	2023-04-22	1000	1300
65	TETRA	facing	2021-07-23	1000	1300
66	TETRA	foundation	2022-07-24	1000	1300
67	TETRA	foundation	2023-06-25	1000	1300
68	Quartet	foundation	2025-04-26	1000	1300
69	Quartet	foundation	2021-02-27	1000	1300
70	Quartet	floors	2020-01-28	1000	1300
71	Quartet	floors	2023-02-25	1000	1300
72	Quartet	facing	2023-01-30	1000	1300
73	Airport	foundation	2023-01-15	1000	1300
78	Airport	foundation	2023-01-20	1000	1300
79	Airport	floors	2023-03-21	1000	1300
80	Airport	facing	2023-01-22	1000	1300
81	TETRA	facing	2023-07-23	1000	1300
82	TETRA	foundation	2023-04-24	1000	1300
83	TETRA	foundation	2023-06-25	1000	1300
84	Quartet	foundation	2023-04-26	1000	1300
85	Quartet	foundation	2021-03-27	1000	1300
86	Quartet	floors	2023-01-28	1000	1300
87	Quartet	floors	2024-02-23	1000	1300
88	Quartet	facing	2023-01-30	1000	1300
89	Quartet	floors	2023-02-25	1000	1300
90	Quartet	facing	2023-01-30	1000	1300
91	Airport	foundation	2023-01-15	1000	1300
96	Airport	foundation	2023-01-20	1000	1300
97	Airport	floors	2023-03-21	1000	1300
98	Airport	facing	2023-01-22	1000	1300
99	TETRA	facing	2023-07-23	1000	1300
100	TETRA	foundation	2023-04-24	1000	1300
101	TETRA	foundation	2023-06-25	1000	1300
102	Quartet	foundation	2023-04-26	1000	1300
103	Quartet	foundation	2021-03-27	1000	1300
104	Quartet	floors	2023-01-28	1000	1300
105	Quartet	floors	2024-02-23	1000	1300
106	Quartet	facing	2023-01-30	1000	1300
28	Sports palace	floors	2024-01-17	1000	1300
29	Sports palace	floors	2023-04-18	1000	1300
30	Sports palace	foundation	2023-05-19	1000	1300
44	Sports palace	floors	2024-01-17	1000	1300
45	Sports palace	floors	2023-04-18	1000	1300
46	Sports palace	foundation	2023-05-19	1000	1300
59	Sports palace	floors	2023-03-17	1000	1300
60	Sports palace	floors	2025-04-18	1000	1300
61	Sports palace	foundation	2020-05-19	1000	1300
75	Sports palace	floors	2024-04-17	1000	1300
76	Sports palace	floors	2023-04-18	1000	1300
77	Sports palace	foundation	2023-05-19	1000	1300
93	Sports palace	floors	2024-04-17	1000	1300
94	Sports palace	floors	2023-04-18	1000	1300
95	Sports palace	foundation	2023-05-19	1000	1300
\.


--
-- Name: work_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.work_data_id_seq', 106, true);


--
-- Name: work_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.work_id_seq', 1, false);


--
-- Name: work_data work_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_data
    ADD CONSTRAINT work_data_pkey PRIMARY KEY (id);


--
-- Name: work work_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work
    ADD CONSTRAINT work_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

