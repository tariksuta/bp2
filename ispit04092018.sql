/*
1.	Kroz SQL kod,naparaviti bazu podataka koja nosi ime vaseg broja dosijea sa default postavkama
*/
create database ispit04092018

use ispit04092018

/*
2.	Unutar svoje baze kreirati tabele sa sljedecom strukutrom
Autori
•	AutorID 11 UNICODE karaltera i primarni kljuc
•	Prezime 25 UNICODE karaktera (obavezan unos)
•	Ime 25 UNICODE karaktera (obavezan unos)
•	Telefon 20 UNICODE karaktera DEFAULT je NULL
•	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
•	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
Izdavaci 
•	IzdavacID 4 UNICODE karaktera i primarni kljuc
•	Naziv 100 UNICODE karaktera(obavezan unos),jedinstvena vrijednost
•	Biljeske 1000 UNICODE karaktera DEFAULT tekst je Lorem ipsum
•	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
•	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
Naslovi
•	NaslovID 6 UNICODE karaktera i primarni kljuc
•	IzdavacID ,spoljni kljuc prema tabeli Izdavaci
•	Naslov 100 UNICODE karaktera (obavezan unos)
•	Cijena monetarni tip
•	DatumIzdavanja datumska vraijabla (obavezan unos) DEFAULT datum unosa zapisa
•	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
•	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
NasloviAutori
•	AutorID ,spoljni kljuc prema tabeli Autori
•	NaslovID ,spoljni kljuc prema tabeli Naslovi
•	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
•	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL

*/

create table Autori
(
AutorID nvarchar(11) constraint PK_Autori primary key,
Prezime nvarchar(25) not null,
Ime nvarchar(25) not null,
Telefon nvarchar(20) default(null),
DatumKreiranjaZapisa date default(getdate()) not null,
DatumModifikovanjaZapisa date default(null)
)

create table Izdavaci
(
IzdavacID nvarchar(4) constraint PK_Izdavaci primary key,
Naziv nvarchar(100) constraint uq_naziv unique not null,
Biljeske nvarchar(100) default('Lorem ipsum'),
DatumKreiranjaZapisa date default(getdate()) not null,
DatumModifikovanjaZapisa date default(null)
)

create table Naslovi
(
NaslovID nvarchar(6) constraint PK_Naslovi primary key,
IzdavacID nvarchar(4) constraint FK_Naslovi_Izdavaci foreign key(IzdavacID) REFERENCES Izdavaci(IzdavacID),
Naslov NVARCHAR(100) NOT NULL,
Cijena MONEY,
DatumIzdavanja DATE DEFAULT(GETDATE()) NOT NULL,
DatumKreiranjaZapisa date default(getdate()) not null,
DatumModifikovanjaZapisa date default(null)
)

CREATE TABLE NasloviAutori
(
AutorID nvarchar(11) constraint FK_NasloviAutori_Autori foreign key(AutorID) REFERENCES Autori(AutorID),
NaslovID NVARCHAR(6) CONSTRAINT FK_NasloviAutori_Naslovi foreign key(NaslovID) REFERENCES Naslovi(NaslovID),
constraint PK_NasloviAutori primary key(AutorID,NaslovID),
DatumKreiranjaZapisa date default(getdate()) not null,
DatumModifikovanjaZapisa date default(null)
)

/*
2b. Generisati testne podatke i obavezno testirati da li su podaci u tabeli za svaki korak posebno:
•	Iz baze podataka pubs tabela authors,  putem podupita u tabelu Autori importovati sve slucajno sortirane zapise.
Vodite racuna da mapirate odgovarajuce kolone.

•	Iz baze podataka pubs i tabela publishers i pub_info , a putem podupita u tabelu Izdavaci importovati
sve slucajno sortirane zapise.Kolonu pr_info mapirati kao biljeske i iste skratiti na 100 karaktera.
Vodte racuna da mapirate odgovarajuce kolone

•	Iz baze podataka pubs tabela titles ,a putem podupita u tablu Naslovi importovati sve zapise.
Vodite racuna da mapirate odgvarajuce kolone

•	Iz baze podataka pubs tabela titleauthor, a putem podupita u tabelu NasloviAutori importovati zapise.
Vodite racuna da mapirate odgovrajuce koloone

*/
INSERT INTO Autori(AutorID,Prezime,Ime,Telefon)
select a.au_id,a.au_lname,a.au_fname,a.phone
from (
		select au_id,au_lname,au_fname,phone
		from pubs.dbo.authors
		) as a
order by newid()

select * from Autori

