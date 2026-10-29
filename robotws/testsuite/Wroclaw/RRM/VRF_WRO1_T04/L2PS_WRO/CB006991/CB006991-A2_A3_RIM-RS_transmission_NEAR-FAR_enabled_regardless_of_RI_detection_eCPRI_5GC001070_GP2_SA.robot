*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library      ../CB007262/CB007262_A/CB007262_keywords.py
Library      ../CB007813/CB007813-B_keywords.py
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Library      ta5g_tshark
Resource     CB006991_kewords.robot
Library      CB006991_keywords.py

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AEQE_GSCN_7880.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=scenario_a2_a3_1070.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 11
...                         0x3F007C = 500
${BIP_SCRIPT_PATH}      ${CURDIR}/../../resources/L2L1_BIP/script
${RIMRS}=         dldata_rimrssendreq
${FILTER}    dldata_rimrssendreq
${NOISE_POWER_FOR_RI}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

*** Test Cases ***
CB006991-A_A2_A3_Start_stop_RIM-RS_transmission_NEAR-FAR_enabled_regardless_of_RI_detection_eCPRI_5GC001070_GP2_SA
    [Documentation]
    ...  Description: This test verifies that GNB supports NEAR-FAR function of RIM and start and stop RIM-RS
    ...               type 1 transmission regardless of Remote Interference detection.
    ...               (Regarding to configuration N_Pt_slot = 1310720) it means that RIM-RS should be scheduled
    ...               every ~655s
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Low Data Traffic In DL And In UL   ue_id=1    pdu=1   tput_dl=1   tput_ul=1
    Activate RIM-RS transmission By Triggering RI
    Wait For Fault To Be Up     fault_id=7525   timeout=800
    Start Gathering BIP Logs When RIM-RS is Enabled ASIM
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=1
    Stop Data Traffic And Detach 1 SA UE
    Start Low Data Traffic In DL And In UL   ue_id=2    pdu=2   tput_dl=1   tput_ul=1
    Wait For RIMRS
    Stop gnbMirroring And Gather L1L2 Bip Logs ASIM
    Convert pcap file to pdml
    Check If RimRsSendReq is Present
    Check If StartRBforRS When Rim-rs is Transmitting is Correctly Set
    Deactivate RIM-RS transmission
    Wait For Fault To Be Down     fault_id=7525   timeout=600
    Start Gathering BIP Logs When RIM-RS is Disabled ASIM
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Stop gnbMirroring And Gather L1L2 logs for Disabled RIMRS ASIM
    Convert pcap file to pdml Disabled RIMRS
    Check If RimRsSendReq Is Not Longer Generated
    [Teardown]    Stop All Data Transfers And Detach UE

*** Keywords ***
Wait For RIMRS
    Sleep    700s
