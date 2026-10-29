*** Settings ***
Documentation
    ...  Purpose of the test is to test changes introduced by feature CB008880 in case of NR RAT recovery reset.
    ...  In first step, site reset will be performed to clear all recovery reset counters.
    ...  In second step, CPCL software node will be crashed and RAT recovery reset will be checked for NR cells.
    ...  Alarm 7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION will be checked in WebEM and Netact.
    ...  In third and fourth step, CPNB and CPNRT software nodes will be crashed. Recovery action and alarm presence will be checked.
    ...  In fifth step, site reset will be performed to clear all recovery reset counters.
    ...  In last step, CPIF software node will be crashed. Recovery action and alarm presence will be checked.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to be reported in WebEM.
${CELLS_TIMEOUT}  180  # [in seconds] Timeout for cells to be in expected state.
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be reported in Netact.
${RECOVERY_TIMEOUT}  1200  # [in seconds] Timeout for SBTS to recover after RAT reset.


*** Keywords ***
TC__FM__B_5G_RAT_reset_counter_cleared__manual_site_reset
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-26982
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26982 - Initial TAT creation
    ...  - 21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27160 - Keyword enhancement in resource file
    ...  - 10.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27304 - Update fault signature check
    ...  - 15.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27496 - Alarm not found at fault signature check
    ...  - 17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27608 - Add check for fault signature
    ...  - 21.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28423 - Test fail because "faulty cells" are calculated after physicalId not lcrId
    ...  - 15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28985 - Crash method of the CPNRT process has changed
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  ******************

    Set Tags  CA-FM  OWNER-ioan.marta@nokia.com  AUTHOR-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB008880

    Step0: Set Parameters
    Step1: Perform Site Reset
    Step2: Crash CPCL Process And Verify Recovery
    Step3: Crash CPNB Process And Verify Recovery
    Step4: Crash CPNRT Process And Verify Recovery
    Step5: Perform Site Reset
    Step6: Crash CPIF Process And Verify Recovery


Step0: Set Parameters
    Log  Step0: Set parameters.  console=true
    Change FEATCADM Parameter  actRatResetEnhancement  true
    Set Test Variables For Fault Signature


Step${index}: Perform Site Reset
    Log  Step${index}: Perform site reset.  console=true
    Perform Site Reset
    IF  '${index}' == '5'
        Collect All Syslogs
        Start Syslog  alias=test_syslog
        ...  log_dir=${TEMP_LOGS_DIR}
        ...  log_name=SYSLOG_RAT_RESET
        ...  ip=192.168.255.126
        ...  ports=@{UDP_PORTS}
        ...  file_limit=0
    END


Step${index}: Crash ${name} Process And Verify Recovery
    Log  Step${index}: Crash ${name} process and verify recovery.  console=true
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=fault
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Crash ${name} Process
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    ${fault_background}  Run Keyword In Background  Assert alarm active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=fault
    ${state}  Catenate  operationalState=${DISABLED}  availabilityStatus=${FAILED}
    ${nr_cells_status}  Run Keyword And Return Status
    ...  Assert Every  NRCEL  ${state}  timeout=${CELLS_TIMEOUT}
    IF  ${nr_cells_status}
        Log  NR cells were failed. [OK]  console=true
    ELSE
        Fail  NR cells were not failed. [NOK]
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  30  Check Modules And Cells
    ${fault_status_webem}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${fault_background}  timeout=${ALARM_TIMEOUT}
    IF  ${fault_status_webem}
        Log  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] with name ${FAULT_4383_RAT_AUTO_RST}[fault_name] was reported in WebEM. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4383_RAT_AUTO_RST}[fault_id] with name ${FAULT_4383_RAT_AUTO_RST}[fault_name] was not reported in WebEM. [NOK]
    END
    Run Keyword And Continue On Failure  Teardown Admin  alias=fault
    ${fault_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_RAT_AUTO_RST}  time_from=${date_netact}
    ...  additional_fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Log  Verify fault signature of fault in WebEM and Netact.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  filtering_minor_field=${MINOR_ID_${name}}  category=${CATEGORY}
    ...  extra_info=${EXTRA_INFO}  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR_ID_${name}}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${date_netact}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR_ID_${name}}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}
    IF  '${index}' == '6'  Check Recovery Reset Counter In Syslog File


