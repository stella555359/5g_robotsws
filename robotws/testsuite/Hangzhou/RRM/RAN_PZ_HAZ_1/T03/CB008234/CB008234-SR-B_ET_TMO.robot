*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case about CB008234-SR-B ET
...   Default B34 WTS cfg file is wts_SA_FDD_2c_1gNBSim_B_TMO
...   Default 5QI is 6
...   Some cases have its own cfg file and scf file
Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Common/Airphone.robot
# Resource          ../Resources/top50_resource.robot
Suite Setup       Run Keywords    Common MultiBTS Suite Setup For RRM    AND
...                Run Keyword And Ignore Error    Start Scout Cli
# Suite Setup       Common Suite Setup For RRM
Test Setup            Common MultiBTS Test Setup For RRM
# Test Setup          Common Test Setup For RRM
Test Teardown     Run Keywords    Common MultiBTS Test Teardown For RRM    AND
...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Test Teardown    Common Test Teardown For RRM
Suite Teardown    Common MutliBTS Suite Teardown For RRM
# Suite Teardown    Common Suite Teardown For RRM
Force Tags        CRT/CIT/CDRT     #Tag Item
# ...   PY27
...      RAN_5G                    #Product [RAN_5G]
# ...      CLOUD_5G_CLASSICAL_2xANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_AEQE_ENB   #TLtype, it is for auto trigger by ute cloud
...      SBTS00/SBTS21B           # it is for auto trigger by ute cloud with the release
# ...      STATE_SKIP_AGENT         # it is for auto trigger by ute cloud with gnb state
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]


Test Timeout    90 minutes

# Library           taf.ccs.aashell   WITH NAME    ccs_aashell
*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
&{fault_4334}            faultId=${4334}
&{fault_4293}            faultId=${4293}
&{fault_61510}           faultId=${61510}
&{fault_61616}           faultId=${61616}
&{fault_4459}            faultId=${4459}
&{fault_8000}            faultId=${8000}
&{fault_7300}            faultId=${7300}
@{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}    &{fault_61510}    &{fault_61616}
...    &{fault_4459}    &{fault_8000}    &{fault_7300}

# ${DEBUG_MODE}            ${TRUE}
${total_throughput}    ${0}
${parameter}           act5qiAndUlNguTnlQosFlowMod
${parameter_8379}      actNonVoNRGbrService
${dist_name}           MRBTS-1/NRBTS-1
${tput_1m}             1100000
${tput_5m}             6000000
${tput_5m_bl}          5000000
${tput_10m}            11000000
${tput_10m_bl}         10000000
${tput_15m}            16500000
${tput_15m_bl}         15000000
${tput_25m}            25000000
&{RAD_HEXs}                     rdOverloadHighThreshold=0x89006f
...                             rdFailDuAdmissionControl=0x590249
${Ignore_Cell_Id_For_Sib}    5    6    9    12

# ${REMOTE_MODE}           ${TRUE}
${PATH2}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB008234/Airphone

