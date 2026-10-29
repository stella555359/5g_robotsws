*** Settings ***
Documentation
...   author: keli.weng
...   contact: keli.weng@nokia-sbell.com
...   this is a robot case about CB008234-SR B34
...   Default WTS cfg file is wts_SA_TDD_2c_1gNBSim_A_B4
...   Default 5QI is 7
...   Some cases have its own cfg file and scf file
Resource           ../Resources/common_resource.robot
Resource           ../../Resources/Common/Airphone.robot
# Resource          ../Resources/top50_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
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


Test Timeout    60 minutes

# Library           taf.ccs.aashell   WITH NAME    ccs_aashell
*** Variables ***
#reduce global paramter as possilbe and automatically got from gNB or __init__
&{fault_7300}             faultId=${7300}
@{Ohter_Allow_Alarms}     &{fault_7300}
${APC_Index}    -1
# ${DEBUG_MODE}            ${TRUE}
${total_throughput}    ${0}
${parameter}           act5qiAndUlNguTnlQosFlowMod
${parameter_8379}      actNonVoNRGbrService
${dist_name}           MRBTS-1/NRBTS-1
${tput_1m}             1053000
${tput_5m}             5250000
${tput_5m_bl}          5000000
${tput_10m}            10530000
${tput_10m_bl}         10000000
${tput_15m}            15810000
${tput_15m_bl}         15000000
${tput_20m}            22000000
${tput_25m}            26350000
${tput_60m}            62914560
${tput_65m}            65000000
&{RAD_HEXs}                     rdOverloadHighThreshold=0x89006f
...                             rdFailDuAdmissionControl=0x590249


# ${REMOTE_MODE}           ${TRUE}
${PATH2}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T03/CB008234/Airphone

*** Test Cases ***
# CB008234_A_1_B4_DL AMBR limitation handling during ICS with single PDU session with single non-GBR setup
#     [Documentation]    author:keli
#     ...    case1
#     ...    1. UE AMBR 10Mbps PDU AMBR 20Mbps
#     ...    2. setup 5QI 9
#     ...    3. UE AMBR Setting 8Mbps
#     ...    4. repeat step1-2
#     ...    5. UE AMBR Setting 15Mbps
#     ...    6. repeat step1-2
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=20:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     sleep    1s

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}
#     Airphone Start Traffic    mbps=20m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     sleep    10s
#     ${arg_tput_dl}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     Should be true    ${arg_tput_dl}<=${tput_10m}
#     Should be true    ${arg_tput_dl}>10000000
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm
#     Check 5QI Initial Setup In NGAP    capture_file_path=${capture_file_path}
#     ...    5qi=9
#     Check DLAMBR In E1AP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=10485760
#     Airphone Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
#     ...    pass_regexp=${None}
#     # retest with pdu1 dl ambr 8Mbps
#     Start tcpdump in SBTS by command
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=8:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}========== set pdu dl ambr 8Mbps. =============${\n}

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}
#     Airphone Start Traffic    mbps=20m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     sleep    10s
#     ${arg_tput_dl}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     Should be true    ${arg_tput_dl}<=${tput_10m}
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm
#     Airphone Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
#     ...    pass_regexp=${None}

#     Check DLAMBR In E1AP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=8388608

#     # retest with pdu1 dl ambr 10Mbps
#     Start tcpdump in SBTS by command
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}========== set pdu dl ambr 10Mbps. =============${\n}

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}
#     Airphone Start Traffic    mbps=20m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     sleep    10s
#     ${arg_tput_dl}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     Should be true    ${arg_tput_dl}<=${tput_10m}
#     Should be true    ${arg_tput_dl}>10000000
#     sleep    2s
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm
#     Airphone Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
#     ...    pass_regexp=${None}
#     Check DLAMBR In E1AP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=10485760



