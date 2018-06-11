-- Header

create or replace package capitajoMasters is
    type record_competition is record (
        
        competition competitions.competition%type,
        nom competitions.libelle%type,
        datecompetition journees.dateheurecompetition%type,
        jour journees.jour%type,
        nbcourses integer
    );

    type t_nageur is table of nageurs%rowtype index by binary_integer;
    type t_competition is table of record_competition index by binary_integer;

    procedure AjouterNageur (un_nageur nageurs%rowtype);
    procedure ModifierNageur (anc_nageur nageurs%rowtype, new_nageur nageurs%rowtype);
    procedure SupprimerNageur (nageurarg nageurs.nrligue%type, annee_journee journees.annee%type);
    procedure AjouterJournee (une_journee journees%rowtype);
    procedure ModifierJournee (anc_journee journees%rowtype, new_journee journees%rowtype);
    function Lister (numcomp journees.competition%type, var_annee journees.annee%type, var_jour journees.jour%type) return t_nageur;
    function Lister (nbcourses integer) return t_competition;
end capitajoMasters;


-- Body

create or replace package body capitajoMasters as

    procedure AjouterNageur (un_nageur nageurs%rowtype) as
    begin

        Insert into NAGEURS (NRLIGUE,NOM,PRENOM,ANNEENAISS,SEXE,CATEGORIE,CLUB,ADRESSE,CODEPOSTAL,LOCALITE,NRTELEPHONE,EMAIL,GSM,COTISATION) 
        values (un_nageur.nrligue,un_nageur.nom,un_nageur.prenom,un_nageur.anneenaiss,un_nageur.sexe,un_nageur.categorie,un_nageur.club,un_nageur.adresse,un_nageur.codepostal,un_nageur.localite,un_nageur.nrtelephone,un_nageur.email,un_nageur.gsm,un_nageur.cotisation);
        dbms_output.put_line('Tuple ajouté !');
    exception
        -- DUP_VAL_ON_INDEX pas nécessaire ici car un trigger gère déjà ça
        when others then
        if sqlerrm like '%CAPITAJOCOTISATION%' then raise_application_error('-20000', 'Cotisation invalide! (O ou N)');
        elsif sqlerrm like '%CAPITAJONAISSANCENOTNULL%' then raise_application_error('-20001', 'L''annee de naissance doit exister!');
        elsif sqlerrm like '%CAPITAJONOMNOTNULL%' then raise_application_error('-20002', 'Le nom doit exister !');
        elsif sqlerrm like '%CAPITAJOPKNAGEURS%' then raise_application_error('-20003', 'La clé primaire de nageurs est incorrecte !');
        elsif sqlerrm like '%CAPITAJOPRENOMNOTNULL%' then raise_application_error('-20004', 'Le prénom doit exister !');
        elsif sqlerrm like '%CAPITAJOREFNAGEURSCAT%' then raise_application_error('-20005', 'La catégorie doit exister dans la table Catégories !'); -- Pas nécessaire
        elsif sqlerrm like '%CAPITAJOREFNAGEURSPK%' then raise_application_error('-20006', 'Le code postal doit exister dans la table codepostaux !');
        elsif sqlerrm like '%CAPITAJOSEXE%' then raise_application_error('-20007', 'Le sexe est invalide! (M ou F)');
        elsif sqlerrm like '%CAPITAJOSEXENOTNULL%' then raise_application_error('-20008', 'Le sexe doit exister !');
        else raise;
        end if;
    end AjouterNageur;


    procedure ModifierNageur (anc_nageur nageurs%rowtype, new_nageur nageurs%rowtype) as
    nageurtemp nageurs%rowtype;
    modifiedexception exception;
    compteur integer;
    exbusy exception;
    pragma exception_init(exbusy, -54);
    cond integer;
    begin
        compteur := 0;
        cond := 0;

        while(cond = 0) loop
            begin
                select * into nageurtemp from nageurs
                where nrligue = anc_nageur.nrligue for update nowait;
                cond :=1;
            exception
                when exbusy then 
                    if compteur < 3 then 
                        compteur := compteur + 1;
                        dbms_lock.sleep(3);
                    else
                        raise;
                    end if;
                when others then raise;
            end;
        end loop;
        
        if anc_nageur.nrligue <> nageurtemp.nrligue or anc_nageur.nom <> nageurtemp.nom
            or anc_nageur.prenom <> nageurtemp.prenom or anc_nageur.anneenaiss <> nageurtemp.anneenaiss
            or anc_nageur.sexe <> nageurtemp.sexe or anc_nageur.categorie <> nageurtemp.categorie
            or anc_nageur.club <> nageurtemp.club or anc_nageur.adresse <> nageurtemp.adresse
            or anc_nageur.codepostal <> nageurtemp.codepostal or anc_nageur.localite <> nageurtemp.localite
            or anc_nageur.nrtelephone <> nageurtemp.nrtelephone or anc_nageur.email <> nageurtemp.email
            or anc_nageur.gsm <> nageurtemp.gsm or anc_nageur.cotisation <> nageurtemp.cotisation 
        then raise modifiedexception; 
        end if;
        update nageurs set 
            nrligue = new_nageur.nrligue,
            nom = new_nageur.nom,
            prenom = new_nageur.prenom,
            anneenaiss = new_nageur.anneenaiss,
            sexe = new_nageur.sexe,
            categorie = new_nageur.categorie,
            club = new_nageur.club,
            adresse = new_nageur.adresse,
            codepostal = new_nageur.codepostal,
            localite = new_nageur.localite,
            nrtelephone = new_nageur.nrtelephone,
            email = new_nageur.email,
            gsm = new_nageur.gsm,
            cotisation = new_nageur.cotisation
        where 
            nrligue = anc_nageur.nrligue;
            commit;
            dbms_output.put_line('Tuple modifié !');
       exception
        -- DUP_VAL_ON_INDEX pas nécessaire ici car un trigger gère déjà ça
        when modifiedexception then raise_application_error('-20010', 'Valeur modifiée en cours de route !');
        when NO_DATA_FOUND then raise_application_error('-20009', 'Aucun nageur a été trouvé pour la modification !');
        when exbusy then raise_application_error('-20002', 'Resource occupée !');
        when others then
        if sqlerrm like '%CAPITAJOCOTISATION%' then raise_application_error('-20000', 'Cotisation invalide! (O ou N)');
        elsif sqlerrm like '%CAPITAJONAISSANCENOTNULL%' then raise_application_error('-20001', 'L''annee de naissance doit exister!');
        elsif sqlerrm like '%CAPITAJONOMNOTNULL%' then raise_application_error('-20002', 'Le nom doit exister !');
        elsif sqlerrm like '%CAPITAJOPKNAGEURS%' then raise_application_error('-20003', 'La clé primaire de nageurs est incorrecte !');
        elsif sqlerrm like '%CAPITAJOPRENOMNOTNULL%' then raise_application_error('-20004', 'Le prénom doit exister !');
        elsif sqlerrm like '%CAPITAJOREFNAGEURSCAT%' then raise_application_error('-20005', 'La catégorie doit exister dans la table Catégories !'); -- Pas nécessaire
        elsif sqlerrm like '%CAPITAJOREFNAGEURSPK%' then raise_application_error('-20006', 'Le code postal doit exister dans la table codepostaux !');
        elsif sqlerrm like '%CAPITAJOSEXE%' then raise_application_error('-20007', 'Le sexe est invalide! (M ou F)');
        elsif sqlerrm like '%CAPITAJOSEXENOTNULL%' then raise_application_error('-20008', 'Le sexe doit exister !');
        else raise;
        end if;
    end ModifierNageur;


    procedure SupprimerNageur (nageurarg nageurs.nrligue%type, annee_journee journees.annee%type) as
        anneenull exception;
        nageurnull exception;
        deletedException exception;
        compteur integer;
        exbusy exception;
        pragma exception_init(exbusy, -54);
        cond integer;
        tmp nageurs%rowtype;
    begin
        compteur := 0;
        cond := 0;
        if annee_journee is null then
            raise anneenull;
        end if;
        if nageurarg is null then
            raise nageurnull;
        end if;
        while(cond = 0) loop
            begin
                select * into tmp
                from nageurs
                where nrligue = nageurarg
                for update nowait;
                cond :=1;
            exception
                when exbusy then 
                    if compteur < 3 then 
                        compteur := compteur + 1;
                        dbms_lock.sleep(3);
                    else
                        raise;
                    end if;
                when others then raise;
            end;
        end loop;

        if tmp.nrligue <> nageurarg
        then raise deletedException; 
        end if;

        delete from nageurs where nrligue not in (select nrligue from resultats where annee < annee_journee) and nrligue = nageurarg;
        update clubs set responsable = null
        where responsable = nageurarg;
        commit;
        if(SQL%FOUND = true) then
            dbms_output.put_line('responsable = null: Inséré');
        end if;
    exception
        when anneenull then raise_application_error('-20000', 'Année invalide !');
        when nageurnull then raise_application_error('-20001', 'Nageur invalide !');
        when exbusy then raise_application_error('-20002', 'Resource occupée !');
        when deletedException then raise_application_error('-20003', 'Tuple déjà supprimé !');
        when others then raise;
    end SupprimerNageur;

    procedure AjouterJournee (une_journee journees%rowtype) as
    begin
        Insert into JOURNEES (COMPETITION,ANNEE,JOUR,DATEHEURECOMPETITION,HEUREECHAUFFEMENT,PISCINE,JUGE,DATELIMITEINSCRIPTION) 
        values (une_journee.competition, une_journee.annee, une_journee.jour, une_journee.dateheurecompetition, une_journee.heureechauffement, une_journee.piscine, une_journee.juge, une_journee.datelimiteinscription);
        dbms_output.put_line('Tuple ajouté !');
    exception
        when DUP_VAL_ON_INDEX then raise_application_error('-20000', 'Valeur déjà existante !');
        when others then
        if sqlerrm like '%CAPITAJOREFJOURNEESPISCINES%' then raise_application_error('-20000', 'Piscine doit exister dans la table piscines !');
        elsif sqlerrm like '%CAPITAJOREFJOURNEESJUGES%' then raise_application_error('-20001', 'Juge doit exister dans la table juges');
        elsif sqlerrm like '%CAPITAJOPKJOURNEES%' then raise_application_error('-20002', 'la clé primaire doit exister');
        elsif sqlerrm like '%CAPITAJOREFJOURNEESCOMPETITIONS%' then raise_application_error('-20003', 'competition doit exister dans la table competitions !');
        elsif sqlerrm like '%CAPITAJODATEEGALES%' then raise_application_error('-20004', 'La date de la compétition doit être égale à la date d''échauffement !');
        elsif sqlerrm like '%CAPITAJODATEINFERIEUR%' then raise_application_error('-20005', 'La date limite d''inscription doit être antérieure d''au moins 8 jours à la date de la compétition !');
        elsif sqlerrm like '%CAPITAJOCHAUFFEDEMIHEURE%' then raise_application_error('-20006', 'Avant toute compétition, le nageur doit pouvoir s''échauffer au moins pendant une demi-heure !');
        else raise;
        end if;
    end AjouterJournee;


