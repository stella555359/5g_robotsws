*** Settings ***
Documentation
...    Author:  Hou Yuguo
...    Feature: Robustness
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot
Force Tags    5G_RAN_TDD    QL3    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    49
&{tp_with_100M}    DLTP=700M    ULTP=80M
&{tp_with_50M}    DLTP=350M    ULTP=40M
&{tp_with_20M}    DLTP=140M    ULTP=16M
&{tp_with_diff_chbw}    100MHz=&{tp_with_100M}    50MHz=&{tp_with_50M}    20MHz=&{tp_with_20M}

${cellband}    41

${scfc_file_3cells}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_3x16DL8UL_NR_cells.xml
${scfc_file_3cells_A1}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_3x16DL8UL_NR_cells_1208_A1.xml
${scfc_file_3cells_A3}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_3x16DL8UL_NR_cells_1070_A3.xml
${scfc_file_3cells_A8}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_3x16DL8UL_NR_cells_1116_A8.xml
${scfc_file_1cell}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_1x16DL8UL_NR_cells.xml

${repeat_number}    10

*** Test Cases ***
Robustness_ABIO_NR_TDD_eCPRI_L3_Call_Stability_Testing
    [Tags]    QL3    Trunk    Robustness    ABIO    Stability    hhh
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_1cell}
    ${cell_band_dict}    Get band From NR Cells
    ${cell_chbw_dict}    Get chBw From NR Cells
    ${global_cell_id_list}    Get Dictionary Keys    ${cell_band_dict}
    ${cellid}    Set Variable    ${global_cell_id_list[0]}
    ${band}    Set Variable    ${cell_band_dict[${cellid}].strip('n')}
    ${chbw}    Set Variable    ${cell_chbw_dict[${cellid}]}
    ${dl_ul_tp_dict}    Set Variable    ${tp_with_diff_chbw['${chbw}']}
    SMAwave L3 Call For A Long Hours    ${cellid}    ${dl_ul_tp_dict['DLTP']}    ${dl_ul_tp_dict['ULTP']}    10%    5G    ${band}

Robustness_ABIO_NR_TDD_eCPRI_BBU_Lock_Unlock
    [Tags]    QL3    Trunk    Robustness    ABIO    BBULock   hhh
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_3cells}
    FOR    ${round}    IN RANGE    ${repeat_number}
        Log To Console     \n--------------------------------------- Round-${round+1} Starting ----------------------------------------
        BBMOD operation via WebUI    Locked    ABIO
        BBMOD operation via WebUI    Unlocked    ABIO
        Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
        SMAwave L3 call    180125707    ${tp_with_20M['DLTP']}    ${tp_with_20M['ULTP']}    10%    5G    ${cellband}
        Log To Console     \n----------------------------------------- Round-${round+1} END -------------------------------------------
    END

Robustness_ABIO_NR_TDD_eCPRI_Cell_Block_Unblock
    [Tags]    ABIO    Robustness    Trunk    QL3    CellBlock    cgao
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_3cells}
    ${cell_id_dict}    Get id From NR Cells
    ${cell_chbw_dict}    Get chBw From NR Cells
    ${cell_global_cell_id_list}    Get Dictionary Keys    ${cell_id_dict}
    Set Test Variable    ${cell_global_cell_id_list}
    Set Test Variable    ${cell_chbw_dict}
    Repeat Keyword    1 hours    Ue Attach to cell and data traffic

Robustness_ABIO_NR_TDD_eCPRI_RRU_Lock_Unlock
    [Tags]    ABIO    Robustness    Trunk    QL3    rrublock    cgao
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_1cell}
    RU lock and unlock ${repeat_number} times make L3 call

