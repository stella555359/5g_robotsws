*** Settings ***
Documentation
    ...  Test will configure faultSnapshotTriggers parameter with the desired parameters for secondary core.
    ...  After that test will perform BTSOMexe crash on secondary core and will check fault 2087 is visible with the correct fault signature.
    ...  Test will check if snapshot collection is started by Manta Ray on srnclabxxxxlcm VM.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${SNAPSHOT_TIMEOUT}  30  # [in minutes] Timeout to check if snapshot was collected in Manta Ray.


*** Keywords ***
FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28900
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  17.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28900 - Initial TAT creation
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  31.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29604 - Additional verification for TRBLCADM faultSnapshotTriggers
    ...  26.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29499 - Enhancement increase timeout for snapshot collection
    ...  26.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29764 - Enhancement test fails due to expected alarm
    ...  ******************

    Set Tags  CA-FM  OWNER-mircea.vladulescu@nokia.com  AUTHOR-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS25R2  FEATURE-CNI-129454

    Step0: Set Fault Variables For Test
    Step1: Configure Fault Snapshot Triggers Object
    Step2: Perform BTSOMexe Process Crash On Secondary Core
    Step3: Check Fault 2087 Is Visible
    Step4: Check Snapshot Collection On Manta Ray
    Step5: Check SBTS Is Enabled After Crash


Step0: Set Fault Variables For Test
    Log  \nStep0: Set fault variables for test.  console=true

    ${smod_r_obj}  Query Infomodel  get object //SMOD_R-* is [activeRole=Secondary]
    ${smod_r_dn}  Set Variable  ${smod_r_obj}[dist_name]
    Set Test Variable  ${PRODUCT_NAME}  ${smod_r_obj}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod_r_obj}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${smod_r_obj}[productCode]
    Set Unit Position For Fault Signature  ${smod_r_dn}

    ${lcm_url}  Get lcm Service URL
    Set Test Variable  ${LCM_URL}
    SSHLibrary.Open Connection  ${LCM_URL}
    SShLibrary.Login  ${NETACT_USER}  ${NETACT_PASSWORD}
    ${files}  SSHLibrary.List Files In Directory  /d/oss/global/diagsnap/ne3sws/
    ${date}  Get Current Date  result_format=%Y%m%d
    FOR  ${file}  IN  @{files}
         IF  ('MRBTS-${BTS_ID}' in '${file}') and ('${SW_VERSION}' in '${file}') and ('${date}' in '${file}')
             SSHLibrary.Execute Command  rm -f /d/oss/global/diagsnap/ne3sws/${file}
             Log  Existing snapshot ${file} removed from Manta Ray.  console=true
         END
    END

    [Teardown]  SSHLibrary.Close Connection


Step1: Configure Fault Snapshot Triggers Object
    Log  \nStep1: Configure fault snapshot triggers object.  console=true

    ${dict}  Get Parameter By Class  TRBLCADM
    ${faultSnapshotTriggers_initial}  Set Variable  ${dict}[0][parameters][faultSnapshotTriggers]
    FOR  ${item}  IN  @{faultSnapshotTriggers_initial}
         IF  '${item}[faultNumber]' == '2087'
             Remove Values From List  ${faultSnapshotTriggers_initial}  ${item}
             Delete Entry With Fault 2087 From TRBLCADM faultSnapshotTriggers  ${faultSnapshotTriggers_initial}
             BREAK
         END
    END
    ${sc_smod_type}  Get Secondary SMOD Type

    ${alarm}  Create Dictionary  faultNumber=2087  snapshotCoverageLevel=Full  triggerType=onFaultDetection  faultSignatureKeywords=${sc_smod_type}
    ${faultSnapshotTriggers_with_added_fault}  Copy List  ${faultSnapshotTriggers_initial}
    Append To List   ${faultSnapshotTriggers_with_added_fault}   ${alarm}

    Log  Create initial delta file.  console=true
    Create Delta  delta_id=initial
    Append Parameter Update To Delta  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                               parameter=faultSnapshotTriggers
    ...                               value=${faultSnapshotTriggers_initial}
    ...                               delta_id=initial
    Save Delta  ${BTS_FILES}/delta_initial.json  delta_id=initial

    Log  Create delta file with added alarm.  console=true
    Create Delta  delta_id=delta_with_added_alarm
    Append Parameter Update To Delta  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                               parameter=faultSnapshotTriggers
    ...                               value=${faultSnapshotTriggers_with_added_fault}
    ...                               delta_id=delta_with_added_alarm
    Save Delta  ${BTS_FILES}/delta_with_added_alarm.json  delta_id=delta_with_added_alarm

    Log  Start recommissioning with fault id 2087 added to faultSnapshotTriggers.  console=true
    Perform Delta Recommissioning  ${BTS_FILES}/delta_with_added_alarm.json


Step2: Perform BTSOMexe Process Crash On Secondary Core
    Log  \nStep2: Perform BTSOMexe process crash on secondary core.  console=true
    ${time_to}  Get Current Date  time_zone=UTC  result_format=datetime    increment=-15m
    Set Test Variable  ${TIME_TO}
    Open connection to primary core
    Open connection to secondary core
    Log  Perform BTSOMexe crash with: killall -9 BTSOMexe  console=true
    SSHLibrary.Execute Command  killall -9 BTSOMexe  connection=secondary_ssh

    [Teardown]  SSHLibrary.Close All Connections


