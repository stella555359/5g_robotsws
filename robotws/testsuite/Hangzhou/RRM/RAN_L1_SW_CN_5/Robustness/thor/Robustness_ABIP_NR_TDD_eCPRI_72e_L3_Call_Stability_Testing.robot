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
&{tp_with_100M}    DLTP=700M    ULTP=130M
&{tp_with_50M}    DLTP=350M    ULTP=40M
&{tp_with_20M}    DLTP=140M    ULTP=16M
&{tp_with_diff_chbw}    100MHz=&{tp_with_100M}    50MHz=&{tp_with_50M}    20MHz=&{tp_with_20M}
&{enable_72e_dict}    actEcpri72e=Ecpri72eULDL
&{disable_72e_dict}    actEcpri72e=disabled
${cellband}    78

${scfc_file_16DL_2eCPRI_72e}    CB010630_D_ABIP_AVQL_NRTDD_50M_A1_4xNRCELL_72e_16D4U_16D2U_8D4U_4D2U_2xeCPRI.xml

${repeat_number}    10

*** Test Cases ***
Robustness_TC01_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_L3_Call_Stability_Testing
    [Tags]    QL3    Trunk    Robustness    ABIP    stability    hhh
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/Robustness/${btsid}/${scfc_file_16DL_2eCPRI_72e}

    Online change SCFC parameter    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRCELL-1    parameter=actDlSrsSubbandBm    value=true
    Wait Until Keyword Succeeds    2min    30s    Check If All Cells Are OnAir
    Online change SCFC parameter    dist_name=MRBTS-${btsid}/NRBTS-${btsid}/NRCELL-1    parameter=actDlSrsSubbandBm    value=false
    Wait Until Keyword Succeeds    2min    30s    Check If All Cells Are OnAir

    ${cell_band_dict}    Get band From NR Cells
    ${cell_chbw_dict}    Get chBw From NR Cells
    ${global_cell_id_list}    Get Dictionary Keys    ${cell_band_dict}
    ${cellid}    Set Variable    ${global_cell_id_list[0]}
    ${band}    Set Variable    ${cell_band_dict[${cellid}].strip('n')}
    ${chbw}    Set Variable    ${cell_chbw_dict[${cellid}]}
    ${dl_ul_tp_dict}    Set Variable    ${tp_with_diff_chbw['${chbw}']}
    SMAwave L3 Call For A Long Hours    ${cellid}    ${dl_ul_tp_dict['DLTP']}    ${dl_ul_tp_dict['ULTP']}    10%    5G    ${band}

*** Keywords ***
SMAwave L3 Call For A Long Hours
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${band}=78    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=7200    ${protocol}=udp    ${PMcounter_refresh_period}=5
    SMAwave UE attach    rat=${rat}    cell_id=${cell_id}    band=${band}    specific_UE_index=${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    FOR    ${round}    IN RANGE    ${repeat_number}
        Log To Console    [INFO] Verify throughput for DL and UL after ${PMcounter_refresh_period} min ...\n
        Sleep    ${PMcounter_refresh_period}min
        SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}
    END
    [Teardown]    SMAwave Stop Data And Detach
