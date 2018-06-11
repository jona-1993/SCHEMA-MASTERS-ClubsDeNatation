-- LMD 1

select nom, prenom
from nageurs
where (to_number(to_char(current_date, 'YYYY')) - anneenaiss) <= 35
and nrligue in (
select nrligue
from resultats
where annee = 2003
and jour = 1
and competition = 2
and tempsreference is not null
minus 
select nrligue
from resultats 
where tempsreference is null
and jour = 1
and competition = 2);


-- LMD 2

select nom, prenom
from nageurs
where (to_number(to_char(current_date, 'YYYY')) - anneenaiss) <= 35
and nrligue in (
select nrligue
from resultats
where annee = 2003
and jour = 2
and competition = 2
and tempsreference is null
minus 
select nrligue
from resultats 
where tempsreference is not null
and jour = 1
and competition = 2);

-- LMD 3

select nom, prenom
from nageurs
where (to_number(to_char(current_date, 'YYYY')) - anneenaiss) <= 35
and nrligue in (
select nrligue
from resultats
where annee = 2003
and jour = 1
and competition = 2
minus 
select nrligue
from resultats 
where jour = 1
and competition = 2);

-- LMD 4

-- Fonctionne Normalement..

select nom, lieu, longueur, nbcouloirs
from piscines
where piscine in (
    select piscines.piscine
    from piscines, (
        select piscine, count(piscine) as compteur
        from journees group by piscine
        order by compteur desc) temp
        where piscines.piscine = temp.piscine
        
        )
and rownum < 2;


-- Fonctionne

select nom, lieu, longueur, nbcouloirs
from piscines
where piscine = (select piscine from (select count(*), piscine
from journees
group by(piscine)
order by 1 desc)
where rownum = 1);


-- LMD 5

SELECT TO_CHAR (DateHeureCompetition, 'DD/MM/YYYY'), Competitions.Libelle
FROM Planning INNER JOIN Competitions USING (Competition)
		   INNER JOIN Journees USING (Competition, annee, jour)
GROUP BY Competition, Competitions.libelle, DateHeureCompetition
HAVING COUNT (Planning.course) >= 10 ;

-- LMD 6

select competitions.libelle, annee, jour, to_char(dateheurecompetition, 'DD/MM/YYYY HH24:MI:SS')
from journees, competitions
where to_char(dateheurecompetition, 'HH24:MI:SS') = (
select max(to_char(dateheurecompetition, 'HH24:MI:SS'))
from journees)
and journees.competition = competitions.competition;

