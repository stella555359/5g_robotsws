*** Settings ***
Documentation
...    copyright: Nokia
...    author: Mateusz Bilewicz (mateusz.bilewicz@nokia.com)
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_MP_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/CB009086/resources/9086_keywords.robot

*** Keywords ***
CB009086-B_B1_Open_loop_transmission_PDSCH_with_Adaptive_RI_UE_capa_2_DL_layers_and_CRI-RI-CQI_wo_PMI_reporting
    Set Internal Traffic Type To UE
    Start Gathering BIP Logs ASIM
    Attach Ue    ue_id=1
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=1
    Start TTI trace
    Start DL and UL Data Traffic
    Start DL Data Traffic
    Sleep    3s
    Stop TTI trace
    Stop gnbMirroring And Gather L1L2 Bip Logs ASIM
    Verify Tput For UE SA    ue_id=1    dir=dl    expected_tput=5
    Verify Tput For UE SA    ue_id=1    dir=ul    expected_tput=2
    Verify Tput For UE SA    ue_id=2    dir=dl    expected_tput=5
    Convert TTI trace from pcap to excelCsv
    ${IS_RI_BITS_CORRECT}=    Analyze Csv For Ri Bits    path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}    expected_ri_bits=${2}
    Should Be Equal    ${IS_RI_BITS_CORRECT}    ${TRUE}

