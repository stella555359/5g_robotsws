*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008124 step B
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 13-Feb-2023
...               Last Modified by            : L. Puchelle
...               Modification:
...                       17-Oct-2022         | Creation
...                       13-Feb-2023         | Implement KW for TC B11
...                       03-Mar-2023         | Implement TC B12, remove B11
...                       07-Mar-2023         | Implement TC B09
...                       14-Mar-2023         | Implement TCs B08 and B25


Resource                            ./CB008124_keywords.robot
Resource                            ../../../resources/common/TtiTrace/ttitrace.robot


*** Variables ***
${TputVolMargin}                 5


*** Keywords ***
CB008124_TC_B_08_B4_CG_activation_deactivation_reactivation_and_UE_release_TDD
    ${duplexModeTC}                   Set Variable       TDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       48
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       0
    ${ULCGconfig.grantedPacketSize}   Set Variable       200
    ${ULCGconfig.maxNumPrbs}          Set Variable       24
    ${ULCGconfig.periodicity}         Set Variable       ms10

    CB008124B CG Loop                  TC=B08    ULCGconfig=${ULCGconfig}    attachNb=1    ULnb=1    UL_throughput=3    UL_durationSec=30


CB008124_TC_B_09_B5_CG_release_with_single_CG_UE_FDD
    ${duplexModeTC}                   Set Variable       FDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       32
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       0
    ${ULCGconfig.grantedPacketSize}   Set Variable       100
    ${ULCGconfig.maxNumPrbs}          Set Variable       12
    ${ULCGconfig.periodicity}         Set Variable       ms10

    CB008124 Create UECG UEnonCG      nbUECG=1
    Create Bearer in Cfg File         5qi=7    proto=udp

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}    CGbearer=7
    CB008124 Full Commissioning       scf_list=${SCF_list}
    CB008124 cell setup

    # TTI capture configuration
    ${TTIdir}                         Get TTI Trace Path                 dir_suffix=B09

    Dated Log New Line            ${trcColor}=== Start TTI trace capture ${defColor}
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    CB008124 Attach               ueSetting=${BASIC_UE_SA}    CPRTcapture=${True}

    # Create CG bearer 7
    UE PDU Session Modify         ue=${BASIC_UE_SA.ue}    pdu=${BASIC_UE_SA.ue}    qfta=4    by=amf

    Dated Log New Line            ${trcColor}=== Start UL traffic ${defColor}
    ${UL_throughput}              Evaluate    5
    Traffic UE UL                 ueSetting=${BASIC_UE_SA}
    ...                           throughput=${UL_throughput}
    ...                           shouldBeStop=False
    ...                           shouldBeCheck=False
    ...                           duration=0

    Traced Sleep                  20    msg=UL CG traffic

    # Delete CG bearer 7
    UE PDU Session Modify         ue=${BASIC_UE_SA.ue}    pdu=${BASIC_UE_SA.ue}    qfta=4    by=amf    toDel=${True}

    ${TimeBearerDeleted}          Get Current Date

    Traced Sleep                  60    msg=UL DG traffic

    Dated Log New Line            ${trcColor}=== Stop UL traffic and detach UE ${defColor}
    Traffic Stop                  ueSetting=${BASIC_UE_SA}           dir=ul
    UE Deregister                 id=${BASIC_UE_SA.ue}

    Dated Log New Line            ${trcColor}=== Stop TTI trace capture ${defColor}
    ${TTIpcap}                    Stop TTI Traces in Streaming mode
    ...                           tti_trace_path=${TTIdir}
    ...                           tti_trace_filename=TTITrace_B09

    ${TTIjson}                    Convert TTItrace from pcap to others
    ...                           input_file_path=${TTIpcap}
    ${TTIcsv}                     decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000

    CB008124 get PM files

    ${cnt_NbUECGinSlots}          Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                           ${pm_path}    NRCELL    ${CGcounter_TOT_CG_ACT_UE}    object_id=${FDD_Cell_list[0].nrCellId}

    ${timeCG}                      Subtract Date From Date    ${TimeBearerDeleted}    ${TIME_LAST_TRAFFIC_START}
    ${CGduration}                  Convert To Integer    ${timeCG}
    ${NbUECGinSlots_max}           Evaluate    ${CGduration}*1000
    ${NbUECGinSlots_min}           Evaluate    (${CGduration}-5)*1000

    ${timeDiff}                   Subtract Date From Date    ${TIME_LAST_TRAFFIC_STOP}    ${TIME_LAST_TRAFFIC_START}
    ${trafficDuration}            Convert To Integer    ${timeDiff}
    ${expectedDataVol}            Evaluate    ${UL_throughput}*1000000*${trafficDuration}/8
    ${expectedDataVolMargin}      Evaluate    ${expectedDataVol} - ${expectedDataVol}*${TputVolMargin}/100
    ${status_UL_dataVolume}       CB008124 check UL Data Volume    expectedDataVolBytes=${expectedDataVolMargin}
    ...                                                            cellId=${FDD_Cell_list[0].nrCellId}

    ${status_UL_BLER}             CB008124 check UL BLER    maxBLER=1    cellId=${FDD_Cell_list[0].nrCellId}

    Should Be True                ${NbUECGinSlots_max} > ${cnt_NbUECGinSlots} and ${cnt_NbUECGinSlots} > ${NbUECGinSlots_min}
    Should Be True                ${status_UL_dataVolume} and ${status_UL_BLER}