# CB008234_A_2_B4_DL AMBR limitation handling during ICS with single PDU session with multi-DRB setup
#     [Documentation]    author:keli
#     ...    case2
#     ...    CRT
#     ...    1. UE AMBR 10Mbps PDU AMBR 10Mbps
#     ...    2. setup 5QI 9 and 6
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12006,M55319C12009;
#     ...    Counter rule: latest(M55319C12006)/latest(M55319C12009)>18;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12006,M55319C12009;
#     ...    Counter rule: latest(M55319C12006)/latest(M55319C12009)<20;
#     ${rule_list}    Create List    ${rule1}    ${rule2}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     # set 5qi6 schedulweight 19
#     Set Param DRB schedulWeight    DRB_id=11    target_value=19
#     sleep    1s
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     # Airphone Execute Egate Command
#     # ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=2 session_ambr_dl=5:Mbps
#     # ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=12
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi9 and 6. =============${\n}
#     Airphone Start Traffic    mbps=15m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=15m    dir=dl
#     ...    pdu_id=1    qfi_id=2
#     sleep    10s
#     ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     ...    qfi_id=1    dir=dl    expected_tput_max=${tput_1m}    expected_tput_min=0
#     ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     ...    qfi_id=2    dir=dl    expected_tput_max=${tput_10m}    expected_tput_min=9500000
#     ${total_throughput}=    Evaluate    ${arg_tput_dl_v1} + ${arg_tput_dl_v2}
#     Should be true    ${total_throughput}<=${tput_10m}
#     Should be true    ${total_throughput}>10400000
#     sleep    2s
#     # ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     # ...    qfi_id=1    dir=dl    expected_tput_max=${tput_1m}    expected_tput_min=0
#     # ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     # ...    qfi_id=2    dir=dl    expected_tput_max=${tput_10m}    expected_tput_min=9900000
#     # ${total_throughput}=    Evaluate    ${arg_tput_dl_v1} + ${arg_tput_dl_v2}
#     # Should be true    ${total_throughput}<=${tput_10m}
#     # Should be true    ${total_throughput}>10400000
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm
#     Check UE DLAMBR In NGAP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=10485760
#     Check PDU DLAMBR In NGAP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=10485760
#     Check DLAMBR In E1AP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=10485760
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check throughput =============${\n}
#     Counter Check DL throughput

# CB008234_A_3_B4_DL AMBR limitation handling during ICS with single PDU session with multi-DRB setup FAF=off
#     [Documentation]    author:keli
#     ...    case3
#     ...    1. UE AMBR 10Mbps PDU AMBR 15Mbps
#     ...    2. setup 5QI 7 and 6
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Disable CB008234 DL AMBR
#     # set 5qi6 schedulweight 19
#     Set Param DRB schedulWeight    DRB_id=11    target_value=19
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=15:Mbps
#     ...    pass_regexp=${None}
#     # Airphone Execute Egate Command
#     # ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=2 session_ambr_dl=5:Mbps
#     # ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=12
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi7 and 6. =============${\n}
#     Airphone Start Traffic    mbps=20m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=20m    dir=dl
#     ...    pdu_id=1    qfi_id=2
#     Log To Console      ${\n}============= DL traffic is started. =============${\n}
#     sleep    10s
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     Should be true    ${arg_tput_dl_v1}>10400000
#     Should be true    ${arg_tput_dl_v2}>10400000
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm


# CB008234_A_4_B4_DL AMBR limitation handling during ICS without PDU Session setup and UE AMBR IE is present
#     [Documentation]    author:keli
#     ...    case4 ta before test
#     ...    1. UE AMBR 15Mbps PDU AMBR 20Mbps
#     ...    2. setup 5QI 7 and 6
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=20:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=15:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal

#     Airphone Execute Egate Command
#     ...    cmd=amf_param id=1 ambr_remove=pdu_setup,nas_transport send_ics_registration=on
#     ...    pass_regexp=${None}

#     Airphone Execute Egate Command    cmd=ue_register id=1
#     ...    pass_regexp=REGISTRATION COMPLETE

#     Log To Console      ${\n}============= ICS without PDU setup. =============${\n}
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=12
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Setup PDU1 5qi7 and 6. =============${\n}
#     sleep    2s
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=1    qfi_id=2
#     Log To Console      ${\n}============= DL traffic is started. =============${\n}
#     sleep    10s
#     ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     ...    qfi_id=1    dir=dl    expected_tput_max=${tput_10m}    expected_tput_min=0
#     ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     ...    qfi_id=2    dir=dl    expected_tput_max=${tput_10m}    expected_tput_min=0
#     ${total_throughput}=    Evaluate    ${arg_tput_dl_v1} + ${arg_tput_dl_v2}
#     Should be true    ${total_throughput}<=${tput_15m}
#     Should be true    ${total_throughput}>15000000
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm
#     Check UE DLAMBR In NGAP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=15728640
#     Check PDU DLAMBR In NGAP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=20971520
#     Check DLAMBR In E1AP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=15728640

# CB008234_A_5_B4_DL AMBR limitation handling during ICS without PDU Session setup and UE AMBR IE is also not present
#     [Documentation]    author:keli
#     ...    case5 ta before test
#     ...    1. UE AMBR 10Mbps PDU AMBR 20Mbps
#     ...    2. setup 5QI 9 and 6
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=20:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_param id=1 ambr_remove=ics
#     ...    pass_regexp=${None}

#     Log To Console      ${\n}============= remove ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     sleep    1s

#     Airphone Execute Egate Command
#     ...    cmd=amf_param id=1 send_ics_registration=on
#     ...    pass_regexp=${None}

#     Airphone Execute Egate Command    cmd=ue_register id=1
#     ...    pass_regexp=REGISTRATION COMPLETE

