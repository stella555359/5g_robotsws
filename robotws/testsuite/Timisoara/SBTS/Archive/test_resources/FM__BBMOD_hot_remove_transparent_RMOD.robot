*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${BBMOD_L_DIST_NAME}     /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1
&{pdu_dict}   IP=10.255.1.9  TYPE=EPC
&{BBMOD_NK170231180}  OUTLET=10  CONTACTOR=NORMALLY_OPEN  &{pdu_dict}
&{BBMOD_AS171630802}  OUTLET=11  CONTACTOR=NORMALLY_OPEN  &{pdu_dict}
&{BBMOD_AS171630739}  OUTLET=12  CONTACTOR=NORMALLY_OPEN  &{pdu_dict}

*** Keywords ***
TC__FM__BBMOD_hot_remove_transparent_RMOD
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14628
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case addresses SBTS functioning in case of FSMr3 LTE RAT baseband (BBMOD) subunit removal while at least
    ...  one RMOD connected to its port(s) supports cells assigned to built-in FSP or other FSP (BBMOD).
	...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14628 - Initial TAT creation
    ...  - 08.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19654 - Collect Keyword Result on RMOD not finished within timeout 300s
    ...  - 12.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21215 - Update FM TC's accordingly with CNI-64164
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 10.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22451 - Fix for path to _A object
    ...  - 26.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22490 - Dictonary keyword fix
    ...  - 09.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22596 - RF module alarm cancel fault 1907 fails due to missing CONF_REF-1
    ...  - 09.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22211 - Ute cloud: Interface not defined in interfaces.yaml
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-marcin.skop@nokia.com
    ...    MAINTAINER-bogdan.boldurean@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS19A
    ...    FEATURE-RP001486_CNI-7599    FEATURE-RP001534

    Step 0: Check All Required States
    Step 1: Power Off FBBX
    Step 2: Power On FBBX


_Power ON Target FBBX
    [Documentation]  KW introduced to turn on BBMOD PDU outlet in case the test fails before step 2.

    Log  Affected FBBX will be turned on  console=${TRUE}
    Pdu Bts Interface On  ${FBBX_IF}
    Assert Alarm Inactive  faultId=10, alarmId=7116  timeout=300

Step 0: Check All Required States
    [Documentation]  In this step validation of configuration will be performed to check if test is allowed.

    Log  \nStep0: Check all required states.  console=${TRUE}
    Run keyword if  ${tl}
    ...  Append variable to interfaces dictionary
    _Check If Configuration Is FSMF Or FSMF+FSMF
    Check commissioned technologies  LTE

    # ${BBMOD_L_DIST_NAME}=  Get FBBX Hosting LTE
    ${connector}=  Check If Any Connector Port Is Used  ${BBMOD_L_DIST_NAME}
    ${RMOD_L_OBJECT}=  Get Rmod Related To FBBX Connector  ${connector}
    ${BBMOD_SERIAL_NUMBER}  ${rmod_cells_rat}  ${bbmod_cells_rat}=  Collect Cells Deployed On Rmod And Fsp  ${RMOD_L_OBJECT}  ${BBMOD_L_DIST_NAME}
    Check FBBX Mode  ${BBMOD_SERIAL_NUMBER}  ${rmod_cells_rat}  ${bbmod_cells_rat}
    Set Test Variable  ${FBBX_IF}  BBMOD_${BBMOD_SERIAL_NUMBER}
    Set Test Variable  ${BBMOD_SERIAL_NUMBER}
    Set Test Variable  ${BBMOD_L_DIST_NAME}
    Set Test Variable  ${RMOD_L_OBJECT}
    Set Test Variable  ${RMOD_SERIAL_NUMBER}  ${RMOD_L_OBJECT.serialNumber}

    ${bts_Name} =   Infomodel Get Objects Parameter   //MRBTS_A-*  btsName
    ${mrbts} =   Infomodel Get Objects Parameter   /MRBTS-1/RAT-1/BTS_L-1  btsId

    ${bbmod_r} =  Query Infomodel  get object //BBMOD_R-* is [serialNumber=${BBMOD_SERIAL_NUMBER}]   timeout=60
    ${conf_a_str_bbmod} =  Remove String  ${bbmod_r.configDN}  _A
    ${string_bbmod} =  Fetch From Right  ${conf_a_str_bbmod}  /MRBTS-${mrbts[0]}/
    Set Test Variable  ${CONF_OBJ_BBMOD}  [${bts_Name[0]}] MRBTS-${mrbts[0]}/${string_bbmod}

    ${rmod_r} =  Query Infomodel  get object //RMOD_R-* is [serialNumber=${RMOD_SERIAL_NUMBER}]   timeout=60
    ${conf_a_rmod} =  Query Infomodel  get object ${rmod_r.configDN}   timeout=60
    ${conf_a_str_rmod} =  Remove String  ${conf_a_rmod.dist_name}  _A
    ${string_rmod} =  Fetch From Right  ${conf_a_str_rmod}  /MRBTS-${mrbts[0]}/
    Set Test Variable  ${CONF_OBJ_RMOD}  [${bts_Name[0]}] MRBTS-${mrbts[0]}/${string_rmod}