CB008124_TC_B_12_B2_CG_activation_KO_due_to_missing_MAC_CE_TDD
    ${duplexModeTC}                   Set Variable       TDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       24
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       0
    ${ULCGconfig.grantedPacketSize}   Set Variable       200
    ${ULCGconfig.maxNumPrbs}          Set Variable       12
    ${ULCGconfig.periodicity}         Set Variable       ms80

    CB008124 Create UECG UEnonCG      nbUECG=1

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}
    CB008124 Full Commissioning       scf_list=${SCF_list}
    CB008124 cell setup

    # TTI capture configuration
    ${TTIdir}                         Get TTI Trace Path                 dir_suffix=B12

    Dated Log New Line            ${trcColor}=== Start TTI trace capture ${defColor}
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    CB008124 Attach               ueSetting=${BASIC_UE_SA}    CPRTcapture=${True}

    CB008124 CG TM activation no MACCE    UEid=${BASIC_UE_SA.ue}    skipNb=2

    Dated Log New Line            ${trcColor}=== Start UL traffic ${defColor}
    ${UL_throughput}              Evaluate    3
    Traffic UE UL                 ueSetting=${BASIC_UE_SA}
    ...                           throughput=${UL_throughput}
    ...                           shouldBeStop=False
    ...                           shouldBeCheck=False
    ...                           duration=0

    Traced Sleep                  30    msg=UL traffic

    Dated Log New Line            ${trcColor}=== Stop UL traffic and detach UE ${defColor}
    Traffic Stop                  ueSetting=${BASIC_UE_SA}           dir=ul
    UE Deregister                 id=${BASIC_UE_SA.ue}

    Dated Log New Line            ${trcColor}=== Stop TTI trace capture ${defColor}
    ${TTIpcap}                    Stop TTI Traces in Streaming mode
    ...                           tti_trace_path=${TTIdir}
    ...                           tti_trace_filename=TTITrace_B12

    ${TTIjson}                    Convert TTItrace from pcap to others
    ...                           input_file_path=${TTIpcap}
    ${TTIcsv}                     decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000

    ${CSRNTI}                     checkULCGActivationErrorNoMACCE    jsonPathName=${TTIjson}

    CB008124 get PM files

    ${timeDiff}                   Subtract Date From Date    ${TIME_LAST_TRAFFIC_STOP}    ${TIME_LAST_TRAFFIC_START}
    ${trafficDuration}            Convert To Integer    ${timeDiff}
    ${expectedDataVol}            Evaluate    ${UL_throughput}*1000000*${trafficDuration}/8
    ${expectedDataVolMargin}      Evaluate    ${expectedDataVol} - ${expectedDataVol}*${TputVolMargin}/100
    ${status_UL_dataVolume}       CB008124 check UL Data Volume    expectedDataVolBytes=${expectedDataVolMargin}
    ...                                                            cellId=${TDD_Cell_list[0].nrCellId}

    ${status_UL_BLER}             CB008124 check UL BLER    maxBLER=1    cellId=${TDD_Cell_list[0].nrCellId}

    Should Be True                ${CSRNTI} and ${status_UL_dataVolume} and ${status_UL_BLER}


