*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Library    resources/keywords_9107.py
Resource     resources/keywords_9107.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot

*** Variables ***
${UE_1}    UE_1
${UE_3}    UE_3
${NR_SUPERCELL}    2
${LTE_SUPERCELL}    15
@{NORMAL_CELLS}    3    16

*** Keywords ***
TC03_CB009107-A_NR_supercell_and_LTE_supercell_work_on_same_two_sectors_with_RF_sharing_configuration_UE_is_in_static(0kmph)
    Set Preferred Cell    15    cell_type=lte    lnbts_id=40896
    Set Preferred Cell    2    cell_type=nr
    Require Ue If Not Reserved    ${UE_1}
    Require Ue If Not Reserved    ${UE_3}
    Switch Ue Mode To NR    UE_1
    Attenuate All Cells Except Supercell NR Sector 1
    Start Verification Supercell    ${UE_1}    ${NR_SUPERCELL}    sector=1    dst_sector=2

    Attenuate All Cells Except Supercell NR Sector 2
    Block Cells    ${NORMAL_CELLS}
    Start Verification Supercell    ${UE_1}    ${NR_SUPERCELL}    sector=2    dst_sector=1
    Unblock Blocked Cells

    Attenuate All Cells Except Supercell NR Sector 1
    Block Cells    ${LTE_SUPERCELL}
    Start Verification Supercell    ${UE_1}    ${NR_SUPERCELL}    sector=1    dst_sector=2
    Unblock Blocked Cells

    Attenuate All Cells Except Supercell LTE Sector 1
    Start Verification Supercell    ${UE_3}    ${LTE_SUPERCELL}    sector=1    dst_sector=2

    Attenuate All Cells Except Supercell LTE Sector 2
    Block Cells    ${NORMAL_CELLS}
    Start Verification Supercell    ${UE_3}    ${LTE_SUPERCELL}    sector=2    dst_sector=1
    Unblock Blocked Cells

    Attenuate All Cells Except Supercell LTE Sector 1
    Block Cells    ${NR_SUPERCELL}
    Start Verification Supercell    ${UE_3}    ${LTE_SUPERCELL}    sector=1    dst_sector=2
    Unblock Blocked Cells

    [Teardown]    Run Keywords
    ...    Detach Ue    ${UE_1}    AND
    ...    Detach Ue    ${UE_3}    AND
    ...    Unblock Blocked Cells
