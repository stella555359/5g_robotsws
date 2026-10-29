*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot
Library    ute_async

*** Variables ***
${RECOVERY_TIMEOUT}   300


*** Keywords ***
TC__FM__BBMOD_hot_remove_local_RMOD_F
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14627
    ...  This test case is created to verify the LTE BBMOD hot remove functionality introduced by RP001486_CNI-7599.
	...  BBMOD hot remove/insert is performed by PDU outlet power off and power on.
    ...  Affected and unaffected cells are verified against infomodel states. Reported alarm is checked.
     ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14627 - Initial TAT creation
    ...  - 24.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-17000 - Minor code fix
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-piotr.szlegel@nokia.com
    ...    MAINTAINER-bogdan.boldurean@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS19A
    ...    FEATURE-RP001486_CNI-7599    FEATURE-RP001534

    Step_0: Check All Required States
    Step_1: Power Off FBBX
    Step_2: Power On FBBX


Step_0: Check All Required States
    [Documentation]  To check if tested system module is FSMr3. Checl all required technologies.
    ...  This part check FBBX hosting LTE, pluged RMOD to FBBX with located carries. Also check if RMOD conncted to FBBX is in local mode.

    Check commissioned technologies  LTE
    Check If Configuration Is FSMF or FSMF+FSMF
    ${BBMOD}=  Get FBBX Hosting LTE
    ${connector}=  Check If Any Connector Port Is Used  ${BBMOD}
    ${RMOD_L_OBJECT}=  Get Rmod Related To FBBX Connector  ${connector}
    ${SELECTED_FBBX_SN}  ${rmod_cells_rat}  ${fsp_cells_rat}=  Collect Cells Deployed On Rmod And Fsp  ${RMOD_L_OBJECT}  ${BBMOD}
    Check FBBX Mode  ${SELECTED_FBBX_SN}  ${rmod_cells_rat}  ${fsp_cells_rat}
    Set Test Variable  ${BBMOD}
    Set Test Variable  ${RMOD_L_OBJECT}
    Set Test Variable  ${RMOD_SN}  ${RMOD_L_OBJECT.serialNumber}
    Set test Variable  ${SELECTED_FBBX_SN}

Check If Configuration Is FSMF or FSMF+FSMF
    [Documentation]  This KW is for checking if tested configuration is FSMF or FSMF+FSMF.

    ${configuration}=  Check System Modules Configuration In InfoModel
    ${string_configuration}=  Convert To String  ${configuration}
    Should Not Match Regexp  ${string_configuration}  4  Tested configuration is not FSMF or FSMF+FSMF. Breaking execution.

    Log  Tested configuration type: Rel${configuration}  console=${TRUE}

Power ON Target FBBX
    [Documentation]  KW introduced to turn on BBMOD PDU outlet in case the test fails before step 2.

    Log  Affected FBBX will be turned on  console=${TRUE}
    Pdu Bts Interface On  ${BBMOD_IF}
    Assert Alarm Inactive  faultId=10, alarmId=7116  timeout=240

