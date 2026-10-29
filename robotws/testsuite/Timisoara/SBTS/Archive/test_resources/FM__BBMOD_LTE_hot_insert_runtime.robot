*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
&{pdu_dict}   IP=10.255.1.9  TYPE=EPC
&{BBMOD_NK170231180}  OUTLET=10  CONTACTOR=NORMALLY_OPEN  &{pdu_dict}
&{BBMOD_AS171630802}  OUTLET=11  CONTACTOR=NORMALLY_OPEN  &{pdu_dict}
&{BBMOD_AS171630739}  OUTLET=12  CONTACTOR=NORMALLY_OPEN  &{pdu_dict}

*** Keywords ***
TC__FM__BBMOD_LTE_hot_insert_runtime
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-13825
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to verify the LTE BBMOD hot insert functionality introduced by RP001486_CNI-7599.
	...  BBMOD hot remove/insert is performed by PDU outlet power off and power on.
    ...  Affected and unaffected cells are verified against infomodel states. Reported alarm is checked.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 1.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-13825 - Initial TAT creation
    ...  - 29.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-17013 - Add change intiger to string
    ...  - 22.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19375 - Update GSM cell check acording with the RMOD connected to power off BBMOD
    ...  - 12.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21215 - Update FM TC's accordingly with CNI-64164
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 10.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22451 - Fix for path to _A object
    ...  - 26.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22491 - Fix for parameter
    ...  - 09.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22211 - Ute cloud: Interface not defined in interfaces.yaml
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-pawel.korniak@nokia.com
    ...    MAINTAINER-bogdan.boldurean@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS19A
    ...    FEATURE-RP001486_CNI-7599    FEATURE-RP001534

    Step 0: Check All Required States
    Step 1: Power Off FBBX
    Step 2: Power On FBBX


Step 0: Check All Required States
    [Documentation]  To check if LTE is commissioned and check if system module release is FSMr3.
    Log  Step 0: Check All Required States  console=${TRUE}
    Run keyword if  ${tl}
    ...  Append variable to interfaces dictionary
    Check commissioned technologies  LTE
    Check If Configuration Is FSMF Or FSMF+FSMF

Check If Configuration Is FSMF Or FSMF+FSMF
   [Documentation]  To check if tested system module configuration is FSMF or FSMF+FSMF.

    ${configuration} =  Check System Modules Configuration In InfoModel
    ${string_configuration}=  Convert To String  ${configuration}
    Should Not Match Regexp  ${string_configuration} 4  Tested module is not FSMr3. Breaking execution
    Log  Tested configuration type: Rel${configuration}  console=${TRUE}

Append variable to interfaces dictionary
    Log  Test variable to interfaces.  console=true
    Add variables in interfaces   BBMOD_NK170231180  ${BBMOD_NK170231180}
    Add variables in interfaces   BBMOD_AS171630802  ${BBMOD_AS171630802}
    Add variables in interfaces   BBMOD_AS171630739  ${BBMOD_AS171630739}