#     Log To Console      ${\n}============= ICS without PDU setup. =============${\n}
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=12
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
#     ...    pass_regexp=QoS Routing Table
#     Log To Console      ${\n}============= Setup PDU1 5qi9 and 6. =============${\n}
#     sleep    2s
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=1    qfi_id=2
#     Log To Console      ${\n}============= DL traffic is started. =============${\n}
#     sleep    10s
#     ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     ...    qfi_id=1    dir=dl    expected_tput_max=${tput_10m}    expected_tput_min=0
#     ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     ...    qfi_id=2    dir=dl    expected_tput_max=${tput_10m}    expected_tput_min=0
#     ${total_throughput}=    Evaluate    ${arg_tput_dl_v1} + ${arg_tput_dl_v2}
#     Should be true    ${total_throughput}<=${tput_10m}
#     Should be true    ${total_throughput}>10400000
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm

#     Check PDU DLAMBR In NGAP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=20971520
#     Check DLAMBR In E1AP By Expression    capture_file_path=${capture_file_path}
#     ...    ambr_dl=10485760


# CB008234_A_6_B5_DL AMBR limitation handling during ICS with multi-PDU Sessions setup with multi-DRB setup
#     [Documentation]    author:keli
#     ...    CRT
#     ...    1. UE AMBR 80Mbps PDU AMBR 30Mbps
#     ...    5QI6 Schedulweight 20
#     ...    5QI7 Schedulweight 10
#     ...    5QI8 Schedulweight 5
#     ...    5QI9 Schedulweight default
#     ...    2. setup PDU1 5QI 7 and 6
#     ...    3. setup PDU1 5QI 7 and 8
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12006,M55319C12008;
#     ...    Counter rule: max(M55319C12006)/max(M55319C12008)>3.8;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12006,M55319C12008;
#     ...    Counter rule: max(M55319C12006)/max(M55319C12008)<4.2;
#     ${rule_list}    Create List    ${rule1}    ${rule2}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1,2 session_ambr_dl=30:Mbps
#     ...    pass_regexp=${None}

#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=80:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=2    trf_type=internal

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=12
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_pdu_setup_param id=1 ue=1 action=delay_till_next_pdu_setup
#     ...    pass_regexp=${None}

#     Airphone Execute Egate Command    cmd=ue_register id=1
#     ...    pass_regexp=REGISTRATION COMPLETE

#     Log To Console      ${\n}============= ICS without PDU setup. =============${\n}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
#     ...    pass_regexp=${None}
#     sleep    1s
#     # Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     # ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=14
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
#     ...    pass_regexp=QoS Routing Table
#     Log To Console      ${\n}============= Setup PDU1 5qi7 and 6. =============${\n}
#     Log To Console      ${\n}============= Setup PDU2 5qi7 and 8. =============${\n}
#     sleep    2s
#     Airphone Start Traffic    mbps=30m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=30m    dir=dl
#     ...    pdu_id=1    qfi_id=2
#     Airphone Start Traffic    mbps=30m    dir=dl
#     ...    pdu_id=2    qfi_id=1
#     Airphone Start Traffic    mbps=30m    dir=dl
#     ...    pdu_id=2    qfi_id=2
#     sleep    10s
#     ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     ...    qfi_id=1    dir=dl    expected_tput_max=14000000    expected_tput_min=13000000
#     ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     ...    qfi_id=2    dir=dl    expected_tput_max=30000000    expected_tput_min=27000000
#     ${arg_tput_dl_v3}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
#     ...    qfi_id=1    dir=dl    expected_tput_max=14000000    expected_tput_min=13000000
#     ${arg_tput_dl_v4}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
#     ...    qfi_id=2    dir=dl    expected_tput_max=7100000    expected_tput_min=6000000
#     ${pdu1_throughput}=    Evaluate    ${arg_tput_dl_v1} + ${arg_tput_dl_v2}
#     ${pdu2_throughput}=    Evaluate    ${arg_tput_dl_v3} + ${arg_tput_dl_v4}
#     ${total_throughput}=    Evaluate    ${pdu1_throughput} + ${pdu2_throughput}
#     Should be true    ${total_throughput}<=${tput_65m}
#     sleep    10s
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check throughput =============${\n}
#     Counter Check DL throughput

# CB008234_A_7_B5_DL AMBR limitation handling with PDU Session Setup with 2nd PDU session
#     [Documentation]    author:keli
#     ...    CRT
#     ...    1. UE AMBR 10Mbps PDU1,2 AMBR 10Mbps
#     ...    5QI6 Schedulweight 20
#     ...    5QI7 Schedulweight 10
#     ...    5QI8 Schedulweight 5
#     ...    5QI9 Schedulweight 10
#     ...    2. setup PDU1 5QI 9
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12007,M55319C12009;
#     ...    Counter rule: max(M55319C12007)/max(M55319C12009)>0.8;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12007,M55319C12009;
#     ...    Counter rule: max(M55319C12007)/max(M55319C12009)<1.2;
#     ${rule_list}    Create List    ${rule1}    ${rule2}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

