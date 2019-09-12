/*
1.	Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. Fajlove baze podataka smjestiti na sljedeæe lokacije:
a)	Data fajl: D:\BP2\Data
b)	Log fajl: D:\BP2\Log

*/
create database ispit20062017 on primary
(NAME = ispit20062017_dat , FILENAME = 'C:\BP2\data\ispit20062017_dat.mdf')
log on
(NAME = ispit20062017_log , FILENAME = 'C:\BP2\log\ispit20062017_log.ldf')
use ispit20062017

/*
2.	U svojoj bazi podataka kreirati tabele sa sljedeæom strukturom:
a)	Proizvodi
i.	ProizvodID, cjelobrojna vrijednost i primarni kljuè
ii.	Sifra, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
iii.	Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
iv.	Kategorija, polje za unos 50 UNICODE karaktera (obavezan unos)
v.	Cijena, polje za unos decimalnog broja (obavezan unos)
b)	Narudzbe
i.	NarudzbaID, cjelobrojna vrijednost i primarni kljuè,
ii.	BrojNarudzbe, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
iii.	Datum, polje za unos datuma (obavezan unos),
iv.	Ukupno, polje za unos decimalnog broja (obavezan unos)
c)	StavkeNarudzbe
i.	ProizvodID, cjelobrojna vrijednost i dio primarnog kljuèa,
ii.	NarudzbaID, cjelobrojna vrijednost i dio primarnog kljuèa,
iii.	Kolicina, cjelobrojna vrijednost (obavezan unos)
iv.	Cijena, polje za unos decimalnog broja (obavezan unos)
v.	Popust, polje za unos decimalnog broja (obavezan unos)

*/
create table Proizvodi
(
ProizvodID int constraint PK_Proizvodi primary key,
Sifra nvarchar(25) constraint uq_sifra unique not null,
Naziv nvarchar(50) not null,
Kategorija nvarchar(50) not null,
Cijena decimal(8,2) not null
)
create table Narudzbe
(
NarudzbaID int constraint PK_Narudzbe primary key,
BrojNarudzbe nvarchar(25) constraint uq_brojnarudzbe unique not null,
Datum date not null,
Ukupno decimal(8,2) not null
)

Create table StavkeNarudzbe
(
ProizvodID int constraint FK_StavkeNarudzbe_Proizvodi foreign key(ProizvodID) REFERENCES Proizvodi(ProizvodID),
NarudzbaID int constraint FK_StavkeNarudzbe_Narudzbe  foreign key(NarudzbaID) REFERENCES Narudzbe(NarudzbaID),
constraint PK_StavkeNarudzbe primary key(ProizvodID,NarudzbaID),
Kolicina INT NOT NULL,
Cijena DECIMAL(8,2) NOT NULL,
Popust DECIMAL(8,2) NOT NULL,
Iznos decimal(8,2) not null
)
/*
3.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljedeæe podatke:
a)	U tabelu Proizvodi dodati sve proizvode koji su prodavani u 2014. godini
i.	ProductNumber -> Sifra
ii.	Name -> Naziv
iii.	ProductCategory (Name) -> Kategorija
iv.	ListPrice -> Cijena
b)	U tabelu Narudzbe dodati sve narudžbe obavljene u 2014. godini
i.	SalesOrderNumber -> BrojNarudzbe
ii.	OrderDate - > Datum
iii.	TotalDue -> Ukupno
c)	U tabelu StavkeNarudzbe prebaciti sve podatke o detaljima narudžbi uraðenih u 2014. godini
i.	OrderQty -> Kolicina
ii.	UnitPrice -> Cijena
iii.	UnitPriceDiscount -> Popust
iv.	LineTotal -> Iznos 
	Napomena: Zadržati identifikatore zapisa!	

*/
INSERT INTO Proizvodi
select DISTINCT P.ProductID,P.ProductNumber,P.Name,PC.Name,P.ListPrice
from AdventureWorks2014.Production.Product AS P INNER JOIN AdventureWorks2014.Production.ProductSubcategory AS PS
	 ON P.ProductSubcategoryID = PS.ProductSubcategoryID INNER JOIN AdventureWorks2014.Production.ProductCategory AS PC
	 ON PS.ProductCategoryID = PC.ProductCategoryID INNER JOIN AdventureWorks2014.Sales.SalesOrderDetail AS SOD 
	 ON P.ProductID = SOD.ProductID INNER JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH
	 ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE DATEPART(YEAR,SOH.OrderDate) = 2014

SELECT * FROM Proizvodi

--b
INSERT INTO Narudzbe
select soh.SalesOrderID,soh.SalesOrderNumber,soh.OrderDate,soh.TotalDue
from AdventureWorks2014.Sales.SalesOrderHeader as soh
where DATEPART(YEAR,soh.OrderDate) = 2014

--c

insert into StavkeNarudzbe
select SOD.ProductID,SOH.SalesOrderID,SOD.OrderQty,SOD.UnitPrice,SOD.UnitPriceDiscount,SOD.LineTotal
from AdventureWorks2014.Sales.SalesOrderDetail AS SOD INNER JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH
	 ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE DATEPART(YEAR,SOH.OrderDate) = 2014


