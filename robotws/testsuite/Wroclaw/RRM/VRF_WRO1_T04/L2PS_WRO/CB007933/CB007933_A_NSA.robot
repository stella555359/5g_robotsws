*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_MP_AP_KL_SANSA_FS_CPRI_CMWV_FDD    CRT    SBTS00    SBTS22R4    SBTS23R1    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library     ta5g_pm_counters
Library     ta5g_setups_and_teardowns
Variables    ${CURDIR}/config/swconfig_flags.py

Suite Setup    Run Keywords    Update Enb And Iphy Configuration And Perform Full Commissioning
    ...                        scfc_filename=Full_CB007933_enable_ASIM_ABIP.xml
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_ahib_withoutL1bypass.xml
    ...                        swconfig_flags_list=@{swconfig_flags}
    ...        AND             Start Default Logging
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{SWCONFIG_FLAGS}=     ${WRITE_PM_COUNTERS_EVERY_MINUTE}
${PRB_AVAIL_PDSCH}=    M55308C10003
${DL_DATA_SLOTS}=      M55308C00001

*** Test Cases ***
CB007933_A1_FDD_Cell_Configuration_Setup_With_20Mhz_DL_And_10Mhz_UL_Bandwidth_For_NSA_UE_Nulling_The_Middle_PRBs_In_DL
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=50
    Sleep    100s
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=40
    Verify Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=18.5
    Verify If PRBs in the GB has been removed from the available PRBs
    Sleep   20s
    [Teardown]    Stop All Data Transfers And Detach UE NSA

*** Keywords ***
Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Sa    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} >= ${expected_tput}

Get Number Of Available PRB
       Wait For Next Full Pm Interval
       ${available_prb}=    Set Variable     ${0}
       ${PM_COUNTERS}=    Get Latest Unpacked Raw Pm Counters File
       ${VALUE_OF_PRB_AVAIL_PDSCH}=    Get Latest Pm Counter Value     counter_id=${PRB_AVAIL_PDSCH}
       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
       ${VALUE_OF_DL_DATA_SLOTS}=      Get Latest Pm Counter Value     counter_id=${DL_DATA_SLOTS}
       ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS}
        ${available_prb}=    Evaluate     ${VALUE_OF_PRB_AVAIL_PDSCH}/${VALUE_OF_DL_DATA_SLOTS}
        [Return]    ${available_prb}

Verify If PRBs in the GB has been removed from the available PRBs
    ${available_prb}    Get Number Of Available PRB
    Run Keyword And Continue On Failure    Should Be True    ${available_prb} == 98

Activate L1Bypass
   Execute Enb Command    cmd=echo "tag -3w app.btsom.nts.L1BypassMap 0x224D:0x574A" | nc 0 15007

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cells}
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Stop All Data Transfers And Detach UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11