CB008124_TC_B_19_B1_CG_activation_KO_due_to_UE_data_rate_conditions_FDD
    ${duplexModeTC}                   Set Variable       FDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       52
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       0
    ${ULCGconfig.grantedPacketSize}   Set Variable       15000
    ${ULCGconfig.maxNumPrbs}          Set Variable       52
    ${ULCGconfig.periodicity}         Set Variable       ms80

    CB008124 Create UECG UEnonCG      nbUECG=1

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}
    CB008124 Full Commissioning       scf_list=${SCF_list}
    CB008124 cell setup

    # TTI capture configuration
    ${TTIdir}                         Get TTI Trace Path                 dir_suffix=B19

    Dated Log New Line            ${trcColor}=== Start TTI trace capture ${defColor}
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    CB008124 Attach               ueSetting=${BASIC_UE_SA}    CPRTcapture=${True}

    Dated Log New Line            ${trcColor}=== Start UL traffic ${defColor}
    ${UL_throughput}              Evaluate    1
    Traffic UE UL                 ueSetting=${BASIC_UE_SA}
    ...                           throughput=${UL_throughput}
    ...                           shouldBeStop=False
    ...                           shouldBeCheck=False
    ...                           duration=0

    Traced Sleep                  60    msg=UL traffic

    Dated Log New Line            ${trcColor}=== Stop UL traffic and detach UE ${defColor}
    Traffic Stop                  ueSetting=${BASIC_UE_SA}           dir=ul
    UE Deregister                 id=${BASIC_UE_SA.ue}

    Dated Log New Line            ${trcColor}=== Stop TTI trace capture ${defColor}
    ${TTIpcap}                    Stop TTI Traces in Streaming mode
    ...                           tti_trace_path=${TTIdir}
    ...                           tti_trace_filename=TTITrace_B19

    ${TTIjson}                    Convert TTItrace from pcap to others
    ...                           input_file_path=${TTIpcap}
    ${TTIcsv}                     decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000

    ${nbULCGconfigured}           checkULCGconfigured         jsonPathName=${TTIjson}
    ${nbULCGstartActivation}      checkULCGstartActivation    jsonPathName=${TTIjson}

    CB008124 get PM files

    ${timeDiff}                   Subtract Date From Date    ${TIME_LAST_TRAFFIC_STOP}    ${TIME_LAST_TRAFFIC_START}
    ${trafficDuration}            Convert To Integer    ${timeDiff}
    ${expectedDataVol}            Evaluate    ${UL_throughput}*1000000*${trafficDuration}/8
    ${expectedDataVolMargin}      Evaluate    ${expectedDataVol} - ${expectedDataVol}*${TputVolMargin}/100
    ${status_UL_dataVolume}       CB008124 check UL Data Volume    expectedDataVolBytes=${expectedDataVolMargin}
    ...                                                            cellId=${FDD_Cell_list[0].nrCellId}

    Should Be True                ${nbULCGconfigured}==1 and ${nbULCGstartActivation}==0 and ${status_UL_dataVolume}


CB008124_TC_B_25_B4_Robustness_CG_activation_deactivation_reactivation_UE_release_FDD
    ${duplexModeTC}                   Set Variable       FDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       32
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       0
    ${ULCGconfig.grantedPacketSize}   Set Variable       200
    ${ULCGconfig.maxNumPrbs}          Set Variable       12
    ${ULCGconfig.periodicity}         Set Variable       ms10

    CB008124B CG Loop                  TC=B25    ULCGconfig=${ULCGconfig}    attachNb=10    ULnb=3    UL_throughput=3    UL_durationSec=20


