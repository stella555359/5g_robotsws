*** Settings ***
Documentation    this suite is used for CB010680 5G Precise Positioning SiSo for Shikra pRRH and mRRH
                ...    1. 5G SA TDD Cells with Maximum 100MHz Bandwidth
                ...    2. RF 6.2 Made2 B0 based non-BF RRHs with eCPRI 7.2a fronthaul
                ...    3. periodical UL-SRS reporting with NDM SRS configuration
                ...    author: Li Na
                ...    contact: na.lig@nokia-sbell.com
                ...    squad group: HAZ3_4

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/common_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013388_PZ3_SG4/Resource/CB013388_Common_KW.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB013388_PZ3_SG4/Resource/CB013388_Params.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010636_Cloud/Resources/CB010636_counter_in_logs.py


Suite Setup    Common Suit Setup CB13388
Suite Teardown    robot_common_operations.Common Suite Teardown

*** Variables ***
@{cell_id_list}    4    5    6    7    8
@{nrcellId_list}    182779905    182779906
${att_ipaddr}             ${tl.attenuator.ip_addr}
${att_api_port}           ${tl.attenuator.port}
${att_connection_port}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${model}                     ${tl.attenuator.model}
${UTE_ADDRESS}            ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
${ul_port_list}               ${tl.ues[0].iperf_details.ports[0:5]}
${dl_port_list}               ${tl.ues[0].iperf_details.ports[5:10]}
${gNB_ip}                     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_ssh_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
@{allowed_alarm_list}               ${4655}    ${61524}    ${4654}    ${61652}
...    ${4592}    ${7312}    ${7313}    ${49}    ${6351}    ${61649}
@{port_list_0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${13}    ${14}    ${15}   ${16}
@{port_list_708}    ${9}    ${10}    ${11}    ${12}
@{port_list_742}    ${13}    ${14}    ${15}   ${16}
@{nrcellId_list_742}     178305    178306

*** Test Cases ***
[1]CB013388_C_1_Online_enable_actULCgType2_success_TDD
    [Setup]    Common case Setup CB013388
    step1 MTK90 Attach and get rnti
    [Teardown]    Common Teardown CB013388

[1]CB013388_C_2_Online_disable_actULCgType2_without_alarms_TDD
    [Setup]    Common case Setup CB013388
    Log To Console    CB013388_C_2
    Set actUlCgType2
    CB013388_C_2 step
    [Teardown]    Common Teardown CB013388


[1]CB013388_C_7_Online_modification_ulCgPrbStartOffset_ulCgMaxNumPrb_success_TDD
    [Setup]    Common case Setup CB013388
    Set actUlCgType2
    CB013388_C_7 step
    [Teardown]    Common Teardown CB013388


[1]CB013388_C_8_Online_modification_ulCgPrbStartOffset_ulCgMaxNumPrb_CP
    [Setup]    Common case Setup CB013388
    Set actUlCgType2
    CB013388_C_8 step
    [Teardown]    Common Teardown CB013388

[1]CB013388_15_test_parallel_modification_IWK_Handover
    [Setup]    Common case Setup CB013388
    Set actUlCgType2
    CB013388_C_15 step
    [Teardown]    Common Teardown CB013388


*** Keywords ***
########################[1]CB013388_C_1_Online_enable_actULCgType2_success_TDD_step###########################
Common Suit Setup CB13388
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    Adjust PA    value_0=${127}    value_1=${5}    port_list_0=${port_list_0}    port_list_1=${port_list_708}

Common Teardown CB013388
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}
    Run Keyword And Ignore Error    ERR_WRN_Check.Start BTSlogs Collection In Log Server    Login_UTE=${True}
    sleep    5s
    Setup Commission SCF    scf_name=_TMOonly5G    timeout=600
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=10min
    robot_common_operations.Common case Teardown
#    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${gNB_ip}
    CI_interface.Common Case Teardown

Common case Setup CB013388
    robot_common_operations.Common case Setup
    Setup Commission SCF    scf_name=_CB013388    timeout=600
    Run Keyword And Ignore Error    Check GNB on air And alarm    bts_host=${gNB_ip}
    ...    allowed_list=${allowed_alarm_list}    time=10min

