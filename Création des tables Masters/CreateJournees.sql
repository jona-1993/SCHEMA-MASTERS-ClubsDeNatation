
CREATE TABLE Journees
(
	Competition NUMBER(2),
	Annee NUMBER(4), 
	Jour NUMBER(1), -- jour de la compétition: jour 1..2..3.. ... 9
	DateHeureCompetition TIMESTAMP,--DATE,
	HeureEchauffement TIMESTAMP,--DATE, 
	Piscine NUMBER(2) CONSTRAINT capitajoRefJourneesPiscines REFERENCES Piscines (Piscine) not null, 
	Juge NUMBER (2) CONSTRAINT capitajoRefJourneesJuges REFERENCES Juges (Juge),
	DateLimiteInscription DATE,	
	CONSTRAINT capitajoPKJournees PRIMARY KEY (Competition,Annee,Jour),
	CONSTRAINT capitajoRefJourneesCompetitions FOREIGN KEY (Competition,Annee) REFERENCES Organisateurs (Competition,Annee),
	CONSTRAINT capitajoDateEgales check (trunc(DateHeureCompetition) = trunc(HeureEchauffement)),
	CONSTRAINT capitajoDateInferieur check (trunc(DateLimiteInscription) - trunc(DateHeureCompetition) <= 8),
	CONSTRAINT capitajoChauffeDemiHeure check (HeureEchauffement + Interval '30' Minute <= Dateheurecompetition)
 );