CB008124_TC_B_26_B3_Robustness_UL_traffic_with_1CGUE_and_1DGUE_TDD
    ${duplexModeTC}                   Set Variable       TDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       48
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       0
    ${ULCGconfig.grantedPacketSize}   Set Variable       200
    ${ULCGconfig.maxNumPrbs}          Set Variable       24
    ${ULCGconfig.periodicity}         Set Variable       ms10

    CB008124 Create UECG UEnonCG      nbUECG=1    nbUEnonCG=1

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}
    CB008124 Full Commissioning       scf_list=${SCF_list}
    CB008124 cell setup

    &{UE_CG}                      copy dictionary    ${BASIC_UE_SA}

    &{UE_nonCG}                   copy dictionary    ${BASIC_UE_SA}
    ${UE_nonCG.ue}                Set Variable       2

    Dated Log New Line            ${trcColor}=== Attach UE non CG ${defColor}
    CB008124 Attach               ueSetting=${UE_nonCG}    CPRTcapture=${True}

    Dated Log New Line            ${trcColor}=== Start UL traffic UE non CG ${defColor}
    ${UL_throughputnoCG}          Evaluate    50
    Traffic UE UL                 ueSetting=${UE_nonCG}
    ...                           throughput=${UL_throughputnoCG}
    ...                           shouldBeStop=False
    ...                           shouldBeCheck=False
    ...                           duration=0

    ${TimeStart_UL_noCG}          Set Variable           ${TIME_LAST_TRAFFIC_START}

    # TTI capture configuration
    ${TTIdir}                     Get TTI Trace Path     dir_suffix=B26

    # Start TTI trace capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    Dated Log New Line            ${trcColor}=== Attach UE CG ${defColor}
    CB008124 Attach               ueSetting=${UE_CG}    CPRTcapture=${True}

    Dated Log New Line            ${trcColor}=== Start UL traffic UE CG ${defColor}
    ${UL_throughputCG}            Evaluate    10
    Traffic UE UL                 ueSetting=${UE_CG}
    ...                           throughput=${UL_throughputCG}
    ...                           shouldBeStop=False
    ...                           shouldBeCheck=False
    ...                           duration=0

    ${TimeStart_UL_CG}            Set Variable           ${TIME_LAST_TRAFFIC_START}

    Traced Sleep                  10                     msg=TTI capture start UL CG

    # Stop TTI trace capture
    ${TTIpcap_attachStartULCG}      Stop TTI Traces in Streaming mode
    ...                           tti_trace_path=${TTIdir}
    ...                           tti_trace_filename=TTITrace_B26_attachStartULCG

    Traced Sleep                  15m                    msg=UL traffic endurance

    # Start TTI trace capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    Traced Sleep                  10                     msg=TTI capture at end of UL traffic

    # Stop TTI trace capture
    ${TTIpcap_endUL}      Stop TTI Traces in Streaming mode
    ...                           tti_trace_path=${TTIdir}
    ...                           tti_trace_filename=TTITrace_B26_endUL


    Dated Log New Line            ${trcColor}=== Stop UL traffic and detach UE ${defColor}
    Traffic Stop                  ueSetting=${UE_CG}     dir=ul
    UE Deregister                 id=${UE_CG.ue}
    ${TimeStop_UL_CG}             Set Variable           ${TIME_LAST_TRAFFIC_STOP}


    Dated Log New Line            ${trcColor}=== Stop UL traffic and detach UE ${defColor}
    Traffic Stop                  ueSetting=${UE_nonCG}           dir=ul
    UE Deregister                 id=${UE_nonCG.ue}
    ${TimeStop_UL_noCG}           Set Variable           ${TIME_LAST_TRAFFIC_STOP}


    ${TTIjson_attachStartULCG}    Convert TTItrace from pcap to others
    ...                           input_file_path=${TTIpcap_attachStartULCG}
    ${TTIcsv_attachStartULCG}     decode_tti_traces_json_using_TtitraceReaderEvtDec   jsonPathName=${TTIjson_attachStartULCG}   num_of_events=200000

    ${TTIjson_endUL}              Convert TTItrace from pcap to others
    ...                           input_file_path=${TTIpcap_endUL}
    ${TTIcsv_endUL}               decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson_endUL}    num_of_events=200000

    CB008124 get PM files

    ${timeDiffCG}                 Subtract Date From Date    ${TimeStop_UL_CG}    ${TimeStart_UL_CG}
    ${trafficDurationCG}          Convert To Integer    ${timeDiffCG}
    ${expectedDataVolCG}          Evaluate    ${UL_throughputCG}*1000000*${trafficDurationCG}/8

    ${timeDiffNoCG}               Subtract Date From Date    ${TimeStop_UL_noCG}    ${TimeStart_UL_noCG}
    ${trafficDurationNoCG}        Convert To Integer    ${timeDiffNoCG}
    ${expectedDataVolNoCG}        Evaluate    ${UL_throughputnoCG}*1000000*${trafficDurationNoCG}/8

    ${expectedDataVol}            Evaluate    ${expectedDataVolCG}+${expectedDataVolNoCG}
    ${expectedDataVolMargin}      Evaluate    ${expectedDataVol} - ${expectedDataVol}*${TputVolMargin}/100
    ${status_UL_dataVolume}       CB008124 check UL Data Volume    expectedDataVolBytes=${expectedDataVolMargin}
    ...                                                            cellId=${TDD_Cell_list[0].nrCellId}

    ${status_UL_BLER}             CB008124 check UL BLER    maxBLER=1    cellId=${TDD_Cell_list[0].nrCellId}

    ${CSRNTI}                     getCSRNTIfromCGactivation      jsonPathName=${TTIjson_attachStartULCG}
    Should Be True                ${CSRNTI}

    ${checkCGperiod1}             checkULCGschedulPeriod   jsonPathName=${TTIjson_attachStartULCG}
    ...                                                    duplexMode=TDD    CSRNTI=${CSRNTI}    CGperiod=10    maxNbCheck=1000
    ${checkCGperiod2}             checkULCGschedulPeriod   jsonPathName=${TTIjson_endUL}
    ...                                                    duplexMode=TDD    CSRNTI=${CSRNTI}    CGperiod=10    maxNbCheck=800

    Should Be True                ${checkCGperiod1} and ${checkCGperiod2} and ${status_UL_dataVolume} and ${status_UL_BLER}


