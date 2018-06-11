

-- Procédure Lister

-- Requête

select juges.juge as idjuge, juges.nom as nomjuge, prenom as prenomjuge, clubs.nom as nomclub
from(select b.juge
    from (select a.juge, count(a.juge) as countjuges 
        from (select juges.juge from juges, journees where juges.juge = journees.juge and annee = '2001') a 
        group by a.juge) b
    order by countjuges desc) c, juges, clubs
where c.juge = juges.juge
and juges.club = clubs.club;

-- Procédure
-- Essayer avec curseur pour tester si pas de résultat
create or replace procedure capitajoLister (annee_journee number) as
begin
-- Regarder si annee_journee est nulle ou pas
    for row in
    (select juges.juge as idjuge, juges.nom as nomjuge, prenom as prenomjuge, clubs.nom as nomclub
    from(select b.juge
        from (select a.juge, count(a.juge) as countjuges 
            from (select juges.juge from juges, journees where juges.juge = journees.juge and annee = annee_journee) a 
            group by a.juge) b
        order by countjuges desc) c, juges, clubs
    where c.juge = juges.juge
    and juges.club = clubs.club) loop
        dbms_output.put_line(row.idjuge || ' ' || row.nomjuge || ' ' || row.prenomjuge || ' ' || row.nomclub);
    end loop;
exception
    when others then raise;
end capitajoLister;

-- Test

set serveroutput on;

exec capitajoLister (2001);


-- Fonction MeilleurTemps

-- requête

select nageurs.nrligue, nageurs.nom, nageurs.prenom, tempsreel 
from resultats, nageurs
where 
    resultats.nrligue = nageurs.nrligue
    and tempsreel =
        (select min(tempsreel) as tempsrecord
        from planning, resultats
        where planning.competition = resultats.competition
            and libelle like '%Libre%'
            and distance = 100
            and tempsreel is not null);

-- Fonction

create or replace function capitajoMeilleurTemps(var_libelle planning.libelle%type, var_distance planning.distance%type)
return nageurs.nrligue%type is 
var_record nageurs.nrligue%type;
libelle_null exception;
distance_null exception;
invalid_libelle exception;
invalid_distance exception;
begin
    if var_libelle is null then
        raise libelle_null;
    end if;
    if var_distance is null then
        raise distance_null;
    end if;
    if not (upper(var_libelle) like '%DOS%' or  upper(var_libelle) like '%BRASSE%' or upper(var_libelle) like '%PAPILLON%' or upper(var_libelle) like '%LIBRE%') then
        raise invalid_libelle;
    end if;
    if var_distance not in (50, 100, 200, 400, 800, 1500) then
        raise invalid_distance;
    end if;
    select nageurs.nrligue into var_record
    from resultats, nageurs
    where 
        resultats.nrligue = nageurs.nrligue
        and tempsreel =
            (select min(tempsreel) as tempsrecord
            from planning, resultats
            where planning.competition = resultats.competition
                and libelle like '%' || var_libelle ||'%'
                and distance = var_distance
                and tempsreel is not null);
    return var_record;
exception
    when no_data_found then raise_application_error(-20005, 'Pas de tuples ..');
    when too_many_rows then raise_application_error(-20000, 'Trop de tuples ..'); -- Vérifier d'avoir des numéros différents partout
    when libelle_null then raise_application_error(-20001, 'Le libelle ne peut pas être null ..');
    when distance_null then raise_application_error(-20002, 'La distance ne peut pas être nulle ..');
    when invalid_libelle then raise_application_error(-20003, 'Le libelle n''est pas correct .. valeurs possibles dos, brasse, papillon et libre. Valeur actuelle: ' || var_libelle);
    when invalid_distance then raise_application_error(-20004, 'La distance n''est pas correcte .. valeurs possibles: 50, 100, 200, 400, 800, 1500. Valeur actuelle:' || var_distance);
    when others then raise;
end capitajoMeilleurTemps;


-- Test

set serveroutput on;
declare 
    temp nageurs.nrligue%type;
    distance planning.distance%type;
    libelle planning.libelle%type;
begin
    distance := 100;
    libelle := 'Libre';
    temp:= capitajoMeilleurTemps(libelle, distance);
    dbms_output.put_line('Nrligue du meilleur nageur dans la course ' || libelle || ', sur la distance ' || distance || ' : ' || temp);

exception

    when others then dbms_output.put_line(sqlerrm);
end;
