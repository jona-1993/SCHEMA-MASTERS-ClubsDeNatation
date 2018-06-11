-- Masters 2018


CREATE TABLE Juges
(
    Juge	NUMBER(2)
    CONSTRAINT capitajoCpJuges PRIMARY KEY,
    Nom		VARCHAR2(20),
    Prenom 	VARCHAR2(20),
    Club 	CHAR(5)
    CONSTRAINT capitajoRefJugesClubs REFERENCES Clubs (Club)
);

