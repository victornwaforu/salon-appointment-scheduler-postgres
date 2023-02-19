#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# display title and header
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to MY SALON. Please select your preferred service identification number.\n"

# display numbered list of services
DISPLAY_SERVICES () {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  #get services offered from the database
  SERVICES_OFFERED=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}
DISPLAY_SERVICES

# get input from customer
read SERVICE_ID_SELECTED

#creating service name and service ID variables
SERVICE_NAME=$($PSQL "SELECT name from services WHERE service_id = '$SERVICE_ID_SELECTED'")
SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

#if service ID selected is not a number
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  # return to service menu
  DISPLAY_SERVICES "Wrong input. That is not a number, please select a valid service identification number"
fi

# If a service that doesn't exist is selected
if [[ -z $SERVICE_ID ]]
then
  DISPLAY_SERVICES "There is no service here. Please select a valid service identification number."
else
  # ask for phone number
  echo -e "\nPlease enter your phone number."
  read CUSTOMER_PHONE
  
  # check if name is in the database
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        
  # if name number not in database
  if [[ -z $CUSTOMER_NAME ]]
  then
    # request for the customer's name
    echo -e "\nI don't have a record for that phone number, please input your name?"
    read CUSTOMER_NAME
    # insert new customer to the database
    NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  # request for suitable time of service
  echo -e "\nPlease input a suitable time for your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
  read SERVICE_TIME

  if [[ $SERVICE_TIME ]]
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  then
    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES('$SERVICE_ID_SELECTED', '$CUSTOMER_ID', '$SERVICE_TIME')")
    # when appointment is inserted successfully
    if [[ $NEW_APPOINTMENT=='INSERT 0 1' ]]
    then
      echo "I have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
    fi  
  fi
fi