#     Set Param DRB schedulWeight    DRB_id=14    target_value=10
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=2 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=2    trf_type=internal

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Setup PDU2 5qi7. =============${\n}
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=2    qfi_id=1
#     sleep    10s
#     ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     ...    qfi_id=1    dir=dl    expected_tput_max=${tput_5m}    expected_tput_min=5000000
#     ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
#     ...    qfi_id=1    dir=dl    expected_tput_max=${tput_5m}    expected_tput_min=5000000
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check throughput =============${\n}
#     Counter Check DL throughput


# CB008234_A_8_B5_DL AMBR limitation handling with PDU Session Setup with 2nd PDU session without DL AMBR Limit IE
#     [Documentation]    author:keli
#     ...    CRT
#     ...    1. UE AMBR 10Mbps PDU1 AMBR 10Mbps
#     ...    5QI6 Schedulweight 20
#     ...    5QI7 Schedulweight 10
#     ...    5QI8 Schedulweight 5
#     ...    5QI9 Schedulweight 40
#     ...    2. setup PDU1 5QI 9
#     ...    3. setup PDU2 5QI 7
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12007,M55319C12009;
#     ...    Counter rule: max(M55319C12009)/max(M55319C12007)>3.8;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12007,M55319C12009;
#     ...    Counter rule: max(M55319C12009)/max(M55319C12007)<4.2;
#     ${rule_list}    Create List    ${rule1}    ${rule2}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

#     Set Param DRB schedulWeight    DRB_id=14    target_value=40
#     Log To Console      ${\n}============ set 5qi 9 drb schedulweight. ============${\n}
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}

#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Airphone Execute Egate Command
#     ...    cmd=amf_param id=1 ambr_remove=ics send_ics_registration=on
#     ...    pass_regexp=${None}


#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=2    trf_type=internal
#     sleep    1s
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_pdu_setup_param id=1 ue=1 action=delay_till_next_pdu_setup
#     ...    pass_regexp=${None}

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_register id=1
#     ...    pass_regexp=REGISTRATION COMPLETE

#     Log To Console      ${\n}============= ICS without PDU setup. =============${\n}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
#     ...    pass_regexp=${None}

#     sleep    1s
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     ...    pass_regexp=${None}

#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
#     ...    pass_regexp=QoS Routing Table
#     Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}

#     Log To Console      ${\n}============= Setup PDU2 5qi7. =============${\n}

#     sleep    2s
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=2    qfi_id=1
#     sleep    10s
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl
#     ${total_throughput}=    Evaluate    ${arg_tput_dl_v1} + ${arg_tput_dl_v2}
#     Should be true    ${total_throughput}<=${tput_10m}
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check throughput =============${\n}
#     Counter Check DL throughput

# CB008234_A_9_B5_DL AMBR limitation handling with PDU Session Setup with 2nd PDU session with mixed non GBR and GBR DRB
#     [Documentation]    author:keli
#     ...    Ta before test
#     ...    5QI5 Schedulweight 10
#     ...    5QI6 Schedulweight 20
#     ...    5QI7 Schedulweight 10
#     ...    5QI8 Schedulweight 5
#     ...    5QI9 Schedulweight 10
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Set Param DRB schedulWeight    DRB_id=14    target_value=10
#     Set Param DRB schedulWeight    DRB_id=10    target_value=10
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=2 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=15:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}


#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=2    trf_type=internal

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=13
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi9 and 7. =============${\n}
#     sleep    2s
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=1    qfi_id=2
#     sleep    10s
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=11 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Setup PDU2 5qi5 and 2. =============${\n}
#     sleep    2s
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=2    qfi_id=1
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=2    qfi_id=2
#     sleep    10s
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     ${arg_tput_dl_v3}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl
#     ${arg_tput_dl_v4}    Airphone Get Average Throughput    pdu_id=2    qfi=2    dir=dl
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm


# CB008234_A_10_B5_DL AMBR limitation handling with PDU Session Setup with 2 PDU sessions
#     [Documentation]    author:keli
#     ...    Ta before test
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Set Param DRB schedulWeight    DRB_id=14    target_value=20
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=2 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=3 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=3    qfi_id=1    trf_type=internal

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}
#     sleep    2s

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Setup PDU2 5qi7. =============${\n}
#     sleep    2s
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=3 ue=1 nwslice=1 gw=3
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Setup PDU3 5qi7. =============${\n}
#     sleep    2s
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=2    qfi_id=1
#     Airphone Start Traffic    mbps=10m    dir=dl
#     ...    pdu_id=3    qfi_id=1
#     sleep    10s
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl
#     ${arg_tput_dl_v3}    Airphone Get Average Throughput    pdu_id=3    qfi=1    dir=dl
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm


