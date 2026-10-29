*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008124 step CB
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: laurent.puchelle@nokia.com
...               Creation Date               : 14-Apr-2023
...               Last Modified by            : Laurent Puchelle
...               Modification:
...                       14-Apr-2022         | Creation

Resource                         ./CB008124_keywords.robot
Resource                         ../../../resources/common/TtiTrace/ttitrace.robot


*** Variables ***
${TputVolMargin}                                5


*** Keywords ***
CB008124_TC_CB_01_B1_CG_overwritten_ULMaxThroughput_FDD
    ${duplexModeTC}                    Set Variable       FDD
    set Suite Variable                 ${duplexModeTC}
    &{ULCGconfig}                      copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}       Set Variable       48
    ${ULCGconfig.ulCgPrbStartOffset}   Set Variable       0
    ${ULCGconfig.grantedPacketSize}    Set Variable       800
    ${ULCGconfig.maxNumPrbs}           Set Variable       40
    ${ULCGconfig.periodicity}          Set Variable       ms1
	${ULCGconfig.p0NominalPusch}       Set Variable       -82


    CB008124 Set CG OW Adjustment
    CB008124 Create UECG UEnonCG      nbUECG=1

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}
    CB008124 Full Commissioning       scf_list=${SCF_list}
    CB008124 cell setup

    # Add background cell noise:
    wtsemu.ul_cell_noise_testmode_nr      profile_id=1
    ...                                   noise_pusch=-750

    wtsemu.cell_testmode_set_nr           cell_id=${FDD_Cell_list[0].nrCellId}
    ...                                   gnb=2
    ...                                   testmode=ul_cell_noise
    ...                                   profile_id=1
    ...                                   action=activate

    # TTI capture configuration
    ${TTIdir}                         Get TTI Trace Path                 dir_suffix=CB01

    Dated Log New Line            ${trcColor}=== Start TTI trace capture ${defColor}
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    &{UE_CG}                      copy dictionary    ${BASIC_UE_SA}

    CB008124 Attach               ueSetting=${UE_CG}    CPRTcapture=${True}

    Dated Log New Line            ${trcColor}=== Start UL traffic ${defColor}
    ${UL_throughput}              Evaluate    200
    ${UE_CG.throughput}           Set Variable    ${UL_throughput}
    Traffic UE UL                 ueSetting=${UE_CG}
    ...                           throughput=${UL_throughput}
    ...                           shouldBeStop=False
    ...                           shouldBeCheck=False
    ...                           duration=0

    Traced Sleep                  60    msg=UL traffic

    Dated Log New Line            ${trcColor}=== Stop UL traffic and detach UE ${defColor}
    Traffic Stop                  ueSetting=${UE_CG}           dir=ul
    Sleep                         10
    UE Deregister                 id=${UE_CG.ue}

    Dated Log New Line            ${trcColor}=== Stop TTI trace capture ${defColor}
    ${TTIpcap}                    Stop TTI Traces in Streaming mode
    ...                           tti_trace_path=${TTIdir}
    ...                           tti_trace_filename=TTITrace_CB01

    ${TTIjson}                    Convert TTItrace from pcap to others
    ...                           input_file_path=${TTIpcap}
    ${TTIcsv}                     decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000

    CB008124 get PM files

    ${cnt_NbCGactAttempt}           Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                             ${pm_path}    NRCELL    ${CGcounter_UL_CG_ACT_ATT}    object_id=${FDD_Cell_list[0].nrCellId}
    ${cnt_NbCGactAttemptSucc}       Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                             ${pm_path}    NRCELL    ${CGcounter_UL_CG_ACT_ATT_SUCC}    object_id=${FDD_Cell_list[0].nrCellId}
    ${cnt_NbCGdeactAttempt}         Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                             ${pm_path}    NRCELL    ${CGcounter_UL_CG_DEACT_ATT}    object_id=${FDD_Cell_list[0].nrCellId}
    ${cnt_NbCGdeactAttempt_succ}    Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                             ${pm_path}    NRCELL    ${CGcounter_UL_CG_DEACT_ATT_SUCC}    object_id=${FDD_Cell_list[0].nrCellId}

    ${timeDiff}                   Subtract Date From Date    ${TIME_LAST_TRAFFIC_STOP}    ${TIME_LAST_TRAFFIC_START}
    ${trafficDuration}            Convert To Integer    ${timeDiff}
    ${expectedDataVol}            Evaluate    ${UL_throughput}*1000000*${trafficDuration}/8
    ${expectedDataVolMargin}      Evaluate    ${expectedDataVol} - ${expectedDataVol}*${TputVolMargin}/100
    ${status_UL_dataVolume}       CB008124 check UL Data Volume    expectedDataVolBytes=${expectedDataVolMargin}
    ...                                                            cellId=${FDD_Cell_list[0].nrCellId}

    ${status_UL_BLER}             CB008124 check UL BLER    maxBLER=1    cellId=${FDD_Cell_list[0].nrCellId}

    # Empirical max number of CG desactivation/re-activation due to traffic generation according to the traffic duration
    ${CGactDeact_max}             Evaluate    10
    Should Be True                ${CGactDeact_max}>=${cnt_NbCGactAttempt}>0 and ${cnt_NbCGactAttemptSucc}==${cnt_NbCGactAttempt}
    Should Be True                ${cnt_NbCGdeactAttempt}==${cnt_NbCGactAttempt} and ${cnt_NbCGdeactAttempt_succ}==${cnt_NbCGactAttempt}
    Should Be True                ${status_UL_dataVolume} and ${status_UL_BLER}
