*** Settings ***
Documentation    Test cases for CB011146 SR get cell info via new API with token
#Library     ../python_resources/admin_cli/hran_admin_cli.py  WITH NAME  hran_admin_cli
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam

*** Variables ***
${cmd_token}    curl https://192.168.255.129/ext/api/auth/v1/login -k -X POST -H "Accept: application/json" -H "Content-Type: application/json"
...    -H "Authorization: Basic TmVtdWFkbWluOm5lbXV1c2Vy" -d '{ "readOnlyMode": false }' -i -w "\nHTTP Status: '%'{http_code}\n"

${cmd_start_cell}   curl https://192.168.255.129/ext/api/sm/v1/cells -k -X GET -H "Accept: application/json" -H "Content-Type: application/json"
...    -H "Authorization: Bearer

${cmd_end}     " -d '{ "readOnlyMode": false }' -i -w "\nHTTP Status: '%'{http_code}\n"

${gsm}    gsm
${lte}    lte
*** Keywords ***
TC__LOGS__CB011146_D_SR_Rest_API_get_CellStatus

    Step 0: Preconditions
    Step 1: Get Cell List
    Step 2: Get Cell with token and compare

#    Step 3: Get RMOD Status


Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    \nStep 0: Preconditions    console=${True}
    sleep    4

    ${btsid}   bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}    ${btsid}

#    ${cell_info}    admin.Get Cells Info

Step 1: Get Cell List
    [Documentation]
    ...   In this step GNCELL, WNCELL and LNCELL are checked

    Log    \nStep 1: Get Cell List    console=${True}
#    sleep    4

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

    ### 1.LNCELL
#    ${cell_LNCEL_list}=    coam.Get Ids For All    LNCEL   timeout=120
#    ${list_with_LNCEL_number_id}=    Create list
#    FOR  ${lncel_cell}  IN  @{cell_LNCEL_list}
#         ${LNCEL_cell_number}    Fetch From Right  ${lncel_cell}  -
#         Append To List    ${list_with_LNCEL_number_id}    ${LNCEL_cell_number}
#    END

#    FOR  ${cell}  IN   @{cell_LNCEL_list}
#        Set Test Variable    ${id}    ${cell}[0]
#        Set Test Variable    ${name}    ${cell}[1]
#        Set Test Variable    ${dist_names}    ${cell}[dist_names][config]
#        Set Test Variable    ${operational_state}    ${cell}[operational_state]
#        Set Test Variable    ${administrative_state}    ${cell}[administrative_state]
#        Set Test Variable    ${availability_status}    ${cell}[availability_status]
#    END

#    ${isEmpty}  Get length  ${list_with_LNCEL_number_id}
#    Run Keyword If  ${isEmpty}!=0    Log    LNCELL exist
#    ...    ELSE  verdicts.Set Test Failed  TC need LTE cells  ${TRUE}


#    ### 2.WNCELL
#    ${cell_WNCEL_list}=    coam.Get Ids For All    WNCEL   timeout=120
#    ${list_with_WNCEL_number_id}=    Create list
#    FOR  ${wncel_cell}  IN  @{cell_WNCEL_list}
#         ${WNCEL_cell_number}    Fetch From Right  ${wncel_cell}  -
#         Append To List    ${list_with_WNCEL_number_id}    ${WNCEL_cell_number}
#    END
#
#    ${isEmpty}  Get length  ${list_with_WNCEL_number_id}
#    Run Keyword If  ${isEmpty}!=0    Log    WNCELL exist
#    ...    ELSE  verdicts.Set Test Failed  TC need WCDMA cells  ${TRUE}


