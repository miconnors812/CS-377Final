CREATE TABLE pokemon (
	dex_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	type1 VARCHAR(50) NOT NULL,
	type2 VARCHAR(50),
	hp INT NOT NULL,
	atk INT NOT NULL,
	def INT NOT NULL,
	spatk INT NOT NULL,
	spdef INT NOT NULL,
	speed INT NOT NULL
);

SELECT * FROM trainers;
CREATE TABLE trainers (
	t_id SERIAL PRIMARY KEY,
	fname VARCHAR(50) NOT NULL,
	lname VARCHAR(50),
	gender VARCHAR(10),
	bday DATE NOT NULL,
	partner INT NOT NULL,
	FOREIGN KEY (partner) REFERENCES pokemon(dex_id)
 );
 
 CREATE TABLE type_effectiveness (
    attacker_type VARCHAR(50),
    defender_type VARCHAR(50),
    multiplier DEC(3,2) NOT NULL,
    PRIMARY KEY (attacker_type, defender_type)
);

CREATE TABLE battling (
	b_id SERIAL PRIMARY KEY,
	t_id1 INT NOT NULL,
	t_id2 INT NOT NULL,
	p1_currhp DEC(6,2) DEFAULT 1,
	p2_currhp DEC(6,2) DEFAULT 1,
	turn_number INT DEFAULT 0,
	winner INT,
	FOREIGN KEY (winner) REFERENCES trainers(t_id),
	FOREIGN KEY (t_id1) REFERENCES trainers(t_id),
	FOREIGN KEY (t_id2) REFERENCES trainers(t_id)
	
);


CREATE TABLE champions (
	c_id SERIAL PRIMARY KEY,
	w_id INT NOT NULL,
	b_id INT NOT NULL,
    FOREIGN KEY (w_id) REFERENCES trainers(t_id),
	FOREIGN KEY (b_id) REFERENCES battling(b_id)
);
CREATE TABLE battle_actions (
    action_id SERIAL PRIMARY KEY,
    b_id INT,
    p1attack DEC(6,2) DEFAULT 0,
	p2attack DEC(6,2) DEFAULT 0,
	p1_currhp DEC(6,2) DEFAULT 1,
	p2_currhp DEC(6,2) DEFAULT 1,
	p1_maxhp DEC(6,2) DEFAULT 1,
	p2_maxhp DEC(6,2) DEFAULT 1,
	turn_number INT NOT NULL,
    FOREIGN KEY (b_id) REFERENCES battling(b_id)
);

-- reset battle tables
DELETE FROM battle_actions;
DELETE FROM champions;
DELETE FROM battling;
ALTER SEQUENCE battling_b_id_seq RESTART WITH 1;
ALTER SEQUENCE battle_actions_action_id_seq RESTART WITH 1;
ALTER SEQUENCE champions_c_id_seq RESTART WITH 1;
INSERT INTO battling (t_id1, t_id2)
VALUES 
(1, 2),
(3, 4),
(5, 6),
(7, 8),
(9, 10),
(11, 12),
(13, 14),
(15, 16),
(17, 18),
(19, 20);

