set serveroutput on;

-- Trigger 1

create or replace trigger capitajoNageursCategorie
before insert or update of anneenaiss
on Nageurs
for each row
declare
    anneeinvalidException Exception;
    age integer;
begin
    age:= to_number(extract(year from current_date)) - :new.anneenaiss;
    if age not between  6 and 100
        then raise anneeinvalidException;
    end if;
    select categorie into :new.categorie 
    from categories 
    where age >= coalesce(agemin, 1) 
      and age <= coalesce(agemax, 100);
    exception 
        when anneeinvalidException then raise_application_error(-20000, 'L''annee de naissance est incorrect');
        when OTHERS then raise;
end capitajoNageursCategorie;

-- TESTS

select * from nageurs
where nom = 'SKOWRON';

update nageurs set anneenaiss = 1990
where nom = 'SKOWRON';

rollback;

-- Trigger 2

-- Incompatible avec le script de lancement

create or replace trigger capitajoNageursInsertUpdDel
before insert or delete or update of anneenaiss, club on nageurs
for each row
declare
    notnull exception;
    nligue Nageurs.nrligue%type;
begin
case 
    when inserting then
            select substr(:new.anneenaiss,3,2) || '/' || lpad (coalesce(substr (max(nrligue),4,6),'0') + 1,6,0) || '/' || substr (:new.club,1,4) into :new.nrligue 
            from nageurs where nageurs.nom = :new.nom and nageurs.prenom = :new.prenom and nageurs.anneenaiss = :new.anneenaiss; -- Il s'agit du numéro de ligue par nageur et non de tous
    when updating then -- Vérifier si l'année naissance à changé dans ce cas, on le fait
        if :old.anneenaiss != :new.anneenaiss then
            select substr(:new.anneenaiss,3,2) || '/' || substr (:old.nrligue,4,6) || '/' || substr (:new.club,1,4) into :new.nrligue from dual;
        end if;
    when deleting then
        /*if :new.club is null then -- ou pas.. à tester
            raise notnull;
        end if;*/
        delete from resultats where nrligue = :old.nrligue;
        update clubs set responsable = null where responsable = :old.nrligue;
end case;
exception
    when notnull then raise_application_error(-20000, 'Le club ne peut être null');
    when OTHERS then raise;
end capitajoNageursInsertUpdDel;

-- TESTS

Insert into NAGEURS (NRLIGUE,NOM,PRENOM,ANNEENAISS,SEXE,CATEGORIE,CLUB,ADRESSE,CODEPOSTAL,LOCALITE,NRTELEPHONE,EMAIL,GSM,COTISATION) values (null,'Capitano','Jonathan','1990','M',null,'LDV',null,null,null,null,null,null,null);

select * from nageurs where nom = 'Capitano';

delete from nageurs where nom = 'Capitano';

commit;

update nageurs set anneenaiss = '1993' where nom = 'Capitano';


-- Trigger 3


-- Solution qui fonctionne < Mais moins de contôle >

create or replace trigger capitajoClubsNbreNageurs
after insert or delete or update of club
on Nageurs
for each row
begin
    case
        when inserting then 
        if :new.club is not null then -- Si il appartient à un club uniquement
            update clubs set NBRENAGEURS = coalesce(NBRENAGEURS, 0) + 1 where clubs.club = :new.club;
        end if;
        when updating then
        if :new.club is not null then -- Si non, il n'appartient plus à un club
          update clubs set NBRENAGEURS = coalesce(NBRENAGEURS, 0) - 1 where clubs.club = :old.club; 
          update clubs set NBRENAGEURS = coalesce(NBRENAGEURS, 0) + 1 where clubs.club = :new.club;
        else
            update clubs set NBRENAGEURS = coalesce(NBRENAGEURS, 0) - 1 where clubs.club = :old.club;
        end if;
        when deleting then
            update clubs set NBRENAGEURS = coalesce(NBRENAGEURS, 0) - 1 where clubs.club = :old.club;
    end case;
end capitajoClubsNbreNageurs;


-- TESTS

-- insert

select * from clubs where club = 'LDV';

Insert into NAGEURS (NRLIGUE,NOM,PRENOM,ANNEENAISS,SEXE,CATEGORIE,CLUB,ADRESSE,CODEPOSTAL,LOCALITE,NRTELEPHONE,EMAIL,GSM,COTISATION) values (null,'Capitano','Jonathan','1990','M',null,'LDV',null,null,null,null,null,null,null);

select * from nageurs where nom = 'Capitano';

select * from clubs where club = 'LDV';


-- update

select * from clubs where club = 'USG';

update nageurs set club = 'USG' where nom = 'Capitano';

