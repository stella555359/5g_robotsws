*** Settings ***
Documentation
    ...  This test case is created to trigger LTE DSP crash and expect LTE DSP reset as recovery action .
    ...  It will be done by creating data.dat file by running command echo 0xFFFF >tmp/data.dat.
    ...  Than crashing DSP will be performed by running command: rioboot -c write -a 0x128FFFFF -f /tmp/data.dat <node_id>.
    ...  LTE DSP and CoreId will be choosen randomly from the pool of all LTE aviable DSP's.
    ...  Recovery action will be tested by checking faultID 6707/6708/6709/4019 with alarmId=7101 and the occurance of LTE DSP reset.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  660  # Timeout for alarm reporting in WebEM
${STARTUP_TIMEOUT}  120  # Timeout for SBTS startup after site reset


*** Keywords ***
TC__FM__LTE_DSP_crash_DSP_recovery_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10138
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 14.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10138 - Initial TAT creation
    ...  - 18.01.2018 - https://jira3.int.net.nokia.com/browse/TAT-13871 - Add new allowed faultId
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 05.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15296 - Reset counter clearance moved at the TC beginning
    ...  - 27.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-16483 - Implementation of unaffected resources verification
    ...  - 28.08.2020 - https://jira3.ext.net.nokia.com/browse/TAT-18302 - Wrong DSP chosen to crash, scenario FSMF rel3
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 21.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22552 - Change actForceAutoReset to true if DSP is on FSMF
    ...  - 23.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23146 - Change actForceUnitAutoReset to true if DSP is on FSMF
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25140 - Test fail since test does not wait enough for fault to occur
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 09.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27314 - Fix dictionary variable
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-iwona.andrejewicz@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534

    Step0: Check All Required States And Perform Site Reset
    Step1: Get All LTE DSPs Dist Names And Choose DSP And CORE Randomly
    Step2: Trigger DSP Crash On LTE DSP
    Step3: Verify SBTS Status During DSP Crash
    Step4: Verify SBTS After Recovery


Step0: Check All Required States And Perform Site Reset
    Log  \nStep0: Check all required states and perform site reset.  console=true
    Check Commissioned Technologies  LTE
    Perform Site Reset
    ${fault_dsp_group_auto_rst}  Copy Dictionary  ${FAULT_6707_DSP_GROUP_AUTO_RST}
    Set To Dictionary  ${fault_dsp_group_auto_rst}  fault_id=regex"6707|6708|6709|4019"
    ${fault_dsp_group_auto_rst_params}  Get String With Alarm Parameters  ${fault_dsp_group_auto_rst}
    Set Test Variable  ${FAULT_PARAMETERS}  ${fault_dsp_group_auto_rst_params}


Step1: Get All LTE DSPs Dist Names And Choose DSP And CORE Randomly
    [Timeout]  15 min

    Log  \nStep1: Get all LTE DSPs dist names and choose DSP and CORE randomly.  console=true
    ${ims_path}  Set Variable  ${BTS_FILES}/IM/InfoModel_log_before_IM_restart.ims2
    Save The Log And Restart Infomodel  ${ims_path}
    Choose DSP For Crash  LTE
    Set Variable For Fault Signature Check
    Change ActForceUnitAutoReset To True If DSP Is On FSMF


Step2: Trigger DSP Crash On LTE DSP
    Log  \nStep2: Trigger LTE DSP crash.  console=true
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}
    Verify SMOD Type And Trigger DSP Crash


Step3: Verify SBTS Status During DSP Crash
    Log  \nStep3:Verify alarms and reasoning status of impacted objects after fault sending.  console=true
    ${supported_alarms}  Create List  6707  6708  6709  4019
    ${status_object}  ${im_dsp_object}  Run Keyword And Ignore Error
    ...  Query Infomodel  get object${CORE_ID}[dist_name] is [stateInfo.availabilityStatus=Failed, stateInfo.operationalState=Disabled]
    IF  '${status_object}'=='FAIL'
      Set Test Restriction  Reasoning status of${CORE_ID}[dist_name] is different than expected. [NOK]
    ELSE
      Log  stateInfo for${CORE_ID}[dist_name] is availabilityStatus=Failed and operationalState=Disabled. [OK]  console=true
    END
    ${bbmod_l}  Fetch From Left  ${CORE_ID}[dist_name]  /BBU_L-
    ${bbmod_r_ref_object}  Query Infomodel  get object //REF-1 is [distName=${bbmod_l}]
    ${bbmod_r_object}  Fetch From Left  ${bbmod_r_ref_object}[dist_name]  /REF-1
    ${status_bbmod_r}  ${im_bbmod_object}  Run Keyword And Ignore Error  Assert Any  BBMOD  availabilityStatus=${DEGRADED}
    IF  '${status_bbmod_r}'=='FAIL'
      Set Test Restriction  Reasoning status of ${bbmod_r_object} is different than expected. [NOK]
    ELSE
      Log  stateInfo for ${bbmod_r_object} is availabilityStatus=Degraded. [OK]  console=true
    END
    ${status_smod_r}  ${im_smod_r_object}  Run Keyword And Ignore Error  Assert Any  SMOD  availabilityStatus=${DEGRADED}
    IF  '${status_smod_r}'=='FAIL'
      Set Test Restriction  Reasoning status of SMOD_R is different than expected. [NOK]
    ELSE
      Log  stateInfo for SMOD-R is availabilityStatus=Degraded. [OK]  console=true
    END

    ${send_fault}  Run Keyword In Background  Assert Alarm Active  parameters=${FAULT_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    ${status}  ${dict_result}  Run Keyword And Ignore Error  Collect Keyword Result  ${send_fault}  timeout=${ALARM_TIMEOUT}
    IF  '${status}'=='FAIL'  Fail  Fault ${supported_alarms} with alarm 7101 didn't occure.
    ${fault_id}  Evaluate  [item for item in ${dict_result} if item['faultId'] in [int(alarm) for alarm in ${supported_alarms}]][0]
    Log  Fault ${fault_id['faultId']} "${FAULT_6707_DSP_GROUP_AUTO_RST}[fault_name]". [OK]  console=true
    Log  Alarm presence will be verified in Netact.  console=true
    Wait Until Keyword Succeeds  180s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6707_DSP_GROUP_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_6707_DSP_GROUP_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_6707_DSP_GROUP_AUTO_RST} reported and cleared in Netact.  console=true


