*** Settings ***
Library    ta_messaging
Library    OperatingSystem
Library    String
Library    taf.gnb.oam.coam.vdu.interface.Vdu  WITH NAME  admin_du
Library    taf.gnb.oam.coam.cu.interface.cu  WITH NAME  admin_cu
Library     ./common_keywords_vran.py

Documentation
...    This file contains general keywords used for activating delta files on Cloud TL.

*** Variables ***
${vCU_admin}                192.168.100.129
${vDU_admin}                192.168.255.129
${PORT}                     443
${USERNAME}                 Nemuadmin
${PASSWORD}                 Nokia@123

*** Keywords ***
Send XML CU Delta Commisioning
    [Arguments]    ${delta_vcu}
    Log to console    Sending vCU Delta Commissioning
    vcu_cm.Fast Delta Commissioning With Delta XML File     ${delta_vcu}

Send XML DU Delta Commisioning
    [Arguments]    ${delta_vdu}
    Log to console    Sending vDU Delta Commissioning
    vdu_cm.Fast Delta Commissioning With Delta XML File     ${delta_vdu}

Perform DU Delta Commissioning
    [Arguments]    ${delta_vdu}
    Log to console    Sending vDU Delta Commissioning
    Wait Until Keyword Succeeds    5min    30s    admin_du.Connect to  host=${vDU_admin}
    ...    port=${PORT}  username=${USERNAME}  password=${PASSWORD}  secure=True

    admin_du.Perform Delta Recommissioning
    ...    delta_file=${delta_vdu}
    ...    timeout=300
    ...    wait_for_completion=True

Perform CU Delta Commissioning
    [Arguments]    ${delta_vcu}
    Log to console    Sending vCU Delta Commissioning
    Wait Until Keyword Succeeds    5min    30s    admin_cu.Connect to  host=${vCU_admin}
    ...    port=${PORT}  username=${USERNAME}  password=${PASSWORD}  secure=True

    admin_cu.Perform Delta Recommissioning
    ...    delta_file=${delta_vcu}
    ...    timeout=300
    ...    wait_for_completion=True