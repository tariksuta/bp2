/*
1. Kroz SQL kod, napraviti bazu podataka koja nosi ime va�eg broja dosijea. U postupku kreiranja u
obzir uzeti samo DEFAULT postavke.
Unutar svoje baze podataka kreirati tabelu sa sljede�om strukturom:
a) Proizvodi:
I. ProizvodID, automatski generatpr vrijednosti i primarni klju�
II. Sifra, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
III. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
IV. Cijena, polje za unos decimalnog broja (obavezan unos)
b) Skladista
I. SkladisteID, automatski generator vrijednosti i primarni klju�
II. Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
III. Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
IV. Lokacija, polje za unos 50 UNICODE karaktera (obavezan unos)
c) SkladisteProizvodi
I) Stanje, polje za unos decimalnih brojeva (obavezan unos)

Napomena: Na jednom skladi�tu mo�e biti uskladi�teno vi�e proizvoda, dok isti proizvod mo�e biti
uskladi�ten na vi�e razli�itih skladi�ta. Onemogu�iti da se isti proizvod na skladi�tu mo�e pojaviti vi�e
puta
*/
create database ispit16072016

use ispit16072016

create table Proizvodi
(
ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
 Sifra nvarchar(10) constraint uq_sifra unique not null,
 Naziv nvarchar(50) not null,
 Cijena decimal(8,2) not null
)

create table Skladista
(
 SkladisteID int constraint PK_Skladista primary key identity(1,1),
 Naziv nvarchar(50) not null,
 Oznaka nvarchar(10) constraint uq_oznaka unique not null,
 Lokacija nvarchar(50) not null
)

create table SkladisteProizvodi
(
SkladisteID INT CONSTRAINT FK_SkladisteProizvodi_Skladiste foreign key(SkladisteID) REFERENCES Skladista(SkladisteID),
ProizvodID INT CONSTRAINT FK_SkladistaProizvodi_Proizvodi foreign key(ProizvodID) REFERENCES Proizvodi(ProizvodID),
CONSTRAINT PK_SkladisteProizvodi primary key(SkladisteID,ProizvodID),
Stanje decimal(8,2) not null
)

/*
2. Popunjavanje tabela podacima
a) Putem INSERT komande u tabelu Skladista dodati minimalno 3 skladi�ta.
b) Koriste�i bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati
10 najprodavanijih bicikala (kategorija proizvoda 'Bikes' i to sljede�e kolone:
I. Broj proizvoda (ProductNumber) - > Sifra,
II. Naziv bicikla (Name) -> Naziv,
III. Cijena po komadu (ListPrice) -> Cijena,
c) Putem INSERT i SELECT komandi u tabelu SkladisteProizvodi za sva dodana skladista
importovati sve proizvode tako da stanje bude 100
*/
INSERT INTO Skladista
values ('Skladiste 1','SAK-100-1','Mostar'),
		('Skladiste 2','SAK-100-2','Sarajevo'),
		('Skladiste 3','SAK-100-3','Tuzla')

--b
insert into Proizvodi
select top 10 P.ProductNumber,P.Name,P.ListPrice
from AdventureWorks2014.Production.Product as P INNER JOIN AdventureWorks2014.Production.ProductSubcategory AS PS
	 ON P.ProductSubcategoryID = PS.ProductSubcategoryID INNER JOIN AdventureWorks2014.Production.ProductCategory AS PC
	 ON PS.ProductCategoryID = PC.ProductCategoryID INNER JOIN AdventureWorks2014.Sales.SalesOrderDetail AS SOD
	 ON P.ProductID = SOD.ProductID
WHERE PC.Name LIKE '%Bikes%'
GROUP BY P.ProductNumber,P.Name,P.ListPrice
ORDER BY SUM(SOD.OrderQty) DESC

SELECT * FROM Proizvodi

--C
INSERT INTO SkladisteProizvodi
SELECT (SELECT SkladisteID FROM Skladista WHERE SkladisteID = 3),ProizvodID,100
FROM Proizvodi

SELECT * FROM SkladisteProizvodi

/*3.
Kreirati uskladi�tenu proceduru koja �e vr�iti pove�anje stanja skladi�ta za odre�eni proizvod na
odabranom skladi�tu. Provjeriti ispravnost procedure.
*/
CREATE PROCEDURE proc_SkladisteProizvodi_update
(
@SkladisteID INT,
@ProizvodID INT,
@Stanje decimal(8,2)
)
as
begin
UPDATE SkladisteProizvodi
set Stanje = Stanje + @Stanje
WHERE SkladisteID = @SkladisteID and ProizvodID = @ProizvodID
end

exec proc_SkladisteProizvodi_update 1,2,33

SELECT * FROM SkladisteProizvodi


/*4.
 Kreiranje indeksa u bazi podataka nad tabelama
a) Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv. Tako�er,
potrebno je uklju�iti kolonu Cijena
b) Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskori�tava indeks iz
prethodnog koraka
c) Uradite disable indeksa iz koraka a)
*/
create nonclustered index IX_Proizvodi_Sifra_Naziv
ON Proizvodi(Sifra,Naziv)
include(Cijena)

