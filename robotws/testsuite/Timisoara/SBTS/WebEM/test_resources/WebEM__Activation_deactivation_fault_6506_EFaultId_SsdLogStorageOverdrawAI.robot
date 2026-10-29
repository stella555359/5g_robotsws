*** Settings ***
Documentation
    ...  This test case is created to send fault 6506.
    ...  Test will randomly select SMOD from ASIB, ASIL, ASOE, ASIM.
    ...  TC supports SMOD with log partition.
    ...  After sending the fault 6506, within 15 min R&D fault 6506 is available in RawAlarmHistory.txt file.
    ...  Checks are made if alarm object is on SMOD.
    ...  Checks are made if raport of log is included in BTS snapshot (report name "snapshot_ssdLogsDiskDump.csv.xz").
    ...  Alarm is deactivated and the checks are done.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${TIMEOUT}  1800  # Timeout for alarm to appear


*** Keywords ***
TC__WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI
    [Documentation]
    ...
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-24492
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24492 - Initial TAT creation
    ...  - 12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  ******************

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CB008390

    Step0: Set Parameters
    Step1: Activate Fault 6506
    Step2: Check R&D Fault 6506 Is Active In RawAlarmHistory File
    Step3: Collect snapshot and check snapshot_ssdLogsDiskDump.Csv File Exist
    Step4: Deactivate Fault 6506
    Step5: Check R&D Fault 6506 Is Not Active In RawAlarmHistory File


Step0: Set Parameters
    Log  \nStep0: Set parameters.  console=true
    ${smod_l_dn}  Get Random SMOD_L
    ${stored_role}  Get StoredRole From MODULE_L  ${smod_l_dn}
    Set Test Variable  ${STORED_ROLE}
    ${smod_r_dn}  Get SMOD_R Dist_name From SMOD_L  ${smod_l_dn}
    Set Test Variable  ${SMOD_R_DN}
    ${date_time}  Get Current Date
    ${current_date_time}  Convert Date  ${date_time}  result_format=%Y-%b-%d %H:%M:%S
    Set Test Variable  ${CURRENT_DATE_TIME}


Step${index}: ${action} Fault 6506
    Log  \nStep${index}: ${action} fault 6506.  console=true
    Open SSH Connection And ${action} Fault 6506


Step2: Check R&D Fault 6506 Is Active In RawAlarmHistory File
    Log  \nStep2: Check R&D fault 6506 is active in RawAlarmHistory file.  console=true
    ${status_fault_object}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${TIMEOUT}  5
    ...  Verify Alarm In RawAlarmHistory File  6506  ${CURRENT_DATE_TIME}  ${SMOD_R_DN}
    Run Keyword If  ${status_fault_object}
    ...  Log  The R&D fault 6506 is active in RawAlarmHistory file on ${SMOD_R_DN}. [OK]  console=true
    ...  ELSE
    ...  Fail  The R&D fault 6506 is not active in RawAlarmHistory file on ${SMOD_R_DN}.[NOK]


Step3: Collect Snapshot And Check Snapshot_ssdLogsDiskDump.Csv File Exist
    Log  \nStep3: Collect snapshot and check snapshot_ssdLogsDiskDump.csv file exist.  console=true
    ${file}  Run Keyword If  '${STORED_ROLE}'=='Idle'
    ...  Set Variable  BTS${BTS_ID}_2011_runtime_sysinfo.zip
    ...  ELSE
    ...  Set Variable  BTS${BTS_ID}_1011_runtime_sysinfo.zip
    Collect Snapshot  ${BTS_FILES}/snapshot.zip  timeout=300
    Unzip  ${BTS_FILES}/snapshot.zip  ${BTS_FILES}/snapshot_dir/
    ${list_of_directories}  OperatingSystem.List Directory  ${BTS_FILES}/snapshot_dir/
    ${parent_file}  Get Directory Of File  ${list_of_directories}  ${file}
    ${file_name}  Fetch From Left  ${file}  .zip
    Unzip  ${BTS_FILES}/snapshot_dir/${parent_file}/${file}  ${BTS_FILES}/snapshot_dir/${parent_file}/${file_name}_dir
    ${directory_content}  OperatingSystem.List Directory  ${BTS_FILES}/snapshot_dir/${parent_file}/${file_name}_dir
    ${status_snapshot_file}  Run Keyword And Return Status
    ...  List Should Contain Value  ${directory_content}  snapshot_ssdLogsDiskDump.csv.xz
    Run Keyword If  ${status_snapshot_file}
    ...  Log  snapshot_ssdLogsDiskDump.csv.xz file exist in ${file}.[OK]  console=true
    ...  ELSE
    ...  Fail  snapshot_ssdLogsDiskDump.csv.xz file not exist.[NOK]


