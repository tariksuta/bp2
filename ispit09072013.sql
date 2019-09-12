/*
1. Primjer se radi na bazi Northwind. Marketing odjel zahtjeva izvještaj o proizvodima iz kojeg se vidi: naziv dobavljaèa u 
sljedeæem formatu: CompanyName(Grad,Adresa) - u izlaz ukljuèiti zagrade, telefon dobavljaèa, cijena po komadu, 
stanje zaliha, razlika stanja zaliha i naruèenih proizvoda. Uslovi su sljedeæi:
- Da se prikažu samo one razlike stanja zaliha gdje ima više naruèenih nego što imamo na stanju 
- Proizvod ima minimalno jednu narudžbu
- U obzir ulaze samo oni proizvodi gdje je cijena veæa od 20

*/
use NORTHWND

select S.CompanyName+'('+S.City+', '+S.Address+')',
		S.Phone,P.UnitPrice,P.UnitsInStock,P.UnitsInStock-P.UnitsOnOrder AS Razlika
from Suppliers as S INNER JOIN Products AS P
	 ON S.SupplierID = P.SupplierID  INNER JOIN [Order Details] AS OD
	 ON P.ProductID = OD.ProductID
where P.UnitsOnOrder > P.UnitsInStock AND P.UnitPrice > 20
GROUP BY S.CompanyName,S.City,S.Address,S.Phone,P.UnitPrice,P.UnitsInStock,P.UnitsOnOrder
HAVING COUNT(OD.ProductID) >= 1

/*
2. Primjer se radi na bazi Northwind. Vaša kompanija želi provjeriti neke podatke o isporukama prodate robe kupcima. 
Prvi korak jeste kreiranje spiska kupaca sa: imenom kompanije, kontakt imenom, i brojem telefona.
Potrebno je sljedeæe:
- Broj potrebnih dana za isporuku u odnosu na datum narudžbe
- Broj utrošenih dana na isporuku u odnosu na datum narudžbe
- Broj dana koji prikazuje razliku izmeðu potrebnih i utrošenih dana
- Uslov je da broj utrošenih dana bude veæi od potrebnog broja dana

*/
SELECT C.CompanyName,C.ContactName,C.Phone,
		DATEDIFF(DAY,O.OrderDate,O.RequiredDate) AS [Broj potrebnih dana],
		DATEDIFF(DAY,O.OrderDate,O.ShippedDate) AS [Broj utrosenih dana],
			DATEDIFF(DAY,O.OrderDate,O.RequiredDate) - DATEDIFF(DAY,O.ShippedDate,O.OrderDate) as Razlika
FROM Customers AS C INNER JOIN Orders AS O
	 ON C.CustomerID = O.CustomerID
where DATEDIFF(DAY,O.OrderDate,O.ShippedDate)  > DATEDIFF(DAY,O.OrderDate,O.RequiredDate) 


/*
. Koristeæi bazu AdventureWorksLT2012 kreirati upit koji prikazuje podatke o proizvodima. 
Izlaz treba da sadrži sljedeæe kolone: kategoriju proizvoda, model proizvoda, broj proizvoda, cijenu, boju, 
te ukupnu kolièinu prodatih proizvoda. Uslovi su sljedeèi:

- u listu ukljuèiti i one proizvode koji nisu prodani niti jednom,
- ukoliko se pojavi kolona sa NULL vrijednostima iste je potrebno zamijeniti brojem 0 (nula),
- prikazati samo proizvode koji pripadaju kategoriji "Mountain Bikes", crne su boje i imaju cijenu veæu od 2000
- Takoðer, u listu ukljuèiti i one proizvode èiji se broj završava slovom 'L' i bijele su boje,
- Izlaz je potrebno sortirati po kolièini prodatih proizvoda opadajuæim redoslijedom

*/
USE AdventureWorksLT2014

SELECT PC.Name,PM.Name,P.ProductNumber,P.ListPrice,
		P.Color,isnull(SUM(SOD.OrderQty),0) AS [Ukupno prodano]
FROM SalesLT.Product AS P INNER JOIN SalesLT.ProductCategory AS PC
	 ON P.ProductCategoryID = PC.ProductCategoryID INNER JOIN SalesLT.ProductModel AS PM
	 ON P.ProductModelID = PM.ProductModelID LEFT JOIN SalesLT.SalesOrderDetail AS SOD
	 ON P.ProductID = SOD.ProductID
