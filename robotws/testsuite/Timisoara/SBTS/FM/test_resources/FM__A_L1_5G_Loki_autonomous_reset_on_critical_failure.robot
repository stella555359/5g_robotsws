*** Settings ***
Documentation
    ...  This test is created to perform failure on 5G Loki.
    ...  Site reset is performed to clear all recovery reset counters.
    ...  One 5G cell is taken randomly, the cell must be deployed on ABIO/ABIN BBMOD and its hwVariant has to be Loki
    ...  bsh, ps aux and kill commands are used to perform the failure.
    ...  The number of failed cells and alarm status are verified.
    ...  After failure, SoC autonomous reset as recovery action is performed, and SBTS must be on air.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after site reset
${NETACT_TIMEOUT}  180  # Timeout for alarm to appear in Netact
${BBMOD_TYPE}  ${EMPTY}  # BBMOD type


*** Keywords ***
TC__FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22433
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  23.12.2021 - https://jira3.int.net.nokia.com/browse/TAT-22433 - Initial TAT creation
    ...  01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  30.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23337 - Return object not found
    ...  26.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24003 - Resolve duplicate keywords
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  01.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26604 - Add other BBMOD type and fault signature checking
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27160 - Keyword enhancement in resource file
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  05.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29639 - Updated fault signature verification
    ...  08.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30174 - Loki SoC correctly selected and connected
    ...  09.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30174 - Device name variable removed
    ...  25.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30568 - Verification for SOC cells changed + optimization
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS22R2

    Step 0: TC Prerequisites
    Step 1: Critical Failure On L1 5G Loki
    Step 2: Verify Fault Signature In WebEM And Netact
    Step 3: Verify SBTS On Air


Step 0: TC Prerequisites
    Log  \nStep 0: TC Prerequisites.  console=true

    ${cells}  Get Cells Info  nr
    ${nr_cells_m_list}  Create List
    FOR  ${cell}  IN  @{cells}
        ${carrier_list}  Set Variable  ${cell}[carrierList]
        ${cell_m}  Fetch From Left  ${carrier_list}[0][id][internal]  /CHANNEL_GROUP
        Append To List  ${nr_cells_m_list}  ${cell_m}
    END
    ${soc_dn}  Get Soc To Kill  ${nr_cells_m_list}  ${BBMOD_TYPE}
    IF  '${soc_dn}'=='${None}'  Fail  There is no ${BBMOD_TYPE} with NR on SBTS.
    Set Test Variable  ${SOC_DN}  ${soc_dn}
    ${dsp_parameters}  coam.Get Parameters  ${SOC_DN}/SYNC_L-1
    ${node_id}  Convert To Hex  ${dsp_parameters}[nodesList][0][nodeId]
    Set Test Variable  ${NODE_ID}  0x${node_id}
    Set Test Variable  ${PRODUCT_NAME}  ${BBMOD_PARAMETERS}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${BBMOD_PARAMETERS}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${BBMOD_PARAMETERS}[productCode]
    ${value}  Fetch From Left  ${BBMOD_L_DN}  /EQM
    ${value_bts_l}  Fetch From Right  ${value}  RAT-1/
    ${bbmod_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${BBMOD_L_DN}
    Set Unit Position For Fault Signature  ${bbmod_r_dn}
    ${bbmod_position}  Get Module Vertical Position  ${bbmod_r_dn}
    ${soc_position}  Get SOC Position  ${SOC_DN}  ${PRODUCT_NAME}
    Set Test Variable  ${BTS_L_ID}  ${value_bts_l}
    Set Test Variable  ${BBMOD_POSITION}  ${bbmod_position}
    Set Test Variable  ${SOC_POSITION}  ${soc_position}
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=(.*LTE:[0-9]+.*,)?.*NR:[0-9]+.*
    Set Test Variable  ${SCOPE}  SoC
    Set Test Variable  ${CATEGORY}  SW_FAILURE

    Perform Site Reset


Step 1: Critical Failure On L1 5G Loki
    Log  \nStep 1: Performing kill command on SOC with Loki and NR.  console=true

    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}

    Open Ssh Connection And Perform Kill Command
    ${cells_on_soc}  Get Cell Mapping By Module Id  ${SOC_DN}
    Wait Until Keyword Succeeds  180s  10s  Verify Cells On SOC  ${cells_on_soc}  ${DISABLED}  ${FAILED}
    ${fault_2087_parameters}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
    Assert Alarm Active  parameters=${fault_2087_parameters}  timeout=180
    Log  Fault ${FAULT_2087_SOC_AUTO_RST} is active in WebEM.  console=true
    Wait Until Keyword Succeeds  300  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2087_SOC_AUTO_RST}
    ...                                                                               time_from=${START_TIME}
    ...                                                                               additional_fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_2087_SOC_AUTO_RST} was active in NetAct.  console=true


