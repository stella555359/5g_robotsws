*** Settings ***
Documentation     File containing keywords used by CB013708 test suite
...               2025-02-03    - riyad.ferrag@nokia.com      - File Creation

Library           OperatingSystem
Library           BuiltIn
Library           String
Library           taf.collectors.btslog                                     WITH NAME    btslog
Library           taf.wts.runner                                            WITH NAME    wtsemu
Library           taf.transport.ssh                                         WITH NAME    ssh
Library           taf.config.scf                                            WITH NAME    scf
Library           taf.sbts.oam.coam.admin                                   WITH NAME    sbts_coam
Library           ../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter
Library           ../../../resources/common/TtiTrace/python/ttitrace.py     WITH NAME    nps_ttitraces_tools
Library           ../../../../../resources/SWENG/python/StringTool.py
Library           ../python/verify_pdsch_payload_length.py

Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource          ../../../../../resources/SWENG/robot/CfgFilesTools.robot
Resource          ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/Backup.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../resources/robot/ConfigCollector_Keywords.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../resources/robot/TDD_MultiBW_Keywords.robot

Variables         ../python/Constants.py


*** Variables ***
${TEST_HALTED}       ALERT: Test halted prematurely. Please investigate - test did not complete as expected.
${TEST_COMPLETED}    NOTICE: Test completed. Review results and logs to verify test outcome and any issues.

${PRINT_DEBUG_INFO}             ${True}
${COLLECT_SNAPSHOT}             ${False}
${COLLECT_PCAP}                 ${True}
${COLLECT_TTI}                  ${True}
${COLLECT_BTS_LOG}              ${True}
${COLLECT_PM}                   ${True}
${IS_BTS_LOGGING}               ${False}
${USE_STATIC_UE}                ${True}


${iphy_file_path}          /ffs/run/simmode
${gnb_alias}               gnb_under_test

&{NRCELL1}                 freqBandIndicatorNR=78
...                        gscnOrSsPbchArfcn=${EMPTY}
...                        nrarfcn=636666
...                        refpayloadsize=9000

&{UE1}                     ueid=1
...                        StaticUE=${False}
...                        ue_nr_capabilities=${EMPTY}
...                        Target_cell=${EMPTY}
...                        DL_TP=1
...                        UL_TP=1
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=1
...                        UlExpected=1

&{UE2}                     ueid=2
...                        StaticUE=${True}
...                        ue_nr_capabilities=${EMPTY}
...                        Target_cell=1
...                        DL_TP=1
...                        UL_TP=1
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=1
...                        UlExpected=1

@{UE_LIST}                 ${UE1}   ${UE2}

&{A1}                      NRCELL1=${NRCELL1}
...                        TTI_TRACE_DURATION=5
...                        L1L2_BIP_TRACE_DURATION=5
...                        THROUGHPUT_TOLERANCE_PERCENT=15
...                        UES_IN_TEST=${UE_LIST}
...                        TRAFFIC_DURATION=5
...                        PM_CONSTRAINT_FILE=${CURDIR}/../config/CB013708_Constraints_SR.csv


*** Keywords ***
Update WTS GSCN
    [Arguments]    ${cellid}=1    ${gscn}=1

    Dated log            * * * * Set GSCN=${gscn} for TDD cellid=${cellid} * * * *

    WtsCfgConfig.startSession
    ${oldValue}          getParam        prefix=set_cell id=${cellid}        param=gscn
    replaceValue         prefix=set_cell id=${cellid}
    ...                  param=gscn
    ...                  oldValue=${oldValue}
    ...                  newValue=${gscn}
    Dated log            CFG File modified: gscn value changed for Cell${cellid} from ${oldValue} to ${gscn}

    WtsCfgConfig.stopSession

Update WTS NRARFCN
    [Arguments]    ${cellid}=1    ${nrarfcn}=633000:633000

    Dated log            * * * * Set nrarfcn=${nrarfcn} for TDD cellid=${cellid} * * * *

    WtsCfgConfig.startSession
    ${oldValue}          getParam        prefix=set_cell id=${cellid}        param=nr_arfcn
    replaceValue         prefix=set_cell id=${cellid}
    ...                  param=nr_arfcn
    ...                  oldValue=${oldValue}
    ...                  newValue=${nrarfcn}
    Dated log            WTS CFG File modified: nr_arfcn value changed for Cell${cellid} from ${oldValue} to ${nrarfcn}

    WtsCfgConfig.stopSession