CREATE OR REPLACE PROCEDURE pokemon_trade(
	new_pokemon_id INT,
	p_trainer_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE trainers
	SET partner = new_pokemon_id
	WHERE t_id = p_trainer_id;
END;
$$;

select * from trainers where t_id = 300;
CALL pokemon_trade(762,300);
select * from trainers where t_id = 300;

CREATE OR REPLACE PROCEDURE surrender_battle(
	battle_id INT,
	losing_trainer_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	DELETE FROM battling
	WHERE b_id = battle_id;
	
	INSERT INTO champions (
            b_id,
            w_id)
        VALUES (
           	battle_id,
            losing_trainer_id);
END;
$$;



SELECT name, 'HP' AS stat, hp AS value,
           RANK() OVER (ORDER BY hp DESC) AS rnk
    FROM pokemon;

SELECT name, atk
FROM pokemon
WHERE atk = (SELECT MAX(atk) FROM pokemon);

SELECT AVG(def)
FROM pokemon;

SELECT name, POSITION('ing' in name)
FROM pokemon
WHERE LOWER(name) LIKE '%ing%';

CREATE OR REPLACE VIEW partner_info AS
	SELECT t.fname, t.lname, p.name, p.type1, p.type2, p.hp, p.atk, p.def, p.spatk, p.spdef, p.speed,
	p.hp + p.atk + p.def + p.spatk + p.spdef + p.speed as stat_total
	FROM trainers i
	JOIN trainers t ON t.t_id = i.t_id
	JOIN pokemon p ON p.dex_id = i.partner;

	SELECT * from partner_info;


CREATE OR REPLACE PROCEDURE update_battle(
    p_b_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE

    v_t1 INT;
    v_t2 INT;

    v_turn INT;

    v_p1attack DECIMAL(6,2);
    v_p2attack DECIMAL(6,2);

    v_p1hp DECIMAL(6,2);
    v_p2hp DECIMAL(6,2);

    v_new_p1hp DECIMAL(6,2);
    v_new_p2hp DECIMAL(6,2);

    v_p1speed INT;
    v_p2speed INT;

    v_winner INT;

    v_p1maxhp DECIMAL(6,2);
    v_p2maxhp DECIMAL(6,2);

BEGIN

	

    -- Get battle state
    SELECT
        b.t_id1,
        b.t_id2,
        b.turn_number,
        b.p1_currhp,
        b.p2_currhp
    INTO
        v_t1,
        v_t2,
        v_turn,
        v_p1hp,
        v_p2hp
    FROM battling b
    WHERE b.b_id = p_b_id
      AND b.winner IS NULL;		

    -- Compute damage, speed, & max HP
    SELECT

        -- p1 attacking p2 type1
	    (COALESCE(te11.multiplier,1) * COALESCE(te12.multiplier, 1) +
	    -- p1 attacking p2 type2
	    COALESCE(te13.multiplier,1) * COALESCE(te14.multiplier, 1)) *
		((p1.atk + p1.spatk)/2),
	
		-- p2 attacking p1 type1
	    (COALESCE(te21.multiplier,1) * COALESCE(te22.multiplier, 1) +
	    -- p2 attacking p1 type2
	    COALESCE(te23.multiplier,1) * COALESCE(te24.multiplier, 1)) *
	
		((p2.atk + p2.spatk)/2),

        p1.speed,
        p2.speed,

        (p1.hp + p1.def + p1.spdef),
        (p2.hp + p2.def + p2.spdef)

    INTO
        v_p1attack,
        v_p2attack,
        v_p1speed,
        v_p2speed,
        v_p1maxhp,
        v_p2maxhp

    FROM trainers t1
    JOIN trainers t2 ON t2.t_id = v_t2
    JOIN trainers t1b ON t1b.t_id = v_t1

    JOIN pokemon p1 ON p1.dex_id = t1b.partner
    JOIN pokemon p2 ON p2.dex_id = t2.partner

    LEFT JOIN type_effectiveness te11
        ON te11.attacker_type = p1.type1
       AND te11.defender_type = p2.type1

    LEFT JOIN type_effectiveness te12
        ON te12.attacker_type = p1.type2
       AND te12.defender_type = p2.type1

    LEFT JOIN type_effectiveness te13
        ON te13.attacker_type = p1.type1
       AND te13.defender_type = p2.type2

    LEFT JOIN type_effectiveness te14
        ON te14.attacker_type = p1.type2
       AND te14.defender_type = p2.type2

    LEFT JOIN type_effectiveness te21
        ON te21.attacker_type = p2.type1
       AND te21.defender_type = p1.type1

    LEFT JOIN type_effectiveness te22
        ON te22.attacker_type = p2.type2
       AND te22.defender_type = p1.type1

    LEFT JOIN type_effectiveness te23
        ON te23.attacker_type = p2.type1
       AND te23.defender_type = p1.type2

    LEFT JOIN type_effectiveness te24
        ON te24.attacker_type = p2.type2
       AND te24.defender_type = p1.type2

    WHERE t1.t_id = v_t1;
	-- initilaize hp
	IF v_turn <= 0 THEN
    	v_p1hp := v_p1maxhp;
    	v_p2hp := v_p2maxhp;
	END IF;
	
    -- Apply damage
    v_new_p1hp := GREATEST(v_p1hp - v_p2attack, 0);
    v_new_p2hp := GREATEST(v_p2hp - v_p1attack, 0);

    -- Determine winner
    IF v_new_p1hp <= 0 AND v_new_p2hp <= 0 THEN

        IF v_p1speed >= v_p2speed THEN
            v_winner := v_t1;
        ELSE
            v_winner := v_t2;
        END IF;

    ELSIF v_new_p1hp <= 0 THEN
        v_winner := v_t2;

    ELSIF v_new_p2hp <= 0 THEN
        v_winner := v_t1;

    ELSE
        v_winner := NULL;
    END IF;

    -- Update battle state
    UPDATE battling
    SET
        p1_currhp = v_new_p1hp,
        p2_currhp = v_new_p2hp,
        winner = v_winner,
        turn_number = turn_number + 1
    WHERE b_id = p_b_id;

    -- Insert new battle action
    INSERT INTO battle_actions (
        b_id,
        turn_number,
        p1attack,
        p2attack,
        p1_currhp,
        p2_currhp,
        p1_maxhp,
        p2_maxhp
    )
    VALUES (
        p_b_id,
        v_turn,
        v_p1attack,
        v_p2attack,
        v_new_p1hp,
        v_new_p2hp,
        v_p1maxhp,
        v_p2maxhp
    );

    -- Insert champion if battle ends
    IF v_winner IS NOT NULL THEN

        INSERT INTO champions (
            b_id,
            w_id
        )
        VALUES (
            p_b_id,
            v_winner
        );

    END IF;

END;
$$;


CREATE OR REPLACE VIEW actions AS
select ba.action_id,ba.turn_number, p1.name AS p1,ba.p2attack, ba.p1_currhp, ba.p1_maxhp,
p2.name AS p2, ba.p1attack, ba.p2_currhp, ba.p2_maxhp, b.winner, b.b_id
	from battle_actions ba 
	JOIN battling b ON b.b_id = ba.b_id
	

	JOIN trainers t2 ON t2.t_id = b.t_id2
	JOIN trainers t1 ON t1.t_id = b.t_id1

    JOIN pokemon p1 ON p1.dex_id = t1.partner
    JOIN pokemon p2 ON p2.dex_id = t2.partner;

	CALL update_battle(7);
	SELECT * FROM actions; --WHERE b_id = 6;

-- display matchups
select b.b_id,p1.name,p2.name, b.winner from battling b  
	JOIN trainers t2 ON t2.t_id = b.t_id2
	JOIN trainers t1 ON t1.t_id = b.t_id1

    JOIN pokemon p1 ON p1.dex_id = t1.partner
    JOIN pokemon p2 ON p2.dex_id = t2.partner ;
	--JOIN battle_actions ba ON ba.b_id = b.b_id;

-- announce winners
select CONCAT(CONCAT_WS(' ','Winner of Battle',c_id,'is',t.fname,t.lname,'&',p.name,'in',b.turn_number,'turns!','They have won',
COUNT(*) OVER (PARTITION BY c.w_id),'times, and they are winner number', ROW_NUMBER() OVER (ORDER BY c.c_id),'right after', 
COALESCE(LAG(t.fname) OVER (ORDER BY c.c_id),'no one else')),'.') AS announcement from champions c
	JOIN trainers t ON t.t_id = c.w_id
    JOIN pokemon p ON p.dex_id = t.partner
	JOIN battling b ON b.b_id = c.b_id;

-- show top three damagers with cute nicknames
SELECT CONCAT(SUBSTR(p1,1,4),'-',SUBSTR(p1,1,4),SUBSTR(p1,LENGTH(TRIM(p1))-1,LENGTH(TRIM(p1))-3)) as nickname,
SUM(p1attack) from actions GROUP BY p1 HAVING SUM(p1attack) > 100 LIMIT 3;