Step 1: Power Off FBBX
    [Documentation]  In this step, LTE-only FBBX will be selected and hot removed.

    Log  Step 1: Power Off FBBX  console=${TRUE}
    ${bbmod}=  Get FBBX Hosting LTE
    Set Test Variable  ${bbmod}
    Check If Any Connector Port Is Used  ${bbmod}
    ${bbmod_object}=  Query Infomodel  get object ${bbmod}
    Set Test Variable  ${FBBX_IF}  BBMOD_${bbmod_object.serialNumber}

    ${bts_Name} =   Infomodel Get Objects Parameter   //MRBTS_A-*  btsName
    ${mrbts} =   Infomodel Get Objects Parameter   /MRBTS-1/RAT-1/BTS_L-1  btsId
    ${bbmod_r} =  Query Infomodel  get object //BBMOD_R-* is [serialNumber=${bbmod_object.serialNumber}]   timeout=60
    ${conf_a_str} =  Remove String  ${bbmod_r.configDN}  _A
    ${string} =  Fetch From Right  ${conf_a_str}  /MRBTS-${mrbts[0]}/
    Set Test Variable  ${CONF_OBJ}  [${bts_Name[0]}] MRBTS-${mrbts[0]}/${string}

    Log  Power Off FBBX Card  console=${TRUE}
    Pdu BTS Interface Off  ${FBBX_IF}
    ${states}=  Catenate  stateInfo.availabilityStatus=NotInstalled, stateInfo.operationalState=Disabled,
    ...  stateInfo.reasoningStatus[0]=NoConnectionToUnit
    Wait Until Keyword Succeeds  180s  1s  Query Infomodel  get object ${bbmod}/BBU_L-1 is [${states}]

    ${bbmod_r}=  Get Infomodel Object  //BBMOD_R-* is [serialNumber=${bbmod_object.serialNumber}]
    ${bbmod_RS}=  Set Variable  ${bbmod_r.dist_name}
    ${faultStatus} =  Run Keyword And Return Status  Assert Alarm Active  parameters=severity=Critical, alarmId=7116, faultId=10,
    ...  faultName="No connection to unit", alarmingResource=${bbmod_RS}  timeout=300
    Run Keyword if  ${faultStatus}
    ...  Log  Expected fault active with : alarmId=7116, faultId=10, faultName="No connection to unit" on alarmingResource=${bbmod_RS}.  console=true
    ...  ELSE
    ...  Fail  Expected fault is not active. [NOK]

    ${configObjectCheck} =  Run Keyword And Return Status  Assert Alarm Active   parameters=faultId=10, configObjectName="${CONF_OBJ}"   timeout=60
    Run Keyword if  ${configObjectCheck}
    ...  Log  Configuration alarming object in alarm is field correctlly : configObjectName="${CONF_OBJ}".  console=true
    ...  ELSE
    ...  Set Test Restriction  Configuration alarming object field in alarm is incorrect. [NOK]

    ${fsp_cells}=  Infomodel Get Cells Deployed on FSP  ${bbmod_object}
    Sort List  ${fsp_cells}
    Set Test Variable  ${fsp_cells}
    Check FSP Cell Statuses
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Assert Every    WNCEL    operationalState=${Enabled_}  timeout=60

    ${rmod_list}  Query Infomodel  get list //RMOD_R-*
    FOR  ${rmod}  IN  @{rmod_list}
        ${status}  run keyword and return status  Query Infomodel  get object ${rmod.dist_name} is [availabilityStatus="not installed"]
        run keyword if  ${status}  run keywords
        ...  Log  Failed RMOD is ${rmod.dist_name}  console=true  AND  Set test variable  ${rmod.dist_name}  AND
        ...  Exit for loop
    END
    ${skip_gsm_cell_check}  Check RMOD alarm  ${rmod.dist_name}
    Run Keyword If  ${skip_gsm_cell_check}
    ...  Log  Fault found on RMOD. GSM cells check will be skipped.  console=${TRUE}
    ...  ELSE
    ...  Run Keyword If  ${SCF_COUNT_GSM}  Assert Every    GNCEL    operationalState=${Enabled_}  timeout=60
    ...  ELSE  Log  No GSM cells were found.  console=${TRUE}

Check RMOD alarm
    [Arguments]  ${RMOD_dist_name}
    ${check_RMOD_alarm}=  Run keyword and return status  Assert Alarm Active  parameters=severity=Major, alarmId=7116, faultId=10,
    ...  faultName="No connection to unit", alarmingResource="${RMOD_dist_name}"  timeout=100
    [Return]  ${check_RMOD_alarm}


Check FSP Cell Statuses
    ${fsp_cells_operational_state}=  Create List  @{EMPTY}
    ${fsp_cells_availability_status}=  Create List  @{EMPTY}
    FOR  ${cell}  IN  @{fsp_cells}
        Append To List  ${fsp_cells_operational_state}  ${cell.operationalState}
        Append To List  ${fsp_cells_availability_status}  ${cell.availabilityStatus}
    END
    Log  ${fsp_cells_operational_state} ${fsp_cells_availability_status}  console=${TRUE}
    Run Keyword And Return Status  List Should Contain Value  ${fsp_cells_operational_state}  ${Disabled_}
    Run Keyword And Return Status  List Should Contain Value  ${fsp_cells_availability_status}  ${Failed_}

Step 2: Power On FBBX
    [Documentation]  In this step, selected LTE FBBX will be reinserted.

    Log  Step 2: Power On FBBX  console=${TRUE}
    Pdu BTS Interface On  ${FBBX_IF}
    Wait Until Keyword Succeeds  180s  1s  Query Infomodel  get object ${bbmod}/BBU_L-1 is [stateInfo.availabilityStatus=Online]
    Assert Alarm Inactive   parameters=alarmId=7116, faultId=10, faultName="No connection to unit", alarmSeverity="Critical"   timeout=300
    Wait Until Keyword Succeeds  600  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}


TC Setup
    Common Test Setup

TC Teardown
    Run keyword if test failed  Run Keyword And Ignore Error  Pdu BTS Interface On  ${FBBX_IF}
    Common Test Teardown