Set UE Serving Cell
    [Arguments]    ${ueid}=1    ${Target_cell}=1
    Dated Log                       * * * * Set UE${ueid} on Cell${Target_cell} * * * *
    WtsCfgConfig.startSession
    ${prefix}            Set variable    set_ue simulated id=${ueid} uec=1 release=
    ${oldValue}          getParam        prefix=${prefix}    param=cell    ignore_comments=True
    replaceValue         prefix=${prefix}    occurrence=${-1}
    ...                  param=cell
    ...                  oldValue=${oldValue}
    ...                  newValue=${Target_cell}
    ...                  ignore_comments=True
    Dated log            ue_id ${ueid} is set to camp on Cell${Target_cell} in basic cfg file
    WtsCfgConfig.stopSession

Set UE Capabilities
    [Arguments]          ${ue_id_used_rc}    ${capa}
    WtsCfgConfig.startSession
    ${oldValue}          getParam           prefix=ue_param id=${ue_id_used_rc}    param=ue_nr_capabilities    ignore_comments=True
    replaceValue         prefix=ue_param id=${ue_id_used_rc}    #occurrence=${-1}
    ...                  param=ue_nr_capabilities
    ...                  oldValue=${oldValue}
    ...                  newValue=${capa}
    ...                  ignore_comments=True
    Dated log            UE id${ue_id_used_rc}: nr_capabilities value changed from ${oldValue} to ${capa}
    WtsCfgConfig.stopSession

Change 3GPP Release for Redcap UE
    [Arguments]    ${ue_id_used_rc}=1
    WtsCfgConfig.startSession
    ${prefix}            Set variable    set_ue simulated id=${ue_id_used_rc} uec
    ${oldValue}          getParam        prefix=${prefix}    param=release    ignore_comments=True
    replaceValue         prefix=${prefix}    #occurrence=${-1}
    ...                  param=release
    ...                  oldValue=${oldValue}
    ...                  newValue=17 red_cap=true
    ...                  ignore_comments=True
    Dated log            Basic cfg file: Set UE 3GPP release 17 with activation of redcap behavior for simulation purposes
    WtsCfgConfig.stopSession

Add PdcpTruncateCmd To CFG File
    [Documentation]      in case of over usage or UEC CPU on huge traffic or under 12bits SN packets traffic,
    ...                  packet trunk like below will help UEC to not cousume a lot of CPU
    ...                  sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100

    Dated Log                       * * * Add PDCP Packet Truncate CMD to WTS cfg file * * *
    ${res}    getIndexUsingParam    prefix=set_uec   paramId=id    paramVal=1
    dated log    ${res}
    WtsCfgConfig.startSession
    ${line_to_search}    Set Variable    set_uec
    ${data2insert}           Set Variable    sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100
    dated log    Prefix look for ${line_to_search}
    dated log    To insert ${data2insert}
    WtsCfgConfig.AddStringBeforeLine    line=${line_to_search}    str=${data2insert}
    WtsCfgConfig.stopSession

# Set UE Parameters
#     [Arguments]      ${ue_id_used_rc}=1    ${capa}=None
#     # ...            ${sim_debug_log_level}=none
#     # ...            ${sim_debug_log_level}=none    ${multibearer}=none    ${isRc}=${False}
#     [Documentation]        Configure the UE using its predefined capabilities

#     Log Detailed Info      Update UE capabilities for UE${ue_id_used_rc}
#     Set UE Capabilities    ${ue_id_used_rc}    ${capa}

#     # Not Needed
#     # Run Keyword if      ${isRc}     Run Keywords
#     # ...                             Log Detailed Info    Modify 3GPP Release from 15 to 17 for Redcap UE ${ue_id_used_rc}
#     # ...        AND                  Change 3GPP Release for Redcap UE     ${ue_id_used_rc}

#     # Run Keyword If     '${APPdcpPacketTrunc}'=='True'      Add PdcpTruncateCmd To CFG File
#     # Set Global Variable    ${APPdcpPacketTrunc}    False

#     # Run Keyword If     '${sim_debug_log_level}'!='none'
#     # ...                 Modify Field in WtsEmu Cfg File     field=sim_debug_log level    value=${sim_debug_log_level}