# CB008234_A_11_B5_DL AMBR limitation handling with PDU Session Setup with partial admission control disable
#     [Documentation]    author:keli
#     ...    Ta before test
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Disable actARPBasedAC
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1,2 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=2    trf_type=internal


#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}

#     Set Param maxNumOfNonGBRBearersSA    2
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=14
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
#     ...    pass_regexp=radio resources not available
#     Log To Console      ${\n}============= Setup PDU2 5qi7 and 8. =============${\n}

#     Airphone Start Traffic    mbps=15m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Run Keyword And Ignore Error    Airphone Start Traffic    mbps=15m    dir=dl
#     ...    pdu_id=2    qfi_id=1
#     Run Keyword And Ignore Error    Airphone Start Traffic    mbps=15m    dir=dl
#     ...    pdu_id=2    qfi_id=2
#     sleep   10s
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     # ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl
#     # ${arg_tput_dl_v3}    Airphone Get Average Throughput    pdu_id=2    qfi=2   dir=dl
#     Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm


# CB008234_A_12_B5_DL AMBR limitation handling with PDU Session Setup with partial admission control enable
#     [Documentation]    author:keli
#     ...    Ta before test
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Enable actARPBasedAC
#     Set Param DRB schedulWeight    DRB_id=14    target_value=10
#     Log To Console      ${\n}============ set 5qi 9 drb schedulweight. ============${\n}
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1,2 session_ambr_dl=10:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=40:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=2    trf_type=internal

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=12
#     ...    pass_regexp=${None}
#     Airphone Attach    ue_id=1    call_type=SA
#     Log To Console      ${\n}============= Setup PDU1 5qi9 and 5qi6. =============${\n}
#     Airphone Start Traffic    mbps=15m    dir=dl
#     ...    pdu_id=1    qfi_id=1
#     Airphone Start Traffic    mbps=15m    dir=dl
#     ...    pdu_id=1    qfi_id=2
#     sleep    10s
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl

#     Set Param maxNumOfNonGBRBearersSA    3
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=14
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Setup PDU2 5qi7 and 8. =============${\n}
#     sleep    2s

#     Run Keyword And Ignore Error    Airphone Start Traffic    mbps=15m    dir=dl
#     ...    pdu_id=2    qfi_id=1
#     Run Keyword And Ignore Error    Airphone Start Traffic    mbps=15m    dir=dl
#     ...    pdu_id=2    qfi_id=2
#     sleep    10s
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl
#     Run Keyword And Ignore Error    Airphone Get Average Throughput    pdu_id=2    qfi=2    dir=dl
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm


