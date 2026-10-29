*** Settings ***
Documentation
...    copyright: Nokia

Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_TDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource     CNI_102746_keywords.robot
Library      CNI_102746_keywords.py
Resource     ../resources/configuration_id.robot

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/1AEQE_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=CNI_102746_near_far_1_1208.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/RIMRS_from_gNB_basic_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4 # rdFeatureFlagBitmapLevel
...                         0x580582 = 3 # rdFeatureFlagBitmap7
...                         0x58057f = 72 # rdFeatureFlagBitmap4
...                         0x58057b = 8 # rdFeatureFlagBitmap0
...                         0x3F007C = 1000

${NOISE_POWER_RI}=       SEPARATOR=
...                       -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-105,
...                       -110,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

*** Test Cases ***
CNI-102746_RIM-RS_detection_and_transmission_with_NEAR-FAR_1_function_enabled_5GC001208
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=50     tput_dl=50
    Generate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=850
    Generate RIMRS
    Wait For Fault To Be Up     fault_id=7527   timeout=1500
    Start Gathering BIP Logs
	Stop gnbMirroring And Gather L1L2 Bip Logs
	Convert pcap file to pdml
    Verify RIM-RS Slot With 4 Repetitions
    Verify RIM-RS Is Detected In First UL Slot
    Stop All Data Transfers And Detach UE
    [Teardown]    Send Configuration ID To Scout



