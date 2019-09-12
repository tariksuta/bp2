/*1.
Kroz SQL kod napraviti bazu podataka koja nosi ime vašeg broja dosijea, a zatim u svojoj bazi podataka kreirati
tabele sa sljedeæom strukturom:
a) Klijenti
i. Ime, polje za unos 50 karaktera (obavezan unos)
ii. Prezime, polje za unos 50 karaktera (obavezan unos)
iii. Grad, polje za unos 50 karaktera (obavezan unos)
iv. Email, polje za unos 50 karaktera (obavezan unos)
v. Telefon, polje za unos 50 karaktera (obavezan unos)
b) Racuni
i. DatumOtvaranja, polje za unos datuma (obavezan unos)
ii. TipRacuna, polje za unos 50 karaktera (obavezan unos)
iii. BrojRacuna, polje za unos 16 karaktera (obavezan unos)
iv. Stanje, polje za unos decimalnog broja (obavezan unos)
c) Transakcije
i. Datum, polje za unos datuma i vremena (obavezan unos)
ii. Primatelj polje za unos 50 karaktera – (obavezan unos)
iii. BrojRacunaPrimatelja, polje za unos 16 karaktera (obavezan unos)
iv. MjestoPrimatelja, polje za unos 50 karaktera (obavezan unos)
v. AdresaPrimatelja, polje za unos 50 karaktera (nije obavezan unos)
vi. Svrha, polje za unos 200 karaktera (nije obavezan unos)
vii. Iznos, polje za unos decimalnog broja (obavezan unos)

Napomena: Klijent može imati više otvorenih raèuna, dok se svaki raèun veže iskljuèivo za jednog klijenta. Sa
raèuna klijenta se provode transakcije, dok se svaka pojedinaèna transakcija provodi sa jednog raèuna
*/
create database ispit07092017

use ispit07092017

create table Klijenti
(
KlijentID INT CONSTRAINT PK_Klijenti primary key identity(1,1),
Ime nvarchar(50) not null,
 Prezime nvarchar(50) not null,
 Grad nvarchar(50) not null,
 Email nvarchar(50) not null,
Telefon nvarchar(50) not null,
)

create table Racuni
(
RacunID INT CONSTRAINT PK_Racuni primary key identity(1,1),
KlijentID INT CONSTRAINT FK_Racuni_Klijenti foreign key(KlijentID) REFERENCES Klijenti(KlijentID),
 DatumOtvaranja date not null,
 TipRacuna nvarchar(50) not null,
 BrojRacuna nvarchar(16) not null,
 Stanje decimal(8,2) not null
)

create table Transakcije
(
TransakcijaID INT CONSTRAINT PK_Transakcije primary key identity(1,1),
RacunID INT CONSTRAINT FK_Tranakcije_Racuni foreign key(RacunID) REFERENCES Racuni(RacunID),
 Datum datetime not null,
Primatelj nvarchar(50) not null,
 BrojRacunaPrimatelja nvarchar(16) not null,
 MjestoPrimatelja nvarchar(50) not null,
AdresaPrimatelja nvarchar(50),
 Svrha nvarchar(200),
 Iznos decimal(8,2) not null
)

/*2.Nad poljem Email u tabeli Klijenti, te BrojRacuna u tabeli Racuni kreirati unique index.*/

create unique nonclustered index IX_Klijenti_Email
ON Klijenti(Email)

create unique nonclustered index UQ_Racuni_BrojRacuna
on Racuni(BrojRacuna)

/*3.Kreirati uskladištenu proceduru za unos novog raèuna. Obavezno provjeriti ispravnost kreirane procedure.*/

create procedure proc_Racuni_insert
(
@KlijentID INT,
@DatumOtvaranja date,
@TipRacuna nvarchar(50),
@BrojRacuna nvarchar(16),
@Stanje decimal(8,2)
)
as
begin
insert into Racuni
values (@KlijentID,@DatumOtvaranja,@TipRacuna,@BrojRacuna,@Stanje)
end

insert into Klijenti
values ('test','test','test','test.test@mail','000-000-000')

exec proc_Racuni_insert 1,'20181010','tip1','0000000000000001',100

select * from Racuni

