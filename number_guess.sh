#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo Enter your username:
read USERNAME

#Get username from DB
DB_USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")

#Random number generatos
RANDOM_NUMBER=$((1 + RANDOM % 1000))

if [[ -z $DB_USERNAME ]]
then
#Insert new user
  INSERT_USERNAME=$($PSQL "INSERT into users(username) VALUES ('$USERNAME')");
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
 
  DB_BEST_GAME=$($PSQL "SELECT MIN(gueses) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")  
  DB_GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")  

  echo "Welcome back, $USERNAME! You have played $DB_GAMES_PLAYED games, and your best game took $DB_BEST_GAME guesses."
fi
  echo -e "\nGuess the secret number between 1 and 1000:"
  NUMBER_GUESS=0;
  while :
  do
      read -p "" GUESS_NUMBER
      if [[ $GUESS_NUMBER =~ ^[0-9]+$ ]]
      then
        if [[ $RANDOM_NUMBER -gt $GUESS_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          (( NUMBER_GUESS = NUMBER_GUESS + 1 ))
        elif [[ $RANDOM_NUMBER -lt $GUESS_NUMBER ]]
        then
          echo "It's lower than that, guess again:"
          (( NUMBER_GUESS = NUMBER_GUESS + 1 ))
        else
          echo "Congratulations! You guessed the correct number."
          (( NUMBER_GUESS = NUMBER_GUESS + 1 ))
          break
        fi
    else
      echo "That is not an integer, guess again:"
    fi
  done
  echo "You guessed it in $NUMBER_GUESS tries. The secret number was $RANDOM_NUMBER. Nice job!"
  #Get user ID
  GET_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  INSERT_GUESES=$($PSQL "INSERT INTO games (gueses, user_id) VALUES ($NUMBER_GUESS, $GET_USER_ID) ")

