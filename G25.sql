DROP TABLE SERVICIO CASCADE;
DROP TABLE INHUMACION CASCADE;
DROP TABLE TRASLADOS CASCADE;
DROP TABLE CESION_USO CASCADE;
DROP TABLE TASA CASCADE;
DROP TABLE OBRA CASCADE;
DROP TABLE SOLICITANTE CASCADE;
DROP TABLE UE CASCADE;
DROP TABLE BENEFICIARIO CASCADE;
DROP TABLE TITULAR CASCADE;
DROP TABLE TITULO CASCADE;
DROP TABLE FALLECIDO CASCADE;
DROP TYPE TIPO_UE CASCADE;
DROP TYPE TIPO_SERVI CASCADE;
DROP TYPE SEXO CASCADE;
DROP TYPE ESTADO_TITULO CASCADE;
DROP TYPE CONCEPTO_TASA CASCADE;
DROP TYPE CARACTER_TITULO CASCADE;

CREATE TYPE TIPO_UE AS
ENUM('Panteon','Capilla','Sepultura','Nicho','Columbario','Osario');

CREATE TYPE TIPO_SERVI AS
ENUM('inhumación','exhumación','cremación','traslado','reduccion');

CREATE TYPE SEXO AS
ENUM('Varon','Mujer');

CREATE TYPE ESTADO_TITULO AS
ENUM('Extinto','Activo', 'Provisional', 'Caducado');

CREATE TYPE CONCEPTO_TASA AS
ENUM('Obras','Título','Mantenimiento_UE','Servicio','ProrrogaCesionDeUso');

CREATE TYPE CARACTER_TITULO AS
ENUM('Testamentario','Intestado','Gratuito');

CREATE TABLE UE(
  id_unidad           INTEGER NOT NULL,
  tipo_ue             TIPO_UE NOT NULL,
  departamentos       INTEGER NOT NULL,
  localizacion        VARCHAR NOT NULL,
  fecha_construccion     DATE,
  unidad_predecesora  INTEGER,
  fecha_concesion     DATE NOT NULL,
  primary key(id_Unidad),
  foreign key(unidad_predecesora) references UE
  ON DELETE CASCADE
  ON UPDATE CASCADE
  /*constraint CHK_pantYcap CHECK ((tipo_ue = 'Capilla' and unidad_predecesora is NULL)
                                or(tipo_ue = 'Panteon' and unidad_predecesora is NULL))*/
);

CREATE TABLE BENEFICIARIO(
  nif_beneficiario      CHAR(9) NOT NULL,
  nombre                          VARCHAR,
  apellidos                       VARCHAR,
  domicilio                       VARCHAR,
  beneficiario_sustituto          CHAR(9),
  primary key(nif_beneficiario)
);

CREATE TABLE TITULAR(
  nif_titular           CHAR(9) NOT NULL,
  nombre                         VARCHAR,
  apellidos                      VARCHAR,
  domicilio                      VARCHAR,
  fecha_nacimiento                  DATE,
  primary key(nif_titular),
  constraint CHK_titular CHECK ((DATE_PART('year',CURRENT_DATE)-DATE_PART('year',fecha_nacimiento)) >= 18 )
);

CREATE TABLE TITULO(
  id_titulo           INTEGER NOT NULL,
  id_unidad           INTEGER NOT NULL,
  nif_beneficiario    CHAR(9),
  nif_titular         CHAR(9) NOT NULL,
  fecha_adjudicacion  DATE NOT NULL,
  caracter_adjudicacion CARACTER_TITULO NOT NULL,
  estado_titulo       ESTADO_TITULO,
  primary key (id_titulo),
  foreign key (id_unidad) references UE(id_unidad),
  foreign key (nif_beneficiario) references BENEFICIARIO,
  foreign key (nif_titular) references TITULAR
);

CREATE TABLE OBRA(
  id_obra         INTEGER NOT NULL,
  licencia          INTEGER NOT NULL,
  fecha_inicio                  DATE,
  fecha_fin                     DATE,
  primary key (id_obra,licencia),
  foreign key (id_obra) references UE
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  constraint CHK_fechasobra CHECK(fecha_inicio<fecha_fin)
);

