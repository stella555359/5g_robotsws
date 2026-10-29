*** Settings ***
Documentation
...    copyright: Nokia

Force Tags     CLOUD_5G_I_MP_AP_LO      VARIANT_SANSA_FS_ECPRI_CMWV_TDD      CRT    RAN_5G    RAN_5G_TDD    CDRT

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      CB008985_keywords.py
Library      BuiltIn
Library      Collections
Library      ta_pcmd
Library      ta_pcmd.tshark_plugin_configurator
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_3AZQI_1supercell_3subcells.xml
    ...                        swconfig_flags_list=@{SW_CONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB008985_A6_3subcells_PCMD_for_SANSA_1116_100M.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_A2.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${port_trace}                         49151
${ip_trace}                           10.0.1.10

@{SW_CONFIG_FLAGS}=             0x340000 = 5 # PM counter interval

@{UE_ID_LIST}=                  11
...                             12

${LOCAL_MOID}=                  PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

#switch to subcell-0
${BEAM_CHANGE_0_0_PM}=            M55305C03001
${BEAM_CHANGE_1_0_PM}=            M55305C03002
${BEAM_CHANGE_2_0_PM}=            M55305C03003

#switch to subcell-1
${BEAM_CHANGE_0_1_PM}=            M55305C03009
${BEAM_CHANGE_1_1_PM}=            M55305C03010
${BEAM_CHANGE_2_1_PM}=            M55305C03011

#switch to subcell-2
${BEAM_CHANGE_0_2_PM}=            M55305C03017
${BEAM_CHANGE_1_2_PM}=            M55305C03018
${BEAM_CHANGE_2_2_PM}=            M55305C03019

#serving subcell counters
${DL_SERV_BEAM_ID_BEAM_0_PM}=   M55305C00001
${UL_SERV_BEAM_ID_BEAM_0_PM}=   M55305C01001

${DL_SERV_BEAM_ID_BEAM_1_PM}=   M55305C00002
${DL_SERV_BEAM_ID_BEAM_2_PM}=   M55305C00003
${DL_SERV_BEAM_ID_BEAM_3_PM}=   M55305C00004

${UL_SERV_BEAM_ID_BEAM_1_PM}=   M55305C01002
${UL_SERV_BEAM_ID_BEAM_2_PM}=   M55305C01003
${UL_SERV_BEAM_ID_BEAM_3_PM}=   M55305C01004

#tshark & pcmd
${UE_CONTEXT_RELEASE_RLF}=          ((f1ap.procedureCode == 6))  && (f1ap.criticality == 1)
${TOTAL_BEAM_CHANGES_1}=            nsetapx.numOfTotalBeamChanges == 1
${FAILED_BEAM_CHANGES_0}=           nsetapx.numOfFailedBeamChanges == 0

*** Test Cases ***
CB008985-A_A6_FR1_TDD_call_continuity_during_subcell_switch_with_PCMD_NSA
    [Setup]    Run Keywords    Prepare Test Environment Variables
    ...    AND    Start Netcat for tracing
    ...    AND    Setup X2 Link
    ...    AND    Start First Tcp Pcap
    Attach NSA UE-11 to Subcell-0
    Attach NSA UE-12 to Subcell-2
    Start DL and UL Data Traffic NSA For Multiple UEs
    Verify DL and UL Tput NSA For Multiple UEs
    Wait For Next Full Pm Interval
    Perform Subcell Switch    ue_id=11    serving_sub=0    target_sub=1
    Perform Subcell Switch    ue_id=12    serving_sub=2    target_sub=0
    Check subcell switch counters
    Check PCMD Trace    packet_filter=${TOTAL_BEAM_CHANGES_1} && ${FAILED_BEAM_CHANGES_0}    number_of_messages=2
    Verify DL and UL Tput NSA For Multiple UEs After Subcell Switch
    Check serving subcell/beam counters
    Verify No RLF occured
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UEs NSA
    ...    AND    Stop Netact for tracing
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
########################PCMD
Start First Tcp Pcap
    Start tshark
    ...    log_filename=eth3_tcp.pcap
    ...    eth_interface=eth3
    ...    capture_filter='tcp'
    ...    log_dirpath=${OUTPUT_DIR}
    ...    alias=tcp_pcap

Start Netcat for tracing
    Log to console    Netcat started
    Run     sudo pkill -9 -f 'nc -l ${port_trace} -k'
    ${NC_PROC}=    Start Process  nc  -l  ${port_trace}  -k  stdout=/dev/null  stderr=/dev/null
    Sleep    5
    Run    ps -ef | grep nc
    Set Test Variable    ${NC_PROC}

Stop Netact for tracing
    Log to console    Netcat stopped
    Terminate Process  ${NC_PROC}

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
    [Arguments]    ${packet_filter}    ${number_of_messages}    ${pcap_file_path}=${None}    ${timeout}=10    ${relation_symbol}= ==
    ...            ${alias}=tcp_pcap   ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Create Subcell Switch Counter List
    @{SUBCELL_SWITCH_COUNTERS}=    Create List
    FOR    ${ID}    IN RANGE    ${0}    ${3}
        Append To List    ${SUBCELL_SWITCH_COUNTERS}    ${BEAM_CHANGE_${ID}_0_PM}
        Append To List    ${SUBCELL_SWITCH_COUNTERS}    ${BEAM_CHANGE_${ID}_1_PM}
        Append To List    ${SUBCELL_SWITCH_COUNTERS}    ${BEAM_CHANGE_${ID}_2_PM}
    END
    Set Test Variable    @{SUBCELL_SWITCH_COUNTERS}

Create Serving Subcell Counter List
    @{SERVING_SUBCELL_COUNTERS}=    Create List
    FOR    ${ID}    IN RANGE    ${0}    ${4}
        Append To List    ${SERVING_SUBCELL_COUNTERS}    ${UL_SERV_BEAM_ID_BEAM_${ID}_PM}
        Append To List    ${SERVING_SUBCELL_COUNTERS}    ${DL_SERV_BEAM_ID_BEAM_${ID}_PM}
    END
    Set Test Variable    @{SERVING_SUBCELL_COUNTERS}

Create Beam Testmode Profiles
    Execute Egate Command
    ...   cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2 ssbeam_bestbeam=0 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-90
    Execute Egate Command
    ...   cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2 ssbeam_bestbeam=1 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-90
    Execute Egate Command
    ...   cmd=beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1 ssbeam_bestbeam=2 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-90
    Execute Egate Command
    ...   cmd=beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=0,1,2 ssbeam_bestbeam=0 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-90


Prepare Test Environment Variables
    Create Beam Testmode Profiles
    Create Subcell Switch Counter List
    Create Serving Subcell Counter List

Attach NSA UE-${ue_id} to Subcell-${subcell_id}
    Activate Beam Control Testmode    ue_id=${ue_id}    profile_id=${${subcell_id}+${1}}    beam_action=attach
    Attach Ue To Enb And Start Gnb Addition    ue_id=${ue_id}    target_cells=1

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cells}
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg

