# Pokémon Battle Database


Overview:

This database models a simplified Pokémon battle system. It tracks Pokémon stats, trainers, battles, tournament brackets, and battle actions. 
The schema is designed to support relationships between trainers and their partner Pokémon, simulate battles, and record outcomes.

The database consists of the following tables:
- pokemon
- trainers
- type_effectiveness
- battling
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
| Column      | Type        | Description                          |
| ----------- | ----------- | ------------------------------------ |
| b_id        | SERIAL (PK) | Battle ID                            |
| t_id1       | INT (FK)    | Trainer 1                            |
| t_id2       | INT (FK)    | Trainer 2                            |
| p1_currhp   | DEC(5,2)    | Current HP of trainer 1's Pokémon    |
| p2_currhp   | DEC(5,2)    | Current HP of trainer 2's Pokémon    |
| turn_number | INT         | Current turn number                  |
| winner      | INT (FK)    | Winning trainer ID (NULL if ongoing) |


## champions

Tracks final winners of tournament brackets.
| Column | Type        | Description          |
| ------ | ----------- | -------------------- |
| c_id   | SERIAL (PK) | Champion record ID   |
| w_id   | INT (FK)    | Winning trainer ID   |
| b_id   | INT (FK)    | Associated battle ID |



## battle_actions

Logs actions taken during battles.
| Column      | Type        | Description                        |
| ----------- | ----------- | ---------------------------------- |
| action_id   | SERIAL (PK) | Action ID                          |
| b_id        | INT (FK)    | Battle ID                          |
| turn_number | INT         | Turn number                        |
| p1attack    | DEC(5,2)    | Damage dealt by trainer 1          |
| p2attack    | DEC(5,2)    | Damage dealt by trainer 2          |
| p1_currhp   | DEC(5,2)    | Pokemon 1 HP after damage          |
| p2_currhp   | DEC(5,2)    | Pokemon 2 HP after damage          |
| p1_maxhp    | DEC(5,2)    | Pokemon 1 max HP  |
| p2_maxhp    | DEC(5,2)    | Pokemon 2 max HP  |


Relationships: 
- Each trainer has one partner Pokémon.
- Battles occur between two trainers.
- Battle actions are tied to a specific battle.
- Champions are determined from battle winners.

---------------------------------------------------------------

# Comprehensive Review:
### Procedures:
###### The Main Procedure: update_battle
This is the procedure that will simulate a pokemon battle between two trainers. All you need to do is supply a battle id and it will progress that battle by one turn where each trainer's pokemon can attack the other. First, it calculates the damage that each pokemon will deal to each other. This is decided by the pokemon's own attack and special attack stat, as well as the type effectiveness between the pokemon's types. After subtracting that damage from each pokemon's health digit, a winner will be decided if one of them has reached lower than 0 and thus has lost. In the case of a tie, the pokemon with a higher speed stat who can move first will win. After this has been done, the entry with the supplied id in the battling table will be updated, an entry will be INSERTed to battle_actions to act as a record for this moment in time, and the winning trainer will be added to the champions table if one is decided on this turn.
<img width="483" height="912" alt="image" src="https://github.com/user-attachments/assets/02435f5a-5aa7-4e14-adba-e3d63a7989f9" />
<img width="501" height="932" alt="image" src="https://github.com/user-attachments/assets/f3857f8f-416a-4975-afef-d99f57adf62a" />
<img width="586" height="942" alt="image" src="https://github.com/user-attachments/assets/4519e58f-4407-4c14-916f-e7ed89c6422d" />
<img width="363" height="263" alt="image" src="https://github.com/user-attachments/assets/8f36cc06-7be1-4998-8da5-25cb55182b3c" />


surrender_battle - a trainer can give up mid battle to end it prematurely and declare the other trainer as a champion.
<img width="532" height="492" alt="image" src="https://github.com/user-attachments/assets/de259c34-81d8-4f97-b808-37b953370104" />


pokemon_trade - swap out a trainer's partner pokemon for a different one using the UPDATE function.
<img width="457" height="303" alt="image" src="https://github.com/user-attachments/assets/3b7d6c11-e264-4ccb-9278-3feaf5a2e5a6" />


### Views:
partner_info - displays a trainer's name and the information regarding their specific partner pokemon.
<img width="1067" height="135" alt="image" src="https://github.com/user-attachments/assets/6613e069-b66d-4378-9aac-ecf460f935fe" />

### General Queries:
AVG, MAX, Where __ Like %%, Order by DESC, and a Window function with rank and over: 
<img width="528" height="367" alt="image" src="https://github.com/user-attachments/assets/b5c05373-18d4-4fe2-b79d-b3b72985bc42" />

## New Features
Declare - this can be used in a procedure to initialize variables that will be used commonly throughout the procedure to reduce redundant code.
<img width="328" height="517" alt="image" src="https://github.com/user-attachments/assets/5e6c40a0-0123-47b6-af7a-cd5002f25ffc" />

Greatest - This is similar to coalesce, in that it compares two values. Instead of choosing the NOT NULL value like coalesce, the one with the greatest value is chosen instead.
<img width="477" height="77" alt="image" src="https://github.com/user-attachments/assets/4e7d68a0-1938-4306-9b37-857d169d49bc" />

Composite Primary Key - This type of primary key requires both values to have a unique combination of their values. This is useful for defining relationships between two values without having any duplicates.
<img width="430" height="36" alt="image" src="https://github.com/user-attachments/assets/9e267c10-4e71-4bd4-8b7c-b101d13ae498" />


