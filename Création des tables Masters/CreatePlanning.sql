
CREATE TABLE Planning
(
	Competition NUMBER(2),
	Annee NUMBER(4),
	Jour NUMBER(1),
	Course NUMBER(2), 
	Libelle VARCHAR2(100),
	Distance NUMBER(4),
	Pause CHAR(1),
	CONSTRAINT capitajoPKPlanning PRIMARY KEY (Competition,Annee,Jour,Course),
	CONSTRAINT capitajoRefPlanningJournees FOREIGN KEY (Competition,Annee,Jour) REFERENCES Journees (Competition,Annee,Jour)
);
 
