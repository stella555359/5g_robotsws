*** Settings ***
Documentation
    ...  This test case is created to perform provisioning of 5 plans from a specified directory.
    ...  Each plan is modified, then the provisioning stars.
    ...  After the provisioning is finished, alarms are checked on SBTS and Netact, they should be the same.
    ...  Expected Faults And Accept Allowed are also checked and counter reset is taken.
    ...  After provisioning the last plan, the NE3SESSION is checked. It should be connected.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${TIMEOUT}  900  #timeout for NE3SESSION to be connected
@{ALLOWED_FAULTS}  6450  4655  4654  4293  9047  1939  7115  4681  3080  4203  4340  4391  6150  6202  6203  6261
...  6351  9000  61006  61058  61074  61510  61524  61611  61616  61631  61649  61652
&{VALIDATE}  -validateBeforePreactivationForLTE=true  #mandatory to be set on True; do not change


*** Keywords ***
TC__FM__Add_configure_remove_all_external_alarms_via_NA
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21277
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21277 - Initial TAT creation
    ...  - 01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* library replacement with taf.nms.netact
    ...  - 04.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-21645 - Keywords moved to resource file
    ...  - 21.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22709 - Remove /home/ute/robotlte
    ...  - 06.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23229 - Change Setup Netact
    ...  - 27.10.2022 - https://jira3.ext.net.nokia.com/browse/TAT-23929 - Fix for multiple keywords
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  ******************

    Set Tags  CA-FM  OWNER-simona.marcu@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com  MAINTAINER-cosmina.rebenciuc@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21

    Step0: Get Path To Test Plans
    Step1: Checks Status Of ENB Before Test
    Step2: Prepare All Files For Test
    Step3: Provision Plan 1
    Step4: Provision Plan 2
    Step5: Provision Plan 3
    Step6: Provision Plan 4
    Step7: Provision Plan To Clear Alarm


Step0: Get Path To Test Plans
    Log  Step0: Get path to test plans  console=true
    Set Test Variable  ${TEST_DATA_FILES}  ${CURDIR}/test_plans/FM__Add_configure_remove_all_external_alarms_via_NA


Step1: Checks Status Of ENB Before Test
    Log  Step1: Checks status of eNB before test  console=true
    Show Current System Module Type
    Wait Until Keyword Succeeds  5x  60s
    ...  Check If Cells OnAir Or PowerSaving Enabled
    Wait Until Keyword Succeeds  5x  60s
    ...  Check If Alarms From WebEM And NetAct Are The Same
    Check Expected Faults And Accept Allowed  ${ALLOWED_FAULTS}
    ${reset}  Get Reset Counter
    Set Test Variable  ${RESET_VALUE}  ${reset}
    Log  Reset counter before test: ${reset}  console=true
    ${backup_list}  Create List
    Set Test Variable  ${BACKUP_LIST}  ${backup_list}
    ${bts_id}  Get ENB Id
    Set Test Variable  ${ENB_ID}  ${bts_id}
    ${enb_release}  Fetch From Left  ${ACTIVE_SW_VERSION}  _
    Set Test Variable  ${ENB_RELEASE}  ${enb_release}
    Set Test Variable  ${PLMN}  PLMN-PLMN
    Create Directory  ${BTS_FILES}/results
    ${results_file}  Set Variable  ${BTS_FILES}/results
    Set Test Variable  ${RESULTS}  ${results_file}


Show Current System Module Type
    [Documentation]  Shows actual System Module Type

    ${status_smod_r_1}  ${system_module_info_left}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //CABINET_R-1/SMOD_R-1
    ${system_module_info_r_1}  Get From Dictionary  ${system_module_info_left}  productName
    ${status_smod_r_2}  ${system_module_info_right}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object //CABINET_R-1/SMOD_R-2
    ${system_module_info_r_2}  Run Keyword If  '${status_smod_r_2}'=='PASS'
    ...  Get From Dictionary  ${system_module_info_right}  productName
    ${system_module_info}  Run Keyword If  '${status_smod_r_1}'=='${status_smod_r_2}' and '${system_module_info_r_1}'=='ASIA AirScale Common'
    ...  Set Variable  AirScale Fullrack
    ...  ELSE IF  '${status_smod_r_1}'=='FAIL' or '${status_smod_r_2}'=='FAIL'
    ...  Set Variable  AirScale
    ...  ELSE
    ...  Set Variable  FSMF
    Set Test Variable  ${SYSTEM_MODULE}  ${system_module_info}
    Log  System Module Type: ${SYSTEM_MODULE}  console=True


