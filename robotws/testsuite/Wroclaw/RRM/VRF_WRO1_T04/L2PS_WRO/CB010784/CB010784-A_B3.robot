*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784_keywords.robot
Library      CB010784_keywords.py

*** Variables ***
${Vlue_DownlinkSymbols_A_B3}=     (nrofDownlinkSymbols 10)
${TA_RACH_RESP_BIN_07}=           M55307C01007

*** Keywords ***
CB010784-A_B3_UE_call_to_ring_cell_wo_3rdPS_addDelay20_NSA_prach146
    Verify NR of Downlink Symbols  ${Vlue_DownlinkSymbols_A_B3}
    Verify Guard Period Lengh    expected_value=2Symbols
    Set Up X2 link
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Start DL and UL Data Traffic    ue_id=11
    Sleep    10s
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=98.5
    Verify Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=88.5
    Verify Timing Advance Counters  ${TA_RACH_RESP_BIN_07}
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE B3
    ...           AND             ADMIN Teardown Admin    alias=admin