insert into Izdavaci(IzdavacID,Naziv,Biljeske)
select b.pub_id,b.pub_name,b.Biljeske
from (
		select P.pub_id,P.pub_name,CAST(PIN.pr_info AS nvarchar(100)) AS Biljeske
		from pubs.dbo.publishers as P INNER JOIN pubs.dbo.pub_info as PIN
			 ON P.pub_id = PIN.pub_id
		) as b
order by NEWID()
select * from Izdavaci

insert into Naslovi(NaslovID,IzdavacID,Naslov,Cijena)
select c.title_id,c.pub_id,c.title,c.price
from (
		select title_id,pub_id,title,price
		from pubs.dbo.titles
		) as c

select * from Naslovi

insert into NasloviAutori(AutorID,NaslovID)
select d.au_id,d.title_id
from (
		select au_id,title_id
		from pubs.dbo.titleauthor
		) as d

select * from NasloviAutori
/*
2c. Kreiranje nove tabele,importovanje podataka i modifikovanje postojece tabele:
     Gradovi
•	GradID ,automatski generator vrijednosti cija je pocetna vrijednost je 5 i uvrcava se za 5,primarni kljuc
•	Naziv 100 UNICODE karaktera (obavezan unos),jedinstvena vrijednost
•	DatumKreiranjaZapisa datumska varijabla (obavezan unos) DEFAULT je datum unosa zapisa
•	DatumModifikovanjaZapisa datumska varijabla,DEFAULT je NULL
•	Iz baze podataka pubs tebela authors a putem podupita u tablelu Gradovi imprtovati nazive gradova bez duplikata
•	Modifikovati tabelu Autori i dodati spoljni kljuc prema tabeli Gradovi

*/
create table Gradovi
(
GradID int constraint PK_Gradovi primary key identity(5,5),
Naziv nvarchar(100) constraint uq_grad unique not null,
DatumKreiranjaZapisa date default(getdate()) not null,
DatumModifikovanjaZapisa date default(null)
)

insert into Gradovi(Naziv)
select g.city
from (
	 select distinct city
	 from pubs.dbo.authors
	 ) as g

alter table Autori
ADD  GradID INT CONSTRAINT FK_Autori_Gradovi foreign key(GradID) REFERENCES Gradovi(GradID)

/*
2d. Kreirati dvije uskladistene procedure koja ce modifikovati podatke u tabelu Autori
•	Prvih deset autora iz tabele postaviti da su iz grada : San Francisco
•	Ostalim autorima podesiti grad na : Berkeley

*/
create procedure proc_Autori_grad_sf
as
begin
UPDATE Autori
set GradID = (
			 SELECT GradID
			 FROM Gradovi
			 where Naziv = 'San Francisco'
			 )
WHERE AutorID in (
					SELECT top 10 AutorID
					FROM Autori
					)
end

exec proc_Autori_grad_sf

create procedure proc_Autori_grad_b
as
begin
UPDATE Autori
set GradID = (
			 SELECT GradID
			 FROM Gradovi
			 where Naziv = 'Berkeley'
			 )
WHERE GradID IS NULL
end

EXEC proc_Autori_grad_b

select * from Autori

/*
3.	Kreirati pogled sa seljdeceom definicijom: Prezime i ime autora (spojeno),grad,naslov,cijena,izdavac i
biljeske ali samo one autore cije knjige imaju odredjenu cijenu i gdje je cijena veca od 10.
Takodjer naziv izdavaca u sredini imena treba ima ti slovo & i da su iz grada San Francisco.Obavezno testirati funkcijonalnost
*/
create view view_Autori_Naslovi
as
select A.Prezime+' '+A.Ime AS [Prezime i ime],
		G.Naziv AS Grad,N.Naslov,N.Cijena,
		I.Naziv AS Izdavac,I.Biljeske
from Autori AS A INNER JOIN NasloviAutori AS NA
	 ON A.AutorID = NA.AutorID INNER JOIN Naslovi AS N
	 ON NA.NaslovID = N.NaslovID INNER JOIN Izdavaci AS I
	 ON N.IzdavacID = I.IzdavacID INNER JOIN Gradovi AS G
	 ON A.GradID = G.GradID
WHERE N.Cijena IS NOT NULL AND N.Cijena > 10  
		AND I.Naziv LIKE '%&%' AND G.Naziv = 'San Francisco'

		select * from view_Autori_Naslovi

/*
4.	Modifikovati tabelu autori i dodati jednu kolonu:

•	Email,polje za unos 100 UNICODE kakraktera ,DEFAULT je NULL

*/
ALTER TABLE Autori
ADD Email nvarchar(100) default(null)

