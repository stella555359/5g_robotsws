*** Settings ***
Documentation   TC to report TC result to reporting portal
...             input parameters are stored in CSV CSV_file
...             template csv file is stored in this folder as report2rp.csv
...             input parameter is CSV_filename
...             return value is link to reportingportal entry

Library         report2rp.py

*** Test Cases ***
Run Reporting
    ${rp_link}=  Report2rp  ${CSV_filename}
    Log To Console  \nlink to reportingportal report: \n${rp_link}