Step 2: Verify Fault Signature In WebEM And Netact
    Log  \nStep 2: Verify fault signature in WebEM and Netact.  console=true

    Sleep  60s  Wait until alarm is cleared and should be found in Alarm History.
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  minor=${NODE_ID}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  time_from=${START_TIME}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${NODE_ID}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Step 3: Verify SBTS On Air
    Log  \nStep 3: Verifying SBTS state - on air.  console=true

    ${status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  300s  20s  Check Modules And Cells
    IF  ${status}
        Log  Site up and running after SoC autonomous reset.  console=true
    ELSE
        Fail  Site didn't manage to reset after SoC autonomous reset.
    END


Get Soc To Kill
    [Arguments]  ${nr_cells_list}  ${bbmod_type}

    FOR  ${cell}  IN  @{nr_cells_list}
        ${list_pool_distnames}  Get Cell To Pool Mapping List Of The Given Cell  ${cell}
        ${soc_dn}  Get SoC Dn If Core Pool DN Is Connecting The Loki SoC  ${list_pool_distnames}  ${bbmod_type}
        IF  '${soc_dn}'!='${None}'  BREAK
    END

    RETURN  ${soc_dn}


Get Cell To Pool Mapping List Of The Given Cell
    [Arguments]  ${cell_m_dn}

    ${all_nrts}  coam.Get Managed Objects  NRTS
    FOR  ${nrts}  IN  @{all_nrts}
        ${status}  Run Keyword And Return Status  Should Contain  ${nrts}[parameters][productVariant]  sBTS
        IF  ${status}
            ${nrts_dn}  Set Variable  ${nrts}[distName]
            BREAK
        ELSE
            CONTINUE
        END
    END
    ${cells_to_pool_mapping}  coam.Get Managed Objects  CELL_TO_POOL_MAPPING_L
    ${list_cell_to_pool_map}  Create List
    FOR  ${cell_to_poll_mapping}  IN  @{cells_to_pool_mapping}
        ${status_nrts}  Run Keyword And Return Status  Should Contain  ${cell_to_poll_mapping}[distName]  ${nrts_dn}
        ${status_cell_dn}  Run Keyword And Return Status  Should Contain  ${cell_to_poll_mapping}[parameters][cellDN]  ${cell_m_dn}
        IF  ${status_nrts} and ${status_cell_dn}
            ${cell_slots}  Set Variable  ${cell_to_poll_mapping}[parameters][cellSlots]
            ${list_pool_distnames}  Get Core Pool DistNames  ${cell_slots}
            BREAK
        ELSE
            CONTINUE
        END
    END
    ${list_pool_distnames}  Remove Duplicates  ${list_pool_distnames}

    RETURN  ${list_pool_distnames}


Get Core Pool DistNames
    [Arguments]  ${cell_slots}

    ${list_pool_distnames}  Create List
    FOR  ${cell_slot}  IN  @{cell_slots}
        Append To List  ${list_pool_distnames}  ${cell_slot}[poolDN]
    END

    RETURN  ${list_pool_distnames}


Get SoC Dn If Core Pool DN Is Connecting The Loki SoC
    [Arguments]  ${core_pool_distnames}  ${bbmod_type}

    FOR  ${core_pool_dn}  IN  @{core_pool_distnames}
        ${core_pool_parameters}  coam.Get Parameters  ${core_pool_dn}
        ${sw_node_schema}  Set Variable  ${core_pool_parameters}[cores][0][coreDN]
        ${sw_node_schema_parameters}  coam.Get Parameters  ${sw_node_schema}
        ${soc_l_dn}  Set Variable  ${sw_node_schema_parameters}[deploymentTargetDn]
        ${soc_l_dn_parameters}  coam.Get Parameters  ${soc_l_dn}

        IF  '${bbmod_type}'=='ABIO'
            ${bbmod_dn}  Fetch From Left  ${soc_l_dn}  /BBU_L
        ELSE
            ${bbmod_dn}  Fetch From Left  ${soc_l_dn}  /BOARD_L
        END
        ${bbmod_parameters}  coam.Get Parameters For  BBMOD  ${bbmod_dn}
        ${bbmod_status}  Run Keyword And Return Status  Should Contain  ${bbmod_parameters}[productName]  ${bbmod_type}

        IF  '${soc_l_dn_parameters}[hwVariant]' == 'Loki' and ${bbmod_status}
            Set Test Variable  ${BBMOD_L_DN}  ${bbmod_dn}
            Set Test Variable  ${BBMOD_PARAMETERS}
            RETURN  ${soc_l_dn}
        ELSE
            CONTINUE
        END
    END

    RETURN  ${None}


Open Ssh Connection And Perform Kill Command
    ${stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L_DN}
    Open Connection To Primary Core
    IF  '${stored_role}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SoC  ${BBMOD_POSITION}  ${SOC_POSITION}
    ${name_process}  Kill Process On SOC  l1  application_
    Set Test Variable  ${INFO}  failed${SPACE}process:${SPACE}${name_process};${SPACE}got signal:${SPACE}11


Verify Cells On SOC
    [Arguments]  ${soc_cells}  ${op_state}  ${av_status}

    ${list_affected_cells}  Create List
    FOR  ${cell}  IN  @{soc_cells}
        ${affected_cell_obj}  coam.Get Parameters  ${cell}
        ${op_state_status}  Run Keyword And Return Status  Should Contain  ${op_state}  ${affected_cell_obj}[operationalState]
        ${av_status}  Run Keyword And Return Status  Should Contain  ${av_status}  ${affected_cell_obj}[availabilityStatus]
        IF  ${op_state_status} and ${av_status}
            Append To List  ${list_affected_cells}  ${cell}
        ELSE
            CONTINUE
        END
    END
    ${no_failed_cells}  Get Length  ${list_affected_cells}
    IF  ${no_failed_cells} == 0  Fail  No failed cells found on SOC after crash on 5G Loki.


TC Setup
    Common Test Setup  tc_name=FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
