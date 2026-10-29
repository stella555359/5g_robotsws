*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    SBTS23R1    RAN_5G    RAN_5G_TDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      CB008985_keywords.py
Library      BuiltIn
Library      Collections


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_4AZQI_1supercell_4subcells.xml
    ...                        swconfig_flags_list=@{GNB_SW_CONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB008985_A2_1SC_4SB_1070_100M_2x2.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_A2.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{GNB_SW_CONFIG_FLAGS}=         0x340000 = 5 # PM counter interval

${LOCAL_MOID}=                  PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

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

${UE_CONTEXT_RELEASE_RLF}=         ((f1ap.procedureCode == 6))  && (f1ap.criticality == 1)

*** Test Cases ***
CB008985-A_A2_FR1_TDD_NSA_call_on_SuperCell_5GC001070
    [Setup]    Run Keywords    Prepare Test Environment Variables
    ...    AND    Setup X2 Link
    Attach NSA UE-11 to Subcell-0
    Start DL and UL Data Traffic NSA
    Verify DL and UL Tput NSA
    Check serving subcell/beam counters    serving_beam_id=0
    Change RF Conditions    ue_id=11
    [Teardown]    Stop All Data Transfers And Detach UE NSA

*** Keywords ***
Setup X2 Link
    Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
    Sleep    10s    Wait For X2 Establishment

Create Beam Testmode Profiles
    ${beam_0}=  Catenate    SEPARATOR=
    ...           beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2 ssbeam_bestbeam=0
    ...           \ ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    Execute Egate Command    cmd=${beam_0}

Create Serving Subcell Counter List
    @{SERVING_SUBCELL_COUNTERS}=    Create List
    FOR    ${ID}    IN RANGE    ${0}    ${5}
        Append To List    ${SERVING_SUBCELL_COUNTERS}    ${UL_SERV_BEAM_ID_BEAM_${ID}_PM}
        Append To List    ${SERVING_SUBCELL_COUNTERS}    ${DL_SERV_BEAM_ID_BEAM_${ID}_PM}
    END
    Set Test Variable    @{SERVING_SUBCELL_COUNTERS}

Prepare Test Environment Variables
    Create Beam Testmode Profiles
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

Start DL and UL Data Traffic NSA
    FOR    ${trf_id}    IN RANGE    ${1}    ${5}
        Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=103 trf_id=${trf_id}
    END
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=150
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=60 trf_id=2
    Sleep    30s

Change RF Conditions
    [Arguments]    ${ue_id}
    FOR    ${pathloss_value}    IN RANGE    ${60}    ${120}    ${20}
        Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${pathloss_value}
        Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=8
        Sleep    10s
    END
    Verify No RLF occured
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=deactivate profile_id=1 scell=8

Verify DL and UL Tput NSA
    Verify Tput For UE NSA    ue_id=11    cc=8    dir=dl    unit=Mbps    expected_tput=400
    Verify Tput For UE NSA    ue_id=11    cc=8    dir=ul    unit=Mbps    expected_tput=100

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${cc}    ${dir}    ${unit}    ${expected_tput}
    ${max_tput}=    Get Max Data Traffic For Given Cc    ue_id=${ue_id}    cc=${cc}    direction=${dir}    unit=${unit}
    Should Be True    ${max_tput} > ${expected_tput}

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

Stop All Data Transfers And Detach UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11

Verify No RLF occured
    Verify Tcpdump Log    packet_filter=${UE_CONTEXT_RELEASE_RLF}    number_of_messages=0
