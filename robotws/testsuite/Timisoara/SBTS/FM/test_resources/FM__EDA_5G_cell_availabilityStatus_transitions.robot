*** Settings ***
Documentation
    ...  Test is designed check the state transition of 5G cells from: Degraded -> Failed -> Offline -> Online.
    ...  In first step, test will trigger fault on RU antenna resulting in degraded 5G cell. Fault 1911 RX out of order will be triggered on ANTL-1.
    ...  Alarm presence in WebEM and Netact will be checked for fault on RMOD, affected cells transision will be checked by test.
    ...  In second step, test will trigger indirect RU reset resulting in the clearance of the faulty situation.
    ...  Fault 2087 SoC autonomous reset as recovery action will be triggered on BBMOD where RMOD is connected, resulting in RMOD reset.
    ...  Alarm presence and fault signature in WebEM and Netact will be checked for fault on BBMOD, affected cells transision will be checked by test

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
@{BBMOD_LIST}  ABIA  ABIO  ABIP  # BBMOD type where RMOD is connected
@{ACCEPTED_CELLS_LIST}  NR  LTE  WCDMA  GSM  # Cells type that are mapped on RMOD
${ALARM_TIMEOUT}  180  # [in seconds] Timeout for alarm to appear in WebEm
${NETACT_TIMEOUT}  300  # [in seconds] Timeout for alarm to appear in Netact
${CELLS_TIMEOUT}  300  # [in seconds] Timeout for cells to be in expected state
${RECOVERY_TIMEOUT}  300  # [in seconds] Timeout for SBTS to recover after crash


*** Keywords ***
TC__FM__EDA_5G_cell_availabilityStatus_transitions
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26733
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  18.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26733 - Initial TAT creation
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27160 - Keyword enhancement in resource file
    ...  08.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27310 - Update fault signature check
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  22.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27973 - Variable not found
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  22.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29213 - Replace RMOD info search from /rom/config/FRIps.txt
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29766 - Added core variables for fault signature
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS24

    Step 0: Testcase Preconditions
    Step 1: Trigger Fault On OBSAI Radio
    Step 2: Trigger L1 Process Crash


Step 0: Testcase Preconditions
    Log  \nStep 0: Testcase preconditions.  console=true
    ${rmod_sn}  ${affected_bbmods_list}  Get Random RMOD Details By Given RMOD Type, BBMODs List And Accepted Cells List  ^F[A-Z]{3,4}  ${BBMOD_LIST}
    ...  ${ACCEPTED_CELLS_LIST}
    ${rmod_dn}  Get Module Dist Name By Serial Number And Class  ${rmod_sn}  RMOD
    ${antl_cells}  Get Cell Mapping By Module Id  ${rmod_dn}/ANTL_R-1
    FOR  ${bbmod_r}  IN  @{affected_bbmods_list}
        ${bbmod_parameters}  coam.Get Parameters For  BBMOD  ${bbmod_r}
        ${bbmod_status}  Run Keyword And Return Status
        ...  Should Not Contain  ${bbmod_parameters}[productName]  ABIA
        IF  ${bbmod_status}
            ${bbmod_dn}  Fetch From Left  ${bbmod_r}  ${SPACE}
            BREAK
        END
    END
    ${bbmod_sn}  Set Variable  ${bbmod_parameters}[serialNumber]
    ${swnode_type}  Catenate  SEPARATOR=${SPACE}  applicationGroup=Platform,  variant=L1Software
    ${bbmod_l}  Query Infomodel  get object //BBMOD_L-* is [serialNumber=${bbmod_sn}]
    ${abip_status}  Run Keyword And Return Status  Should Contain  ${bbmod_l}[productName]  ABIP
    ${bbmod_position}  Get Module Vertical Position  ${bbmod_dn}
    IF  ${abip_status}
        ${soc_position}  Set Variable  1
    ELSE
        ${soc_position}  Get SoC Possition  ${bbmod_dn}  ${rmod_dn}
    END
    Set Unit Position For Fault Signature  ${bbmod_dn}
    Set Test Variable  ${PRODUCT_NAME}  ${bbmod_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${bbmod_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${bbmod_parameters}[productCode]
    Set Test Variable  ${RMOD_SN}
    Set Test Variable  ${RMOD_DN}
    Set Test Variable  ${ANTL_CELLS}
    Set Test Variable  ${BBMOD_POSITION}
    Set Test Variable  ${SOC_POSITION}
    Set Test Variable  ${NODE_ID}  0x[0-9A-Z]+
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=(.*LTE:[0-9]+.*,)?.*NR:[0-9]+.*
    Set Test Variable  ${SCOPE}  SoC
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Log  Chosen RMOD serial number is: ${RMOD_SN}.  console=true
    Log  Chosen RMOD dist name is: ${RMOD_DN}.  console=true
    Log  RMODs cells mapped on ANTL-1 are: ${ANTL_CELLS}.  console=true
    Log  Affected BBMOD is: ${bbmod_dn}.  console=true
    Perform Site Reset


Step 1: Trigger Fault On OBSAI Radio
    Log  \nStep 1: Trigger fault on OBSAI radio.  console=true
    ${fault_radio_reset}  Get String With Alarm Parameters  ${FAULT_1911}
    Trigger Fault On ANTL-1
    Assert Alarm Active  parameters=${fault_radio_reset}  timeout=${ALARM_TIMEOUT}
    Log  Fault 1911 - ${FAULT_1911}[fault_name] is active in WebEM. [OK]  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_1911}  additional_fault_id=${FAULT_1911}[fault_id]
    Log  Fault 1911 - ${FAULT_1911}[fault_name] is active in NetAct. [OK]  console=true

    Wait Until Keyword Succeeds  300s  10s
    ...  Assert  RMOD  ${RMOD_DN}  parameters=operationalState=${ENABLED}
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}s  10s
    ...  Check AvailabilityStatus Status Of Cells Mapped On ANTL-1  ${ANTL_CELLS}  ${DEGRADED}


