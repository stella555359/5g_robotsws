*** Settings ***

Documentation     File containing keywords used by CB012979 test suites to test -H ID99
...               2024-10-15    - riyad.ferrag@nokia.com      - File Creation

Library           OperatingSystem
Library           String
Library           taf.collectors.btslog                                     WITH NAME    btslog
Library           taf.wts.runner                                            WITH NAME    wtsemu
Library           ../../../resources/common/TtiTrace/python/ttitrace.py     WITH NAME    nps_ttitraces_tools
Library           taf.config.scf                                            WITH NAME    scf
Library           taf.sbts.oam.coam.admin                                   WITH NAME    sbts_coam
Library           ../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter
Library           taf.transport.ssh                                         WITH NAME    ssh
Library           ../python/verify_pdsch_payload_length.py
Library           BuiltIn
Library           ../../../../../resources/SWENG/python/StringTool.py

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

${userneed_PCAP}                 False
${userneed_TTI}                  False
${userneed_Btslog}               False
${userneed_TPcheck}              False

# following to manage end of collect
${BtsLogStarted}                 False
${save_debug_data}               False

# 12979_Set_RedcapRel17_And_Options KW use this variable
${bearer_set_allreadyDone}       False

# miscelaneous
${iphy_file_path}                /ffs/run/simmode

# Riyad - addition
${gnb_alias}                     gnb_under_test
${APPdcpPacketTrunc}             False

&{NRCELL1}                 freqBandIndicatorNR=78
...                        gscnOrSsPbchArfcn=${EMPTY}
...                        nrarfcn=636666
...                        refpayloadsize=9000

&{rd_param_12979}          address=0x81002D
...                        value=1

# Riyad - modification
&{UE1_legacy}              ueid=1
...                        isRc=${False}
...                        Rx=4
...                        ue_nr_capabilities=${EMPTY}
...                        Target_cell=${EMPTY}
...                        DL_TP=1750
...                        UL_TP=175
...                        Last_trfid_used=0
...                        pdu=1

# To be deleted
# ...                        DlExpected=50
# ...                        UlExpected=20

@{uelist1}                 ${UE1_legacy}

&{A1}                      NRCELL1=${NRCELL1}
...                        twoUEonSameCell=${False}
...                        GetTtiTraceTime=1
...                        deviation_in_percent=15
...                        ListOfUeEngaged=${uelist1}
...                        TrafficDuration=5
...                        miNrDlSignalQuality=5min
...                        rdMaxPdschPayloadSize=${rd_param_12979}
...                        PMdod=${CURDIR}/../config/CB012979_Constraints_SR.csv

*** Keywords ***
12979_update_wtscfg_gscn
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

12979_update_wtscfg_nrarfcn
    [Arguments]    ${cellid}=1    ${nrarfcn}=633000:633000

    Dated log            * * * * Set nrarfcn=${nrarfcn} for TDD cellid=${cellid} * * * *

    WtsCfgConfig.startSession
    ${oldValue}          getParam        prefix=set_cell id=${cellid}        param=nr_arfcn
    replaceValue         prefix=set_cell id=${cellid}
    ...                  param=nr_arfcn
    ...                  oldValue=${oldValue}
    ...                  newValue=${nrarfcn}
    Dated log            CFG File modified: nr_arfcn value changed for Cell${cellid} from ${oldValue} to ${nrarfcn}

    WtsCfgConfig.stopSession

12979_Set_UE_serving_cell
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

12979_Set_UE_capa
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

12979_Set_Redcap_3gppRel17
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

12979_Add_PdcpTruncateCmd_WTSCFG
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

