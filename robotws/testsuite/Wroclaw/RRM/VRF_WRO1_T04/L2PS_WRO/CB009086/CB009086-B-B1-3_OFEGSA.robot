*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD_ORAN    RAN_5G    RAN_5G_FDD    CRT    SBTS00

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    resources/9086_keywords.robot
Library     resources/9086_keywords.py
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Backup And Modify Swconfig File
    ...                        parameters_list=@{SWCONFIG_FLAGS}
    ...        AND             Install OFEGSA RU
    ...                        sh_path=${INSTALL_OFEGSA}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=CB009086_B_B1_OFEGSA.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_9086_B_B1_3_OFEGSA.cfg

Suite Teardown   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIL
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu
@{SWCONFIG_FLAGS}=     0x59006a = 0    0x58057a = 4    0x58057c = 0x1800000    0x58057d = 0x400
${LOCAL_MOID}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${REP_QUANT}=    itf_l2_ps_csi_PerCsiReportConfig.reportQuantity
${MAX_LAYERS}=    itf_l2_ps_pdsch_PdschConfig.maxNumOfDlLayers
${INSTALL_OFEGSA}=    ${CURDIR}/config/install_ofegsa.sh

*** Test Cases ***
CB009086-B_B1_Open_loop_transmission_PDSCH_with_Adaptive_RI_UE_capa_4_DL_layers_and_CRI-RI-CQI_with_PMI_reporting
    Set Internal Traffic Type To UE
    Start Bip Logs Collection
    Attach Ue    ue_id=1
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=1
    Start TTI trace
    Start DL and UL Data Traffic
    Start DL Data Traffic
    Sleep    5s
    Stop Bip Logs Collection
    Stop TTI trace
    Verify Tput For UE SA    ue_id=1    dir=dl    expected_tput=5
    Verify Tput For UE SA    ue_id=1    dir=ul    expected_tput=2
    Verify Tput For UE SA    ue_id=2    dir=dl    expected_tput=5
    Convert TTI trace from pcap to excelCsv
    ${IS_RI_BITS_CORRECT}=    Analyze Csv For Ri Bits    path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}    expected_ri_bits=${2}
    Should Be Equal    ${IS_RI_BITS_CORRECT}    ${TRUE}
    Verify Tcpdump Log    packet_filter=${REP_QUANT}==0    number_of_messages=4    pcap_file_path=${OUTPUT_DIR}/L1L2_GNB0/L1L2_GNB0.pcap
    Verify Tcpdump Log    packet_filter=${MAX_LAYERS}==1    number_of_messages=2    pcap_file_path=${OUTPUT_DIR}/L1L2_GNB0/L1L2_GNB0.pcap
    Verify Tcpdump Log    packet_filter=${MAX_LAYERS}==4    number_of_messages=2    pcap_file_path=${OUTPUT_DIR}/L1L2_GNB0/L1L2_GNB0.pcap
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Stop Bip Logs Collection    AND    Stop All Data Transfers And Detach UE SA
    ...    AND    Send Configuration ID To Scout
