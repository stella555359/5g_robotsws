*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB010784/CB010784_keywords.robot
Library      CB010784_keywords.py

*** Variables ***
${Vlue_DownlinkSymbols_A_B4}=     (nrofDownlinkSymbols 6)
${TA_RACH_RESP_BIN_25}=           M55307C01025

*** Keywords ***
CB010784-A_B4_UE_call_to_regular_cell_with_3rdPS_SA_UEspecificCSIRS_GP6
    Verify NR of Downlink Symbols   ${Vlue_DownlinkSymbols_A_B4}
    Verify Guard Period Lengh    expected_value=6Symbols
    Start Gathering BIP Logs
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
	Start DL and UL Data Traffic SA A B4
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=dl    unit=M    expected_tput=98.5
    Verify Tput For UE SA    ue_id=1    pdu=1    qfi=1    dir=ul    unit=M    expected_tput=98.5
    Verify Timing Advance Counters  ${TA_RACH_RESP_BIN_25}
    Stop gnbMirroring And Gather L1L2 Bip
    Verify CSI-RS In Some BI Slots
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE B2
    ...           AND             ADMIN Teardown Admin    alias=admin
