*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008124 step A
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 17-Oct-2022
...               Last Modified by            :
...               Modification:
...                       17-Oct-2022         | Creation


Resource                            ./CB008124_keywords.robot
Resource                            ../../../resources/common/TtiTrace/ttitrace.robot

*** Variables ***
${DL_duration}                   60
${DL_trace_duration}             5

${TputVolMargin}                 5


*** Keywords ***
CB008124_TC_A_05_Cell_Setup_KO_due_to_PRACH_overlapping_TDD
    ${duplexModeTC}                   Set Variable       TDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       40
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       90

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}
    CB008124 Full Commissioning       scf_list=${SCF_list}
    CB008124 cell setup
    CB008124 check CellSetup          ULCGenabled=${False}


CB008124_TC_A_08_B2_Initial_Context_Setup_with_UE_CG2_Capability_FDD
    ${duplexModeTC}                   Set Variable       FDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       20

    CB008124_A_Initial_Context_Setup_with_UE_CG2_Capability    TCid=A08    ULCGconfig=${ULCGconfig}


CB008124_TC_A_12_B2_Initial_Context_Setup_with_UE_CG2_Capability_TDD
    ${duplexModeTC}                   Set Variable       TDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       20
    ${ULCGconfig.periodicity}         Set Variable       ms2

    CB008124_A_Initial_Context_Setup_with_UE_CG2_Capability    TCid=A12    ULCGconfig=${ULCGconfig}


CB008124_A_Initial_Context_Setup_with_UE_CG2_Capability
    [Arguments]                       ${TCid}    ${ULCGconfig}=${ULCG_defaultConf}

    CB008124 Create UECG UEnonCG      nbUECG=1

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}
    CB008124 Full Commissioning       scf_list=${SCF_list}
    CB008124 cell setup

    # TTI capture configuration
    ${TTIdir}                         Get TTI Trace Path                 dir_suffix=${TCid}

    Dated Log New Line                ${trcColor}=== Start TTI trace capture ${defColor}
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    CB008124 Attach                   ueSetting=${BASIC_UE_SA}    CPRTcapture=${True}
    Sleep                             10
    UE Deregister                     id=${BASIC_UE_SA.ue}

    Dated Log New Line                ${trcColor}=== Stop TTI trace capture ${defColor}
    ${TTIpcap}                        Stop TTI Traces in Streaming mode
    ...                               tti_trace_path=${TTIdir}
    ...                               tti_trace_filename=TTITrace_${TCid}

    ${TTIjson}                        Convert TTItrace from pcap to others
    ...                               input_file_path=${TTIpcap}
    ${TTIcsv}                         decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000

    CB008124 check attach             ULCGconfig=${ULCGconfig}
    CB008124 check CellSetup          ULCGenabled=${True}    ULCGconfig=${ULCGconfig}
    ${nbULCGconfigured}               checkULCGconfigured    jsonPathName=${TTIjson}
    Should Be True                    ${nbULCGconfigured}==1
