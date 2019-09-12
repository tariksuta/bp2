/*1.
Koristeci iskljucivo SQL kod, kreirati bazu pod vlastitim brojem indeksa sa defaultnim postavkama.
Unutar svoje baze podataka kreirati tabele sa sljedecom strukturom:
a) Narudzba
- NarudzbaID, primarni kljuc
- Kupac, 40 UNICODE karakter
- PunaAdresa, 80 UNICODE karakter
- DatumNarudzbe, datumska varijabla, definirati kao datum
- Prevoz, novcana varijabla
- Uposlenik, 40 UNICODE karakter
- GradUposlenika, 30 UNICODE karakter
- DatumZaposlenja, datumska varijabla, definirati kao datum
- BtGodStaza, cjelobrojna varijabla
b) Proizvod
- ProizvodID, cjelobrojna varijabla, primarni kljuc
- NazivProizoda, 40 UNICODE karakter
- NazivDobavljaca, 40 UNICODE karakter
- StanjeNaSklad, cjelobrojna varijabla
- NarucenaKol, cjelobrojna varijabla
c) DetaljiNarudzbe
- NarudzbaID, cjelobrojna varijabla, obavezan unos
- ProizvodID, cjelobrojna varijabla, obavezan unos
- CijenaProizvoda, novcana varijabla
- Kolicina, cjelobrojna varijabla, obavezan unos
- Popoust, varijabla za realne vrijednosti
Napomena: Na jednoj narudzbi se nalazi jedan ili vise proizvoda.
*/
create database ispit24062019

use ispit24062019

create table Narudzba
(
 NarudzbaID int constraint PK_Narudzba primary key,
Kupac nvarchar(40),
 PunaAdresa  nvarchar(80),
DatumNarudzbe date,
Prevoz money,
Uposlenik  nvarchar(40),
GradUposlenika  nvarchar(30),
 DatumZaposlenja date,
 BtGodStaza int
)

create table Proizvod
(
 ProizvodID int constraint PK_Proizvod primary key,
 NazivProizoda nvarchar(40),
NazivDobavljaca nvarchar(40),
 StanjeNaSklad int,
 NarucenaKol int
)

create table DetaljiNarudzbe
(
 NarudzbaID int constraint FK_DetaljiNarudzbe_Narudzba foreign key(NarudzbaID) REFERENCES Narudzba(NarudzbaID) not null,
ProizvodID  int constraint FK_DetaljiNarudzbe_Proizvod foreign key(ProizvodID) REFERENCES Proizvod(ProizvodID) not null,
constraint PK_DetaljiNarudzbe primary key(NarudzbaID,ProizvodID),
 CijenaProizvoda money,
 Kolicina int not null,
 Popust real
)

/*2.
Import podataka u kreirane tabele.
a) Narudzbe
Koristeci bazu Northwind iz tabela Orders, Customers i Employees importovati podatke po sljedecem pravilu:
- OrderID -> ProizvodID
- CompanyName -> Kupac
- PunaAdresa – spojeno adresa, postanski broj I grad, pri cemu ce se izmedju rijeci staviti srednja crta sa razmakom
prije I poslije nje
- OrderDate -> DatumNarudzbe
- Freight -> Prevoz
- Uposlenik – spojeno prezime I ime sa razmakom izmedju njih
- City -> Grad iz kojeg je uposlenik
- HireDate -> DatumZaposlenja
- BrGodStaza – broj godina od datuma zaposlenja
b) Proizvod
Koristeci bazu Northwind iz tabela Products I Suppliers putem podupita importovati podake po sljedecem pravilu:
- ProductID -> ProizvodID
- ProductName -> NazivProizvoda
- CompanyName -> NazivDobavljaca
- UnitsInStock -> StanjeNaSklad
- UnitsOnOrder -> NarucenaKol
c) DetaljiNarudzbe
Koristeci bazu Northwind iz tabele OrderDetails importovati podake po sljedecem pravilu:
- OrderID -> NarudzbaID
- ProductID -> ProizvodID
- CijenaProizvoda – manja zaokruzena vrijednost kolone UnitPrice, npr UnitPrice = 3,60 / CijenaProizvoda = 3,00
*/
insert into Narudzba
select O.OrderID,C.CompanyName,
		C.Address+' - '+C.PostalCode+' - '+C.City,
		O.OrderDate,O.Freight,
		E.FirstName+' '+E.LastName,E.City,
		E.HireDate,
		DATEDIFF(YEAR,E.HireDate,GETDATE())
from NORTHWND.dbo.Customers as C INNER JOIN NORTHWND.dbo.Orders AS O
	 ON C.CustomerID = O.CustomerID INNER JOIN NORTHWND.dbo.Employees AS E
	 ON O.EmployeeID = E.EmployeeID