#    ### 3.GNCEL
#    ${cell_GNCEL_list}=    coam.Get Ids For All    GNCEL   timeout=120
#    ${list_with_GNCEL_number_id}=    Create list
#    FOR  ${gncel_cell}  IN  @{cell_GNCEL_list}
#         ${GNCEL_cell_number}    Fetch From Right  ${gncel_cell}  -
#         Append To List    ${list_with_GNCEL_number_id}    ${GNCEL_cell_number}
#    END
#
#    ${isEmpty}  Get length  ${list_with_GNCEL_number_id}
#    Run Keyword If  ${isEmpty}!=0    Log    GNCELL exist
#    ...    ELSE  verdicts.Set Test Failed  TC need GSM cells  ${TRUE}

Step 2: Get Cell with token and compare
    [Documentation]
    ...   In this step necessary test variables are set.
    Log    \nStep 2: Get Cell with token and compare    console=${True}

    ${output_token}    Run    ${cmd_token}
    ${out}    Fetch From Right    ${output_token}    token":"
    ${token}    Fetch From Left    ${out}    ","type

    ### Concatenate commnad with token
    ${cmd_getcells}    Set Variable    ${cmd_start_cell} ${token}${cmd_end}
    ${output_cells}    Run    ${cmd_getcells}


    #### Check content

    log to console     Tehnology:${gsm}
    FOR  ${a}  IN RANGE  0    ${i}-1

        Should contain    ${output_cells}     ${id_${gsm}_${a}}
        Should contain    ${output_cells}     ${operational_state_${gsm}_${a}}
        Should contain    ${output_cells}     "administrativeState" : "${administrative_state_${gsm}_${a}}"
    END

    log to console     Tehnology:${lte}
    FOR  ${b}  IN RANGE  0    ${j}-1

        Should contain    ${output_cells}     ${id_${lte}_${b}}
        Should contain    ${output_cells}     ${name_${lte}_${b}}
        Should contain    ${output_cells}     ${operational_state_${lte}_${b}}
        Should contain    ${output_cells}     "administrativeState" : "${administrative_state_${lte}_${b}}"
    END
#    Should contain    ${output_cells}     ${id_${lte}}
#    Should contain    ${output_cells}     ${operational_state_${lte}}
#    Should contain    ${output_cells}     "administrativeState" : "${administrative_state_${lte}}"


Step 3: Get RMOD Status
    [Documentation]
    ...  In this step test check if supported radio from list are in available state

    Log     \nStep 3: Get RMOD Status  console=${True}
    sleep    4

    ${list_of_rmods}    coam.Get Parameters For All    RMOD

    FOR  ${radio_module}  IN  @{list_of_rmods}
        ${serial_number}    Get From Dictionary    ${radio_module}    serialNumber
        ${product_name}    Get From Dictionary    ${radio_module}    productName
        ${rmod_id}    Get From Dictionary   ${radio_module}    id
        Wait Until Keyword Succeeds    30 min    10 s    pm_logs_general.Check RMOD States  ${rmod_id}  (?i)Unlocked  (?i)Enabled
        Log    \n${product_name} with SN ${serial_number} is available    console=${TRUE}
    END


Check All Cells Working States
    [Documentation]
    ...  This keyword checks that all cells (2G, 3G and 4G) reached working status

    Run Keyword If    ${SCF_COUNT_LTE}   Run Keywords
    ...    coam.Assert Every    LNCEL    ${OnAir_LTE_cells_expected_states}
    ...    AND
    ...    coam.Assert No  LNCEL  ${DEGRADED_CELL_REGEX}

    Run Keyword If    ${SCF_COUNT_GSM}   Run Keywords
    ...    coam.Assert Every    GNCEL    ${OnAir_GSM_cells_expected_states}
    ...    AND
    ...    coam.Assert No  GNCEL  ${DEGRADED_CELL_REGEX}

    Run Keyword If    ${SCF_COUNT_WCDMA}   Run Keywords
    ...    coam.Assert Every    WNCEL    ${OnAir_WCDMA_cells_expected_states}
    ...    AND
    ...    coam.Assert No  WNCEL  ${DEGRADED_CELL_REGEX}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
