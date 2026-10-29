*** Settings ***
Library     ute_ue
Library     taf.sw.syslog   WITH NAME   taf_syslog
Library     ute_tshark
Library     SSHLibrary
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB007552/resources/test_specific_keywords_CB007552.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.bip_log_collector.BipLogCollector  WITH NAME  BIP
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB007552/resources/test_variables_CB007552.py    WITH NAME    msgs

Documentation  Set of keywords for feature CB007552 execution

*** Keywords ***
Common CB007552 Test Setup
    [Arguments]    ${ue_1}=None    ${ue_2}=None
    Prepare All UEs    ${ue_1}    ${ue_2}
    Set TESTNAME without spaces
    Set Test Variable    ${LOG_PATH}    ${LOG_PATH}/${TESTNAME}
    Set Test Variable    ${syslog_path}    ${LOG_PATH}/syslog
    Set Test Variable    ${scf_path}    ${LOG_PATH}/scf
    Run    mkdir -p ${LOG_PATH}
    Run    mkdir -p ${syslog_path}
    Run    mkdir -p ${scf_path}
    ${BTS_USED}    Get Test gNBs
    Set Test Variable    ${BTS_USED}
    ${CA_testcase}    Check If Specific Testcase    CA
    ${Multi_UE_testcase}    Check If Specific Testcase    Two_Or_More_UEs
    ${Inter_gNB_testcase}    Check If Specific Testcase    Inter-gNB_handover
    ${CNI_testcase}    Check If Specific Testcase    CNI
    Set Test Variable    ${CA_testcase}
    Set Test Variable    ${Multi_UE_testcase}
    Set Test Variable    ${Inter_gNB_testcase}
    Set Test Variable    ${CNI_testcase}
    IF    '${Inter_gNB_testcase}'=='True'    Install Taf Syslog On Remote
    Collect SCF Before Test
    Start Collecting Syslog For All
    Start Tcpdump Logging


Teardown
    [Arguments]    ${ue_1}=None    ${ue_2}=None
    Run Keyword And Ignore Error    Teardown All Aliases For Tshark
    Run Keyword And Ignore Error    taf_syslog.Teardown All Aliases For Syslog
    IF    '${Multi_UE_testcase}'=='True'
    ...               Run Keyword If Test Failed    Stop Collecting Syslog For All
    Make Snapshot If Test Failed
    Detach UEs And Set Maximal Attenuation    ${ue_1}    ${ue_2}


Make Snapshot If Test Failed
    Set TESTNAME without spaces
    Run Keyword If Test Failed    webUI_operations.Make Webui Snapshot


Upload SCF
    [Arguments]    ${scf_type}
    Perform SCF Commissioning      ${scf_type}
    Wait Until Keyword Succeeds    10 min    10 sec    Wait For Cells On Air
    IF    '${CA_testcase}'=='False'
    ...               Wait For X2 Link Available    cells_up


Wait For X2 Link Available
    [Arguments]  ${admin_alias}
    admin.Setup Admin    alias=${admin_alias}
    Wait Until Keyword Succeeds  900  10  testline_preparation.Verify X2 Link Is Available  ${admin_alias}
    admin.Teardown Admin    connection=${admin_alias}


Start Tcpdump Logging
    Kill tcpdump on CU
    Sleep    5s
    Start Tcpdump On CU    filename=${test_name}_SCTP.pcap
    Sleep    5s
    IF    '${Inter_gNB_testcase}'=='True'
    ...               Start Tcpdump On Remote CU    ${remote_mplane_ip}
    Log To Console    Tcpdump logging started...


Stop Tcpdump Logging
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_SCTP.pcap
    IF    '${Inter_gNB_testcase}'=='True'
    ...               Stop Tcpdump On CU And Download Logs For Remote DU
    Log To Console    Tcpdump logging stopped...


