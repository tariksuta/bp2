/*1. Kreirati bazu podataka pod nazivom: BrojDosijea (npr. 2046) bez posebnog kreiranja data i log fajla*/
create database ispit10062014

use ispit10062014

/*2.
 U Vašoj bazi podataka kreirati tabele sa sljedećim parametrima:
 Studenti
 StudentID, automatski generator vrijednosti i primarni ključ
 BrojDosijea, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
 Ime, polje za unos 35 UNICODE karaktera (obavezan unos)
 Prezime, polje za unos 35 UNICODE karaktera (obavezan unos)
 Godina studija, polje za unos cijelog broja (obavezan unos)
 NacinStudiranja, polje za unos 10 UNICODE karaktera (obavezan unos) DEFAULT je Redovan
 Email, polje za unos 50 karaktera (nije obavezan)
 Nastava
 NastavaID, automatski generator vrijednosti i primarni ključ
 Datum, polje za unos datuma i vremana (obavezan unos)
 Predmet, polje za unos 20 UNICODE karaktera (obavezan unos)
 Nastavnik, polje za unos 50 UNICODE karaktera (obavezan unos)
 Ucionica, polje za unos 20 UNICODE karaktera (obavezan unos)
 Prisustvo
 PrisustvoID, automatski generator vrijednosti i primarni ključ
 StudentID, spoljni ključ prema tabeli Studenti
 NastavaID, spoljni ključ prema tabeli Nastava
*/

create table Studenti
(
 StudentID int constraint PK_Studenti primary key identity(1,1),
 BrojDosijea nvarchar(10) constraint uq_brojdosijea unique not null,
 Ime nvarchar(35) not null,
 Prezime nvarchar(35) not null,
 GodinaStudija int not null,
 NacinStudiranja nvarchar(10) default('Redovan') not null,
 Email nvarchar(50)
)

create table Nastava
(
 NastavaID int constraint PK_Nastava primary key identity(1,1),
 Datum datetime not null,
 Predmet nvarchar(20) not null,
 Nastavnik nvarchar(50) not null,
 Ucionica nvarchar(20) not null
)

create table Prisustvo
(
 PrisustvoID int constraint PK_Prisustvo primary key identity(1,1),
 StudentID int constraint FK_Prisustvo_Studenti foreign key(StudentID) REFERENCES Studenti(StudentID),
 NastavaID int constraint FK_Prisustvo_Nastava foreign key(NastavaID) REFERENCES Nastava(NastavaID),
)

/*3.
Kreirati tabelu Predmeti sa sljedećim parametrima:
 PredmetID, automatski generator vrijednosti i primarni ključ
 Naziv, polje za unos 30 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
Modifikovati tabelu Nastava (ukloniti kolonu Predmet) i povezati je sa tabelom Predmeti. Koristeći INSERT
komandu u tabelu Predmeti unijeti tri zapisa
*/
CREATE TABLE Predmeti
(
PredmetID INT CONSTRAINT PK_Predmeti primary key identity(1,1),
Naziv nvarchar(30) constraint uq_naziv unique not null
)

alter table Nastava
DROP column Predmet

ALTER TABLE Nastava
ADD PredmetID INT CONSTRAINT FK_Nastava_Predmeti foreign key(PredmetID) REFERENCES Predmeti(PredmetID)

insert into Predmeti
values ('Web razvoj i dizajn'),
		('Analiza i dizajn softvera'),
		('Baze podataka II')

		SELECT * FROM Predmeti

/*4.
Koristeći bazu podataka AdventureWorksLT2012 i tabelu SalesLT.Customer, preko INSERT i SELECT komande
importovati 10 zapisa u tabelu Studenti i to sljedeće kolone:
 Prva tri karaktera kolone Phone -> BrojDosijea
 FirstName -> Ime
 LastName -> Prezime
 2 -> GodinaStudija
 DEFAULT -> NacinStudiranja
 EmailAddress -> Email
*/
INSERT INTO Studenti(BrojDosijea,Ime,Prezime,GodinaStudija,Email)
SELECT TOP 10 LEFT(C.Phone,3),C.FirstName,C.LastName,2,
		C.EmailAddress