/*
5.	Kreirati dvije uskladistene procedure koje ce modifikovati podatke u tabeli Autori i svim autorima generisati novu email adresu:
•	Prva procedura u formatu Ime.Prezime@fit.ba svim autorima iz grada San Francisco
•	Druga procedura u formatu Prezime.ime@fit.ba svim autorima iz grada Berkeley

*/
alter procedure proc_Autori_Email_sf
as
begin
update Autori
set Email = Ime+'.'+Prezime+'@fit.ba',DatumModifikovanjaZapisa = GETDATE()
where GradID IN (
				SELECT GradID
				FROM Gradovi
				where Naziv = 'San Francisco'
				)
end

exec proc_Autori_Email_sf

alter procedure proc_Autori_Email_b
as
begin
update Autori
set Email = Prezime+'.'+Ime+'@fit.ba',DatumModifikovanjaZapisa = GETDATE()
where GradID IN (
				SELECT GradID
				FROM Gradovi
				where Naziv = 'Berkeley'
				)
end

exec proc_Autori_Email_b

select * from Autori

/*
6.	Iz baze podataka AdventureWorks2014 u lokalnu,privremenu,tabelu u vasu bazu podataka imoportovati zapise o osobama ,
a putem podupita. Lista kolona je Title,LastName,FirstName,
EmailAddress,PhoneNumber,CardNumber.
Kreirati dvije dodatne kolone UserName koja se sastoji od spojenog imena i prezimena(tacka izmedju) i
kolona Password za lozinku sa malim slovima dugacku 16 karaktera.Lozinka se generise putem SQL funkcije za
slucajne i jednistvene ID vrijednosti.Iz lozinke trebaju biti uklonjene sve crtice '-' i zamjenjene brojem '7'.
Uslovi su da podaci ukljucuju osobe koje imaju i nemaju kreditanu karticu, a 
NULL vrijesnot u koloni Titula treba zamjenuti sa 'N/A'.Sortirati prema prezimenu i imenu.
Testirati da li je tabela sa podacima kreirana

*/
select p.Titula,p.FirstName,p.LastName,p.EmailAddress,p.PhoneNumber,p.CardNumber,p.UserName,p.Lozinka
into #Privremena
from (
		SELECT ISNULL(P.Title,'N/A') AS Titula,P.FirstName,P.LastName,EA.EmailAddress,PP.PhoneNumber,CC.CardNumber,
				LOWER(P.FirstName+'.'+P.LastName) AS UserName,
				LOWER(REPLACE(LEFT(NEWID(),16),'-','7')) AS Lozinka
		FROM AdventureWorks2014.Person.Person AS P INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA
	 ON P.BusinessEntityID = EA.BusinessEntityID INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP
	 ON P.BusinessEntityID = PP.BusinessEntityID LEFT JOIN AdventureWorks2014.Sales.PersonCreditCard AS PCC
	 ON P.BusinessEntityID = PCC.BusinessEntityID LEFT JOIN AdventureWorks2014.Sales.CreditCard AS CC
	 ON PCC.CreditCardID = CC.CreditCardID
		) as p
order by p.LastName,p.FirstName

select * from #Privremena

/*
7.	Kreirati indeks koji ce nad privremenom tabelom iz prethodnog koraka,primarno,maksimalno 
ubrzati upite koje koriste kolonu UserName,a sekundarno nad kolonama LastName i FirstName.Napisati testni upit
*/
create nonclustered index IX_Privremena_UserName
ON #Privremena (UserName)
include(LastName,FirstName)

select LastName,FirstName
from #Privremena
where UserName like '%s'

/*
8.	Kreirati uskladistenu proceduru koja brise sve zapise iz privremen tabele koje nemaju kreditnu karticu.
Obavezno testirati funkcjionalnost
*/
create procedure proc_Privremena_delete_null
as
begin
delete from #Privremena
where CardNumber is null
end

exec proc_Privremena_delete_null

select * from #Privremena

/*
9.	Kreirati backup vase baze na default lokaciju servera i nakon toga obrisati privremenu tabelu
*/
backup database ispit04092018 to
disk = 'ispit04092018.bak'

drop table #Privremena
/*
10.	Kreirati proceduru koja brise sve zapise i svih tabela unutar jednog izvrsenja.Testirati da li su podaci obrisani
*/

create procedure proc_svizapisi_delete
as
begin
ALTER TABLE NasloviAutori
DROP CONSTRAINT FK_NasloviAutori_Autori
ALTER TABLE NasloviAutori
DROP CONSTRAINT FK_NasloviAutori_Naslovi
ALTER TABLE Autori
DROP CONSTRAINT FK_Autori_Gradovi
alter table Naslovi
drop constraint FK_Naslovi_Izdavaci
DELETE FROM NasloviAutori
DELETE FROM Autori
DELETE FROM Gradovi
DELETE FROM Naslovi
DELETE FROM Izdavaci
end

EXEC proc_svizapisi_delete