*** Test Cases ***
CB008234-B #B3-b UL AMBR limitation handling after ICS with two PDU session multiple non-GBR DRB setup
    [Documentation]    author:keli
    ...    FDD CRT
    ...    case 2
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_FDD_2c_1gNBSim_B_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_ul=10:Mbps
    ...    pass_regexp=${None}
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=2 session_ambr_ul=5:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set pdu ul ambr. =============${\n}
    Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue=1 ue_ambr_ul=20:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set ue ul ambr. =============${\n}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
    ...    pass_regexp=${None}
    sleep    1s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=2 trf_type=internal
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=2 qfi=1 trf_type=internal
    ...    pass_regexp=${None}
    sleep    1s

    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=2 default=on
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=1
    ...    pass_regexp=${None}

    Airphone Execute Egate Command    cmd=amf_ue_pdu_setup_param id=1 ue=1 action=delay_till_next_pdu_setup
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=ue_register id=1
    ...    pass_regexp=REGISTRATION COMPLETE
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
    ...    pass_regexp=${None}
    # Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Setup PDU1 5qi7 and 6. =============${\n}
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Setup PDU2 5qi8. =============${\n}
    sleep    2s
    Start Traffic Both DL and UL    mbps=10m    pdu_id=1
    ...    qfi_id=1
    sleep    2s
    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=1    qfi_id=2
    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=2    qfi_id=1
    Log To Console      ${\n}============= UL traffic is started. =============${\n}
    sleep    10s
    ${tput_dl}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
    ${tput_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    ${tput_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=ul
    ${tput_v3}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=ul
    ${total_throughput}=    Evaluate    ${tput_v1} + ${tput_v2} + ${tput_v3}
    Should be true    ${tput_dl}>0
    Should be true    ${total_throughput}<=${tput_15m}
    Should be true    ${total_throughput}>${tput_15m_bl}
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Check Case2 ULAMBR From WiresharkLog    ${capture_file_path}


CB008234-B #B4-b UL AMBR limitation handling during PDU session resource setup with GBR
    [Documentation]    author:keli
    ...    CRT
    ...    case 5
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    # Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_ul=10:Mbps
    ...    pass_regexp=${None}
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=2 session_ambr_ul=5:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set pdu ul ambr. =============${\n}
    Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue=1 ue_ambr_ul=20:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set ue ul ambr. =============${\n}

    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=2    trf_type=internal

    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Setup PDU1 5qi6. =============${\n}
    Start Traffic Both DL and UL    mbps=20m    pdu_id=1
    ...    qfi_id=1
    # Airphone Start Traffic    mbps=20m    dir=dl
    # ...    pdu_id=1    qfi_id=1
    # Airphone Start Traffic    mbps=20m    dir=ul
    # ...    pdu_id=1    qfi_id=1
    sleep    10s
    ${tput_dl}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
    ${tput_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    Should be true    ${tput_v1}<=${tput_10m}
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=5 default=on
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=6
    ...    pass_regexp=${None}
    Run Keyword And Ignore Error    Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
    ...    pass_regexp=QoS Routing Table
    Log To Console      ${\n}============= Setup PDU2 5qi5 and 1. =============${\n}
    sleep    2s
    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=2    qfi_id=2
    sleep    10s
    Log To Console      ${\n}============= check Ave Tput. =============${\n}
    # ${tput_ul_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    # ${tput_ul_v2}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=ul
    ${arg_tput_ul_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=1    dir=ul    expected_tput_max=${tput_15m}    expected_tput_min=0
    ${arg_tput_ul_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
    ...    qfi_id=1    dir=ul    expected_tput_max=${tput_15m}    expected_tput_min=0
    ${arg_tput_ul_v3}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
    ...    qfi_id=2    dir=ul    expected_tput_max=${tput_10m}    expected_tput_min=9000000

    ${total_throughput}=    Evaluate    ${arg_tput_ul_v1} + ${arg_tput_ul_v2}
    Should be true    ${total_throughput}<=${tput_15m}
    Should be true    ${total_throughput}>${tput_15m_bl}

    Airphone Stop Traffic
    # stop tcpdump in sbts by command
    # ${capture_file_path}    Download wireshark log to testvm
    # Check calculation ULAMBR In F1AP By Expression    capture_file_path=${capture_file_path}
    # ...    ambr_ul=10485760


CB008234-B #B5-b UL AMBR limitation handling with PDU Session Modify Rollback for PDU AMBR modify fail
    [Documentation]    author:keli
    ...    CRT
    ...    case 8
    ...    1. UE AMBR 20Mbps PDU1 AMBR 10Mbps
    ...    2. Setup PDU1 5qi6
    ...    3. Modified PDU AMBR to 5Mbps
    ...    3. Add 5qi7 failure
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16006;
    ...    Counter rule: max(M55319C16006)>40000;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16006;
    ...    Counter rule: max(M55319C16006)<82500;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16006;
    ...    Counter rule: latest(M55319C16006)<=41000;
    ${rule4}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16006;
    ...    Counter rule: latest(M55319C16006)>33000;
    ${rule5}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16007;
    ...    Counter rule: M55319C16007==0;

    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    0
    # Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_ul=10:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set pdu ul ambr. =============${\n}
    Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue=1 ue_ambr_ul=20:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set ue ul ambr. =============${\n}

    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
    sleep    1s

    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Setup PDU1 5qi6. =============${\n}
    Airphone Start Traffic    mbps=20m    dir=dl
    ...    pdu_id=1    qfi_id=1
    Airphone Start Traffic    mbps=20m    dir=ul
    ...    pdu_id=1    qfi_id=1
    sleep    10s
    ${tput_dl}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
    ${tput_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    Should be true    ${tput_v1}<=${tput_10m}
    Sleep    1 min    reason=wait for counter ready
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    1
    sleep    10s
    Log To Console      ${\n}============= changed RnD param. =============${\n}
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 session_ambr_ul=5:Mbps by=amf
    ...    pass_regexp=${None}
    sleep    1s
    Airphone Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=PDU Session Resource Modify Unsuccessful Transfer
    Log To Console      ${\n}============= add 5qi7 failure. =============${\n}
    sleep    2s
    Run Keyword And Ignore Error    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=1    qfi_id=1
    Run Keyword And Ignore Error    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=1    qfi_id=2
    sleep    10s
    ${tput_ul_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    sleep    10s
    ${tput_ul_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    Should be true    ${tput_ul_v1}<${tput_10m}
    Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=ul
    sleep    10s
    # stop tcpdump in sbts by command
    # ${capture_file_path}    Download wireshark log to testvm
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    0
    Sleep    5 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check throughput =============${\n}
    Counter Check throughput

CB008234-B #B5-c UL AMBR limitation handling with PDU Session Modify Success for Add Delete PDU AMBR Modify
    [Documentation]    author:keli
    ...    case 9
    ...    1. PDU 1 ULAMBR 10Mbps
    ...       PDU 2 ULAMBR 5Mbps
    ...       ULAMBR 50Mbps
    ...    Setup PDU1 5qi6
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${CURDIR}/counter_rule_B09.txt
    Change RnD Flags By aaShell
    ...    ${RAD_HEXs['rdFailDuAdmissionControl']}    0
    # Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_ul=10:Mbps
    ...    pass_regexp=${None}
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=2 session_ambr_ul=5:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set pdu ul ambr. =============${\n}
    Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue=1 ue_ambr_ul=50:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set ue ul ambr. =============${\n}

    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=2    trf_type=internal
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=3    trf_type=internal
    sleep    1s
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Setup PDU1 5qi6. =============${\n}
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=5 default=on
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= Setup PDU2 5qi5 and 7. =============${\n}
    sleep    2s

    Airphone Qosflow Modify    qos_flow=4    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=1    5qi=9    fiveqi_type=non-gbr
    Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=1 pdu=2 session_ambr_ul=30:Mbps qosflows_to_del=5 qosflows_to_add=3 by=amf
    ...    pass_regexp=${None}

    Log To Console    ${\n}============ modified PDU1 5qi6 to 9 modified ul ambr. ============${\n}
    Log To Console    ${\n}============ pdu2 deleted 5qi5, Added 5qi8. ============${\n}
    sleep    2s
    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=1    qfi_id=1
    Run Keyword And Ignore Error    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=2    qfi_id=1
    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=2    qfi_id=2
    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=2    qfi_id=3
    sleep    10s
    ${tput_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=ul
    Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=2    dir=ul
    Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=3    dir=ul
    Run Keyword And Ignore Error    Airphone Start Traffic    mbps=20m    dir=ul
    ...    pdu_id=1    qfi_id=1
    sleep    5s
    ${tput_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=2    dir=ul
    Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=3    dir=ul
    sleep    5s
    Run Keyword And Ignore Error    Airphone Start Traffic    mbps=20m    dir=ul
    ...    pdu_id=1    qfi_id=1
    Run Keyword And Ignore Error    Airphone Start Traffic    mbps=20m    dir=ul
    ...    pdu_id=2    qfi_id=2
    sleep    5s
    ${tput_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=2    dir=ul
    Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=3    dir=ul
    # stop tcpdump in sbts by command
    # ${capture_file_path}    Download wireshark log to testvm
    Sleep    5 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check throughput =============${\n}
    Counter Check throughput


CB008234-B #B6-a UL AMBR limitation handling with partial PDU Session release
    [Documentation]    author:keli
    ...    case 11
    ...    CRT
    ...    PDU 1 ULAMBR 10Mbps
    ...    PDU 2 ULAMBR 20Mbps
    ...    ULAMBR 50Mbps
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_FDD_2c_1gNBSim_B_TMO
    ...    base_path=${CURDIR}/Airphone
    ...    call_type=sansa
    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_ul=10:Mbps
    ...    pass_regexp=${None}
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=2 session_ambr_ul=5:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set pdu ul ambr. =============${\n}
    Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue=1 ue_ambr_ul=50:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set ue ul ambr. =============${\n}

    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 qfi=1 trf_type=internal
    ...    pass_regexp=${None}
    sleep    1s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=2 qfi=1 trf_type=internal
    ...    pass_regexp=${None}
    sleep    1s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=1 pdu=2 qfi=2 trf_type=internal
    ...    pass_regexp=${None}
    sleep    1s

    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Setup PDU1 5qi6. =============${\n}
    Airphone Start Traffic    mbps=20m    dir=dl
    ...    pdu_id=1    qfi_id=1
    Airphone Start Traffic    mbps=20m    dir=ul
    ...    pdu_id=1    qfi_id=1
    sleep    10s
    ${tput_dl}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
    ${tput_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    Should be true    ${tput_v1}<=${tput_10m}
    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=5 default=on
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=6
    ...    pass_regexp=${None}
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
    ...    pass_regexp=handled successfully
    Log To Console      ${\n}============= Setup PDU2 5qi5 and 1. =============${\n}
    sleep    1s

    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=2    qfi_id=1
    Airphone Start Traffic    mbps=10m    dir=ul
    ...    pdu_id=2    qfi_id=2
    sleep    10s
    ${tput_ul_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    ${tput_ul_v2}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=ul
    ${total_ngbr_throughput}=    Evaluate    ${tput_ul_v1} + ${tput_ul_v2}
    Should be true    ${total_ngbr_throughput}<=${tput_15m}
    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
    ...    qfi_id=2    dir=ul    expected_tput_max=${tput_10m}    expected_tput_min=9000000
    Airphone Execute Egate Command    cmd=ue_pdu_session_release pdu=1 ue=1 by=amf
    ...    pass_regexp=Successfully released
    Log To Console      ${\n}============= Release PDU1. =============${\n}
    sleep    10s
    ${arg_tput_ul_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
    ...    qfi_id=1    dir=ul    expected_tput_max=${tput_5m}    expected_tput_min=4800000
    ${arg_tput_ul_v3}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
    ...    qfi_id=2    dir=ul    expected_tput_max=${tput_10m}    expected_tput_min=9000000

    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    # Check Case11 ULAMBR From WiresharkLog


*** Keywords ***
Disable CB008126
    [Documentation]    Disable 5QI, UL TNL tunnel IP modification function
    @{para_list}   Create List   act5qiAndUlNguTnlQosFlowMod
    @{value_list}   Create List   false
    @{mo_list}   Create List   ${dist_name}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Enable CB008126
    [Documentation]    Enable 5QI, UL TNL tunnel IP modification function
    @{para_list}   Create List   act5qiAndUlNguTnlQosFlowMod
    @{value_list}   Create List   true
    @{mo_list}   Create List   ${dist_name}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Disable CB008379
    @{cell_list}=    Create List    1    2
    @{para_list}   Create List   ${parameter_8379}
    @{value_list}   Create List   false
    FOR   ${cell_i}    IN    @{cell_list}
        @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-${cell_i}
        ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
        ...      value_list=${value_list}   mo_list=${mo_list}
        Log To Console    paramter update result: ${out}
    END

Enable actMcsPrbReductionFdmUl
    @{cell_list}=    Create List    1    2
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${value}    Set Variable    true
    FOR   ${cell_i}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${dist_name}/NRCELL-${cell_i}
        ...    parameter=actMcsPrbReductionFdmUl
        ...    value=${value}    operation=update    connection=commission
    END
    [Teardown]    COAM_Admin.Logout    connection=commission


Disbale actMcsPrbReductionFdmUl
    @{cell_list}=    Create List    1    2
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${value}    Set Variable    false
    FOR   ${cell_i}    IN    @{cell_list}
        coam.perform_parameter_recommissioning    dist_name=${dist_name}/NRCELL-${cell_i}
        ...    parameter=actMcsPrbReductionFdmUl
        ...    value=${value}    operation=update    connection=commission
    END
    [Teardown]    COAM_Admin.Logout    connection=commission

Disable actARPBasedAC
    @{cell_list}=    Create List    1    2
    @{para_list}   Create List   actARPBasedAC
    @{value_list}   Create List   off
    FOR   ${cell_i}    IN    @{cell_list}
        @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-${cell_i}
        ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
        ...      value_list=${value_list}   mo_list=${mo_list}
        Log To Console    paramter update result: ${out}
    END

Enable actARPBasedAC
    @{cell_list}=    Create List    1    2
    @{para_list}   Create List   actARPBasedAC
    @{value_list}   Create List   on
    FOR   ${cell_i}    IN    @{cell_list}
        @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-${cell_i}
        ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
        ...      value_list=${value_list}   mo_list=${mo_list}
        Log To Console    paramter update result: ${out}
    END

Set Param maxNumOfNonGBRBearersSA
    [Arguments]    ${target_value}=${0}
    @{cell_l}=    Create List    1    2
    Change Param maxNumOfNonGBRBearersSA    @{cell_l}    target_value=${target_value}

Change Param maxNumOfNonGBRBearersSA
    [Arguments]    @{cell_list}    ${target_value}
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict1}=    create dictionary    parameterName=maxNumOfNonGBRBearersSA
    ...                              operation=update
    ...                              value=${target_value}
    ${parameter_list}    Create List    ${dict1}
    FOR   ${cell_i}    IN    @{cell_list}
        coam_admin.perform_object_recommissioning
        ...    dist_name=${dist_name}/NRCELL-${cell_i}
        ...    parameter_delta_list=${parameter_list}    operation=update    connection=commission
    END
    [Teardown]    COAM_Admin.Logout    connection=commission


# Qosflow Modify
#     [Arguments]    ${qos_flow}    ${5qi}   ${fiveqi_type}=non-gbr    ${time_out}=3min
#     ${command}    Set Variable    qosflow_modify qos_flow=${qos_flow} 5qi=${5qi} fiveqi_type=${fiveqi_type}
#     ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#     ...          cmd=${command}    timeout=3min

Set Pdu Param For Trf Data
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${trf_type}=internal
    Airphone Execute Egate Command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_type=${trf_type}
    ...    pass_regexp=${None}
    sleep    1s


PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu_id}=2   ${gw_id}=2
    ${cmd}    Catenate   ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${gw_id}
    Airphone Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=${None}

Check Case2 ULAMBR From WiresharkLog
    [Arguments]   ${capture_file_path}
    Check PDU ULAMBR In NGAP By Expression    capture_file_path=${capture_file_path}
    ...    ambr_ul=10485760
    Check PDU ULAMBR In NGAP By Expression    capture_file_path=${capture_file_path}
    ...    ambr_ul=5242880
    Check UE ULAMBR In NGAP By Expression    capture_file_path=${capture_file_path}
    ...    ambr_ul=20971520
    Check calculation ULAMBR In F1AP By Expression    capture_file_path=${capture_file_path}
    ...    ambr_ul=15728640

Check Case11 ULAMBR From WiresharkLog
    Check calculation ULAMBR In F1AP By Expression    capture_file_path=${capture_file_path}
    ...    ambr_ul=10485760
    Check recalc ULAMBR In F1AP By Expression    capture_file_path=${capture_file_path}
    ...    ambr_ul=15728640

Check UE ULAMBR In NGAP By Expression
    [Arguments]  ${capture_file_path}    ${ambr_ul}=10485760
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.uEAggregateMaximumBitRateUL == ${ambr_ul}'
    ...    filter_expression='ngap.uEAggregateMaximumBitRateUL == ${ambr_ul}'

Check PDU ULAMBR In NGAP By Expression
    [Arguments]  ${capture_file_path}    ${ambr_ul}=10485760
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.pDUSessionAggregateMaximumBitRateUL == ${ambr_ul}'
    ...    filter_expression='ngap.pDUSessionAggregateMaximumBitRateUL == ${ambr_ul}'

Check calculation ULAMBR In F1AP By Expression
    [Arguments]  ${capture_file_path}    ${ambr_ul}=10485760
    Check F1AP UeContextSetupRequest By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='f1ap.BitRate == ${ambr_ul}'
    ...    filter_expression='f1ap.BitRate == ${ambr_ul}'

Check recalc ULAMBR In F1AP By Expression
    [Arguments]  ${capture_file_path}    ${ambr_ul}=10485760
    Check F1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='f1ap.BitRate == ${ambr_ul}'
    ...    filter_expression='f1ap.BitRate == ${ambr_ul}'

Check 5QI Initial Setup In NGAP
    [Arguments]  ${capture_file_path}    ${5qi}=9
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.PDUSessionResourceSetupListCxtReq == 1'
    ...    filter_expression='ngap.QosFlowSetupRequestList == 1 && ngap.qosFlowIdentifier == 1'
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.PDUSessionResourceSetupListCxtReq == 1'
    ...    filter_expression='ngap.QosFlowSetupRequestList == 1 && ngap.fiveQI == ${5qi}'

Check NGAP InitialContextSetup By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    InitialContextSetupRequest
    Should Contain    ${output}    InitialContextSetupResponse
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    PDUSessionResourceModifyRequest
    Should Contain    ${output}    PDUSessionResourceModifyResponse
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}


Check E1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=e1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    BearerContextSetupRequest
    Should Contain    ${output}    BearerContextModificationRequest
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Check F1AP UeContextSetupRequest By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=f1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    UEContextSetupRequest
    Should Contain    ${output}    UEContextSetupResponse
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}


Check F1AP PDUSESSIONMODIFY By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=f1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    UEContextModificationRequest
    Should Contain    ${output}    UEContextModificationResponse
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Check F1AP RRC Reconfiguration By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=f1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    RRC Reconfiguration Complete
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Check F1AP RRC Reconfiguration In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=f1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    RRC Reconfiguration Complete


Check NGAP PDUSESSIONMODIFY Failed In Wireshark Log
    [Documentation]    check ngap.radioNetwork
    ...    ngap.radioNetwork == 22 radio resources not available
    ...    ngap.radioNetwork == 34 not supported 5QI value
    [Arguments]  ${capture_file_path}    ${num}=22
    Check NGAP PDUSESSIONMODIFY By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.PDUSessionResourceFailedToModifyListModRes == 1'
    ...    filter_expression='ngap.cause == 0 && ngap.radioNetwork == ${num}'

Change RnD Flags By aaShell
    [Arguments]    @{args}    ${is_permanent}=no
    ccs_aashell.create_aashell_cli    name=aashell
    ccs_aashell.setup    aashell
    ccs_aashell.change_rad_params    aashell    ${args}    ${is_permanent}
    Sleep  10s    Wait for r&d param application
    [Teardown]    ccs_aashell.teardown   aashell

Check Ave Tput via bearer stats
    [Documentation]     check the average of two tput value
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${qfi_id}=1
    ...    ${dir}=dl   ${expected_tput_max}=10000000    ${expected_tput_min}=0
    ${tput_v1}    Airphone Get Average Throughput    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}    qfi=${qfi_id}    dir=${dir}
    sleep    2s
    ${tput_v2}    Airphone Get Average Throughput    ue_id=${ue_id}
    ...    pdu_id=${pdu_id}    qfi=${qfi_id}    dir=${dir}
    ${arg_tput}=    Evaluate    (${tput_v1} + ${tput_v2})/2
    Should be true    ${arg_tput}<=${expected_tput_max}
    Should be true    ${arg_tput}>=${expected_tput_min}
    [Return]    ${arg_tput}

Counter Check throughput
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

Start Traffic Both DL and UL
    [Arguments]    ${mbps}=5m    ${pdu_id}=1    ${qfi_id}=1
    Airphone Start Traffic    mbps=${mbps}    dir=dl
    ...    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Log To Console      ${\n}============= DL traffic is started. =============${\n}
    sleep    1s
    Airphone Start Traffic    mbps=${mbps}    dir=ul
    ...    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Log To Console      ${\n}============= UL traffic is started. =============${\n}