Check Expected Faults And Accept Allowed
    [Documentation]
    ...  Keyword check whether expected faults are present on eNB
    ...  By default expected_faults list is empty
    ...  Allowed faults could be declared in eNB configuration file
    ...  Author: krystian.gordziejewski@gmail.com
    [Arguments]  ${allowed_faults}  ${expected_faults}=&{EMPTY}

    ${netact_alarms}  netact.Get Alarms  dist_name=${MRBTS_DN}
    ${netact_alarms_ids}  Get Ids From Netact Alarms  ${netact_alarms}
    ${faults_to_delete}  Create List
    FOR  ${fault}  IN  @{allowed_faults}
        ${fault}  Convert To Integer  ${fault}
        Append To List  ${faults_to_delete}  ${fault}
    END
    FOR  ${fault}  IN  @{expected_faults}
        ${fault}  Convert To Integer  ${fault}
        List Should Contain Value  ${netact_alarms_ids}  ${fault}
        Append To List  ${faults_to_delete}  ${fault}
    END
    Remove Values From List  ${netact_alarms_ids}  @{faults_to_delete}
    Should Be Empty  ${netact_alarms_ids}


Step2: Prepare All Files For Test
    [Documentation]  Prepare all necessary files for test

    Log  Step2: Prepare all files for test  console=true
    Export Configuration  local_dir=${RESULTS}  file_name=${ENB_ID}_full_backup.xml  operation_type=actual
    Prepare And Import All Plans From Directory


Wait Until NE3S_SESSION Is Connected
    [Arguments]  ${timeout}

    Log  Wait until NE3S_SESSION is connected  console=true
    ${timeout}  Convert To Integer  ${timeout}
    ${range}  Evaluate  ${timeout}/10
    FOR  ${loop}  IN RANGE  ${range}
        ${nms_object}  Query Infomodel  get object /MRBTS-1/RAT-1/NE3SADAPT-*/NE3S_SESSION-*
        ${downlink_state}  Get From Dictionary  ${nms_object}[stateInfo]  downlinkState
        ${uplink_state}  Get From Dictionary  ${nms_object}[stateInfo]  uplinkState
        ${downlink_state_status}  Run Keyword And Return Status
        ...  Should Be Equal  ${downlink_state}  UnsecureConnected
        ${uplink_state_status}  Run Keyword And Return Status
        ...  Should Be Equal  ${uplink_state}  UnsecureConnected
        ${status}  Run Keyword If  ${downlink_state_status} and ${uplink_state_status}
        ...  Set Variable  ${TRUE}
        Run Keyword If  ${status}
        ...  Log  NE3S_SESSION is connected.  console=true
        Run Keyword If  ${status}
        ...  Exit For Loop
        Sleep  10
    END


Step3: Provision Plan 1
    [Documentation]  Provision plan_1 to trigger faults and check if they are reported

    Log  Step3: Provision plan 1  console=true
    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    netact.Provision Plan  plan_name=${ENB_ID}_plan_1  dist_names=${MRBTS_DN}  create_backup_plan=true
    ...  backup_plan_name=${ENB_ID}_${current_date}_backup  provisioning_operation=activate  parameters=${VALIDATE}
    Append To List  ${BACKUP_LIST}  ${ENB_ID}_${current_date}_backup
    netact.Delete Plan  plan_name=${ENB_ID}_plan_1
    Wait Until Keyword Succeeds  5x  1min
    ...  Check If Cells OnAir Or PowerSaving Enabled
    ${reset}  Get Reset Counter
    Log  Reset counter after provisioning - ${reset}  console=true
    Should Be Equal  ${reset}  ${RESET_VALUE}
    Append To List  ${ALLOWED_FAULTS}  1517  # in some configuration - fault 1517 can rise on AS
    ${expected_faults_fullrack}  Create List  1401  1405  1409
    ${expected_faults_fsmf}  Create List  1401  1405  1409  1413  1417  1421
    ${expected_faults}  Set Variable If  "${SYSTEM_MODULE}"=="AirScale" or "${SYSTEM_MODULE}"=="AirScale Fullrack"  ${expected_faults_fullrack}
    ...  ${EXPECTED_FAULTS}
    ${expected_faults}  Set Variable If  "${SYSTEM_MODULE}"=="FSMF"  ${expected_faults_fsmf}  ${expected_faults}
    Wait Until Keyword Succeeds  10x  30sec
    ...  Check Faults On ENB  ${ALLOWED_FAULTS}  ${expected_faults}
    Wait Until Keyword Succeeds  5x  6min
    ...  Check If Alarms From WebEM And NetAct Are The Same


