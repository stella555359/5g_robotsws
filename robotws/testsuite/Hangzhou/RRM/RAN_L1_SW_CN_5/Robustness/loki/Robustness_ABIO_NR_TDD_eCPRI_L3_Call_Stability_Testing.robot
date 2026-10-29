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
@{ALLOWED_FAULT}
&{tp_with_100M}    DLTP=550M    ULTP=80M
&{tp_with_50M}    DLTP=350M    ULTP=40M
&{tp_with_20M}    DLTP=140M    ULTP=16M
&{tp_with_diff_chbw}    100MHz=&{tp_with_100M}    50MHz=&{tp_with_50M}    20MHz=&{tp_with_20M}

${cellband}    41

${scfc_file_1cell}      scf_BTS10420_ABIO_AEHC_TDD_eCPRI_1x16DL8UL_NR_cells.xml

${repeat_number}    10

${ue_index}    UE_1

*** Test Cases ***
Robustness_TC08_NR_FR1_TDD_eCPRI_ABIO_L3_Call_Stability_Testing
    [Tags]    QL3    Trunk    Robustness    ABIO    Stability    hhh
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Robustness${/}${scfc_file_1cell}
    ${cell_band_dict}    Get band From NR Cells
    ${cell_chbw_dict}    Get chBw From NR Cells
    ${global_cell_id_list}    Get Dictionary Keys    ${cell_band_dict}
    ${cellid}    Set Variable    ${global_cell_id_list[0]}
    ${band}    Set Variable    ${cell_band_dict[${cellid}].strip('n')}
    ${chbw}    Set Variable    ${cell_chbw_dict[${cellid}]}
    ${dl_ul_tp_dict}    Set Variable    ${tp_with_diff_chbw['${chbw}']}
    SMAwave L3 Call For A Long Hours    ${cellid}    ${dl_ul_tp_dict['DLTP']}    ${dl_ul_tp_dict['ULTP']}    10%    5G    ${band}    ${ue_index}


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
