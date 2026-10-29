*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library      ../CB007813/CB007813-B_keywords.py
Library     CB006991_keywords.py
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Resource    CB006991_kewords.robot

Library      ta5g_tshark

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AEQE_GSCN_7880.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB006991_A2_A3_1208.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 11
...                         0x3F007C = 700

${NOISE_POWER_FOR_RI}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

*** Test Cases ***
CB006991-A_A2_A3_Start_stop_RIM-RS_transmission_NEAR-FAR_enabled_regardless_of_RI_detection_eCPRI_5GC001208_GP2_NSA
    [Documentation]
    ...  Description: This test verifies that gNB supports to start and stop RIM-RS type 1 transmission
    ...               regardless of Remote Interference detection.
    ...               (Regarding to configuration N_Pt_slot = 655360) it means that RIM-RS should be scheduled
    ...               every ~328s
    Set Up X2 link
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Start DL and UL Data Traffic    ue_id=11
    Activate RIM-RS transmission By Triggering RI
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Start Gathering BIP Logs When RIM-RS is Enabled
    Attach Ue To Enb And Start Gnb Addition    ue_id=12   target_cells=1
    Stop Data Traffic And Detach 1 UE
    Start DL and UL Data Traffic     ue_id=12
    Wait For RIMRS
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Convert pcap file to pdml
    Check If RimRsSendReq is Present
    Check If StartRBforRS When Rim-rs is Transmitting is Correctly Set
    Check If CSI-RS and RIM-RS are not send on the same slot
    Deactivate RIM-RS transmission
    Wait For Fault To Be Down     fault_id=7525   timeout=600
    Start Gathering BIP Logs When RIM-RS is Disabled
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Start DL and UL Data Traffic    ue_id=11
    Stop gnbMirroring And Gather L1L2 logs for Disabled RIMRS
    Convert pcap file to pdml Disabled RIMRS
    Check If RimRsSendReq Is Not Longer Generated
    [Teardown]    Stop All Data Transfers And Detach NSA UEs

*** Keywords ***
Wait For RIMRS
    Sleep    400s