Step3: Check Fault 2087 Is Visible
    Log  \nStep3: Check Fault 2087 is visible.  console=true

    ${fault_2087_sc_auto_reset_params}  Get String With Alarm Parameters  ${FAULT_2087_SC_AUTO_RST}
    Assert Alarm Active  parameters=${fault_2087_sc_auto_reset_params}  timeout=300s
    Assert Alarm Inactive  parameters=${fault_2087_sc_auto_reset_params}  timeout=300s
    Check Fault Signature Of Alarm In WebEM  fault_id=2087  category=SW_FAILURE  info=.*(btsom|BTSOM)exe  load_name=${SW_VERSION}  minor=0x.+
    ...  reset_counter=[0-9]+  scope=ESM  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=2087  category=SW_FAILURE  time_from=${TIME_TO}  info=.*(btsom|BTSOM)exe
    ...  load_name=LOAD_NAME: ${SW_VERSION}  minor=0x.+  reset_counter=[0-9]+  scope=SCOPE: ESM  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Step4: Check Snapshot Collection On Manta Ray
    Log  \nStep4: Check snapshot collection on Manta Ray.  console=true

    SSHLibrary.Open Connection  ${LCM_URL}
    SShLibrary.Login  ${NETACT_USER}  ${NETACT_PASSWORD}
    ${file}  Wait Until Keyword Succeeds  ${SNAPSHOT_TIMEOUT}m  1m  Check If Snapshot Was Collected In Manta Ray
    SSHLibrary.Get File  /d/oss/global/diagsnap/ne3sws/${file}  ${BTS_FILES}/netact_snapshot/${file}
    Log  Snapshot saved at ${BTS_FILES}/netact_snapshot/${file}.  console=true
    Log  Removing snapshot from Manta Ray.  console=true
    SSHLibrary.Execute Command  rm -f /d/oss/global/diagsnap/ne3sws/${file}

    [Teardown]  SSHLibrary.Close Connection


Step5: Check SBTS Is Enabled After Crash
    Log  \nStep5: Check SBTS is enabled after crash.  console=true

    ${WCDMA_ON_SC}  Check If WCDMA Cells Are Deployed On Secondary Core
    IF  ${WCDMA_ON_SC}
        ${4001_bts_rest_major}  Get String With Alarm Parameters  ${FAULT_4001_BTS_RST_REQ_MAJOR}
        Assert Alarm Active  parameters=${4001_bts_rest_major}
        Log  Fault ID 4001 BTS Reset Required found and WCDMA cells deployed on secondary core, performing RAT reset.  console=true
        Rat Reset  WCDMA  timeout=300
        Assert Alarm Inactive  parameters=${4001_bts_rest_major}
    END
    Wait Until Keyword Succeeds  10m  1m  Check Modules And Cells


Check If Snapshot Was Collected In Manta Ray
    ${files}  SSHLibrary.List Files In Directory  /d/oss/global/diagsnap/ne3sws/
    ${date}  Get Current Date  result_format=%Y%m%d
    FOR  ${file}  IN  @{files}
         IF  ('MRBTS-${BTS_ID}' in '${file}') and ('${SW_VERSION}' in '${file}') and ('${date}' in '${file}')
             Log  Snapshot collected on Manta Ray.  console=true
             ${snapshot_found}  Set Variable    ${TRUE}
             BREAK
         ELSE
             ${snapshot_found}  Set Variable    ${FALSE}
         END
    END
    IF  not ${snapshot_found}  Fail  Shanpshot was not found on Manta Ray.

    RETURN  ${file}


Get Secondary SMOD Type
    ${fsm}  Get Fsm Info
    FOR  ${smod}  IN  @{fsm}
         IF  '${smod}[activeRole]'=='Secondary'
             ${type}  Fetch From Left  ${smod}[productName]  ${SPACE}
             RETURN  ${type}
         END
    END


Check If WCDMA Cells Are Deployed On Secondary Core
    ${smods}  Get Fsm Info
    FOR  ${smod}  IN  @{smods}
         IF  '${smod}[activeRole]'=='Secondary'  BREAK
    END
    ${cells}  Get Cell Mapping By Module Id  ${smod}[id][internal]
    ${status}  Evaluate  True if True in [True if 'WNCEL' in cell else False for cell in ${cells}] else False

    RETURN  ${status}


Delete Entry With Fault 2087 From TRBLCADM faultSnapshotTriggers
    [Arguments]  ${faultSnapshotTriggers_without_2087}
    Log  Create delta file without 2087.  console=true
    Create Delta  delta_id=initial_without_2097
    Append Parameter Update To Delta  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                               parameter=faultSnapshotTriggers
    ...                               value=${faultSnapshotTriggers_without_2087}
    ...                               delta_id=initial_without_2097
    Save Delta  ${BTS_FILES}/initial_without_2097.json  delta_id=initial_without_2097
    Log  Remove 2097 from TRBLCADM faultSnapshotTriggers.  console=true
    Perform Delta Recommissioning  ${BTS_FILES}/initial_without_2097.json


TC Setup
    Common Test Setup  tc_name=FM__Snapshot_Collection_after_reset_with_faultsignature
    Setup NetAct


TC Teardown
    Teardown NetAct
    Perform Delta Recommissioning  ${BTS_FILES}/delta_initial.json
    Common Test Teardown
