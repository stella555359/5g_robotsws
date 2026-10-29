#!/bin/bash

package_count=$(pip list | wc -l)
if [[ $package_count -le 400 ]]; then
  echo "Error: Enter pyenv where you have installed libs firs! In current env: $package_count libs avaliable" >&2
  return 0
fi
cd /home/ute/MN/UTE/robotws

# Ustaw sciezke do folderu z plikami robot
robotws="/home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T05/CloudRAN/CRT"
robot_files=("$robotws"/*.robot)
robot_folder=$robotws
ls -al $robotws | grep ".robot"
sleep 2s

# ======= WYBIERANIE SUITY =======
# Zainicjuj tablice, aby przechowywac tylko nazwy plików bez sciezek i rozszerzen
options=()
for file in "${robot_files[@]}"; do
  filename=$(basename "$file")
  options+=("$filename" "")
done

# Uzyj dialog --menu do wyswietlenia dostepnych opcji uzytkownikowi
selected=$(dialog --extra-button --extra-label "Advanced run.." --menu "Choose test suite to run: ~/${robot_folder#"/home/ute/"}/" 20 70 10 "${options[@]}" 2>&1 >/dev/tty)

# Sprawdz, wybor uzytkownika
exit_code=$?
robot_suite=$robot_folder/$selected

if [ "$exit_code" -eq 1 ] || [ "$exit_code" -eq 255 ]; then
  clear
  echo "Operation terminated by user!"
  return 0
elif [ "$exit_code" -eq 3 ]; then
  # Odpal advanced run

  # ======= WYBIERANIE KONKRETNYCH TC =======
  # Utwórz liste z TCami
  lista_tc=()
  czyIgnoruj=true

  while IFS= read -r linia; do
    if [ -n "$linia" ]; then
      if [[ "$linia" =~ \*\*\*[\[:space:]]*Test[[:space:]]*Cases[\[:space:]]*\*\*\* ]]; then
        czyIgnoruj=false
      elif [[ "$linia" =~ \*\*\*[\[:space:]]*Keywords[\[:space:]]*\*\*\* ]]; then
        break;
      elif [ "$czyIgnoruj" = false ]; then
        if [[ ! "$linia" =~ ^[[:space:]]+ && ! "$linia" =~ ^\# ]]; then
          lista_tc+=("$linia")
        fi
      fi
    fi
  done <"$robot_suite"

  # Utworzenie tablicy do checklisty
  checklist_select=()
  checklist_deselect=()
  for element in "${lista_tc[@]}"; do
    checklist_select+=("$element" "" on)
    checklist_deselect+=("$element" "" off)
  done

  echo $lista_tc

  # Wyswietlenie checklisty za pomoca dialog
  checklist=("${checklist_select[@]}")
  label="Deselect All"
  switch_flag=true

  while true; do
    choosen_tc=$(dialog --extra-button --extra-label "$label" --checklist "Choose $selected TC's to run:" 20 70 15 "${checklist[@]}" 2>&1 >/dev/tty)
    exit_code=$?

    if [ "$exit_code" -eq 3 ]; then
      # Wybranie select/deselect all
      echo "3rd button pressed!"
      echo "flag: " $switch_flag
      if [ "$switch_flag" == "true" ]; then
        checklist=("${checklist_deselect[@]}")
        label="Select All"
        switch_flag=false
      else
        echo "enter if!"
        checklist=("${checklist_select[@]}")
        label="Deselect All"
        switch_flag=true
      fi
    elif [ "$exit_code" -eq 1 ] || [ "$exit_code" -eq 255 ]; then
      clear
      echo "Operation terminated by user!"
      return 0
    else
      # Zatwierdzenie wybranych TC
      # Sprawdzenie czy wybrano min 1 tc
      if [ -z $choosen_tc ]; then
        dialog --msgbox "You have not chosen any TC, nothing to run!" 0 0
        continue
      fi
      # Wywolanie okna dodatkowych przelacznikow -i/-e/--variable etc.
      additional_tags=$(dialog --inputbox "(Optional) Provide additional options like:\n  -i or --include TAG\n  -e or --exclude TAG\n  --variable VARIABLE_NAME:value\n  --variablefile /dir/to/__init__.py\n  --dryrun\n\nnote: TAGS can be combined with AND, OR and NOT statements\ni.e.  --include xxANDyyNOTzz - run xx and yy but don't run zz" 20 70 2>&1 >/dev/tty)
      exit_code=$?

      if [ "$exit_code" -eq 1 ] || [ "$exit_code" -eq 255 ]; then
        clear
        echo "Operation terminated by user!"
        return 0
      fi

      current_date=$(date +"%Y%m%d-%H%M")

      IFS=" " read -ra testcases <<<"$choosen_tc"
      if [ ${#testcases[@]} == ${#lista_tc[@]} ]; then
        clear
        echo "Starting $robot_suite"
        robot $additional_tags -l ${current_date}_log.html -L TRACE -b debug.log $robot_suite
        (google-chrome ${robot_folder%%/testsuite*}/${current_date}_log.html --ignore-certificate-errors &> /dev/null &)
      else
        clear
        echo "Starting ${#testcases[@]} TC from $robot_suite"
        cmd_options=""
        for tc in ${testcases[@]}; do
          cmd_options+=" -t $tc"
        done
        robot $additional_tags -l ${current_date}_log.html -L TRACE -b debug.log $cmd_options $robot_suite
        (google-chrome ${robot_folder%%/testsuite*}/${current_date}_log.html --ignore-certificate-errors &> /dev/null &)
      fi
      return 0
    fi
  done

else
  clear
  echo "Starting $robot_suite"
  robot -l ${current_date}_log.html -L TRACE -b debug.log $robot_suite
  (google-chrome ${robot_folder%%/testsuite*}/${current_date}_log.html --ignore-certificate-errors &> /dev/null &)
  return 0
fi