Check Faults On ENB
    [Arguments]  ${allowed_faults}=${allowed_faults}  ${expected_faults}=&{EMPTY}

    @{enb_alarms}  Wait Until Keyword Succeeds  5 x  2 s
    ...  coam.Get Active Alarms  timeout=${20}
    ${faults_ids}  Create List
    ${faults_list}  Create List
    ${faults_to_delete}  Create List
    FOR  ${enb_alarm}  IN  @{enb_alarms}
        ${fault_id}  Get From Dictionary  ${enb_alarm}  faultId
        Append To List  ${faults_ids}  ${fault_id}
    END
    ${faults_list}  Copy List  ${faults_ids}
    ${list_fault}  Set Variable  ${faults_list}
    FOR  ${expected_fault}  IN  @{expected_faults}
        ${fault}  Convert To Integer  ${expected_fault}
        List Should Contain Value  ${faults_ids}  ${fault}
        Append To List  ${faults_to_delete}  ${fault}
    END
    FOR  ${fault}  IN  @{allowed_faults}
        ${fault}  Convert To Integer  ${fault}
        Append To List  ${faults_to_delete}  ${fault}
    END
    Remove Values From List  ${faults_ids}  @{faults_to_delete}
    Should Be Empty  ${faults_ids}  msg='Not allowed faults: ${faults_ids}'


Step4: Provision Plan 2
    [Documentation]  Provision plan_2 to trigger faults and check if they are reported

    Log  Step4: Provision plan 2  console=true
    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    netact.Provision Plan  plan_name=${ENB_ID}_plan_2  parameters=${VALIDATE}  create_backup_plan=true
    ...  backup_plan_name=${ENB_ID}_${current_date}_backup
    netact.Delete Plan  plan_name=${ENB_ID}_plan_2
    Append To List  ${BACKUP_LIST}  ${ENB_ID}_${current_date}_backup
    Wait Until Keyword Succeeds  5s  60s
    ...  Check If Cells OnAir Or PowerSaving Enabled
    ${reset}  Get Reset Counter
    Log To Console  /n Reset counter after provisioning - ${reset}
    Should Be Equal  ${reset}  ${RESET_VALUE}
    ${expected_faults_fullrack}  Create List  1401  1405  1409
    ${expected_faults_fsmf}  Create List  1401  1405  1409  1413  1417  1421
    ${expected_faults}  Set Variable If  "${SYSTEM_MODULE}"=="AirScale" or "${SYSTEM_MODULE}"=="AirScale Fullrack"  ${expected_faults_fullrack}
    ...  ${EXPECTED_FAULTS}
    ${expected_faults}  Set Variable If  "${SYSTEM_MODULE}"=="FSMF"  ${expected_faults_fsmf}  ${expected_faults}
    Wait Until Keyword Succeeds  10s  30s
    ...  Check Faults On ENB  ${ALLOWED_FAULTS}  ${expected_faults}
    Wait Until Keyword Succeeds  5s  120s
    ...  Check If Alarms From WebEM And NetAct Are The Same


Step5: Provision Plan 3
    [Documentation]  Provision Plan_3 to trigger faults and check if they are reported

    Log  Step5: Provision plan 3  console=true
    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    netact.Provision Plan  plan_name=${ENB_ID}_plan_3  parameters=${VALIDATE}  create_backup_plan=true
    ...  backup_plan_name=${ENB_ID}_${current_date}_backup
    netact.Delete Plan  plan_name=${ENB_ID}_plan_3
    Append To List  ${BACKUP_LIST}  ${ENB_ID}_${current_date}_backup
    Wait Until Keyword Succeeds  5s  60s
    ...  Check If Cells OnAir Or PowerSaving Enabled
    ${reset}  Get Reset Counter
    Log To Console  /n Reset counter after provisioning - ${reset}
    Should Be Equal  ${reset}  ${RESET_VALUE}
    ${expected_faults_fullrack}  Create List  1402  1406  1410
    ${expected_faults_fsmf}  Create List  1402  1406  1410  1413  1418  1422
    ${expected_faults}  Set Variable If  "${SYSTEM_MODULE}"=="AirScale" or "${SYSTEM_MODULE}"=="AirScale Fullrack"  ${expected_faults_fullrack}
    ...  ${EXPECTED_FAULTS}
    ${expected_faults}  Set Variable If  "${SYSTEM_MODULE}"=="FSMF"  ${expected_faults_fsmf}  ${expected_faults}
    Wait Until Keyword Succeeds  10s  30s
    ...  Check Faults On ENB  ${ALLOWED_FAULTS}  ${expected_faults}
    Wait Until Keyword Succeeds  5s  120s
    ...  Check If Alarms From WebEM And NetAct Are The Same


