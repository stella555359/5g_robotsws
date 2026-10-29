*** Settings ***
Documentation
...    Author:  Yanqing.li
...    Contact: yanqing.li@nokia-sbell.com
...    Feature: CB008985
...    Release: 23R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}
${scfc_file_TC35_36}    TC35_TC36_ASOE_3AZHL_TDD_eCPRI_1NRSuperCELLx6subcells_4T4R_SA.xml
${isCommission}    True

*** Test Cases ***
TC35_CB008985_A_US05_TDD_FR1_SA_call_on_supercell_Cell_Block_Unblock_ecpri_ASOE_branch
    [Tags]    ASOE    SMAwave    CPE    CB008985    TC35    Branch    QC_538345
    Run Keyword If    ${isCommission}    Full Commission for supercell
    L3 call with block unblock cell

TC36_CB008985_A_US05_TDD_FR1_SA_call_on_supercell_IQ_capture_ecpri_ASOE_branch
    [Tags]    ASOE    SMAwave    CPE    CB008985    TC36    Branch    QC_538344
    Run Keyword If    ${isCommission}    Full Commission for supercell
    L3 call with IQ capture

TC35_CB008985_A_US05_TDD_FR1_SA_call_on_supercell_Cell_Block_Unblock_ecpri_ASOE_trunk
    [Tags]    ASOE    SMAwave    CPE    CB008985    TC35     trunk    QC_372530
    Run Keyword If    ${isCommission}    Full Commission for supercell
    L3 call with block unblock cell

TC36_CB008985_A_US05_TDD_FR1_SA_call_on_supercell_IQ_capture_ecpri_ASOE_trunk
    [Tags]    ASOE    SMAwave    CPE    CB008985    TC36     trunk    QC_372531
    Run Keyword If    ${isCommission}    Full Commission for supercell
    L3 call with IQ capture

*** Keywords ***
SMAwave supercell L3 call
    [Arguments]    ${cell_id}    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}    ${band}=41    ${specific_UE_index}=${EMPTY}
    ...    ${duration}=600    ${protocol}=udp
    SMAwave UE attach    ${rat}    ${cell_id}    ${band}    ${specific_UE_index}
    SMAwave Start Data Traffic    ${dl_tput}    ${ul_tput}    ${protocol}    ${duration}
    SMAwave Verify throughput for DL and UL    ${dl_tput}    ${ul_tput}    ${dl_deviation}    ${rat}

Full Commission for supercell
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008985${/}${scfc_file_TC35_36}
    Set Suite Variable    ${isCommission}    False

L3 call with IQ capture
    ${scf_file}    Get Current Scfc
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-11    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='6 beams'
    Adjust HBTE attenuation values    10.108.241.29    1:127; 2:127; 5:127; 6:127; 3:127; 4:127; 7:127; 8:127
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:20; 12:20; 15:20; 16:20
    SMAwave supercell L3 call    11    210M    20M    10%    5G    41
    ${ul_subcell_index_list}=    Create List    [SMOD_R-1(ASOE)] [PCI: 11]${72a_flag}NRCELL-11: Subcell 0
    ${dl_subcell_index_list}=    Create List    [SMOD_R-1(ASOE)] [PCI: 11]${72a_flag}NRCELL-11: Subcell 0

    Configure IQ capture via webUI    ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${dl_subcell_index_list}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Blind    capture_from=BBU
    ...    profile_prefix=${None}    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${None}
    sleep    60s
    Save IQ capture data via webUI
    [Teardown]    SMAwave Stop Data And Detach

L3 call with block unblock cell
    ${scf_file}    Get Current Scfc
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-11    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='6 beams'
    Perform NR Cell block 11 via AdminCLI
    Perform NR Cell unblock 11 via AdminCLI
    Adjust HBTE attenuation values    10.108.241.29    1:20; 2:20; 5:20; 6:20; 3:127; 4:127; 7:127; 8:127
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    11    210M    20M    10%    5G    41
