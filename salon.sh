#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

list_services() {
$PSQL "select * from services" | while IFS='|' read -r service_id service
do
  echo "$service_id) $service"
done
}

create_appointment() {
  SERVICE_ID_SELECTED=$1
  service=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED;")
  #read number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  customer_id=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")
  #check if number exist
  if [[ -z $customer_id ]]
  #if not ask about name
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    #read name
    read CUSTOMER_NAME
    #save customer
    result=$($PSQL "insert into customers(name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    customer_id=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")
  fi
    CUSTOMER_NAME=$($PSQL "select name from customers where customer_id = $customer_id")
    #if yes 
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    #read time
    read SERVICE_TIME
    #save appointment
    result=$($PSQL "insert into appointments(customer_id, service_id, time) values ($customer_id, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    echo -e "\nI have put you down for a $service at $SERVICE_TIME, $CUSTOMER_NAME."
}

select_service() {
  if [[ -n $1 ]] 
  then
    echo $($PSQL "select service_id from services where service_id = $1")
  fi
}

main_menu() {
local services_count=$($PSQL "select count(*) from services")
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

list_services

read SERVICE_ID_SELECTED 
service_id=$(select_service $SERVICE_ID_SELECTED)

while [[ -z $service_id  ]] 
do
  echo -e "\nI could not find that service. What would you like today?"
  list_services
  read SERVICE_ID_SELECTED
  service_id=$(select_service $SERVICE_ID_SELECTED)
done
  create_appointment $SERVICE_ID_SELECTED 
}

main_menu