Modify Basic CFG
    [Documentation]        Update WTS CFG file with test parameters
    [Arguments]

    FOR     ${idx}     IN       @{param.UES_IN_TEST}
            Log Detailed Info   WTS basic.cfg file adaptation for UE=${idx.ueid}

            Run Keyword If      '${idx.Target_cell}'!='${EMPTY}'
            ...                 Set UE Serving Cell
            ...                 ${idx.ueid}
            ...                 ${idx.Target_cell}

            Run Keyword If      '${idx.ue_nr_capabilities}'!='${EMPTY}'
            ...                 Run Keywords
            ...                 Log Detailed Info    Update UE capabilities for UE${idx.ueid}
            ...   AND           Set UE Capabilities     ue_id_used_rc=${idx.ueid}    capa=${idx.ue_nr_capabilities}
    END

    Run Keyword If      ${USE_STATIC_UE}
    ...                 Run Keywords
    ...                 Dated Log       Adding 5QI7 bearer definition to CFG file
    ...   AND           Create Bearer in Cfg File    5qi=7    proto=udp

Iphy Adaptation
    Run Keyword If    not ${isAic}    Run Keywords
    ...                               Dated log                           Update GSCN value into IPHY for cell1
    ...    AND                        WtsXmlConfig.startSession           file=iphy
    ...    AND                        WtsXmlConfig.setTextUsingIndex      //GSCN                ${param.NRCELL1.gscnOrSsPbchArfcn}    1
    ...    AND                        WtsXmlConfig.stopSession            file=iphy
    ...         ELSE                  Dated log                           GSCN value into IPHY for cell1 in case CR is correct by default

Set SCF Params
    [Documentation]        Dedicated KW to use a delta commissioning file
    [Arguments]                   ${deltaScf}         ${gnb_alias}
    Dated Log New Line            * * * * DELTA COMMISSIONING STARTED * * * *
    sbts_coam.connect_to          name=${gnb_alias}
    Dated Log New Line            delta_file=${deltaScf}
    coam_parameter.perform_scf_delta_commission    delta_file=${deltaScf}    connection=${gnb_alias}
    OAM wait available
    sbts_coam.teardown            connection=${gnb_alias}
    Dated Log New Line            * * * * DELTA COMMISSIONING FINISHED * * * *
    Dated Log New Line            * * * * TL RESTART TRIGGERED * * * *
    Restart TL

# Test Line Preparation
#     [Arguments]                     ${param}    ${deltaScf}    ${multibearer}=None
#     # call of Restart TL kw via "Set SCF Params"
#     Critical Step               Modify Basic CFG      multibearer=${multibearer}
#     Run Keyword If              '${param.NRCELL1.gscnOrSsPbchArfcn}'!='${EMPTY}'    Critical Step    Iphy Adaptation
#     step                        Set RAD Params Of CB013708
#     Critical Step               Set SCF Params        ${deltaScf}    ${gnb_alias}

EPCSIM Session Management
    ${alias_epcsim}                      SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable                   ${alias_epcsim}
    Dated Log                            alias_epcsim sur ssh wait For Connect ${alias_epcsim}

# CB013708 Main Scenario
#     [Documentation]                 Generic KW for CB013708 TL Preparation and TC execution
#     [Arguments]                     ${param}    ${deltaScf}
#     Dated Log New Line              TEST STARTED : ${TEST_NAME}
#     Init Sequence                   ${param}
#     Test Line Preparation           ${param}    ${deltaScf}
#     L3 Call Setup
#     # Step                            ID99 validation

CB013708 Main Scenario
    [Documentation]             Generic KW for CB013708 TL Preparation and TC execution
    [Arguments]                 ${param}    ${deltaScf}
    Dated Log New Line          TEST STARTED : ${TEST_NAME}
    Init Sequence               ${param}
    Critical Step               Modify Basic CFG
    Critical Step               Set RAD Params Of CB013708
    Critical Step               Set SCF Params      ${deltaScf}    ${gnb_alias}
    Critical Step               UE Call Setup And Log Capture

CB013708 Capture start
    [Arguments]                     ${step}

    Dated Log New Line              =======> ${step} Capture start

    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_setup}
    ...  AND                        Capture Start                   ${CaptureCore_setup}

    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_attach}
    ...  AND                        Capture Start                   ${CaptureCore_attach}

    Run Keyword If                  "${step}" == "Traff"            Capture Start
    ...                                                             ${CaptureBIP}

Start Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...
    ...     KW starts Btslog on Testpc with log-collector
    ...
    ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...
    ...     *Note:* KW works only on ute-vm
    Dated Log                       * * * * Start Btslog
    Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    ${btslog_collector_name}=   Set Variable    btslog
    btslog.create_btslog_collector
    ...     name=${btslog_collector_name}
    ...     executor=${testpc_ssh_config}
    btslog.setup_collectors    names=${btslog_collector_name}
    btslog.start_collectors    names=${btslog_collector_name}
    btslog.set_suite_alias     ${btslog_collector_name}

    Dated log     =====> Start Btslog
    set Test variable     ${IS_BTS_LOGGING}    True

