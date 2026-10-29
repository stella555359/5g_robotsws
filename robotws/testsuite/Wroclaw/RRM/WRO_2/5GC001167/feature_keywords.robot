*** Settings ***
Documentation    :copyright: Nokia

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    ../keywords/logging.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot

Library     taf.sbts.oam.coam.admin
Library     taf.hw.pdu
Library     Keywords5GC001167.py
Library     OperatingSystem
Library     DateTime
Library     Telnet
Library     ute_wtssim
Library     ute_fsmaccess
Library     ta5g_aashell
Library     ta5g_throughput
Library     ta5g_ue_mobility
Library     ta5g_cell_operations
Library     ta5g_enb
Library     ta5g_iphy
Library     ta5g_egate
Library     ta5g_tshark
Library     ta5g_iperf_traffic
Library     ta5g_testline_management
Library     ta5g_commissioning
Library     ta5g_file_system
Library     taf.ul.ettf.setups
Library     taf.ul.ettf.retry_context

Variables    feature_variables.py

*** Variables ***
${WTS_DIR}                      /opt/wts/latest
${rdMergedMeasGapSetupAndDrxRelease}=        0x890046=1 # rdMergedMeasGapSetupAndDrxRelease
${DISABLE_HWF_READING}=         0x4F0214=0 #DISABLE HWFREADING
@{SWCONFIG_FLAGS_LIST}=         ${DISABLE_HWF_READING}    ${rdMergedMeasGapSetupAndDrxRelease}
${PDU_MODEL}=                   ${tl.pdus[0].__class__.__name__}
${PDU_IP}=                      ${tl.pdus[0].addr}
${PDU_PORT_AP}=                 ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${GNB_PDU_PORT}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
*** Keywords ***
Custom Prepare Test Environement And Reach Onair
    [Arguments]    ${retries}=3    ${iphy_xml}=${None}    ${scfc}=${None}    ${egate_cfg}=${None}
    ...    ${disablel1bypass}=False    ${flags}=@{SWCONFIG_FLAGS_LIST}

    With Swconfig Flags    flags=${flags}
    Enable C-Plane Debug Logs    with_reboot=${FALSE}
    Run Keyword If    ${disablel1bypass}==True    Disable L1ByPass

    With Retry Context    ${retries}
    ...            Update And Put Iphy Xml         input_filepath=${iphy_xml}
    ...    AND     With Gnb Configuration          commissioning=${scfc}
    ...    AND     With Simulator Configuration    config=${egate_cfg}

    Enable Tshark Verification

Prepare Test Environement And Reach Onair
    [Arguments]    ${iphy_xml}    ${scfc}    ${egate_cfg}    ${cell_number}    ${disablel1bypass}=False
    Log To Console    Parameter $cell number:${cell_number} is unused - consider removing it.
    Run Keyword If    ${disablel1bypass}==True        Disable L1ByPass
    Enable C-Plane Debug Logs       with_reboot=${FALSE}
    With Swconfig Flags             flags=@{swconfig_flags_list}
    Start Default Logging           output_dirpath=${OUTPUT_DIR}/Prepare_Test_Environement
    Update And Put Iphy Xml         input_filepath=${iphy_xml}
    With Gnb Configuration          commissioning=${scfc}
    FOR    ${i}    IN RANGE    3
          ${is_gnb_procedural_status_configured} =    Run Keyword And Return Status    Check Radios Availability
          Exit For Loop If    ${is_gnb_procedural_status_configured} == ${true}
          Reboot Tl Via Pdu
    END
    Wait For Gnb To Reach Configured State
    Sleep    2m
    Reach Onair    lua_cfg=${egate_cfg}    timeout=300
    Stop Default Logging

Prepare Test Environement And Verify Ngap Link Up
    [Arguments]    ${iphy_xml}    ${scfc}    ${egate_cfg}    ${disablel1bypass}=False
    Run Keyword If    ${disablel1bypass}==True        Disable L1ByPass
    Create Cp Runtime File    alias=cp_runtime
    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Prepare_Test_Environement
    Update And Put Iphy Xml    input_filepath=${iphy_xml}
    With Swconfig Flags        flags=@{swconfig_flags_list}
    With Gnb Configuration     commissioning=${scfc}
    FOR    ${i}    IN RANGE    3
          ${is_gnb_procedural_status_configured} =    Run Keyword And Return Status    Check Radios Availability
          Exit For Loop If    ${is_gnb_procedural_status_configured} == ${true}
          Reboot Tl Via Pdu
    END
    Wait For Gnb To Reach Configured State
    Sleep    2m
    Configure Wts Without Onair Check    lua_cfg=${egate_cfg}
    Verify Ngap Messages    packet_filter=${NGAP_SETUP_RESPONSE}    timeout=${NGAP_SETUP_RESPONSE_TIMEOUT}
    Stop Default Logging