_Check If Configuration Is FSMF Or FSMF+FSMF
    [Documentation]  This KW is for checking if tested configuration is FSMF or FSMF+FSMF.

    ${configuration}=  Check System Modules Configuration In InfoModel
    ${string_configuration}=  Convert To String  ${configuration}
    Should Not Match Regexp  ${string_configuration}  4  Tested configuration is not FSMF or FSMF+FSMF. Breaking execution.

    Log  Tested configuration type: Rel${configuration}  console=${TRUE}


Step 1: Power Off FBBX
    [Documentation]  In this step, LTE-only FBBX will be hot removed.

    Log  \nStep1: Power Off FBBX.  console=${TRUE}

    Pdu BTS Interface Off  ${FBBX_IF}

    ${bbmod_r}=  Get Infomodel Object  //BBMOD_R-* is [serialNumber=${BBMOD_SERIAL_NUMBER}]
    Set Test Variable  ${BBMOD_R_DIST_NAME}  ${bbmod_r.dist_name}
    ${rmod_r}=  Get Infomodel Object  //RMOD_R-* is [serialNumber=${RMOD_L_OBJECT.serialNumber}]
    Set Test Variable  ${RMOD_R_DIST_NAME}  ${rmod_r.dist_name}

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_alarm_on_bbmod
    ${bbmod_alarm}=  Run Keyword In Background  Assert Alarm Active
    ...  parameters=severity=Critical, alarmId=7116, faultId=10, faultName="No connection to unit",
    ...  alarmAttribute[?].attributeValue=regex"${BBMOD_SERIAL_NUMBER}"  timeout=300  alias=check_alarm_on_bbmod

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_alarm_on_rmod
    ${rmod_alarm}=  Run Keyword In Background  Assert Alarm Active
    ...  parameters=severity=Major, alarmId=7116, faultId=10, faultName="No connection to unit",
    ...  alarmAttribute[?].attributeValue=regex"${RMOD_SERIAL_NUMBER}"  timeout=300  alias=check_alarm_on_rmod

    Log  Check if BBMOD has been removed by checking its states:  console=${TRUE}
    Wait Until Keyword Succeeds  90s  1s  Verify parameters  ${BBMOD_R_DIST_NAME}  operationalState=disabled

    Log  Check if RMOD connected to affected BBMOD has proper states:  console=${TRUE}
    Wait Until Keyword Succeeds  90s  1s  Verify parameters  ${RMOD_R_DIST_NAME}  operationalState=disabled

    Log  Check alarm presence on BBMOD:  console=${TRUE}
    ${alarm_on_bbmod}=  Collect Keyword Result  ${bbmod_alarm}  timeout=300
    Run Keyword if  ${alarm_on_bbmod}
    ...  Log  [ OK ]___Critical alarm 7101 with fault 10 "No connection to unit" is active on BBMOD.  console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  [ NOK ]___Critical alarm 7101 with fault 10 "No connection to unit" has not been reported on BBMOD.

    ${configObjectCheck_BBMOD} =  Run Keyword And Return Status  Assert Alarm Active   parameters=faultId=10, configObjectName="${CONF_OBJ_BBMOD}"
    ...  timeout=60
    Run Keyword if  ${configObjectCheck_BBMOD}
    ...  Log  Configuration alarming object in alarm is field correctlly: configObjectName="${CONF_OBJ_BBMOD}".  console=true
    ...  ELSE
    ...  Set Test Restriction  Configuration alarming object field in alarm is incorrect. [NOK]

    Log  Check alarm presence on RMOD:  console=${TRUE}
    ${alarm_on_rmod}=  Collect Keyword Result  ${rmod_alarm}  timeout=300
    Run Keyword if  ${alarm_on_rmod}
    ...  Log  [ OK ]___Alarm 7101 with fault 10 "No connection to unit" is active on RMOD.  console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  [ NOK ]___Alarm 7101 with fault 10 "No connection to unit" has not been reported on RMOD.

    ${configObjectCheck_RMOD} =  Run Keyword And Return Status  Assert Alarm Active   parameters=faultId=10, configObjectName="${CONF_OBJ_RMOD}"
    ...  timeout=60
    Run Keyword if  ${configObjectCheck_RMOD}
    ...  Log  Configuration alarming object in alarm is field correctlly: configObjectName="${CONF_OBJ_RMOD}".  console=true
    ...  ELSE
    ...  Set Test Restriction  Configuration alarming object field in alarm is incorrect. [NOK]

    ${rmod_cells}=  Infomodel Get Cells Deployed On RMOD  ${RMOD_L_OBJECT}
    ${bbmod_l_object}=  Get Infomodel Object  ${BBMOD_L_DIST_NAME}
    ${bbmod_and_rmod_cells}=  Infomodel Get Cells Deployed On Module  ${bbmod_l_object}
    ${unaffected_cells} =  Query Infomodel  get list //CELL_M-*
    Remove Values From List  ${unaffected_cells}  @{bbmod_and_rmod_cells}

    Log  Check affected cells handled by BBMOD:  console=${TRUE}
    Remove Values From List  ${bbmod_and_rmod_cells}  @{rmod_cells}
    FOR  ${bbmod_cell}  IN  @{bbmod_and_rmod_cells}
        Infomodel Cell Should Be Failed  ${bbmod_cell}
    END

    Log  Check affected cells handled by RMOD:  console=${TRUE}
    FOR  ${rmod_cell}  IN  @{rmod_cells}
        ${has_pair} =  Infomodel Cell Has At Least One Operational RXTX Pair  ${rmod_cell}
        Run Keyword If  ${has_pair}  Infomodel Cell Should Be Degraded  ${rmod_cell}
        ...  ELSE  Infomodel Cell Should Be Failed  ${rmod_cell}
    END

    Log  Check if unaffected cells are online:  console=${TRUE}
    FOR  ${unaffected_cell}  IN  @{unaffected_cells}
        Infomodel Cell Should Be Online  ${unaffected_cell}
    END


