*** Settings ***
Documentation
...    Author:  Hou Yuguo
...    Feature: Robustness

Suite Setup       Run Keywords    common_resource_suite.Common Suite Setup
...    AND    Configure TL With Vendor Update    ${enable_72e_dict}
...    ${SCFC_path}/Robustness/${btsid}/${scfc_file_16DL_2eCPRI_72e}    ${btsid}
Suite Teardown    common_resource_suite.Common Suite Teardown

Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot
Force Tags    5G_RAN_TDD    QL3    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    49
&{tp_with_100M}    DLTP=700M    ULTP=130M
&{tp_with_50M}    DLTP=350M    ULTP=40M
&{tp_with_20M}    DLTP=140M    ULTP=16M
&{tp_with_diff_chbw}    100MHz=&{tp_with_100M}    50MHz=&{tp_with_50M}    20MHz=&{tp_with_20M}
&{enable_72e_dict}    actEcpri72e=Ecpri72eUL
&{disable_72e_dict}    actEcpri72e=disabled
${cellband}    78

${scfc_file_16DL_2eCPRI_72e}    CB010630_D_ABIP_AVQL_NRTDD_50M_A1_4xNRCELL_72e_16D4U_16D2U_8D4U_4D2U_2xeCPRI.xml

${repeat_number}    10

*** Test Cases ***
Robustness_TC01_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_L3_Call_Stability_Testing
    [Tags]    QL3    Trunk    Robustness    ABIP    stability    hhh
    ${cell_band_dict}    Get band From NR Cells
    ${cell_chbw_dict}    Get chBw From NR Cells
    ${global_cell_id_list}    Get Dictionary Keys    ${cell_band_dict}
    ${cellid}    Set Variable    ${global_cell_id_list[0]}
    ${band}    Set Variable    ${cell_band_dict[${cellid}].strip('n')}
    ${chbw}    Set Variable    ${cell_chbw_dict[${cellid}]}
    ${dl_ul_tp_dict}    Set Variable    ${tp_with_diff_chbw['${chbw}']}
    SMAwave L3 Call For A Long Hours    ${cellid}    ${dl_ul_tp_dict['DLTP']}    ${dl_ul_tp_dict['ULTP']}    10%    5G    ${band}

Robustness_TC02_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_BBU_Lock_Unlock
    [Tags]    QL3    Trunk    Robustness    ABIP    BBULock   hhh
    FOR    ${round}    IN RANGE    ${repeat_number}
        Log To Console     \n--------------------------------------- Round-${round+1} ----------------------------------------
        BBMOD operation via WebUI    Locked    ABIP
        BBMOD operation via WebUI    Unlocked    ABIP
        Wait Until Keyword Succeeds     300s    30s    Check If All Cells Are OnAir
        SMAwave L3 call    cell_id=11    dl_tput=${tp_with_100M['DLTP']}    ul_tput=${tp_with_100M['ULTP']}    dl_deviation=10%
        ...    rat=5G    band=${cellband}
    END

Robustness_TC04_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_Cell_Block_Unblock
    [Tags]    ABIP    Robustness    Trunk    QL3    CellBlock    cgao
    ${cell_id_dict}    Get id From NR Cells
    ${cell_chbw_dict}    Get chBw From NR Cells
    ${cell_global_cell_id_list}    Get Dictionary Keys    ${cell_id_dict}
    Set Test Variable    ${cell_global_cell_id_list}
    Set Test Variable    ${cell_chbw_dict}
    Repeat Keyword    0.5 hours    Ue Attach to cell and data traffic

Robustness_TC03_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_RRU_Lock_Unlock
    [Tags]    ABIP    Robustness    Trunk    QL3    rrublock    cgao
    RU lock and unlock ${repeat_number} times make L3 call


Robustness_TC06_NR_FR1_TDD_eCPRI_ABIP_AVQL_72e_Site_Reset
    [Tags]    ABIP    SMAwave    Robustness    SiteReset    Trunk    QL3    yaqin
    FOR    ${item}    IN RANGE    ${repeat_number}
        Site Reset Via WebUI
        Log To Console    \n[INFO] Round-${item+1} Site resetting ...
        Sleep    120s
        Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir
        SMAwave L3 call    cell_id=11    dl_tput=140M    ul_tput=16M    dl_deviation=10%    rat=5G    band=${cellband}
    END

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
        SMAwave L3 call    cell_id=11    dl_tput=800M    ul_tput=150M
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
