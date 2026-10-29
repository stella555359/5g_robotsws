*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot

*** Variables ***
${mcs_ip}    ${tl.mcses[0].ip_addr}
${mcs_model}    ${tl.mcses[0].model}
${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs
${scf_path_25R1}       /home/ute/Downloads/SCF/25R1
${scf_path_24R3}       /home/ute/Downloads/SCF/24R3
${scf_path_23R4}       /home/ute/Downloads/SCF/23R4
${scf_path_24R1}       /home/ute/Downloads/SCF/24R1
${scf_path_24R2}       /home/ute/Downloads/SCF/24R2
${scf_path_common}     /home/ute/Downloads/SCF/common.xml
@{beam_set_5_1_horizontal}   -34   -34   -18   -18   18   18   34   34   -34   -34   -18   -18   18   18   34   34
@{beam_set_5_1_vertical}   89   89   89   89   103   103   103   103   89   89   89   89   103   103   103  103
@{beam_set_16D8U_horizontal}   -50.6   -50.6   -50.6   -50.6   -10.5   -10.5   -10.5   -10.5   10.5   10.5   10.5   10.5
...   50.6   50.6   50.6   50.6
@{beam_set_16D8U_vertical}   95.9   95.9   89.1   89.1   100.8   100.8   107.4   107.4   105.7   105.7   86.3   86.3
...   95.9   95.9   102.4  102.4
${tshark_path}    /usr/bin/tshark

*** Test Cases ***
CB008305-A_11_Verify_2UEs_maxNumLayerPerMuRbg_Paired
    [Tags]    CRT    CB008305
    [Setup]    Case Setup
    Run keyword and ignore error    MCS Set angle    horizontal_set=${beam_set_5_1_horizontal}    vertical_set=${beam_set_5_1_vertical}
    Recover swconfig file
    Reload Case SCF and Commission    scf_file=${scf_path}/CB008305.xml
    Common UE Attach    ue_index=1    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=1    send_traffic=50MKbits/sec
    ...    send_duration=600
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=1    send_traffic=1500MKbits/sec
    ...    send_duration=600
    Common UE Attach    ue_index=2    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=2    send_traffic=50MKbits/sec
    ...    send_duration=600
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=2    send_traffic=1500MKbits/sec
    ...    send_duration=600
    sleep    5s
    Common Capture BIP log and download
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${1}    check_traffic=800
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${2}    check_traffic=800
    Check BIP Log
	log to console    "begin to sleep"
    sleep    15min
    Check counter
    [Teardown]    Case Teardown

CB008305-B_04_Verify_PMCounter_For_MUMIMO
    [Tags]    CRT    CB008305
    [Setup]    Case Setup
    Run keyword and ignore error    MCS Set angle    horizontal_set=${beam_set_5_1_horizontal}    vertical_set=${beam_set_5_1_vertical}
    Recover swconfig file
    Reload Case SCF and Commission    scf_file=${scf_path}/CB008305.xml
    Common UE Attach    ue_index=1    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=1    send_traffic=50MKbits/sec
    ...    send_duration=600
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=1    send_traffic=1500MKbits/sec
    ...    send_duration=600
    Common UE Attach    ue_index=2    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=2    send_traffic=50MKbits/sec
    ...    send_duration=600
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=2    send_traffic=1500MKbits/sec
    ...    send_duration=600
	log to console    "begin to sleep"
    sleep    15min
    Check counter
    [Teardown]    Case Teardown

CB008305-C_02_Verify_MUMIMO_Interworking_With_PowerSaving
    [Tags]    CRT    CB008305
    [Setup]    Case Setup
    Run keyword and ignore error    MCS Set angle    horizontal_set=${beam_set_16D8U_horizontal}    vertical_set=${beam_set_16D8U_vertical} 
    Reload Case SCF and Commission    scf_file=${scf_path}/CB008305_16D8U.xml
    Common UE Attach    ue_index=1    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=1    send_traffic=50MKbits/sec
    ...    send_duration=1200
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=1    send_traffic=1000MKbits/sec
    ...    send_duration=1200
    Common UE Attach    ue_index=2    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=2    send_traffic=50MKbits/sec
    ...    send_duration=1200
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=2    send_traffic=1000MKbits/sec
    ...    send_duration=1200
    sleep    5s
    Common UE Attach    ue_index=5    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=5    send_traffic=50MKbits/sec
    ...    send_duration=1200
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=5    send_traffic=1000MKbits/sec
    ...    send_duration=1200
    sleep    5s
    Common UE Attach    ue_index=7    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=7    send_traffic=50MKbits/sec
    ...    send_duration=1200
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=7    send_traffic=1000MKbits/sec
    ...    send_duration=1200
    sleep    5s
    Common Capture BIP log and download
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${1}    check_traffic=800
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${2}    check_traffic=800
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${5}    check_traffic=800
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${7}    check_traffic=800
    Check BIP Log 16D8U
	log to console    "begin to sleep"
    sleep    5min
    Check counter 16D8U
    [Teardown]    Case Teardown

CB008701-A_12_Verify_4UEs_Paired_To_16DL_Layers_without_rank_downgrade
    [Tags]    CRT    CB008701
    [Setup]    Case Setup
    Run keyword and ignore error    MCS Set angle    horizontal_set=${beam_set_16D8U_horizontal}    vertical_set=${beam_set_16D8U_vertical} 
    Reload Case SCF and Commission    scf_file=${scf_path}/CB008305_16D8U.xml
    Common UE Attach    ue_index=1    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=1    send_traffic=50MKbits/sec
    ...    send_duration=1000
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=1    send_traffic=100MKbits/sec
    ...    send_duration=1000
    Common UE Attach    ue_index=2    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=2    send_traffic=50MKbits/sec
    ...    send_duration=800
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=2    send_traffic=1000MKbits/sec
    ...    send_duration=800
    sleep    5s
    Common UE Attach    ue_index=5    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=5    send_traffic=50MKbits/sec
    ...    send_duration=600
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=5    send_traffic=1000MKbits/sec
    ...    send_duration=600
    sleep    5s
    Common UE Attach    ue_index=7    power_reset=true
    sleep    3s
    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=7    send_traffic=50MKbits/sec
    ...    send_duration=600
    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=7    send_traffic=1000MKbits/sec
    ...    send_duration=600
    sleep    5s
    Common Capture BIP log and download
    Run keyword and ignore error    Check DL UL Throughput On Site    dl_target=2500
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${1}    check_traffic=1000
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${2}    check_traffic=1000
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${5}    check_traffic=1000
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${7}    check_traffic=1000
    Check BIP Log 16D8U
    [Teardown]    Case Teardown

CB008701-A_13_Verify_8UEs_Paired_To_16DL_Layers_with_rank_downgrade
    [Tags]    CRT    CB008701
    [Setup]    Case Setup
    Run keyword and ignore error    MCS Set angle    horizontal_set=${beam_set_16D8U_horizontal}    vertical_set=${beam_set_16D8U_vertical} 
    Reload Case SCF and Commission    scf_file=${scf_path}/CB008305_16D8U.xml
    Set Test Variable    ${ue_num}    ${1}
    Run keyword and ignore error    Multi UE Attach And Send Traffic    num=${ue_num}
    sleep    3s
    Run keyword and ignore error    Check DL UL Throughput On Site    dl_target=1300    ul_target=140
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${0}    check_traffic=1300
    [Teardown]    Case Teardown

*** Keywords ***
Common Suite Setup for COAM
    robot_common_operations.Common Suite Setup

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Run keyword if    'SBTS24R3' in ${result}    set test variable    ${scf_path}    ${scf_path_24R3}
    ...    ELSE IF    'SBTS23R4' in ${result}    set test variable    ${scf_path}    ${scf_path_23R4}
    ...    ELSE IF    'SBTS24R1' in ${result}    set test variable    ${scf_path}    ${scf_path_24R1}
    ...    ELSE IF    'SBTS24R2' in ${result}    set test variable    ${scf_path}    ${scf_path_24R2}
    ...    ELSE IF    'SBTS25R1' in ${result}    set test variable    ${scf_path}    ${scf_path_25R1}
    robot_common_operations.Common Case Setup

Case Teardown
    Run keyword and ignore error    COAM Teardown gnb connections
    #Run keyword and ignore error    CI_interface.Common Case Teardown
    robot_common_operations.Common Case Teardown

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Multi UE Attach And Send Traffic
    [Arguments]    ${send_traffic_ul}=200MKbits/sec    ${send_traffic_dl}=2000MKbits/sec    ${send_duration}=1800    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Common UE Attach    ue_index=${ue_no}    power_reset=true
        sleep    3s
        Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
        ...    send_duration=${send_duration}
        Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
        ...    send_duration=${send_duration}
    END

Check DL UL Throughput On Site
    [Arguments]    ${dl_target}=1300    ${ul_target}=0
    ${cells}    Get NRcellid list
    ${cell}    Create list    ${cells}[0]
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cell}    target_throughput=${dl_target}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cell}    target_throughput=${ul_target}