/*4.
 Iz baze podataka Northwind u svoju bazu podataka prebaciti sljedeæe podatke:
a) U tabelu Klijenti prebaciti sve kupce koji su obavljali narudžbe u 1996. godini
i. ContactName (do razmaka) -> Ime
ii. ContactName (poslije razmaka) -> Prezime
iii. City -> Grad
iv. ContactName@northwind.ba -> Email (Izmeðu imena i prezime staviti taèku)
v. Phone -> Telefon
b) Koristeæi prethodno kreiranu proceduru u tabelu Racuni dodati 10 raèuna za razlièite kupce
(proizvoljno). Odreðenim kupcima pridružiti više raèuna.

c) Za svaki prethodno dodani raèun u tabelu Transakcije dodati po 10 transakcija. Podatke za tabelu
Transakcije preuzeti RANDOM iz Northwind baze podataka i to poštujuæi sljedeæa pravila:
i. OrderDate (Orders) -> Datum
ii. ShipName (Orders) - > Primatelj
iii. OrderID + '00000123456' (Orders) -> BrojRacunaPrimatelja
iv. ShipCity (Orders) -> MjestoPrimatelja,
v. ShipAddress (Orders) -> AdresaPrimatelja,
vi. NULL -> Svrha,
vii. Ukupan iznos narudžbe (Order Details) -> Iznos
Napomena (c): ID raèuna ruèno izmijeniti u podupitu prilikom inserta podataka
*/

--a
insert into Klijenti
select DISTINCT SUBSTRING(C.ContactName,1,CHARINDEX(' ',C.ContactName)-1),
		SUBSTRING(C.ContactName,CHARINDEX(' ',C.ContactName)+1,20),
		C.City,
		SUBSTRING(C.ContactName,1,CHARINDEX(' ',C.ContactName)-1)+'.'+SUBSTRING(C.ContactName,CHARINDEX(' ',C.ContactName)+1,20)+'@northwind.ba',
		C.Phone
from NORTHWND.dbo.Customers AS C INNER JOIN NORTHWND.dbo.Orders as O
	 ON C.CustomerID = O.CustomerID
WHERE DATEPART(YEAR,O.OrderDate) = 1996

SELECT * FROM Klijenti

--B
EXEC proc_Racuni_insert 3,'20171201','TIP2','1111111111111111',1500
EXEC proc_Racuni_insert 10,'20170601','TIP2','1111111111411111',1900
EXEC proc_Racuni_insert 3,'20190101','TIP1','1111131111111111',850
EXEC proc_Racuni_insert 7,'20180901','TIP2','1114111111111111',1200
EXEC proc_Racuni_insert 18,'20171201','TIP1','5111111111111111',2300
EXEC proc_Racuni_insert 10,'20181001','TIP1','1111111111111161',1000
EXEC proc_Racuni_insert 23,'20180301','TIP2','1111711111111111',1500
EXEC proc_Racuni_insert 40,'20190511','TIP1','1111111181111111',500
EXEC proc_Racuni_insert 40,'20180111','TIP2','1111111181114111',2500
EXEC proc_Racuni_insert 45,'20190611','TIP1','5111311181151111',570

SELECT * FROM Racuni

--C

INSERT INTO Transakcije
select TOP 10 (SELECT RacunID FROM Racuni WHERE RacunID = 11),O.OrderDate,
		O.ShipName,CAST(O.OrderID AS NVARCHAR) + '00000123456',
		O.ShipCity,O.ShipAddress,NULL,SUM((OD.UnitPrice-(OD.UnitPrice*OD.Discount))*OD.Quantity)
from NORTHWND.dbo.Orders as O INNER JOIN NORTHWND.dbo.[Order Details] as OD
	 ON O.OrderID = OD.OrderID
GROUP BY O.OrderDate,O.ShipName,O.OrderID,O.ShipCity,O.ShipAddress
ORDER BY NEWID()

SELECT * FROM Transakcije





/*5.
 Svim raèunima èiji vlasnik dolazi iz Londona, a koji su otvoreni u 8. mjesecu, stanje uveæati za 500. Grad i mjesec
se mogu proizvoljno mijenjati kako bi se rezultat komande prilagodio vlastitim podacima
*/

update Racuni
SET Stanje = Stanje + 500
WHERE KlijentID in (
					select KlijentID
					from Klijenti
					where Grad = 'Lander'
					) and DATEPART(MONTH,DatumOtvaranja) = 6

