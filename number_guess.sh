#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

RANDOM_NUMBER=$(( RANDOM % 1000 ))

echo "Enter your username:"
read NAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME'")
if [[ -z $USER_ID ]]
then
echo -e "\nWelcome, $NAME! It looks like this is your first time here.\n"
else
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
echo -e "\nWelcome back, $NAME! You have played $(echo $GAMES_PLAYED | sed -E 's/^ *| *$//g') games, and your best game took $(echo $BEST_GAME | sed -E 's/^ *| *$//g') guesses.\n"
fi
echo "Guess the secret number between 1 and 1000:"
read NUMBER
NUMBER_CHECKER() {
echo $1
read NUMBER
}
NUMBER_OF_GUESSES=1
while [[ $NUMBER -ne $RANDOM_NUMBER ]]
do
NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
if [[ $NUMBER =~ ^[0-9]+$ ]]
then
if [[ $NUMBER -gt $RANDOM_NUMBER ]]
then
NUMBER_CHECKER "It's lower than that, guess again:"
else
NUMBER_CHECKER "It's higher than that, guess again:"
fi
else
NUMBER_CHECKER "That is not an integer, guess again:"
fi
done
if [[ -z $USER_ID ]]
then
INSERT_USER_DATA=$($PSQL "INSERT INTO users(name,games_played,best_game) VALUES('$NAME',1,$NUMBER_OF_GUESSES)")
else
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
if [[ $BEST_GAME -gt $NUMBER_OF_GUESSES ]]
then
BEST_GAME=$NUMBER_OF_GUESSES
fi
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=games_played+1 WHERE user_id=$USER_ID")
UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$BEST_GAME WHERE user_id=$USER_ID")
fi
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
