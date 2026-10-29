*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008124 step D
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 20-Mar-2023
...               Last Modified by            : L. Puchelle
...               Modification:
...                       20-Mar-2023         | Creation, delivery of TC D06


Resource                            ./CB008124_keywords.robot
Resource                            ../../../resources/common/TtiTrace/ttitrace.robot


*** Variables ***
${TputVolMargin}                 5


*** Keywords ***
CB008124_TC_D_06_B3_CG_interaction_with_A-CSI_5ms_FDD
    ${duplexModeTC}                   Set Variable       FDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       24
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       0
    ${ULCGconfig.grantedPacketSize}   Set Variable       200
    ${ULCGconfig.maxNumPrbs}          Set Variable       12
    ${ULCGconfig.periodicity}         Set Variable       ms5

    CB008124 Create UECG UEnonCG      nbUECG=1

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}    ACSI=true
    CB008124 Full Commissioning       scf_list=${SCF_list}
    CB008124 cell setup

    # TTI capture configuration
    ${TTIdir}                         Get TTI Trace Path                 dir_suffix=D06

    Dated Log New Line            ${trcColor}=== Start TTI trace capture ${defColor}
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    CB008124 Attach               ueSetting=${BASIC_UE_SA}    CPRTcapture=${True}

    Dated Log New Line            ${trcColor}=== Start UL traffic ${defColor}
    ${UL_throughput}              Evaluate    5
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
    ...                           tti_trace_filename=TTITrace_D06

    ${TTIjson}                    Convert TTItrace from pcap to others
    ...                           input_file_path=${TTIpcap}
    ${TTIcsv}                     decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000

    CB008124 get PM files

    ${nbACSIchecked}              checkACSInotInCGslots    jsonPathName=${TTIjson}    duplexMode=FDD

    ${timeDiff}                   Subtract Date From Date    ${TIME_LAST_TRAFFIC_STOP}    ${TIME_LAST_TRAFFIC_START}
    ${trafficDuration}            Convert To Integer    ${timeDiff}
    ${expectedDataVol}            Evaluate    ${UL_throughput}*1000000*${trafficDuration}/8
    ${expectedDataVolMargin}      Evaluate    ${expectedDataVol} - ${expectedDataVol}*${TputVolMargin}/100
    ${status_UL_dataVolume}       CB008124 check UL Data Volume    expectedDataVolBytes=${expectedDataVolMargin}
    ...                                                            cellId=${FDD_Cell_list[0].nrCellId}

    ${status_UL_BLER}             CB008124 check UL BLER    maxBLER=1    cellId=${FDD_Cell_list[0].nrCellId}

    Should Be True                ${nbACSIchecked}>0 and ${status_UL_dataVolume} and ${status_UL_BLER}