Robustness_ABIO_NR_TDD_eCPRI_Full_Commission_TDD_patterns
    [Tags]    QL3    Trunk    Robustness    ABIO    TddPattern    jw
    FOR    ${round}    IN RANGE    ${repeat_number}
        Log To Console     --------------------------------------- Round-${round+1} Starting ----------------------------------------
        Full Commission TDDFrameStructure    A1
        SMAwave L3 call    180125707    ${tp_with_20M['DLTP']}    ${tp_with_20M['ULTP']}    10%    5G    ${cellband}
        Full Commission TDDFrameStructure    A3
        SMAwave L3 call    180125707    ${tp_with_20M['DLTP']}    ${tp_with_20M['ULTP']}    10%    5G    ${cellband}
        Full Commission TDDFrameStructure    A8
        SMAwave L3 call    180125707    ${tp_with_20M['DLTP']}    ${tp_with_20M['ULTP']}    10%    5G    ${cellband}
        Log To Console     ------------------------------------------ Round-${round+1} END ------------------------------------------
    END

Robustness_ABIO_NR_TDD_eCPRI_Site_Reset
    [Tags]    ABIP    SMAwave    Robustness    SiteReset    Trunk    QL3    yaqin
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_3cells}
    FOR    ${item}    IN RANGE    ${repeat_number}
        Site Reset Via WebUI
        Log To Console    \n[INFO] Round-${item+1} Site resetting ...
        Sleep    120s
        Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir
        SMAwave L3 call    180125707    ${tp_with_20M['DLTP']}    ${tp_with_20M['ULTP']}    10%    5G    41
    END

*** Keywords ***
SMAwave L3 Call For A Long Hours
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${band}=41    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=7200    ${protocol}=udp    ${PMcounter_refresh_period}=5
    SMAwave UE attach    rat=${rat}    cell_id=${cell_id}    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    FOR    ${round}    IN RANGE    ${repeat_number}
        Log To Console    [INFO] Verify throughput for DL and UL after ${PMcounter_refresh_period} min ...\n
        Sleep    ${PMcounter_refresh_period}min
        SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}
    END
    [Teardown]    SMAwave Stop Data And Detach

Ue Attach to cell and data traffic
    Perform NR Cell block ${cell_global_cell_id_list} via AdminCLI
    ${random_cell_id}    Random Choice Cell Id
    Perform NR Cell unblock ${random_cell_id} via AdminCLI
    ${chbw}    Set Variable    ${cell_chbw_dict[${random_cell_id}]}
    ${dl_ul_tp_dict}    Set Variable    ${tp_with_diff_chbw['${chbw}']}
    SMAwave L3 call    cell_id=${random_cell_id}    dl_tput=${dl_ul_tp_dict['DLTP']}    ul_tput=${dl_ul_tp_dict['ULTP']}
    ...    dl_deviation=10%    rat=5G    band=${cellband}    duration=60
    Perform NR Cell block ${random_cell_id} via AdminCLI
    Perform NR Cell unblock ${cell_global_cell_id_list} via AdminCLI
    Wait Until Keyword Succeeds     200s    20s    Check If All Cells Are OnAir

RU lock and unlock ${num} times make L3 call
    FOR    ${id}    IN RANGE    ${num}
        RU lock and unlock for gnb    ru_index=1
        SMAwave L3 call    cell_id=1    dl_tput=${tp_with_100M['DLTP']}    ul_tput=${tp_with_100M['ULTP']}
        ...    dl_deviation=10%    rat=5G    band=${cellband}    duration=60
    END

RU lock and unlock for gnb
    [Arguments]    ${ru_index}=1
    5G RMOD Operation via WebUI    locked    ${ru_index}
    5G RMOD Operation via WebUI    unlocked    ${ru_index}
    Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir

Random Choice Cell Id
    ${selected_cell}      Evaluate    random.choice(${cell_global_cell_id_list})    random
    [Return]    ${selected_cell}

Full Commission TDDFrameStructure
    [Arguments]    ${tdd_pattern}=A1
    ${scf_file}    Run Keyword If    '${tdd_pattern}'=='A1'    Set Variable    ${scfc_file_3cells_A1}
    ...    ELSE IF    '${tdd_pattern}'=='A3'    Set Variable    ${scfc_file_3cells_A3}
    ...    ELSE IF    '${tdd_pattern}'=='A8'    Set Variable    ${scfc_file_3cells_A8}
    ...    ELSE    Log To Console    [ERROR] tdd pattern should be A1 | A3 | A8.
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scf_file}
