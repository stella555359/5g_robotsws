*** Settings ***
Documentation
...   author:  Iuliia Taupeka
...   contact: iuliia.taupeka@nokia.com

Library     BuiltIn
Library     DateTime
Library     Collections
Library     String
Library     OperatingSystem
Library     taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library     utils.py
Resource    ../../Resources/common_keywords.robot
Resource    ../../Resources/common_logging.robot
Resource    ../../Resources/aic_common_resources_new.robot
Resource    ../../Resources/cu_trs_conn.robot
Resource    ../../Resources/cu_cloud_deployment.robot
Resource    ../../Resources/cu_cloud_recovery.robot
Resource    ../../Resources/vdu_oam_state.robot


*** Variables ***
${TIMEOUT}        1200
${INTERVAL}       30
${VCU_OE_SERVER_PROMPT_TENANT}   \\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$
${VCU_CONTAINER_PROMPT}          bash-\\d\\.\\d\\$\\s

*** Keywords ***
TC__CB007800_B_CB007406_C_Cloud_CPConfig_Noncritical_Process_Container_Loop_Failure
    [Documentation]
    ...    author: iuliia.taupeka@nokia.com
    ...    history change: <date>,<who>,<what and how>
    ...    18.10.2024, iuliia.taupeka@nokia.com, TC created. version 1.0

    Step 1: Preconditions
    Step 2: Kill CPConfig Service in OAMconfig Container Without Container Reset
    Step 3: Kill CPConfig Service in OAMconfig Container And Verify Container Restart


Step 1: Preconditions
    [Documentation]
    ...  In this test step test checks CU specific pod (oamconfig) restart times and recover it if is more than 0.
    Log    Step 0: Preconditions    console=${True}
    Recovery CU Specfic Pods Restart Times If Not Equal Zero   pod_abbr=oamconfig


Step 2: Kill CPConfig Service in OAMconfig Container Without Container Reset
    [Documentation]
    ...    In this test step test kills CPCONFIG process inside oamconfig comtainer for 5 times
    ...    and verifies that container restart did not happen.
    Log    Step 2: Kill CPConfig Service in OAMconfig Container Without Container Reset    console=${True}
    Repeat Keyword    5 times    Trigger CPConfig container loop failure


Step 3: Kill CPConfig Service in OAMconfig Container And Verify Container Restart
    [Documentation]
    ...    In this test step test kills CPCONFIG process inside oamconfig comtainer for 1 more time
    ...    and verifies that container restart happened.
    Log    Step 3: Kill CPConfig Service in OAMconfig Container And Verify Container Restart    console=${True}
    Trigger CPConfig container loop failure    1
    #jk check if reset
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info  ${EMPTY}   ${EMPTY}   oamconfig
    ${current_num}=  _Get vCU Specified Active Pod Container Restart Times  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}
    Run Keyword IF    ${current_num} == 1
    ...  Log to console    Pod reset done !!
    ...  ELSE    Fail    pod didnt reset !!


Trigger CPConfig container loop failure
     [Arguments]    ${ctr_restart_times}=0
     Kill the oamconfig container    ${ctr_restart_times}
     Check vCU Pods and Containers Status

Check vCU Pods and Containers Status
    log to console    Check vCU Pods and Containers Status
    wait until keyword succeeds    1min    10s    Check vCU Pods and Containers Status With Tenant
    wait until keyword succeeds    15min    30s    vDU Verify All Cells Status Should Be Onair

Kill the oamconfig container
    [Arguments]    ${ctr_restart_times}=0
    Log  Kill the oamconfig container    console=${True}
    ${oamconfig_conn} =  Connect To CU K8S Master With Admin
    Trigger CU Process Recovery     pod_abbr=oamconfig   container=oamconfig  process=CPCONFIG
    ...   alias=${oamconfig_conn}
    Sleep    5s
    ${current_num}=  _Get vCU Specified Active Pod Container Restart Times  pod_abbr=oamconfig
    Should Be Equal   ${current_num}   ${ctr_restart_times}
    Check vCU Not Happen Site Reset
    [Teardown]   aic_common_resources_new.Close Interactive Connection   ${oamconfig_conn}
