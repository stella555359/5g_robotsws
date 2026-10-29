*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_MP_AP_KL_SANSA_FS_CPRI_CMWV_FDD    CRT    SBTS00    SBTS22R4    SBTS23R1    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ./resources/CB007813_common_keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library      ../CB007262/CB007262_A/CB007262_keywords.py
#Library      CB007813_A_keywords.py


Suite Setup    Run Keywords    Add Noise To AP L1
    ...        AND             Configure VM interfaces
    ...        AND             Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/inter_iphy.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB007813_Intra_HO.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/intra_HO_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu

*** Test Cases ***
CB007813_A2_A3_Intra-gNB_HO_between_cells_with_symmetric_BW_10MHz_DL_UL_and_asymetric_BW_30MHz_DL_10MHz_UL_Multi_UE_SA
    Set Internal Traffic Type To UE
    Attach Multiple Ues And Establish PDU Sessions
    Start Data Traffic To Multiple Ues
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=9.5
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=4.5
    Perform Intra gNB HO To Symmetric Cell
    Sleep   10s
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=9.5
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=4.5
    Perform Intra gNB HO To Asymmetric Cell
    [Teardown]    Stop All Data Transfers And Detach UE SA


CB007813_A2_A3_Intra-gNB_HO_between_cells_with_symmetric_BW_10MHz_DL_UL_and_asymetric_BW_30MHz_DL_10MHz_UL_Multi_UE_NSA
    Attach Multiple UEs And Start Gnb Addition
    Sleep    20s
    Start Data Traffic
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=9.5
    Verify Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=4.8
    Perform A3 Triggered Handover To Cell 2
    Sleep   10s
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=9.5
    Verify Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=4.8
    Perform A3 Triggered Handover To Cell 1
    [Teardown]    Stop All Data Transfers And Detach UE NSA


*** Keywords ***
Configure VM interfaces
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.51/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.50/24

Stop All Data Transfers And Detach UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11
    Execute Egate Command    cmd=trf_data_stop id=2 ue=12
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=12
    Execute Egate Command    cmd=trf_data_stop id=2 ue=13
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=13

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    Execute Egate Command    cmd=trf_data_stop ue=2 pdu=2
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=2 ue_deregister_type=switch_off
    Execute Egate Command    cmd=trf_data_stop ue=3 pdu=3
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=3 ue_deregister_type=switch_off

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=3 pdu=3 trf_type=internal

Attach Multiple Ues And Establish PDU Sessions
    Attach Multiple Ues    first_ue_id=1    last_ue_id=3
    Establish Pdu Session    ue_id=1    pdu_id=1   gw_id=1
    Establish Pdu Session    ue_id=2    pdu_id=2   gw_id=2
    Establish Pdu Session    ue_id=3    pdu_id=3   gw_id=3

Start Data Traffic To Multiple Ues
    Execute Egate Command
    ...    cmd=trf_data_start ue=1 dir=dl mbps=100 pdu=1 trf_id=1
    Execute Egate Command
    ...    cmd=trf_data_start ue=2 dir=dl mbps=10 pdu=2 trf_id=1
    Execute Egate Command
    ...    cmd=trf_data_start ue=3 dir=dl mbps=10 pdu=3 trf_id=1
    Execute Egate Command
    ...    cmd=trf_data_start ue=1 dir=ul mbps=50 pdu=1 trf_id=1
    Execute Egate Command
    ...    cmd=trf_data_start ue=2 dir=ul mbps=5 pdu=2 trf_id=1
    Execute Egate Command
    ...    cmd=trf_data_start ue=3 dir=ul mbps=5 pdu=3 trf_id=1
    Sleep    20s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Perform Intra gNB HO To Symmetric Cell
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ...    timeout=20

Perform Intra gNB HO To Asymmetric Cell
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    ...    timeout=20

Attach Multiple UEs And Start Gnb Addition
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure
    ...    ue=11
    ...    target_cells=1
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg
    Attach Ue To Enb    ue_id=12
    Start Gnb Addition Procedure
    ...    ue=12
    ...    target_cells=1
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg
    Attach Ue To Enb    ue_id=13
    Start Gnb Addition Procedure
    ...    ue=13
    ...    target_cells=1
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg

Start Data Traffic
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=100
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=50
    Execute Egate Command    cmd=trf_data_start id=2 ue=12 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start id=2 ue=12 dir=ul mbps=5
    Execute Egate Command    cmd=trf_data_start id=2 ue=13 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start id=2 ue=13 dir=ul mbps=5
    Sleep    20s

Perform A3 Triggered Handover To Cell 2
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=11 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Sending SgNB Modification Confirm
    ...    timeout=20

Perform A3 Triggered Handover To Cell 1
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=11 meas_id=3 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Sending SgNB Modification Confirm
    ...    timeout=20

