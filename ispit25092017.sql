/*
1.	Kroz SQL kod napraviti bazu podataka koja nosi ime vašeg broja dosijea, a zatim u svojoj bazi podataka kreirati tabele sa sljedeæom strukturom:
a)	Klijenti
i.	Ime, polje za unos 50 karaktera (obavezan unos)
ii.	Prezime, polje za unos 50 karaktera (obavezan unos)
iii.	Drzava, polje za unos 50 karaktera (obavezan unos)
iv.	Grad, polje za  unos 50 karaktera (obavezan unos)
v.	Email, polje za unos 50 karaktera (obavezan unos)
vi.	Telefon, polje za unos 50 karaktera (obavezan unos)
b)	Izleti
i.	Sifra, polje za unos 10 karaktera (obavezan unos)
ii.	Naziv, polje za unos 100 karaktera (obavezan unos)
iii.	DatumPolaska, polje za unos datuma (obavezan unos)
iv.	DatumPovratka, polje za unos datuma (obavezan unos)
v.	Cijena, polje za unos decimalnog broja (obavezan unos)
vi.	Opis, polje za unos dužeg teksta (nije obavezan unos)
c)	Prijave
i.	Datum, polje za unos datuma i vremena (obavezan unos)
ii.	BrojOdraslih polje za unos cijelog broja (obavezan unos)
iii.	BrojDjece polje za unos cijelog broja (obavezan unos)

Napomena: Na izlet se može prijaviti više klijenata, dok svaki klijent može prijaviti više izleta. 
Prilikom prijave klijent je obavezan unijeti broj odraslih i broj djece koji putuju u sklopu izleta.

*/
create database ispit25092017

use ispit25092017

create table Klijenti
(
KlijentID INT CONSTRAINT PK_Klijenti primary key identity(1,1),
Ime nvarchar(50) not null,
Prezime nvarchar(50) not null,
Drzava nvarchar(50) not null,
Grad nvarchar(50) not null,
Email nvarchar(50) not null,
Telefon nvarchar(50) not null,
)

create table Izleti
(
IzletID INT CONSTRAINT PK_Izleti primary key identity(1,1),
Sifra nvarchar(10) not null,
Naziv nvarchar(100) not null,
DatumPolaska date not null,
DatumPovratka date not null,
Cijena decimal(8,2) not null,
Opis text
)

create table Prijave
(
IzletID INT CONSTRAINT FK_Prijave_Izleti foreign key(IzletID) REFERENCES Izleti(IzletID),
KlijentID INT CONSTRAINT FK_Prijave_Klijenti foreign key(KlijentID) REFERENCES Klijenti(KlijentID),
CONSTRAINT PK_Prijave primary key(IzletID,KlijentID),
Datum datetime not null,
BrojOdraslih int not null,
BrojDjece int not null
)

/*
2.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljedeæe podatke:
a)	U tabelu Klijenti prebaciti sve uposlenike koji su radili u odjelu prodaje (Sales) 
i.	FirstName -> Ime
ii.	LastName -> Prezime
iii.	CountryRegion (Name) -> Drzava
iv.	Addresss (City) -> Grad
v.	EmailAddress (EmailAddress)  -> Email (Izmeðu imena i prezime staviti taèku)
vi.	PersonPhone (PhoneNumber) -> Telefon
b)	U tabelu Izleti dodati 3 izleta (proizvoljno)	
*/

insert into Klijenti
select P.FirstName,P.LastName,CR.Name,A.City,P.FirstName+'.'+P.LastName+SUBSTRING(EA.EmailAddress,CHARINDEX('@',EA.EmailAddress),25),
		PP.PhoneNumber