CB008234_20_AMBR limitation interacts with CB008126_UL NGU TNL Modification
    [Documentation]    author:keli
    ...    Ta before test
    [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
    ...    base_path=${CURDIR}/Airphone
    ${rule1}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16009;
    ...    Counter rule: latest(M55319C16009)==0;
    ${rule2}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C16007;
    ...    Counter rule: latest(M55319C16007)>0;
    ${rule3}    Catenate
    ...    Distname: MRBTS-1/NRBTS-1;
    ...    Counter: M55319C12007;
    ...    Counter rule: latest(M55319C12007)>0;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

    Start tcpdump in SBTS by command
    Start Multi Bts Log
    Airphone Execute Egate Command
    ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=10:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
    Airphone Execute Egate Command
    ...    cmd=amf_ue_param ue=1 ue_ambr_dl=20:Mbps
    ...    pass_regexp=${None}
    Log To Console      ${\n}============= set ue dl ambr. =============${\n}
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
    Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal

    Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
    ...    pass_regexp=${None}
    Airphone Attach    ue_id=1    call_type=SA
    Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}
    sleep    2s
    Airphone Start Traffic    mbps=40m    dir=dl
    ...    pdu_id=1    qfi_id=1
    Airphone Start Traffic    mbps=40m    dir=ul
    ...    pdu_id=1    qfi_id=1
    sleep    10s
    ${arg_tput_ul_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
    sleep    2s
    Airphone Qosflow Modify    qos_flow=13    5qi=177    fiveqi_type=non-gbr
    Airphone Qosflow Modify    qos_flow=15    5qi=7    fiveqi_type=non-gbr
    ${ret}    airphone_pdu_session_modify    ue_id=1
    ...    pdu_id=1
    ...    qosflows_to_modify=15
    ...    session_ambr_dl=40:Mbps
    ...    session_ambr_ul=40:Mbps
    ...    switch_ul_tunnel_endpoint=ip_teid by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID
    Log To Console    ${\n}============ Modified 5qi9to7. ============${\n}
    sleep    2s
    Run Keyword And Ignore Error    Airphone Start Traffic    mbps=40m    dir=ul
    ...    pdu_id=1    qfi_id=1
    sleep    10s

    ${arg_tput_ul_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=ul
    ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
    ...    qfi_id=1    dir=dl    expected_tput_max=${tput_20m}    expected_tput_min=${tput_15m}
    stop tcpdump in sbts by command
    ${capture_file_path}    Download wireshark log to testvm
    Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    Sleep    5 min    reason=wait for counter ready
    Log To Console      ${\n}============= Check throughput =============${\n}
    Counter Check DL throughput

# CB008234_21_EC1_DL AMBR limitation handling with feature activation with related parameters boundary testing
#     [Documentation]    author:keli
#     ...    case21 ta before test
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Start Multi Bts Log
#     Log To Console    start change param
#     ${value_list1}=    Set Variable    100,100,0
#     ${value_list2}=    Set Variable    100,100,100
#     ${value_list3}=    Set Variable    100,2000,0
#     ${value_list4}=    Set Variable    1000,1000,1000
#     ${value_list5}=    Set Variable    2000,2000,2000
#     ${value_lists}    Create List    ${value_list1}    ${value_list2}    ${value_list3}
#     ...    ${value_list4}    ${value_list5}
#     FOR   ${target_value_list}    IN    @{value_lists}
#         ${split_values}=    Split String    ${target_value_list}    ,
#         Start tcpdump in SBTS by command
#         Set Param dlAmbr time param    ${split_values}[0]
#         ...    ${split_values}[1]    ${split_values}[2]
#         Airphone Execute Egate Command
#         ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1 session_ambr_dl=20:Mbps
#         ...    pass_regexp=${None}
#         Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#         Airphone Execute Egate Command
#         ...    cmd=amf_ue_param ue=1 ue_ambr_dl=10:Mbps
#         ...    pass_regexp=${None}
#         Log To Console      ${\n}============= set ue dl ambr. =============${\n}
#         Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#         sleep    1s

#         Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#         ...    pass_regexp=${None}
#         Airphone Attach    ue_id=1    call_type=SA
#         Log To Console      ${\n}============= Setup PDU1 5qi9. =============${\n}
#         Airphone Start Traffic    mbps=20m    dir=dl
#         ...    pdu_id=1    qfi_id=1
#         sleep    10s
#         # ${arg_tput_dl}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#         ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#         ...    qfi_id=1    dir=dl    expected_tput_max=${tput_10m}    expected_tput_min=10000000
#         # Should be true    ${arg_tput_dl}<=${tput_10m}
#         # Should be true    ${arg_tput_dl}>10000000
#         Airphone Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
#         ...    pass_regexp=${None}
#         stop tcpdump in sbts by command
#         ${capture_file_path}    Download wireshark log to testvm
#     END

# CB008234_A_EC_test
#     [Documentation]    author:keli
#     ...    Ta before test
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_B4
#     ...    base_path=${CURDIR}/Airphone
#     Set Param DRB schedulWeight    DRB_id=12    target_value=2
#     Set Param DRB schedulWeight    DRB_id=13    target_value=3
#     Set Param DRB schedulWeight    DRB_id=14    target_value=4
#     Start tcpdump in SBTS by command
#     Start Multi Bts Log
#     Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id=1 ue=1 pdu=1,2 session_ambr_dl=120:Mbps
#     ...    pass_regexp=${None}

#     Log To Console      ${\n}============= set pdu dl ambr. =============${\n}
#     Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue=1 ue_ambr_dl=60:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= set ue dl ambr. =============${\n}

#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=1    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=2    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=1    qfi_id=3    trf_type=internal
#     Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=1    trf_type=internal
#     # Set Pdu Param For Trf Data    ue_id=1    pdu_id=2    qfi_id=2    trf_type=internal

#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=13 default=on
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=14
#     ...    pass_regexp=${None}
#     # Airphone Execute Egate Command
#     # ...    cmd=amf_ue_pdu_setup_param id=1 ue=1 action=delay_till_next_pdu_setup
#     # ...    pass_regexp=${None}

#     Airphone Execute Egate Command    cmd=ue_register id=1
#     ...    pass_regexp=REGISTRATION COMPLETE

#     Log To Console      ${\n}============= ICS without PDU setup. =============${\n}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
#     ...    pass_regexp=QoS Routing Table
#     sleep    1s
#     Airphone Execute Egate Command    cmd=qosflow_modify qos_flow=15 default=on
#     ...    pass_regexp=${None}
#     # Airphone Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=14
#     # ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=2
#     ...    pass_regexp=QoS Routing Table
#     Log To Console      ${\n}============= Setup PDU1 5qi7 and 8. =============${\n}
#     Log To Console      ${\n}============= Setup PDU2 5qi9. =============${\n}
#     sleep    2s
#     Airphone Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 protocol=tcp
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=100 protocol=tcp
#     ...    pass_regexp=${None}
#     # Airphone Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl mbps=80 protocol=tcp
#     # ...    pass_regexp=${None}
#     # Airphone Execute Egate Command    cmd=trf_data_start ue=1 pdu=2 qfi=2 dir=dl mbps=30 protocol=tcp
#     # ...    pass_regexp=${None}
#     # Airphone Start Traffic    mbps=80m    dir=dl
#     # ...    pdu_id=1    qfi_id=1
#     # Airphone Start Traffic    mbps=80m    dir=dl
#     # ...    pdu_id=1    qfi_id=2
#     # Airphone Start Traffic    mbps=30m    dir=dl
#     # ...    pdu_id=1    qfi_id=3
#     sleep    10s
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     ${arg_tput_dl_v3}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl
#     sleep    1min
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     ${arg_tput_dl_v3}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl
#     Airphone Execute Egate Command    cmd=trf_data_stop ue=1 pdu=all
#     ...    pass_regexp=${None}
#     sleep    10s

#     Airphone Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 protocol=tcp
#     ...    pass_regexp=${None}
#     Airphone Execute Egate Command    cmd=trf_data_start ue=1 pdu=2 qfi=1 dir=dl mbps=100 protocol=tcp
#     ...    pass_regexp=${None}

#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     ${arg_tput_dl_v3}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl
#     sleep    1min
#     ${arg_tput_dl_v1}    Airphone Get Average Throughput    pdu_id=1    qfi=1    dir=dl
#     ${arg_tput_dl_v2}    Airphone Get Average Throughput    pdu_id=1    qfi=2    dir=dl
#     ${arg_tput_dl_v3}    Airphone Get Average Throughput    pdu_id=2    qfi=1    dir=dl


#     # ${arg_tput_dl_v4}    Airphone Get Average Throughput    pdu_id=2    qfi=2    dir=dl
#     # ${arg_tput_dl_v1}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     # ...    qfi_id=1    dir=dl    expected_tput_max=14000000    expected_tput_min=13000000
#     # ${arg_tput_dl_v2}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=1
#     # ...    qfi_id=2    dir=dl    expected_tput_max=30000000    expected_tput_min=27000000
#     # ${arg_tput_dl_v3}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
#     # ...    qfi_id=1    dir=dl    expected_tput_max=14000000    expected_tput_min=13000000
#     # ${arg_tput_dl_v4}    Check Ave Tput via bearer stats   ue_id=1    pdu_id=2
#     # ...    qfi_id=2    dir=dl    expected_tput_max=7100000    expected_tput_min=6000000
#     # ${pdu1_throughput}=    Evaluate    ${arg_tput_dl_v1} + ${arg_tput_dl_v2}
#     # ${pdu2_throughput}=    Evaluate    ${arg_tput_dl_v3} + ${arg_tput_dl_v4}
#     # ${total_throughput}=    Evaluate    ${pdu1_throughput} + ${pdu2_throughput}
#     # Should be true    ${total_throughput}<=${tput_65m}
#     sleep    2min
#     stop tcpdump in sbts by command
#     ${capture_file_path}    Download wireshark log to testvm



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

Disable CB008234 DL AMBR
    @{para_list}   Create List   actDlAmbr
    @{value_list}   Create List   disabled
    @{mo_list}   Create List   MRBTS-1/NRBTS-1
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

Enable CB008234 DL AMBR
    @{para_list}   Create List   actDlAmbr
    @{value_list}   Create List   SA
    @{mo_list}   Create List   MRBTS-1/NRBTS-1
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
    @{para_list}   Create List   actMcsPrbReductionFdmUl
    @{value_list}   Create List   true
    FOR   ${cell_i}    IN    @{cell_list}
        @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-${cell_i}
        ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
        ...      value_list=${value_list}   mo_list=${mo_list}
        Log To Console    paramter update result: ${out}
    END

Disbale actMcsPrbReductionFdmUl
    @{cell_list}=    Create List    1    2
    @{para_list}   Create List   actMcsPrbReductionFdmUl
    @{value_list}   Create List   false
    FOR   ${cell_i}    IN    @{cell_list}
        @{mo_list}   Create List   MRBTS-1/NRBTS-1/NRCELL-${cell_i}
        ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
        ...      value_list=${value_list}   mo_list=${mo_list}
        Log To Console    paramter update result: ${out}
    END

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


Set Param DRB schedulWeight
    [Arguments]    ${DRB_id}=14    ${target_value}=${0}
    @{para_list}   Create List   schedulWeight
    @{value_list}   Create List   ${target_value}
    @{mo_list}   Create List   ${dist_name}/NRDRB-${DRB_id}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}
    Log To Console    paramter update result: ${out}

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



Set Param dlAmbr time param
    [Arguments]    ${target_value1}=100    ${target_value2}=1000    ${target_value3}=500
    @{para_list}   Create List   dlAmbrMonitorPeriod    dlAmbrSampInterval    dlAmbrZeroRateMonitorDuration
    @{value_list}   Create List   ${target_value1}    ${target_value2}    ${target_value3}
    @{mo_list}   Create List   ${dist_name}    ${dist_name}    ${dist_name}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    timeout=90s
    Log To Console    paramter update result: ${out}


PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu_id}=2   ${gw_id}=2
    ${cmd}    Catenate   ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1 gw=${gw_id}
    Airphone Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=${None}