Activate Beam Control Testmode
    [Arguments]    ${ue_id}    ${profile_id}    ${beam_action}
    Execute Egate Command
    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${profile_id} beamaction=${beam_action}

Start DL and UL Data Traffic NSA For Multiple UEs
    FOR    ${ue_id}    IN    @{UE_ID_LIST}
        Execute Egate Command    cmd=trf_data_start id=2 ue=${ue_id} dir=dl mbps=50
        Execute Egate Command    cmd=trf_data_start id=2 ue=${ue_id} dir=ul mbps=30
        Sleep    5s
    END
    Sleep    35s

Perform Subcell Switch
    [Arguments]    ${ue_id}    ${serving_sub}    ${target_sub}
    ${switch_regexp}=  Catenate    SEPARATOR=
    ...           UeId:${${ue_id}-${1}},Serving CellId:8,PhyCellId:50] Switching Beam via MAC CE for pdcch.
    ...           \ Old Beam: ${serving_sub} New Beam: ${target_sub}
    Execute Egate Command And Wait For Data
    ...   cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${${target_sub}+${1}} beamaction=switch scell=8
    ...   pass_regexp=${switch_regexp}
    ...   timeout=40
    Sleep    5s

Verify DL and UL Tput NSA For Multiple UEs
    FOR    ${ue_id}    IN    @{UE_ID_LIST}
        Verify Tput For UE NSA    ue_id=${ue_id}    cc=8    dir=dl    unit=Mbps    expected_tput=40
        Verify Tput For UE NSA    ue_id=${ue_id}    cc=8    dir=ul    unit=Mbps    expected_tput=20
    END

