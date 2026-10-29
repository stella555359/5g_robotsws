*** Settings ***
#Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP    CRT    SBTS00    RAN_5G    RAN_5G_FDD
#...   PY36

Documentation    :copyright: Nokia
...   The aim of this feaure is test the repetitions for RIM-RS2 with framework-1

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
#Resource         ../resources/robot/PM_Counters.robot
#Resource         ../resources/robot/common_log_collection.robot
Resource         ./resource/CB009823_keywords.robot
Library          ./resource/CB009823_PCMD_verify.py
Library      ta5g_setups_and_teardowns


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/CB009823_iphy.xml
    ...                        swconfig_flags_list=@{L2PS_RI_DEBUG}
    ...        AND             Start Default Logging
    ...        AND             Configure PCMD in Wireshark
#    ...        AND             Find Scfc And Fix And Send Full Commissioning
#    ...                        scfc_filename=scf_near_far_prbblanking_srsbm.xml
    ...        AND              Find Scfc and Send Delta Commissioning    scfc_filename=delta_near_far.json
    ...        AND             Sleep    30s
#    ...        AND             gnb.Perform gNB reboot
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_GMC_RS2.cfg

Suite Teardown   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x580582 = 3
...                         0x58057b = 8
...                         0x58012d=2 # k1min=4
...                         0x5800f4=2 # k2min=4

${port_trace}                         49151
${ip_trace}                           10.0.1.10

${NOISE_POWER_FOR_RI}=     SEPARATOR=
...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47

${NOISE_POWER_RI}=       SEPARATOR=
...                       -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,
...                       -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

${RI_SLOPE_MEASUREMENTS}=    SEPARATOR=
...      ((((nsetapx.riSlopeMeasRecord == 0) && (nsetapx.recordCollectionDuration == 10000)) &&
...      (nsetapx.slotNumber == 7)) && (nsetapx.symbolNumber == 12) && (nsetapx.numOfDropHeightSamples))
${RIM_RS_MEASUREMENTS}=      SEPARATOR=
...      (((nsetapx.rimRsMonitoringRecord == 1) && (nsetapx.rimRsSetId == 44444)) &&
...      (nsetapx.propagationDelayInSymbol)) && (nsetapx.repetitionIndex == 4)
${RIM_RS_MEASUREMENTS_RECONF}=      SEPARATOR=
...      ((nsetapx.rimRsMonitoringRecord == 1) && (nsetapx.propagationDelayInSymbol)) &&
...      (nsetapx.repetitionIndex == 2)

${NO_CONNTENT_FOR_PCMDREPORTING}=      (nsetapx.dlRbRlcMeasRecord  == 0) && (nsetapx.ulRbRlcMeasRecord == 0)
${folder_path}=   /home/ute/test_logs/

*** Test Cases ***
[1]CB009823_L_03_Verify_the_RIM-RS_Type_2_transmission_with_NEAR-FAR_function_enabled
    [Tags]    QC_352926      QCD_MN_RAN    QCP_RAN_ET
    [Setup]    Run Keywords   Start Netcat for tracing
    ...    AND     Setup X2 Link
    ...    AND     Start First Tcp Pcap
    Attach single UE and start traffic
    Activate RI
    Wait For Fault To Be Up     fault_id=7525   timeout=1500
    Activate RIMRS_near
    Verify PCMD Trace Records for RI    packet_filter=${RI_SLOPE_MEASUREMENTS}
    Wait For Fault To Be Up     fault_id=7527   timeout=1500
    Sleep    100s
    Verify PCMD Trace Records for RIM-RS      packet_filter=${RIM_RS_MEASUREMENTS}
    Stop Netact for tracing
    Stop Tcp Pcap
    ${file_path}=     Find Latest Pcapng File  ${folder_path}
    Convert pcap file to pdml     ${file_path}
    Verify If All PCMD Records For RI and RIMRS Exist
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Attach single UE and start traffic
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In UL   ue_id=1    pdu=1    tput_ul=175

Activate RIMRS_near
    ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...        rimrs_testmode_nr profile_id=94 config_mode=standalone aggressor_cell=1 victim_cell=1 rsSetId=44444 numRsSetId=1
	...        \ rimRsType=rsType2 propagation_delay=16 rsType2NScId=1,2,3,4,5,6,7,8 rsPattern1Period=25 rsPattern2Period=25
	...        \ factorRsSequenceRS2=0 startRbForRs=1,50,100,150 repetitionRsType2=4 rim_framework=framework_1
	...        \ numRsType2SetId=131072 numRsType1SetId=131072 repetitionRsType1=2

    Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=1 gnb=2 testmode=rim_rs profile_id=94 action=activate