select * from Racuni

select * from Klijenti

/*6.
Kreirati view (pogled) koji prikazuje ime i prezime (spojeno), grad, email i telefon klijenta, zatim tip raèuna, broj
raèuna i stanje, te za svaku transakciju primatelja, broj raèuna primatelja i iznos. Voditi raèuna da se u rezultat
ukljuèe i klijenti koji nemaju otvoren niti jedan raèun
*/

create VIEW view_Klijenti_Transkacije
as
select K.Ime+' '+K.Prezime AS [Ime i prezime],
		K.Grad,K.Email,K.Telefon,
		R.TipRacuna,R.BrojRacuna,R.Stanje,
		T.BrojRacunaPrimatelja,T.Iznos
from Klijenti as K LEFT JOIN Racuni AS R
	 ON K.KlijentID = R.KlijentID LEFT JOIN Transakcije AS T
	 ON R.RacunID = T.RacunID

	 SELECT * FROM view_Klijenti_Transkacije

/*7.
Kreirati uskladištenu proceduru koja æe na osnovu proslijeðenog broja raèuna klijenta prikazati podatke o
vlasniku raèuna (ime i prezime, grad i telefon), broj i stanje raèuna te ukupan iznos transakcija provedenih sa
raèuna. Ukoliko se ne proslijedi broj raèuna, potrebno je prikazati podatke za sve raèune. Sve kolone koje
prikazuju NULL vrijednost formatirati u 'N/A'. U proceduri koristiti prethodno kreirani view. Obavezno provjeriti
ispravnost kreirane procedure
*/

CREATE PROCEDURE proc_view_Klijenti_Transkacije_SelectByBrojRacuna
(
@BrojRacuna nvarchar(16) = null
)
as
begin
select [Ime i prezime],Grad,Telefon,ISNULL(BrojRacuna,'N/A') AS BrojRacuna,ISNULL(CAST(Stanje AS nvarchar),'N/A') AS Stanje,
		ISNULL(CAST(SUM(Iznos) AS nvarchar),'N/A') as Ukupno
from view_Klijenti_Transkacije
where BrojRacuna = @BrojRacuna or @BrojRacuna is null
group by [Ime i prezime],Grad,Telefon,BrojRacuna,Stanje
end

EXEC proc_view_Klijenti_Transkacije_SelectByBrojRacuna '1111111111111111'

EXEC proc_view_Klijenti_Transkacije_SelectByBrojRacuna
/*8.
Kreirati uskladištenu proceduru koja æe na osnovu unesenog identifikatora klijenta vršiti brisanje klijenta
ukljuèujuæi sve njegove raèune zajedno sa transakcijama. Obavezno provjeriti ispravnost kreirane procedure
*/

CREATE PROCEDURE proc_Klijenti_delete
(
@KlijentiD INT
)
AS
BEGIN
DELETE FROM Transakcije
WHERE RacunID in (
				 select R.RacunID
				 from Racuni AS R
				 WHERE R.KlijentID = @KlijentiD
				 )
DELETE FROM Racuni
WHERE KlijentID IN (
					SELECT KlijentID
					FROM Klijenti
					WHERE KlijentID = @KlijentiD
					)
DELETE FROM Klijenti
WHERE KlijentID = @KlijentiD
END

EXEC proc_Klijenti_delete 23

/*9.
Komandu iz zadatka 5. pohraniti kao proceduru a kao parametre proceduri proslijediti naziv grada, mjesec i iznos
uveæanja raèuna. Obavezno provjeriti ispravnost kreirane procedure
*/

create procedure proc_zad_5
(
@Grad nvarchar(50),
@Mjesec INT,
@Iznos decimal(8,2)
)
as
begin
update Racuni
SET Stanje = Stanje + @Iznos
WHERE KlijentID in (
					select KlijentID
					from Klijenti
					where Grad = @Grad
					) and DATEPART(MONTH,DatumOtvaranja) = @Mjesec
end
exec proc_zad_5 'Lander',6,100

select * from Racuni
/*10. Kreirati full i diferencijalni backup baze podataka na lokaciju servera D:\BP2\Backup*/

backup database ispit07092017 to
disk ='C:\BP2\Backup\ispit07092017.bak'

backup database ispit07092017 to
disk ='C:\BP2\Backup\ispit07092017_dif.bak'
with differential