WHERE (PC.Name = 'Mountain Bikes' AND P.Color = 'Black' and P.ListPrice > 2000) OR (P.ProductNumber  LIKE '%L' AND P.Color = 'White')
group by pc.Name,pm.Name,P.ProductNumber,P.ListPrice,P.Color
ORDER BY [Ukupno prodano] DESC


/* 1. Kreirati bazu podataka pod nazivom: BrojDosijea (npr. 2046) bez posebnog kreiranja data i log fajla.*/

create database ispit09072013

use ispit09072013

/*2.
U vašoj bazi podataka keirati tabele sa sljedeæim parametrima:
- Kupci
	- KupacID, automatski generator vrijednosti i primarni kljuè
 	- Ime, polje za unos 35 UNICODE karaktera (obavezan unos),
	- Prezime, polje za unos 35 UNICODE karaktera (obavezan unos),
	- Telefon, polje za unos 15 karaktera (nije obavezan),
	- Email, polje za unos 50 karaktera (nije obavezan),
	- KorisnickoIme, polje za unos 15 karaktera (obavezan unos) jedinstvena vrijednost,
	- Lozinka, polje za unos 15 karaktera (obavezan unos)
- Proizvodi
	- ProizvodID, automatski generator vrijednosti i primarni kljuè
	- Sifra, polje za unos 25 karaktera (obavezan unos)
	- Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
	- Cijena, polje za unos decimalnog broj (obavezan unos)
	- Zaliha, polje za unos cijelog broja (obavezan unos)

- Narudzbe 

 	- NarudzbaID, automatski generator vrijednosti i primarni kljuè
 	- KupacID, spoljni kljuè prema tabeli Kupci,
	- ProizvodID, spoljni kljuè prema tabeli Proizvodi,
	- Kolicina, polje za unos cijelog broja (obavezan unos)
	- Popust, polje za unos decimalnog broj (obavezan unos), DEFAULT JE 0

*/

create table Kupci
(
   KupacID int constraint PK_Kupci primary key identity(1,1),
  Ime nvarchar(35) not null,
 Prezime  nvarchar(35) not null,
 Telefon nvarchar(15),
 Email nvarchar(50),
 KorisnickoIme nvarchar(15) constraint uq_korisnickoime unique nonclustered not null,
 Lozinka nvarchar(15) not null
)

create table Proizvodi
(
 ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
 Sifra nvarchar(25) not null,
 Naziv nvarchar(50) not null,
 Cijena decimal(8,2) not null,
 Zaliha int not null,
)

create table Narudzbe
(
  NarudzbaID int constraint PK_Narudzbe primary key identity(1,1),
  KupacID int constraint FK_Narudzbe_Kupci foreign key (KupacID) REFERENCES Kupci(KupacID),
 ProizvodID int constraint FK_Narudzbe_Proizvodi foreign key (ProizvodID) REFERENCES Proizvodi(ProizvodID),
 Kolicina int not null,
 Popust decimal(8,2) default(0) not null
)


/*3.

 Modifikovati tabele Proizvodi i Narudzbe i to sljedeæa polja:
	- Zaliha (tabela Proizvodi) - omoguæiti unos decimalnog broja
	- Kolicina (tabela Narudzbe) - omoguæiti unos decimalnog broja

*/
alter table Proizvodi
ALTER COLUMN Zaliha decimal(8,2) not null

alter table Narudzbe
ALTER COLUMN Kolicina decimal(8,2) not null


/*4.
Koristeæi bazu podataka AdventureWorksLT 2012 i tabelu SalesLT.Customer, preko INSERT I SELECT komande importovati 10 zapisa
u tabelu Kupci i to sljedeæe kolone:
	- FirstName -> Ime
	- LastName -> Prezime
	- Phone -> Telefon
	- EmailAddress -> Email
	- Sve do znaka '@' u koloni EmailAddress -> KorisnickoIme
	- Prvih 8 karaktera iz kolone PasswordHash -> Lozinka

*/
insert into Kupci
select TOP 10 C.FirstName,C.LastName,C.Phone,
		C.EmailAddress,SUBSTRING(C.EmailAddress,1,CHARINDEX('@',C.EmailAddress)-1),
		LEFT(C.PasswordHash,8)
from AdventureWorksLT2014.SalesLT.Customer AS C

SELECT * FROM Kupci

