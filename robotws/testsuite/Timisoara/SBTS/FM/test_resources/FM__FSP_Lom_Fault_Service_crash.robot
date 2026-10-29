*** Settings ***
Documentation
    ...  Test Case scope is to verify the supervision functionality so that failures of LOM Fault Service,
    ...  can be detected during SBTS runtime and autorecovery is triggered : SOC reset/FSP reset is performed in case of FSP LOM crash
    ...  One of the FSPs will be selected randomly. After sending fault, check that the FSP is disabled an cells on FSP are disabled.
    ...  In the end, TC will wait until SBTS is reaching onAir state.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${BBMOD_TYPE}  ${EMPTY}  # Mandatory. Could be FBBA, FBBC, ABIA, ABIC, ABIL, ABIN, ABIO, ABIP.
${RECOVERY_TIMEOUT}  900  # Time for SBTS to reach onAIr state


*** Keywords ***
TC__FM__FSP_Lom_Fault_Service_crash
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25198
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  27.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25198 -Initial TAT creation
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add faults defined in py file
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  12.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29198 - Kill the process with the lowest pid
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29766 - Added core variables for fault signature
    ...  21.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30161 - Adjust variables for the fault signature
    ...  ******************

    Set Tags  CA-FM  OWNER-virgil.blot@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS23  FEATURE-CNI93958

    Step0: Set Parameters
    Step1: Trigger Crash Fsp
    Step2: Check Cells And Fsp And Wait Until SBTS Is OnAir


Step0: Set Parameters
    Log  \nStep0: Set parameters.  console=true
    IF  '${BBMOD_TYPE}'=='${EMPTY}'  Fail  Please provide BBMOD type (FBBA/FBBC/ABIA/ABIC/ABIL/ABIO/ABIN/ABIP).
    ${bbmod_r_object}  Get Random Module Based On Its Type  ${BBMOD_TYPE}  BBMOD
    ${bbmod_r_dn}  Set Variable  ${bbmod_r_object}[id]
    ${bbmod_position}  Get Module Vertical Position  ${bbmod_r_dn}
    Set Test Variable  ${BBMOD_POSITION}
    ${bbmod_l_dn}  Get Module L Dist Name  ${bbmod_r_object}[serialNumber]  BBMOD
    Set Test Variable  ${BBMOD_L_DN}
    ${cells_list_on_fsp}  Get Cell Mapping By Module Id  ${bbmod_r_dn}
    Set Test Variable  ${CELLS_LIST_ON_FSP}
    Set Variables For Fault Signature
    Perform Site Reset


Step1: Trigger Crash Fsp
    Log  \nStep1: Trigger FSP crash.  console=true
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}
    ${stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L_DN}
    Open Connection To Primary Core
    IF  '${stored_role}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SOC  ${BBMOD_POSITION}  0
    Trigger Crash Lom Fault Service


Step2: Check Cells And Fsp And Wait Until SBTS Is OnAir
    Log  \nStep2: Check cells and fsp and wait until SBTS is onAir.  console=true
    ${affected_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${CELLS_LIST_ON_FSP}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    IF  ${affected_cells_status}
        Log  Affected cells are failed. [OK]  console=true
    ELSE
        Fail  Affected cells are not failed. [NOK]
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Admin Check All Required State
    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_BB_AUTO_RST}[fault_id]  category=${CATEGORY}
    ...  extra_info=${EXTRA_INFO}  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}
    ...  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  core_serial_number=${CORE_SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  core_vendor_unit_number=${CORE_PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_BB_AUTO_RST}[fault_id]  time_from=${START_TIME}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  core_serial_number=${CORE_SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  core_vendor_unit_number=${CORE_PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Set Variables For Fault Signature
    ${module_l_parameters}  coam.Get Parameters  ${BBMOD_L_DN}
    ${module_r_dn}  Get Module Dist Name By Serial Number And Class  ${module_l_parameters}[serialNumber]  BBMOD
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${module_l_parameters}[productCode]
    ${module_r_parameters}  coam.Get Parameters  ${module_r_dn}
    Set Test Variable  ${CORE_SERIAL_NUMBER}  ${module_r_parameters}[coreHwBoardSerialNumber]
    Set Test Variable  ${CORE_PRODUCT_CODE}  ${module_r_parameters}[coreHwBoardProductCode]
    Set Unit Position For Fault Signature  ${module_r_dn}
    Set Test Variable  ${MINOR}  .*(CPUA)?.*(NRT)?.*
    Set Test Variable  ${INFO}  lom-fault
    Set Test Variable  ${SCOPE}  Board
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=(.*LTE:[0-9]+.*)?.*NR:[0-9]+.*
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


Trigger Crash Lom Fault Service
    SSHLibrary.Set Client Configuration  prompt=~ >
    SSHLibrary.Set Client Configuration  timeout=10s
    SSHLibrary.Write  ps -eaf | grep FaultServiceExe
    ${output}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${output}  /opt/FaultServiceExe/FaultServiceExe
    ${btssw}  Get Regexp Matches  ${lines}  btssw *[0-9]*
    Should Not Be Empty  ${btssw}  msg=Process ids not found on SOC. [NOK]
    ${ids}  Create List
    FOR  ${item}  IN  @{btssw}
    	${item}  Fetch From Right  ${item}  ${SPACE}
    	${item}  Convert To Integer  ${item}
    	Append To List  ${ids}  ${item}
    END
    Sort List  ${ids}
    ${min_id}  Set Variable  ${ids}[0]
    SSHLibrary.Write  kill -9 ${min_id}
    SSHLibrary.Read Until Prompt


TC Setup
    Common Test Setup  tc_name=FM__FSP_Lom_Fault_Service_crash
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
