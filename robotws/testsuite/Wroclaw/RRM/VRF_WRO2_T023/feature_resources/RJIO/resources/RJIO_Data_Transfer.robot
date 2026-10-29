*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     String
Library     OperatingSystem
Resource    ../../../resources/ca_INTER_RAT.robot
Resource    ../../../resources/attenuator.robot


*** Keywords ***
Data Transfer On RJIO
    [Arguments]    ${dum1}=None    ${dum2}=None
    Log  dum1=${dum1}, dum2=${dum2}
    ${original_log_level} =  Set Log Level  TRACE
    Run Keyword If  ${L3_CALL_FOR_LAST_RMOD}  Return From Keyword If  '${i}' != '${RMOD_AMOUNT}'

    Log  Performing Data Transfer - Start  console=True
    Preconditions - Data Transfer On RJIO
    Step 1: Perform DL And UL Data Transfer - Data Transfer On RJIO
    Step 2: Check Throughputs - Data Transfer On RJIO

    [Teardown]    Run Keywords  Run Keyword If  '${i}' == '${RMOD_AMOUNT}' or not ${L3_CALL_FOR_LAST_RMOD}
    ...  Step 3: Stop Data Transfer, Collect Logs And Set Max Attenuation - Data Transfer On RJIO
    ...  AND  Set Log Level  ${original_log_level}


Data Transfer On RJIO For CSV4ALL
    [Arguments]    ${dum1}=None
    Set Test Variable  ${ADMIN_TEARDOWN_FOR_L3_CALL}  False
    Log  dum1=${dum1}
    ${original_log_level} =  Set Log Level  TRACE
    Run Keyword If  ${L3_CALL_FOR_LAST_RMOD}  Return From Keyword If  '${CSV4ALL_CURRENT_ITERATION}' != '${RMOD_AMOUNT}'

    Log  Performing Data Transfer - Start  console=True
    Preconditions - Data Transfer On RJIO
    Step 1: Perform DL And UL Data Transfer - Data Transfer On RJIO
    Step 2: Check Throughputs - Data Transfer On RJIO

    [Teardown]    Run Keywords  Run Keyword If  '${CSV4ALL_CURRENT_ITERATION}' == '${RMOD_AMOUNT}' or not ${L3_CALL_FOR_LAST_RMOD}
    ...  Teardown Data Transfer On RJIO
    ...  AND  Set Log Level  ${original_log_level}


Teardown Data Transfer On RJIO
    Step 3: Stop Data Transfer, Collect Logs And Set Max Attenuation - Data Transfer On RJIO
    Run Keyword If  '${UE_TYPE}' == 'iphone'  Collect And Save Baseband Logs For Iphone  NR_UE
    Run Keyword If  '${ADMIN_TEARDOWN_FOR_L3_CALL}'  Teardown Admin  connection=l3_call
    Set Test Variable  ${ADMIN_TEARDOWN_FOR_L3_CALL}  False


Preconditions - Data Transfer On RJIO
    Set Test Variable    ${WIRESHARK_STARTED}    False
    Start Wireshark Log Collection For IWK Test
    ...  options=-i any host ${MPLANE} and not udp port 2152 -s 0 -W 1
    ...  replace_enb=False  replace_gnb=False
    Set Test Variable    ${WIRESHARK_STARTED}    True

    Log  Set attenuation on ports. console=True
    Set Attenuation For All Cells  100%
    Set Attenuation  ${CELL_ALIAS}  ${0}

    _choose ue type helper
    ${ue_capabilities} =  Create List  QUALCOMM_ON_PIGTAILS  ${ADDITIONAL_UE_CAPABILITY}
    Log  Require UE. console=True
    Require_Ue   ue_alias=NR_UE   capabilities=${ue_capabilities}
    Run Keyword If  '${UE_TYPE}' == 'iphone'  Remove Baseband Logs    NR_UE

    Set Test Variable  ${ADMIN_TEARDOWN_FOR_L3_CALL}  True
    Setup Admin  bts_host=192.168.255.129  admin_api_log_dir=${OUTPUT DIR}/${TEST_NAME}/admin_logs_attach  alias=l3_call


_choose ue type helper
    IF  '${ADDITIONAL_UE_CAPABILITY}' == 'REAL_IPHONE_UE'
        Set Test Variable  ${UE_TYPE}  iphone
    ELSE
        Set Test Variable  ${UE_TYPE}  android
    END


