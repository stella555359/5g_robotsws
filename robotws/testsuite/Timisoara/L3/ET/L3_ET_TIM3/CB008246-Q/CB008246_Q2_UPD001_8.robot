*** Settings ***
Documentation     TCs
#Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...           CONFIGURED    CRT    RAN_5G    SBTS00
#...           NoResUsage
#
#Resource     CB008246_Variables_and_Keywords.robot
#Resource     CB008246_Keywords.robot
#Resource     ../resources/5G_SW_WRO_Keywords.robot
#Resource     CB008225_1_Keywords.robot
##Resource     ../TransRob/TransRob_Variables_Keywords.robot
#
#Suite Setup    Run Keywords     Get VM Password
#...            AND              Setup Custom IPHY   iphy=${custom-iphy}
#...            AND              log to console    Vm Ethernet Interfaces
#...            AND              CB008246_Variables_and_Keywords.Start Vm Ethernet Interfaces
#...            AND              Setup Custom SCF    scf=${custom-scf8246}
#...            AND              Reach Onair    lua_cfg=${CURDIR}/config/wts_withDyn.lua
#...            AND              Start Xn And Ng Interfaces For Second Gnb
#...            AND              Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
#
#Test Setup     Start Default Logging   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#
#Test Teardown   Stop Default Logging     output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
#
#Suite Teardown    Run Keywords      log to console    Wait until AirPhone is ready to gather logs
#...               AND               Sleep    200s
#...               AND               Stop Default Processes And Gather Logs And Compress Logs
##...               AND               Send Full Commissioning    input_filepath=/home/ute/testline_init_results/configs/scfc.xml
#
#*** Variables ***
#${REPEAT_COUNTER}  1  # Number of cycles to perform
#${SUSPEND}    nr-rrc.suspendConfig_element
#
#*** Test Cases ***
#8_CB008246_Q2_UPD001_Link_adaptation_HR_DRB_interworking_with_RRC_INACTIVE_CONNECTED_state_transition_DynamicBetaoffsets_configured
#    [Documentation]        gNB configures UE with qam64lowSE mcs-Table specific semistatic betaoffsets in UCI-onPUSCH IE
#    ...                    per [5G_CP_ARC_ALG_2594] when DynamicBetaoffsets is configured
#    log to console    Start TTI Traces in Streaming mode
#    Start TTI Traces in Streaming mode
#    sleep    1s
#    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
#        Set Test Variable  ${CYCLE}  ${INDEX}
#        Log  ==============================================================================  console=True
#        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
#        Log  ==============================================================================  console=True
#        log to console    Set AMF To Send CNAI
#        Set AMF To Send CNAI IE In UE Initial Context Setup Request    command=${SET_AMF_TO_SEND_CNAI_IE_IN_UE_ICS_REQ_EGATE_CMD_MNC_489_UE${INDEX}}
#        log to console    ue_nr_rrc_resume ue_id=${INDEX}
#        ue_nr_rrc_resume    ue_id=${INDEX}
#        sleep    1s
#        log to console    Set PDU Param Internal Traffic
#        Set PDU Param Internal Traffic    ue_id=${INDEX}    pdu_id=${INDEX}
#        sleep    1s
#        log to console    Attach UE
#        Attach UE    ue_id=${INDEX}
#        sleep    1s
#        log to console    Establish PDU Session
#        Establish PDU Session    ue_id=${INDEX}    pdu_id=${INDEX}    gw_id=${INDEX}
#        log to console    Establish PDU Session
#        sleep    1s
#        Modify QOS    ue_id=${INDEX}    pdu_id=${INDEX}
#        log to console     Modify QOS ue_id=${INDEX} pdu_id=${INDEX}
#        sleep    1s
#        Start Data Traffic For 1 PDU    ue_id=${INDEX}
#        log to console     Start Data Traffic For 1 PDU     ue_id=${INDEX}    pdu_id=${INDEX}
#        log to console    sleep 2s
#        sleep    2s
#        Check Data Traffic    ue_id=${INDEX}    pdu_id=${INDEX}    qfi_id=3    dir=dl    throughput=5    marg=4
#        log to console    Check Bearer Stats Traffic
#        sleep    1s
#        Stop Data Traffic For 1 PDU     ue_id=${INDEX}
#        log to console     Stop Data Traffic For 1 PDU      ue_id=${INDEX}    pdu_id=${INDEX}
#        log to console    Wait For RRC RELEASE WITH SUSPEND UE 65s
#        Verify Tshark For At Least Given Number Of Messages
#    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${SUSPEND}    number_of_messages=${INDEX}    timeout=65
#        Start Data Traffic For 1 PDU    ue_id=${INDEX}
#        log to console     Start Data Traffic For 1 PDU
#        log to console    sleep 2s
#        sleep    2s
#        log to console  Check Data Traffic
#        Check Data Traffic    ue_id=${INDEX}    pdu_id=${INDEX}    qfi_id=3    dir=dl    throughput=5    marg=4
#        Deregister Ue Without Confirmation    ue_id=${INDEX}
#        log to console     Sleep 20s
#        sleep    2s
#        log to console    verify tcpdump 64qamLowSe
#        Verify tcpdump    ue=1    packet_filter=${64qamLowSe}    cell_id=1    number_of_messages=6
#        log to console    verify tcpdump DynBetaOffset
#        Verify tcpdump    ue=1    packet_filter=${DynBetaOffset}    cell_id=1    number_of_messages=6
#    END
#    log to console  Stop TTI Traces in Streaming mode
#    Stop TTI Traces in Streaming mode    tti_trace_path=${OUTPUT_DIR}/${TEST_NAME}/tshark
#    log to console  Convert TTI trace from pcap to excelCsv
#    Convert TTI trace from pcap to excelCsv     input_file_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/ttitrace_streaming.pcap
#    ...                                         output_file_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/tti
#    log to console    Check msg in TTI-csv logs  QAM64LOWSE and HIGHRELIABILITY
#    ${counter1}    ${counter2}    Check msg in TTI logs for 1 cycle  QAM64LOWSE    HIGHRELIABILITY
#    log to console    QAM64LOWSE: ${counter1}
#    log to console    HIGHRELIABILITY: ${counter2}
#
