*** Settings ***
Documentation   The purpose of this test case is to verify that data transfer is decreased after cell degraded.
...    Author:        daniel.bartkowiak@nokia.com
...    Maintainer:    Daniel Bartkowiak

Resource      resources/ca_recovery.robot
Resource      ../../Resources/SiSo_L3_call.robot

*** Variables ***
${RMODS_SN}               # RUs serial number, separated by 'space'
${node}        default
@{SELECTED_CELLS}             # define list of nrCellIdentity ex. <eutranCellId_1>  <eutranCellId_2>
${CELLS_YAML_PATH}            # define cells yaml file path

*** Keywords ***
TC__SiSo_REC_LTE_Cell_Degraded_On_Two_RMODs_With_Data_Transfer
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-17275
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check whether data transfer is available on degraded LTE cell or not.
    ...  Only cells from selected RUs are going to be tested.
    ...  Interrupted RMOD is randomly selected from ${RMODS_SN}.
    ...  TC can be reused when 3xRMOD configuration
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.01.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-17275 - Initial creation
    ...  - 20.11.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-35840 - TC adaptation for L3 call proxy solution

    Set Tags    CA-REC    OWNER-daniel.bartkowiak@nokia.com    AUTHOR-daniel.bartkowiak@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    PHASE-CRT
    ...    FEATURE-CB007184
  Common Test Setup
  Logging With Timestamp
  ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
  ...  style=ONGOING
    step1: Two RMODs LTE Preconditions
    step2: Power Off RMOD LTE
    step3: Two RMODs LTE Data Transfer
    step4: Power On RMOD LTE

    [Teardown]  Run Keywords  Log to console  TC finished. Result = ${KEYWORD STATUS}
    ...  AND  Set Suite Variable  ${KEYWORD STATUS}
    ...  AND  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Recovery LTE  connection=${node}
    ...  AND  Common Test Teardown

step1: Two RMODs LTE Preconditions
    Log to console  ---------------------------------------
    Log to console  step1: Two RMODs LTE Preconditions
    Log to console  ---------------------------------------${\n}
    ${rmods_list}=  Split String  ${RMODS_SN}
    ${rmod}=  Evaluate  random.randint(0, len(${rmods_list})-1)  modules=random
    ${TESTED_RMOD_SN}=  Create List  ${rmods_list[${rmod}]}
    Set Test Variable  ${node}  ${cfg['RF_INFO']['${TESTED_RMOD_SN[0]}']['btsid']}
    ${tested_rmod_dn}=  Get RU DistName For Serial Number  rmod_sn=${rmods_list[${rmod}]}  alias=${node}
    ${TESTED_CELLS}=    admin.Get Cell Mapping By Module Id  ${tested_rmod_dn}  connection=${node}
    Preconditions For CNI-127210
    ${release}  admin.Get Sw Release Name  connection=${node}
    ${proper_sw}  Run Keyword If  "${release}"=="SBTS24R3" and ${PRECOND_FOR_CNI}
    ...  Check If Current Build Is Newer Than  SBTS24R3_ENB_0000_000602_000000  alias=${node}
    ...  ELSE IF  ${PRECOND_FOR_CNI}
    ...  Check If Current Build Is Newer Than  SBTS25R1_ENB_9999_240929_000023  alias=${node}
    Run keyword If   ${proper_sw}  Set Test Variable  ${PRECOND_FOR_CNI}  False

    Set Test Variable  ${TESTED_RMOD_SN}
    Set Test Variable  ${TESTED_CELLS}
    Log  TC preconditions finieshed successfuly  console=${TRUE}