step1 MTK90 Attach and get rnti
    [Arguments]    ${ue_index}=${3}
    Start Catch TCPDUMP SCTP Log 13388    filename=Tcpdump_MTK90.pcap
    Attach MTK90 power UE and check throughput    ue_index=${ue_index}    ul_throughput=${15}    dl_throughput=${2300}
    ...    cells=${nrcellId_list[0:2]}
    Stop And Copy TCPDUMP To UTE 13388    filename=Tcpdump_MTK90.pcap
    Pcap chang to txt    pcap_name=Tcpdump_MTK90.pcap    text_name=Tcpdump_MTK90.txt
    ${rnti_MTK90}    get_rnti_and_ca_info    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/Tcpdump_MTK90.txt
    ${rnti_list_MTK90}    Get Dictionary Keys    ${rnti_MTK90}
    step3 X80 Attach and check log
    ${data_MTK90}    check Btslog    rnti=${rnti_list_MTK90}[0]
    Run keyword and continue on failure    should be empty    ${data_MTK90}
    UE Stop Traffic    ue_index=${ue_index}    ue_type=samsung
    [Teardown]  MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${ue_index}

Set actUlCgType2
    [Arguments]    ${bts_host}=${gNB_ip}    ${username}=${gNB_username}    ${password}=${gNB_password}
    ...    ${connection}=GNB_OAM    ${input_list}=${actUlCgType2_true}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ...    connection=${connection}
    Modify Parameters with coam     input_list=${input_list}    connection=${connection}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


step3 X80 Attach and check log
    Set actUlCgType2
    BTSLOG Start btslog on remote machine
    ${rnti_X80}    attach X80 and check UL traffic    ue_index=${4}    ul_throughput=${15}    dl_throughput=${2300}
    ...    cells=${nrcellId_list[0:2]}
    ${rnti_list}    Get Dictionary Keys    ${rnti_X80}
    Stop BTSLOG Collect btslog on remote machine
    UE Stop Traffic    ue_index=${4}    ue_type=samsung
    ${data_X80}    check Btslog    rnti=${rnti_list}[0]
    Run keyword and continue on failure    should not be empty    ${data_X80}
    [Teardown]  Run Keyword And Ignore error    X80 detach multi power ue    ue_index=${4}

case teardown
    Set actUlCgType2    input_list=${actUlCgType2_false}

 ######################[1]CB013388_C_2_Online_disable_actULCgType2_without_alarms_TDD######################
CB013388_C_2 step
    [Arguments]    ${ue_index}=${3}
    BTSLOG Start btslog on remote machine
    Start Catch TCPDUMP SCTP Log 13388    filename=Tcpdump_MTK90.pcap
    Attach MTK90 power UE and check throughput    ue_index=${ue_index}    ul_throughput=${15}    dl_throughput=${2300}
    ...    cells=${nrcellId_list[0:2]}
    Stop And Copy TCPDUMP To UTE 13388    filename=Tcpdump_MTK90.pcap
    Pcap chang to txt    pcap_name=Tcpdump_MTK90.pcap    text_name=Tcpdump_MTK90.txt
    ${rnti_MTK90}    get_rnti_and_ca_info    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/Tcpdump_MTK90.txt
    ${rnti_list_MTK90}    Get Dictionary Keys    ${rnti_MTK90}
    Stop BTSLOG Collect btslog on remote machine
    ${data_MTK90}    check Btslog    rnti=${rnti_list_MTK90}[0]
    Run keyword and continue on failure    should not be empty    ${data_MTK90}
    sleep    10min
    Set actUlCgType2    input_list=${actUlCgType2_false}
    BTSLOG Start btslog on remote machine
    ${rnti_X80}    attach X80 and check UL traffic    ue_index=${4}    ul_throughput=${15}    dl_throughput=${2300}
    ...    cells=${nrcellId_list[0:2]}
    ${rnti_list}    Get Dictionary Keys    ${rnti_X80}
    Stop BTSLOG Collect btslog on remote machine
    UE Stop Traffic    ue_index=${4}    ue_type=samsung
    Run Keyword And Ignore error    X80 detach multi power ue    ue_index=${4}
     ${data_X80}    check Btslog    rnti=${rnti_list}[0]
    ${data_MTK90}    check Btslog    rnti=${rnti_list_MTK90}[0]
    ${data_X80_con}    check Btslog    rnti=${rnti_list}[0]
    ...    CON_True=True
    ${data_MTK90_con}    check Btslog    rnti=${rnti_list_MTK90}[0]
    ...    CON_True=True
    Run keyword and continue on failure    should be empty     ${data_X80_con}
    Run keyword and continue on failure    should be empty    ${data_X80}
    Run keyword and continue on failure    should be empty    ${data_MTK90}
    Run keyword and continue on failure    should be empty    ${data_MTK90_con}
    UE Stop Traffic    ue_index=${ue_index}    ue_type=samsung
    [Teardown]    Run keyword and continue on failure
    ...    MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${ue_index}