select Sifra,Naziv
from Proizvodi
where Cijena > 2100

alter index IX_Proizvodi_Sifra_Naziv on Proizvodi
disable
/*
5. Kreirati view sa sljede�om definicijom. Objekat treba da prikazuje sifru, naziv i cijenu proizvoda,
oznaku, naziv i lokaciju skladi�ta, te stanje na skladi�tu.
*/
create view view_Proizvodi_Skladista
as
select P.Sifra,P.Naziv AS Proizvod,P.Cijena,
		S.Oznaka,S.Naziv as Skladiste,S.Lokacija,
		SP.Stanje
from Proizvodi as P INNER JOIN SkladisteProizvodi AS SP
	 ON P.ProizvodID = SP.ProizvodID INNER JOIN Skladista AS S
	 ON SP.SkladisteID = S.SkladisteID

	 select * from view_Proizvodi_Skladista

/*6.
 Kreirati uskladi�tenu proceduru koja �e na osnovu unesene �ifre proizvoda prikazati ukupno stanje
zaliha na svim skladi�tima. U rezultatu prikazati sifru, naziv i cijenu proizvoda te ukupno stanje zaliha.
U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane procedure.
*/
create procedure proc_view_Proizvodi_Skladista_UkupnoStanje
(
@Sifra nvarchar(10)
)
as
begin
select Sifra,Proizvod,Cijena,SUM(Stanje) as [Ukupno stanje]
from view_Proizvodi_Skladista
where Sifra = @Sifra
GROUP BY Sifra,Proizvod,Cijena
end
exec proc_view_Proizvodi_Skladista_UkupnoStanje 'BK-M68B-42'
/*7.
. Kreirati uskladi�tenu proceduru koja �e vr�iti upis novih proizvoda, te kao stanje zaliha za uneseni
proizvod postaviti na 0 za sva skladi�ta. Provjeriti ispravnost kreirane procedure.
*/
create procedure proc_Proizvodi_insert
(
@Sifra nvarchar(10),
@Naziv nvarchar(50),
@Cijena decimal(8,2)
)
as
begin
insert into Proizvodi
values (@Sifra,@Naziv,@Cijena)

INSERT INTO SkladisteProizvodi
SELECT SkladisteID,(SELECT ProizvodID FROM Proizvodi WHERE Sifra = @Sifra),0
FROM Skladista
end

exec proc_Proizvodi_insert 'AB-CULT','Namaz',1.45

select * from SkladisteProizvodi

/*8.
 Kreirati uskladi�tenu proceduru koja �e za unesenu �ifru proizvoda vr�iti brisanje proizvoda
uklju�uju�i stanje na svim skladi�tima. Provjeriti ispravnost procedure.
*/
CREATE PROCEDURE proc_Proizvodi_delete
(
@Sifra nvarchar(10)
)
as
begin
delete from SkladisteProizvodi
where ProizvodID in (
					select ProizvodID
					from Proizvodi
					where Sifra = @Sifra
					)
delete from Proizvodi
where Sifra = @Sifra
end

exec proc_Proizvodi_delete 'AB-CULT'

/*9.
 Kreirati uskladi�tenu proceduru koja �e za unesenu �ifru proizvoda, oznaku skladi�ta ili lokaciju
skladi�ta vr�iti pretragu prethodno kreiranim view-om (zadatak 5). Procedura obavezno treba da
vra�a rezultate bez obrzira da li su vrijednosti parametara postavljene. Testirati ispravnost procedure
u sljede�im situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vra�a sve zapise)
b) Postavljena je vrijednost parametra �ifra proizvoda, a ostala dva parametra nisu
c) Postavljene su vrijednosti parametra �ifra proizvoda i oznaka skladi�ta, a lokacija
nije
d) Postavljene su vrijednosti parametara �ifre proizvoda i lokacije, a oznaka skladi�ta
nije
e) Postavljene su vrijednosti sva tri parametra
*/
create procedure proc_view_Proizvodi_Skladista_pretraga
(
@Sifra nvarchar(10) = null,
@Oznaka nvarchar(10) = null,
@Lokacija nvarchar(50) = null
)
as
begin
select *
from view_Proizvodi_Skladista
where (Sifra = @Sifra or @Sifra is null)
		and (Oznaka = @Oznaka or @Oznaka is null)
		and (Lokacija = @Lokacija or @Lokacija is null)
end

exec proc_view_Proizvodi_Skladista_pretraga
exec proc_view_Proizvodi_Skladista_pretraga 'BK-R50B-52'
exec proc_view_Proizvodi_Skladista_pretraga 'BK-R50B-52','SAK-100-2'
exec proc_view_Proizvodi_Skladista_pretraga @Sifra = 'BK-R50B-52',@Lokacija = 'Sarajevo'


/*10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:*/

backup database ispit16072016 to
disk = 'ispit16072017.bak'

backup database ispit16072016 to
disk = 'ispit16072017_diff.bak'
with differential