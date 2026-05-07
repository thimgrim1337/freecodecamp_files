#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
GET_TEAM_ID() {
  local NAME=$1
  local ID=$($PSQL "select team_id from teams where name = '$NAME';")

    if [[ -z $ID  ]] 
    then
      $($PSQL "insert into teams(name) values('$NAME');")
      echo $($PSQL "select team_id from teams where name = '$NAME';")
    else
      echo $ID
    fi
}

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  if [[ $YEAR != year ]]
  then
    WINNER_ID=$(GET_TEAM_ID "$WINNER")
    OPPONENT_ID=$(GET_TEAM_ID "$OPPONENT")
    $PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);"
 fi
done