########################[1]CB013388_C_7__step###########################
CB013388_C_7 step
    [Arguments]    ${ue_index}=${3}
    BTSLOG Start btslog on remote machine
    ${rnti_X80}    attach X80 and check UL traffic    ue_index=${4}    ul_throughput=${15}    dl_throughput=${2300}
    ...    cells=${nrcellId_list[0:2]}
    ${rnti_list}    Get Dictionary Keys    ${rnti_X80}
    Stop BTSLOG Collect btslog on remote machine
    ${data_X80}    check Btslog    rnti=${rnti_list}[0]
    Run keyword and continue on failure    should not be empty    ${data_X80}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=GNB_OAM
    ${status}    Run Keyword And Return Status    Modify Parameters with coam     input_list=${ulConfigured_55}   connection=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    should be equal     '${status}'    'False'
    sleep    10min
    Set actUlCgType2    input_list=${ulConfigured_55}
    BTSLOG Start btslog on remote machine
    Start Catch TCPDUMP SCTP Log 13388    filename=Tcpdump_MTK90.pcap
    Attach MTK90 power UE and check throughput    ue_index=${ue_index}    ul_throughput=${15}    dl_throughput=${2300}
    ...    cells=${nrcellId_list[0:2]}
    Stop And Copy TCPDUMP To UTE 13388    filename=Tcpdump_MTK90.pcap
    Stop BTSLOG Collect btslog on remote machine
    UE Stop Traffic    ue_index=${ue_index}    ue_type=samsung
    Pcap chang to txt    pcap_name=Tcpdump_MTK90.pcap    text_name=Tcpdump_MTK90.txt
    ${rnti_MTK90}    get_rnti_and_ca_info    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/Tcpdump_MTK90.txt
    ${rnti_list_MTK90}    Get Dictionary Keys    ${rnti_MTK90}
     ${data_X80}    check Btslog    rnti=${rnti_list}[0]
    ${data_MTK90}    check Btslog    rnti=${rnti_list_MTK90}[0]
    ${data_X80_con}    check Btslog    rnti=${rnti_list}[0]
    ...    CON_True=True
    ${data_MTK90_con}    check Btslog    rnti=${rnti_list_MTK90}[0]
    ...    CON_True=True
#    Run keyword and continue on failure    should not be empty    ${data_X80}
    Run keyword and continue on failure    should not be empty    ${data_MTK90}
#    Run keyword and continue on failure    should not be empty    ${data_MTK90_con}
    UE Stop Traffic    ue_index=${4}    ue_type=samsung
    [Teardown]    attach teardown


attach teardown
    Run Keyword And Ignore error    X80 detach multi power ue    ue_index=${4}
    Run Keyword And Ignore error    MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${3}