Step_1: Power Off FBBX
    [Documentation]  Turn off FBBX from PDU than check all required states. Check all aftected cells and their states.

    Set Test Variable  ${BBMOD_IF}  BBMOD_${SELECTED_FBBX_SN}
    Log To Console   Power Off FBBX Card
    Pdu BTS Interface Off  ${BBMOD_IF}

    ${bbmod_r}=  Get Infomodel Object  //BBMOD_R-* is [serialNumber=${SELECTED_FBBX_SN}]
    Set Test Variable  ${BBMOD_R_DIST_NAME}  ${bbmod_r.dist_name}
    ${rmod_r}=  Get Infomodel Object  //RMOD_R-* is [serialNumber=${RMOD_L_OBJECT.serialNumber}]
    Set Test Variable  ${RMOD_R_DIST_NAME}  ${rmod_r.dist_name}

    Log  Check if BBMOD has been removed by checking its states:  console=${TRUE}
    Wait Until Keyword Succeeds  90s  1s  Verify parameters  ${BBMOD_R_DIST_NAME}  operationalState=disabled

    Log  Check if RMOD connected to affected BBMOD has proper states:  console=${TRUE}
    Wait Until Keyword Succeeds  90s  1s  Verify parameters  ${RMOD_R_DIST_NAME}  operationalState=disabled

    ${BBMOD_r}=  Get Infomodel Object  //BBMOD_R-* is [serialNumber=${SELECTED_FBBX_SN}]
    set test variable  ${BBMOD_RS}  ${bbmod_r.dist_name}
    ${rmod_r}=  Get Infomodel Object  //RMOD_R-* is [serialNumber=${RMOD_SN}]
    set test variable  ${RMOD_RS}  ${rmod_r.dist_name}

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault
    ${fault_Status_bbmod}=  wait until keyword succeeds  180s  60s  Assert Alarm Active  parameters=severity=Critical, alarmId=7116,
    ...  faultId=10, faultName="No connection to unit", alarmingResource=${BBMOD_RS}  timeout=120  alias=fault
    Run Keyword if  ${fault_Status_bbmod}
    ...  Log  Fault 10 for FFBX present [OK]  console=${TRUE}
    ...  ELSE
    ...  Fail  No fault 10 [NOK]

    ${fault_Status_rmod}=  wait until keyword succeeds  180s  60s  Assert Alarm Active  parameters=severity=Critical, alarmId=7116, faultId=10,
    ...  faultName="No connection to unit", alarmingResource=${RMOD_RS}  timeout=120  alias=fault
    Run Keyword if  ${fault_Status_rmod}
    ...  Log  Fault 10 for RMOD present [OK]  console=${TRUE}
    ...  ELSE
    ...  Fail  No fault 10 [NOK]

    ${rmod_cells}=  Infomodel Get Cells Deployed On RMOD  ${RMOD_L_OBJECT}
    FOR  ${cell}  IN  @{rmod_cells}
        Infomodel Cell Should Be Failed  ${cell}
    END

    ${left_cells} =  Query Infomodel  get list //CELL_M-*
    Remove Values From List  ${left_cells}  @{rmod_cells}
    Set Suite Variable  ${left cells}
    FOR  ${im_cell}  IN  @{left_cells}
        Infomodel Cell Should Be Online  ${im_cell}
    END

Step_2: Power On FBBX
    [Documentation]  Plug in FBBX and check states to recover station.

    Pdu BTS Interface On  ${BBMOD_IF}
    Log  Power on FBBX  console=${TRUE}
    Log  Check if BBMOD has been inserted by checking its states:  console=${TRUE}
    Wait Until Keyword Succeeds  240s  10s  Verify parameters  ${BBMOD_R_DIST_NAME}  operationalState=enabled

    Log  Check if RMOD connected to affected BBMOD has proper states:  console=${TRUE}
    Wait Until Keyword Succeeds  240s  10s  Verify parameters  ${RMOD_R_DIST_NAME}  operationalState=enabled

    ${all_cells_status}=  run keyword and return status  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells  ${OnAirDone_}
    ...                   ${Enabled_}
    ...                   ${Active_}
    Run Keyword If  ${all_cells_status}
    ...  Log  All cells are on air after recovery - recovery succedeed [OK]  console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  message=Some cells status is not as expected after recovery - recovery filed [NOK]

    ${fault_Status_bbmod}=  wait until keyword succeeds  60s  5s  Assert Alarm Inactive  parameters=severity=Critical, alarmId=7116, faultId=10,
    ...  faultName="No connection to unit", alarmingResource=${BBMOD_RS}  timeout=120  alias=fault
    Run Keyword if  ${fault_Status_bbmod}
    ...  Log  Fault 10 for FFBX absent [OK]  console=${TRUE}
    ...  ELSE
    ...  Fail  Fault 10 is still active [NOK]

    ${fault_Status_rmod}=  wait until keyword succeeds  60s  5s  Assert Alarm Inactive  parameters=severity=Critical, alarmId=7116, faultId=10,
    ...  faultName="No connection to unit", alarmingResource=${RMOD_RS}  timeout=120  alias=fault
    Run Keyword if  ${fault_Status_rmod}
    ...  Log  Fault 10 for RMOD absent [OK]  console=${TRUE}
    ...  ELSE
    ...  Fail  Fault 10 is still active [NOK]


TC Setup
    Common Test Setup

TC Teardown
    Run keywords    Power ON Target FBBX    AND    Common Test Teardown    AND    Teardown All Aliases For Admin