Start Collecting Syslog
    [Arguments]    ${VM_IP}    ${NAME}
    IF    '${VM_IP}' == '${tl.test_pc[0].default_ssh_connection_details.addr}'
    ...               taf_syslog.Start Syslog    log_dir=${syslog_path}    log_name=syslog_${NAME}.log    ip=192.168.255.126
    ...                               alias=${NAME}
    IF    '${VM_IP}' != '${tl.test_pc[0].default_ssh_connection_details.addr}'
    ...               taf_syslog.Start Syslog    log_dir=${syslog_path}    log_name=syslog_${NAME}.log    ip=192.168.255.126
    ...                               host_ip=${VM_IP}    alias=${NAME}


Stop Collecting Syslog
    [Arguments]    ${NAME}
    ${file_path}    taf_syslog.Collect Syslog Results    alias=${NAME}
    RETURN    ${file_path}


Start Collecting Syslog For All
    FOR    ${key}    IN    @{BTS_USED.keys()}
        Log To Console    Starting Syslog on ${key}
        Start Collecting Syslog    ${BTS_USED["${key}"]["VM_IP"]}    ${key}
    END


Stop Collecting Syslog For All
    FOR    ${key}    IN    @{BTS_USED.keys()}
        Log To Console    Collecting syslog from ${key}
        Stop Collecting Syslog    ${key}
    END


Start Tcpdump On Local CU
    SSHLibrary.Open Connection    host=192.168.255.129   alias=local_pcap
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu  alias=local_pcap
    SSHLibrary.Start Command  tcpdump -i any sctp -w /tmp/${TESTNAME}_SCTP.pcap


Stop Tcpdump On CU And Download Logs For Local CU
    SSHLibrary.Switch Connection  local_pcap
    SSHLibrary.Start Command    killall tcpdump
    Sleep    10s
    ${response}    Read Command Output
    Log to console    ${response}
    SSHLibrary.Start Command    chmod 777 /tmp/${TESTNAME}_SCTP.pcap
    SSHLibrary.File Should Exist    /tmp/${TESTNAME}_SCTP.pcap
    SSHLibrary.Get File    /tmp/${TESTNAME}_SCTP.pcap  destination=${LOG_PATH}/${TESTNAME}_SCTP.pcap
    SSHLibrary.Start Command    rm /tmp/${TESTNAME}_SCTP.pcap
    SSHLibrary.Close Connection


Start Tcpdump On Remote CU
    [Arguments]    ${remote_mplane_ip}
    SSHLibrary.Open Connection    host=${remote_mplane_ip}    alias=target_pcap
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Start Command    tcpdump -i any sctp -w /tmp/target_SCTP.pcap


Stop Tcpdump On CU And Download Logs For Remote DU
    SSHLibrary.Switch Connection  target_pcap
    SSHLibrary.Start Command    killall tcpdump
    Sleep    10s
    ${response}    Read Command Output
    Log to console    ${response}
    SSHLibrary.Start Command    chmod 777 /tmp/target_SCTP.pcap
    SSHLibrary.File Should Exist    /tmp/target_SCTP.pcap
    SSHLibrary.Get File    /tmp/target_SCTP.pcap  destination=${LOG_PATH}/${TESTNAME}_target_SCTP.pcap
    SSHLibrary.Start Command    rm /tmp/target_SCTP.pcap
    SSHLibrary.Close Connection


Setup Attenuator
    Initialize Attenuator


Teardown Attenuator
    Release Attenuator


[1]CB007552_F_IWK.1.4_SA_TDD-TDD_2CC_CA_n78C_20MHz+100MHz_SCellA_+_ScellC_Band_Combination_Adjusted_For_n41C_80MHz+100MHz
    Attach    UE_1   ${CELL_1_1_ALIAS}    0db
    Verify Downlink Throughput For CA Check    dl    1800Mbits/sec    ${CELL_1_2_ALIAS}    90dB    490 Mbits/sec
    Sleep    10s
    Verify Downlink Throughput For CA Check    dl    1800Mbits/sec    ${CELL_1_2_ALIAS}    0dB    1.10 Gbits/sec
    Stop Tcpdump Logging
    Stop Collecting Syslog For All
    Verify Scell Aggregation    SA
    Check If Syslog Contains Messages    ca_msgs


