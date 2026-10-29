*** Settings ***
Documentation
    ...  Test case will verify the reporting and clearing of fault 7324 when enhX2linkSupervision feature is activated.
    ...  Functionality is introduced by the feature CB Enhanced X2 Link Supervision.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ADJ_ENB_ID}  ${EMPTY}  # [MANDATORY] Unique ID of the neighbor eNB.
${NETACT_TIMEOUT}  60  # Timeout for fault reporting in Netact.
${COMMISSIONING_STATE}  ${FALSE}
# ${FALSE} or ${TRUE}. The value is used in check if recommissioning was done, keyword to apply recommissioning when test fails.


*** Keywords ***
TC__FM__Activate_Deactivate_EnhX2LinkSupervision
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21130
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21130 - Initial TAT creation
    ...  - 06.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21560 - check fault verification change
    ...  - 02.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21698 - Test fails because: NRBTS_A-* matching objects not found
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com  FEATURE-CB005956
    ...  FEATURE-CB006758  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21

    Step0: Check All Required States
    Step1: Change Parameters Values To Trigger Fault
    Step2: Verify Fault Appearence And Services
    Step3: Verify Fault Clearence And Services


Step0: Check All Required States
    Log  Step0: Check all required states.  console=true

    ${is_neighboring_defined}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${ADJ_ENB_ID}
    Run Keyword If  ${is_neighboring_defined}
    ...  Log  Neighboring enb is defined, test will continue [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Neighboring enb is not defined, test will be set as failed [NOK].

    ${id}  Get Substring  ${ADJ_ENB_ID}  2
    ${adress}  Get Substring  ${id}  1
    Run Keyword If  600 <= ${id} <= 699
    ...  Set Test Variable  ${LNADJ_ADRESS}  10.15.236.${adress}
    ...  ELSE IF  700 <= ${id} <= 799
    ...  Set Test Variable  ${LNADJ_ADRESS}  10.15.236.1${adress}
    ...  ELSE IF  800 <= ${id} <= 854
    ...  Set Test Variable  ${LNADJ_ADRESS}  10.15.236.2${adress}
    ...  ELSE
    ...  Fail  msg= Neighboring MRBTS ID is out of supported range [NOK].

    ${link_adj_status}  Run Keyword And Return Status
    ...  Query Infomodel  get object //LTEENB_R-* is [ipAddr=${LNADJ_ADRESS}, x2LinkStatus=available]
    Run Keyword If  ${link_adj_status}
    ...  Log  Neighboring adjacent link LTEENB is available [OK].  console=true
    ...  ELSE
    ...  Fail  msg= Neighboring adjacent link LTEENB is unavailable [NOK].

    ${im_bts_id}  Admin Get BTS ID
    ${lnadjgnb}  Query Infomodel  get object //LNADJGNB_A-*  timeout=30
    Set Test Variable  ${DIST_NAME}  MRBTS-${im_bts_id}/NRBTS-${lnadjgnb.adjGnbId}

    ${max_num_x2_links_ini}  Get MaxNumX2Links Parameter Value From Infomodel  maxNumX2Links
    ${act_enhanced_x2_link_supervision_ini}  Get ActEnhancedX2LinkSupervision Parameter Value From Infomodel  actEnhancedX2LinkSupervision
    Set Test Variable  ${MAX_NUM_X2_LINKS_INI}
    Set Test Variable  ${ACT_ENHANCED_X2_LINK_SUPERVISION_INI}

    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}


Step1: Change Parameters Values To Trigger Fault
    Log  Step1: Change parameters values to trigger fault.  console=true

    ${status_1}  Run Keyword And Return Status
    ...  Change Parameter MaxNumX2Links  2  maxNumX2Links  ${DIST_NAME}
    ${status_2}  Run Keyword And Return Status
    ...  Change Parameter ActEnhancedX2LinkSupervision  true  actEnhancedX2LinkSupervision  ${DIST_NAME}
    Run Keyword If  '${status_1}'=='True' or '${status_2}'=='True'
    ...  Set Test Variable  ${COMMISSIONING_STATE}  True