Check counter 16D8U
    ${counter1}    Check BTS Counters via webUI    counter_id=M55308C34023
    ${counter2}    Check BTS Counters via webUI    counter_id=M55308C34019
    ${counter3}    Check BTS Counters via webUI    counter_id=M55308C34015
    should be true    ${counter1}[-1]>=${1} or ${counter1}[-2]>=${1} or ${counter1}[-3]>=${1}
    should be true    ${counter2}[-1]>=${1} or ${counter2}[-2]>=${1} or ${counter2}[-3]>=${1}
    should be true    ${counter3}[-1]>=${1} or ${counter3}[-2]>=${1} or ${counter3}[-3]>=${1}

Check counter
    ${counter}    Check BTS Counters via webUI    counter_id=M55308C34011
    should be true    ${counter}[-1]>=${1}

Load BIP Log
    [Arguments]    ${bip_file}=${bip_log_path}     ${alias}=CB8305
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template={tshark_path} -r ${bip_file} -Y 'dldata_pdschsendreq' -T pdml
    ...                                 alias=${alias}
    [Return]   ${packets}

Check BIP Log
    Load BIP Log  
    ${value}    Get value from Bip Log    field_name=DlData_PdschGrant.numOfLayers    pcap_parser=CB8305
    Should Contain    ${value}    4

Check BIP Log 16D8U
    Load BIP Log 
    ${value_layer}    Get value from Bip Log    field_name=DlData_PdschGrant.numOfLayers    pcap_parser=CB8305
    ${value_subcell}    Get value from Bip Log    field_name=_3gpp.subcellid    pcap_parser=CB8305
    Should Contain    ${value_layer}    4
    Should Contain any    ${value_subcell}    0    1    2    3
