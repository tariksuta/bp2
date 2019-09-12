/*1.
Kreirati bazu podataka koju ćete imenovati Vašim brojem dosijea. Fajlove baze smjestiti na sljedeće lokacije:
 Data fajl -> D:\DBMS\Data
 Log fajl -> D:\DBMS\Log
*/


create database ispit04072015 on primary
(NAME = ispit04072015,filename = 'C:\BP2\data\ispit04072015.mdf')
log on
(NAME = ispit04072015_log,filename = 'C:\BP2\log\ispit04072015_log.ldf')

use ispit04072015
/*2.
U bazi podataka kreirati sljedeće tabele:
a. Klijenti
 JMBG, polje za unos 13 karaktera (obavezan unos i jedinstvena vrijednost),
 Ime, polje za unos 30 karaktera (obavezan unos),
 Prezime, polje za unos 30 karaktera (obavezan unos),
 Adresa, polje za unos 100 karaktera (obavezan unos),
 Telefon, polje za unos 20 karaktera (obavezan unos),
 Email, polje za unos 50 karaktera (jedinstvena vrijednost),
 Kompanija, polje za unos 50 karaktera.
b. Krediti
 Datum, polje za unos datuma (obavezan unos),
 Namjena, polje za unos 50 karaktera (obavezan unos),
 Iznos, polje za decimalnog broja (obavezan unos),
 BrojRata, polje za unos cijelog broja (obavezan unos),
 Osiguran, polje za unos bit vrijednosti (obavezan unos),
 Opis, polje za unos dužeg niza karaktera.
c. Otplate
 Datum, polje za unos datuma (obavezan unos)
 Iznos, polje za unos decimalnog broja (obavezan unos),
 Rata, polje za unos cijelog broja (obavezan unos),
 Opis, polje za unos dužeg niza karaktera.
Napomena: Klijent može uzeti više kredita, dok se kredit veže isključivo za jednog klijenta. Svaki kredit može imati
više otplata (otplata rata).
*/
create table Klijenti
(
KlijentID INT CONSTRAINT PK_Klijenti primary key identity(1,1),
 JMBG nvarchar(13) constraint UQ_JMBG UNIQUE NONCLUSTERED NOT NULL,
 Ime NVARCHAR(30) NOT NULL,
 Prezime NVARCHAR(30) NOT NULL,
 Adresa NVARCHAR(100) NOT NULL,
 Telefon NVARCHAR(20) NOT NULL,
 Email NVARCHAR(50) CONSTRAINT UQ_Email UNIQUE NONCLUSTERED,
 Kompanija NVARCHAR(50)
)

CREATE TABLE Krediti
(
KreditID INT CONSTRAINT PK_Krediti primary key identity(1,1),
KlijentID INT CONSTRAINT FK_Krediti_Klijenti foreign key(KlijentID) references Klijenti(KlijentID),
 Datum date not null,
 Namjena nvarchar(50) not null,
 Iznos decimal(8,2) not null,
 BrojRata int not null,
 Osiguran bit not null,
Opis text
)

create table Otplate
(
OtplataID INT CONSTRAINT PK_Otplate primary key identity(1,1),
KreditID INT CONSTRAINT PK_Otplate_Krediti foreign key(KreditID) REFERENCES Krediti(KreditID),
 Datum date not null,
 Iznos decimal(8,2) not null,
 Rata int not null,
 Opis text
)

/*3.
Koristeći AdventureWorks2014 bazu podataka, importovati 10 kupaca u tabelu Klijenti i to sljedeće kolone:
a. Zadnjih 13 karaktera kolone rowguid (Crticu '-' zamijeniti brojem 1)-> JMBG,
b. FirstName (Person) -> Ime,
c. LastName (Person) -> Prezime,
d. AddressLine1 (Address) -> Adresa,
e. PhoneNumber (PersonPhone) -> Telefon,
f. EmailAddress (EmailAddress) -> Email,
g. 'FIT' -> Kompanija
Također, u tabelu Krediti unijeti minimalno tri zapisa sa proizvoljnim podacima
*/
INSERT INTO Klijenti
select TOP 10 REPLACE(RIGHT(C.rowguid,13),'-','1'),
		P.FirstName,P.LastName,A.AddressLine1,PP.PhoneNumber,EA.EmailAddress,'FIT'
from AdventureWorks2014.Sales.Customer as C INNER JOIN AdventureWorks2014.Person.Person AS P
	 ON C.PersonID = P.BusinessEntityID INNER JOIN AdventureWorks2014.Person.BusinessEntityAddress AS BEA
	 ON P.BusinessEntityID = BEA.BusinessEntityID INNER JOIN AdventureWorks2014.Person.Address AS A
	 ON BEA.AddressID = A.AddressID INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP
	 ON P.BusinessEntityID =PP.BusinessEntityID INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA
	 ON P.BusinessEntityID = EA.BusinessEntityID

	 SELECT * FROM Klijenti

	 insert into Krediti (KlijentID,Datum,Namjena,Iznos,BrojRata,Osiguran) 
	 values (2,'20170812','Stambeni',70000,50,1),
			(5,'20181012','Stambeni',80000,55,1),
			(9,'20190112','Ne namjenski',7000,15,1)

			select * from Krediti
