-- Masters 2018


CREATE TABLE Secretariats
(
    Secretaire	NUMBER(2)
    CONSTRAINT capitajoCPSecretariats PRIMARY KEY,
    Nom			VARCHAR2(20),
    Prenom		VARCHAR2(20),
    Adresse		VARCHAR2(50),
    CodePostal	CHAR(5)
    CONSTRAINT capitajoRefSecretariatsCodePostaux
    REFERENCES CodePostaux (CodePostal),
    Localite		VARCHAR2(20),
    NrTelephone	CHAR(15),
    NrFax		CHAR(15),
    EMAIL		VARCHAR2(50)
 );

