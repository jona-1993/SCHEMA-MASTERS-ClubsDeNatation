
update clubs set responsable = (
select nrligue
from nageurs n1
where
   clubs.club = n1.club
    and nom = (select max(nom)
                from nageurs n2
                where n1.club = n2.club
                and anneenaiss = (select min(anneenaiss)
                                    from nageurs n3
                                    where n2.club = n3.club
                                    group by club)
                group by club)
    and anneenaiss = (select min(anneenaiss)
                    from nageurs n4
                    where n1.club = n4.club
                    group by club));

