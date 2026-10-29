*** Settings ***
Documentation
...    Author:  You Xingkai
...    Contact: xingkai.you@nokia-sbell.com
...    Feature: CB008434
...    Release: 23R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}
${scfc_file_TC34}    TC34_ASOE_3AZHL_TDD_eCPRI_3NRSuperCELLx2subcells_4T4R_SA.xml
${scfc_file_TC40}    TC40_ASOE_3AZHL_TDD_eCPRI_2NRSuperCELL_4_2_subcells_4T4R_SA.xml

*** Test Cases ***
TC34_CB008434_B_US02_super_cell_setup_on_full_board_3_super_cells_ecpri_ASOE_branch
    [Tags]    CB008434    QL3    Branch    QC_538342
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008434${/}${scfc_file_TC34}
    ${scf_file}    Get Current Scfc
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-21    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='2 beams'
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-22    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='2 beams'
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-23    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='2 beams'

    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    21    210M    20M    10%    5G    41
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:127; 2:127; 5:127; 6:127; 9:20; 10:20; 13:20; 14:20; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    21    210M    20M    10%    5G    41

    Adjust HBTE attenuation values    10.108.241.30
    ...    1:127; 2:127; 5:127; 6:127; 9:127; 10:127; 13:127; 14:127; 3:20; 4:20; 7:20; 8:20; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    22    210M    20M    10%    5G    41
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:127; 2:127; 5:127; 6:127; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:20; 12:20; 15:20; 16:20
    SMAwave L3 call    22    210M    20M    10%    5G    41

    Adjust HBTE attenuation values    10.108.241.30    11:127; 12:127; 15:127; 16:127
    Adjust HBTE attenuation values    10.108.241.29    1:20; 2:20; 5:20; 6:20; 3:127; 4:127; 7:127; 8:127
    SMAwave L3 call    23    210M    20M    10%    5G    41
    Adjust HBTE attenuation values    10.108.241.29    1:127; 2:127; 5:127; 6:127; 3:20; 4:20; 7:20; 8:20
    SMAwave L3 call    23    210M    20M    10%    5G    41

TC40_CB008434_A_US02_super_cell_setup_on_full_board_2_and_4_sub_cells_within_each_super_cell_block_unblock_ecpri_ASOE_branch
    [Tags]    CB008434    QL3    Branch    QC_538343
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008434${/}${scfc_file_TC40}

    ${scf_file}    Get Current Scfc
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-11    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='4 beams'
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-12    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='2 beams'

    Perform NR Cell block 11 via AdminCLI
    Perform NR Cell unblock 11 via AdminCLI
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    Adjust HBTE attenuation values    10.108.241.29    1:20; 2:20; 5:20; 6:20; 3:20; 4:20; 7:20; 8:20
    SMAwave L3 call    12    210M    20M    10%    5G    41

TC34_CB008434_B_US02_super_cell_setup_on_full_board_3_super_cells_ecpri_ASOE_trunk
    [Tags]    ASOE    SMAwave    CPE    CB008434    TC34    QL3     trunk    QC_372452
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008434${/}${scfc_file_TC34}

    ${scf_file}    Get Current Scfc
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-21    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='2 beams'
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-22    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='2 beams'
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-23    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='2 beams'

    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    21    210M    20M    10%    5G    41
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:127; 2:127; 5:127; 6:127; 9:20; 10:20; 13:20; 14:20; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    21    210M    20M    10%    5G    41

    Adjust HBTE attenuation values    10.108.241.30
    ...    1:127; 2:127; 5:127; 6:127; 9:127; 10:127; 13:127; 14:127; 3:20; 4:20; 7:20; 8:20; 11:127; 12:127; 15:127; 16:127
    SMAwave L3 call    22    210M    20M    10%    5G    41
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:127; 2:127; 5:127; 6:127; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:20; 12:20; 15:20; 16:20
    SMAwave L3 call    22    210M    20M    10%    5G    41

    Adjust HBTE attenuation values    10.108.241.30    11:127; 12:127; 15:127; 16:127
    Adjust HBTE attenuation values    10.108.241.29    1:20; 2:20; 5:20; 6:20; 3:127; 4:127; 7:127; 8:127
    SMAwave L3 call    23    210M    20M    10%    5G    41
    Adjust HBTE attenuation values    10.108.241.29    1:127; 2:127; 5:127; 6:127; 3:20; 4:20; 7:20; 8:20
    SMAwave L3 call    23    210M    20M    10%    5G    41

TC40_CB008434_A_US02_super_cell_setup_on_full_board_2_and_4_sub_cells_within_each_super_cell_block_unblock_ecpri_ASOE_trunk
    [Tags]    ASOE    SMAwave    CPE    CB008434    TC40    QL3     trunk    QC_372453
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB008434${/}${scfc_file_TC40}

    ${scf_file}    Get Current Scfc
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-11    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='4 beams'
    ${numberOfTransmittedSsBlocks}    Get Value From SCF By Class    ${scf_file}    NRCELLGRP    NRCELLGRP-12    numberOfTransmittedSsBlocks
    should be true    '${numberOfTransmittedSsBlocks}'=='2 beams'

    Perform NR Cell block 11 via AdminCLI
    Perform NR Cell unblock 11 via AdminCLI
    Adjust HBTE attenuation values    10.108.241.30
    ...    1:20; 2:20; 5:20; 6:20; 9:127; 10:127; 13:127; 14:127; 3:127; 4:127; 7:127; 8:127; 11:127; 12:127; 15:127; 16:127
    Adjust HBTE attenuation values    10.108.241.29    1:20; 2:20; 5:20; 6:20; 3:20; 4:20; 7:20; 8:20
    SMAwave L3 call    12    210M    20M    10%    5G    41
