*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library      ../CB007813/CB007813-B_keywords.py
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      ta5g_tshark
Resource    CB006991_kewords.robot
Library     CB006991_keywords.py
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AEQE_GSCN_7880.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB006991_A4_A5_1070.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg

#Suite Teardown   Run Keywords    Print Active Alarms
#    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 11
...                         0x3F007C = 1200
${BIP_SCRIPT_PATH}      ${CURDIR}/../../resources/L2L1_BIP/script
${RIMRS}=         dldata_rimrssendreq
${FILTER}    dldata_rimrssendreq
${NOISE_POWER_FOR_RI}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

*** Test Cases ***
CB006991-A_A4_A5_Start_stop_RIM-RS_transmission_depending_on_RI_detection_eCPRI_5GC001070_GP2_SA
    [Documentation]
    ...  Description: This test verifies that GNB supports to start and stop RIM-RS type 1 transmission depending
    ...  on Remote Interference detection.
    ...               (Regarding to configuration N_Pt_slot = 327680) it means that RIM-RS should be scheduled
    ...               every ~164s
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Low Data Traffic In DL And In UL   ue_id=1    pdu=1   tput_dl=1   tput_ul=1
    Activate RIM-RS transmission By Triggering RI
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=1
    Stop Data Traffic And Detach 1 SA UE
    Start Low Data Traffic In DL And In UL   ue_id=2    pdu=2   tput_dl=1   tput_ul=1
    Wait For Rimrssendreq
    Start Gathering BIP Logs And Wait 600s
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Convert pcap file to pdml
    Verify RIM-RS Slot And Sfn With 8 Repetitions
    Check If RimRsSendReq is Present
    Check If StartRBforRS When Rim-rs is Transmitting is Correctly Set
    Check If CSI-RS and RIM-RS are not send on the same slot
    Deactivate RIM-RS transmission
    Wait For Fault To Be Down     fault_id=7525   timeout=600
    Start Gathering BIP Logs And Wait 600s
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Low Data Traffic In DL And In UL   ue_id=1    pdu=1   tput_dl=1   tput_ul=1
    Stop gnbMirroring And Gather L1L2 logs for Disabled RIMRS
    Convert pcap file to pdml Disabled RIMRS
    Check If RimRsSendReq Is Not Longer Generated
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Wait For Rimrssendreq
    Sleep    1750s

Start Gathering BIP Logs And Wait 600s
    [Arguments]    ${target_file_name}=tcpdump
     ${webservice}=  Create Dictionary
     ...  host=192.168.255.129
     ...  user=Nemuadmin
     ...  password=nemuuser
     ...  port=443

     create_interface_mirroring_l1l2bip_collector
     ...  name=tcpdump
     ...  webservice=${webservice}
     ...  target_file_name=tcpdump
     ...  timeout=1300
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}
     Sleep    600

Verify RIM-RS Slot And Sfn With 8 Repetitions
    ${slot_rimrssendreq}    ${sfn_rimrssendreq}    get_rimrs_slot_and_sfn    pdml_path=${OUTPUT_DIR}/BIP_log_RIM.pdml
    Should Be True    ${slot_rimrssendreq} == [3, 7, 13, 17, 1, 5, 11, 15]
    Should Be True    ${sfn_rimrssendreq} == [124, 124, 124, 124, 125, 125, 125, 125]