procedure ModifierJournee (anc_journee journees%rowtype, new_journee journees%rowtype) as

    journeetemp journees%rowtype;
    modifiedexception exception;
    compteur integer;
    exbusy exception;
    pragma exception_init(exbusy, -54);
    cond integer;
    begin
        compteur := 0;
        cond := 0;
        while(cond = 0) loop
            begin
                select * into journeetemp from journees
                where jour = anc_journee.jour
                and competition = anc_journee.competition
                and annee = anc_journee.annee for update nowait;
                cond :=1;
            exception
                when exbusy then 
                    if compteur < 3 then 
                        compteur := compteur + 1;
                        dbms_lock.sleep(3);
                    else
                        raise;
                    end if;
                when others then raise;
            end;
        end loop;
        if anc_journee.jour <> journeetemp.jour 
        or anc_journee.competition <> journeetemp.competition
        or to_char(anc_journee.dateheurecompetition, 'DD/MM/YYYY HH:MI:SS') <> to_char(journeetemp.dateheurecompetition, 'DD/MM/YYYY HH:MI:SS')
        or to_char(anc_journee.heureechauffement, 'DD/MM/YYYY HH:MI:SS') <> to_char(journeetemp.heureechauffement, 'DD/MM/YYYY HH:MI:SS')
        or anc_journee.piscine <> journeetemp.piscine 
        or anc_journee.juge <> journeetemp.juge
        or to_char(anc_journee.datelimiteinscription, 'DD/MM/YYYY HH:MI:SS') <> to_char(journeetemp.datelimiteinscription, 'DD/MM/YYYY HH:MI:SS')
        then raise modifiedexception; 
        end if;
        
        update journees set 
            jour = new_journee.jour,
            annee = new_journee.annee,
            competition = new_journee.competition,
            dateheurecompetition = new_journee.dateheurecompetition,
            heureechauffement = new_journee.heureechauffement,
            piscine = new_journee.piscine,
            juge = new_journee.juge,
            datelimiteinscription = new_journee.datelimiteinscription
        where 
            jour = anc_journee.jour
            and competition = anc_journee.competition
            and annee = anc_journee.annee;
        commit;
        dbms_output.put_line('Tuple modifié !');
    exception
        when DUP_VAL_ON_INDEX then raise_application_error('-20000', 'Valeur déjà existante !');
        when modifiedexception then raise_application_error('-20010', 'Valeur modifiée en cours de route !'); commit;
        when NO_DATA_FOUND then raise_application_error('-20009', 'Aucue journee a été trouvé pour la modification !');
        when exbusy then raise_application_error('-20002', 'Resource occupée !');
        when others then
        if sqlerrm like '%CAPITAJOREFJOURNEESPISCINES%' then raise_application_error('-20000', 'Piscine doit exister dans la table piscines !');
        elsif sqlerrm like '%CAPITAJOREFJOURNEESJUGES%' then raise_application_error('-20001', 'Juge doit exister dans la table juges');
        elsif sqlerrm like '%CAPITAJOPKJOURNEES%' then raise_application_error('-20002', 'la clé primaire doit exister');
        elsif sqlerrm like '%CAPITAJOREFJOURNEESCOMPETITIONS%' then raise_application_error('-20003', 'competition doit exister dans la table organisateurs (et compétitions) !');
        elsif sqlerrm like '%CAPITAJODATEEGALES%' then raise_application_error('-20004', 'La date de la compétition doit être égale à la date d''échauffement !');
        elsif sqlerrm like '%CAPITAJODATEINFERIEUR%' then raise_application_error('-20005', 'La date limite d''inscription doit être antérieure d''au moins 8 jours à la date de la compétition !');
        elsif sqlerrm like '%CAPITAJOCHAUFFEDEMIHEURE%' then raise_application_error('-20006', 'Avant toute compétition, le nageur doit pouvoir s''échauffer au moins pendant une demi-heure !');
        else raise;
        end if;
    end ModifierJournee;

    function Lister (numcomp journees.competition%type, var_annee journees.annee%type, var_jour journees.jour%type) 
        return t_nageur is table_nageurs t_nageur;
        numcompNullException exception;
        var_anneeNullException exception;
        var_jourNullException exception;
        begin
            if numcomp is null then raise numcompNullException;
            elsif var_annee is null then raise var_anneeNullException;
            elsif var_jour is null then raise var_jourNullException;
            end if;

            select * bulk collect into table_nageurs
            from nageurs
            where (to_number(to_char(current_date, 'YYYY')) - anneenaiss) <= 35
                and nrligue in (
                    select nrligue
                    from resultats
                    where annee = var_annee
                        and jour = var_jour
                        and competition = numcomp
                        and tempsreference is not null
                    minus 
                        select nrligue
                        from resultats 
                        where tempsreference is null
                            and jour = var_jour
                            and competition = numcomp);
            
            if table_nageurs.count = 0 then
                raise no_data_found;
            end if;

            return table_nageurs;
        exception
            when no_data_found then raise_application_error(-20003, 'Aucune ligne trouvée !');
            when numcompNullException then raise_application_error(-20000, 'Le numéro de compétition entré en paramètre ne peut être null !');
            when var_anneeNullException then raise_application_error(-20001, 'L''annee entrée en paramètre ne peut être null !');
            when var_jourNullException then raise_application_error(-20002, 'Le jour entré en paramètre ne peut être null !');
            when others then raise;
    end Lister;

    function Lister (nbcourses integer) 
        return t_competition is table_competition t_competition;
        nbcoursesNullException exception;
        cursor curs(ncourses integer) is
            SELECT competition, competitions.libelle, dateheurecompetition, jour, COUNT (Planning.course) as nbcourses
            FROM Planning INNER JOIN Competitions USING (Competition)
		               INNER JOIN Journees USING (Competition, annee, jour)
            GROUP BY Competition, Competitions.libelle, DateHeureCompetition, jour
            HAVING COUNT (Planning.course) >= ncourses;
        begin
            if nbcourses is null then raise nbcoursesNullException; end if;
            open curs(nbcourses);
            fetch curs bulk collect into table_competition;
            close curs;
            if table_competition.count = 0 then
                raise no_data_found;
            end if;
            return table_competition;
        exception
            when no_data_found then raise_application_error(-20003, 'Aucune ligne trouvée !');
            when nbcoursesNullException then raise_application_error(-20000, 'Le paramètre nbcourses ne peut être null !');
            when others then raise;
    end Lister;