########################[1]CB013388_C_8__step###########################
CB013388_C_8 step
    [Arguments]    ${ue_index}=${3}
    BTSLOG Start btslog on remote machine
    ${rnti_X80}    attach X80 and check UL traffic    ue_index=${4}    ul_throughput=${15}    dl_throughput=${2300}
    ...    cells=${nrcellId_list[0:2]}
    ${rnti_list}    Get Dictionary Keys    ${rnti_X80}
    Stop BTSLOG Collect btslog on remote machine
    ${data_X80}    check Btslog    rnti=${rnti_list}[0]
    Run keyword and continue on failure    should not be empty    ${data_X80}
    Set actUlCgType2    input_list=${NRULCG_PROFILE}
    BTSLOG Start btslog on remote machine
    Start Catch TCPDUMP SCTP Log 13388    filename=Tcpdump_MTK90.pcap
    Attach MTK90 power UE and check throughput    ue_index=${ue_index}    ul_throughput=${15}    dl_throughput=${2300}
    ...    cells=${nrcellId_list[0:2]}
    Stop And Copy TCPDUMP To UTE 13388    filename=Tcpdump_MTK90.pcap
    Stop BTSLOG Collect btslog on remote machine
    UE Stop Traffic    ue_index=${ue_index}    ue_type=samsung
    Pcap chang to txt    pcap_name=Tcpdump_MTK90.pcap    text_name=Tcpdump_MTK90.txt
    ${rnti_MTK90}    get_rnti_and_ca_info    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/Tcpdump_MTK90.txt
    ${rnti_list_MTK90}    Get Dictionary Keys    ${rnti_MTK90}
     ${data_X80}    check Btslog    rnti=${rnti_list}[0]
    ${data_MTK90}    check Btslog    rnti=${rnti_list_MTK90}[0]
    ${data_X80_con}    check Btslog    rnti=${rnti_list}[0]
    ...    CON_True=True
    ${data_MTK90_con}    check Btslog    rnti=${rnti_list_MTK90}[0]
    ...    CON_True=True
#    Run keyword and continue on failure    should not be empty    ${data_X80}
    Run keyword and continue on failure    should not be empty    ${data_MTK90}
    UE Stop Traffic    ue_index=${4}    ue_type=samsung
    [Teardown]    attach teardown

########################[1]CB013388_C_15__step###########################
Adjust PA
    [Arguments]      ${value_0}    ${value_1}    ${port_list_0}    ${port_list_1}
    Adjust the HBTE attenuation value    value=${value_0}    port_list=${port_list_0}
    Adjust the HBTE attenuation value    value=${value_1}     port_list=${port_list_1}

Adjust the HBTE attenuation value
    [Arguments]      ${value}    ${port_list}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    FOR    ${port_num}    IN    @{port_list}
        att.set_attenuation     port=${port_num}    value=${value}
        ${value_port}    att.read_attenuation    port=${port_num}
        should be equal    ${value_port}    ${value}
    END
    sleep  3s

CB013388_C_15 step
    Adjust PA    value_0=${0}    value_1=${40}    port_list_0=${port_list_742}    port_list_1=${port_list_708}
    attach X80 power ue    ue_index=${4}    gnb_index=${1}
    UE Start Traffic    ue_index=${4}    ue_type=samsung    ul_throughput=15M    dl_throughput=100M
    sleep    3s
    Check Throught From Asslog    ul_list=${nrcellId_list_742[0:1]}    dl_list=${nrcellId_list_742[0:1]}     ul_tp=15    dl_tp=100
    ...    target_avg_percent_UL=0.9   target_avg_percent_DL=0.5    gnb_index=${1}
    BTSLOG Start btslog on remote machine
    Start Catch TCPDUMP SCTP Log 13388    filename=Tcpdump_X80.pcap
    Adjust the HBTE attenuation value    value=${0}    port_list=${port_list_708}
    FOR    ${item}    IN RANGE    ${4}
        ${item_1}    Evaluate    ${item} + 1
        ${value}    Evaluate    ${item_1} * 6
        Adjust the HBTE attenuation value    value=${value}     port_list=${port_list_742}
    END
    sleep    5s
    Stop And Copy TCPDUMP To UTE 13388    filename=Tcpdump_X80.pcap
    Stop BTSLOG Collect btslog on remote machine
    Pcap chang to txt    pcap_name=Tcpdump_X80.pcap    text_name=Tcpdump_X80.txt
    ${rnti_X80}    get_rnti_and_ca_info    txt_file_path=${OUTPUT_DIR}/${TEST NAME}/Tcpdump_X80.txt
    ${rnti_list}    Get Dictionary Keys    ${rnti_X80}
    ${data_X80}    check Btslog    rnti=${rnti_list}[0]
    Run keyword and continue on failure    should not be empty    ${data_X80}
    [Teardown]    attach X80 teardown


attach X80 teardown
    Run Keyword And Ignore error    UE Stop Traffic    ue_index=${4}    ue_type=samsung
    Run Keyword And Ignore error    X80 detach multi power ue    ue_index=${4}