Get Directory Of File
    [Arguments]  ${list_of_directories}  ${file}

    FOR  ${directory}  IN  @{list_of_directories}
        ${directory_name}  Fetch From Left  ${directory}  .zip
        Unzip  ${BTS_FILES}/snapshot_dir/${directory}  ${BTS_FILES}/snapshot_dir/${directory_name}_dir
        ${directory_content}  OperatingSystem.List Directory  ${BTS_FILES}/snapshot_dir/${directory_name}_dir
        ${status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${directory_content}  ${file}
        Run Keyword If  ${status}
        ...  Return From Keyword  ${directory_name}_dir
    END


Step5: Check R&D Fault 6506 Is Not Active In RawAlarmHistory File
    Log  \nStep5: Check R&D fault 6506 is not active in RawAlarmHistory file.  console=true
    ${status_fault}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${TIMEOUT}  5
    ...  Verify Alarm In RawAlarmHistory File  6506  ${CURRENT_DATE_TIME}  ${SMOD_R_DN}  inactive
    Run Keyword If  ${status_fault}
    ...  Log  The R&D fault 6506 is in RawAlarmHistory file in Inactive faults. [OK]  console=true
    ...  ELSE
    ...  Fail  The R&D fault 6506 is in RawAlarmHistory file, but not in Inactive faults.[NOK]


Get Random SMOD_L
    ${smod_l_list}  Query Infomodel  get list //SMOD_L-*
    ${smod_list}  Create List
    Set Test Variable  ${SMOD_LIST}
    FOR  ${smod}  IN  @{smod_l_list}
        ${check_asib_type}  Run Keyword And Return Status
        ...  Should Contain  ${smod}[productName]  ASIB
        ${check_smod_type}  Run Keyword And Return Status
        ...  Should Match Regexp  ${smod}[productName]  (ASIL|ASOE|ASIM)
        Run Keyword If  ${check_asib_type}
        ...  Check If Smod Contains Log Partition  ${smod}  (A.102|A.203|A.204|M.02)
        ...  ELSE IF  ${check_smod_type}
        ...  Append To List  ${SMOD_LIST}  ${smod}[dist_name]
    END
    ${status_soc_list}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${SMOD_LIST}
    Run Keyword If  ${status_soc_list}==${FALSE}
    ...  Fail  There is no SMOD with log partition.
    ${smod_l_dn}  Evaluate  random.choice(${SMOD_LIST})  random

    [Return]  ${smod_l_dn}


Check If Smod Contains Log Partition
    [Arguments]  ${smod}  ${product_code_metch}

    ${check_product_code}  Run Keyword And Return Status
    ...  Should Match Regexp  ${smod}[productCode]  ${product_code_metch}
    Run Keyword If  ${check_product_code}
    ...  Append To List  ${SMOD_LIST}  ${smod}[dist_name]


Open SSH Connection And ${activate_deactivate} Fault 6506
    Open Connection To Primary Core
    Run Keyword If  '${STORED_ROLE}'=='Idle'
    ...  Open Connection To Secondary Core
    SSHLibrary.Set Client Configuration  prompt=>
    SSHLibrary.Write  cd /ffs/run/logs/oam/uri/planfiles
    SSHLibrary.Read Until Prompt
    Run Keyword If  '${activate_deactivate}'=='Activate'
    ...  Run Keywords
    ...  SSHLibrary.Write  fallocate -l 10M test.txt
    ...  AND
    ...  SSHLibrary.Read Until Prompt
    ...  AND
    ...  SSHLibrary.Close Connection
    ...  AND
    ...  Log  Fault is activated.  console=true
    ...  ELSE IF  '${activate_deactivate}'=='Deactivate'
    ...  Run Keywords
    ...  SSHLibrary.Write  rm test.txt
    ...  AND
    ...  SSHLibrary.Read Until Prompt
    ...  AND
    ...  SSHLibrary.Close Connection
    ...  AND
    ...  Log  Fault is deactivated.  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__Activation_deactivation_fault_6506


TC Teardown
    Common Test Teardown
