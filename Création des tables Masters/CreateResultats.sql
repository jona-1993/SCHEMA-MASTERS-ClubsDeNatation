
CREATE TABLE Resultats
( 
	NrLigue CHAR(14) CONSTRAINT capitajoRefResultatsNageurs REFERENCES Nageurs (NrLigue),
	Competition NUMBER(2),
	Annee NUMBER(4),
	Jour NUMBER(1),
	Course NUMBER(2),
	TempsReference INTERVAL DAY TO SECOND,
	TempsReel  INTERVAL DAY TO SECOND,
	Place NUMBER(2),
	Points NUMBER(4),
	Decision CHAR(2) CONSTRAINT capitajoRefResultatsDecisions REFERENCES Decisions (Decision),
	Categorie CHAR(2) CONSTRAINT capitajoRefResultatsCategories  REFERENCES Categories(Categorie),
	Club CHAR(5) CONSTRAINT capitajoRefResultatsClubs  REFERENCES Clubs(Club),
	CONSTRAINT capitajoPKResultats PRIMARY KEY (NrLigue,Competition,Annee,Jour,Course),
	CONSTRAINT capitajoRefResultatsCourses FOREIGN KEY (Competition,Annee,Jour,Course) REFERENCES Planning (Competition,Annee,Jour,Course)
); 

