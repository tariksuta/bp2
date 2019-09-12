/*1.
Kroz SQL kod, napraviti bazu podataka koja nosi ime va�eg broja dosijea. U postupku kreiranja u obzir uzeti
samo DEFAULT postavke.
Unutar svoje baze podataka kreirati tabele sa sljede�om strukturom:
a) Klijenti
i. KlijentID, automatski generator vrijednosti i primarni klju�
ii. Ime, polje za unos 30 UNICODE karaktera (obavezan unos)
iii. Prezime, polje za unos 30 UNICODE karaktera (obavezan unos)
iv. Telefon, polje za unos 20 UNICODE karaktera (obavezan unos)
v. Mail, polje za unos 50 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
vi. BrojRacuna, polje za unos 15 UNICODE karaktera (obavezan unos)
vii. KorisnickoIme, polje za unos 20 UNICODE karaktera (obavezan unos)
viii. Lozinka, polje za unos 20 UNICODE karaktera (obavezan unos)
b) Transakcije
i. TransakcijaID, automatski generator vrijednosti i primarni klju�
ii. Datum, polje za unos datuma i vremena (obavezan unos)
iii. TipTransakcije, polje za unos 30 UNICODE karaktera (obavezan unos)
iv. PosiljalacID, referenca na tabelu Klijenti (obavezan unos)
v. PrimalacID, referenca na tabelu Klijenti (obavezan unos)
vi. Svrha, polje za unos 50 UNICODE karaktera (obavezan unos)
vii. Iznos, polje za unos decimalnog broja (obavezan unos)
*/
create database ispit05092016

use ispit05092016

create table Klijenti
(
 KlijentID int constraint PK_Klijenti primary key identity(1,1),
Ime nvarchar(30) not null,
 Prezime nvarchar(30) not null,
 Telefon nvarchar(20) not null,
 Mail nvarchar(50) constraint uq_email unique not null,
 BrojRacuna nvarchar(15) not null,
 KorisnickoIme nvarchar(20) not null,
 Lozinka nvarchar(20) not null
)

create table Transakcije
(
TransakcijaID int constraint PK_Tranakcije primary key identity(1,1),
Datum datetime not null,
 TipTransakcije nvarchar(30) not null,
 PosiljalacID int constraint FK_Transakcije_Posiljalac foreign key(PosiljalacID) references Klijenti(KlijentID) not null,
 PrimalacID int constraint FK_Transakcije_Primalac foreign key(PrimalacID) references Klijenti(KlijentID) not null,
 Svrha nvarchar(50) not null,
 Iznos decimal(8,2) not null
)

/*2.
Popunjavanje tabela podacima:
a) Koriste�i bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati 10 kupaca
u tabelu Klijenti. Ime, prezime, telefon, mail i broj ra�una (AccountNumber) preuzeti od kupca,
korisni�ko ime generisati na osnovu imena i prezimena u formatu ime.prezime, a lozinku generisati na
osnovu polja PasswordHash, i to uzeti samo zadnjih 8 karaktera.
b) Putem jedne INSERT komande u tabelu Transakcije dodati minimalno 10 transakcija
*/
insert into Klijenti
select TOP 10 P.FirstName,P.LastName,PP.PhoneNumber,EA.EmailAddress,C.AccountNumber,
		LOWER(P.FirstName+'.'+P.LastName),RIGHT(PW.PasswordHash,8)
from AdventureWorks2014.Sales.Customer AS C INNER JOIN AdventureWorks2014.Person.Person AS P
	 ON C.PersonID = P.BusinessEntityID INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA
	 ON P.BusinessEntityID = EA.BusinessEntityID INNER JOIN AdventureWorks2014.Person.Password AS PW
	 ON P.BusinessEntityID = PW.BusinessEntityID INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP
	 ON P.BusinessEntityID = PP.BusinessEntityID
	 SELECT * FROM Klijenti
--B
INSERT INTO Transakcije
VALUES ('20181213','TIP1',2,5,'dug',350),
		 ('20180113','TIP1',4,9,'dug',150),
		  ('20171013','TIP2',9,6,'kazna',50),
		   ('20170223','TIP2',1,3,'kazna',100),
		   ('20170223','TIP1',2,9,'dug',100),
		   ('20190222','TIP2',7,8,'kazna',100),
		   ('20190529','TIP1',5,10,'dug',500),
		   ('20170723','TIP2',7,1,'kazna',100),
		   ('20180723','TIP1',10,6,'duf',250),
		   ('20180223','TIP2',2,3,'kazna',100)

	select * from Transakcije



/*3.
Kreiranje indeksa u bazi podataka nada tabelama:
a) Non-clustered indeks nad tabelom Klijenti. Potrebno je indeksirati Ime i Prezime. Tako�er, potrebno je
uklju�iti kolonu BrojRacuna.
b) Napisati proizvoljni upit nad tabelom Klijenti koji u potpunosti iskori�tava indeks iz prethodnog koraka.
Upit obavezno mora imati filter.
c) Uraditi disable indeksa iz koraka a)
*/
create nonclustered index IX_Klijenti_Ime_Prezime
ON Klijenti(Ime,Prezime)
include(BrojRacuna)

select Ime,Prezime,BrojRacuna
from Klijenti
where BrojRacuna like '%[^123]'

