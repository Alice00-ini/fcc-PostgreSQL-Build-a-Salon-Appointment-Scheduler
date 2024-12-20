#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  HAVE_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  HAVE_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  if [[ -z $HAVE_SERVICE_ID ]]
  then 
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ //g')
    
    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then 
      # get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ //g')
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")      
      
      echo -e "\nWhat time would you like your$HAVE_SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      # insert new appointment
      INSERT_APPOINMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a$HAVE_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    
  fi
  
#   case $SERVICE_SELECTION in
#     1) cut ;;
#     2) color ;;
#     3) perm ;;
#     4) style ;;
#     5) trim ;;
#     *) MAIN_MENU "I could not find that service. What would you like today?" ;;
# esac


}

MAIN_MENU
