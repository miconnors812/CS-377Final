# Pokémon Battle Database


Overview:

This database models a simplified Pokémon battle system. It tracks Pokémon stats, trainers, battles, tournament brackets, and battle actions. 
The schema is designed to support relationships between trainers and their partner Pokémon, simulate battles, and record outcomes.

The database consists of the following tables:
- pokemon
- trainers
- type_effectiveness
- battling
- bracket
- champions
- battle_actions

## pokemon

Stores base information and stats for each Pokémon.
| Column | Type        | Description               |
| ------ | ----------- | ------------------------- |
| dex_id | SERIAL (PK) | Unique Pokémon ID         |
| name   | VARCHAR     | Pokémon name              |
| type1  | VARCHAR     | Primary type              |
| type2  | VARCHAR     | Secondary type (optional) |
| hp     | INT         | Hit Points                |
| atk    | INT         | Attack stat               |
| def    | INT         | Defense stat              |
| spatk  | INT         | Special Attack            |
| spdef  | INT         | Special Defense           |
| speed  | INT         | Speed stat                |

## trainers

Stores trainer information and their partner Pokémon.
| Column  | Type        | Description                |
| ------- | ----------- | -------------------------- |
| t_id    | SERIAL (PK) | Unique trainer ID          |
| fname   | VARCHAR     | First name                 |
| lname   | VARCHAR     | Last name                  |
| gender  | VARCHAR     | Gender                     |
| bday    | DATE        | Birthday                   |
| partner | INT (FK)    | Pokémon (pokemon.dex_id)   |

## type_effectiveness

Defines how effective one type is against another.
| Column        | Type     | Description       |
| ------------- | -------- | ----------------- |
| attacker_type | VARCHAR  | Attacking type    |
| defender_type | VARCHAR  | Defending type    |
| multiplier    | DEC(3,2) | Damage multiplier |
Primary Key: (attacker_type, defender_type)

## battling

Represents an active or recorded battle between two trainers.
| Column     | Type        | Description                       |
| ---------- | ----------- | --------------------------------- |
| b_id       | SERIAL (PK) | Battle ID                         |
| t_id1      | INT (FK)    | Trainer 1                         |
| t_id2      | INT (FK)    | Trainer 2                         |
| p1_currhp  | DEC(5,2)    | Current HP of trainer 1's Pokémon |
| p2_currhp  | DEC(5,2)    | Current HP of trainer 2's Pokémon |
| turn_order | INT         | Indicates whose turn it is        |

## bracket

Stores tournament bracket information for 4 trainers.
| Column  | Type        | Description            |
| ------- | ----------- | ---------------------- |
| br_id   | SERIAL (PK) | Bracket ID             |
| t_id1–4 | INT (FK)    | Participating trainers |
| winner1 | INT         | Winner of match 1      |
| winner2 | INT         | Winner of match 2      |

## champions

Tracks final winners of tournament brackets.
| Column | Type        | Description                 |
| ------ | ----------- | --------------------------- |
| c_id   | SERIAL (PK) | Champion record ID          |
| w1_id  | INT         | Winner from bracket match 1 |
| w2_id  | INT         | Winner from bracket match 2 |


## battle_actions

Logs actions taken during battles.
| Column      | Type        | Description    |
| ----------- | ----------- | -------------- |
| action_id   | SERIAL (PK) | Action ID      |
| b_id        | INT (FK)    | Battle ID      |
| turn_number | INT         | Turn number    |
| actor       | INT         | Acting trainer |
| damage      | DEC(5,2)    | Damage dealt   |

Relationships: 
- Each trainer has one partner Pokémon.
- Battles occur between two trainers.
- Battle actions are tied to a specific battle.
- Brackets organize trainers into tournament rounds.
- Champions are determined from bracket winners.

