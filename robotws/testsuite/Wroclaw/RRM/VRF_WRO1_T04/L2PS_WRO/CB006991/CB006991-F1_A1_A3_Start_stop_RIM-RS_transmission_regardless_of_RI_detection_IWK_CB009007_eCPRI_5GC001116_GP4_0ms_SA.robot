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

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AEQE_GSCN_7880.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB006991_F1_1116.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 11
...                         0x3F007C = 500

*** Test Cases ***
CB006991-F_F1_A1_A3_Start_stop_RIM-RS_transmission_regardless_of_RI_detection_IWK_CB009007_eCPRI_5GC001116_GP4_0ms_SA
    [Documentation]
    ...  Description: This test verifies that gGNB supports to start and stop RIM-RS type 1 transmission depending
    ...  on Remote Interference detection when CB009007 (Enhanced PDSCH scheduling on special slot) is enabled and
    ...  the special slot is set to 6DL-4GP-4UL.
    ...               (Regarding to configuration N_Pt_slot = 327680) it means that RIM-RS should be scheduled
    ...               every ~164s
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL And In UL   ue_id=1    pdu=1   tput_dl=1   tput_ul=1
    Activate RIM-RS transmission By Sending Delta Commisioning
    Start Gathering BIP Logs When RIM-RS is Enabled
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=1
    Stop Data Traffic And Detach 1 SA UE
    Start Data Traffic In DL And In UL   ue_id=2    pdu=2   tput_dl=1   tput_ul=1
    Wait For RIMRS
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Convert pcap file to pdml
    Check If RimRsSendReq is Present
    Check If StartRBforRS When Rim-rs is Transmitting is Correctly Set
    Check If CSI-RS and RIM-RS are not send on the same slot
    Deactivate RIM-RS transmission by Sending Delta Commisioning
    Start Gathering BIP Logs When RIM-RS is Disabled
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL And In UL   ue_id=1    pdu=1   tput_dl=1   tput_ul=1
    Stop gnbMirroring And Gather L1L2 logs for Disabled RIMRS
    Convert pcap file to pdml Disabled RIMRS
    Check If RimRsSendReq Is Not Longer Generated
    [Teardown]    Stop All Data Transfers And Detach UE

*** Keywords ***
Wait For RIMRS
    Sleep    180s