/*
4.	U svojoj bazi podataka kreirati novu tabelu Skladista sa poljima SkladisteID i Naziv, 
a zatim je povezati sa tabelom Proizvodi u relaciji više prema više. 
Za svaki proizvod na skladištu je potrebno èuvati kolièinu (cjelobrojna vrijednost).
*/
CREATE TABLE Skladista
(
SkladisteID INT CONSTRAINT PK_Skladiste primary key identity(1,1),
Naziv nvarchar(50) not null
)

create table SkladisteProizvodi
(
SkladisteID INT CONSTRAINT FK_SkladisteProizvodi_Skladiste foreign key(SkladisteID) REFERENCES Skladista(SkladisteID),
ProizvodID INT CONSTRAINT FK_SkladisteProizvodi_Proizvodi foreign key(ProizvodID) REFERENCES Proizvodi(ProizvodID),
constraint PK_SkladisteProizvodi primary key(SkladisteID,ProizvodID),
Kolicina int not null
)

/*
5.	U tabelu Skladista  dodati tri skladišta proizvoljno, a zatim za sve proizvode na svim skladištima postaviti kolièinu na 0 komada.
*/
INSERT INTO Skladista
values ('Skladiste 1'),
		('Skladiste 2'),
		('Skladiste 3')

INSERT INTO SkladisteProizvodi
select (select SkladisteID from Skladista where SkladisteID = 3),ProizvodID,0
from Proizvodi
select * from SkladisteProizvodi
/*
6.	Kreirati uskladištenu proceduru koja vrši izmjenu stanja skladišta (kolièina).
Kao parametre proceduri proslijediti identifikatore proizvoda i skladišta, te kolièinu.	
*/
create procedure proc_SkladisteProizvodi_Update
(
@SkladisteID INT,
@ProizvodID INT,
@Kolicina int
)
AS
BEGIN
UPDATE SkladisteProizvodi
set Kolicina = Kolicina + @Kolicina
where SkladisteID = @SkladisteID and ProizvodID = @ProizvodID
END

EXEC proc_SkladisteProizvodi_Update 1,707,150

select * from SkladisteProizvodi


/*
7.	Nad tabelom Proizvodi kreirati non-clustered indeks nad poljima Sifra i Naziv, 
a zatim napisati proizvoljni upit koji u potpunosti iskorištava kreirani indeks. 
Upit obavezno mora sadržavati filtriranje podataka.
*/
USE ispit20062017

create nonclustered index IX_Proizvodi_Sifra_Naziv
on Proizvodi(Sifra,Naziv)

select Sifra,Naziv
from Proizvodi
where Sifra like '%[0-5]'

/*8.	Kreirati trigger koji æe sprijeèiti brisanje zapisa u tabeli Proizvodi.*/

CREATE TRIGGER tr_Proizovid_delete
ON Proizvodi instead of delete
as
begin
PRINT 'Nije dozvoljeno brisanje zapisa'
rollback
end

delete from Proizvodi
where ProizvodID = 707
/*
9.	Kreirati view koji prikazuje sljedeæe kolone: šifru, naziv i cijenu proizvoda, ukupnu prodanu kolièinu i ukupnu zaradu od prodaje.
*/
create view view_Proizvod_Narudzbe
as
select P.Sifra,P.Naziv,P.Cijena,SUM(SN.Kolicina) AS [Ukupno prodano],SUM((SN.Cijena-(SN.Cijena*SN.Popust))*SN.Kolicina) AS Ukupno
from Proizvodi as P INNER JOIN StavkeNarudzbe AS SN
	 ON P.ProizvodID = SN.ProizvodID 
group by P.Sifra,P.Naziv,P.Cijena

select * from view_Proizvod_Narudzbe

/*
10.	Kreirati uskladištenu proceduru koja æe za unesenu šifru proizvoda prikazivati ukupnu prodanu kolièinu i ukupnu zaradu.
Ukoliko se ne unese šifra proizvoda procedura treba da prikaže prodaju svih proizovda. U proceduri koristiti prethodno kreirani view.	
*/
create procedure proc_view_Proizvod_Narudzbe_SelectBySifra
(
@Sifra nvarchar(25) = null
)
as
begin
select [Ukupno prodano],Ukupno
from view_Proizvod_Narudzbe
where Sifra = @Sifra or @Sifra is null
end

exec proc_view_Proizvod_Narudzbe_SelectBySifra 'LJ-0192-S'

exec proc_view_Proizvod_Narudzbe_SelectBySifra
/*
11.	U svojoj bazi podataka kreirati novog korisnika za login student te mu dodijeliti odgovarajuæu permisiju
kako bi mogao izvršavati prethodno kreiranu proceduru.
*/
create user novi from login student

GRANT EXECUTE ON proc_view_Proizvod_Narudzbe_SelectBySifra TO novi

/*12.	Napraviti full i diferencijalni backup baze podataka na lokaciji D:\BP2\Backup	 */

backup database ispit10062017 to
disk = 'C:\BP2\Backup\ispit10062017.bak'

backup database ispit10062017 to
disk = 'C:\BP2\Backup\ispit10062017_dif.bak'
with differential