CREATE TABLE FALLECIDO(
  nif_fallecido        CHAR(9) NOT NULL,
  id_titulo            INTEGER NOT NULL,
  nombre                        VARCHAR,
  apellidos                     VARCHAR,
  sexo                    SEXO NOT NULL,
  domicilio                     VARCHAR,
  lugar_fallecimiento           VARCHAR,
  fecha_defuncion           TIMESTAMPTZ,
  primary key (nif_fallecido),
  foreign key (id_titulo) references TITULO(id_titulo),
  constraint CHK_defun48 CHECK((DATE_PART('hour',CURRENT_DATE)-DATE_PART('hour',fecha_defuncion))<=48)/*,
  constraint CHK_defun24 CHECK((DATE_PART('hour',CURRENT_DATE)-DATE_PART('hour',fecha_defuncion))>=24)*/
);

CREATE TABLE SOLICITANTE(
  nif_solicitante     CHAR(9) NOT NULL,
  nombre              VARCHAR,
  apellidos           VARCHAR,
  domicilio           VARCHAR,
  primary key (nif_solicitante)
);

CREATE TABLE SERVICIO(
  id_servicio       INTEGER NOT NULL UNIQUE,
  nif_solicitante   CHAR(9) NOT NULL,
  id_unidad         INTEGER NOT NULL,
  nif_fallecido      CHAR(9) NOT NULL,
  fecha             DATE NOT NULL,
  certificado       BIT NOT NULL,
  parte_anatomica   VARCHAR,
  tipo_servicio     TIPO_SERVI,
  primary key(id_servicio),
  foreign key(id_unidad) references UE
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  foreign key(nif_solicitante) references SOLICITANTE,
  foreign key(nif_fallecido) references FALLECIDO
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE INHUMACION(
  id_servicio INTEGER NOT NULL,
  hora TIME,
  primary key(id_servicio),
  foreign key(id_servicio) references SERVICIO(id_servicio)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

--Hemos puesto el nombre TRASLADOS pero en esta tabla entran también las exhumaciones y reducciones
CREATE TABLE TRASLADOS(
  id_servicio INTEGER NOT NULL,
  ubicacion_origen VARCHAR,
  hora        TIME,
  primary key(id_servicio),
  foreign key(id_servicio) references SERVICIO(id_servicio)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);

CREATE TABLE CESION_USO(
  id_titulo               INTEGER NOT NULL,
  fecha_vencimiento       DATE NOT NULL,
  anualidad               INTEGER NOT NULL,
  primary key(id_titulo, fecha_vencimiento),
  foreign key(id_Titulo) references TITULO
    ON DELETE CASCADE
    ON UPDATE CASCADE
);


CREATE TABLE TASA(
  id_tasa              INTEGER NOT NULL,
  id_titulo            INTEGER NOT NULL,
  fecha_vencimiento    DATE NOT NULL,
  pago                 BIT,
  concepto             CONCEPTO_TASA,
  primary key (id_tasa),
  foreign key (id_titulo) references TITULO
);


INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('25765093A','Antonio','Antunez Gómez','Palencia','1985-05-08');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('19611257B','Benito','Benitez Perez','Laguna de Duero','1965-02-19');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('13948177C','Carlos','Coronado Ramirez','Burgos','1979-04-29');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('41398187D','Daniel','Delgado Tunez','Avila','1982-09-02');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('44510027C','Juan','Gonzalez Marquez','Palencia','1985-05-08');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('90362514C','Jose','Torres Gómez','Avila','1985-05-08');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('42580387A','Marcos','Benitez Gonzalez','Laguna de Duero','1965-02-19');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('20637396A','Lucas','Toribio Perez','Palencia','1965-02-19');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('99300996C','Alberto','Coronado Sanz','Burgos','1979-05-29');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('68875948C','Daniel','Delgado Torres','Palencia','1962-09-12');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('62460345B','Mikel','Coronado Motos','Palencia','1959-03-19');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('90988624C','Mario','Chaveinte Garcia','Laguna de Duero','1972-09-22');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('22072110D','Alejandro','Lopez Zambrano','Burgos','1986-07-07');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('22072110C','Francisco','Illan Torres','Palencia','1952-02-23');


INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('40441301C','Pepe','Benitez Cura','Palencia','1995-03-09');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('93624561C','Tomás','Hidalgo Pinacho ','Burgos','1970-06-19');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('19611258B','Alberto','Pulido Torres','Avila','1962-02-02');

INSERT INTO TITULAR(nif_titular,nombre,apellidos,domicilio,fecha_nacimiento)
VALUES('62450345B','Pablo','Nandez Iglesias','Palencia','1992-09-22');

/*BENEFICIARIO-------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('19611258B','Alberto','Pulido Torres', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('13948179A','Benito','Benifacio', 'Palencia', '19611258B');

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('44510026A','Carlos','Torcuato Perez', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('84591736E','Jose','Miguelañez Miura', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('42580381A','Paco','Peñas Pecos', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('90988626A','Luis','Mendez Iglesias', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('20637391B','Jandro','Pentos Diaz', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('99300999B','Charly','Martin Sanz', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('68875944A','Kika','Cura Montiel', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('62450345B','Pablo','Nandez Iglesias', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('22072112D','Chavi','Benifacio', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('60929356A','Jhon','Steven Sierra', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('40441302A','Pablo','Pordomingo Gomez', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('70561069A','Felix','Fernandez Vegas', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('83625791A','Juancho','Tuñon Toribio', 'Palencia', NULL);

INSERT INTO BENEFICIARIO(nif_beneficiario,nombre,apellidos,domicilio,beneficiario_sustituto)
VALUES('83492017A','Juanito','Gines Lopez', 'Palencia', NULL);
/*UE-----------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(1,'Nicho',1,'Sector: 3, parcela: 1','2013-05-27', NULL, '2013-07-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(2,'Panteon',1,'Sector: 8, Parcela: 4','2013-08-20', NULL, '2013-10-03');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(3,'Capilla',5,'Sector: 6, Parcela: 7','2014-05-27', NULL, '2014-10-11');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(4,'Nicho',1,'Sector: 6, Parcela: 7','2014-08-20', 3, '2014-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(5,'Nicho',1,'Sector: 6, Parcela: 7','2015-01-10', 3, '2015-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(6,'Sepultura',3,'Sector: 4, Parcela: 6','2016-09-05', 3, '2016-10-31');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(7,'Columbario',8,'Sector: 1, Parcela: 5','2017-03-19', NULL, '2017-04-11');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(8,'Capilla',10,'Sector: 9, Parcela: 9','2018-01-02', NULL, '2018-02-17');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(9,'Osario',50,'Sector: 7, Parcela: 8','2018-06-15', NULL, '2018-08-07');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(10,'Panteon',6,'Sector: 10, Parcela: 1','2018-12-24', NULL, '2019-01-13');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(11,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-20', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(12,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-21', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(13,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-21', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(14,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-22', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(15,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-23', 10, '2019-12-27');

INSERT INTO UE(id_unidad,tipo_ue,departamentos,localizacion,fecha_construccion, unidad_predecesora, fecha_concesion)
VALUES(16,'Nicho',1,'Sector: 10, Parcela: 1','2019-08-23', 10, '2019-12-27');



/*TITULO-------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(1,1,NULL,'25765093A','2013-08-10','Gratuito','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(2,2,'19611258B','19611257B','2013-11-01','Intestado','Caducado');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(3,3,'13948179A','13948177C','2014-12-20','Gratuito','Extinto');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(4,4,NULL,'41398187D','2015-01-10','Testamentario','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(5,5,'44510026A','44510027C','2015-04-29','Testamentario','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(6,6,'84591736E','90362514C','2016-10-31','Testamentario','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(7,7,'42580381A','42580387A','2017-04-11','Intestado','Extinto');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(8,8,NULL,'20637396A','2018-02-17','Gratuito','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(9,9,'99300999B','99300996C','2018-08-07','Testamentario','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(10,10,'68875944A','68875948C','2019-01-13','Testamentario','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(11,11,'62450345B','13948177C','2019-12-17','Intestado','Caducado');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(12, 12, NULL,'90988624C','2019-12-20','Gratuito','Extinto');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(13,13,'22072112D','22072110D','2019-12-30','Testamentario','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(14,14,'60929356A','22072110C','2020-02-24','Testamentario','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(15,15,'40441302A','40441301C','2019-12-27','Gratuito','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(16,16,'70561069A','93624561C','2019-12-27','Gratuito','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(17,2,'83625791A','19611258B','2020-01-13','Intestado','Activo');

INSERT INTO TITULO(id_titulo,id_unidad,nif_beneficiario,nif_titular,fecha_adjudicacion,
caracter_adjudicacion,estado_titulo)
VALUES(18,11,'83492017A','62450345B','2020-01-23','Intestado','Activo');




/*OBRA----------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(1,718,'2013-03-22','2013-05-27');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(2,769,'2013-07-19','2013-08-20');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(3,980,'2014-04-02','2014-05-27');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(4,1094,'2014-07-06','2014-08-20');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(5,1254,'2014-11-24','2015-01-10');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(6,1805,'2016-06-12','2016-09-05');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(7,1900,'2017-01-12','2017-03-19');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(8,356,'2017-12-20','2018-01-02');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(9,42,'2018-02-01','2018-06-15');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(10,232,'2018-10-06','2018-12-24');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(11,1165,'2018-06-11','2019-08-20');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(12,1007,'2019-07-16','2019-08-21');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(13,1612,'2019-05-30','2019-08-21');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(14,74,'2019-07-01','2019-08-22');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(15,777,'2019-06-20','2019-08-23');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(16,666,'2019-07-15','2019-08-25');

INSERT INTO OBRA(id_obra,licencia,fecha_inicio,fecha_fin)
VALUES(16,624,'2020-03-20','2020-05-15');

/*SERVICIOS-----------------------------------------------------------------------------------------------------------------------------------------------*/

/*INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(1,'25755093A',2,'', ,'2013-08-20', NULL, '2013-10-03');*/

/*TASAS----------------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(1,1,'2013-12-06','1','Título');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(2,1,'2013-08-20','1','Obras');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(3,3,'2014-05-27','1','Obras');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(4,4,'2015-01-12','1','Título');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(5,5,'2015-05-29','1','Título');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(6,5,'2018-01-02','1','Obras');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(7,6,'2019-10-31','1','Obras');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(8,6,'2019-12-27','1','Título');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(9,7,'2020-01-25','1','Título');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(10,7,'2020-06-13','1','Obras');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(11,8,'2020-05-30','1','Título');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(12,8,'2021-03-14','1','Obras');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(13,9,'2020-07-28','1','Título');

INSERT INTO TASA(id_tasa,id_titulo,fecha_vencimiento,pago,concepto)
VALUES(14,9,'2022-06-09','1','Obras');


/*SOLICITANTE---------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO SOLICITANTE(nif_solicitante,nombre,apellidos,domicilio)
VALUES('25765093A','Antonio','Antunez Gómez','Palencia');

INSERT INTO SOLICITANTE(nif_solicitante,nombre,apellidos,domicilio)
VALUES('19611258B','Alberto','Pulido Torres','Avila');

INSERT INTO SOLICITANTE(nif_solicitante,nombre,apellidos,domicilio)
VALUES('62450345B','Pablo','Nandez Iglesias','Palencia');

INSERT INTO SOLICITANTE(nif_solicitante,nombre,apellidos,domicilio)
VALUES('44510027C','Juan','Gonzalez Marquez','Palencia');

INSERT INTO SOLICITANTE(nif_solicitante,nombre,apellidos,domicilio)
VALUES('99300996C','Alberto','Coronado Sanz','Burgos');

INSERT INTO SOLICITANTE(nif_solicitante,nombre,apellidos,domicilio)
VALUES('20637396A','Lucas','Toribio Perez','Palencia');

INSERT INTO SOLICITANTE(nif_solicitante,nombre,apellidos,domicilio)
VALUES('22072110D','Alejandro','Lopez Zambrano','Burgos');

INSERT INTO SOLICITANTE(nif_solicitante,nombre,apellidos,domicilio)
VALUES('93624561C','Tomás','Hidalgo Pinacho ','Burgos');


/*FALLECIDO-----------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('15611257B',1,'Ramon','De Pitis Alvarez','Varon','Valladolid','Palencia', '2022-12-12 00:00:00');

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('19611257B',17,'Benito','Benitez Perez','Varon','Laguna de Duero','Palencia', '2022-12-12 00:00:00');

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('62460345B',18,'Mikel','Coronado Motos','Varon','Palencia','Palencia', '2022-12-12 00:00:00');

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('62850429B',16,'Alvaro','Varito Gonzalez','Varon','Palencia','Palencia', '2022-12-12 00:00:00');

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('62852429B',5,'Edson','Arantes do Nascimento','Varon','Minas Gerais','Palencia', '2022-12-12 00:00:00');

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('72830429B',9,'Diego','Armando Maradona','Varon','Buenos Aires','Palencia', '2022-12-12 00:00:00');

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('62950726B',8,'Hendrik','Johannes Cruyff','Varon','Amsterdam','Barcelona', '2022-12-12 00:00:00');

INSERT INTO FALLECIDO(nif_fallecido,id_titulo,nombre,apellidos,sexo,domicilio,lugar_fallecimiento,fecha_defuncion)
VALUES('82830422B',13,'Alfredo','Stéfano Di Stéfano','Varon','Madrid','Palencia', '2022-12-12 00:00:00');

/*SERVICIOS-----------------------------------------------------------------------------------------------------------------------------------------------*/

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(1,'19611258B',2,'19611257B','2013-08-20','0', NULL,'inhumación');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(2,'62450345B',11,'62460345B','2013-08-20','0', NULL,'inhumación');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(3,'25765093A',1,'15611257B','2013-08-20','0', NULL,'inhumación');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(4,'93624561C',16,'62850429B','2013-08-20','0', NULL,'inhumación');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(5,'44510027C',5,'62852429B','2013-08-20','0', NULL,'cremación');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(6,'99300996C',9,'72830429B','2013-08-20','0', NULL,'inhumación');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(7,'20637396A',8,'62950726B','2013-08-20','0', NULL,'inhumación');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(8,'22072110D',13,'82830422B','2013-08-20','0', NULL,'inhumación');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(9,'25765093A',1,'15611257B','2013-08-20','0', NULL,'traslado');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(10,'22072110D',13,'82830422B','2022-12-14','0', NULL,'reduccion');

INSERT INTO SERVICIO(id_servicio,nif_solicitante,id_unidad,nif_fallecido,fecha,certificado,parte_anatomica,tipo_servicio)
VALUES(11,'99300996C',9,'72830429B','2013-08-20','0', NULL,'exhumación');

INSERT INTO INHUMACION(id_servicio,hora)
VALUES(1,'20:00:00');

INSERT INTO INHUMACION(id_servicio,hora)
VALUES(2,'21:00:00');

INSERT INTO INHUMACION(id_servicio,hora)
VALUES(3,'22:00:00');

INSERT INTO INHUMACION(id_servicio,hora)
VALUES(4,'10:00:00');

INSERT INTO INHUMACION(id_servicio,hora)
VALUES(6,'13:00:00');

INSERT INTO INHUMACION(id_servicio,hora)
VALUES(7,'18:00:00');

INSERT INTO INHUMACION(id_servicio,hora)
VALUES(8,'17:30:00');

INSERT INTO TRASLADOS(id_servicio,ubicacion_origen,hora)
VALUES(9,'Sector: 3, parcela: 1','20:30:00');

INSERT INTO TRASLADOS(id_servicio,ubicacion_origen,hora)
VALUES(10,'Sector: 4, parcela: 5','16:30:00');

INSERT INTO TRASLADOS(id_servicio,ubicacion_origen,hora)
VALUES(11,'Sector: 2, parcela: 6','12:30:00');


INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(1,'2038-08-10',0);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(1,'2055-08-10',0);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(2,'2038-11-01',1);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(3,'2039-12-20',3);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(4,'2040-01-10',2);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(5,'2040-04-29',1);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(6,'2041-10-31',0);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(7,'2042-04-11',0);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(8,'2043-02-17',2);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(8,'2069-02-17',2);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(9,'2043-08-07',3);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(10,'2044-01-13',3);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(11,'2044-12-17',1);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(12,'2044-12-20',0);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(13,'2044-12-30',2);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(14,'2045-02-24',0);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(15,'2044-12-27',0);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(16,'2044-12-27',1);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(17,'2045-01-13',0);

INSERT INTO CESION_USO(id_titulo,fecha_vencimiento,anualidad)
VALUES(18,'2045-01-23',0);