[1]CB007552_5G_7_CB007552-B_IWK.6.1.1_Successful_Intra-frequency_Intra-DU_Intra-gNB_Handover
    Attach    UE_2    ${CELL_1_1_ALIAS}    0db
    Perform Handover    UE_2    ${CELL_1_1_ALIAS}    ${CELL_1_2_ALIAS}
    ...                 800Mbits/sec    200Mbits/sec    260Mbits/sec    25Mbits/sec
    Stop Tcpdump Logging
    Stop Collecting Syslog For All
    Check If Syslog Contains Messages    intra_du_msgs


[1]CB007552_5G_13_CB007552-B_IWK.8.2.1_Successful_Inter-Frequency_Inter-gNB_handover
    Attach    UE_2   ${CELL_1_1_ALIAS}    0db
    Perform Handover    UE_2    ${CELL_1_1_ALIAS}    ${CELL_2_1_ALIAS}
    ...                 800Mbits/sec    200Mbits/sec    200Mbits/sec    25Mbits/sec
    Stop Collecting Syslog For All
    Stop Tcpdump Logging
    Verify Handover
    Check If Syslog Contains Messages    inter_du_msgs


[1]CB007552_5G_5_CB007552-BB.5.1_Two_Or_More_UEs_Served_With_Large_And_Small_BWP_Profiles_In_The_Cell_Simultanously
    Attach    UE_1   ${CELL_1_1_ALIAS}    0db
    Attach    UE_2   ${CELL_1_1_ALIAS}    0db
    Stop Tcpdump Logging
    Check Throughput For Multi UE Attach    sa_large_and_small    800s
    Stop Collecting Syslog For All
    Verify PRB Allocation    SA    large-small
    Verify Multi UE Attach In PCAP    ${msgs.sa_ue1_attach}    ${msgs.sa_ue2_attach}
    Check If Syslog Contains Messages    multi_ue_sa_msgs


[1]CB007552_5G_7_CB007552-A_IWK2.1.3 Successful_Intra-gNB_HO_PSCell_Change_Wth_Small_BWP
    Attach    UE_3    ${CELL_2_2_ALIAS}    0db
    Perform Handover    UE_3    ${CELL_2_2_ALIAS}    ${CELL_2_3_ALIAS}
    ...                 600Mbits/sec    200Mbits/sec    240Mbits/sec    20Mbits/sec
    Stop Collecting Syslog For All
    Stop Tcpdump Logging
    Check If Syslog Contains Messages    intra_du_ho_nsa_msgs


[1]CB007552_5G_5_CB007552-A_IWK3.1.2_Two_Or_More_UEs_Served_With_Large_And_Small_BWP_Profile_In_The_Cell_Simultaneously_NSA_3x
    Attach    UE_1   ${CELL_2_2_ALIAS}    10db
    Attach    UE_3   ${CELL_2_2_ALIAS}    10db
    Check Throughput For Multi UE Attach    nsa_large_and_small    60s
    Stop Tcpdump Logging
    Stop Collecting Syslog For All
    Verify MultiUE Attach In Pcap    ${UE_1_ATTACH}    ${UE_4_ATTACH}
    Verify PRB Allocation    NSA    large-small
    Check If Syslog Contains Messages    multi_ue_ls_nsa_msgs


[1]CB007552_5G_5_CB007552-A_IWK3.1.1_Two_Or_More_UEs_Served_With_Small_BWP_Profile_In_The_Cell_Simultaneously_NSA_3x
    Attach    UE_3   ${CELL_2_3_ALIAS}    10db
    Attach    UE_4   ${CELL_2_3_ALIAS}    10db
    Stop Tcpdump Logging
    Check Throughput For Multi UE Attach    nsa_small_and_small   60s
    Stop Collecting Syslog For All
    Verify PRB Allocation    NSA    small-small
    Check If Syslog Contains Messages    multi_ue_ss_nsa_msgs


