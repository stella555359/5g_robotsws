*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784_keywords.robot
Library      CB010784_keywords.py

*** Keywords ***
CB010784-B_IWK1_HighSpeed_UE_call_to_ring_cell_wo_3rdPS_addDelay80_SA_prach161
    Check Guard Period Length     expected_value=4Symbols
    Attach SA UE-1 To TDD Cell
    Start DL and UL Data Traffic SA HighSpeed
    Verify DL and UL Tput SA
    Activate HighSpeed Test Model      profile_id=2
    Verify DL and UL Tput SA
    Check Timing Advance Counters
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE SA    ue_id=1
    ...           AND             Stop Tshark With Alias
