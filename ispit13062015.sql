/*
1. Kreirati bazu podataka koju ćete imenovati Vašim brojem dosijea. Fajlove baze smjestiti na sljedeće lokacije:
 Data fajl -> D:\DBMS\Data
 Log fajl -> D:\DBMS\Log
*/
create database ispit13062015 on primary
(NAME = ispit13062015,FILENAME = 'C:\BP2\data\ispit13062015.mdf')
log on
(NAME = ispit13062015_log,FILENAME = 'C:\BP2\log\ispit13062015.ldf')

use ispit13062015


/*2.
. U bazi podataka kreirati sljedeće tabele:
a. Kandidati
 Ime, polje za unos 30 karaktera (obavezan unos),
 Prezime, polje za unos 30 karaktera (obavezan unos),
 JMBG, polje za unos 13 karaktera (obavezan unos i jedinstvena vrijednost),
 DatumRodjenja, polje za unos datuma (obavezan unos),
 MjestoRodjenja, polje za unos 30 karaktera,
 Telefon, polje za unos 20 karaktera,
 Email, polje za unos 50 karaktera (jedinstvena vrijednost).
b. Testovi
 Datum, polje za unos datuma i vremena (obavezan unos),
 Naziv, polje za unos 50 karaktera (obavezan unos),
 Oznaka, polje za unos 10 karaktera (obavezan unos i jedinstvena vrijednost),
 Oblast, polje za unos 50 karaktera (obavezan unos),
 MaxBrojBodova, polje za unos cijelog broja (obavezan unos),
 Opis, polje za unos 250 karaktera.
c. RezultatiTesta
 Polozio, polje za unos ishoda testiranja – DA/NE (obavezan unos)
 OsvojeniBodovi, polje za unos decimalnog broja (obavezan unos),
 Napomena, polje za unos dužeg niza karaktera.

Napomena: Kandidat može da polaže više testova i za svaki test ostvari određene rezultate, pri čemu kandidat ne
može dva puta polagati isti test. Također, isti test može polagati više kandidata
*/

create table Kandidati
(
KandidatID INT CONSTRAINT PK_Kandidati primary key identity(1,1),
 Ime nvarchar(30) not null,
 Prezime nvarchar(30) not null,
 JMBG nvarchar(13) constraint uq_jmbg unique not null,
 DatumRodjenja date not null,
 MjestoRodjenja nvarchar(30),
 Telefon nvarchar(20),
 Email nvarchar(50) constraint uq_email unique
)

create table Testovi
(
TestID INT CONSTRAINT PK_Testovi primary key identity(1,1),
 Datum datetime not null,
 Naziv nvarchar(50) not null,
 Oznaka nvarchar(10) constraint uq_oznaka unique not null,
 Oblast nvarchar(50) not null,
 MaxBrojBodova int not null,
 Opis nvarchar(250)
)

create table RezultatiTesta
(
TestID INT CONSTRAINT FK_RezultatiTesta_Testovi foreign key(TestID) REFERENCES Testovi(TestID),
KandidatID INT CONSTRAINT FK_RezultatiTesta_Kandidati foreign key(KandidatID) references Kandidati(KandidatID),
constraint PK_RezultatiTesta primary key(TestID,KandidatID),
 Polozio bit not null,
 OsvojeniBodovi decimal(8,2) not null,
 Napomena text
)


/*3.
Koristeći AdventureWorks2014 bazu podataka, importovati 10 kupaca u tabelu Kandidati i to sljedeće
kolone:
a. FirstName (Person) -> Ime,
b. LastName (Person) -> Prezime,
c. Zadnjih 13 karaktera kolone rowguid iz tabele Customer (Crticu zamijeniti brojem 0) -> JMBG,
d. ModifiedDate (Customer) -> DatumRodjenja,
e. City (Address) -> MjestoRodjenja,
f. PhoneNumber (PersonPhone) -> Telefon,
g. EmailAddress (EmailAddress) -> Email.
Također, u tabelu Testovi unijeti minimalno tri testa sa proizvoljnim podacima.
*/
insert into Kandidati
select TOP 10 P.FirstName,P.LastName,REPLACE(RIGHT(C.rowguid,13),'-','0'),
		C.ModifiedDate,A.City,PP.PhoneNumber,EA.EmailAddress
from AdventureWorks2014.Sales.Customer AS C INNER JOIN AdventureWorks2014.Person.Person AS P
	 ON C.PersonID = P.BusinessEntityID INNER JOIN AdventureWorks2014.Person.BusinessEntityAddress AS BEA
	 ON P.BusinessEntityID = BEA.BusinessEntityID INNER JOIN AdventureWorks2014.Person.Address AS A
	 ON BEA.AddressID = A.AddressID INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP
	 ON P.BusinessEntityID = PP.BusinessEntityID INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA
	 ON P.BusinessEntityID = EA.BusinessEntityID

INSERT INTO Testovi(Datum,Naziv,Oznaka,Oblast,MaxBrojBodova)
values ('20190619','Analiza i dizajn softvera','ADS','Dizajn',100),
		('20190623','Engleski jezi III','ENGIII','JEZIK',80),
		('20190626','Web razvoj i dizajn','WRD','WEB',100)

