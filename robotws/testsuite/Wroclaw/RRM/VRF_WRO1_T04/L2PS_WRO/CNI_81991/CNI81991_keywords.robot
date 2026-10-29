*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Library      taf.transport.ssh  WITH NAME  ssh
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      ta5g_pm_counters

*** Keywords ***
Commmon Test Setup
    [Arguments]    ${iphy_config_file_name}   ${scf_file_name}   ${lua_config_file_name}
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${iphy_config_file_name}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scf_file_name}
    Check Radios Availability
    Start Vm Ethernet Interfaces
    Reach Onair    lua_cfg=${lua_config_file_name}

Start Tshark With Alias
   [Arguments]    ${log_filename}   ${alias}    ${log_dirpath}
    Start Tshark
    ...    log_filename=${log_filename}
    ...    alias=${alias}
    ...    eth_interface=eth4
    ...    capture_filter=''
    ...    log_dirpath=${log_dirpath}

Verify if RRCSetup or RRCReconfiguration Contain the dedicated part of BWP
   [Arguments]    ${alias}    ${packet_filter}
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    number_of_messages=1
    ...    source_ip='10.0.2.1/24'

Verify If RRCSetup Msg Does Not Contain The Dedicated Part Of BWP-0
   [Arguments]    ${alias}    ${packet_filter}
    Verify Tshark For Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    number_of_messages=0

Verify RRC Setup Message Contains SRB1 And Mandatory Parameters
   [Arguments]    ${alias}    ${packet_filter}
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    number_of_messages=1
    ...    source_ip='10.0.2.1/24'

Verify If 1st RRC_Reconfiguration Message Includes Dedicated Part Of BWP-0
   [Arguments]    ${alias}    ${packet_filter}
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    number_of_messages=1
    ...    source_ip='10.0.2.1/24'

Verify If UE Switched To Use BWP-1 And Setup With SRB2
   [Arguments]    ${alias}    ${packet_filter}
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    number_of_messages=1
    ...    source_ip='10.0.2.1/24'

UEs Idle Mode exit
    Execute egate command   cmd=ue_im_exit id=1 by=ue service_type=emergency_services

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_S1U  ip_with_mask=10.0.1.125/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_X2   ip_with_mask=10.0.1.124/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_NG   ip_with_mask=10.0.1.123/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_XN   ip_with_mask=10.0.1.122/24
    Start Vm Ethernet Interface    if_name=eth3:AMF2       ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:mme     ip_with_mask=10.0.1.131/24
    Start Vm Ethernet Interface    if_name=eth3:ser     ip_with_mask=10.0.1.132/24
    Start Vm Ethernet Interface    if_name=eth3:sgwu    ip_with_mask=10.0.1.133/24
    Start Vm Ethernet Interface    if_name=eth3:swg1    ip_with_mask=10.0.1.134/24
    Start Vm Ethernet Interface    if_name=eth3:enbx2u  ip_with_mask=10.0.1.135/24
    Start Vm Ethernet Interface    if_name=eth3:enbs1   ip_with_mask=10.0.1.136/24
    Start Vm Ethernet Interface    if_name=eth3:enbx2   ip_with_mask=10.0.1.137/24
    Start Vm Ethernet Interface    if_name=eth3:enb4s1   ip_with_mask=10.0.1.138/24
    Start Vm Ethernet Interface    if_name=eth3:enb4x2   ip_with_mask=10.0.1.139/24

Perform command to drop RRC: Reconfiguration Complete message
    [Arguments]    ${ue_id}=1
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop

Verify PM counters And Check If M55124C01031 Not Incremented After RRC Reestab Request
    Wait For Next Full Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Raw Pm Counters File

    Verify Any Counters In File
    ...  M55124C00502  1  RRC_REESTAB_FALLBACK
    ...  M55124C00515  1  REESTAB_ACC_FALLBACK
    ...  M55124C01031  0  NRRCC_RRC_STPSUCC_TOT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

Verify PM counters And Check If M55124C01031 Is Incremented
    Wait For Next Raw Pm Interval
    Sleep    10
    ${pm_counter_file}=    Get Latest Unpacked Raw Pm Counters File

    Verify Any Counters In File
    ...  M55124C00502  0  RRC_REESTAB_FALLBACK
    ...  M55124C00515  0  REESTAB_ACC_FALLBACK
    ...  M55124C01031  1  NRRCC_RRC_STPSUCC_TOT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}

Send RRC Reestablishment Request With Invalid Short MAC-I
    Execute Egate Command   cmd=ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure action=invalid_short_mac_i
    ...    timeout=20s