Check Cell Sibs On Rrc
    [Arguments]    ${number_of_cells}
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${SIB1_CELL1_PACKET_ON_RRC}
    ...    number_of_messages=1
    ...    timeout=600
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${SIB1_CELL2_PACKET_ON_RRC}
    ...    number_of_messages=1
    ...    timeout=600
    Run Keyword If    ${number_of_cells}==3
    ...    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${SIB1_CELL3_PACKET_ON_RRC}
    ...    number_of_messages=1
    ...    timeout=600

Check Cell Sibs On Rrc Extended Timer
    [Arguments]    ${number_of_cells}
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${SIB1_CELL1_PACKET_ON_RRC}
    ...    number_of_messages=1
    ...    timeout=720
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${SIB1_CELL2_PACKET_ON_RRC}
    ...    number_of_messages=1
    ...    timeout=720
    Run Keyword If    ${number_of_cells}==3
    ...    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=${SIB1_CELL3_PACKET_ON_RRC}
    ...    number_of_messages=1
    ...    timeout=720

Set Internal Traffic Type To UEs
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${ue_id} trf_type=internal

Start Dl Data Traffic
    [Arguments]    ${ue_id}    ${qfi}    ${trf_id}    ${mbps}=150    ${size}=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} trf_id=${trf_id} mbps=${mbps} size=${size} dir=dl

Start Ul Data Traffic
    [Arguments]    ${ue_id}    ${qfi}    ${trf_id}   ${mbps}=150    ${size}=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${ue_id} qfi=${qfi} trf_id=${trf_id} mbps=${mbps} size=${size} dir=ul

Display Bearer Statistic In Egate Console
    [Arguments]    ${ue_id}    ${qfi}
    Execute Egate Command    cmd=bearer_stats ue=${ue_id} pdu=${ue_id} qfi=${qfi} dir=bi

Stop All Data Traffics
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id}

Stop Data Traffics
    [Arguments]    ${ue_id}    ${qfi}    ${dir}
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${ue_id} qfi=${qfi} dir=${dir}

Perform Ue Reestablishment
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${cause}=otherFailure
    Execute Egate Command    cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${cause}

Wait for Traffic to Stabilize
    Sleep    3s

Attach UE And Start Data Traffic
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}=1    ${gw_id}=1
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue    ue_id=${ue_id}    cell=${cell_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1

Send_Data_Traffic_For_Ue_And_Display_Bearer_Statistic
    [Arguments]    ${ue_id}    ${qif}=1
    Start Dl Data Traffic    ue_id=${ue_id}    qfi=${qif}    trf_id=1
    Start Ul Data Traffic    ue_id=${ue_id}    qfi=${qif}    trf_id=1
    Wait for Traffic to Stabilize
    Display Bearer Statistic In Egate Console    ue_id=${ue_id}    qfi=${qif}
    Stop Data Traffics    ue_id=${ue_id}    qfi=${qif}    dir=bi

Detach_Ue_And_Verify_Detach_Procedure
    Start Tcpdump On Remote Interface    alias=detach_check    log_filename_prefix=detach_check    log_dirpath=${OUTPUT_DIR}/tshark
    Deregister Ue    ue_id=1
    Verify Tcpdump Log       ${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    alias=detach_check    number_of_messages=1
    Stop Tcpdump On Remote Interface

Perform UE Handover
    [Arguments]    ${ue_id}    ${a2_meas_id}=1    ${a3_meas_id}=3    ${phycell_id}=51
    Send A2 Measurement To Reconfigure A3    ue_id=${ue_id}    a2_meas_id=${a2_meas_id}
    Send A3 Measurement To Perform UE Handover    ue_id=${ue_id}    phycell_id=${phycell_id}    a3_meas_id=${a3_meas_id}

Send A2 Measurement To Reconfigure A3
    [Arguments]    ${ue_id}    ${a2_meas_id}    ${a2_rsrp}=30
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a2_meas_id} event\=A2 srsrp_nr\=${a2_rsrp}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete

Send A3 Measurement To Perform UE Handover
    [Arguments]    ${ue_id}     ${phycell_id}    ${a3_meas_id}    ${a3_rsrp}=100
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a3_meas_id} phycell_id\=${phycell_id} srsrp_nr\=${a3_rsrp} event\=A3
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-*.* to EXT_ENB-*.* performed

Send A3 Measurement To Perform UE Handover With Nrsrsp
    [Arguments]    ${ue_id}     ${phycell_id}    ${a3_meas_id}    ${a3_rsrp}=100
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${a3_meas_id} phycell_id\=${phycell_id} nrsrp_nr\=${a3_rsrp} event\=A3
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-*.* to EXT_ENB-*.* performed

