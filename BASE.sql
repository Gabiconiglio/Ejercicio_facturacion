--drop database PROBLEMA_1_2_FACTURACION
--CREATE DATABASE PROBLEMA_1_2_FACTURACION
--GO
--USE PROBLEMA_1_2_FACTURACION
--GO
SET DATEFORMAT DMY
CREATE TABLE FORMAS_PAGO
(
ID_FORMAPAGO INT,
FORMAPAGO VARCHAR (50),

CONSTRAINT PK_FORMAS_PAGO PRIMARY KEY (ID_FORMAPAGO)
)

CREATE TABLE ARTICULOS
(
ID_ARTICULO INT,
DESCRIPCION VARCHAR (50),
PRE_UNITARIO DECIMAL (10,2)

CONSTRAINT PK_ARTICULOS PRIMARY KEY (ID_ARTICULO)
)

CREATE TABLE FACTURAS
(
NRO_FACTURA INT IDENTITY (1,1),
FECHA DATETIME,
FECHA_BAJA DATETIME,
ID_FORMAPAGO INT,
DESCUENTO decimal (8,2),
TOTAL decimal (8,2),
CLIENTE VARCHAR (50)

CONSTRAINT PK_FACTURA PRIMARY KEY (NRO_FACTURA),
CONSTRAINT FK_FACTURA_FORMAS_PAGO FOREIGN KEY (ID_FORMAPAGO)
REFERENCES FORMAS_PAGO (ID_FORMAPAGO)
)


CREATE TABLE DETALLES_FACTURA
(
ID_DETALLE_FACTURA INT IDENTITY (1,1),
ID_ARTICULO INT,
CANTIDAD INT,
NRO_FACTURA INT,
CONSTRAINT PK_DETALLES_FACTURA PRIMARY KEY (ID_DETALLE_FACTURA),
CONSTRAINT FK_DETALLES_FACTURA_ARTICULOS FOREIGN KEY (ID_ARTICULO)
REFERENCES ARTICULOS (ID_ARTICULO),
CONSTRAINT FK_DETALLES_FACTURA_FACTURA FOREIGN KEY(NRO_FACTURA)
REFERENCES FACTURAS(NRO_FACTURA)
)




insert into FORMAS_PAGO (id_formaPago, formaPago)
values (1,'Efectivo')
insert into FORMAS_PAGO (id_formaPago, formaPago)
values (2,'Credito')
insert into FORMAS_PAGO (id_formaPago, formaPago)
values (3,'Debito')
insert into FORMAS_PAGO (id_formaPago, formaPago)
values (4,'Cheque')
insert into FORMAS_PAGO (id_formaPago, formaPago)
values (5,'Mercado Pago')

insert into ARTICULOS (id_articulo, descripcion, pre_unitario)
values (1,'Arroz',180)
insert into ARTICULOS (id_articulo, descripcion, pre_unitario)
values (2,'Fideos',120)
insert into ARTICULOS (id_articulo, descripcion, pre_unitario)
values (3,'Lentejas',100)
insert into ARTICULOS (id_articulo, descripcion, pre_unitario)
values (4,'YerbaMate',300)
insert into ARTICULOS (id_articulo, descripcion, pre_unitario)
values (5,'Vino',500)
insert into ARTICULOS (id_articulo, descripcion, pre_unitario)
values (6,'Fernet',1120)
insert into ARTICULOS (id_articulo, descripcion, pre_unitario)
values (7,'Sal',280)
insert into ARTICULOS (id_articulo, descripcion, pre_unitario)
values (8,'Aceite',350)


insert into FACTURAS(fecha,id_formaPago,DESCUENTO,TOTAL,cliente)
values ('5/6/2021',1,0,500,'Toledo Bruno')
INSERT INTO DETALLES_FACTURA (ID_ARTICULO, CANTIDAD, NRO_FACTURA)
VALUES (5,1,1)


--1 sp para cargar articulos	

SELECT * FROM ARTICULOS

create proc SP_CARGA_ARTICULOS
AS
BEGIN
SELECT * FROM ARTICULOS
END

EXEC SP_CARGA_ARTICULOS

--2 SP PARA CARGAR FORMAS DE PAGO

CREATE PROC SP_CARGA_FORMAS_PAGO
AS
BEGIN 
SELECT * FROM FORMAS_PAGO
END

--3 sp para cargar numero de factura

create proc SP_PROXIMA_FACTURA
@NEXT INT OUTPUT
AS
BEGIN
SET @NEXT=(SELECT MAX(NRO_FACTURA)+1 FROM FACTURAS);
END


