*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CIT    SBTS00    SBTS23R1    RAN_5G    RAN_5G_TDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      CB008985_keywords.py
Library      BuiltIn
Library      Collections
Library      ta_pcmd
Library      ta_pcmd.tshark_plugin_configurator


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_4AZQI_1supercell_4subcells.xml
    ...                        swconfig_flags_list=@{SW_CONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB008985_A6_4subcells_PCMD_for_SANSA_1208_100M.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_A2.cfg

Suite Teardown     Run Keywords    Print Active Alarms
    ...        AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SW_CONFIG_FLAGS}=             0x340000 = 5 # PM counter interval

${LOCAL_MOID}=                  PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

#switch to subcell-0
${BEAM_CHANGE_0_0_PM}=            M55305C03001
${BEAM_CHANGE_1_0_PM}=            M55305C03002
${BEAM_CHANGE_2_0_PM}=            M55305C03003
${BEAM_CHANGE_3_0_PM}=            M55305C03004

#switch to subcell-1
${BEAM_CHANGE_0_1_PM}=            M55305C03009
${BEAM_CHANGE_1_1_PM}=            M55305C03010
${BEAM_CHANGE_2_1_PM}=            M55305C03011
${BEAM_CHANGE_3_1_PM}=            M55305C03012

#switch to subcell-2
${BEAM_CHANGE_0_2_PM}=            M55305C03017
${BEAM_CHANGE_1_2_PM}=            M55305C03018
${BEAM_CHANGE_2_2_PM}=            M55305C03019
${BEAM_CHANGE_3_2_PM}=            M55305C03020

#switch to subcell-3
${BEAM_CHANGE_0_3_PM}=            M55305C03025
${BEAM_CHANGE_1_3_PM}=            M55305C03026
${BEAM_CHANGE_2_3_PM}=            M55305C03027
${BEAM_CHANGE_3_3_PM}=            M55305C03028

#serving subcell counters
${DL_SERV_BEAM_ID_BEAM_0_PM}=   M55305C00001
${UL_SERV_BEAM_ID_BEAM_0_PM}=   M55305C01001

${DL_SERV_BEAM_ID_BEAM_1_PM}=   M55305C00002
${DL_SERV_BEAM_ID_BEAM_2_PM}=   M55305C00003
${DL_SERV_BEAM_ID_BEAM_3_PM}=   M55305C00004
${DL_SERV_BEAM_ID_BEAM_4_PM}=   M55305C00005

${UL_SERV_BEAM_ID_BEAM_1_PM}=   M55305C01002
${UL_SERV_BEAM_ID_BEAM_2_PM}=   M55305C01003
${UL_SERV_BEAM_ID_BEAM_3_PM}=   M55305C01004
${UL_SERV_BEAM_ID_BEAM_4_PM}=   M55305C01005

#tshark & pcmd
${UE_CONTEXT_RELEASE_RLF}=         ((f1ap.procedureCode == 6))  && (f1ap.criticality == 1)
${TOTAL_BEAM_CHANGES_1}=            nsetapx.numOfTotalBeamChanges == 1
${FAILED_BEAM_CHANGES_0}=           nsetapx.numOfFailedBeamChanges == 0

*** Test Cases ***
CB008985-A_A6_FR1_TDD_call_continuity_during_subcell_switch_with_PCMD_SA
    [Tags]    AP_REG
    [Setup]    Run Keywords    Prepare Test Environment Variables
    ...    AND    Start Tcp Pcap
    ...    AND    Start PCMD
    Attach SA UE-1 to Subcell-3
    Start DL and UL Data Traffic SA
    Verify DL and UL Tput SA    ue_id=1
    Wait For Next Full Pm Interval
    Perform Subcell Switch    ue_id=1    serving_sub=3    target_sub=1
    Verify DL and UL Tput SA After Subcell Switch    ue_id=1
    Check subcell switch counters
    Check PCMD Trace    packet_filter=${TOTAL_BEAM_CHANGES_1} && ${FAILED_BEAM_CHANGES_0}
    Check serving subcell/beam counters    serving_beam_id=1
    Verify No RLF occured
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE SA    ue_id=1
    ...    AND    Stop Tcp Pcap
    ...    AND    Stop And Teardown PCMD

*** Keywords ***
########################PCMD
Start PCMD
    Configure PCMD    technology=5G    asn1per_decoding=${True}
    Start collecting PCMD reports

Start Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}/tshark
    ...    alias=tcp_pcap

Stop Tcp Pcap
    [Arguments]    ${alias}=tcp_pcap
    Stop tshark    alias=${alias}

Stop And Teardown PCMD
    Stop collecting PCMD reports
    Deconfigure PCMD

Configure PCMD in Wireshark
#    Add Nestapx Prototcol Plugin To Tshark
    Add Preferences To Wireshark Config
    Start Server Interface

Add Nestapx Prototcol Plugin To Tshark
    Load Tshark Bin Plugin    technology=5G

Add Preferences To Wireshark Config
    ${preferences_exist}    Check If Preferences Exist
    ${command}=  catenate  SEPARATOR=
    ...    echo "ntrstr.port: 49151,49392" >> ~/.config/wireshark/preferences  &&
    ...    echo "ntrstr.defragment: TRUE" >> ~/.config/wireshark/preferences
    Run Keyword If    ${preferences_exist}==False
    ...    Run    ${command}
    ...    ELSE    Log    File '~/.config/wireshark/preferences' contains the required flags for PCMD