Change UE Cell Location
    [Arguments]    ${ue_id}=1     ${cell_id}=1
    Execute Egate Command     cmd=ue_change_location id=${ue_id} cell=${cell_id}

Establish VoNR Qosflow
    [Arguments]    ${ue_id}    ${qosflows}
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=${qosflows} by=amf

Delete VoNR Qosflow
    [Arguments]    ${ue_id}    ${qosflows}
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_del=${qosflows} by=amf

Verify Successful Reconfiguration
    [Arguments]    ${packet_filter}
    Verify Tcpdump Log      packet_filter=${packet_filter}

Verify If SCells B And C Are Released After HO
    Verify Tcpdump Log      ${HO_WITH_2_SCELLS_B_C_ACTIVE_AND_TO_BE_RELEASED}

Verify If SCells C Are Released After HO
    Verify Tcpdump Log      ${HO_WITH_1_SCELL_C_ACTIVE_AND_TO_BE_RELEASED}

Verify HO Without CA
    Verify Tcpdump Log      ${HO_WITHOUT_CA_ACTIVE}

Verify If Two Scells Are Released
    Verify Tcpdump Log      ${TWO_SCELLS_TO_BE_REMOVED_LIST}
    Verify Tcpdump Log      ${TWO_SCELLS_TO_RELEASE_LIST}

Verify ICS On NGAP
    Verify Ngap Messages    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}

Verify If Scell Released
    [Arguments]    ${scell_to_release}
    ${num_of_scell_to_rel}=    Scell Release Packet    scell_to_release=${scell_to_release}
    Verify Tcpdump Log      ${num_of_scell_to_rel}      number_of_messages=2

Verify Successful 2CC On NGAP And F1AP Messages
    [Arguments]    ${pcap_file_path}=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    Verify Ngap Messages    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}    pcap_file_path=${pcap_file_path}
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_B_TO_ADD_MOD_LIST}    pcap_file_path=${pcap_file_path}

Attach UE With Scell Configuration
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${nwslice}    ${cell_id}=1
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue    ue_id=${ue_id}    cell=${cell_id}    enb=2
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=${nwslice}

Verify Successful VoNR Establishment On ICS
    Verify Tcpdump Log     ${F1AP_FIVEQI1_AND_FIVEQI5_SETUP_ON_ICS}
    Verify Tcpdump Log     ${E1AP_FIVEQI1_AND_FIVEQI5_SETUP}

Verify No Carrier Aggregation Configured For UE
    Verify Tcpdump Log     packet_filter=${CARRIER_AGGREGATION_SCELL_CONFIGURATION_FAILURE}    number_of_messages=1

Activate And Check If Xp Link is active
    Sleep    5s
    Execute Egate Command    cmd=enb_xp_param id=2 xp_peers=1
    Sleep    1s
    ute_wtssim.execute egate command and wait for data    cmd=enb_xp_link_up enb=2 target=1
    ...                                                   pass_regexp=XpAP Link .* is up   timeout=600
    # sometimes the link falls, and come back again after 4-5 seconds, so we add a sleep here
    Sleep    10s
    Log to console  \n***Activate eNBSim with XpAp interface completed ***

Proceed with DSS Activation Script
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Log to console  \n***Activate eNBSim with XpAp interface completed ***
    Log to console  \n***DSS activation script started ***
    Execute Egate Command    cmd=script file=${CURDIR}/config/5GC001167-F/dss_start.cfg
    Log to console  \n***DSS activation script completed ***
    Check Cell Sibs On Rrc    number_of_cells=3

Proceed with DSS Activation Script With Extended Timer For SIB Reception
    Log to console  \n***Activate eNBSim with XpAp interface completed ***
    Log to console  \n***DSS activation script started ***
    Execute Egate Command    cmd=script file=${CURDIR}/config/5GC001167-F/dss_start.cfg
    ...   fail_regexp=DSS_SETUP_FAILURE Not matching cell Ids - NR DSS Setup Req not received yet   timeout=120
    Log to console  \n***DSS activation script completed ***
    Check Cell Sibs On Rrc Extended Timer   number_of_cells=3

Add Additional Interfaces
    Run		command=sudo ifconfig eth3:EPCsim 10.0.1.10/24 up
    Run		command=sudo ifconfig eth3:simeNB 10.0.1.11/24 up
    Run		command=sudo ifconfig eth3:CRMsim 10.0.1.200/24 up

