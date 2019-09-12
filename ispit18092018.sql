/*1.Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea sa default postavkama*/
create database ispit18092018
use ispit18092018

/*2.
Unutar svoje baze podataka kreirati tabele sa sljedećem strukturom:
Autori
• AutorID, 11 UNICODE karaktera i primarni ključ
• Prezime, 25 UNICODE karaktera (obavezan unos)
• Ime, 25 UNICODE karaktera (obavezan unos)
• ZipKod, 5 UNICODE karaktera, DEFAULT je NULL
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
Izdavaci
• IzdavacID, 4 UNICODE karaktera i primarni ključ
• Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
• Biljeske, 1000 UNICODE karaktera, DEFAULT tekst je Lorem ipsum
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
Naslovi
• NaslovID, 6 UNICODE karaktera i primarni ključ
• IzdavacID, spoljni ključ prema tabeli „Izdavaci“
• Naslov, 100 UNICODE karaktera (obavezan unos)
• Cijena, monetarni tip podatka
• Biljeske, 200 UNICODE karaktera, DEFAULT tekst je The quick brown fox jumps over the lazy dog
• DatumIzdavanja, datum izdanja naslova (obavezan unos) DEFAULT je datum unosa zapisa
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
NasloviAutori (Više autora može raditi na istoj knjizi)
• AutorID, spoljni ključ prema tabeli „Autori“
• NaslovID, spoljni ključ prema tabeli „Naslovi“
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
*/
create table Autori
(
 AutorID nvarchar(11) constraint pk_Autori primary key,
Prezime nvarchar(25) not null,
 Ime nvarchar(25) not null,
ZipKod nvarchar(5) default (null),
 DatumKreiranjaZapisa date default  (getdate()) not null,
 DatumModifikovanjaZapisa date default(null)
)

create table Izdavaci
(
IzdavacID nvarchar(4) constraint pk_Izdavaci primary key,
 Naziv nvarchar(100) constraint uq_naziv unique nonclustered not null,
 Biljeske nvarchar(1000) default('Lorem ipsum'),
 DatumKreiranjaZapisa date default  (getdate()) not null,
 DatumModifikovanjaZapisa date default(null)
)

create table Naslovi
(
NaslovID nvarchar(6) constraint pk_Naslovi primary key,
 IzdavacID nvarchar(4) constraint fk_Naslovi_Izdavaci foreign key(IzdavacID) REFERENCES Izdavaci(IzdavacID),
 Naslov nvarchar(100) not null,
 Cijena money,
 Biljeske nvarchar(200) default ('The quick brown fox jumps over the lazy dog'),
 DatumIzdavanja date default(getdate()) not null,
  DatumKreiranjaZapisa date default  (getdate()) not null,
 DatumModifikovanjaZapisa date default(null)
)
create table NasloviAutori
(
 AutorID nvarchar(11) constraint fk_NaslovAutori_Autori foreign key(AutorID) references Autori(AutorID),
 NaslovID nvarchar(6) constraint fk_NaslovAutori_Naslovi foreign key(NaslovID) references Naslovi(NaslovID),
 DatumKreiranjaZapisa date default  (getdate()) not null,
 DatumModifikovanjaZapisa date default(null)
 )


/*2b
Generisati testne podatake i obavezno testirati da li su podaci u tabelema za svaki korak zasebno :
• Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Autori“ importovati sve slučajno sortirane
zapise. Vodite računa da mapirate odgovarajuće kolone.

• Iz baze podataka pubs i tabela („publishers“ i pub_info“), a putem podupita u tabelu „Izdavaci“ importovati sve
slučajno sortirane zapise. Kolonu pr_info mapirati kao bilješke i iste skratiti na 100 karaktera. Vodite računa da
mapirate odgovarajuće kolone i tipove podataka.

• Iz baze podataka pubs tabela „titles“, a putem podupita u tabelu „Naslovi“ importovati one naslove koji imaju
bilješke. Vodite računa da mapirate odgovarajuće kolone.

• Iz baze podataka pubs tabela „titleauthor“, a putem podupita u tabelu „NasloviAutori“ zapise. Vodite računa da
mapirate odgovarajuće kolone.
*/
insert into Autori(AutorID,Prezime,Ime,ZipKod)
select a.au_id,a.au_lname,a.au_fname,a.zip
from (
		select a.au_id,a.au_lname,a.au_fname,a.zip
		from pubs.dbo.authors as a
		) as a
order by NEWID()
select * from Autori

insert into Izdavaci(IzdavacID,Naziv,Biljeske)
select b.pub_id,b.pub_name,b.Biljeske
from (
		select P.pub_id,P.pub_name,CAST(PIN.pr_info AS NVARCHAR(100)) AS Biljeske
		from pubs.dbo.publishers as P INNER JOIN pubs.dbo.pub_info as PIN
			 ON P.pub_id = PIN.pub_id
		) as b