FROM AdventureWorksLT2014.SalesLT.Customer as C

SELECT * FROM Studenti

/*5.
U Vašoj bazi podataka kreirajte stored proceduru koja će na osnovu proslijeđenih parametara raditi izmjenu
(UPDATE) podataka u tabeli Studenti. Proceduru pohranite pod nazivom usp_Studenti_Update. Koristeći
prethodno kreiranu proceduru izmijenite jedan zapis sa Vašim podacima.
*/
CREATE PROCEDURE usp_Studenti_Update
(
@StudentID INT,
@BrojDosijea nvarchar(10),
@Ime nvarchar(35),
@Prezime nvarchar(35),
@GodinaStudija int,
@NacinStudiranja nvarchar(10),
@Email nvarchar(50)
)
as
begin
update Studenti
set BrojDosijea = @BrojDosijea,
	Ime = @Ime,
	Prezime = @Prezime,
	GodinaStudija = @GodinaStudija,
	NacinStudiranja = @NacinStudiranja,
	Email = @Email
WHERE StudentID = @StudentID
end

exec usp_Studenti_Update 6,'IB170048','Tarik','Suta',2,'DL','tarik.suta@edu.fit.ba'

select * from Studenti

/*6.
U Vašoj bazi podataka kreirajte stored proceduru koja će raditi INSERT podataka u tabelu Nastava. Podaci se
moraju unijeti preko parametara. Također, u istoj proceduri dodati prisustvo na nastavi (koristeći INSERT
SELECT komandu dodati prisustvo sve studente za prethodno dodanu nastavu). Proceduru pohranite pod
nazivom usp_Nastava_Insert
*/
create procedure usp_Nastava_Insert
(
@Datum datetime,
@Nastavnik nvarchar(50),
@Ucionica nvarchar(20),
@PredmetID INT
)
AS
BEGIN
INSERT INTO Nastava
values (@Datum,@Nastavnik,@Ucionica,@PredmetID)

insert into Prisustvo
SELECT StudentID,(select NastavaID from Nastava WHERE Datum = @Datum and PredmetID = @PredmetID)
FROM Studenti
END

exec usp_Nastava_Insert '20190412','Elmir Babovic','AMF2',1

/*7.
Koristeći proceduru koju ste kreirali u prethodnom zadatku dodati novu nastavu. Za parametar @Datum
proslijediti trenutni datum i vrijeme, a ostale parametre upisati ručno
*/
DECLARE @datum datetime = SYSDATETIME()
EXEC usp_Nastava_Insert @datum,'Emina Junuz','AKS',2

SELECT * FROM Prisustvo

SELECT * FROM Nastava


/*8.
U Vašoj bazi podataka kreirajte stored proceduru koja ća na osnovu proslijeđenih parametara (@NastavaID i
@StudentID) brisati prisustvo na nastavi. Proceduru pohranite pod nazivom usp_Prisustvo_Delete
*/
create procedure usp_Prisustvo_Delete
(
@NastavaID INT,
@StudentID INT
)
AS
BEGIN
DELETE FROM Prisustvo
where NastavaID = @NastavaID and StudentID = @StudentID
END

select * from Prisustvo

EXEC usp_Prisustvo_Delete 1,10
/*9.
U Vašoj bazi podataka kreirajte view koji će sadržavati sljedeća polja: broj dosijea, ime i prezime studenta,
datum nastave, učionicu, nastavnika i predmet. View pohranite pod nazivom view_Studenti_Nastava.
*/

CREATE VIEW view_Studenti_Nastava
AS
SELECT S.BrojDosijea,S.Ime+' '+S.Prezime AS [Ime i prezime],
		N.Datum,N.Ucionica,N.Nastavnik,PR.Naziv
FROM Studenti AS S INNER JOIN Prisustvo AS P
	 ON S.StudentID =P.StudentID INNER JOIN Nastava AS N
	 ON P.NastavaID = N.NastavaID INNER JOIN Predmeti AS PR
	 ON N.PredmetID = PR.PredmetID

	SELECT * FROM view_Studenti_Nastava

	/*Backup bez navodenja putanje na default lokaciju*/

	backup database ispit10062014 to
	disk = 'ispit10062014.bak'