alter index IX_Klijenti_Ime_Prezime on Klijenti
disable


/*4.
. Kreirati uskladi�tenu proceduru koja �e vr�iti upis novih klijenata. Kao parametre proslijediti sva polja. Provjeriti
ispravnost kreirane procedure
*/
create procedure proc_Klijenti_insert
(
@Ime nvarchar(30),
@Prezime nvarchar(30),
@Telefon nvarchar(20),
@Mail nvarchar(50),
@BrojRacuna nvarchar(15),
@KorisnickoIme nvarchar(20),
@Lozinka nvarchar(20)
)
as
begin
insert into Klijenti
values (@Ime,@Prezime,@Telefon,@Mail,@BrojRacuna,@KorisnickoIme,@Lozinka)
end

exec proc_Klijenti_insert 'test','test','000-000-000','test.test@mail','111111111111111','test.test','loz123'

select * from Klijenti

/*5.
 Kreirati view sa sljede�om definicijom. Objekat treba da prikazuje datum transakcije, tip transakcije, ime i
prezime po�iljaoca (spojeno), broj ra�una po�iljaoca, ime i prezime primaoca (spojeno), broj ra�una primaoca,
svrhu i iznos transakcije
*/
create view view_Klijenti_Transakcije
as
select T.Datum,T.TipTransakcije,K.Ime+' '+K.Prezime AS [Ime i prezime posiljaoca],
		K.BrojRacuna AS [Broj racuna posiljaoca],
		(select KL.Ime+' '+KL.Prezime from Klijenti AS KL WHERE KL.KlijentID = T.PrimalacID) AS [Ime i prezime primaoca],
		(select  KL.BrojRacuna  from Klijenti AS KL WHERE KL.KlijentID = T.PrimalacID)  AS [Broj racuna primaoca],
		T.Svrha,T.Iznos
from  Klijenti AS K INNER JOIN Transakcije AS T
	  ON K.KlijentID = T.PosiljalacID

	  SELECT * FROM view_Klijenti_Transakcije


/*6.
. Kreirati uskladi�tenu proceduru koja �e na osnovu unesenog broja ra�una po�iljaoca prikazivati sve transakcije
koje su provedene sa ra�una klijenta. U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane
procedure
*/
CREATE PROCEDURE proc_view_Klijenti_Transakcije_SelectByBrojRacuna
(
@BrojRacuna nvarchar(15)
)
as
begin
select *
from view_Klijenti_Transakcije
where [Broj racuna posiljaoca] = @BrojRacuna
end

exec proc_view_Klijenti_Transakcije_SelectByBrojRacuna 'AW00011008'

/*7.
Kreirati upit koji prikazuje sumaran iznos svih transakcija po godinama, sortirano po godinama. U rezultatu upita
prikazati samo dvije kolone: kalendarska godina i ukupan iznos transakcija u godini
*/
select DATEPART(YEAR,Datum) as Godina,SUM(Iznos) as Ukupno
from Transakcije
group by DATEPART(YEAR,Datum) 
ORDER BY Godina

/*8.
 Kreirati uskladi�tenu proceduru koje �e vr�iti brisanje klijenta uklju�uju�i sve njegove transakcije, bilo da je za
transakciju vezan kao po�iljalac ili kao primalac. Provjeriti ispravnost kreirane procedure.
*/
CREATE PROCEDURE proc_Klijenti_delete
(
@KlijentID INT
)
AS
BEGIN
DELETE FROM Transakcije
where PosiljalacID in (
						SELECT KlijentID
						FROM Klijenti
						WHERE KlijentID = @KlijentID
						) OR  PrimalacID in (
											SELECT KlijentID
						                    FROM Klijenti
						                    WHERE KlijentID = @KlijentID
											)
delete from Klijenti
where KlijentID = @KlijentID
END

select * from Transakcije

exec proc_Klijenti_delete 5


/*9.
 Kreirati uskladi�tenu proceduru koja �e na osnovu unesenog broja ra�una ili prezimena po�iljaoca vr�iti pretragu
nad prethodno kreiranim view-om (zadatak 5). Testirati ispravnost procedure u sljede�im situacijama:
a) Nije postavljena vrijednost niti jednom parametru (vra�a sve zapise)
b) Postavljena je vrijednost parametra broj ra�una,
c) Postavljena je vrijednost parametra prezime,
d) Postavljene su vrijednosti oba parametra.
*/

create procedure proc_view_Klijenti_Transakcije_2
(
@BrojRacuna nvarchar(15) = null,
@Prezime nvarchar(30) = null
)
as
begin
select *
from view_Klijenti_Transakcije
where ([Broj racuna posiljaoca] = @BrojRacuna OR @BrojRacuna IS NULL)
		AND ([Ime i prezime posiljaoca] LIKE '%' + @Prezime OR @Prezime IS NULL)
end

EXEC proc_view_Klijenti_Transakcije_2
EXEC proc_view_Klijenti_Transakcije_2 'AW00011001'
EXEC proc_view_Klijenti_Transakcije_2 @Prezime = 'Huang'
EXEC proc_view_Klijenti_Transakcije_2

/*10. Napraviti full i diferencijalni backup baze podataka na default lokaciju servera*/
backup database ispit05092016 to
disk = 'ispit05092016.bak'

backup database ispit05092016 to
disk = 'ispit05092016_dif.bak'