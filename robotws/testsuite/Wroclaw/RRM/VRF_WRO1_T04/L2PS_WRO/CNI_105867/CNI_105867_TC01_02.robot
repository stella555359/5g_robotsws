*** Settings ***
Documentation    :copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      ta5g_tshark
Library      BuiltIn
Library      Collections
Library    OperatingSystem
Library      dl_mitigation_verify.py
Resource     CNI_105867_keywords.robot
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/CB006991_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CNI105867_scenario1.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/RIMRS_from_gNB_basic_setup.cfg

#Suite Teardown   Run Keywords    Print Active Alarms
#    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f= 8
...                         0x580582 = 3
...                         0x58057b = 8

${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu

${MULTI_RIMRS_SET_IDS}=      SEPARATOR=
...      ((nsetapx.rimRsSetId == 22222) && (nsetapx.rimRsSetId == 22223)) &&
...      (nsetapx.rimRsSetId == 22224)

${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

${port_trace}               49151
${ip_trace}                 10.0.1.10

${folder_path}=     /home/ute/test_logs/
${pdml_file}=      pdml_file=${OUTPUT_DIR}/BIP_log_1.pdml

*** Test Cases ***
CNI-105867_US1_Starts_stop_DL_mitigation_based_on_congfigured_NrOfActive_setIDs_3_5GC001208
    [Tags]    AP_REG
    [Setup]    Run Keywords   Start Netcat for tracing
    ...    AND     Setup X2 Link
    ...    AND     Start Tcp Pcap
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=175     tput_dl=175
    Activate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=1000
    Activate RIMRS
    Wait For Fault To Be Up     fault_id=7527   timeout=1200
    Sleep      90s
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Convert pcap file to pdml
    ${pdml_file}=    Set Variable    ${OUTPUT_DIR}/BIP_log_1.pdml
    @{muted_slots_to_check}=    Create List    2    3    7    8    12    13    17    18
    Verify If Mitigation Started And Transsmission PDSCH Is Not Visible In Muting Slots    ${pdml_file}    @{muted_slots_to_check}
    Sleep      15s
    Stop Netcat for tracing
    Verify If RsSetIDs Are Correct        packet_filter=${MULTI_RIMRS_SET_IDS}
    Stop Tcp Pcap
    Stop And Teardown PCMD
    Stop RIMRS generation for 1 setID
    Wait For Updated Fault 7527 Without Dl Mittigation
    Start Gathering BIP Logs And Wait 5s
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Convert second pcap file to pdml
    ${second_pdml_file}=    Set Variable    ${OUTPUT_DIR}/BIP_log_2.pdml
    @{slots_to_check}=    Create List    0    1    2    3     5    6    7     8    10    11    12    13    15    16    17    18
    Verify If Mitigation Stopped And Transsmission PDSCH Is Visible In Muting Slots    ${second_pdml_file}    @{slots_to_check}
    Cancel RI
    Wait For Fault To Be Down     fault_id=7525   timeout=800
    Verify If Admin Fault Is Down     fault_id=7525
    Verify If Admin Fault Is Up     fault_id=7527
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE
    ...    AND    Send Configuration ID To Scout
