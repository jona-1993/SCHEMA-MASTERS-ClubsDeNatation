-- Préambule

drop table cafet purge;

create table cafet(
    nr number constraint CafetPK primary key,
    nom varchar(20),
    montant number(5, 2)   -- Pour pouvoir mettre 100.75 car 5 digits 
);


insert into cafet values (1, 'Dupont', 25.5);
insert into cafet values (2, 'Durant', 0);
insert into cafet values (3, 'Smets', 10);
insert into cafet values (4, 'Dupuis', 100.75);
insert into cafet values (5, 'Tuche', 65.75);

commit;


-----------------------------
-- Transaction 1 Lecture sale
-----------------------------

-- Session 1

update cafet set nom = 'Baracuda'
where nr = 3;

-- Pour ne pas abimer le contenu initial
rollback;


-- Session 2

select nom
from cafet
where nr = 3;

-- Résultat: Smets


-----------------------------
-- Transaction 2 Perte de maj
-----------------------------
-- VERROU LONG !
-- Session 1

update cafet set montant = montant + 5
where nr = 2;

-- Attente update concurent
commit;

-- Session 2

update cafet set montant = montant + 6
where nr = 2;

-- Attente Commit concurent
commit;

select montant from cafet where nr = 2;

-- Résultat: montant = 11


-------------------------------------------
-- Transaction 3 Lecture non-reproductibles
-------------------------------------------

-- Session 1

--1
select * from cafet where nr = 2;

--3
select * from cafet where nr = 2;

-- 5
select * from cafet where nr = 2;

-- Session 2

--2
update cafet set montant = 9
where nr = 2;

-- 4
commit;


-------------------------
-- Transaction 4 DeadLock
-------------------------


-- Session 1

update cafet set montant = montant + 6
where nr = 2;

-- Attente update concurent

update cafet set montant = montant + 5
where nr = 1;

-- Session 2

update cafet set montant = montant + 5
where nr = 1;

-- Attente update concurent

update cafet set montant = montant + 6
where nr = 2;


-------------------------------------------
-- Transaction 5 Empecher non-reproductible
-------------------------------------------


-- Session 1

set transaction read only;

--1
select * from cafet where nr = 2;

--3
select * from cafet where nr = 2;

-- 5
select * from cafet where nr = 2;

-- Session 2

--2
update cafet set montant = 9
where nr = 2;

-- 4
commit;


----------------
-- Transaction 6
----------------

-- Session 1

--1
 UPDATE Cafet SET Nom ='xxx'
WHERE nr = 2;

--=> Verrou long (Exclusif en écriture)

--3
commit;

--=> Nom = xxx

--=> Déverouille la session 2

-- Session 2

-- 2
UPDATE Cafet SET Nom ='yyy'
    WHERE nr = 2;

--=> Boucle indéfiniment

--4
commit;

--=> Nom = yyy

----------------
-- Transaction 7
----------------

-- Session 1

SELECT * FROM Cafet FOR UPDATE;

--=> Verrou long (Exclusif en écriture)

-- Session 2

SELECT * FROM Cafet FOR UPDATE;

--=> Boucle indéfiniment

----------------
-- Transaction 8
----------------

-- Session 1

SELECT * FROM Cafet
FOR UPDATE NOWAIT;
--=> Verrou Long

-- Session 2

SELECT * FROM Cafet
FOR UPDATE NOWAIT;
--=> 
--ORA-00054: ressource occupée et acquisition avec NOWAIT indiqué ou expiration
--00054. 00000 -  "resource busy and acquire with NOWAIT specified or timeout expired"
--*Cause:    Interested resource is busy.
--*Action:   Retry if necessary or increase timeout.