CB013708 Capture Stop
    [Arguments]                     ${step}
    Dated Log                       =======> ${step} Capture Stop
    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Stop                     ${CaptureCore_setup}
    ...  AND                        Capture Stop                     ${CaptureCPRT_setup}
    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Stop                     ${CaptureCore_attach}
    ...  AND                        Capture Stop                     ${CaptureCPRT_attach}
    Run Keyword If                  "${step}" == "Traff"             Capture Stop
    ...                                                              ${CaptureBIP}

Get Alarms List
    [Arguments]    ${Step}=Beg    ${testCaseDir}=${LOG_PATH}
    Dated log New Line   OAM Get Active Alarms to Save into file
    ${timeStamp}          get current date     result_format=%Y%m%d_%H%M%S
    ${aliasGNB}           OAM Connect                             ${GNB_DU.oam}

    ${active_alarms}      OAM Get Active Alarms                   oam=${GNB_DU.oam}    textFormat=${False}

    ${len}                Get Length                             ${active_alarms}
    ${alarm_id_list}      Create List
    ${alarm_name_list}    Create List
    ${faultId}=           set variable if                        ${isAiC}        fault_id
    ...                                                                          faultId
    ${faultName}=         set variable if                        ${isAiC}        fault_name
    ...                                                                          faultName
    FOR    ${i}           IN RANGE    ${len}
          ${tmp_id}         Get From Dictionary    ${active_alarms[${i}]}    ${faultId}
          ${tmp_name_id}    Get From Dictionary    ${active_alarms[${i}]}    ${faultName}
          Append To List    ${alarm_id_list}    ${tmp_id}
          Append To List    ${alarm_name_list}    ${tmp_name_id}
    # Dated log     Active alarms: alarm_id_list=${alarm_id_list}
    # Dated log     Active alarms: alarm_name_list=${alarm_name_list}
    END
    Append To File        ${testCaseDir}/OAM_Alarms_${Step}_${timeStamp}.txt     Active Alarms Id List:\n${alarm_id_list}\n\n
    Append To File        ${testCaseDir}/OAM_Alarms_${Step}_${timeStamp}.txt     Active Alarms Name List:\n${alarm_name_list}\n\n

    OAM Disconnect        ${GNB_DU.oam}