order by newid()
select * from Izdavaci


insert into Naslovi(NaslovID,IzdavacID,Naslov,Cijena,Biljeske)
select t.title_id,t.pub_id,t.title,t.price,t.notes
from (
		select t.title_id,t.pub_id,t.title,t.price,t.notes
		from pubs.dbo.titles as t
		where t.notes is not null
		) as t

		select * from Naslovi

insert into NasloviAutori(AutorID,NaslovID)
select ta.au_id,ta.title_id
from (
		select ta.au_id,ta.title_id
		from pubs.dbo.titleauthor as ta
		) as ta

		select * from NasloviAutori

/*2c
Kreiranje nove tabele, importovanje podataka i modifikovanje postojeće tabele:
Gradovi
• GradID, automatski generator vrijednosti koji generiše neparne brojeve, primarni ključ
• Naziv, 100 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
• DatumKreiranjaZapisa, datuma dodavanja zapisa (obavezan unos) DEFAULT je datum unosa zapisa
• DatumModifikovanjaZapisa, polje za unos datuma izmjene zapisa , DEFAULT je NULL
✓ Iz baze podataka pubs tabela „authors“, a putem podupita u tabelu „Gradovi“ importovati nazive gradove bez
duplikata.
✓ Modifikovati tabelu Autori i dodati spoljni ključ prema tabeli Gradovi:
*/
create table Gradovi
(
GradID int constraint pk_Gradovi primary key identity(1,2),
Naziv nvarchar(100) constraint uq_grad unique nonclustered not null,
DatumKreiranjaZapisa date default  (getdate()) not null,
 DatumModifikovanjaZapisa date default(null)
)

insert into Gradovi(Naziv)
select g.city
from (
		select distinct city
		from pubs.dbo.authors
		) as g

alter table Autori
add GradID INT CONSTRAINT FK_Autori_Gradovi foreign key(GradID) references Gradovi(GradID)



/*2d
Kreirati dvije uskladištene proceduru koja će modifikovati podataka u tabeli Autori:
• Prvih pet autora iz tabele postaviti da su iz grada: Salt Lake City
• Ostalim autorima podesiti grad na: Oakland

Vodite računa da se u tabeli modifikuju sve potrebne kolone i obavezno testirati da li su podaci u tabeli za svaku proceduru
posebno.
*/
create procedure proc_Autori_mod_slc
as
begin
UPDATE Autori
set GradID = (
			SELECT GradID
			FROM Gradovi
			WHERE Naziv = 'Salt Lake City'
			),DatumModifikovanjaZapisa = GETDATE()
where AutorID in (
				 select top 5 AutorID
				 from Autori
				 )
end

exec proc_Autori_mod_slc

select * from Autori

create procedure proc_Autori_mod_oak
as
begin
UPDATE Autori
set GradID = (
			SELECT GradID
			FROM Gradovi
			WHERE Naziv = 'Oakland'
			),DatumModifikovanjaZapisa = GETDATE()
where GradID IS NULL
end

EXEC proc_Autori_mod_oak

select * from Autori


/*3.
Kreirati pogled sa sljedećom definicijom: Prezime i ime autora (spojeno), grad, naslov, cijena, bilješke o naslovu i naziv
izdavača, ali samo za one autore čije knjige imaju određenu cijenu i gdje je cijena veća od 5. Također, naziv izdavača u sredini
imena ne smije imati slovo „&“ i da su iz autori grada Salt Lake City 
*/

CREATE VIEW view_Autori_Naslovi
as
select A.Prezime+' '+A.Ime AS [Ime i prezime],
		G.Naziv AS Grad,N.Naslov,N.Cijena,N.Biljeske,I.Naziv AS Izdavac
from Autori as A INNER JOIN NasloviAutori AS NA
	 ON A.AutorID = NA.AutorID INNER JOIN Naslovi AS N
	 ON NA.NaslovID = N.NaslovID INNER JOIN Izdavaci AS I
	 ON N.IzdavacID = I.IzdavacID INNER JOIN Gradovi AS G
	 ON A.GradID = G.GradID
where N.Cijena IS NOT NULL AND N.Cijena > 5 AND I.Naziv NOT LIKE '%&%' AND G.Naziv = 'Salt Lake City'

SELECT * FROM  view_Autori_Naslovi


/*4.
Modifikovati tabelu Autori i dodati jednu kolonu:
• Email, polje za unos 100 UNICODE karaktera, DEFAULT je NULL
*/
ALTER TABLE Autori
ADD Email nvarchar(100) default(null)