from AdventureWorks2014.HumanResources.Employee as E INNER JOIN AdventureWorks2014.Person.Person AS P
	 ON E.BusinessEntityID = P.BusinessEntityID INNER JOIN AdventureWorks2014.Person.BusinessEntityAddress AS BEA
	 ON P.BusinessEntityID = BEA.BusinessEntityID INNER JOIN AdventureWorks2014.Person.Address AS A
	 ON BEA.AddressID = A.AddressID INNER JOIN AdventureWorks2014.Person.StateProvince AS SP
	 ON A.StateProvinceID = SP.StateProvinceID INNER JOIN AdventureWorks2014.Person.CountryRegion AS CR
	 ON SP.CountryRegionCode = CR.CountryRegionCode INNER JOIN AdventureWorks2014.Person.EmailAddress AS EA
	 ON P.BusinessEntityID = EA.BusinessEntityID INNER JOIN AdventureWorks2014.Person.PersonPhone AS PP
	 ON P.BusinessEntityID = PP.BusinessEntityID
WHERE E.JobTitle LIKE '%Sales%'

select * from Klijenti

--b
insert into Izleti (Sifra,Naziv,DatumPolaska,DatumPovratka,Cijena)
values ('AB-100-10','Putovanje u Zanzibar','20191010','20191031',2050),
		('AB-100-20','Putovanje u London','20191110','20191022',1200),
		('AB-100-30','Putovanje u Istanbul','20191012','20191020',600)

/*
3.	Kreirati uskladištenu proceduru za unos nove prijave. Proceduri nije potrebno proslijediti parametar Datum.
Datum se uvijek postavlja na trenutni. Koristeæi kreiranu proceduru u tabelu Prijave dodati 10 prijava.
*/
create procedure proc_Prijave_insert
(
@IzletID INT,
@KlijentID INT,
@BrojOdraslih int,
@BrojDjece INT
)
as
begin
insert into Prijave
values (@IzletID,@KlijentID,SYSDATETIME(),@BrojOdraslih,@BrojDjece)
end

select * from Klijenti

EXEC proc_Prijave_insert 1,5,2,2 
EXEC proc_Prijave_insert 1,3,2,2 
EXEC proc_Prijave_insert 1,9,2,3 
EXEC proc_Prijave_insert 2,1,2,3
EXEC proc_Prijave_insert 2,6,2,2
EXEC proc_Prijave_insert 2,7,2,1
EXEC proc_Prijave_insert 2,2,2,3
EXEC proc_Prijave_insert 3,8,2,2
EXEC proc_Prijave_insert 3,2,2,3
EXEC proc_Prijave_insert 3,6,2,2

select * from Prijave





/*
4.	Kreirati index koji æe sprijeèiti dupliciranje polja Email u tabeli Klijenti. Obavezno testirati ispravnost kreiranog indexa.
*/
create unique nonclustered index UQ_Klijenti_Email
ON Klijenti(Email)

select * from Klijenti

insert into Klijenti
values ('test','test','test','test','Brian.Welcker@adventure-works.com','000--000')

/*
5.	Svim izletima koji imaju više od 3 prijave cijenu umanjiti za 10%.
*/
UPDATE Izleti
set Cijena = Cijena-(Cijena*0.10)
WHERE IzletID in (
					select P.IzletID
					from Prijave as P
					GROUP BY P.IzletID
					HAVING COUNT(P.IzletID) > 3
					)
SELECT * FROM Izleti
/*
6.	Kreirati view (pogled) koji prikazuje podatke o izletu: šifra, naziv, datum polaska, datum povratka i cijena, 
te ukupan broj prijava na izletu, 
ukupan broj putnika, ukupan broj odraslih i ukupan broj djece. Obavezno prilagoditi format datuma (dd.mm.yyyy).
*/
CREATE VIEW view_Izleti_Prijave
as
select I.Sifra,I.Naziv,convert(nvarchar,I.DatumPolaska,104) as DatumPolaska,convert(nvarchar,I.DatumPovratka,104) as DatumPovratka,I.Cijena,
		COUNT(P.IzletID) AS [Broj prijava],
		SUM(P.BrojOdraslih+P.BrojDjece) AS BrojPutnika,
		SUM(P.BrojOdraslih) AS [Broj odraslih],
		SUM(P.BrojDjece) AS [Broj djece]
from Izleti as I INNER JOIN Prijave AS P
	 ON I.IzletID = P.IzletID