Step6: Provision Plan 4
    [Documentation]  Provision plan_4 to trigger faults and check if they are reported

    Log  Step6: Provision plan 4  console=true
    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    netact.Provision Plan  plan_name=${ENB_ID}_plan_4  parameters=${VALIDATE}  create_backup_plan=true
    ...  backup_plan_name=${ENB_ID}_${current_date}_backup
    netact.Delete Plan  plan_name=${ENB_ID}_plan_4
    Append To List  ${BACKUP_LIST}  ${ENB_ID}_${current_date}_backup
    Wait Until Keyword Succeeds  5s  60s
    ...  Check If Cells OnAir Or PowerSaving Enabled
    ${reset}  Get Reset Counter
    Log To Console  /n Reset counter after provisioning - ${reset}
    Should Be Equal  ${reset}  ${RESET_VALUE}
    ${expected_faults_fullrack}  Create List  1403  1407
    ${expected_faults_fsmf}  Create List  1403  1407  1413  1415  1419  1423
    ${expected_faults}  Set Variable If  "${SYSTEM_MODULE}"=="AirScale" or "${SYSTEM_MODULE}"=="AirScale Fullrack"  ${expected_faults_fullrack}
    ...  ${EXPECTED_FAULTS}
    ${expected_faults}  Set Variable If  "${SYSTEM_MODULE}"=="FSMF"  ${expected_faults_fsmf}  ${expected_faults}
    Wait Until Keyword Succeeds  10s  30s
    ...  Check Faults On ENB  ${ALLOWED_FAULTS}  ${expected_faults}
    Wait Until Keyword Succeeds  5s  120s
    ...  Check If Alarms From WebEM And NetAct Are The Same


Step7: Provision Plan To Clear Alarm
    [Documentation]  Provision plan to clean alarm

    Log  Step7: Provision plan to clear alarm  console=true
    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    netact.Provision Plan  plan_name=${ENB_ID}_plan_5  parameters=${VALIDATE}
    netact.Delete Plan  plan_name=${ENB_ID}_plan_5
    Wait Until Keyword Succeeds  5s  60s
    ...  Check If Cells OnAir Or PowerSaving Enabled
    ${reset}  Get Reset Counter
    Log To Console  /n Reset counter after provisioning - ${reset}
    Should Be Equal  ${reset}  ${RESET_VALUE}
    Wait Until Keyword Succeeds  5x  60s
    ...  Check If Alarms From WebEM And NetAct Are The Same
    Wait Until Keyword Succeeds  5x  60s
    ...  Check Expected Faults And Accept Allowed  ${ALLOWED_FAULTS}
    Wait Until NE3S_SESSION Is Connected  ${TIMEOUT}


Test Teardown If Fail
    [Arguments]  ${backup_list}  ${ute_admin_alias}=default  ${type}=admin

    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${status}  ${value}  Run Keyword And Ignore Error
    ...  Provision All Backups  list=${backup_list}
    Run Keyword If  '${status}'=='FAIL'
    ...  Recommission All Delta Backups  ${backup_list}  alias=${ute_admin_alias}
    Check Faults On ENB  ${ALLOWED_FAULTS}
    Run Keyword If  '${type}'=='netact'
    ...  Check If Alarms From WebEM And NetAct Are The Same
    Wait Until NE3S_SESSION Is Connected  ${TIMEOUT}


Provision All Backups
    [Arguments]  ${list}  ${reset_expected}=True

    Reverse List  ${list}
    FOR  ${plan}  IN  @{list}
        Log To Console  \nRestoring from backup plan ${plan}
        netact.Provision Plan  ${plan}
        Run Keyword If  ${reset_expected}
        ...  Wait Until Keyword Succeeds  15x  30sec
        ...  Check If Cells OnAir Or PowerSaving Enabled
    END
    Reverse List  ${list}


Recommission All Delta Backups
    [Arguments]  ${backup_deltas}  ${alias}=default

    Reverse List  ${backup_deltas}
    FOR  ${delta}  IN  @{backup_deltas}
        Perform Delta Recommissioning  ${delta}  alias=${alias}
        Wait Until Keyword Succeeds  15x  30sec
        ...  Check If Cells OnAir Or PowerSaving Enabled
    END


TC Setup
    Common Test Setup  tc_name=FM__Add_configure_remove_all_external_alarms_via_NA
    Setup Netact


TC Teardown
    Run Keyword If Test Failed
    ...  Test Teardown If Fail  ${BACKUP_LIST}
    Teardown Netact
    Common Test Teardown