Step2: Verify Fault Appearence And Services
    Log  Step2: Verify fault appearence and services.  console=true

    ${fault_7324_params}  Get String With Alarm Parameters  ${FAULT_7324}
    Assert Alarm Active  parameters=${fault_7324_params}  timeout=120
    Log  Fault ${FAULT_7324} active in WebEM.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  15
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_7324}  additional_fault_id=${FAULT_7324}[fault_id]
    Log  Fault ${FAULT_7324} active in Netact.  console=true

    ${cells_status}  Run Keyword And Return Status
    ...  Check All Cells
    Run Keyword If  ${cells_status}
    ...  Log  All cells in configuration are : OnAirDone Enabled Active [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Cells status is incorect [NOK].

    ${nrbts_l_status}  Run Keyword And Return Status
    ...  Query Infomodel  get object //NRBTS_L-* is [stateInfo.reasoningStatus[0]="MaxX2LinkReached"]  timeout=60
    Run Keyword If  ${nrbts_l_status}
    ...  Log  Reasoning status is MaxX2LinkReached [OK].  console=true
    ...  ELSE
    ...  Set Test Restriction  message=Reasoning Status is different than expected [NOK].

    ${lteenb_links}  Query Infomodel  get list //LTEENB_R-*  timeout=60
    FOR  ${link}  IN  @{lteenb_links}
        ${status}  Run Keyword And Return Status
        ...  Should Be Equal  ${link.x2LinkStatus}  available
        Run Keyword If  ${status}
        ...  Log  LTEENB link: ${link.dist_name} has x2LinkStatus: available [OK].  console=true
        ...  ELSE
        ...  Set Test Restriction  message=LTEENB link: ${link.dist_name} has x2LinkStatus: unavailable [NOK].
    END


Step3: Verify Fault Clearence And Services
    Log  Step3: Verify fault clearence and services.  console=true

    ${status_1}  Run Keyword And Return Status
    ...  Change Parameter ActEnhancedX2LinkSupervision  ${ACT_ENHANCED_X2_LINK_SUPERVISION_INI}  actEnhancedX2LinkSupervision  ${DIST_NAME}
    ${status_2}  Run Keyword And Return Status
    ...  Change Parameter MaxNumX2Links  ${MAX_NUM_X2_LINKS_INI}  maxNumX2Links  ${DIST_NAME}
    Run Keyword If  '${status_1}'=='True' and '${status_2}'=='True'
    ...  Set Test Variable  ${COMMISSIONING_STATE}  False

    ${fault_7324_params}  Get String With Alarm Parameters  ${FAULT_7324}
    Assert Alarm Inactive  parameters=${fault_7324_params}  timeout=120
    Log  Fault ${FAULT_7324} is inactive in WebEM.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  15
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7324}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_7324}[fault_id]
    Log  Fault ${FAULT_7324} is inactive in Netact.  console=true

    ${cells_status}  Run Keyword And Return Status
    ...  Check All Cells
    Run Keyword If  ${cells_status}
    ...  Log  All cells in configuration are : OnAirDone Enabled Online Active [OK].  console=true
    ...  ELSE
    ...  Fail  msg=Cells status is incorect [NOK].


Check If Recommissioning Was Done
    [Documentation]  This KW is created to ensure that recommissioning is performed when the test fails.

    Log  Check if recommissioning was done...  console=true
    Run Keyword If  ${COMMISSIONING_STATE}
    ...  Run Keywords
    ...  Change Parameter ActEnhancedX2LinkSupervision  ${ACT_ENHANCED_X2_LINK_SUPERVISION_INI}  actEnhancedX2LinkSupervision  ${DIST_NAME}
    ...  AND
    ...  Change Parameter MaxNumX2Links  ${MAX_NUM_X2_LINKS_INI}  maxNumX2Links  ${DIST_NAME}


TC Setup
    Common Test Setup  tc_name=FM__Activate_Deactivate_EnhX2LinkSupervision
    Setup NetAct


TC Teardown
    Check If Recommissioning Was Done
    Teardown NetAct
    Common Test Teardown