Step 2: Trigger L1 Process Crash
    Log  \nStep 2: Trigger L1 process crash.  console=true
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=check_warm_reset
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
    ${alarm_webem}  Run Keyword In Background  Assert alarm active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=check_warm_reset
    Open Ssh Connection And Perform Kill Command
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}s  10s
    ...  Check AvailabilityStatus Status Of Cells Mapped On ANTL-1  ${ANTL_CELLS}  ${FAILED}
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}s  10s
    ...  Check AvailabilityStatus Status Of Cells Mapped On ANTL-1  ${ANTL_CELLS}  ${OFFLINE}

    ${status_alarm_webem}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${alarm_webem}  timeout=${ALARM_TIMEOUT}
    IF  ${status_alarm_webem}
        Log  Fault 2087 - ${FAULT_2087_SOC_AUTO_RST}[fault_name] was reported in WebEm. [OK]  console=true
    ELSE
        Fail  Fault 2087 - ${FAULT_2087_SOC_AUTO_RST}[fault_name] was not reported in WebEm. [NOK]
    END

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2087_SOC_AUTO_RST}  time_from=${date_netact}
    ...  suppl_info=[A-Za-z]+ SoC_[A-Za-z] autonomous reset  additional_fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]
    Log  Fault 2087 - ${FAULT_2087_SOC_AUTO_RST}[fault_name] was reported in NetAct. [OK]  console=true

    Log  Verify fault signature of fault in WebEM and Netact.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  minor=${NODE_ID}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  time_from=${date_netact}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${NODE_ID}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}

    ${status_recovery}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}s  20s
    ...  Check Modules And Cells
    IF  ${status_recovery}
        Log  Site reached on air state after recovery action. [OK]  console=true
    ELSE
        Fail  Site didn't manage to reach on air state. [NOK]
    END


Get SoC Possition
    [Arguments]  ${bbmod_dist_name}  ${rmod_dist_name}

    ${all_cablinks}  Query Infomodel  get list //CABLINK_R-* is [firstEndpointDN=${bbmod_dist_name}, secondEndpointDN=${rmod_dist_name}]
    ${cablink}  Evaluate  random.choice(${all_cablinks})  random
    ${port}  Set Variable  ${cablink}[firstEndpointPortId]
    ${position}  Set Variable If  ${port}<=6  1  2

    RETURN  ${position}


Trigger Fault On ANTL-1
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    Connect To RMOD Through Lxc-attach And Telnet Using Rmod Ip, Side And Port  ${rmod_ip}  ${smod_side}  2323  ${stored_role}
    SSHLibrary.Write  sendFault 1130 1 0 0 0 0 0
    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections
    Log  Fault was sent on RMOD.  console=true


Check AvailabilityStatus Status Of Cells Mapped On ANTL-1
    [Arguments]  ${cells}  ${status}

    FOR  ${cell}  IN  @{cells}
        ${cell_parameters}  coam.Get Parameters  ${cell}
        ${degraded_status}  Run Keyword And Return Status
        ...  Should Contain  ${status}  ${cell_parameters}[availabilityStatus]
        IF  ${degraded_status}==${FALSE}
            Fail  Cell is not correct state: ${status}=!${cell_parameters}[availabilityStatus]. [NOK]
        END
    END
    Log  All cells mapped on ANTL-1 have correct state. [OK]  console=true


Open Ssh Connection And Perform Kill Command
    Open Connection To Primary Core
    Open Connection To SoC  ${BBMOD_POSITION}  ${SOC_POSITION}
    ${name_process}  Kill Process On SOC  l1  application_
    SSHLibrary.Close All Connections
    Set Test Variable  ${INFO}  failed${SPACE}process:${SPACE}${name_process};${SPACE}got signal:${SPACE}11


TC Setup
    Common Test Setup  tc_name=FM__EDA_5G_cell_availabilityStatus_transitions
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Site Reset
    Teardown NetAct
    Common Test Teardown