Set Pdu Param For Trf Data
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${trf_type}=internal
    Airphone Execute Egate Command
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_type=${trf_type}
    ...    pass_regexp=${None}
    sleep    1s


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

Check UE DLAMBR In NGAP By Expression
    [Arguments]  ${capture_file_path}    ${ambr_dl}=10485760
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.uEAggregateMaximumBitRateDL == ${ambr_dl}'
    ...    filter_expression='ngap.uEAggregateMaximumBitRateDL == ${ambr_dl}'

Check PDU DLAMBR In NGAP By Expression
    [Arguments]  ${capture_file_path}    ${ambr_dl}=10485760
    Check NGAP InitialContextSetup By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='ngap.pDUSessionAggregateMaximumBitRateDL == ${ambr_dl}'
    ...    filter_expression='ngap.pDUSessionAggregateMaximumBitRateDL == ${ambr_dl}'

Check DLAMBR In E1AP By Expression
    [Arguments]  ${capture_file_path}    ${ambr_dl}=10485760
    Check E1AP BearerContextSetupRequest By Expression In Wireshark Log
    ...    capture_file_path=${capture_file_path}
    ...    filter='e1ap.BitRate == ${ambr_dl}'
    ...    filter_expression='e1ap.BitRate == ${ambr_dl}'


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