Step4: Verify SBTS After Recovery
    Log  \nStep4:Verify SBTS after recovery.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check All Cells
    ${im_log_path}  Set Variable  ${BTS_FILES}/IM/InfoModel_log_after_recovery_reset.ims2
    Save Infomodel Log  ${im_log_path}
    Log  Check if cells status from other RATs remained unchanged.  console=true
    IF  ${SCF_COUNT_GSM}  Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${im_log_path}
    IF  ${SCF_COUNT_WCDMA}  Infomodel Check If Cells In RAT Were Operational According To IM Log  WCDMA  ${im_log_path}
    Assert Alarm Inactive  parameters=${FAULT_PARAMETERS}
    Log  Alarm 7101 "${FAULT_6707_DSP_GROUP_AUTO_RST}[fault_name]" is cleared after recovery action.  console=true
    Admin Check Active Alarms TAF

    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_6707_DSP_GROUP_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_6707_DSP_GROUP_AUTO_RST}[fault_id]  time_from=${START_TIME}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


Change ActForceUnitAutoReset To True If DSP Is On FSMF
    [Documentation]  This KW is created to change actForceUnitAutoReset to true if DSP is on FSMF.
    ...  SMOD position is checked and it should have the same BTS_L id with the DSP.
    ...  Then the productName of the SMOD is taken and checked. If it's FSMF, the actForceUnitAutoReset will be changed to true.

    ${system_modules_info}  Get Fsm Info
    FOR  ${smod}  IN  @{system_modules_info}
        ${ports_dict}  Get From Dictionary  ${smod}  ports
        Check SMOD Position  ${ports_dict}
        ${product_name_smod}  Get From Dictionary  ${smod}  productName
        IF  '${product_name_smod}'=='Flexi System Module Outdoor FSMF'
          Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset
          Set Test Variable  ${STATUS_ACTFORCEUNITAUTORESET}  ${TRUE}
          BREAK
        ELSE
          Log  DSP is connected on ASIA and actForceUnitAutoReset will not be changed.  console=true
          Set Test Variable  ${STATUS_ACTFORCEUNITAUTORESET}  ${FALSE}
          BREAK
        END
    END


Check SMOD Position
    [Arguments]  ${ports_values}

    FOR  ${value}  IN  @{ports_values}
        ${id_dict}  Get From Dictionary  ${value}  id
        ${internal_dist_name}  Get From Dictionary  ${id_dict}  internal
        ${status}  Run Keyword And Return Status  Should Contain  ${internal_dist_name}  BTS_L-${BTS_L_ID_BBMOD}
        IF  ${status}  BREAK
    END


Set Variable For Fault Signature Check
    ${bbmod_l}  Fetch From Left  ${CORE_ID}[dist_name]  /BBU_L-
    ${bbmod_object}  Query Infomodel  get object ${bbmod_l}
    Set Test Variable  ${PRODUCT_NAME}  ${bbmod_object.productName}
    Set Test Variable  ${PRODUCT_CODE}  ${bbmod_object.productCode}
    Set Test Variable  ${SERIAL_NUMBER}  ${bbmod_object.serialNumber}
    ${bbmod_r}  Query Infomodel  get object //BBMOD_R-* is [serialNumber=${SERIAL_NUMBER}]
    Set Unit Position For Fault Signature  ${bbmod_r}[dist_name]
    Set Test Variable  ${INFO}  .*FATAL EXCEPTION.*
    Set Test Variable  ${SCOPE}  DSP group
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=LTE:[0-9]+
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


TC Setup
    Common Test Setup  tc_name=FM__LTE_DSP_crash_DSP_recovery_reset
    Setup NetAct


TC Teardown
    IF  ${STATUS_ACTFORCEUNITAUTORESET}  Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    Teardown NetAct
    Common Test Teardown