end capitajoMasters;



-- Tests

-- Supprimer nageur
begin
    capitajomasters.SUPPRIMERNAGEUR('63/000228/CCM', 2017);
    --capitajomasters.SUPPRIMERNAGEUR('62/000118/ZNA', 2030); -- Aucune valeur
exception
    when others then
        dbms_output.put_line(sqlerrm);
end;


-- Ajouter nageur

declare
    nageur nageurs%rowtype;
begin
    nageur.nrligue := '50000';
    nageur.nom := 'totott';
    nageur.club := 'NSG';
    nageur.prenom := 'momott';
    nageur.anneenaiss := 1993;
    nageur.sexe := 'M';
    
    capitajomasters.AjouterNageur(nageur);
exception
    when others then
        dbms_output.put_line(sqlerrm);
end;

-- Modifier nageur

declare
    nageur nageurs%rowtype;
    nageur2 nageurs%rowtype;
begin
    nageur.nrligue := '93/000001/NSG';
    nageur.nom := 'totott';
    nageur.prenom := 'momott';
    nageur.anneenaiss := 1993;
    nageur.sexe := 'M';
    nageur.club := 'NSG';
    
    nageur2.nrligue := '93/000001/NSG';
    nageur2.nom := 'toto';
    nageur2.prenom := 'tita';
    nageur2.anneenaiss := 1995;
    nageur2.sexe := 'F';
    nageur2.club := 'NSG';
    
    capitajoMasters.ModifierNageur(nageur, nageur2);