step2: Power Off RMOD LTE
    Log to console  ----------------------
    Log to console  step2: Power Off RMOD LTE
    Log to console  ----------------------${\n}
    Set Start Timestamp In IMS For CNI-127210
    ${off_status}=  Run Keyword And Return Status  PDU Switch OFF Device Lists  ${TESTED_RMOD_SN}
    Run Keyword If  ${off_status}  Log  ${TESTED_RMOD_SN[0]} successfuly Powered Off  console=${TRUE}
    ...  ELSE  Run Keywords  Log  ${TESTED_RMOD_SN[0]} powering off failed  console=${TRUE}  AND  Fail  ${TESTED_RMOD_SN[0]} powering off failed
    ${alarm10_status}=    Run Keyword And Return Status admin.Assert Alarm Active
    ...  faultId=10, serialNo=${TESTED_RMOD_SN[0]}  timeout=60  connection=${node}
    ${alarm4003_status}=  Run Keyword And Return Status admin.Assert Alarm Active  faultId=4003  timeout=30  connection=${node}

    Run Keyword If  ${PRECOND_FOR_CNI}  Sleep  60s
    ${alarm4003_status}  Run Keyword If  not ${PRECOND_FOR_CNI}
    ...  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4003  timeout=30  connection=${node}
    ...  ELSE  Run Keyword And Return Status  Check Active Fault In IMS For CNI-127210  fault_id=4003  severity=Minor

    Run Keyword If  not ${alarm10_status} and ${alarm4003_status}  Run Keywords  Log  Expected Faults (10 or 4003) were not activated!
    ...  AND  Fail  Faults 10 or 4003 were not found
    Log  Expected Faults 10 and 4003 are visible  console=${TRUE}
    Append To List  ${GLO_ADMIN_ALLOWED_ALARMS}  faultId=10, serialNo=${TESTED_RMOD_SN[0]}  faultId=4003
    Verify Alarms On All Nodes
    Wait Until Keyword Succeeds  120s  10s  Check If Tested Cells Degraded  ${TESTED_CELLS}  connection=${node}
    Log  Following cells are correctly degraded:${\n}${TESTED_CELLS}  console=${TRUE}

step3: Two RMODs LTE Data Transfer
    Log to console  -----------------------------------
    Log to console  step3: Two RMODs LTE Data Transfer
    Log to console  -----------------------------------${\n}
    SiSo Convert Id to Runtime Distname  connection=any
    Set Test Variable  ${LOGS_DIR}  ${cfg.test_logs_path}
    SiSo L3 Call

step4: Power On RMOD LTE
    Log to console  ----------------------
    Log to console  step4: Power On RMOD LTE
    Log to console  ----------------------${\n}
    Set Start Timestamp In IMS For CNI-127210
    ${on_status}=  Run Keyword And Return Status  PDU Switch On Device Lists  ${TESTED_RMOD_SN}
    Run Keyword If  ${on_status}  Log  ${TESTED_RMOD_SN[0]} successfuly powered on  console=${TRUE}
    ...  ELSE  Run Keywords  Log  ${TESTED_RMOD_SN[0]} power on failed  console=${TRUE}  AND  Fail  ${TESTED_RMOD_SN[0]} power on failed
    ${alarm10_status}=      Run Keyword And Return Status admin.Assert Alarm Inactive  faultId=10  timeout=300  connection=${node}

    Run Keyword If  ${PRECOND_FOR_CNI}  Sleep  60s
    ${alarm4003_status}  Run Keyword If  not ${PRECOND_FOR_CNI}
    ...  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4003  timeout=60  connection=${node}
    ...  ELSE  Run Keyword And Return Status  Check Removed Active Fault In IMS For CNI-127210

    Run Keyword If  not ${alarm10_status} and ${alarm4003_status}  Run Keywords  Log  Faults (10 or 4003) should be deactivated!
    ...  AND  Fail  Faults 10 or 4003 should be deactivated!
    Log  Expected Faults 10 and 4003 are cleared  console=${TRUE}
    Wait Until Keyword Succeeds  120s  10s  Check If All Cells Are OnAir  alias=${node}
    Remove Values From List  ${GLO_ADMIN_ALLOWED_ALARMS}  faultId=10, serialNo=${TESTED_RMOD_SN[0]}  faultId=4003
    Sleep    30s    Wait for clearing FaultId 4589
    ${unexpected_historical_alarms_list}=  Get Unexpected Historical Alarms  connection=${node}
    Run Keyword If    ${unexpected_historical_alarms_list} is not None
    ...  Check For Alarm 4589  ${cfg['RF_INFO']['${TESTED_RMOD_SN[0]}']['btsid']}  ${TESTED_RMOD_SN[0]}  ${unexpected_historical_alarms_list}
    Verify Alarms On All Nodes

Recovery LTE
    [Arguments]  ${connection}=default
    Log  Checking if recovery is required...  console=${TRUE}
    ${rec_status}=  Run Keyword And Return Status admin.Assert Alarm Active  faultId=10  timeout=60  connection=${connection}
    Run Keyword If  ${rec_status}  PDU Switch On Device Lists  ${TESTED_RMOD_SN}
    ...  ELSE  Log  RMOD recovery not needed  console=${TRUE}