INSERT INTO Proizvod
select B.ProductID,B.ProductName,B.CompanyName,B.UnitsInStock,B.UnitsOnOrder
from (
		select P.ProductID,P.ProductName,S.CompanyName,P.UnitsInStock,P.UnitsOnOrder
		from NORTHWND.dbo.Products as P INNER JOIN NORTHWND.dbo.Suppliers AS S
			 ON P.SupplierID = S.SupplierID
		) AS B

INSERT INTO DetaljiNarudzbe
select OrderID,ProductID,FLOOR(UnitPrice),
		Quantity,Discount
from NORTHWND.dbo.[Order Details]






/*
3. a) U tabelu Narudzba dodati kolonu SifraUposlenika kao 20 UNICODE karaktera. Postaviti uslov da podatak mora biti duzine
tacno 15 karaktera
b) Kolonu SifraUpooslenika popuniti na nacin da se obrne string koji se dobije spajanjem grada uposlenika I prvih 10 karaktera
datuma zaposlenja pri cemu se izmedju grada I 10 karaktera nalazi jedno prazno mjesto. Provjeriti da li je izvrsena izmjena.
c) U tabeli Narudzba u koloni SifraUposlenika izvrsiti zamjenu svih zapisa kojima grad uposlenika zavrsava slovom “d” tako da
se umjesto toga ubaci slucajno generisani string duzine 20 karaktera. Provjeriti da li je izvrsena zamjena
*/
ALTER TABLE Narudzba
ADD SifraUposlenika NVARCHAR(20) CONSTRAINT Check_Duzina CHECK(LEN(SifraUposlenika)= 15)

UPDATE Narudzba
set SifraUposlenika = REVERSE(LEFT(GradUposlenika,4)+' '+ cast(DatumZaposlenja as nvarchar(10)))

SELECT * FROM Narudzba

alter table Narudzba
drop constraint Check_Duzina

UPDATE Narudzba
set SifraUposlenika= LEFT(NEWID(),20)
WHERE GradUposlenika like '%d'

SELECT * FROM Narudzba

/*4.
Koristeci svoju bazu iz tabela Narudzba I DetaljiNarudzbe kreirati pogled koji ce imati sljedecu strukturu: Uposlenik,
SifraUposlenika, ukupan broj proizvoda izveden iz NazivProizvoda, uz uslove da je sifra uposlenika 20 karaktera, te da je
ukupan broj proizvoda veci od 2. Provjeriti sadrzaj pogleda, pri cemu se treba izvrsiti sortiranje po ukupnom broju proizvoda u
opadajucem redosljedu
*/
create view view_Narudzba_DetaljiNarudzbe
as
select N.Uposlenik,N.SifraUposlenika,COUNT(P.NazivProizoda) AS [Broj prozvoda]
from Narudzba AS N INNER JOIN DetaljiNarudzbe AS DN
	 ON N.NarudzbaID = DN.NarudzbaID INNER JOIN Proizvod AS P
	 ON DN.ProizvodID = P.ProizvodID
WHERE LEN(N.SifraUposlenika) = 20
GROUP BY N.Uposlenik,N.SifraUposlenika
HAVING COUNT(P.NazivProizoda) > 2

SELECT * FROM view_Narudzba_DetaljiNarudzbe
ORDER BY [Broj prozvoda] DESC

/*5.
Koristeci vlastitu bazu kreirati proceduru nad tabelom Narudzbe kojom ce se duzina podataka u koloni SifraUposlenika
smanjiti sa 20 na 4 slucajno generisana karaktera. Pokrenuti proceduru
*/

CREATE PROCEDURE proc_Narudzbe_SifraUposlenika_4
as
begin
UPDATE Narudzba
SET SifraUposlenika = left(NEWID(),4)
WHERE LEN(SifraUposlenika) = 20
end
exec proc_Narudzbe_SifraUposlenika_4

select * from Narudzba
/*6.
Koristeci vlastitu bazu kreirati pogled koji ce imati sljedecu strukturu: NazivProizvoda, Ukupno – ukupnu sumu prodaje
proizvoda uz uzimanje u obzir I popusta. Suma mora biti zaokruzena na dvije decimale. U pogled uvrstiti one proizvode koji su
naruceni, uz uslov da je suma veca od 1000. Provjeriti sadrzaj pogleda pri cemu ispis treba sortirati u opadajucem redoslijedu
po vrijednosti sume
*/
create view view_Proizvodi_DetaljiNarudzbe
as
select P.NazivProizoda,ROUND(SUM((DN.CijenaProizvoda-(DN.CijenaProizvoda*DN.Popust))*DN.Kolicina),2) AS Ukupno
from Proizvod AS P INNER JOIN DetaljiNarudzbe AS DN
	 ON P.ProizvodID = DN.ProizvodID