12979_Set_UE_Params
    [Arguments]    ${infra}=SA    ${ue_id_used_rc}=1    ${capa}=None
    ...            ${sim_debug_log_level}=none    ${multibearer}=none    ${isRc}=${False}
    [Documentation]        3 steps on this KW
    ...                    step 1\   setting ue_nr_capabilities
    ...                    step 2\   set_ue simulated id=1 uec=1 >release=17 red_cap=true<
    ...                    step 3\   specific basic design according arguments
    ...                    step 4\   Set UE1 on Cell1
    ...                    step 5\   Add below command to cfg file:
    ...                               sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100

    #step 1
    DdatedLog_12979      Update UE capabilities for UE${ue_id_used_rc}
    12979_Set_UE_capa    ${ue_id_used_rc}    ${capa}

    #step 2
    Run Keyword if      ${isRc}     Run Keywords
    ...                             DdatedLog_12979     Modify 3GPP Release from 15 to 17 for Redcap UE ${ue_id_used_rc}
    ...        AND                  12979_Set_Redcap_3gppRel17        ${ue_id_used_rc}

    #step 3
    Run Keyword If     '${APPdcpPacketTrunc}'=='True'      12979_Add_PdcpTruncateCmd_WTSCFG
    Set Global Variable    ${APPdcpPacketTrunc}    False

    Run Keyword If     '${sim_debug_log_level}'!='none'
    ...                 Modify Field in WtsEmu Cfg File     field=sim_debug_log level    value=${sim_debug_log_level}

    DdatedLog_12979     multibearer >${multibearer}< bearer_set_allreadyDone >${bearer_set_allreadyDone}<
    Run Keyword If      ${multibearer} and not ${bearer_set_allreadyDone}
    ...                 Run Keywords
    ...                 Dated Log  -- B E A R E R - C R E A T I O N --
    ...   AND           Create Bearer in Cfg File    5qi=7    proto=udp
    ...   AND           Create Bearer in Cfg File    5qi=8    proto=udp
    ...   AND           Create Bearer in Cfg File    5qi=9    proto=udp
    ...   AND           Create Bearer in Cfg File    5qi=2    proto=udp

    ${bearer_set_allreadyDone}=    Set Variable    ${True}   #already done
    Set Global Variable    ${bearer_set_allreadyDone}

# Modify gscn in wts cfg file, set ue serving cell & WTS CFG Params - no TL restart at this step
12979_WTSCFG Adaptation
    [Arguments]    ${multibearer}=None    ${targcell}=None

    ${multibearer}=    set Variable if    '${multibearer}'!='None'    ${multibearer}    ${False}

    Run Keyword If      '${param.NRCELL1.gscnOrSsPbchArfcn}'!='${EMPTY}'
    ...                 12979_update_wtscfg_gscn    cellid=1    gscn=${param.NRCELL1.gscnOrSsPbchArfcn}

    Run Keyword If    ${isAic}    12979_update_wtscfg_nrarfcn    cellid=1    nrarfcn=${param.NRCELL1.nrarfcn}:${param.NRCELL1.nrarfcn}

    FOR     ${idx}     IN                      @{param.ListOfUeEngaged}
            DdatedLog_12979                    basic.cfg adaptation for UE=${idx.ueid}

            Run Keyword If                     '${idx.Target_cell}'!='${EMPTY}'
            ...                                12979_Set_UE_serving_cell
            ...                                ${idx.ueid}
            ...                                ${idx.Target_cell}

            Run Keyword If                     '${idx.ue_nr_capabilities}'!='${EMPTY}'
            ...                                12979_Set_UE_Params
            ...                                infra=SA
            ...                                ue_id_used_rc=${idx.ueid}
            ...                                capa=${idx.ue_nr_capabilities}
            ...                                isRc=${idx.isRc}
            ...                                multibearer=${multibearer}
    END

# Modify gscn in AP iphy.xml file - no TL restart
12979_IPHY_Adaptation
    Run Keyword If    not ${isAic}    Run Keywords
    ...                               Dated log                           Update GSCN value into IPHY for cell1
    ...    AND                        WtsXmlConfig.startSession           file=iphy
    ...    AND                        WtsXmlConfig.setTextUsingIndex      //GSCN                ${param.NRCELL1.gscnOrSsPbchArfcn}    1
    ...    AND                        WtsXmlConfig.stopSession            file=iphy
    ...         ELSE                  Dated log                           GSCN value into IPHY for cell1 in case CR is correct by default

12979_Set SCF Params
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

12979_TL Preparation
    [Arguments]                     ${param}    ${deltaScf}    ${multibearer}=None     ${3fdd}=None
    # call of Restart TL kw via "12979_Set SCF Params" kw
    Critical Step               12979_WTSCFG Adaptation      multibearer=${multibearer}
    Run Keyword If              '${param.NRCELL1.gscnOrSsPbchArfcn}'!='${EMPTY}'    Critical Step    12979_IPHY_Adaptation
    Critical Step               12979_Set SCF Params        ${deltaScf}    ${gnb_alias}

12979_Session Mgmt
    ${alias_epcsim}                      SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable                   ${alias_epcsim}
    Dated Log                            alias_epcsim sur ssh wait For Connect ${alias_epcsim}