Check If Preferences Exist
    ${preferences_file}    Set Variable    ~/.config/wireshark/preferences
    ${file_exist}=    Run Keyword And Return Status
        ...    File Should Exist    ${preferences_file}
    Run Keyword If   ${file_exist}==False    Create File    ${preferences_file}
    ${file_content}=  OperatingSystem.Get File   ${preferences_file}
    ${preferences_exist}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${file_content}    ntrstr.port: 49151,49392
    [Return]    ${preferences_exist}

Start Server Interface
    [Documentation]    Starts interface between gNB and Trace Control Entity
    Start Vm Ethernet Interface    if_name=eth3:SERVER    ip_with_mask=10.0.1.1/24

Check PCMD Trace
    [Arguments]    ${packet_filter}    ${number_of_messages}=1    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=tcp_pcap   ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Create Subcell Switch Counter List
    @{SUBCELL_SWITCH_COUNTERS}=    Create List
    FOR    ${ID}    IN RANGE    ${0}    ${4}
        Append To List    ${SUBCELL_SWITCH_COUNTERS}    ${BEAM_CHANGE_${ID}_0_PM}
        Append To List    ${SUBCELL_SWITCH_COUNTERS}    ${BEAM_CHANGE_${ID}_1_PM}
        Append To List    ${SUBCELL_SWITCH_COUNTERS}    ${BEAM_CHANGE_${ID}_2_PM}
        Append To List    ${SUBCELL_SWITCH_COUNTERS}    ${BEAM_CHANGE_${ID}_3_PM}
    END
    Set Test Variable    @{SUBCELL_SWITCH_COUNTERS}

Create Serving Subcell Counter List
    @{SERVING_SUBCELL_COUNTERS}=    Create List
    FOR    ${ID}    IN RANGE    ${0}    ${5}
        Append To List    ${SERVING_SUBCELL_COUNTERS}    ${UL_SERV_BEAM_ID_BEAM_${ID}_PM}
        Append To List    ${SERVING_SUBCELL_COUNTERS}    ${DL_SERV_BEAM_ID_BEAM_${ID}_PM}
    END
    Set Test Variable    @{SERVING_SUBCELL_COUNTERS}

Create Beam Testmode Profiles
    Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3 ssbeam_bestbeam=0 ssbeam_rsrp_best=-48 ssbeam_rsrp_avg=-80
    Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3 ssbeam_bestbeam=1 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-90
    Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3 ssbeam_bestbeam=2 ssbeam_rsrp_best=-46 ssbeam_rsrp_avg=-90
    Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2 ssbeam_bestbeam=3 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-90

Prepare Test Environment Variables
    Create Beam Testmode Profiles
    Create Subcell Switch Counter List
    Create Serving Subcell Counter List

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Attach SA UE-${ue_id} to Subcell-${subcell_id}
    Set Internal Traffic Type To UE
    Activate Beam Control Testmode    ue_id=${ue_id}    profile_id=${${subcell_id}+${1}}    beam_action=attach
    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=1    gw_id=1

Activate Beam Control Testmode
    [Arguments]    ${ue_id}    ${profile_id}    ${beam_action}
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${profile_id} beamaction=${beam_action}

Start DL and UL Data Traffic SA
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=100 trf_id=1
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=40
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Increase Traffic
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=2
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:2
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175 trf_id=3
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:3
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=50 trf_id=4
    ...    pass_regexp=UE1: Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:4
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=90 trf_id=2
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:2
    Sleep    10s

Verify DL and UL Tput SA
    [Arguments]    ${ue_id}
    Verify Tput For UE    ue_id=${ue_id}    dir=dl    expected_tput=90
    Verify Tput For UE    ue_id=${ue_id}    dir=ul    expected_tput=40

Verify DL and UL Tput SA After Subcell Switch
    [Arguments]    ${ue_id}
    Increase Traffic
    Verify Tput For UE    ue_id=${ue_id}    dir=dl    expected_tput=490
    Verify Tput For UE    ue_id=${ue_id}    dir=ul    expected_tput=125

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${max_tput}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${max_tput} > ${expected_tput}

Perform Subcell Switch
    [Arguments]    ${ue_id}    ${serving_sub}    ${target_sub}
    ${switch_regexp}=  Catenate    SEPARATOR=
    ...           UeId:${${ue_id}-${1}},Serving CellId:0,PhyCellId:50] Switching Beam via MAC CE for pdcch.
    ...           \ Old Beam: ${serving_sub} New Beam: ${target_sub}
    Execute Egate Command
    ...   cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${${target_sub}+${1}} beamaction=switch scell=0
    ...   pass_regexp=${switch_regexp}
    Sleep    5s

Check subcell switch counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${BEAM_CHANGE_3_1_PM}
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Remove Values From List   ${SUBCELL_SWITCH_COUNTERS}    ${BEAM_CHANGE_3_1_PM}

    Verify If Latest Pm Counters In Counter Id List Have Exact Value
    ...    counter_id_list=@{SUBCELL_SWITCH_COUNTERS}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

Check serving subcell/beam counters
    [Arguments]    ${serving_beam_id}
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${DL_SERV_BEAM_ID_BEAM_${serving_beam_id}_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${UL_SERV_BEAM_ID_BEAM_${serving_beam_id}_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Remove Values From List   ${SERVING_SUBCELL_COUNTERS}    ${UL_SERV_BEAM_ID_BEAM_${serving_beam_id}_PM}
    ...    ${DL_SERV_BEAM_ID_BEAM_${serving_beam_id}_PM}

    Verify If Latest Pm Counters In Counter Id List Have Exact Value
    ...    counter_id_list=@{SERVING_SUBCELL_COUNTERS}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

Verify No RLF occured
    Verify Tcpdump Log    packet_filter=${UE_CONTEXT_RELEASE_RLF}    number_of_messages=0

Stop All Data Transfers And Detach UE SA
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off



