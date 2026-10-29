*** Settings ***

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...           CONFIGURED    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1    PY36
...           CONFIGS_Timisoara/RAN_L3_SW_TIM/2_CELLS_SANSA_TDD_CA/iphy_and_scfc_n41_n79.yaml
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Alexandru Tancau, Alexandru Goman, Andrei Maria
...              :contact: alexandru.tancau@nokia.com, alexandru.goman@nokia.com, andrei.maria@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../resources/ute_report.robot
Resource     CNI-91473_Variables_And_Keywords.robot

Suite Setup     Run Keywords    Setup Custom IPHY   iphy=${custom-iphy-9}
...             AND             Setup Custom SCF    scf=${custom-scf-9}
...             AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...             AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_TDD_2Cells_SANSA_n41_n79-PC15.lua
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup        Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CNI-91473_9_ROBUSTNESS_actMultiFrequencyBandIndicatorNRSupport_UE_PC_For_Band_79_As_Pcell_And_Band_41_As_Scell
    [Tags]     CRT
    [Documentation]
    Perform Parameter Commissioning    parameter=pMaxNROwnCell    value=1    dist_name=MRBTS-1/NRBTS-1/NRCELL-2
    Wait for all cells to be enabled    timeout=480

    Attach Multiple UEs    first_ue_id=1    last_ue_id=3
    Establish Pdu Session With Traffic   ue_id=1    pdu_id=1    gw_id=1     throughput=3mbps
    Establish Pdu Session With Traffic   ue_id=2    pdu_id=2    gw_id=2     throughput=3mbps
    Establish Pdu Session With Traffic   ue_id=3    pdu_id=3    gw_id=3     throughput=3mbps
    Deregister Ue Without Confirmation    ue_id=1-3

    Verify Tcpdump Log    packet_filter=${UE_PMAX_N79_1}      number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UE_BAND_N79}      number_of_messages=3    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC1_5}      number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE}      number_of_messages=3    relation_symbol= >=

    Perform Parameter Commissioning    parameter=pMaxNROwnCell    value=23    dist_name=MRBTS-1/NRBTS-1/NRCELL-2
    Wait for all cells to be enabled    timeout=480

    Attach Multiple UEs    first_ue_id=1    last_ue_id=3
    Establish Pdu Session With Traffic   ue_id=1    pdu_id=1    gw_id=1     throughput=3mbps
    Establish Pdu Session With Traffic   ue_id=2    pdu_id=2    gw_id=2     throughput=3mbps
    Establish Pdu Session With Traffic   ue_id=3    pdu_id=3    gw_id=3     throughput=3mbps
    Deregister Ue Without Confirmation    ue_id=1-3

    Verify Tcpdump Log    packet_filter=${UE_PMAX_N79_23}      number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UE_BAND_N79}      number_of_messages=3    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC1_5}      number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE}      number_of_messages=3    relation_symbol= >=

    Perform Parameter Commissioning    parameter=pMaxNROwnCell    value=30    dist_name=MRBTS-1/NRBTS-1/NRCELL-2
    Wait for all cells to be enabled    timeout=480

    Attach Multiple UEs    first_ue_id=1    last_ue_id=3
    Establish Pdu Session With Traffic   ue_id=1    pdu_id=1    gw_id=1     throughput=3mbps
    Establish Pdu Session With Traffic   ue_id=2    pdu_id=2    gw_id=2     throughput=3mbps
    Establish Pdu Session With Traffic   ue_id=3    pdu_id=3    gw_id=3     throughput=3mbps
    Deregister Ue Without Confirmation    ue_id=1-3

    Verify Tcpdump Log    packet_filter=${UE_PMAX_N79_30}      number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${UE_BAND_N79}      number_of_messages=3    relation_symbol= >=
    Verify Ngap Messages  packet_filter=${UE_POWER_CLASS_PC1_5}      number_of_messages=3    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${FULL_POWER_MODE}      number_of_messages=3    relation_symbol= >=
    [Teardown]    Add Scout Data Info To Testcase