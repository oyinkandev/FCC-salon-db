#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~ My Salon ~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

CUSTOMER_NAME=""
CUSTOMER_PHONE=""

CREATE_APPOINTMENT() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  CUST_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//')
  CUST_NAME_FORMATTED=$(echo $CUST_NAME | sed 's/^ *//;s/ *$//')
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUST_NAME_FORMATTED?"
  read SERVICE_TIME
  INSERTED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUST_NAME_FORMATTED."
}

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  while true; do
    # Display services
    SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do 
      echo "$SERVICE_ID) $NAME Services"
    done
    
    # Prompt for service selection
    read SERVICE_ID_SELECTED

    # Check if service exists
    HAVE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -n $HAVE_SERVICE ]]
    then
      break
    else
      echo -e "\nI could not find that service. What would you like today?"
    fi
  done

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  HAVE_CUST=$($PSQL "SELECT customer_id, name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $HAVE_CUST ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERTED=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CREATE_APPOINTMENT
  else
    CREATE_APPOINTMENT
  fi
}

MAIN_MENU