/*4.
Kreirati stored proceduru koja će na osnovu proslijeđenih parametara služiti za unos podataka u tabelu
RezultatiTesta. Proceduru pohraniti pod nazivom usp_RezultatiTesta_Insert. Obavezno testirati ispravnost
kreirane procedure (unijeti proizvoljno minimalno 10 rezultata za različite testove).
*/
CREATE PROCEDURE usp_RezultatiTesta_Insert
(
@TestID INT,
@KandidatID INT,
@Polozio bit,
@OsvBodovi decimal(8,2)
)
as
begin
insert into RezultatiTesta(TestID,KandidatID,Polozio,OsvojeniBodovi)
values (@TestID,@KandidatID,@Polozio,@OsvBodovi)
end

exec usp_RezultatiTesta_Insert 1,3,1,88
exec usp_RezultatiTesta_Insert 1,5,1,77
exec usp_RezultatiTesta_Insert 1,9,0,45
exec usp_RezultatiTesta_Insert 2,1,1,65
exec usp_RezultatiTesta_Insert 2,6,1,70
exec usp_RezultatiTesta_Insert 2,5,1,74
exec usp_RezultatiTesta_Insert 3,1,0,50
exec usp_RezultatiTesta_Insert 3,8,1,65
exec usp_RezultatiTesta_Insert 3,4,1,80
exec usp_RezultatiTesta_Insert 3,10,1,100

select * from RezultatiTesta


/*5.
Kreirati view (pogled) nad podacima koji će sadržavati sljedeća polja: ime i prezime, jmbg, telefon i email
kandidata, zatim datum, naziv, oznaku, oblast i max. broj bodova na testu, te polje položio, osvojene bodove i
procentualni rezultat testa. View pohranite pod nazivom view_Rezultati_Testiranja
*/
create view view_Rezultati_Testiranja
as
select K.Ime+' '+K.Prezime AS [Ime i prezime],
		K.JMBG,K.Telefon,K.Email,T.Datum,
		T.Naziv,T.Oznaka,T.Oblast,T.MaxBrojBodova,
		RT.Polozio,RT.OsvojeniBodovi,
		FLOOR((RT.OsvojeniBodovi/T.MaxBrojBodova)* 100) AS Procenat
from Kandidati as K INNER JOIN RezultatiTesta AS RT
	 ON K.KandidatID = RT.KandidatID INNER JOIN Testovi AS T
	 ON RT.TestID = T.TestID

	select * from view_Rezultati_Testiranja


/*6.
Kreirati stored proceduru koja će na osnovu proslijeđenih parametara @OznakaTesta i @Polozio prikazivati
rezultate testiranja. Kao izvor podataka koristiti prethodno kreirani view. Proceduru pohraniti pod nazivom
usp_RezultatiTesta_SelectByOznaka. Obavezno testirati ispravnost kreirane procedure
*/

create procedure usp_RezultatiTesta_SelectByOznaka
(
@OznakaTesta nvarchar(10),
@Polozio bit
)
as
begin
select *
from view_Rezultati_Testiranja
where Oznaka = @OznakaTesta and Polozio = @Polozio
end

exec usp_RezultatiTesta_SelectByOznaka 'ADS',0




/*7.
 Kreirati proceduru koja će služiti za izmjenu rezultata testiranja. Proceduru pohraniti pod nazivom
usp_RezultatiTesta_Update. Obavezno testirati ispravnost kreirane procedure
*/

create procedure usp_RezultatiTesta_Update
(
@TestID INT,
@kandidatID INT,
@Polozio BIT,
@OsvBodovi decimal(8,2),
@Napomena text
)
as
begin
UPDATE RezultatiTesta
set Polozio = @Polozio,
	OsvojeniBodovi = @OsvBodovi,
	Napomena = @Napomena
where TestID = @TestID and KandidatID = @kandidatID
end

select * from RezultatiTesta

exec usp_RezultatiTesta_Update 1,9,1,55,'greska prilikom ocjenjivanja'


/*8.
Kreirati stored proceduru koja će služiti za brisanje testova zajedno sa svim rezultatima testiranja. Proceduru
pohranite pod nazivom usp_Testovi_Delete. Obavezno testirati ispravnost kreirane procedure.
*/

create procedure usp_Testovi_Delete
(
@TestID INT
)
AS
BEGIN
DELETE FROM RezultatiTesta
WHERE TestID IN (
				SELECT TestID
				FROM Testovi
				WHERE TestID =@TestID
				)
DELETE FROM Testovi
WHERE TestID = @TestID
END

exec usp_Testovi_Delete 2


/*9.
Kreirati trigger koji će spriječiti brisanje rezultata testiranja. Obavezno testirati ispravnost kreiranog triggera.
*/

create trigger tr_RezultatiTestiranja_delete
on RezultatiTesta INSTEAD OF DELETE
AS
BEGIN
PRINT 'Nije dozvoljeno brisanje zapisa'
rollback
END

delete from RezultatiTesta
where TestID = 3


/*10. Uraditi full backup Vaše baze podataka na lokaciju D:\DBMS\Backup*/

backup database ispit13062015 to
disk = 'C:\BP2\Backup\ispit13062015.bak'