WHERE P.NarucenaKol > 0
GROUP BY P.NazivProizoda
HAVING SUM((DN.CijenaProizvoda-(DN.CijenaProizvoda*DN.Popust))*DN.Kolicina) > 1000

SELECT * FROM view_Proizvodi_DetaljiNarudzbe
ORDER BY Ukupno desc

/*7.
a) Koristeci vlastitu bazu podataka kreirati pogled koji ce imati sljedecu strukturu:
- Kupac,
- NazivProizvoda
- Suma po cijeni proizvoda
Pri cemu ce se u pogled smjestiti samo oni zapisi kod kojih je cijena proizvoda veca od srednje vrijednosti cijene proizvoda.
Provjeriti sadrzaj pogleda pri cemu izlaz treba sortirati u rastucem redoslijedu izracunatoj sumi
*/
create view view_1
as
select N.Kupac,P.NazivProizoda,SUM(DN.CijenaProizvoda) AS [Suma po cijeni]
from Narudzba as N INNER JOIN DetaljiNarudzbe AS DN
	 ON N.NarudzbaID = DN.NarudzbaID INNER JOIN Proizvod AS P
	 ON DN.ProizvodID = P.ProizvodID
WHERE DN.CijenaProizvoda > (
							SELECT AVG(CijenaProizvoda)
							FROM DetaljiNarudzbe
							)
group by N.Kupac,P.NazivProizoda

SELECT * FROM view_1
ORDER BY [Suma po cijeni]

/*
b) Koristeci vlastitu bazu podataka kreirati proceduru kojom ce se, koristeci prethodno kreirani pogled, definirati parametri:
Kupac, NazivProizvoda I SumaPoCijeni. Proceduru kreirati tako da je prilikom izvrsavanja moguce unijeti bilo koji broj
parametara (mozemo ostaviti bilo koji parametar bez unijete vrijednosti), uz uslov da vrijednost sume bude veca od srednje
vrijednosti suma koje su smjestene u pogled. Sortirati po sumi cijene. Procedura se treba izvrsiti ako se unese vrijednost za bilo
koji parametar. Nakon kreiranja pokrenuti proceduru za sljedece vrijednosti parametara:
1. SumaPoCijeni = 123
2. Kupac = Hanari Carnes
3. NazivProizvoda = Cote de Blaye
*/

CREATE PROCEDURE proc_view_1_pretraga
(
@Kupac NVARCHAR(40) = null,
@NazivProizvoda nvarchar(40) = null,
@SumaPoCijeni decimal(8,2) = null
)
as
begin
select *
from view_1
where (Kupac = @Kupac or @Kupac is null)
		and (NazivProizoda = @NazivProizvoda or @NazivProizvoda is null)
		and ([Suma po cijeni] = @SumaPoCijeni or @SumaPoCijeni is null)
		and [Suma po cijeni] > (
								SELECT AVG([Suma po cijeni])
								FROM view_1
								)
ORDER BY [Suma po cijeni]
end

EXEC proc_view_1_pretraga @SumaPoCijeni = 123
EXEC proc_view_1_pretraga 'Hanari Carnes'
EXEC proc_view_1_pretraga @NazivProizvoda = 'Côte de Blaye'


/*8
 a) Kreirati indeks nad tabelom Proizvod. Potrebno je indeksirati NazivDobavljaca. Ukljuciti I kolone StanjeNaSklad I
NarucenaKol. Napisati proizvoljni upit nad tabelom Proizvod koji u potpunosti koristi prednost kreiranog indeksa.
b) Uraditi disable indeksa iz prethodnog koraka
*/
create nonclustered index IX_Proizvod_NazivDobavljaca
on Proizvod(NazivDobavljaca)
include(StanjeNaSklad,NarucenaKol)

select NazivDobavljaca
from Proizvod
where NarucenaKol > 50

alter index IX_Proizvod_NazivDobavljaca on Proizvod
disable

/*9
Napraviti backup baze podataka na default lokaciju servera
*/

backup database ispit24062019 to 
disk ='ispit24062019.bak'

/*Kreirati proceduru kojom ce se u jednom pokretanju izvrsiti brisanje svih pogleda I procedura koji su kreirani u vasoj bazi*/

create procedure proc_delete
as
begin
drop view view_Narudzba_DetaljiNarudzbe
drop proc proc_Narudzbe_SifraUposlenika_4
drop view view_Proizvodi_DetaljiNarudzbe
drop view view_1
drop proc proc_view_1_pretraga
drop proc proc_delete
end

exec proc_delete