Check E1AP BearerContextSetupRequest By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=e1ap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    BearerContextSetupRequest
    Should Contain    ${output}    BearerContextSetupResponse
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

Check NGAP PDUSESSIONSETUP By Expression In Wireshark Log
    [Arguments]  ${capture_file_path}    ${filter}    ${filter_expression}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    PDUSessionResourceSetupRequest
    ${output}    Parse Pcap by expressionbackup
    ...    filter=${filter}
    ...    filter_expression=${filter_expression}
    ...    input_file=${capture_file_path}

Check PDURESOURCEMODIFYSUCCESSRESPONSE In Wireshark Log
    [Arguments]  ${capture_file_path}
    ${output}    Parse Pcap by expression    filter_expression=ngap
    ...    input_file=${capture_file_path}
    Should Contain    ${output}    PDUSessionResourceModifyRequest
    Should Contain    ${output}    PDUSessionResourceModifyResponse

    ${output}    Parse Pcap by expressionbackup
    ...    filter='ngap.PDUSessionResourceModifyListModRes == 1'
    ...    filter_expression='ngap.TransportLayerAddressIPv4 == 10.0.1.200'
    ...    input_file=${capture_file_path}


Counter Check For NG_FLOW_Setup
    [Documentation]     NG_FLOW_Setup_ATT_TOT: M55125C08501
    ...                 NG_FLOW_Setup_SUCC:M55125C08502
    [Arguments]    ${starttime}    ${endtime}    ${success_val}=${0}
    PM_counters_collector
    ${pi_list}    Create List    M55125C08501    M55125C08502
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_M55125C08501}    Sum Counter Value Of Pi Value List    ${value1}    M55125C08501
    ${sum_M55125C08502}    Sum Counter Value Of Pi Value List    ${value1}    M55125C08502
    Should be true    ${sum_M55125C08501}>${0}
    Should be true    ${sum_M55125C08502}==${success_val}

Counter Update Check For NG_FLOW_MOD
    [Documentation]     NG_FLOW_MOD_ATT_TOT: M55125C00044
    ...                 NG_FLOW_MOD_FAIL:M55125C00045
    ...                 NG_FLOW_MOD_SUCC:M55125C00047
    [Arguments]    ${starttime}    ${endtime}    ${success_val}=${0}    ${fail_val}=${0}
    PM_counters_collector
    ${pi_list}    Create List    M55125C00044    M55125C00045    M55125C00047
    ${value1}    Get_PM_counters_values_For_Period    ${starttime}    ${endtime}
    ...    ${pi_list}
    Log To Console    ${value1}
    ${sum_M55125C00044}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00044
    ${sum_M55125C00045}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00045
    ${sum_M55125C00047}    Sum Counter Value Of Pi Value List    ${value1}    M55125C00047
    ${sum_M55125C00047_45} =    Evaluate    ${sum_M55125C00045} + ${sum_M55125C00047}
    Should be true    ${sum_M55125C00045}==${fail_val}
    Should be true    ${sum_M55125C00047}==${success_val}
    Should be true    ${sum_M55125C00044}==${sum_M55125C00047_45}


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

Counter Check DL throughput
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb
    Log To Console    ${value1}