CB012979 Main Scenario
    [Documentation]                 Generic KW for CB012979 TL Preparation and TC execution
    [Arguments]                     ${param}        ${deltaScf}
    Dated Log New Line              * * * * TEST STARTED * * * *
    ${TTI_logdir}=                  Set Variable    ${logsDir}/tti
    Set Global Variable             ${TTI_logdir}
    Init Sequence                   ${param}
    # 12979_TL Preparation            ${param}    ${deltaScf}
    12979_Session Mgmt
    12979_L3 Call

12979_Capture start
    [Arguments]                     ${step}

    Dated Log                       * * * * 12979_Capture start

    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_setup}
    ...  AND                        Capture Start                   ${CaptureCore_setup}

    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_attach}
    ...  AND                        Capture Start                   ${CaptureCore_attach}

    Run Keyword If                  "${step}" == "Traff"            Capture Start
    ...                                                             ${CaptureBIP}

12979_Start Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...
    ...     KW starts Btslog on Testpc with log-collector
    ...
    ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...
    ...     *Note:* KW works only on ute-vm
    Dated Log                       * * * * 12979_Start Btslog
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

    Dated log     =====> 12979_Start Btslog
    set Test variable     ${BtsLogStarted}    True

12979_Capture Stop
    [Arguments]                     ${step}
    Dated Log                       * * * * 12979_Capture Stop
    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Stop                     ${CaptureCore_setup}
    ...  AND                        Capture Stop                     ${CaptureCPRT_setup}
    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Stop                     ${CaptureCore_attach}
    ...  AND                        Capture Stop                     ${CaptureCPRT_attach}
    Run Keyword If                  "${step}" == "Traff"             Capture Stop
    ...                                                              ${CaptureBIP}
#    Set Global Variable               ${CaptureBIP.path}   # Not compatible with RF50
    Set Global Variable               ${CaptureBIP}

12979_Alarmslist
    [Arguments]    ${Step}=Beg    ${testCaseDir}=${LOG_PATH}
    Dated log New Line   OAM Get Active Alarms to Save into file
    ${aliasGNB}          OAM Connect                             ${GNB_DU.oam}

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
    Append To File        ${testCaseDir}/OAM_Alarms_${Step}_${TEST_NAME}.txt     Active Alarms Id List:\n${alarm_id_list}\n\n
    Append To File        ${testCaseDir}/OAM_Alarms_${Step}_${TEST_NAME}.txt     Active Alarms Name List:\n${alarm_name_list}\n\n

    OAM Disconnect        ${GNB_DU.oam}