########################  Step B KWs  ########################
CB008124B CG Loop
    [Arguments]                   ${TC}=TC    ${ULCGconfig}=${ULCG_defaultConf}    ${attachNb}=1    ${ULnb}=1
    ...                           ${UL_throughput}=3    ${UL_durationSec}=20

    CB008124 Create UECG UEnonCG    nbUECG=1

    ${SCF_list}                   CB008124 Get SCF File
    CB008124 SCF config           scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}
    CB008124 Full Commissioning       scf_list=${SCF_list}
    CB008124 cell setup

    ${tgtCellId}                  Set Variable If    '${duplexModeTC}' == 'TDD'
    ...                                               ${TDD_Cell_list[0].nrCellId}
    ...                                               ${FDD_Cell_list[0].nrCellId}

    # Add background cell noise:
    wtsemu.ul_cell_noise_testmode_nr      profile_id=1
    ...                                   noise_pusch=-750

    wtsemu.cell_testmode_set_nr           cell_id=${tgtCellId}
    ...                                   gnb=2
    ...                                   testmode=ul_cell_noise
    ...                                   profile_id=1
    ...                                   action=activate

    # TTI capture configuration
    ${TTIdir}                     Get TTI Trace Path     dir_suffix=${TC}
    ${TTINameTC}                  Set Variable    TTITrace_${TC}

    ${ULduration}                 Evaluate    0
    @{TTItraceFileList}           Create List
    FOR    ${loopAttach}    IN RANGE    1    ${attachNb}+1
        Dated Log new line        ${trcColor}##### Attach ${loopAttach} / ${attachNb} ##### ${defColor}

        ${TTIloopName}            Set Variable    ${TTINameTC}_Attach_${loopAttach}

        # Start TTI trace capture
        Start TTI Traces in Streaming mode    src_ip=10.0.1.2

        CB008124 Attach           ueSetting=${BASIC_UE_SA}    CPRTcapture=${True}

        # Stop TTI trace capture
        ${TTIpcap}                Stop TTI Traces in Streaming mode
        ...                       tti_trace_path=${TTIdir}
        ...                       tti_trace_filename=${TTIloopName}
        Append To List            ${TTItraceFileList}    ${TTIpcap}

        ${ULdurationLoop}    ${TTItracePCAPs}        CB008124B CG Activation Desactivation Loop
        ...                                          TTIdir=${TTIdir}   TTIbaseName=${TTIloopName}   ULnb=${ULnb}
        ...                                          UL_throughput=${UL_throughput}    UL_durationSec=${UL_durationSec}

        ${ULduration}             Evaluate    ${ULduration} + ${ULdurationLoop}
        ${TTItraceFileList}       Combine Lists    ${TTItraceFileList}    ${TTItracePCAPs}

        UE Deregister             id=${BASIC_UE_SA.ue}
        Sleep                     3s
    END

    CB008124 get PM files

    ${cnt_NbCGactAttempt}           Run Keyword if    not ${isAic}
    ...                             Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                ${pm_path}    NRCELL    ${CGcounter_UL_CG_ACT_ATT}    object_id=${tgtCellId}
    ...              ELSE           Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    ...                                &{dictCGcnt_UL_CG_ACT_ATT}
    ${cnt_NbCGactAttemptSucc}       Run Keyword if    not ${isAic}
    ...                             Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                ${pm_path}    NRCELL    ${CGcounter_UL_CG_ACT_ATT_SUCC}    object_id=${tgtCellId}
    ...              ELSE           Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    ...                                &{dictCGcnt_UL_CG_ACT_ATT_SUCC}
    ${cnt_NbCGdeactAttempt}         Run Keyword if    not ${isAic}
    ...                             Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                ${pm_path}    NRCELL    ${CGcounter_UL_CG_DEACT_ATT}    object_id=${tgtCellId}
    ...              ELSE           Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    ...                                &{dictCGcnt_UL_CG_DEACT_ATT}
    ${cnt_NbCGdeactAttempt_succ}    Run Keyword if    not ${isAic}
    ...                             Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                ${pm_path}    NRCELL    ${CGcounter_UL_CG_DEACT_ATT_SUCC}    object_id=${tgtCellId}
    ...              ELSE           Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    ...                                &{dictCGcnt_UL_CG_DEACT_ATT_SUCC}
    ${cnt_NbCGmodAttempt}           Run Keyword if    not ${isAic}
    ...                             Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                ${pm_path}    NRCELL    ${CGcounter_UL_CG_MOD_ATT}    object_id=${tgtCellId}
    ...              ELSE           Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    ...                                &{dictCGcnt_UL_CG_MOD_ATT}
    ${cnt_NbCGmodAttempt_succ}      Run Keyword if    not ${isAic}
    ...                             Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                ${pm_path}    NRCELL    ${CGcounter_UL_CG_MOD_ATT_SUCC}    object_id=${tgtCellId}
    ...              ELSE           Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    ...                                &{dictCGcnt_UL_CG_MOD_ATT_SUCC}
    ${cnt_NbUECGinSlots}            Run Keyword if    not ${isAic}
    ...                             Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                                ${pm_path}    NRCELL    ${CGcounter_TOT_CG_ACT_UE}    object_id=${tgtCellId}
    ...              ELSE           Retrieve Counter Sum of Values From Pm Files For Object and Id on vDU
    ...                                &{dictCGcnt_TOT_CG_ACT_UE}

    CB008124B Convert TTI pcap list    TTIdir=${TTIdir}   TTItraceFileList=${TTItraceFileList}
    ${TTIcsvAll}                       Join Path    ${TTIdir}    *.csv
    # Following pattern is present in TTI trace in case of CG activation and CG modification.
    # (CG modification is triggered in case of 3 NACKs or 20 ACKs and MCS not max)
    # => this has to be taken into account to check the number of successful activation/desactivation
    ${NbCGact}                         Run          grep "CHANGESTATE;ueCgStateEntry;CGACTIVATED;" ${TTIcsvAll} | wc -l
    ${NbCGdeact}                       Evaluate     ${NbCGact} - ${cnt_NbCGmodAttempt}
    ${cnt_NbCGact}                     Evaluate     ${cnt_NbCGactAttempt} + ${cnt_NbCGmodAttempt}
    ${cnt_NbCGactSucc}                 Evaluate     ${cnt_NbCGactAttemptSucc} + ${cnt_NbCGmodAttempt_succ}

    # Compute max/min UL traffic duration because:
    #    - it could be residual traffic after the traffic stops (add 1s)
    #    - Traffic start or CG activation could be delayed according to the SWENG or configuration (remove 2s)
    ${ULdurationMax}              Evaluate    ${ULduration}+${attachNb}*${ULnb}
    ${ULdurationMin}              Evaluate    ${ULduration}-2*${attachNb}*${ULnb}

    # Define the number of UL slots per frame (tdLte frame is assumed in case of TDD)
    ${nbSlotsULinFrame}           Set Variable If    '${duplexModeTC}'=='FDD'    10    4

    ${ULslotswithCGmax}           Evaluate    ${ULdurationMax}*1000/10*${nbSlotsULinFrame}
    ${ULslotswithCGmin}           Evaluate    ${ULdurationMin}*1000/10*${nbSlotsULinFrame}

    ${expectedDataVol}            Evaluate    ${UL_throughput}*1000000*${ULduration}/8
    ${expectedDataVolMargin}      Evaluate    ${expectedDataVol} - ${expectedDataVol}*${TputVolMargin}/100
    ${status_UL_dataVolume}       CB008124 check UL Data Volume    expectedDataVolBytes=${expectedDataVolMargin}    cellId=${tgtCellId}
    ${status_UL_BLER}             CB008124 check UL BLER    maxBLER=1    cellId=${tgtCellId}

    Should Be True                ${cnt_NbCGact}==${NbCGact} and ${cnt_NbCGactSucc}==${NbCGact}
    Should Be True                ${cnt_NbCGdeactAttempt}==${NbCGdeact} and ${cnt_NbCGdeactAttempt_succ}==${NbCGdeact}
    Should Be True                ${cnt_NbUECGinSlots}<${ULslotswithCGmax} and ${cnt_NbUECGinSlots}>${ULslotswithCGmin}
    Should Be True                ${status_UL_dataVolume} and ${status_UL_BLER}