/*5.
Kreirati dvije uskladištene proceduru koje će modifikovati podatke u tabelu Autori i svim autorima generisati novu email
adresu:
• Prva procedura: u formatu: Ime.Prezime@fit.ba svim autorima iz grada Salt Lake City
• Druga procedura: u formatu: Prezime.Ime@fit.ba svim autorima iz grada Oakland
*/
create procedure proc_Autori_Email_slc
as
begin
update Autori
set Email = Ime+'.'+Prezime+'@fit.ba',DatumModifikovanjaZapisa = GETDATE()
WHERE GradID IN (
				SELECT GradID
				FROM Gradovi
				WHERE Naziv = 'Salt Lake City'
				)
end

exec proc_Autori_Email_slc

select * from Autori

create procedure proc_Autori_Email_oak
as
begin
update Autori
set Email = Prezime+'.'+Ime+'@fit.ba',DatumModifikovanjaZapisa = GETDATE()
WHERE GradID IN (
				SELECT GradID
				FROM Gradovi
				WHERE Naziv = 'Oakland'
				)
end

exec proc_Autori_Email_oak

select * from Autori

/*6.
z baze podataka AdventureWorks2014 u lokalnu, privremenu, tabelu u vašu bazi podataka importovati zapise o osobama, a
putem podupita. Lista kolona je: Title, LastName, FirstName, EmailAddress, PhoneNumber i CardNumber. Kreirate
dvije dodatne kolone: UserName koja se sastoji od spojenog imena i prezimena (tačka se nalazi između) i kolonu Password
za lozinku sa malim slovima dugačku 24 karaktera. Lozinka se generiše putem SQL funkciju za slučajne i jedinstvene ID
vrijednosti. Iz lozinke trebaju biti uklonjene sve crtice „-“ i zamijenjene brojem „7“. Uslovi su da podaci uključuju osobe koje
imaju i nemaju kreditnu karticu, a NULL vrijednost u koloni Titula zamjeniti sa podatkom 'N/A'. Sortirati prema prezimenu i
imenu istovremeno. Testirati da li je tabela sa podacima kreirana.
*/

select T.Titula,T.LastName,T.FirstName,T.EmailAddress,T.PhoneNumber,T.CardNumber,T.UserName,T.Lozinka
INTO #Privremena
from (
		SELECT ISNULL(P.Title,'N/A') AS Titula,P.LastName,P.FirstName,EA.EmailAddress,PP.PhoneNumber,CC.CardNumber,
				LOWER(P.FirstName+'.'+P.LastName) AS UserName,
				lower(replace(left(NEWID(),24),'-','7')) as Lozinka
		FROM AdventureWorks2014.Person.Person AS P INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA
			 ON P.BusinessEntityID = EA.BusinessEntityID INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP
			 ON P.BusinessEntityID = PP.BusinessEntityID LEFT JOIN AdventureWorks2014.Sales.PersonCreditCard AS PCC
			 ON P.BusinessEntityID = PCC.BusinessEntityID LEFT JOIN AdventureWorks2014.Sales.CreditCard AS CC
			 ON PCC.CreditCardID = CC.CreditCardID
		) AS T
ORDER BY T.LastName,T.FirstName

SELECT * FROM #Privremena

/*7.
Kreirati indeks koji će nad privremenom tabelom iz prethodnog koraka, primarno, maksimalno ubrzati upite koje koriste
kolone LastName i FirstName, a sekundarno nad kolonam UserName. Napisati testni upit.
*/

CREATE NONCLUSTERED INDEX IX_Privremena_LastName_FirstName
on #Privremena (LastName,FirstName)
INCLUDE(UserName)

select LastName,FirstName
from #Privremena
where UserName like '%d'
/*8.
Kreirati uskladištenu proceduru koja briše sve zapise iz privremene tabele koji imaju kreditnu karticu Obavezno testirati
funkcionalnost procedure.
*/

create procedure proc_Privremena_delete_notnull
as
begin
delete from #Privremena
where CardNumber is not null
end

exec proc_Privremena_delete_notnull

select * from #Privremena


/*9. Kreirati backup vaše baze na default lokaciju servera i nakon toga obrisati privremenu tabelu*/
backup database ispit18092018 to
disk = 'ispit18092018.bak'

drop table #Privremena

/*10a Kreirati proceduru koja briše sve zapise iz svih tabela unutar jednog izvršenja. Testirati da li su podaci obrisani*/

create procedure proc_Delete_zapise
as
begin
ALTER TABLE NasloviAutori
DROP CONSTRAINT fk_NaslovAutori_Naslovi
ALTER TABLE NasloviAutori
DROP CONSTRAINT fk_NaslovAutori_Autori
ALTER TABLE Autori
DROP CONSTRAINT FK_Autori_Gradovi
ALTER TABLE Naslovi
drop constraint fk_Naslovi_Izdavaci
DELETE FROM NasloviAutori
delete from Autori
delete from Gradovi
delete from Naslovi
delete from Izdavaci
end

exec proc_Delete_zapise

/*10b Uraditi restore rezervene kopije baze podataka i provjeriti da li su svi podaci u izvornom obliku*/