group by I.Sifra,I.Naziv,I.DatumPolaska,I.DatumPovratka,I.Cijena

SELECT * FROM view_Izleti_Prijave
/*
7.	Kreirati uskladištenu proceduru koja æe na osnovu unesene šifre izleta prikazivati zaradu od izleta i 
to sljedeæe kolone: naziv izleta, zarada od odraslih, zarada od djece, ukupna zarada. 
Popust za djecu se obraèunava 50% na ukupnu cijenu za djecu. Obavezno testirati ispravnost kreirane procedure.
*/
CREATE PROCEDURE proc_prikazi_zaradu
(
@Sifra nvarchar(10)
)
as
begin
select I.Naziv,SUM(P.BrojOdraslih) *I.Cijena AS [Zarada od odraslih],
		SUM(P.BrojDjece)*I.Cijena*0.5 AS [Zarada od djece],
		(SUM(P.BrojOdraslih) *I.Cijena + SUM(P.BrojDjece)*I.Cijena*0.5 ) as Ukupno
from Izleti AS I INNER JOIN Prijave AS P
	 ON I.IzletID = P.IzletID
WHERE I.Sifra = @Sifra
group by I.Naziv,I.Cijena
end

EXEC proc_prikazi_zaradu 'AB-100-20'

/*
8.	a) Kreirati tabelu IzletiHistorijaCijena u koju je potrebno pohraniti identifikator izleta kojem je cijena izmijenjena, 
datum izmjene cijene, staru i novu cijenu. Voditi raèuna o tome da se jednom izletu može više puta mijenjati
cijena te svaku izmjenu treba zapisati u ovu tabelu.

b) Kreirati trigger koji æe pratiti izmjenu cijene u tabeli Izleti te za svaku izmjenu u prethodno
kreiranu tabelu pohraniti podatke izmijeni.

c) Za odreðeni izlet (proizvoljno) ispisati sljdedeæe podatke: naziv izleta, datum polaska, datum povratka, 
trenutnu cijenu te kompletnu historiju izmjene cijena tj. datum izmjene, staru i novu cijenu.

*/
create table IzletiHistorijaCijena
(
IHCID INT CONSTRAINT PK_IzletiHistorijaCijena PRIMARY KEY IDENTITY(1,1),
IzletID INT CONSTRAINT FK_IzletiHistorijaCijena_Izleti foreign key(IzletID) REFERENCES Izleti(IzletID),
DatumIzmjene datetime,
StaraCijena decimal(8,2),
NovaCijena decimal(8,2)
)

create trigger tr_Izleti_promjene
ON Izleti AFTER UPDATE
AS
BEGIN
INSERT INTO IzletiHistorijaCijena
SELECT d.IzletID,sysdatetime(),d.Cijena,I.Cijena
FROM deleted as d inner join Izleti as I
	 ON d.IzletID = I.IzletID
END

UPDATE Izleti
SET Cijena = Cijena+ 22
WHERE IzletID = 2

--c

select I.Naziv,I.DatumPolaska,I.DatumPovratka,I.Cijena,
		IHC.DatumIzmjene,IHC.StaraCijena
from Izleti AS I INNER JOIN IzletiHistorijaCijena AS IHC
	 ON I.IzletID = IHC.IzletID


/*9.	Obrisati sve klijente koji nisu imali niti jednu prijavu na izlet. */
DELETE FROM Klijenti
WHERE KlijentID IN (
						SELECT K.KlijentID
						FROM Klijenti AS K LEFT JOIN Prijave AS P
							 ON K.KlijentID = P.KlijentID
						GROUP BY K.KlijentID
						HAVING COUNT(P.KlijentID) = 0
						
					)


/*10.	Kreirati full i diferencijalni backup baze podataka na lokaciju servera D:\BP2\Backup*/

BACKUP DATABASE ispit25092017 to 
disk = 'C:\BP2\Backup\ispit25092017.bak'

BACKUP DATABASE ispit25092017 to 
disk = 'C:\BP2\Backup\ispit25092017_dif.bak'
with differential