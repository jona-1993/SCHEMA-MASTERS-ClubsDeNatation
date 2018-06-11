CREATE TABLE Clubs
(
	Club CHAR(5) CONSTRAINT capitajoPKclub PRIMARY KEY,
	Nom VARCHAR2(50),
	Secretariat NUMBER(2) CONSTRAINT capitajoRefSecretariat REFERENCES Secretariats(Secretaire),
	Responsable CHAR(14),
	NbreNageurs NUMBER(4)
);