TTI Trace Start
    [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True    ${targpath}=${LOG_PATH}
    Log Detailed Info    Arguments suffix:${suffix} time:${time} event_nr_max:${event_nr_max} w_convert_pcap_to_excelCsv:${w_convert_pcap_to_excelCsv}
    Log Detailed Info    Arguments targpath:${targpath}
    ${tm}                  Get Current Date
    ${tm}=                 Remove String    ${tm.replace(' ','-')}    .
    Set global variable    ${tm}
    Dated Log              Start TTI Traces in Streaming Mode
    ttitrace.Start TTI Traces in Streaming Mode      filter_bitmap2=0x0

    Traced Sleep    ${time}      msg=Waiting for TTI Traces

TTI Trace Stop
    [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True    ${targpath}=${LOG_PATH}
    Log Detailed Info    Arguments suffix:${suffix} time:${time} event_nr_max:${event_nr_max}
    Log Detailed Info    Arguments w_convert_pcap_to_excelCsv:${w_convert_pcap_to_excelCsv} targpath:${targpath}
    Dated log              Stop TTI Traces in Streaming Mode...
    ${ttiTraceSubDir}      set Variable    TtiTrace-${time}-${tm}
    ${ttiTraceSubDir}      set Variable if    '${suffix}'!='${EMPTY}'     ${ttiTraceSubDir}-${suffix}
    ...                                                                ${ttiTraceSubDir}
    ${tti_trace_path}=     ttitrace.Stop TTI Traces in Streaming Mode    tti_trace_path=${targpath}/${ttiTraceSubDir}
    Dated log              Decode TTI Traces...
    nps_ttitraces_tools.decode_tti_traces_using_TtitraceReaderEvtDec       desired_storage_directory=${targpath}/${ttiTraceSubDir}
    ...                                                                    num_of_events=${event_nr_max}
    run keyword if   '${w_convert_pcap_to_excelCsv}'=='True'    run keywords
    ...               Dated log    Convert TTI trace from pcap to excelCsv...    AND
    ...               Run keyword and continue on failure     ttitrace.Convert TTI trace from pcap to excelCsv     input_file_path=${tti_trace_path}
    ...                                                                    output_file_path=${targpath}/${ttiTraceSubDir}
    [return]     ${targpath}/${ttiTraceSubDir}

ID99 validation
    Log Detailed Info       CaptureBip.name: ${CaptureBip.name}
    Log Detailed Info       LOG_PATH: ${LOG_PATH}
    ${file}=                catenate    ${LOG_PATH}/${CaptureBIP.name}.pcap
    Log Detailed Info       PCAP L1L2 PATH: ${file}
    Dated Log New Line      Extract DlData_PdschSendReq info from BIP L1L2 trace : ${file}

    set test variable       ${pcapprocessed}           CB013708_Pdsch_Payload_Size.csv
    set test variable       ${pcapprocessed_path}      ${LOG_PATH}/${pcapprocessed}

    ${cmd_mcshark}          Catenate    tshark -r
    ...                     ${file}     -T fields -Y "dldata_pdschpayloadtbsendreq"
    ...                     -e _ws.col.Info
    ...                     -e bip.msg.fragment.count
    ...                     -e bip.msg.reassembled.length
    ...                     -E header=y -E separator='/t' > ${pcapprocessed_path}
    Run                      ${cmd_mcshark}

    Run      command=sed -i -e 's/ //g' ${pcapprocessed_path}

    ${thresh}=              Convert To Integer      ${param.NRCELL1.refpayloadsize}
    Dated Log               ===> Verify that L1 PDSCH Payload Size is above 9KB with a maximum set to 64KB
    ${isSuccess}            check_payload_size_above_9kb    ${file}    ${thresh}
    Dated Log New Line      Payload size check status is : ${isSuccess}
    Should Be True          "${isSuccess}" == "True"

Print PM Measurements
    [Documentation]   Display PM Measurements
    [Arguments]       ${CellID}=1

    ${M55301C20035}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_PM_FILES}    M55301C20035    ${CellID}
    ${M55308C10001}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_PM_FILES}    M55308C10001    ${CellID}
    ${M55308C10002}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_PM_FILES}    M55308C10002    ${CellID}

    Dated Log         ---------------------------------------------------COUNTERS & KPIs----------------------------------------------------
    Dated Log         M55308C34013 - CQI-15 Histogram when UE reports related to 256QAM table..............................: ${M55301C20035}
    Dated Log         M55308C10001 - Number of used PRBs for PDSCH.........................................................: ${M55308C10001}
    Dated Log         M55308C10002 - Number of used PRBs for PUSCH.........................................................: ${M55308C10002}
    Dated Log         ----------------------------------------------------------------------------------------------------------------------

PM Counters Collection and KPI Evaluation
    [Documentation]                 Wait for a Zone Of Interest for counters files collection
    [Arguments]                     ${PM_COUNTER_DIR}

    ${zoi}                          ZOI Start

    Dated log New Line              Retrieve the most recent Performance Monitoring (PM) counter files for analysis and validation.
    ZOI Wait End                    zoi=${zoi}
    ${LATEST_PM_FILES}              Counters.Collect PM files from BTS    ${PM_COUNTER_DIR}
    set Suite Variable              ${LATEST_PM_FILES}
    Dated Log                       The PM counters file collected from gnb are stored under : ${LATEST_PM_FILES}
    KPI Evaluate                    pmFile=${LATEST_PM_FILES}
    ...                             constraintsFile=${param.PM_CONSTRAINT_FILE}
    ...                             failOnError=${True}

    Print PM Measurements           CellID=1