-- delete

delete from nageurs where nom = 'Capitano';

select * from clubs where club = 'LDV';

select * from clubs where club = 'USG';


-- Trigger 4 (On laisse tomber)

-- Ne marche pas très bien..


create or replace trigger capitajoClubsResponsable
before insert or update of anneenaiss, nom on Nageurs -- After et vérifier avec le nrligue
for each row
declare
    anneenaissance nageurs.anneenaiss%type;
    nomresp clubs.responsable%type;
begin -- vérifier si club null
    select anneenaiss, nageurs.nom into anneenaissance, nomresp from nageurs, clubs where clubs.responsable = nageurs.nrligue and :new.club = clubs.club;
    --select anneenaiss, nageurs.nom into anneenaissance, nomresp from (select anneenaiss, nageurs.nom from nageurs, clubs where clubs.responsable = nageurs.nrligue and :new.club = clubs.club) where rownum = 1;

    if((to_number(to_char(current_date, 'YYYY')) - to_number(:new.anneenaiss)) >= (to_number(to_char(current_date, 'YYYY')) - to_number(anneenaissance))) then
        if((to_number(to_char(current_date, 'YYYY')) - to_number(:new.anneenaiss)) = (to_number(to_char(current_date, 'YYYY')) - to_number(anneenaissance))) then
            if(:new.nom > nomresp) then
                update clubs set responsable = :new.nrligue;
            end if;
        else
            update clubs set responsable = :new.nrligue;
        end if;
    end if;
exception
    when no_data_found then update clubs set responsable = :new.nrligue;
end capitajoClubsResponsable;



-- UNSTABLE BRANCH

create or replace trigger capitajoClubsResponsable
after insert or update of anneenaiss, nom on Nageurs -- After et vérifier avec le nrligue
for each row
declare
    anneenaissance nageurs.anneenaiss%type;
    nomresp clubs.responsable%type;
begin -- vérifier si club null
    --select anneenaiss, nageurs.nom into anneenaissance, nomresp from nageurs, clubs where clubs.responsable = nageurs.nrligue and :new.club = clubs.club;
    --select anneenaiss, nageurs.nom into anneenaissance, nomresp from (select anneenaiss, nageurs.nom from nageurs, clubs where clubs.responsable = nageurs.nrligue and :new.club = clubs.club) where rownum = 1;
    

    if((to_number(to_char(current_date, 'YYYY')) - to_number(:new.anneenaiss)) >= (to_number(to_char(current_date, 'YYYY')) - to_number(anneenaissance))) then
        if((to_number(to_char(current_date, 'YYYY')) - to_number(:new.anneenaiss)) = (to_number(to_char(current_date, 'YYYY')) - to_number(anneenaissance))) then
            if(:new.nom > nomresp) then
                update clubs set responsable = :new.nrligue;
            end if;
        else
            update clubs set responsable = :new.nrligue;
        end if;
    end if;
exception
    when no_data_found then update clubs set responsable = :new.nrligue;
end capitajoClubsResponsable;

-- END UNSTABLE
 -- On laisse tomber ..
create or replace trigger capitajoClubsResponsable
after insert or update of anneenaiss, nom on Nageurs -- After et vérifier avec le nrligue
for each row
declare
    ageresponsable integer;
    agenageur integer;
begin -- vérifier si club null
agenageur := to_number(extract year from current_date)) - :new.anneenaiss;
select coalesce(to_number(extract(extract year from current_date)) - to_number(substr(responsable, 1, 2) + 1990), 0) into ageresponsable from clubs where clubs.club = :new.club;
if inserting then
    if(agenageur >= ageresponsable) then
        if(agenageur = ageresponsable) then
            if(:new.nom > nomresp) then
                update clubs set responsable = :new.nrligue;
            end if;
        else
            update clubs set responsable = :new.nrligue;
        end if;
    end if;
exception
    when no_data_found then update clubs set responsable = :new.nrligue;
end capitajoClubsResponsable;

-- TESTS


select * from clubs where club = 'LDV';

Insert into NAGEURS (NRLIGUE,NOM,PRENOM,ANNEENAISS,SEXE,CATEGORIE,CLUB,ADRESSE,CODEPOSTAL,LOCALITE,NRTELEPHONE,EMAIL,GSM,COTISATION) values ('007','Capitano','Jonathan','1500','M',null,'LDV',null,null,null,null,null,null,null);

select * from nageurs where nom = 'Capitano';

select * from clubs where club = 'LDV';

delete from nageurs where nom = 'Capitano';

select nageurs.nom, anneenaiss from nageurs, clubs where clubs.responsable = nageurs.nrligue and 'LDV' = clubs.club;


