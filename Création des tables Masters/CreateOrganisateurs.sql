-- Masters 2018


CREATE TABLE Organisateurs
(
    Competition		NUMBER(2)
    CONSTRAINT capitajoRefOrganisateursCompetitions 
    REFERENCES Competitions (Competition),
    Annee			NUMBER(4),
    NbreJours		NUMBER(2)
    CONSTRAINT capitajoCheckOrganisateursNbJ 
    CHECK (NbreJours IS NOT NULL),          
    Secretariat		NUMBER(2) 
    CONSTRAINT capitajoRefOrganisateursSecretariats 
    REFERENCES Secretariats (Secretaire),
    DroitInscriptionIndividuel	NUMBER(4,2),
    DroitInscriptionRelais		NUMBER(4,2),
    ForfaitParCourse	NUMBER(4,2),

    CONSTRAINT capitajoCpOrganisateurs 
    PRIMARY KEY (Competition,Annee)
);
 
 