exception
    when NO_DATA_FOUND then dbms_output.put_line(sqlerrm);
    when others then dbms_output.put_line(sqlerrm);
end;

-- Ajouter Journee

declare
    journee journees%rowtype;
begin
    journee.competition := 4;
    journee.annee := 2015;
    journee.jour := 1;
    journee.dateheurecompetition := to_date('25/6/2018 7:00', 'DD/MM/YYYY HH:MI');
    journee.heureechauffement := to_date('25/6/2018 6:00', 'DD/MM/YYYY HH:MI');
    journee.piscine := 1;
    journee.juge := 1;
    journee.datelimiteinscription := to_date('20/6/2018 12:00', 'DD/MM/YYYY HH:MI');
    
    capitajomasters.AjouterJournee(journee);
exception
    when DUP_VAL_ON_INDEX then dbms_output.put_line(sqlerrm);
    when others then dbms_output.put_line(sqlerrm);
end;

-- Modifier journee

declare
    journee journees%rowtype;
    journee2 journees%rowtype;
begin
    journee.competition := 4;
    journee.annee := 2015;
    journee.jour := 1;
    journee.dateheurecompetition := to_date('25/6/2018 7:00', 'DD/MM/YYYY HH:MI');
    journee.heureechauffement := to_date('25/6/2018 6:00', 'DD/MM/YYYY HH:MI');
    journee.piscine := 1;
    journee.juge := 1;
    journee.datelimiteinscription := to_date('20/6/2018 12:00', 'DD/MM/YYYY HH:MI');
    
    journee2.competition := 4;
    journee2.annee := 2015;
    journee2.jour := 1;
    journee2.dateheurecompetition := to_date('26/6/2018 8:00', 'DD/MM/YYYY HH:MI');
    journee2.heureechauffement := to_date('26/6/2018 7:00', 'DD/MM/YYYY HH:MI');
    journee2.piscine := 2;
    journee2.juge := 2;
    journee2.datelimiteinscription := to_date('21/6/2018 10:00', 'DD/MM/YYYY HH:MI');
    
    capitajoMasters.ModifierJournee(journee, journee2);
