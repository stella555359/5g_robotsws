*** Settings ***

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00
...           CONFIGS_Timisoara/RAN_L3_SW_TIM/2_CELLS_SANSA_TDD_CA/iphy_and_scfc_n78_n41.yaml
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Alexandru Tancau
...              :contact: alexandru.tancau@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../resources/ute_report.robot
Resource     CNI-91473_Variables_And_Keywords.robot

Suite Setup     Run Keywords    Setup Custom IPHY   iphy=${custom-iphy-4}
...             AND             Setup Custom SCF    scf=${custom-scf-4}
...             AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_TDD_2Cells_SANSA_n78_n41-PC15.lua
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Suite Teardown    Run Keywords     Perform Parameter Commissioning
...                                parameter=actMultiFrequencyBandIndicatorNRSupport    value=false    dist_name=MRBTS-1/NRBTS-1
...               AND              Wait for all cells to be enabled    timeout=480
...               AND              Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CNI-91473_4_actMultiFrequencyBandIndicatorNRSupport_UE_PC_For_Band_78_As_Pcell_And_Band_41_As_Scell
    [Tags]     CRT
    [Documentation]     Scope of this test case is to verify 3GPP TS 38.331 BandNR.ue-PowerClass-v1610 IE (PC 1.5) for
    ...                 the BandNR N78 of PCell. Also, it verifies if the corresponding Pmax to 29dBm is linked and
    ...                 ul-FullPowerTransmission-r16 is presented and the output will be fullPowerMode1
    Attach UE and verify tcpdump    ue=1    packet_filter=${UE_PMAX1_N78}    pmax_value=30   nrband=${UE_BAND_N78}    cell_id=1
    Attach UE and verify tcpdump    ue=2    packet_filter=${UE_PMAX2_N78}    pmax_value=-29   nrband=${UE_BAND_N78}   cell_id=1
    Attach UE and verify tcpdump    ue=3    packet_filter=${UE_PMAX3_N78}    pmax_value=0   nrband=${UE_BAND_N78}     cell_id=1
    Perform Parameter Commissioning    parameter=actMultiFrequencyBandIndicatorNRSupport    value=true    dist_name=MRBTS-1/NRBTS-1
    Wait for all cells to be enabled    timeout=480
    Attach UE and verify tcpdump    ue=1    packet_filter=${UE_PMAX1_N78}    pmax_value=30   nrband=${UE_BAND_N78}    cell_id=1
    Attach UE and verify tcpdump    ue=2    packet_filter=${UE_PMAX2_N78}    pmax_value=-29   nrband=${UE_BAND_N78}   cell_id=1
    Attach UE and verify tcpdump    ue=3    packet_filter=${UE_PMAX3_N78}    pmax_value=0   nrband=${UE_BAND_N78}     cell_id=1
    [Teardown]    Add Scout Data Info To Testcase