[1]CB007552-F_IWK.1.1_NSA_TDD-TDD_2CC_CA_n41(2A)_SCellA+ScellC_Band_Combination
    Attach    UE_1   ${CELL_2_3_ALIAS}    0db
    Verify Downlink Throughput For CA Check    dt_dl    1800Mbits/sec    ${CELL_2_2_ALIAS}    90dB    220 Mbits/sec
    Set Attenuation For Cell    ${CELL_2_2_ALIAS}    0dB
    Verify Downlink Throughput For CA Check    dt_dl    1800Mbits/sec    ${CELL_2_2_ALIAS}    0dB    480 Mbits/sec
    Stop Tcpdump Logging
    Stop Collecting Syslog For All
    Verify Scell Aggregation    NSA
    Check If Syslog Contains Messages    ca_nsa_msgs


Check Throughput For Multi UE Attach
    [Arguments]    ${bwp_type}    ${tput_duration}
    Start Throughput For Multi UE Attach Check    ${bwp_type}    ${tput_duration}
    Kill Tcpdump on CU
    BIP.Start Log Collecting
    Sleep    20s
    BIP.Stop Log Collecting
    BIP.Download Log    ${LOG_PATH}/${TESTNAME}
    Log To Console    Logging Stopped...
    Verify Throughput For Multi UE Attach Check    ${bwp_type}


############################################# CNI_78446 ###############################################################
[1]CNI_78446_A_1_SA_Inital_RRC_Setup_With_Dedicated_Config_In_InitialDownlinkBWP_With_Large_BWP
    Activate CNI For Proper SW Release
    Attach    UE_1   ${CELL_1_1_ALIAS}    0db
    Start Data Transfer In Both Directions    UE_1    600Mbits/sec    200Mbits/sec    400Mbits/sec    40Mbits/sec
    Stop Collecting Syslog For All
    Stop Tcpdump Logging
    Verify MultiUE Attach In PCAP     ${UE_1_ATTACH_1}    ${UE_1_ATTACH_2}    ${UE_1_ATTACH_3}
    Deactivate CNI


[1]CNI_78446_B_2_SA_Intra-gNB_Handover_After_Inital_RRC_Setup_With_Dedicated_Config_In_InitialDownlinkBWP_To_Small_BWP
    Activate CNI For Proper SW Release
    Attach    UE_2    ${CELL_1_1_ALIAS}    0db
    Stop Tcpdump Logging

    Perform Handover    UE_2    ${CELL_1_1_ALIAS}    ${CELL_1_2_ALIAS}
    ...                 600Mbits/sec    200Mbits/sec    260Mbits/sec    20Mbits/sec
    Stop Collecting Syslog For All
    Verify MultiUE Attach In PCAP    ${UE_1_ATTACH_1}    ${UE_1_ATTACH_2}    ${UE_2_ATTACH_3}
    Check If Syslog Contains Messages    intra_du_msgs
    Deactivate CNI


[1]CNI_78446_B_5_2CC_CA-Scell_Setup_After_Inital_RRC_Setup_With_Dedicated_Config_In_InitialDownlinkBWP_To_Large_BWP
    Activate CNI For Proper SW Release
    Attach    UE_1    ${CELL_1_1_ALIAS}    20db
    Stop Tcpdump Logging
    Sleep    10s
    Start Tcpdump On CU    filename=${test_name}_SCTP_CA.pcap
    Verify Downlink Throughput For CA Check    dl    600Mbits/sec    ${CELL_1_2_ALIAS}    90dB    480Mbits/sec
    Sleep    10s
    Verify Downlink Throughput For CA Check    dl    1800Mbits/sec    ${CELL_1_2_ALIAS}    20dB    1.10Gbits/sec
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_SCTP_CA.pcap
    Stop Collecting Syslog For All
    Verify SCell Aggregation    CNI
    Verify MultiUE Attach In PCAP    ${UE_1_ATTACH_1}    ${UE_1_ATTACH_2}    ${UE_1_ATTACH_CA}
    Check If Syslog Contains Messages    ca_msgs
    Deactivate CNI


Prepare Logging
    ${cp_runtime}=  Prepare Smod Logging
    IF  ${cp_runtime}!=True  Wait Until Keyword Succeeds    10 min    10 sec    Wait For Cells On Air