12979_TTI start
    [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True    ${targpath}=${LOG_PATH}
    DdatedLog_12979  Arguments suffix:${suffix} time:${time} event_nr_max:${event_nr_max} w_convert_pcap_to_excelCsv:${w_convert_pcap_to_excelCsv}
    DdatedLog_12979  Arguments targpath:${targpath}
    ${tm}                  Get Current Date
    ${tm}=                 Remove String    ${tm.replace(' ','-')}    .
    Set global variable    ${tm}
    Dated Log              Start TTI Traces in Streaming Mode
    ttitrace.Start TTI Traces in Streaming Mode      filter_bitmap2=0x0

    Traced Sleep    ${time}      msg=Waiting for TTI Traces

12979_TTI stop
    [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True    ${targpath}=${LOG_PATH}
    DdatedLog_12979  Arguments suffix:${suffix} time:${time} event_nr_max:${event_nr_max}
    DdatedLog_12979  Arguments w_convert_pcap_to_excelCsv:${w_convert_pcap_to_excelCsv} targpath:${targpath}
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

12979 TC validation

    Dated Log New Line      ===> CaptureBip.name: ${CaptureBip.name}
    Dated Log New Line      ===> LOG_PATH: ${LOG_PATH}
    ${file}=                catenate    ${LOG_PATH}/${CaptureBIP.name}.pcap
    Dated Log New Line      ===> PCAP L1L2 PATH: ${file}
    Dated Log New Line      Extract DlData_PdschSendReq info from L1L2 PCAP file : ${file}

    set test variable                 ${pcapprocessed}           PdschPayloadSize.csv
    set test variable                 ${pcapprocessed_path}      ${LOG_PATH}/${pcapprocessed}

    ${cmd_mcshark}                    Catenate    tshark -r
    ...                               ${file}     -T fields -Y "dldata_pdschpayloadtbsendreq"
    ...                               -e _ws.col.Info
    ...                               -e bip.msg.fragment.count
    ...                               -e bip.msg.reassembled.length
    ...                               -E header=y -E separator='/t' > ${pcapprocessed_path}
    Run                               ${cmd_mcshark}

    Run      command=sed -i -e 's/ //g' ${pcapprocessed_path}

    ${thresh}=              Convert To Integer      ${param.NRCELL1.refpayloadsize}
    Dated Log               ===> Verify that L1 PDSCH Payload Size is set to 64KB (old value: 9KB)
    ${isSuccess}            check_payload_size_above_9kb    ${file}    ${thresh}
    Dated Log New Line      Payload size check status is : ${isSuccess}
    Should Be True          ${isSuccess} == True

12979_L3 Call
    # Start Bts logs
    Run Keyword If      ${userneed_Btslog} and not ${isAic}    12979_Start Btslog

    # Get Current Alarm list
    12979_Alarmslist     Beg                          ${logsDir}

    #                                        Capture during Cell Setup
    Run Keyword If      ${userneed_PCAP}             12979_Capture start    cellSetup
    Critical Step                                    CallSetup.Setup Wtsemu SA

    #                                        Capture during UE Attach
    Run Keyword If      ${userneed_PCAP}             12979_Capture start    Attach
    FOR     ${idx}     IN                            @{param.ListOfUeEngaged}
            Critical Step                            CallSetup.UE Register           ue=${idx.ueid}
            Critical Step                            CallSetup.Launch PDU Session    ue=${idx.ueid}    pdu=${idx.pdu}
    END
    Run Keyword If      ${userneed_PCAP}             Run Keywords       12979_Capture Stop     Attach
    ...                                              AND                12979_Capture Stop     cellSetup

    #                                        TRAFFIC Start
    FOR     ${idx}     IN                            @{param.ListOfUeEngaged}
            DdatedLog_12979                          TRAFFIC for UE=${idx.ueid} - pdu number ${idx.pdu}

            FTS_trfxl                                ue=${idx.ueid}     pdu=${idx.pdu}    qfi=1    mbps=${idx.UL_TP}      dir=ul
            FTS_trfxl                                ue=${idx.ueid}     pdu=${idx.pdu}    qfi=1    mbps=${idx.DL_TP}      dir=dl

    END

    #                                        TTI Capture
    Run Keyword If       ${userneed_TTI}             12979_TTI start
    ...                                              time=${param.GetTtiTraceTime}    w_convert_pcap_to_excelCsv=False    targpath=${TTI_logdir}
    Traced Sleep                                     1s     traffic TP tti collection
    Run Keyword If       ${userneed_TTI}             12979_TTI stop                   suffix=TTI_underTraffic
    ...                                              time=${param.GetTtiTraceTime}    w_convert_pcap_to_excelCsv=False    targpath=${TTI_logdir}

    #                                        BIPL1L2 Capture
    Run Keywords                                     Dated log              1s L1L2 Bip collection
    ...       AND                                    12979_Capture Start     Traff
    ...       AND                                    Sleep                  1s
    ...       AND                                    12979_Capture Stop      Traff

    Critical Step       12979 TC validation

12979_SetRadParam
    [Documentation]     Add or Modify the RAD params

    Dated Log New Line   Add Rad parameters for CB012979-H ID99
    dated log    -----> address=${param.rdMaxPdschPayloadSize.address}; value=${param.rdMaxPdschPayloadSize.value}

    ${dict_rdparam}=         create dictionary       field=0x58000f    value=${param.rad_58000f}

    ${list_rdparam}=       Create List         ${dict_rdparam}

    SetConfig.Set Fields in swconfig DU       param_list=${list_rdparam}

12979_Test Teardown
    [Documentation]    Perform needed actions at the end of a test case

    Dated log New Line                       Test Teardown CB012979-H ID99 : start
    Dated log                                .....................................
    Run Keyword And Ignore Error    Produce Scout Data

    # Run Keyword If Test Failed      Set Global Variable    ${save_debug_data}    ${True}

    Run Keyword If Test Failed      Dated log              TEST - I N T E R R U P T I O N -
    Run Keyword If Test Passed      Dated log              TEST - N A T U R A L - E N D -

    12979_CollectConfigfilesUsedForTest

    12979_Alarmslist       End    ${logsDir}
    StringTool.printLineWithTitle              title=TEST_NAME : ${TEST NAME}

    Display diagnosis

    Run Keyword If        ${AutoSaveDebugData} == ${True}    Set Global Variable    ${save_debug_data}    ${True}

    Dated log             save_debug_data : ${save_debug_data}
    Dated log             AutoSaveDebugData : ${AutoSaveDebugData}

    #following to uncomment if you don't want any SosReport / Snapshot collection
    Set Global Variable             ${save_debug_data}    ${False}

    Run Keyword If        ${BtsLogStarted}                 12979_Stop Btslog      ${logsDir}
    Run Keyword If        ${save_debug_data} == ${True}    12979_LogCollection

    ${cmd}                set variable    cp -p ${tl.core.dir_path}/egate_console.* ${logsDir}
    Dated Log             ${cmd}
    SSH Exec              ${cmd}          alias=${alias_epcsim}

    Dated log             12979_Test Teardown CB012979-H ID99 : end

12979_Test Suite Teardown
    [Documentation]          Suite Teardown for CB012979.
    setup.Suite Teardown

12979_LogCollection
    Dated log   L O G S _ C O L L E C T I O N

#    Run Keyword If    not ${isAic}    Run Keywords    Get Snapshot
#    ...    AND                                        SSH Exec             mv ${LOG_PATH_bu}/SNAPSHOT_GNB*zip ${logsDir}    alias=${alias_epcsim}
#
#    Run Keyword If    not ${isAic}    Run Keywords    Get Sos Report
#    ...    AND                                        SSH Exec             mv %{HOME}/SosReport*tgz ${logsDir}              alias=${alias_epcsim}

    #move pcap file from mirroring
    SSH Exec             mv ${LOG_PATH_bu}/*.pcap ${logsDir}              alias=${alias_epcsim}

    Run Keyword If 	'${AutoSaveDebugData}'
    ...   Run Keyword And Ignore Error
    ...   SSH Exec       cp -rp ${LOG_PATH}/l2stream3 ${logsDir}          alias=${alias_epcsim}

12979_Create Test Suite Folder
    [Documentation]    CB012979 Create test case folder

    ${timeStamp}     get current date       result_format=%Y%m%d_%H%M%S

    ${testCase}    Replace String    ${TEST_NAME[0:30]}    ${SPACE}    _
    ${testCase}    Replace String    ${testCase}    .    _
    ${testCase}    Remove String     ${testCase}    [1]
    ${testCase}    Remove String     ${testCase}    [1.0]
    ${testCase}    Remove String     ${testCase}    [2.0]
    ${testCase}    Remove String     ${testCase}    [
    ${testCase}    Remove String     ${testCase}    ]

    Set Suite Variable    ${testSuiteDir}    ${OUTPUT DIR}/Logs/${testCase}${timeStamp}

    create directory      ${testSuiteDir}

    Set Suite Variable    ${ConfigDir}        ${testSuiteDir}/Config_${timeStamp}
    Create Directory      ${ConfigDir}
    Set Suite Variable    ${logsDir}          ${testSuiteDir}/logs
    Create Directory      ${logsDir}
    Run Keyword If        ${VMmonitoring}     Run keywords
    ...                                       Set Global Variable   ${MoniDir}          ${testSuiteDir}/MONITORING
    ...                   AND                 Create Directory      ${MoniDir}

12979_Backup Scf
    [Documentation]                 Save the current SCF
    [Arguments]    ${dir}=${LOG_PATH}
    ${timeStamp}       get current date     result_format=%Y%m%d_%H%M%S
    # ${timeStamp}=      Remove String    ${timeStamp.replace(' ','-')}
    ${g_backup_scf}    OAM Get SCF File    dir=${dir}    file=SCF_ofTheTest_${timeStamp}.xml
    Set Suite Variable    ${g_backup_scf}
    Dated Log    SCF backup file = ${g_backup_scf}
    ${g_backup_scf_cu}    Run Keyword If    ${isAic}    OAM Get Cu SCF File    dir=${dir}    file=SCF_ofTheTest_cu_${timeStamp}.xml
    Run Keyword If    ${isAic}    Run Keywords    Set Suite Variable    ${g_backup_scf_cu}
    ...    AND    Dated Log    SCF cu backup file = ${g_backup_scf_cu}

12979_CollectConfigfilesUsedForTest
    [Documentation]                 Save current scf/iphy/swconfig/basic files used for the test in ${testSuiteDir}
    Dated Log                       * * * Collect configuration files used for the test
    12979_Backup Scf      ${ConfigDir}
    Backup Files FTS      ${FD_ALL}           ${ConfigDir}

    # Previous KW collected only the original .cfg, not the cfg modified by the test. Correction:
    SSH Exec              rm ${ConfigDir}/*.cfg                                                          alias=${alias_epcsim}
    ${cmd}                set variable    cp -p ${tl.core.dir_path}/${tl.core.cfg_filename} ${ConfigDir}/${tl.core.cfg_filename}
    Dated Log             ${cmd}
    SSH Exec              ${cmd}                                                                         alias=${alias_epcsim}

    Set Suite Variable    ${LOG_PATH_bu}      ${LOG_PATH}
    Set Suite Variable    ${LOG_PATH}         ${ConfigDir}
    # Get Data From Gnb TargetBD File           card_name=${param.RU}
    Set Suite Variable    ${LOG_PATH}         ${LOG_PATH_bu}

12979_Init Trace color
    ${consTraceColor}               Evaluate                    "${CYAN}"
    ${consTraceColorRed}            Evaluate                    "${RED}"
    ${defColor}                     Evaluate                    "${NORMAL}"
    Set Suite Variable              ${consTraceColor}
    Set Suite Variable              ${consTraceColorRed}
    Set Suite Variable              ${defColor}

12979_Capture_session_initiating
    Dated Log New Line              * * * install Mirroring scripts in GNB

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

12979_Stop Btslog
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

FTS_trfxl_old
    [Documentation]    As loop in loop is not possible in Robot this is
    ...                a sub KW of Traffic KW in charge to start traffic
    ...                Huge traffic is possible up to  3500 Mbps In DL :
    ...                175 Mbps maximum is possible by trf_id, egate limit to 20 Trf_id, Maximum traffic rate
    ...                is so theoricaly 175 (max Mbps by trf_id) x nb max trf_id (20) 3500 Mbps on DL
    ...                record last trfid used
    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${mbps}=22    ${dir}=dl
    DdatedLog_12979  Arguments ue:${ue} pdu:${pdu} qfi:${qfi} mbps:${mbps} dir:${dir}

    Dated log   Args_trf: ue ${ue} pdu ${pdu} qfi ${qfi} mbps ${mbps}
    ${trfid}     set variable    1
    FOR    ${i}    IN RANGE    9999999
            # Dated log  mbps ${mbps}
            Dated log  trf_id ${trfid}
            ${complement}          Evaluate                ${mbps} - 175    #175 is the maximum DL TP by trf_id
            #Dated log  complement ${complement}
            Run Keyword If         ${complement}>0 and ${mbps}>=175
                ...                                        wtsemu.trf_data_start       ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=${dir}
                ...                                                                    trf_id=${trfid}    mbps=175
                ...     ELSE IF    ${mbps}>0 and ${mbps}<=175
                ...                                        wtsemu.trf_data_start       ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=${dir}
                ...                                                                    trf_id=${trfid}    mbps=${mbps}
                ...     ELSE                               Exit For Loop
            ${mbps}     set variable    ${complement}
            ${trfid}   Evaluate        ${trfid} + 1
            Run Keyword If    ${trfid} > 19    Exit For Loop       #Trf_id max = 20

            sleep   2s   #to no let start traffic too quickly
    END

FTS_trfxl
    [Documentation]    A sub-keyword of Traffic KW responsible for starting traffic.
    ...                Handles up to 3500 Mbps in DL with 175 Mbps per trf_id.
    ...                egate limits to 20 trf_ids, giving a theoretical max of 3500 Mbps on DL.
    ...                Records the last trf_id used.
    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${mbps}=22    ${dir}=dl
    DdatedLog_12979  Arguments: ue=${ue}, pdu=${pdu}, qfi=${qfi}, mbps=${mbps}, dir=${dir}

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


DdatedLog_12979
    [Documentation]    This KW will help on non regression to see deeper informations
    ...                ${debugArg} need to be set to True at the begining of this file
    [Arguments]        ${SomethinToTrace}=none

    Run Keyword If     ${debugArg}    Dated Log   Debug wwwwwwwwww: ${SomethinToTrace}