Perform And Verify Successful Stepwise VoNR Establishment
    Start Tcpdump On Remote Interface    alias=vonr_bearer    log_filename_prefix=vonr_bearer_remote    log_dirpath=${OUTPUT_DIR}/tshark
    Wait For Rrc Mesg Capturing
    Establish VoNR Qosflow    ue_id=1    qosflows=2
    Wait For Rrc Mesg Capturing
    Establish VoNR Qosflow    ue_id=1    qosflows=3
    Wait For Rrc Mesg Capturing
    Stop Tcpdump On Remote Interface
    Verify Tcpdump Log     ${E1AP_FIVEQI5_SETUP}    alias=vonr_bearer    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_bearer_remote.pcap
    Verify Tcpdump Log     ${F1AP_FIVEQI5_SETUP}    alias=vonr_bearer    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_bearer_remote.pcap
    Verify Tcpdump Log     ${E1AP_FIVEQI1_SETUP}    alias=vonr_bearer    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_bearer_remote.pcap
    Verify Tcpdump Log     ${F1AP_FIVEQI1_SETUP}    alias=vonr_bearer    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_bearer_remote.pcap

Perform And Verify Successful Stepwise VoNR Release
    Start Tcpdump On Remote Interface    alias=vonr_bearer_del    log_filename_prefix=vonr_bearer_del_remote    log_dirpath=${OUTPUT_DIR}/tshark
    Wait For Rrc Mesg Capturing
    Delete VoNR Qosflow    ue_id=1    qosflows=3
    Wait For Rrc Mesg Capturing
    Delete VoNR Qosflow    ue_id=1    qosflows=2
    Verify Tcpdump Log     ${E1AP_FIVEQI5_RELEASE}    alias=vonr_bearer_del    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_bearer_del_remote.pcap
    Verify Tcpdump Log     ${F1AP_FIVEQI5_RELEASE}    alias=vonr_bearer_del    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_bearer_del_remote.pcap
    Verify Tcpdump Log     ${E1AP_FIVEQI1_RELEASE}    alias=vonr_bearer_del    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_bearer_del_remote.pcap
    Verify Tcpdump Log     ${F1AP_FIVEQI1_RELEASE}    alias=vonr_bearer_del    pcap_file_path=${OUTPUT_DIR}/tshark/vonr_bearer_del_remote.pcap
    Stop Tcpdump On Remote Interface

Wait For Rrc Mesg Capturing
    Sleep    ${RRC_MESG_CAPTURING_TIMER}

Reboot Tl Via Pdu
    taf.hw.pdu.Setup Pdu    model=${PDU_MODEL}    host=${PDU_IP}    alias=testline_pdu
    taf.hw.pdu.Power Off    port=${PDU_PORT_AP}    pdu_device=testline_pdu
    Sleep    3s
    taf.hw.pdu.Power On    port=${PDU_PORT_AP}    pdu_device=testline_pdu
    Sleep    3s
    taf.hw.pdu.Power Off    port=${GNB_PDU_PORT}    pdu_device=testline_pdu
    Sleep    3s
    taf.hw.pdu.Power On    port=${GNB_PDU_PORT}    pdu_device=testline_pdu

Disable L1Bypass
    Run    ssh toor4nsn@192.168.255.1 "echo tag -fd app.btsom.nts.L1BypassMap | nc 127.0.0.1 15007"

Wait For Environment To Stabilize
    Sleep    180s

Prepare Test Environement And Reach Onair With Retry
    [Arguments]    ${iphy_xml}    ${scfc}    ${egate_cfg}    ${cell_number}    ${disablel1bypass}
    ...    ${number_of_retries}=4
    FOR    ${i}    IN RANGE    ${number_of_retries}
          ${setup_state}=    Run Keyword And Return Status    Prepare Test Environement And Reach Onair
    ...				iphy_xml=${iphy_xml}
    ...				scfc=${scfc}
    ...             egate_cfg=${egate_cfg}
    ...             cell_number=${cell_number}
    ...             disablel1bypass=${disablel1bypass}
          Exit For Loop If    ${setup_state} == ${true}
          Run Keyword If    ${i} == ${number_of_retries}-1    Fail
          Run keyword and ignore error   Stop Default Logging
          Run keyword and ignore error   Stop And Collect Wts Logs
          Run keyword and ignore error   Compress Test Logs
    END

Prepare Test Environement And Verify Ngap Link Up With Retry
    [Arguments]    ${iphy_xml}    ${scfc}    ${egate_cfg}    ${disablel1bypass}
    ...    ${number_of_retries}=4
    FOR    ${i}    IN RANGE    ${number_of_retries}
          ${setup_state}=    Run Keyword And Return Status    Prepare Test Environement And Verify Ngap Link Up
    ...				iphy_xml=${iphy_xml}
    ...				scfc=${scfc}
    ...             egate_cfg=${egate_cfg}
    ...             disablel1bypass=${disablel1bypass}
          Exit For Loop If    ${setup_state} == ${true}
          Run Keyword If    ${i} == ${number_of_retries}-1    Fail
          Run keyword and ignore error   Stop Default Logging
          Run keyword and ignore error   Stop And Collect Wts Logs
          Run keyword and ignore error   Compress Test Logs
    END