Set Test Variables For Fault Signature
    ${cells_string}  Get Matching Lcr Ids String For All RAT Cells  NRCEL
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=NR:${cells_string}
    ${sw_node_cpcl}  Query Infomodel  get object //SW_NODE_L-* is [rat=NR hostname=regex"CPCL"]
    ${sw_node_cpnb}  Query Infomodel  get object //SW_NODE_L-* is [rat=NR hostname=regex"CPNB"]
    ${sw_node_cpnrt}  Query Infomodel  get object //SW_NODE_L-* is [rat=NR hostname=regex"CPNRT"]
    ${sw_node_cpif}  Query Infomodel  get object //SW_NODE_L-* is [rat=NR hostname=regex"CPIF"]
    ${node_id_cpcl}  Convert To Hex  ${sw_node_cpcl}[nodeId]  prefix=0x
    ${node_id_cpnb}  Convert To Hex  ${sw_node_cpnb}[nodeId]  prefix=0x
    ${node_id_cpnrt}  Convert To Hex  ${sw_node_cpnrt}[nodeId]  prefix=0x
    ${node_id_cpif}  Convert To Hex  ${sw_node_cpif}[nodeId]  prefix=0x
    ${software}  Get Software Info
    ${active_sw}  Get From Dictionary  ${software}  Active SW version
    ${sw_variant}  Fetch From Left  ${active_sw}  _
    ${minor_id_cpcl}  Set Variable If  '${sw_variant}' < 'SBTS24R3'  ${node_id_cpcl}  ${node_id_cpcl}${SPACE}CPCL
    ${minor_id_cpnb}  Set Variable If  '${sw_variant}' < 'SBTS24R3'  ${node_id_cpnb}  ${node_id_cpnb}${SPACE}CPNB
    ${minor_id_cpnrt}  Set Variable If  '${sw_variant}' < 'SBTS24R3'  ${node_id_cpnrt}  ${node_id_cpnrt}${SPACE}CPNRT
    ${minor_id_cpif}  Set Variable If  '${sw_variant}' < 'SBTS24R3'  ${node_id_cpif}  ${node_id_cpif}${SPACE}CPIF
    Set Test Variable  ${MINOR_ID_CPCL}
    Set Test Variable  ${MINOR_ID_CPNB}
    Set Test Variable  ${MINOR_ID_CPNRT}
    Set Test Variable  ${MINOR_ID_CPIF}
    ${smod_l_dn}  Fetch From Left  ${sw_node_cpcl}[dist_name]  /SMOD_L-1
    ${smod_l_parameters}  Query Infomodel  get object ${smod_l_dn}/SMOD_L-1
    Set Test Variable  ${PRODUCT_NAME}  ${smod_l_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${smod_l_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod_l_parameters}[serialNumber]
    ${smod_r}  Query Infomodel  get object //SMOD_R-* is [serialNumber=${smod_l_parameters}[serialNumber]]
    Set Unit Position For Fault Signature  ${smod_r}[dist_name]
    Set Test Variable  ${EXPECTED_FAULT_ID}  ${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Set Test Variable  ${CATEGORY}  TIMEOUT
    Set Test Variable  ${SCOPE}  NR RAT
    Set Test Variable  ${INFO}  Node communication failure
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


Crash ${name} Process
    Log  Crash ${name} process.  console=true
    Open Connection To Primary Core
    IF  '${name}'=='CPNRT'
        Method To Crash CPNRT Process
    ELSE
        SSHLibrary.Write  ps aux | grep lxc
        ${output}  SSHLibrary.Read Until Prompt
        ${status}  Run Keyword And Return Status  Get Lines Containing String  ${output}  ${name}
        IF  '${status}' == 'False'  Open Connection To Secondary Core
        ${lines}  Get Lines Containing String  ${output}  ${name}
        ${root}  Get Regexp Matches  ${lines}  root *[0-9]*
        ${process_id}  Evaluate  random.choice(${root})  random
        ${id}  Get Regexp Matches  ${process_id}  [0-9]+
        SSHLibrary.Write  kill -9 ${id}[0]
        SSHLibrary.Read Until Prompt
    END


Check Recovery Reset Counter In Syslog File
    ${nr_bts}  Query Infomodel  get object //NRBTS_R-*
    ${syslog_collected}  Run Keyword And Return Status
    ...  Collect Syslog Results  alias=test_syslog  destination=${UDP_LOGS}/syslog_rat_reset  unzip=true
    IF  ${syslog_collected}
        Log  Syslog file is collected.  console=true
    ELSE
        Fail  Syslog file is not collected. [NOK]
    END
    ${reset_counter_matches}  Grep File  ${UDP_LOGS}/syslog_rat_reset/SYSLOG_RAT_RESET  ResetCounter  encoding_errors=replace
    Should Contain  ${reset_counter_matches}  [ResetCounter #0#] Reset counter for ${nr_bts}[dist_name] is: 0
    ...  msg=Reset counter not found in syslogs.[NOK]
    Log  Reset counter found in syslogs.  console=true


Method To Crash CPNRT Process
    SSHLibrary.Write  ps -eaf | grep CPNRT
    ${output_node_id}  SSHLibrary.Read Until Prompt
    ${status}  Run Keyword And Return Status  Get Lines Containing String  ${output_node_id}  node_CPNRT
    IF  '${status}'=='False' and '${ENB_BRANCH}'<='SBTS25R3'
        Open Connection To Secondary Core
        SSHLibrary.Write  ps -eaf | grep CPNRT
        ${output_node_id}  SSHLibrary.Read Until Prompt
    END
    ${match}  Get Regexp Matches  ${output_node_id}  \/ram\/node_CPNRT.?[0-9]+\/[a-z.]+ -n 0x[0-9]{4}
    ${node_id}  Get Regexp Matches  ${match}[0]  0x[0-9]{4}
    SSHLibrary.Write  lxc-attach -n ${node_id}[0]
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ps -aux
    ${output}  SSHLibrary.Read Until Prompt
    ${lines}  Split To Lines  ${output}
    FOR  ${line}  IN  @{lines}
        ${lines_node_id}  Get Lines Containing String  ${line}  --startup=nid=${node_id}[0]
        ${status}  Run Keyword And Return Status  Should Not Be Empty  ${lines_node_id}
        IF  ${status}
            ${split}  Split String  ${lines_node_id}
            Set Test Variable  ${PID}  ${split}[1]
            BREAK
        ELSE
            CONTINUE
        END
    END
    SSHLibrary.Write  kill -9 ${PID}
    SSHLibrary.Read Until Prompt


TC Setup
    Common Test Setup  tc_name=FM__B_5G_RAT_reset_counter_cleared__manual_site
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Site Reset
    Teardown NetAct
    Common Test Teardown