CB008124B CG Activation Desactivation Loop
    [Arguments]                   ${TTIdir}    ${TTIbaseName}
    ...                           ${ULnb}=1    ${UL_throughput}=3    ${UL_durationSec}=20

    ${ULduration}                 Evaluate    0
    @{TTItraceList}               Create List
    FOR    ${loopAct}    IN RANGE    1    ${ULnb}+1
        Dated Log New Line            ${trcColor}=== UL traffic ${loopAct} / ${ULnb} ${defColor}

        # Start TTI trace capture
        Start TTI Traces in Streaming mode    src_ip=10.0.1.2

        Traffic UE UL             ueSetting=${BASIC_UE_SA}
        ...                       throughput=${UL_throughput}
        ...                       shouldBeStop=False
        ...                       shouldBeCheck=False
        ...                       duration=0

        Traced Sleep              ${UL_durationSec}    msg=UL traffic ${loopAct}

        Traffic Stop              ueSetting=${BASIC_UE_SA}           dir=ul

        Sleep                     5s
        # Stop TTI trace capture
        ${TTIfileName}            Set Variable    ${TTIbaseName}_UL_${loopAct}
        ${TTIpcap}                Stop TTI Traces in Streaming mode
        ...                       tti_trace_path=${TTIdir}
        ...                       tti_trace_filename=${TTIfileName}

        Append To List            ${TTItraceList}    ${TTIpcap}
        ${timeDiff}               Subtract Date From Date    ${TIME_LAST_TRAFFIC_STOP}    ${TIME_LAST_TRAFFIC_START}
        ${trafficDuration}        Convert To Integer    ${timeDiff}
        ${ULduration}             Evaluate    ${ULduration} + ${trafficDuration}
    END
    [Return]                      ${ULduration}    ${TTItraceList}


CB008124B Convert TTI pcap list
    [Arguments]                   ${TTIdir}    ${TTItraceFileList}

    FOR    ${TTIpcap}    IN    @{TTItraceFileList}
        #${TTIpcapPath}      Join Path    ${TTIdir}    ${TTIpcap}
        ${TTIjson}          Convert TTItrace from pcap to others    input_file_path=${TTIpcap}
        ${TTIcsv}           decode_tti_traces_json_using_TtitraceReaderEvtDec   jsonPathName=${TTIjson}   num_of_events=200000
    END
