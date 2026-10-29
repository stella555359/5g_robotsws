*** Settings ***
Documentation    RestApi for CB011146_SR_D

Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/BTS_log_level.robot


*** Variables ***
${cmd_token_user_begin}    curl https://192.168.255.129/ext/api/auth/v1/login -k -X POST -H "Accept: application/json" -H "Content-
${cmd_token_user_end}    Type: application/json" -H "Authorization: Basic

${cmd_start_cell}   curl https://192.168.255.129/ext/api/sm/v1/cells -k -X GET -H "Accept: application/json" -H "Content-Type: application/json"
...    -H "Authorization: Bearer
${cmd_end}     " -d '{ "readOnlyMode": false }' -i -w "\nHTTP Status: '%'{http_code}\n"


${BTS_Security_Administrator}    QlRTU2VjdXJpdHk6TmVtdUAxMjM=
${BTS_Application}    QlRTQXBwbGljYXRpb246TmVtdUAxMjM=
${BTS_Read_Only}     QlRTUmVhZDpOZW11QDEyMw==

${BTS_User_Passwd}    Nemu@123

${gsm}    gsm
${lte}    lte
*** Keywords ***
TC__LOGS__CB011146_D_SR_Rest_API_get_CellStatus_otherUser

    Step 0: Preconditions
    Step 1: Activate BTS Users
    Step 2: Get Cell List
    Step 3: Get Cell with token and compare    ${BTS_Security_Administrator}
    Step 4: Get Cell with token and compare    ${BTS_Application}
    Step 5: Get Cell with token and compare    ${BTS_Read_Only}


Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    \nStep 0: Preconditions    console=${True}
    sleep    4

    ${btsid}   bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}    ${btsid}

## actCli should be TRUE

    coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actCli  operation=update  value=true  skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds  15m  30s  pm_logs_general.Check All Modules And All Cells Working States

Step 1: Activate BTS Users

        Log  \nStep 1: Activate BTS Users  console=true

    Setup Local user account    account_type=BTSSecurity    new_password=${BTS_User_Passwd}
    Setup Local user account    account_type=BTSApplication    new_password=${BTS_User_Passwd}
    Setup Local user account    account_type=BTSRead    new_password=${BTS_User_Passwd}


Step 2: Get Cell List
    [Documentation]
    ...   In this step existing NRCELL, GNCELL, WNCELL and LNCELL are checked

    Log    \nStep 2: Get Cell List    console=${True}
#    sleep    4

    ### 1.GNCELL
    ${i}  evaluate  0
    ${cell_info}=    coam.get_cells_info    cell_type=${gsm}    timeout=60    #connection=${GNB_DU.oam.httpAlias}

    FOR    ${cell}    IN    @{cell_info}
#
        Set Test Variable    ${id_${gsm}_${i}}    ${cell}[id][configuration]
#        Set Test Variable    ${name_${gsm}_${i}}    ${cell}[cellName]
#        Set Test Variable    ${dist_names}    ${cell}[dist_names][config]
        Set Test Variable    ${operational_state_${gsm}_${i}}    ${cell}[status][operationalState]
        Set Test Variable    ${administrative_state_${gsm}_${i}}    ${cell}[status][administrativeState]
#        Set Test Variable    ${availability_status}    ${cell}[availability_status]
        ${i}  evaluate  ${i} + 1
    END
    Set Test Variable    ${i}

    ### 2.LNCELL
    ${j}  evaluate  0
    ${cell_info}=    coam.get_cells_info    cell_type=${lte}    timeout=60    #connection=${GNB_DU.oam.httpAlias}
#    Dated log      =======> Current cell(s) info is ${cell_info}
    FOR    ${cell}    IN    @{cell_info}

#    ${cell_info}=    set variable   ${cell_info[${cell_id}]['status']}
#        Should be equal    ${elem['status']['operationalState']}    Enabled    ignore_case=true
#        Should be equal    ${elem['status']['proceduralStatus']}    configured    ignore_case=true
#        Should be equal    ${elem['status']['administrativeState']}    Unlocked    ignore_case=true
        Set Test Variable    ${id_${lte}_${j}}    ${cell}[id][configuration]
        Set Test Variable    ${name_${lte}_${j}}    ${cell}[cellName]
#        Set Test Variable    ${dist_names}    ${cell}[dist_names][config]
        Set Test Variable    ${operational_state_${lte}_${j}}    ${cell}[status][operationalState]
        Set Test Variable    ${administrative_state_${lte}_${j}}    ${cell}[status][administrativeState]
#        Set Test Variable    ${availability_status}    ${cell}[availability_status]
        ${j}  evaluate  ${j} + 1
    END
    Set Test Variable    ${j}

Step 3: Get Cell with token and compare
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    \nStep 3: Get Cell with token and compare    console=${True}
    [Arguments]    ${BTS_user}
    Get Cell with token and compare   ${BTS_user}

Step 4: Get Cell with token and compare
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    \nStep 4: Get Cell with token and compare    console=${True}
    [Arguments]    ${BTS_user}
    Get Cell with token and compare   ${BTS_user}

Step 5: Get Cell with token and compare
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    \nStep 5: Get Cell with token and compare    console=${True}
    [Arguments]    ${BTS_user}
    Get Cell with token and compare   ${BTS_user}

Get Cell with token and compare

    [Arguments]    ${BTS_user}

    ${cmd_token}   Set Variable   ${cmd_token_user_begin}${cmd_token_user_end} ${BTS_user}"
#    ${cmd_token}   Set Variable   ${cmd_token_user_begin} ${BTS_user}"
    log to console    comandatoken:${cmd_token}


    ${output_token}    Run    ${cmd_token}
    Should contain    ${output_token}    "token":
    ${out}    Fetch From Right    ${output_token}    token":"
    ${token}    Fetch From Left    ${out}    ","type

    ### Concatenate commnad with token
    ${cmd_getcells}    Set Variable    ${cmd_start_cell} ${token}${cmd_end}
    ${output_cells}    Run    ${cmd_getcells}


    #### Check content

    FOR  ${a}  IN RANGE  0    ${i}-1

        Should contain    ${output_cells}     ${id_${gsm}_${a}}
        Should contain    ${output_cells}     ${operational_state_${gsm}_${a}}
        Should contain    ${output_cells}     "administrativeState" : "${administrative_state_${gsm}_${a}}"
    END


    FOR  ${b}  IN RANGE  0    ${j}-1

        Should contain    ${output_cells}     ${id_${lte}_${b}}
        Should contain    ${output_cells}     ${name_${lte}_${b}}
        Should contain    ${output_cells}     ${operational_state_${lte}_${b}}
        Should contain    ${output_cells}     "administrativeState" : "${administrative_state_${lte}_${b}}"
    END



TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