UE Call Setup And Log Capture

    ${alias_epcsim}                      SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable                   ${alias_epcsim}
    Dated Log                            alias_epcsim sur ssh wait For Connect ${alias_epcsim}

    # Start Bts logs
    Run Keyword If      ${COLLECT_BTS_LOG}            Start Btslog

    # Get Current Alarm list
    Get Alarms List    start    ${logsDir}

    #                                        Capture during Cell Setup
    Run Keyword If      ${COLLECT_PCAP}              CB013708 Capture start    cellSetup
    Critical Step                                    CallSetup.Setup Wtsemu SA

    #                                        Capture during UE Attach
    Run Keyword If      ${COLLECT_PCAP}              CB013708 Capture start    Attach
    FOR     ${idx}     IN                            @{param.UES_IN_TEST}
            Critical Step                            CallSetup.UE Register              ue=${idx.ueid}
            Critical Step                            CallSetup.Launch PDU Session       ue=${idx.ueid}    pdu=${idx.pdu}
            Run Keyword If      ${idx.StaticUE}      CallSetup.UE PDU Session Modify    ue=${idx.ueid}    pdu=${idx.pdu}    qfta=4
    END
    #Stop pcap capture for cell setup and ues attach
    Run Keyword If      ${COLLECT_PCAP}              Run Keywords       CB013708 Capture Stop     Attach
    ...                                              AND                CB013708 Capture Stop     cellSetup

    #                                        TRAFFIC Start
    FOR     ${idx}     IN                            @{param.UES_IN_TEST}
            Log Detailed Info                        TRAFFIC for UE=${idx.ueid} - pdu number ${idx.pdu}

            FTS_trfxl                                ue=${idx.ueid}     pdu=${idx.pdu}    qfi=1    mbps=${idx.UL_TP}      dir=ul
            FTS_trfxl                                ue=${idx.ueid}     pdu=${idx.pdu}    qfi=1    mbps=${idx.DL_TP}      dir=dl

    END

    #                                        BIPL1L2 Capture
    Run Keywords                                     Dated log                  L1L2 Bip Trace Duration: ${param.L1L2_BIP_TRACE_DURATION}s
    ...       AND                                    CB013708 Capture Start     Traff
    ...       AND                                    Sleep                      ${param.L1L2_BIP_TRACE_DURATION}s
    ...       AND                                    CB013708 Capture Stop      Traff

    #                                        TTI Capture
    Run Keyword If       ${COLLECT_TTI}              TTI Trace Start
    ...                                              time=${param.TTI_TRACE_DURATION}    w_convert_pcap_to_excelCsv=False    targpath=${TTI_logdir}
    Traced Sleep                                     1s     traffic TP tti collection
    Run Keyword If       ${COLLECT_TTI}              TTI Trace Stop                   suffix=TTI_underTraffic
    ...                                              time=${param.TTI_TRACE_DURATION}    w_convert_pcap_to_excelCsv=False    targpath=${TTI_logdir}

    Run Keyword If       ${COLLECT_PM}       Run Keywords
    ...    Sleep    60s    reason=Wait time before PM Counters Collection and analysis
    ...    AND      PM Counters Collection and KPI Evaluation    PM_COUNTER_DIR=${LOG_PATH}/PM

Set RAD Params Of CB013708
    [Documentation]     Add or Modify the RAD params Of CB013708

    Dated Log New Line   Add RAD parameters Of CB013708

    dated log    -----> field=0x5809bb value=50 - rdCsiReportSkippingPercent
    dated log    -----> field=0x5809bc value=2 - rdRrcUesHighThresholdForPeriodicCsiLoadReduction
    dated log    -----> field=0x5809bd value=2 - rdRrcUesLowThresholdForPeriodicCsiLoadReduction
    dated log    -----> field=0x5809be value=300 - rdMinIdlePeriodForCsiLoadReduction

    ${rad_param_1}=       create dictionary    field=0x5809bb    value=50
    ${rad_param_2}=       create dictionary    field=0x5809bc    value=2
    ${rad_param_3}=       create dictionary    field=0x5809bd    value=2
    ${rad_param_4}=       create dictionary    field=0x5809be    value=300
    ${rad_param_list}=    Create List          ${rad_param_1}
    ...                                        ${rad_param_2}
    ...                                        ${rad_param_3}
    ...                                        ${rad_param_4}

    SetConfig.Set Fields in swconfig DU        param_list=${rad_param_list}
    Dated Log New Line   RAD parameters of CB013708 update completed

