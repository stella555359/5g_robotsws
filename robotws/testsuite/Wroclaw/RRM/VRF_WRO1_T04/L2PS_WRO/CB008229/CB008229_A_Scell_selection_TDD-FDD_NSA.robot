*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD    RAN_5G    RAN_5G_TDD    CRT    SBTS00

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh         WITH NAME    ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    ta5g_pm_counters
Resource    ./resources/CB008229_keywords.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_AEQE_AHFIB_TDD_FDD_2CC_CA.xml
...                            swconfig_flags_list=@{SWCONFIG_FLAGS}
...            AND             Start Default Logging
...            AND             Find Scfc And Fix And Send Full Commissioning
...                            scfc_filename=full_CB008229_TDD-FDD_CA.xml
...            AND             Sleep    5m
...            AND             Wait For Gnb To Reach Configured State
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_NSA_b78_66.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=                 0x340000 = 5
${SUM_UE_SCELL_CONF_LARGE_BWP}=    M55167C00003
${SUM_UE_SCELL_CONF_SMALL_BWP}=    M55167C00002
${LOCAL_MOID_PCELL}=               PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
#FDD
${rb_scs15_bw20}=                  106
${rb_scs15_bw25}=                  133
#TDD
${rb_scs30_bw60}=                  162
${rb_scs30_bw100}=                 273

${LARGE_BWP_SCELL}=                SEPARATOR=
...                                ((nr-rrc.subcarrierSpacing == 1 && nr-rrc.carrierBandwidth ==273)
...                                && (nr-rrc.subcarrierSpacing == 0 && nr-rrc.carrierBandwidth ==133))
${SMALL_BWP_SCELL}=                SEPARATOR=
...                                ((nr-rrc.subcarrierSpacing == 1 && nr-rrc.carrierBandwidth ==162)
...                                && (nr-rrc.subcarrierSpacing == 0 && nr-rrc.carrierBandwidth ==106))

*** Test Cases ***
CB008229-A_IWK2_FDD_TDD_CA_Scell_selection_NSA
    Enable PDSCH decoding in the multiplexed slots
    Wait For Next Full Pm Interval
    Attach Small BWP Capable UE And Start DL Data Traffic
    Verify BWP SCell Selection    ${SMALL_BWP_SCELL}
    Verify Scell Selection PM Counter For Small BWP
    Verify Tput For Small BWP Capable UE
    Stop All Data Transfers And Detach UE NSA    ue_id=14
    Attach Large BWP Capable UE And Start DL Data Traffic
    Verify BWP SCell Selection    ${LARGE_BWP_SCELL}
    Verify Scell Selection PM Counter For Large BWP
    Verify Tput For Large BWP Capable UE
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
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=150 trf_id=1 size=8000
    Sleep    2s
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=150 trf_id=2 size=8000
    Sleep    2s
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=150 trf_id=3 size=8000
    Sleep    60s    reason=Wait for throughput stabilization

Attach Small BWP Capable UE And Start DL Data Traffic
    Attach Ue To Enb And Start Gnb Addition    ue_id=14   target_cells=1
    Sleep    2s
    Execute Egate Command    cmd=trf_data_start id=2 ue=14 dir=dl mbps=150 trf_id=1 size=8000
    Sleep    2s
    Execute Egate Command    cmd=trf_data_start id=2 ue=14 dir=dl mbps=150 trf_id=2 size=8000
    Sleep    60s    reason=Wait for throughput stabilization

Verify BWP SCell Selection
    [Arguments]    ${packet_filter}
    Verify Ngap Messages      ${packet_filter}

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}
    Log To Console    ${avg_tput}Mbps

Verify Tput For Large BWP Capable UE
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=340

Verify Tput For Small BWP Capable UE
    Verify Tput For UE NSA    ue_id=14    id=2    dir=dl    unit=M    expected_tput=240

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
