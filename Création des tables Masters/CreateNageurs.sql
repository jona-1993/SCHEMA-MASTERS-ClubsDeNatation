
CREATE TABLE Nageurs
(
	NrLigue CHAR(14) CONSTRAINT capitajoPKNageurs PRIMARY KEY,
	Nom VARCHAR2(20) CONSTRAINT capitajoNomNotNull NOT NULL,
	Prenom VARCHAR2(20) CONSTRAINT capitajoPrenomNotNull NOT NULL,
	AnneeNaiss NUMBER(4) CONSTRAINT capitajoNaissanceNotNull NOT NULL,
	Sexe CHAR(1) CONSTRAINT capitajoSexeNotNull NOT NULL CONSTRAINT capitajoSexe CHECK (Sexe in ('F','M')),
	Categorie CHAR(2) CONSTRAINT capitajoRefNageursCat REFERENCES Categories(Categorie),
	Club CHAR(5) CONSTRAINT capitajoRefNageursClubs  REFERENCES Clubs (Club),
	Adresse VARCHAR2(50),
	CodePostal CHAR(5) CONSTRAINT capitajoRefNageursPK REFERENCES CodePostaux (CodePostal),
	Localite VARCHAR2(20),
	NrTelephone CHAR(15),
	EMAIL VARCHAR2(50),
	GSM CHAR(15),
	Cotisation CHAR(1) CONSTRAINT capitajoCotisation CHECK (Cotisation in ('O','N'))
);

