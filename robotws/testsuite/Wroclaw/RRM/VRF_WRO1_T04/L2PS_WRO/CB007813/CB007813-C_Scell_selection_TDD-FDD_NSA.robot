*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CONFIGS_L2PS_WRO/CB007813/TDD_FDD_CA_NSA/CB007813-C_T-F_NSA.yaml
...    RAN_5G    RAN_5G_TDD    CRT     SBTS00    SBTS22R4    SBTS23R1

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    ta5g_pm_counters
Library    ../CB007262/CB007262_A/CB007262_keywords.py


Suite Setup    Run Keywords    Start Default Logging
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_NSA_b78_66.cfg


Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=                 0x340000 = 5
${SUM_UE_SCELL_CONF_LARGE_BWP}=    M55167C00003
${SUM_UE_SCELL_CONF_SMALL_BWP}=    M55167C00002
${LOCAL_MOID_PCELL}=               PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#FDD
${rb_scs15_bw20}=                  106
${rb_scs15_bw30}=                  160
#TDD
${rb_scs30_bw40}=                  106
${rb_scs30_bw60}=                  162

${LARGE_BWP_SCELL}=                SEPARATOR=
...                                ((nr-rrc.subcarrierSpacing == 1 && nr-rrc.carrierBandwidth ==162)
...                                && (nr-rrc.subcarrierSpacing == 0 && nr-rrc.carrierBandwidth ==160))
${SMALL_BWP_SCELL}=                SEPARATOR=
...                                ((nr-rrc.subcarrierSpacing == 1 && nr-rrc.carrierBandwidth ==106)
...                                && (nr-rrc.subcarrierSpacing == 0 && nr-rrc.carrierBandwidth ==106))

*** Test Cases ***
CB007813_C_IWK2_TDD_FDD_CA_Scell_selection_wo_inner_guardband_NSA
    Wait For Next Full Pm Interval
    Attach Small BWP Capable UE And Start DL Data Traffic
    Verify BWP SCell Selection    ${SMALL_BWP_SCELL}
    Verify Scell Selection PM Counter For Small BWP
    Stop All Data Transfers And Detach UE NSA    ue_id=14
    Attach Large BWP Capable UE And Start DL Data Traffic
    Verify BWP SCell Selection    ${LARGE_BWP_SCELL}
    Verify Scell Selection PM Counter For Large BWP
    Stop All Data Transfers And Detach UE NSA    ue_id=11

*** Keywords ***
Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cells}
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg
    ...    timeout=15

Attach Large BWP Capable UE And Start DL Data Traffic
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=170
    ...    pass_regexp=SCellIndex 9 activated successfully
    ...    timeout=130
    Sleep    10s
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=170 trf_id=2
    Sleep    10s
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=150 trf_id=3
    Sleep    60s

Attach Small BWP Capable UE And Start DL Data Traffic
    Attach Ue To Enb And Start Gnb Addition    ue_id=14   target_cells=1
    Sleep    2s
    Execute Egate Command    cmd=trf_data_start id=2 ue=14 dir=dl mbps=170 trf_id=1
    ...    pass_regexp=SCellIndex 9 activated successfully
    ...    timeout=130
    Sleep    60s

Verify BWP SCell Selection
    [Arguments]    ${packet_filter}
    Verify Ngap Messages      ${packet_filter}

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Verify Tput For Large BWP Capable UE
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=300

Verify Tput For Small BWP Capable UE
    Verify Tput For UE NSA    ue_id=14    id=2    dir=dl    unit=M    expected_tput=130

Verify Scell Selection PM Counter For Large BWP
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${SUM_UE_SCELL_CONF_LARGE_BWP}
    ...    value=60
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    filepath=${PM_COUNTERS_FILE}

Verify Scell Selection PM Counter For Small BWP
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File
    Verify If Latest Pm Counter Has Exact Value
    ...    counter_id=${SUM_UE_SCELL_CONF_SMALL_BWP}
    ...    value=60
    ...    local_moid=${LOCAL_MOID_PCELL}
    ...    filepath=${PM_COUNTERS_FILE}

Stop All Data Transfers And Detach UE NSA
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=trf_data_stop id=2 ue=${ue_id}
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=${ue_id}
