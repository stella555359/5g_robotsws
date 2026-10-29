*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Resource     testsuite/Wroclaw/RRM/resources/logs.robot
Resource     CNI_102746_keywords.robot
Library      CNI_102746_keywords.py

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/1AEQE_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=CNI_102746_near_far_1_1116_trans.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/RIMRS_from_gNB_basic_setup.cfg

#Suite Teardown   Run Keywords    Print Active Alarms
#    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x580582 = 3
...                         0x58057f = 72
...                         0x58057b = 8
...                         0x3F007C = 800


${NOISE_POWER_FOR_RI}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

${RIMRS_SET_IDS}=      nsetapx.rimRsSetId == 22222

*** Test Cases ***
CNI-102746_RIM-RS_detection_and_transmission_with_NEAR-FAR_1_function_enabled_5GC001116
    [Setup]    Run Keywords   Start Tcp Pcap
    ...    AND     Start PCMD
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL and UL   ue_id=1    pdu=1    tput_ul=1     tput_dl=1
    Generate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=900
    Generate RIMRS For 1116 FS
    Wait For Fault To Be Up     fault_id=7527   timeout=1500
    Start Gathering BIP Logs And Wait 200s
    Stop gnbMirroring And Gather L1L2 Bip Logs
    Convert pcap file to pdml
    ${pdml_file}=    Set Variable    ${OUTPUT_DIR}/BIP_log_2.pdml
    @{slots_to_check}=    Create List    3    12
    Verify If Transmission RIMRS Is On Correct Slots    ${pdml_file}    @{slots_to_check}
    Verify If RimrsSetID Is Detected      packet_filter=${RIMRS_SET_IDS}
    Verify Detection RimRs For First ULslot
    [Teardown]    Run Keywords     Stop Tcp Pcap
    ...      AND     Stop And Teardown PCMD
    ...      AND     Stop All Data Transfers And Detach UE


*** Keywords ***
Start Gathering BIP Logs And Wait 200s
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
     Sleep    400

Verify Detection RimRs For First ULslot
    ${slot}    ${symbolindex}     Get Slot And Symbolindex    pdml_path=${OUTPUT_DIR}/BIP_log_2.pdml
    Should Be Equal    ${slot}    ${4}
    Should Contain     ${symbolindex}    ${12}     ${13}

Verify If Transmission RIMRS Is On Correct Slots
    [Arguments]    ${pdml_file}    @{slots_to_check}
    ${result}=    check_rimrssendreq_in_correct_slots    ${pdml_file}    ${slots_to_check}
    Run Keyword If    '${result}' == 'Passed'    Log    msg 'dldata_rimrssendreq' found on all expected slots.
    ...    ELSE    Fail    msg 'dldata_rimrssendreq' not found on all expected slots.

Convert pcap file to pdml
    [Arguments]   ${input_file}=${OUTPUT_DIR}/BIP_L1L2.pcap
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y '(dldata_rimrssendreq) || (3gpp.slot == 4 && UlData_detectionResUnitsResp_t.symbolIndex == 12)'
    ...    -T pdml > ${OUTPUT_DIR}/BIP_log_2.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...
    Sleep    300s

Generate RI
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id=7 start_symbol_position=0 num_of_symbols=32 noise_power_values=${NOISE_POWER_FOR_RI}
    Sleep   5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode=remote_interference gnb=2 cell_id=1 profile_id=7 action=activate

Generate RIMRS For 1116 FS
        ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...     rimrs_testmode_nr profile_id=3 config_mode=standalone aggressor_cell=1 rsSetId=22222
    ...     \ propagation_delay=22 rsNearFarConfig=1
    ...     \ rsType1NScId=1,2,3,4,5,6,7,8 rsPattern1Period=50 factorRsSequence=0 offsetRsSequence=0
    ...     \ startRbForRs=1,50,100,150 rimRsTxPower=-330 repetitionRsType1=2 rsPattern2Period=25
    Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=3 action=activate

Verify If RimrsSetID Is Detected
    [Arguments]    ${packet_filter}    ${pcap_file_path}=${None}    ${timeout}=10
    ...            ${alias}=tcp_pcap    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
     ...   pass_criteria= >=1
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}
