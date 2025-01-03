PGDMP  9    $                |         
   librarydb2    14.13    16.4 8    /           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            0           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            1           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            2           1262    18116 
   librarydb2    DATABASE        CREATE DATABASE librarydb2 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Turkish_T�rkiye.1254';
    DROP DATABASE librarydb2;
                postgres    false                        2615    2200    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                postgres    false            3           0    0    SCHEMA public    ACL     Q   REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
                   postgres    false    4            �            1255    18208    validate_email()    FUNCTION     �  CREATE FUNCTION public.validate_email() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
    -- E-posta alanı boşsa hata fırlat
    IF NEW.email IS NULL OR NEW.email = '' THEN
        RAISE EXCEPTION 'E-posta adresi boş olamaz.';
    END IF;

    -- E-posta formatını kontrol et
    IF NEW.email !~* '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$' THEN
        RAISE EXCEPTION 'Geçersiz e-posta formatı: %', NEW.email;
    END IF;

    RETURN NEW;
END;
$_$;
 '   DROP FUNCTION public.validate_email();
       public          postgres    false    4            �            1255    18199    validate_issue()    FUNCTION       CREATE FUNCTION public.validate_issue() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    book_count INT;
BEGIN
    -- Aynı öğrencinin aynı kitaptan tekrar alıp almadığını kontrol et
    IF EXISTS (
        SELECT 1
        FROM issue
        WHERE student_id = NEW.student_id
          AND book_id = NEW.book_id
    ) THEN
        RAISE EXCEPTION 'Student % has already issued book %.', NEW.student_id, NEW.book_id;
    END IF;

    -- Aynı öğrencinin toplamda kaç kitap ödünç aldığını kontrol et
    SELECT COUNT(*)
    INTO book_count
    FROM issue
    WHERE student_id = NEW.student_id;

    IF book_count >= 5 THEN
        RAISE EXCEPTION 'Student % cannot issue more than 5 books.', NEW.student_id;
    END IF;

    RETURN NEW;
END;
$$;
 '   DROP FUNCTION public.validate_issue();
       public          postgres    false    4            �            1255    18194    validate_password()    FUNCTION     �  CREATE FUNCTION public.validate_password() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
BEGIN
    -- Şifreyi kontrol et
    IF NEW.password !~ '^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>])(?=.{8,})' THEN
        RAISE EXCEPTION 'Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one special character.';
    END IF;

    RETURN NEW;
END;
$_$;
 *   DROP FUNCTION public.validate_password();
       public          postgres    false    4            �            1255    18197    validate_student_fields()    FUNCTION     �  CREATE FUNCTION public.validate_student_fields() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Year kontrolü
    IF NEW.student_year NOT IN (1, 2, 3, 4) THEN
        RAISE EXCEPTION 'Invalid year: %. Year must be one of 1, 2, 3, or 4.', NEW.student_year;
    END IF;

    -- Semester kontrolü
    IF NEW.student_sem NOT IN (1, 2, 3, 4, 5, 6, 7, 8) THEN
        RAISE EXCEPTION 'Invalid semester: %. Semester must be one of 1 to 8.', NEW.student_sem;
    END IF;

    -- Course kontrolü
    IF NEW.student_course NOT IN ('B Tech', 'BBA', 'MBA', 'BSC', 'BCA') THEN
        RAISE EXCEPTION 'Invalid course: %. Course must be one of B Tech, BBA, MBA, BSC, or BCA.', NEW.student_course;
    END IF;

    RETURN NEW;