/*4.
. Kreirati stored proceduru koja će na osnovu proslijeđenih parametara služiti za unos podataka u tabelu
Otplate. Proceduru pohraniti pod nazivom usp_Otplate_Insert. Obavezno testirati ispravnost kreirane
procedure (unijeti minimalno 5 zapisa sa proizvoljnim podacima).
*/
create procedure usp_Otplate_Insert
(
@KreditID INT,
@Datum date,
@Iznos decimal(8,2),
@Rata int
)
as
begin
insert into Otplate (KreditID,Datum,Iznos,Rata)
values (@KreditID,@Datum,@Iznos,@Rata)
end

exec usp_Otplate_Insert 1,'20170912',500,1
exec usp_Otplate_Insert 1,'20171012',500,2
exec usp_Otplate_Insert 1,'20171112',500,3
exec usp_Otplate_Insert 2,'20181112',450,1
exec usp_Otplate_Insert 2,'20181214',450,2
exec usp_Otplate_Insert 2,'20190110',450,3
exec usp_Otplate_Insert 3,'20190215',300,1

select * from Otplate







/*5.
Kreirati view (pogled) nad podacima koji će prikazivati sljedeća polja: jmbg, ime i prezime, adresa, telefon i
email klijenta, zatim datum, namjenu i iznos kredita, te ukupan broj otplaćenih rata i ukupan otplaćeni iznos.
View pohranite pod nazivom view_Krediti_Otplate
*/
CREATE VIEW view_Klijenti_Otplate
as
select K.JMBG,K.Ime+' '+K.Prezime AS [Ime i prezime],
		K.Adresa,K.Telefon,K.Email,
		KR.Datum,KR.Namjena,KR.Iznos,
		COUNT(O.KreditID) AS [Broj otplacenih rata],
		SUM(O.Iznos) AS [Ukupan otplacen iznos]
from Klijenti as K INNER JOIN Krediti AS KR
	 ON K.KlijentID = KR.KlijentID INNER JOIN Otplate AS O
	 ON KR.KreditID = O.KreditID
GROUP BY K.JMBG,K.Ime,K.Prezime,K.Adresa,K.Telefon,K.Email,KR.Datum,KR.Namjena,KR.Iznos

SELECT * FROM view_Klijenti_Otplate

/*6.
Kreirati stored proceduru koja će na osnovu proslijeđenog parametra @JMBG prikazivati podatke o otplati
kredita. Kao izvor podataka koristiti prethodno kreirani view. Proceduru pohraniti pod nazivom
usp_Krediti_Otplate_SelectByJMBG. Obavezno testirati ispravnost kreirane procedure
*/
CREATE PROCEDURE usp_Krediti_Otplate_SelectByJMBG
(
@JMBG NVARCHAR(13)
)
AS
BEGIN
SELECT *
FROM view_Klijenti_Otplate
WHERE JMBG = @JMBG
END

EXEC usp_Krediti_Otplate_SelectByJMBG '1E7E0B0FDD67A'

/*7.
. Kreirati proceduru koja će služiti za izmjenu podataka o otplati kredita. Proceduru pohraniti pod nazivom
usp_Otplate_Update. Obavezno testirati ispravnost kreirane procedure
*/
CREATE PROCEDURE usp_Otplate_Update
(
@OtplataID INT,
@KreditID INT,
@Datum date,
@Iznos decimal(8,2),
@Rata int,
@Opis text
)
as
begin
update Otplate
set KreditID = @KreditID,
	Datum = @Datum,
	Iznos = @Iznos,
	Rata = @Rata,
	Opis = @Opis
WHERE OtplataID = @OtplataID and KreditID = @KreditID
end

select * from Otplate

exec usp_Otplate_Update 1,1,'20170914',550,1,'Doslo do promjene'

/*8.
Kreirati stored proceduru koja će služiti za brisanje kredita zajedno sa svim otplatama. Proceduru pohranite
pod nazivom usp_Krediti_Delete. Obavezno testirati ispravnost kreirane procedure.
*/

create procedure usp_Krediti_Delete
(
@KreditID INT
)
AS
BEGIN
DELETE FROM Otplate
where KreditID in (
					select KreditID
					from Krediti
					where KreditID = @KreditID
					)
delete from Krediti
where KreditID = @KreditID
END

exec usp_Krediti_Delete 2


/*9.
Kreirati trigger koji će spriječiti brisanje zapisa u tabeli Otplate. Trigger pohranite pod nazivom
tr_Otplate_IO_Delete. Obavezno testirati ispravnost kreiranog triggera
*/
create trigger tr_Otplate_IO_Delete
on Otplate instead of delete
as
print 'Nije dozvoljeno brisati podatke'
rollback

delete  from Otplate
where KreditID = 3

/*Uraditi full backup Vaše baze podataka na lokaciju D:\DBMS\Backup*/

backup database ispit04072015 to
disk ='ispit04072015.bak'