Step 2: Power On FBBX
    [Documentation]  In this step, selected LTE FBBX will be reinserted.

    Log  \nStep2: Power On FBBX.  console=${TRUE}

    Pdu BTS Interface On  ${FBBX_IF}

    Log  Check if BBMOD has been inserted by checking its states:  console=${TRUE}
    Wait Until Keyword Succeeds  240s  10s  Verify parameters  ${BBMOD_R_DIST_NAME}  operationalState=enabled

    Log  Check if RMOD connected to affected BBMOD has proper states:  console=${TRUE}
    Wait Until Keyword Succeeds  240s  10s  Verify parameters  ${RMOD_R_DIST_NAME}  operationalState=enabled

    _Check If Alarm 7116 Is Inactive  ${BBMOD_R_DIST_NAME}  ${BBMOD_SERIAL_NUMBER}
    _Check If Alarm 7116 Is Inactive  ${RMOD_R_DIST_NAME}  ${RMOD_SERIAL_NUMBER}

    Log  Check all cells status:  console=${TRUE}
    ${all_cells_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  360  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run Keyword If  ${all_cells_status}
    ...  Log  [ OK ]___All cells are on air - test succedeed  console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  [ NOK ]___Some cells are not on air - test failed

_Check If Alarm 7116 Is Inactive
    [Documentation]  Helper for checking if alarm on specific alarming object has been cleared.
    [Arguments]  ${object_r_dist_name}  ${object_serialNumber}

    Log  Check if alarm on ${object_r_dist_name} has been cleared:  console=${TRUE}
    ${alarm_status}=  Run Keyword And Return Status  Assert Alarm Inactive  severity=Critical, faultId=10, alarmId=7116,
    ...  alarmAttribute[?].attributeValue=regex"${object_serialNumber}"  timeout=300
    Run Keyword if  ${alarm_status}
    ...  Log  [ OK ]___Alarm 7101 with fault 10 "No connection to unit" is inctive on ${object_r_dist_name}  console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  [ NOK ]___Alarm 7101 with fault 10 "No connection to unit" is still active on ${object_r_dist_name}  fail_fast=${TRUE}

Append variable to interfaces dictionary
    Log  Test variable to interfaces.  console=true
    Add variables in interfaces   BBMOD_NK170231180  ${BBMOD_NK170231180}
    Add variables in interfaces   BBMOD_AS171630802  ${BBMOD_AS171630802}
    Add variables in interfaces   BBMOD_AS171630739  ${BBMOD_AS171630739}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords    _Power ON Target FBBX    AND    Common Test Teardown    AND    Teardown All Aliases For Admin