Step 1: Perform DL And UL Data Transfer - Data Transfer On RJIO
    Log  \n==== Step 1: Perform DL And UL Data Transfer - Data Transfer On RJIO ====  console=True

    Get UE Info  NR_UE  ALL
    Log  Perform attach to cell ${NR_CELL_ID}. console=True
    Prepare UE For Data Transfer  NR_UE  ${NR_CELL_ID}  connection=l3_call  apn=${APN_CONTAINS}  ue_type=${UE_TYPE}
    ...  lte_cell=False
    ${apn} =  Get Full APN Name For UE  ${APN_CONTAINS}  ue_alias=NR_UE
    Start Data Transfer  NR_DL  NR_UE  dl  throughput=60 Mbits/sec  duration=180s
    ...  protocol=udp  packet=1400  parallel_streams=4  buffer=32M  apn=${apn}
    Log  -DL started-  console=True
    Start Data Transfer  NR_UL  NR_UE  ul  throughput=25 Mbits/sec  duration=180s
    ...  protocol=udp  packet=1400  parallel_streams=4  buffer=32M  apn=${apn}
    Log  -UL started-  console=True
    Sleep    60s


Step 2: Check Throughputs - Data Transfer On RJIO
    Log  \n==== Step 2: Check Throughputs - Data Transfer On RJIO ====  console=True

    Get UE Info  NR_UE  ALL
    Log  Check if data transfer is alive.  console=True
    Check Data Transfer Is Alive  NR_DL
    Check Data Transfer Is Alive  NR_UL
    Log  Check throughput.  console=True
    ${nr_dl_tput}  Get Average Throughput  NR_DL
    ${nr_dl_tput} =  Evaluate  ${nr_dl_tput}/1000.0
    ${nr_ul_tput}  Get Average Throughput  NR_UL
    ${nr_ul_tput} =  Evaluate  ${nr_ul_tput}/1000.0
    Log    \nDL TPUT: ${nr_dl_tput} Mbps \nUL TPUT: ${nr_ul_tput} Mbps   console=True
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation
    ...  NR_DL  ${NR_EXPECTED_DL_TPUT} Mbits/sec  85%  10
    Run Keyword And Continue On Failure  Verify Average Throughput With Deviation
    ...  NR_UL  ${NR_EXPECTED_UL_TPUT} Mbits/sec  80%  10


Step 3: Stop Data Transfer, Collect Logs And Set Max Attenuation - Data Transfer On RJIO
    Log  \n==== Step 3: Stop Data Transfer, Collect Logs And Set Max Attenuation - Data Transfer On RJIO ====  console=True

    Get UE Info  NR_UE  ALL
    Stop Data Transfer  NR_DL
    Stop Data Transfer  NR_UL
    Detach UE  NR_UE
    Set Attenuation For All Cells  100%
    Sleep  10s  reason=Wait for any possibly hanging resources to be cleared after attenuation.
    Run Keyword And Continue On Failure  Check Hanging Resources
    Run Keyword If  ${WIRESHARK_STARTED}
    ...    Stop Wireshark Log Collection For IWK Test  ${OUTPUT DIR}/${TEST_NAME}/pcap
    Log  Performing Data Transfer - End  console=True


Prepare Attenuator And Set Attenuation To Max
    [Arguments]    ${ip}  ${port}  ${attenuation_port_numbers}  ${max_attenuation}  ${vendor}
    Log  \nip_addr=${ip}\nport=${port}  console=True
    Log  attenuation_port_numbers=${attenuation_port_numbers}  console=True
    Log  max_attenuation=${max_attenuation}\nvendor=${vendor}  console=True
    Setup Attenuator  ip_addr=${ip}  port=${port}  attenuation_port_numbers=${attenuation_port_numbers}
    ...    max_attenuation=${max_attenuation}  vendor=${vendor}

    Set Attenuation To Max On All Ports  ${max_attenuation}


Set Attenuation To Max On All Ports
    [Arguments]    ${max_attenuation}
    ${ports_to_attenuate} =    Evaluate    list(range(1, 257))
    ${values} =    Evaluate    [${max_attenuation}] * 256
    Set Ports Attenuation     ports=${ports_to_attenuate}    values=${values}


Check Hanging Resources
    ${log_directory} =  Set Variable  ${OUTPUT DIR}/${TEST_NAME}/hanging_resources
    OperatingSystem.Create Directory  ${OUTPUT DIR}/${TEST_NAME}/hanging_resources
    Sleep  10s
    ${timestamp} =  Get Time
    ${result} =  Process.Run Process  python  ${HANGING_SCRIPT_PATH}  cwd=${log_directory}
    ...  stdout=${log_directory}/hanging_stdout_${timestamp}.txt  stderr=${log_directory}/hanging_stderr_${timestamp}.txt
    ...  timeout=1min  alias=hanging_script
    Should Be True  ${result.rc} == 0  msg=A problem with hanging.py script occured.
    ${hanging_resource_result} =  Set Variable  ${result.stdout}
    ${_}  ${hanging_resource_result} =  Split String From Right  ${hanging_resource_result}  separator=\n  max_split=1
    Log  ++++ hanging resource result is : ${hanging_resource_result} ++++  console=True
    Should Be Equal As Strings  ${hanging_resource_result}  No hanging resources
