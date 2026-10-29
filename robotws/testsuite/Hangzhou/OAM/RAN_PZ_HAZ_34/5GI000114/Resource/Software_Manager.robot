*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Library    BuiltIn
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact

*** Variables ***
${general_data_table}   //table[@id='frmTaskDetails:taskGeneral']

*** Keyword ***