exception
    when DUP_VAL_ON_INDEX then dbms_output.put_line(sqlerrm);
    when NO_DATA_FOUND then dbms_output.put_line(sqlerrm);
    when others then dbms_output.put_line(sqlerrm);
end;

-- Liste 1

declare
    liste capitajomasters.t_nageur;
begin
    liste := CAPITAJOMASTERS.Lister(2, 2003, 1);
    --liste := CAPITAJOMASTERS.Lister(null, 2003, 1);
    --liste := CAPITAJOMASTERS.Lister(2, null, 1);
    --liste := CAPITAJOMASTERS.Lister(2, 2003, null);
    --liste := CAPITAJOMASTERS.Lister(2, 2050, 1); -- aucune valeur
    for i in 1..liste.count loop
        dbms_output.put_line('*********************');
        dbms_output.put_line('nrligue = ' || liste(i).nrligue);
        dbms_output.put_line('nom = ' || liste(i).nom);
        dbms_output.put_line('prenom = ' || liste(i).prenom);
    end loop;
exception
    when no_data_found then dbms_output.put_line(sqlerrm);
    when others then dbms_output.put_line(sqlerrm);
end;


-- Liste 2

declare
    liste capitajomasters.t_competition;
begin
    liste := CAPITAJOMASTERS.Lister(10);
    --liste := CAPITAJOMASTERS.Lister(100); -- aucune valeur
    -- liste := CAPITAJOMASTERS.Lister(null);
    for i in 1..liste.count loop
        dbms_output.put_line('*********************');
        dbms_output.put_line('Numéro de compétition = ' || liste(i).competition);
        dbms_output.put_line('Nom de compétition = ' || liste(i).nom);
        dbms_output.put_line('Date de compétition = ' || liste(i).datecompetition);
        dbms_output.put_line('Jour = ' || liste(i).jour);
        dbms_output.put_line('Nombre de courses = ' || liste(i).nbcourses);
    end loop;
exception
    when no_data_found then dbms_output.put_line(sqlerrm);
    when others then dbms_output.put_line(sqlerrm);
end;