--4 sp para la carga de productos en detalle
select * from FACTURAS

drop proc SP_INSERTAR_FACTURA

create proc SP_INSERTAR_FACTURA
@FECHA DATETIME,
@PAGO INT,
@DTO decimal(8,2),
@TOTAL decimal(8,2),
@CLIENTE VARCHAR(70),
@factura_nro int output

AS
BEGIN
INSERT INTO FACTURAS (FECHA,ID_FORMAPAGO,DESCUENTO,TOTAL,CLIENTE)
VALUES(@FECHA,@PAGO,@DTO,@TOTAL,@CLIENTE)
set @factura_nro=SCOPE_IDENTITY();
END


--5 sp para la carga del detalle
select* from DETALLES_FACTURA

drop proc SP_INSERTAR_DETALLE

create proc SP_INSERTAR_DETALLE
@id_articulo int,
@cantidad int,
@factura_nro int
as
begin 
insert into DETALLES_FACTURA (ID_ARTICULO,CANTIDAD,NRO_FACTURA)
VALUES(@id_articulo,@cantidad,@factura_nro)
END

EXEC SP_INSERTAR_DETALLE 2,600,6
-----
select* from facturas
select* from detalles_factura

--6 Sp para consultar Facturas

--drop proc SP_CONSULTAR_FACTURAS

create proc SP_CONSULTAR_FACTURAS
@fecha_desde datetime,
@fecha_hasta datetime,
@cliente varchar (50)
as
begin
select *
from FACTURAS f
inner join FORMAS_PAGO fp on fp.ID_FORMAPAGO=f.ID_FORMAPAGO
where (@fecha_desde is null or  FECHA>=@fecha_desde)
		and (@fecha_hasta is null or FECHA<=@fecha_hasta)
		and (@cliente is null or CLIENTE like '%' + @cliente +'%')
		and FECHA_BAJA is null;
end

exec SP_CONSULTAR_FACTURAS '09/09/22','12/09/22', 'Gabriel Coniglio' 

--7 sp para elimiar factura

create proc SP_ELIMINAR_FACTURA
@FACTURA_NRO INT
AS
BEGIN
UPDATE FACTURAS SET FECHA_BAJA=GETDATE()
WHERE NRO_FACTURA=@FACTURA_NRO
END

--8 sp para consultar detalle factura

create proc SP_CONSULTA_DETALLE
@FACTURA_NRO INT
AS
BEGIN
SELECT FA.FECHA,FA.CLIENTE,FA.TOTAL,FA.DESCUENTO,AR.DESCRIPCION,AR.PRE_UNITARIO,DF.CANTIDAD
FROM DETALLES_FACTURA DF
INNER JOIN ARTICULOS AR ON AR.ID_ARTICULO=DF.ID_ARTICULO
INNER JOIN FACTURAS FA ON FA.NRO_FACTURA=DF.NRO_FACTURA
WHERE DF.NRO_FACTURA=@FACTURA_NRO
END

EXEC SP_CONSULTA_DETALLE 2

--8 sp para actualizar los datos de la factura

create proc SP_ACTUALIZAR_DETALLE
@fecha datetime,
@cliente varchar(50),
@factura_nro int
as
begin
update FACTURAS set FECHA=@fecha, CLIENTE=@cliente
where NRO_FACTURA=@factura_nro
end

select* from facturas
exec SP_ACTUALIZAR_DETALLE  '08/09/2022','Juan Perez', 1

--9 sp para reporte

create proc SP_REPORTE
as
begin 
select fa.NRO_FACTURA,fa.FECHA,fp.FORMAPAGO,fa.CLIENTE,fa.TOTAL
from FACTURAS fa
inner join FORMAS_PAGO fp on fp.ID_FORMAPAGO=fa.ID_FORMAPAGO
end

exec SP_REPORTE

--10 sp reporte de promedio de ventas por cliente

create proc SP_REPORTE_PROMEDIO 
AS
BEGIN
SELECT FA.CLIENTE, AVG(DF.CANTIDAD*AR.PRE_UNITARIO)
FROM FACTURAS FA
INNER JOIN DETALLES_FACTURA DF ON DF.NRO_FACTURA=FA.NRO_FACTURA
INNER JOIN ARTICULOS AR ON AR.ID_ARTICULO=DF.ID_ARTICULO
GROUP BY FA.CLIENTE
END

EXEC SP_REPORTE_PROMEDIO