END;
$$;
 0   DROP FUNCTION public.validate_student_fields();
       public          postgres    false    4            �            1259    18118    books    TABLE     �   CREATE TABLE public.books (
    book_id integer NOT NULL,
    book_name character varying(255) NOT NULL,
    book_edition character varying(100),
    book_publisher character varying(255),
    book_price numeric(10,2),
    book_page integer
);
    DROP TABLE public.books;
       public         heap    postgres    false    4            �            1259    18117    books_book_id_seq    SEQUENCE     �   CREATE SEQUENCE public.books_book_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.books_book_id_seq;
       public          postgres    false    210    4            4           0    0    books_book_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.books_book_id_seq OWNED BY public.books.book_id;
          public          postgres    false    209            �            1259    18146    issue    TABLE     �   CREATE TABLE public.issue (
    issue_id integer NOT NULL,
    student_id integer,
    book_id integer,
    date_of_issue date NOT NULL
);
    DROP TABLE public.issue;
       public         heap    postgres    false    4            �            1259    18145    issue_issue_id_seq    SEQUENCE     �   CREATE SEQUENCE public.issue_issue_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.issue_issue_id_seq;
       public          postgres    false    4    216            5           0    0    issue_issue_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.issue_issue_id_seq OWNED BY public.issue.issue_id;
          public          postgres    false    215            �            1259    18127    students    TABLE     T  CREATE TABLE public.students (
    student_id integer NOT NULL,
    student_name character varying(100) NOT NULL,
    student_surname character varying(100),
    student_father character varying(100),
    student_course character varying(100),
    student_branch character varying(100),
    student_year integer,
    student_sem integer
);
    DROP TABLE public.students;
       public         heap    postgres    false    4            �            1259    18189    issued_books_details    VIEW     �  CREATE VIEW public.issued_books_details AS
 SELECT i.book_id,
    b.book_name,
    b.book_edition,
    b.book_publisher,
    b.book_price,
    b.book_page,
    s.student_id,
    s.student_name,
    s.student_surname,
    s.student_father,
    s.student_course,
    s.student_branch,
    s.student_year,
    s.student_sem,
    i.date_of_issue
   FROM ((public.issue i
     JOIN public.books b ON ((i.book_id = b.book_id)))
     JOIN public.students s ON ((i.student_id = s.student_id)));
 '   DROP VIEW public.issued_books_details;
       public          postgres    false    210    210    210    210    210    210    212    212    212    212    212    212    212    212    216    216    216    4            �            1259    18163    return    TABLE     �   CREATE TABLE public.return (
    return_id integer NOT NULL,
    student_id integer,
    book_id integer,
    doi date NOT NULL,
    dor date
);
    DROP TABLE public.return;
       public         heap    postgres    false    4            �            1259    18162    return_return_id_seq    SEQUENCE     �   CREATE SEQUENCE public.return_return_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.return_return_id_seq;
       public          postgres    false    218    4            6           0    0    return_return_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.return_return_id_seq OWNED BY public.return.return_id;
          public          postgres    false    217            �            1259    18184    returned_books_details    VIEW     "  CREATE VIEW public.returned_books_details AS
 SELECT r.student_id,
    s.student_name,
    s.student_surname,
    s.student_father,
    s.student_course,
    s.student_branch,
    s.student_year,
    s.student_sem AS student_semester,
    r.book_id,
    b.book_name,
    b.book_edition,
    b.book_publisher,
    b.book_price,
    b.book_page,
    r.doi AS date_of_issue,
    r.dor AS date_of_return
   FROM ((public.return r
     JOIN public.students s ON ((r.student_id = s.student_id)))
     JOIN public.books b ON ((r.book_id = b.book_id)));
 )   DROP VIEW public.returned_books_details;
       public          postgres    false    210    210    210    210    210    212    212    212    212    212    212    212    212    218    218    218    218    210    4            �            1259    18126    students_student_id_seq    SEQUENCE     �   CREATE SEQUENCE public.students_student_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.students_student_id_seq;
       public          postgres    false    4    212            7           0    0    students_student_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.students_student_id_seq OWNED BY public.students.student_id;
          public          postgres    false    211            �            1259    18136    users    TABLE     �  CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    surname character varying(100),
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    security_question character varying(255),
    answer character varying(255),
    role character varying(20) DEFAULT 'user'::character varying
);
    DROP TABLE public.users;
       public         heap    postgres    false    4            �            1259    18135    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    214    4            8           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    213            |           2604    18121    books book_id    DEFAULT     n   ALTER TABLE ONLY public.books ALTER COLUMN book_id SET DEFAULT nextval('public.books_book_id_seq'::regclass);
 <   ALTER TABLE public.books ALTER COLUMN book_id DROP DEFAULT;
       public          postgres    false    209    210    210            �           2604    18149    issue issue_id    DEFAULT     p   ALTER TABLE ONLY public.issue ALTER COLUMN issue_id SET DEFAULT nextval('public.issue_issue_id_seq'::regclass);
 =   ALTER TABLE public.issue ALTER COLUMN issue_id DROP DEFAULT;
       public          postgres    false    215    216    216            �           2604    18166    return return_id    DEFAULT     t   ALTER TABLE ONLY public.return ALTER COLUMN return_id SET DEFAULT nextval('public.return_return_id_seq'::regclass);
 ?   ALTER TABLE public.return ALTER COLUMN return_id DROP DEFAULT;
       public          postgres    false    217    218    218            }           2604    18130    students student_id    DEFAULT     z   ALTER TABLE ONLY public.students ALTER COLUMN student_id SET DEFAULT nextval('public.students_student_id_seq'::regclass);
 B   ALTER TABLE public.students ALTER COLUMN student_id DROP DEFAULT;
       public          postgres    false    212    211    212            ~           2604    18139    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    214    213    214            $          0    18118    books 
   TABLE DATA           h   COPY public.books (book_id, book_name, book_edition, book_publisher, book_price, book_page) FROM stdin;
    public          postgres    false    210   M       *          0    18146    issue 
   TABLE DATA           M   COPY public.issue (issue_id, student_id, book_id, date_of_issue) FROM stdin;
    public          postgres    false    216   YN       ,          0    18163    return 
   TABLE DATA           J   COPY public.return (return_id, student_id, book_id, doi, dor) FROM stdin;
    public          postgres    false    218   �N       &          0    18127    students 
   TABLE DATA           �   COPY public.students (student_id, student_name, student_surname, student_father, student_course, student_branch, student_year, student_sem) FROM stdin;
    public          postgres    false    212   �N       (          0    18136    users 
   TABLE DATA           n   COPY public.users (id, name, surname, username, email, password, security_question, answer, role) FROM stdin;
    public          postgres    false    214   JP       9           0    0    books_book_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.books_book_id_seq', 7, true);
          public          postgres    false    209            :           0    0    issue_issue_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.issue_issue_id_seq', 27, true);
          public          postgres    false    215            ;           0    0    return_return_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.return_return_id_seq', 8, true);
          public          postgres    false    217            <           0    0    students_student_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.students_student_id_seq', 8, true);
          public          postgres    false    211            =           0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 28, true);
          public          postgres    false    213            �           2606    18125    books books_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (book_id);
 :   ALTER TABLE ONLY public.books DROP CONSTRAINT books_pkey;
       public            postgres    false    210            �           2606    18151    issue issue_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_pkey PRIMARY KEY (issue_id);
 :   ALTER TABLE ONLY public.issue DROP CONSTRAINT issue_pkey;
       public            postgres    false    216            �           2606    18168    return return_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.return
    ADD CONSTRAINT return_pkey PRIMARY KEY (return_id);
 <   ALTER TABLE ONLY public.return DROP CONSTRAINT return_pkey;
       public            postgres    false    218            �           2606    18134    students students_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (student_id);
 @   ALTER TABLE ONLY public.students DROP CONSTRAINT students_pkey;
       public            postgres    false    212            �           2606    18202    users unique_username 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT unique_username UNIQUE (username);
 ?   ALTER TABLE ONLY public.users DROP CONSTRAINT unique_username;
       public            postgres    false    214            �           2606    18144    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    214            �           2620    18200    issue issue_validation_trigger    TRIGGER     }   CREATE TRIGGER issue_validation_trigger BEFORE INSERT ON public.issue FOR EACH ROW EXECUTE FUNCTION public.validate_issue();
 7   DROP TRIGGER issue_validation_trigger ON public.issue;
       public          postgres    false    216    223            �           2620    18195 !   users password_validation_trigger    TRIGGER     �   CREATE TRIGGER password_validation_trigger BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.validate_password();
 :   DROP TRIGGER password_validation_trigger ON public.users;
       public          postgres    false    221    214            �           2620    18198 #   students student_validation_trigger    TRIGGER     �   CREATE TRIGGER student_validation_trigger BEFORE INSERT OR UPDATE ON public.students FOR EACH ROW EXECUTE FUNCTION public.validate_student_fields();
 <   DROP TRIGGER student_validation_trigger ON public.students;
       public          postgres    false    222    212            �           2620    18212    users validate_email_trigger    TRIGGER     �   CREATE TRIGGER validate_email_trigger BEFORE INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.validate_email();
 5   DROP TRIGGER validate_email_trigger ON public.users;
       public          postgres    false    214    235            �           2606    18157    issue issue_book_id_fkey    FK CONSTRAINT     |   ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(book_id);
 B   ALTER TABLE ONLY public.issue DROP CONSTRAINT issue_book_id_fkey;
       public          postgres    false    3203    210    216            �           2606    18152    issue issue_student_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.issue
    ADD CONSTRAINT issue_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(student_id);
 E   ALTER TABLE ONLY public.issue DROP CONSTRAINT issue_student_id_fkey;
       public          postgres    false    3205    216    212            �           2606    18174    return return_book_id_fkey    FK CONSTRAINT     ~   ALTER TABLE ONLY public.return
    ADD CONSTRAINT return_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(book_id);
 D   ALTER TABLE ONLY public.return DROP CONSTRAINT return_book_id_fkey;
       public          postgres    false    210    218    3203            �           2606    18169    return return_student_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.return
    ADD CONSTRAINT return_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(student_id);
 G   ALTER TABLE ONLY public.return DROP CONSTRAINT return_student_id_fkey;
       public          postgres    false    218    3205    212            $   ,  x�=�KN�0���s��ΣI���V}��VBHl�dhM]����p*��i%��~�|�(�z\kQ��7G��;�-(�i>�T��5���ٴ�ڵ�fz���!�`��ݥ�@�k��E��I����z�a���!�Ą�=��q[>|Q����Ǳi�P������~Db��Cn�bϚoґ0�%y�z��Cz�4-Dy5���b�0��SOP�<G���31(uc�B�u�߮���D�1^���L���e"%dR�4��<B��yO�ȟd-�l�1Pʲ��z��Ν��A*�g�&B�?Wk�      *   ?   x�34�4�4�4202�54�5��24�4F1���X �&("�@Sd#3N��0s�=...  ��      ,   3   x�3�4B##]C#]#$&�)�1N93N3�r��&8�,����qqq �"�      &   O  x�mP[N�@��9Ŝ b�X§���d�""~Ӭ[;�A��"s�p��as���%��V�T��]Njƺ����7jgX�k�T�}�#���u.�0	Jww^��-�WRV.�����x=,Q��f@�Ԥ�
Ne�O�u����+R�p��"7��t�ip>໿�푕�
�������,�5�nG�N�1-Hgg|�h5R���s݈2��x]f�,;�M���������85���cj"=ɓ�A�����Q4-���N�O�<��T��qSe��~�G6��'}:��e�	�?��E����Y��;$&_��Ƀ���}Q����<���~2��k
�0      (     x���͎�0��ӧȊ���I�OvU��mR���nl��N�/�[��`�IڭT�%��h�?χ��Ka�<b���OQ@������L"m�e��I�
>3�#n�R&�:g�D�VYAo`Y�-�p-�j�#�ch��s
s�r�2�)}B���ݱ��Gc��'چ�G�q�fZ����T�o`ƅ(��Դ�1�R��X
m`��<����$�~�g��H�t�}�<v�3VӒ<X\Q!�LK����2�=شr����|o�"�n&1��j�2������ U`:߼��mS�	m���Lg�����7�'+8�
K�8��Ч��F�w�;�k*���{0�aA�d�:Ӟ�����������iƝ�aV��[�
��W�fx����9_��{j��FH`���T0Ec�Z)v.���d�:G��y���]���*�S������2?M
��j�kJ���g�*��Y�Eϳ�`b��������&����qv<���9�-3�{7?@W��u0�:��"i�Cu"}m�Z��:v�Y     