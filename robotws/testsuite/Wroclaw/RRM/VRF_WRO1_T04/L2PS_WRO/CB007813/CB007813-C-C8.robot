*** Settings ***
Force Tags    CLOUD_5G_I_BO_AP_KLLL_SANSA_FS_CPRI_CMWV_FDD    RAN_5G    RAN_5G_FDD    CRT     SBTS00    SBTS22R4    SBTS23R1

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     CB007813-C_keywords.robot
Resource     connect.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    CB007813-B_keywords.py
Library    ../CB007262/CB007262_A/CB007262_keywords.py
Library     vendor_file_modifier.py
Library    Collections

Documentation
...    author: Kamil Galczynski
...    release: 22R4

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AHFIB_7813_C_PRB_pooling_1.xml
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB007813_C_PRB_pooling_30_10_20_10_wo_inner_gb.xml
    ...        AND             Check Radios Availability
    ...        AND             Download and Modify Vendor File and perform commissioning
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_7813_c_PRB_pooling_1.cfg


Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu

*** Test Cases ***
CB007813_C_IWK6_Active_30_10MHz_and 20_10Mhz_n66_channel_wo_inner_GB_on_cells_from_same_active_PRB_pool
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL And In UL   ue_id=1    pdu=1   tput_dl=50   tput_ul=10
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=9.5
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=30
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=2
    Start Data Traffic In DL And In UL   ue_id=2    pdu=2   tput_dl=50   tput_ul=10
    Verify Tput For UE    ue_id=2   dir=ul    expected_tput=9.5
    Verify Tput For UE    ue_id=2   dir=dl    expected_tput=30
    Attach Ue    ue_id=3
    Establish Pdu Session    ue_id=3    pdu_id=3    gw_id=2
    Start Data Traffic In DL And In UL   ue_id=3    pdu=3   tput_dl=2   tput_ul=2
    Verify Tput For UE    ue_id=3   dir=ul    expected_tput=1.5
    Verify Tput For UE    ue_id=3   dir=dl    expected_tput=1.5
    [Teardown]    Stop All Data Transfers And Detach UE SA

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=3 pdu=3 trf_type=internal

Start Data Traffic In DL And In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}    ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=1
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu} Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:${ue_id} UpfId:1 Pdu:${pdu} Qfi:1 TrfId:1
    Sleep    30s

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
