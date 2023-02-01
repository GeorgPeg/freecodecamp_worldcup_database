#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Clean
echo $($PSQL "TRUNCATE teams, games")

# Teams
cat games.csv | while IFS=',' read YEAR ROUND WIN OPP WIN_G OPP_G
do
  if [[ $YEAR != "year" ]]
  then
    # Teams table ####
    # WINNERS
    # Search team
    TEAM=$($PSQL "SELECT name FROM teams WHERE name = '$WIN'")
    # If not found
    if [[ -z $TEAM ]]
    then
      # Insert team 
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WIN')")
      # Print info
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "Inserted $WIN into teams."
      fi
    fi
    # Save winner id 
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")
    
    # OPPONENTS
    TEAM=$($PSQL "SELECT name FROM teams WHERE name = '$OPP'")
    # If not found
    if [[ -z $TEAM ]]
    then
      # Insert team 
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPP')")
      # Print info
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "Added $OPP to teams."
      fi
    fi
    # Save opponent id 
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPP'") 

    # Games table ####
    # Search team
    GAME=$($PSQL "SELECT * FROM games WHERE year = $YEAR AND round = '$ROUND' AND winner_id = $WIN_ID AND opponent_id = $OPP_ID AND winner_goals = $WIN_G AND opponent_goals = $OPP_G")
    # If not found
    if [[ -z $GAME ]]
    then   
      # Insert game 
      INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WIN_G, $OPP_G)")
      # Print info
      if [[ $INSERT_GAME == "INSERT 0 1" ]]
      then
        echo "Added $YEAR, '$ROUND', $WIN_ID ($WIN), $OPP_ID ($OPP), $WIN_G : $OPP_G to games."
      fi  
    fi
  fi
done
