*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource     CB009823_keywords_ABIP.robot
Library      CB009823_verify.py
Library      ta5g_tshark
Library      BuiltIn
Library      Collections
Library      OperatingSystem
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/AEQE_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_CB009823_A_1116_ABIP.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/RIMRS_from_gNB_basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4 # rdFeatureFlagBitmapLevel
...                         0x580582 = 3 # rdFeatureFlagBitmap7
...                         0x58057f = 72 # rdFeatureFlagBitmap4
...                         0x58057b = 8 # rdFeatureFlagBitmap0
...                         0x3F007C = 1500

${NOISE_POWER_RI}=       SEPARATOR=
...                       -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-105,
...                       -110,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115


*** Test Cases ***
CB009823-A1_Start_and_stop_RIMRS_transmission_and_RS1_detection_depending_on_RI_enabled_5GC001116_6GP_3ms_shift
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=1     tput_dl=1
	Activate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=1000
    Start Gathering BIP Logs
	Stop gnbMirroring And Gather L1L2 Bip Logs
	Convert pcap file to pdml
    Verify If RS1 Is Properly Transmitted
    Activate RIMRS
    Wait For Fault To Be Up     fault_id=7527   timeout=2500
    Start Gathering BIP Logs And Wait 200s
    Stop gnbMirroring And Gather L1L2 Bip Logs2
    Verify PM Counters For RIMRS
    Convert Second pcap file to pdml
    Verify If RS2 Is Properly Transmitted
    Deactive Ri
    Wait For Fault To Be Down     fault_id=7525   timeout=600
    Wait For Next Pm Interval
    Verify If Pm Counters Are Not Incremented
    [Teardown]    Run Keywords     Stop All Data Transfers And Detach UE
    ...    AND    Send Configuration ID To Scout