/*5.
Koristeæi bazu podataka AdventureWorksLT2012 i tabelu SalesLT.Product importovati u temp tabelu po
nazivom tempBrojDosijea (npr. temp2046) 5 proizvoda i to sljedeæe kolone:
	
	- ProductName -> Sifra
	- Name -> Naziv
	- StandardCost -> Cijena

*/
SELECT top 5 P.ProductNumber as sifra,P.Name as naziv,P.StandardCost as cijena
INTO #tempTabela
FROM AdventureWorksLT2014.SalesLT.Product AS P

select * from #tempTabela

/*6.
. U vašoj bazi podataka kreirajte stored proceduru koja æe raditi INSERT podataka u tabelu Narudzbe. 
Podaci se moraju unijeti preko parametara. Takoðer , u proceduru dodati ažuriranje (UPDATE) polja 'Zaliha' (tabela Proizvodi) u 
zavisnosti od prosljeðene kolièine. Proceduru pohranite pod nazivom usp_Narudzbe_Insert.
*/
create procedure proc_Narudzbe_insert
(
@KupacID INT,
@ProizvodID INT,
@Kolicina decimal(8,2),
@Popust decimal(8,2)
)
AS
BEGIN
INSERT INTO Narudzbe
VALUES (@KupacID,@ProizvodID,@Kolicina,@Popust)

UPDATE Proizvodi
set Zaliha = Zaliha - @Kolicina
WHERE ProizvodID = @ProizvodID
END

select * from Proizvodi

INSERT INTO Proizvodi
SELECT sifra,naziv,cijena,100
FROM #tempTabela

/*7.
 Koristeæi proceduru koju ste kreirali u prethodnom zadatku kreirati 5 narudžbi.
*/

SELECT * FROM Kupci

EXEC proc_Narudzbe_insert 1,1,5,0.1
EXEC proc_Narudzbe_insert 4,2,5,0.15
EXEC proc_Narudzbe_insert 6,4,20,0.2
EXEC proc_Narudzbe_insert 6,3,20,0.2
EXEC proc_Narudzbe_insert 9,5,30,0.3

SELECT * FROM Narudzbe

SELECT * FROM Proizvodi





/*8.
 U vašoj bazi podataka kreirajte view koji æe sadržavati sljedeæa polja: ime kupca, prezime kupca, telefon, 
 šifra proizvoda, naziv proizvoda, cijena, kolièina, te ukupno. View pohranite pod nazivom view_Kupci_Narudzbe.
*/

CREATE VIEW view_Kupci_Narudzbe
AS
SELECT K.Ime,K.Prezime,K.Telefon,
		P.Sifra,P.Naziv,P.Cijena,N.Kolicina,
		SUM((P.Cijena-(P.Cijena*N.Popust))*N.Kolicina) AS Ukupno
FROM Kupci AS K INNER JOIN Narudzbe AS N
	 ON K.KupacID = N.KupacID INNER JOIN Proizvodi AS P
	 ON N.ProizvodID = P.ProizvodID
group by K.Ime,K.Prezime,K.Telefon,P.Sifra,P.Naziv,P.Cijena,N.Kolicina

SELECT * FROM view_Kupci_Narudzbe

/*9.
. U vašoj bazi podataka kreirajte stored proceduru koja æe na osnovu proslijeðenog imena ili 
prezimena kupca (jedan parametar) kao rezultat vratiti sve njegove narudžbe. 
Kao izvor podataka koristite view kreiran u zadatku 8. Proceduru pohranite pod nazivom usp_Kupci_Narudzbe.
*/
create procedure usp_Kupci_Narudzbe
(
@Ime nvarchar(35) = null,
@Prezime nvarchar(35) = null
)
as
begin
select *
from view_Kupci_Narudzbe
Where (Ime = @Ime or @Ime is null) and (Prezime  = @Prezime or @Prezime is null)
end

exec usp_Kupci_Narudzbe 'Rosmarie'

/*10.
. U vašoj bazi podataka kreirajte stored proceduru koja æe raditi DELETE zapisa iz tabele Proizvodi.
Proceduru pohranite pod nazivom usp_Proizvodi_Delete. Pokušajte obrisati jedan od proizvoda kojeg ste dodatli u zadatku 5.
Modifikujte proceduru tako da obriše proizvod i svu njegovu historiju prodaje (Narudzbe).
*/

create procedure usp_Proizvodi_Delete
(
@ProizvodID INT
)
AS
BEGIN
DELETE FROM Narudzbe
where ProizvodID in (
					select ProizvodID
					from Proizvodi
					where ProizvodID = @ProizvodID
					)
delete from Proizvodi
where ProizvodID = @ProizvodID
END

select * from Narudzbe

exec usp_Proizvodi_Delete 3