Increase Traffic
    FOR    ${ue_id}    IN    @{UE_ID_LIST}
        Execute Egate Command    cmd=trf_data_start id=2 ue=${ue_id} dir=dl mbps=50 trf_id=2
        Execute Egate Command    cmd=trf_data_start id=2 ue=${ue_id} dir=ul mbps=20 trf_id=2
        Sleep    5s
    END

Verify DL and UL Tput NSA For Multiple UEs After Subcell Switch
    Increase Traffic
    FOR    ${ue_id}    IN    @{UE_ID_LIST}
        Verify Tput For UE NSA    ue_id=${ue_id}    cc=8    dir=dl    unit=Mbps    expected_tput=100
        Verify Tput For UE NSA    ue_id=${ue_id}    cc=8    dir=ul    unit=Mbps    expected_tput=20
    END

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${cc}    ${dir}    ${unit}    ${expected_tput}
    ${max_tput}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}    cc=${cc}    direction=${dir}    unit=${unit}
    Should Be True    ${max_tput} > ${expected_tput}

Verify No RLF occured
    Verify Tcpdump Log    packet_filter=${UE_CONTEXT_RELEASE_RLF}    number_of_messages=0

Check subcell switch counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${BEAM_CHANGE_0_1_PM}
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${BEAM_CHANGE_2_0_PM}
    ...    value=1
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Remove Values From List   ${SUBCELL_SWITCH_COUNTERS}    ${BEAM_CHANGE_0_1_PM}    ${BEAM_CHANGE_2_0_PM}

    Verify If Latest Pm Counters In Counter Id List Have Exact Value
    ...    counter_id_list=@{SUBCELL_SWITCH_COUNTERS}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

Check serving subcell/beam counters
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${DL_SERV_BEAM_ID_BEAM_0_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${UL_SERV_BEAM_ID_BEAM_0_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${DL_SERV_BEAM_ID_BEAM_1_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Verify If Latest Pm Counter Is Bigger Than The Given Value
    ...    counter_id=${UL_SERV_BEAM_ID_BEAM_1_PM}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

    Remove Values From List   ${SERVING_SUBCELL_COUNTERS}    ${UL_SERV_BEAM_ID_BEAM_0_PM}
    ...    ${DL_SERV_BEAM_ID_BEAM_0_PM}    ${DL_SERV_BEAM_ID_BEAM_1_PM}    ${UL_SERV_BEAM_ID_BEAM_1_PM}

    Verify If Latest Pm Counters In Counter Id List Have Exact Value
    ...    counter_id_list=@{SERVING_SUBCELL_COUNTERS}
    ...    value=0
    ...    local_moid=${LOCAL_MOID}
    ...    filepath=${PM_COUNTERS_FILE}

Stop All Data Transfers And Detach UEs NSA
    FOR    ${ue_id}    IN RANGE    ${11}    ${13}
        Execute Egate Command    cmd=trf_data_stop id=2 ue=${ue_id}
        Sleep    5s
        Execute Egate Command    cmd=ue_detach id=${ue_id}
    END



