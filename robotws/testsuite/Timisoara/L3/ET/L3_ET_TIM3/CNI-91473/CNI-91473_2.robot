*** Settings ***

Force Tags    CLOUD_5G_I_LO_AP_LO
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Alexandru Tancau
...              :contact: alexandru.tancau@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     CNI-91473_Variables_And_Keywords.robot
Resource     ../resources/ute_report.robot

Suite Setup     Run Keywords    Setup Custom IPHY   iphy=${custom-iphy-2}
...             AND             Setup Custom SCF    scf=${custom-scf-2}
...             AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Start Xn And Ng Interfaces For Second Gnb
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_TDD_2Cells_SANSA_n77_n41-PC15.lua
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
Test Setup        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Suite Teardown    Run Keywords     Perform Parameter Commissioning
...                                parameter=actMultiFrequencyBandIndicatorNRSupport    value=false    dist_name=MRBTS-1/NRBTS-1
...               AND              Wait for all cells to be enabled    timeout=480
...               AND              Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CNI-91473_2_actMultiFrequencyBandIndicatorNRSupport_UE_PC_For_Band_41_As_Scell_And_Band_77_As_Pcell
    [Tags]    CRT
    [Documentation]     Scope of this test case is to verify 3GPP TS 38.331 BandNR.ue-PowerClass-v1610 IE (PC 1.5) for
    ...                 the BandNR N77 of PCell. Also, it verifies if the corresponding Pmax to 29dBm is linked and
    ...                 ul-FullPowerTransmission-r16 is presented and the output will be fullPowerMode1
    Attach UE and verify tcpdump    ue=11    packet_filter=${UE_PMAX1_N77}    pmax_value=29   nrband=${UE_BAND_N77}    cell_id=2
    Attach UE and verify tcpdump    ue=12    packet_filter=${UE_PMAX2_N77}    pmax_value=-16   nrband=${UE_BAND_N77}   cell_id=2
    Attach UE and verify tcpdump    ue=13    packet_filter=${UE_PMAX3_N77}    pmax_value=5   nrband=${UE_BAND_N77}     cell_id=2
    Perform Parameter Commissioning    parameter=actMultiFrequencyBandIndicatorNRSupport    value=true    dist_name=MRBTS-1/NRBTS-1
    Wait for all cells to be enabled    timeout=480
    Attach UE and verify tcpdump    ue=11    packet_filter=${UE_PMAX1_N77}    pmax_value=29   nrband=${UE_BAND_N77}    cell_id=2
    Attach UE and verify tcpdump    ue=12    packet_filter=${UE_PMAX2_N77}    pmax_value=-16   nrband=${UE_BAND_N77}   cell_id=2
    Attach UE and verify tcpdump    ue=13    packet_filter=${UE_PMAX3_N77}    pmax_value=5   nrband=${UE_BAND_N77}     cell_id=2
    Add Scout Data Info To Testcase
