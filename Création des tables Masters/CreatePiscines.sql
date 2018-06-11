-- Masters 2018


CREATE TABLE Piscines
(
    Piscine		NUMBER(2) 
    CONSTRAINT capitajoCpPiscines PRIMARY KEY,
    Nom			VARCHAR2(50),
    Adresse		VARCHAR2(50),
    CodePostal	CHAR(5)
    CONSTRAINT capitajoRefPiscinesCodePostaux 
    REFERENCES CodePostaux (CodePostal),
    Lieu		VARCHAR2(20),
    Longueur		NUMBER(2),
    NbCouloirs	NUMBER(2)
);