CB013708 Test Teardown
    [Documentation]    Perform needed actions at the end of a test case

    Dated log New Line    Test Teardown : S T A R T

    Run Keyword And Ignore Error    Produce Scout Data

    Run Keyword If Test Failed      Dated Log New Line   ${TEST_HALTED}      level=WARN
    Run Keyword If Test Passed      Dated log New Line   ${TEST_COMPLETED}   level=INFO

    Collect Configuration Files
    Get Alarms List                end             ${logsDir}

    Dated log New Line    COLLECT_SNAPSHOT: ${COLLECT_SNAPSHOT}

    Run Keyword If        ${IS_BTS_LOGGING}      Stop Btslog      ${logsDir}
    Run Keyword If        ${COLLECT_SNAPSHOT}   Collect Snapshots

    CallSetup.Flush Egate Console Buffer

    ${cmd}                set variable    cp -p ${tl.core.dir_path}/egate_console.* ${logsDir}
    Dated Log             Running command : ${cmd}
    SSH Exec              command=${cmd}          alias=${alias_epcsim}

    SSH Exec              mv ${LOG_PATH}/*.pcap ${logsDir}               alias=${alias_epcsim}

    Run Keyword If        ${IS_BTS_LOGGING}
    ...                   Run Keyword And Ignore Error
    ...                   SSH Exec       cp -rp ${LOG_PATH}/l2stream3 ${logsDir}    alias=${alias_epcsim}

    Dated log New Line    Test Teardown : E N D
    Display diagnosis

CB013708 Test Suite Teardown
    [Documentation]       Suite Teardown for CB013708
    setup.Suite Teardown

Collect Snapshots
    Dated log       Collect Snapshots
    Run Keywords        Get Snapshot
    ...         AND     SSH Exec    mv ${LOG_PATH}/SNAPSHOT_GNB*.zip ${logsDir}    alias=${alias_epcsim}
    ...         AND     Get Sos Report
    ...         AND     SSH Exec    mv ${HOME}/SosReport*.tgz ${logsDir}           alias=${alias_epcsim}


Create Test Suite Folder
    [Documentation]     CB013708 Create test case folder

    ${timeStamp}     get current date       result_format=%Y%m%d_%H%M%S

    ${testCase}    Replace String    ${TEST_NAME[0:30]}    ${SPACE}    _
    ${testCase}    Replace String    ${testCase}    .    _
    ${testCase}    Remove String     ${testCase}    [1]
    ${testCase}    Remove String     ${testCase}    [1.0]
    ${testCase}    Remove String     ${testCase}    [2.0]
    ${testCase}    Remove String     ${testCase}    [
    ${testCase}    Remove String     ${testCase}    ]

    Set Suite Variable    ${testcase}
    Set Suite Variable    ${testSuiteDir}    ${OUTPUT DIR}/Logs/${testCase}_${timeStamp}

    create directory      ${testSuiteDir}

    Set Suite Variable    ${ConfigDir}        ${testSuiteDir}/ConfigFiles
    Create Directory      ${ConfigDir}
    Set Suite Variable    ${logsDir}          ${testSuiteDir}/TestLogs
    Create Directory      ${logsDir}
    Set Suite Variable    ${TTI_logdir}       ${logsDir}/TTIlogs
    Set suite Variable    ${TTI_logdir}


Backup SCF File
    [Documentation]                 Save the current SCF
    [Arguments]    ${dir}=${LOG_PATH}
    ${timeStamp}       get current date     result_format=%Y%m%d_%H%M%S
    ${g_backup_scf}    OAM Get SCF File    dir=${dir}    file=SCF_test_backup_${timeStamp}.xml
    Set Suite Variable    ${g_backup_scf}
    Dated Log    SCF backup file = ${g_backup_scf}
    ${g_backup_scf_cu}    Run Keyword If    ${isAic}    OAM Get Cu SCF File    dir=${dir}    file=SCF_backup_original_cu_${timeStamp}.xml
    Run Keyword If    ${isAic}    Run Keywords    Set Suite Variable    ${g_backup_scf_cu}
    ...    AND    Dated Log    SCF cu backup file = ${g_backup_scf_cu}

Collect Configuration Files
    [Documentation]                 Save current scf/iphy/swconfig/basic files used for the test in ${testSuiteDir}
    Dated Log New Line              Collect Configuration Files
    Backup SCF File       ${ConfigDir}
    Backup Files FTS      ${FD_ALL}           ${ConfigDir}

    # Previous KW collected only the original .cfg, not the cfg modified by the test. Correction:
    SSH Exec              rm ${ConfigDir}/*.cfg         alias=${alias_epcsim}
    ${cmd}                set variable    cp -p ${tl.core.dir_path}/${tl.core.cfg_filename} ${ConfigDir}/${tl.core.cfg_filename}
    Dated Log             ${cmd}
    SSH Exec              ${cmd}                        alias=${alias_epcsim}

Init Trace Color
    ${consTraceColor}               Evaluate                    "${CYAN}"
    ${consTraceColorRed}            Evaluate                    "${RED}"
    ${defColor}                     Evaluate                    "${NORMAL}"
    Set Suite Variable              ${consTraceColor}
    Set Suite Variable              ${consTraceColorRed}
    Set Suite Variable              ${defColor}

Capture Session Initialization
    Dated Log New Line              * * * Init Capture Session

    ${CaptureCPRT_setup}            Capture CPRT Set Upon Config     airscale=${GNB_DU}
    ${CaptureCPRT_setup.filter}     Get Filter For SCTP
    Capture Init                    ${CaptureCPRT_setup}             withTN=False             suffix=_setup

    ${CaptureCore_setup}    Run Keyword If    ${isAic}
    ...                                         Capture CORE Set Upon Config    airscale=${GNB_CU}
    ...                                 ELSE    Capture CORE Set Upon Config    airscale=${GNB_DU}
    Capture Init                    ${CaptureCore_setup}             withTN=False             suffix=_setup

    ${CaptureBIP}                   Capture L1L2 Set Upon Config    airscale=${GNB_DU}
    Capture Init                    ${CaptureBIP}                   withTN=False

    Set Suite Variable              ${CaptureCPRT_setup}
    Set Suite Variable              ${CaptureCore_setup}
    Set Suite Variable              ${CaptureBIP}

    ${CaptureCPRT_attach}           Capture CPRT Set Upon Config     airscale=${GNB_DU}
    ${CaptureCPRT_attach.filter}    Get Filter For SCTP
    Capture Init                    ${CaptureCPRT_attach}            withTN=False              suffix=_attach_

    ${CaptureCore_attach}    Run Keyword If    ${isAic}
    ...                                          Capture CORE Set Upon Config    airscale=${GNB_CU}
    ...                                  ELSE    Capture CORE Set Upon Config    airscale=${GNB_DU}
    Capture Init                    ${CaptureCore_attach}            withTN=False              suffix=_attach_

    Set Suite Variable              ${CaptureCPRT_attach}
    Set Suite Variable              ${CaptureCore_attach}

Stop Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop and fetch btslog from Testpc
    ...
    ...    *Note:* KW works only on ute-vm
    ...    :return path: Path to btslog file
    ...
    ...    :param target_dir: Directory to store the btslog file
    ...
    [Arguments]    ${target_dir}=None
    Dated Log                       *** Stop Btslog
    Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud

    ${btslog_collector_name}=   Set Variable    btslog
    btslog.stop_collectors         names=${btslog_collector_name}
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    Builtin.Sleep   15 sec      # wait for btslog to close
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors     names=${btslog_collector_name}
    [RETURN]    ${target_dir}/${btslog_collector_name}/syslog_files.tgz

FTS_trfxl
    [Documentation]    A sub-keyword of Traffic KW responsible for starting traffic.
    ...                Handles up to 3500 Mbps in DL with 175 Mbps per trf_id.
    ...                egate limits to 20 trf_ids, giving a theoretical max of 3500 Mbps on DL.
    ...                Records the last trf_id used.
    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${mbps}=22    ${dir}=dl
    Log Detailed Info    Arguments: ue=${ue}, pdu=${pdu}, qfi=${qfi}, mbps=${mbps}, dir=${dir}

    Dated log   Args_trf: ue=${ue}, pdu=${pdu}, qfi=${qfi}, mbps=${mbps}

    ${trfid}    Set Variable    1
    FOR    ${i}    IN RANGE    9999999
        Dated log   Starting traffic for trf_id: ${trfid}

        ${complement}    Evaluate    ${mbps} - 175    # 175 is the maximum DL throughput per trf_id
        Run Keyword If    ${complement} > 0 and ${mbps} >= 175
        ...               wtsemu.trf_data_start    ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    trf_id=${trfid}    mbps=175
        ...    ELSE IF    ${mbps} > 0 and ${mbps} <= 175
        ...               wtsemu.trf_data_start    ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=${dir}    trf_id=${trfid}    mbps=${mbps}
        ...    ELSE       Exit For Loop

        ${mbps}    Set Variable    ${complement}
        ${trfid}   Evaluate    ${trfid} + 1

        Run Keyword If    ${trfid} > 19    Exit For Loop    # Max trf_id is 20

        Sleep    5s    # Slow down traffic start to prevent overload
    END

Log Detailed Info
    [Documentation]    This KW will help on non regression to see deeper informations
    ...                ${PRINT_DEBUG_INFO} need to be set to True at the begining of this file
    [Arguments]        ${SomethingToTrace}=none

    Run Keyword If     ${PRINT_DEBUG_INFO}    Dated Log   Debug >>>>>>>>>>: ${SomethingToTrace}
