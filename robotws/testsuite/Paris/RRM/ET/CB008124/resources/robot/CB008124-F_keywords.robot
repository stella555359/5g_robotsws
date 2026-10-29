*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008124 step F
...
...               Test Case Scenario author   : jing.tian@nokia.com
...               Test Case Scenario contact  : jing.tian@nokia.com
...               Test Case automation author : laurent.puchelle@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 17-Jul-2023
...               Last Modified by            : Yann HERVE
...               Modification:
...                       17-Jul-2022         | Creation
...                       18-Feb-2025         | Increase UE1 UL rate to trigger ULCG activation

Resource            ./CB008124_keywords.robot
Resource            ../../../resources/common/TtiTrace/ttitrace.robot
Resource            ../../../../../resources/SWENG/robot/KPIs.robot

Library             ../../../../../resources/SWENG/python/ScfVendorOperations.py

*** Variables ***
${TputVolMargin}                          5

${CB008124_F05_CG_constraints}            CB008124_F05_interaction_PRB_pooling_constraints_CG.csv
${CB008124_F05_noCG_constraints}          CB008124_F05_interaction_PRB_pooling_constraints_noCG.csv


*** Keywords ***
CB008124_TC_F_05_B3_CG_interaction_with_PRB_pooling_TDD
    ${duplexModeTC}                   Set Variable       TDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       52
    ${ULCGconfig.ulCgMaxNumUeUl}      Set Variable       3
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       0
    ${ULCGconfig.grantedPacketSize}   Set Variable       10000
    ${ULCGconfig.maxNumPrbs}          Set Variable       52
    ${ULCGconfig.periodicity}         Set Variable       ms10

    CB008124F Define UEs F05

    # Disable inter-subpool PRB pooling to avoid booking PRB from Cell2 for Cell1/Cell3
    CB008124F Disable interSubPool PRB pooling

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}
    CB008124F pooling config          scf_file=${SCF_list}

    ${VendorFileOrig}    ${VendorFileMod}    Download Vendor File

###################################################################################################
####  Vendor file modification, should be replaced by implementation of ticket FIVEG_FTPS-47501
###################################################################################################
    Dated Log new line                 ${trcColor}=== Modify hidden parameters in vendor file for PRB pooling ${defColor}

    # UPdate vendor file to reduce L1Sp capacity (bbL1SpPrbInitCapacity) in order to trigger PRB pooling:
    #      <p name="maxNumLayerPrbL1Sp">678</p>
    #      <p name="maxNumStreamPrbL1Sp">1356</p>
    # Code based on 8940 scripts (see CB008940-Common-Keywords.robot)

    # Retrieve vendor file items
    ScfVendorOperations.setup reader    ${VendorFileOrig}
    ${mo_dict}                          ScfVendorOperations.get moelements byclass    NRBTS

    # Inside bbL1SpPrbInitCapacity
    &{original_values}      Create Dictionary
    ...                     bbHwVariant=ABIO
    ...                     csSize=64
    ...                     direction=UL
    ...                     l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm
    ...                     maxNumLayerPrbL1Sp=1092
    ...                     maxNumStreamPrbL1Sp=2184
    ...                     maxNumWbStreamPrbL1Sp=1092

    &{new_values}           Copy Dictionary    ${original_values}
    Set To Dictionary       ${new_values}    maxNumLayerPrbL1Sp       654
    Set To Dictionary       ${new_values}    maxNumStreamPrbL1Sp      1308
    Set To Dictionary       ${new_values}    maxNumWbStreamPrbL1Sp    654

    @{original_items_list}    Create List    ${original_values}
    @{new_items_list}         Create List    ${new_values}
    ${list_name}            Set Variable     bbL1SpPrbInitCapacity
    ${modified_mo}          ScfVendorOperations.replace items inList    ${original_items_list}    ${new_items_list}
    ...                     ${list_name}    ${mo_dict}

    # Apply new Vendor file
    ScfVendorOperations.save back toxml                   ${VendorFileMod}
###################################################################################################

    ${DU_SCF}                        Set Variable    ${SCF_list}[0]
    Vendor File And Commissioning    vendorfile_path=${VendorFileMod}    SCF_path=${DU_SCF}

    CB008124 cell setup

    # TTI capture configuration
    ${TTIdir}                         Get TTI Trace Path                 dir_suffix=F05


    &{UE1}                        Copy Dictionary    ${BASIC_UE_SA}
    &{UE2}                        Copy Dictionary    ${BASIC_UE_SA}
    Set To Dictionary             ${UE2}             ue          2
    &{UE3}                        Copy Dictionary    ${BASIC_UE_SA}
    Set To Dictionary             ${UE3}             ue          3

    Dated Log New Line            ${trcColor} === Attach UEs ${defColor}
    CB008124 Attach               ueSetting=${UE1}
    CB008124 Attach               ueSetting=${UE2}
    CB008124 Attach               ueSetting=${UE3}

    ${UL_throughput_no_ULCG}      Evaluate    220
    Dated Log New Line            ${trcColor} === Start ${UL_throughput_no_ULCG}Mbps UL on UE2/UE3 ${defColor}
    Traffic UE UL                 ueSetting=${UE2}
    ...                           throughput=${UL_throughput_no_ULCG}
    ...                           shouldBeStop=False
    ...                           shouldBeCheck=False
    ...                           duration=0

    Traffic UE UL                 ueSetting=${UE3}
    ...                           throughput=${UL_throughput_no_ULCG}
    ...                           shouldBeStop=False
    ...                           shouldBeCheck=False
    ...                           duration=0


    #Dated Log New Line            ${trcColor} === Start TTI trace capture ${defColor}
    #Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    Dated Log New Line            ${trcColor} === Send UL packet on CG UE1 ${defColor}
    ${pktPeriodCG}                Evaluate    4
    ${pktSizeCG}                  Evaluate    1000
    ${pktBurstCG}                 Evaluate    3
    Send UE UL packets            ueSetting=${UE1}
    ...                           duration=0
    ...                           period_ms=${pktPeriodCG}
    ...                           size=${pktSizeCG}
    ...                           burst=${pktBurstCG}
    ...                           shouldBeStop=${False}
    ...                           shouldBeCheck=${True}
    ...                           deviation=${TputVolMargin}

    Traced Sleep                  10    msg=TTI trace capture with CG

    #Dated Log New Line            ${trcColor} === Stop TTI trace capture ${defColor}
    #${TTIpcap}                    Stop TTI Traces in Streaming mode
    #...                           tti_trace_path=${TTIdir}
    #...                           tti_trace_filename=TTITrace_F05


    ${zoiCG}                      ZOI Start
    ZOI Wait End                  zoi=${zoiCG}
    ${pm_pathCG}                  Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    Dated Log New Line            ${trcColor} === ZOI CG, PM: ${pm_pathCG} ${defColor}

    Dated Log New Line            ${trcColor} === Stop traffic UE1 CG ${defColor}
    Traffic Stop                  ueSetting=${UE1}             dir=ul

    ${zoinonCG}                   ZOI Start
    ZOI Wait End                  zoi=${zoinonCG}
    ${pm_pathNoCG}                Counters.Collect PM files from BTS    ${LOG_PATH}/PM
    Dated Log New Line            ${trcColor} === ZOI non CG, PM: ${pm_pathNoCG} ${defColor}

    Dated Log New Line            ${trcColor} === Stop traffic UE2/UE3 ${defColor}
    Traffic Stop                  ueSetting=${UE2}             dir=ul
    Traffic Stop                  ueSetting=${UE3}             dir=ul

    Dated Log New Line            ${trcColor} === Detach UEs ${defColor}
    UE Deregister                 id=${UE1.ue}
    UE Deregister                 id=${UE2.ue}
    UE Deregister                 id=${UE3.ue}


    #${TTIjson}                    Convert TTItrace from pcap to others
    #...                           input_file_path=${TTIpcap}
    #${TTIcsv}                     decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000

    # KPIs and counters checks
    KPI Evaluate                  pmFile=${pm_pathCG}
    ...                           constraintsFile=${CURDIR}/../../config/${CB008124_F05_CG_constraints}
    ...                           failOnError=${True}

    KPI Evaluate                  pmFile=${pm_pathNoCG}
    ...                           constraintsFile=${CURDIR}/../../config/${CB008124_F05_noCG_constraints}
    ...                           failOnError=${True}


CB008124_TC_F_06_B4_CG_interaction_with_UE_pooling_20ms_TDD
    ${duplexModeTC}                   Set Variable       TDD
    set Suite Variable                ${duplexModeTC}
    &{ULCGconfig}                     copy dictionary    ${ULCG_defaultConf}
    ${ULCGconfig.ulCgMaxNumPrbs}      Set Variable       40
    ${ULCGconfig.ulCgMaxNumUeUl}      Set Variable       5
    ${ULCGconfig.ulCgPrbStartOffset}  Set Variable       0
    ${ULCGconfig.grantedPacketSize}   Set Variable       100
    ${ULCGconfig.maxNumPrbs}          Set Variable       16
    ${ULCGconfig.periodicity}         Set Variable       ms20

    CB008124F Define UEs F06

    ${SCF_list}                       CB008124 Get SCF File
    CB008124 SCF config               scf_file=${SCF_list}    actUlCgType2=true    ULCGconfig=${ULCGconfig}
    CB008124F pooling config          scf_file=${SCF_list}

    ${VendorFileOrig}    ${VendorFileMod}    Download Vendor File

###################################################################################################
####  Vendor file modification, should be replaced by implementation of ticket FIVEG_FTPS-47501
###################################################################################################
    Dated Log new line                 ${trcColor}=== Modify hidden parameters in vendor file for UE pooling ${defColor}
    Run    cp ${VendorFileOrig} ${VendorFileMod}
    Run    sed -i 's#<p name="maxNumScheUePdschL1Pool">[[:graph:]]*<#<p name="maxNumScheUePdschL1Pool">12<#g' ${VendorFileMod}
    Run    sed -i 's#<p name="maxNumScheUePuschL1Pool">[[:graph:]]*<#<p name="maxNumScheUePuschL1Pool">12<#g' ${VendorFileMod}
    Run    sed -i 's#<p name="maxNumScheUePdschL1Sp">[[:graph:]]*<#<p name="maxNumScheUePdschL1Sp">6<#g' ${VendorFileMod}
    Run    sed -i 's#<p name="maxNumScheUePuschL1Sp">[[:graph:]]*<#<p name="maxNumScheUePuschL1Sp">6<#g' ${VendorFileMod}
    Run    sed -i 's#<p name="bbPoolMinResource">[[:graph:]]*<#<p name="bbPoolMinResource">50<#g' ${VendorFileMod}
###################################################################################################

    ${DU_SCF}                        Set Variable    ${SCF_list}[0]
    Vendor File And Commissioning    vendorfile_path=${VendorFileMod}    SCF_path=${DU_SCF}

    CB008124 cell setup

    # TTI capture configuration
    ${TTIdir}                         Get TTI Trace Path                 dir_suffix=F06

    # Attach all Ues
    FOR                           ${UEid}    IN RANGE    1    16
        Dated Log New Line        ${trcColor}=== Attach UE ${UEid} ${defColor}
        &{UEloop}                 copy dictionary    ${BASIC_UE_SA}
        ${UEloop.ue}              Set Variable       ${UEid}
        CB008124 Attach           ueSetting=${UEloop}    CPRTcapture=${False}
    END

    # Start UL on noCG UEs of cell 3
    ${UL_throughputnoCG}          Evaluate    20
    FOR                           ${UEid}    IN RANGE    6    16
        Dated Log New Line        ${trcColor}=== Start UL ${UL_throughputnoCG}Mbps on UE ${UEid} ${defColor}
        &{UEloop}                 copy dictionary    ${BASIC_UE_SA}
        ${UEloop.ue}              Set Variable       ${UEid}
        Traffic UE UL             ueSetting=${UEloop}
        ...                       throughput=${UL_throughputnoCG}
        ...                       shouldBeStop=${False}
        ...                       shouldBeCheck=${False}
        ...                       duration=0
    END

    # Start UL on 2 noCG UEs of cell 1
    ${pktPeriodNoCG1}             Evaluate    4
    ${pktSizeNoCG1}               Evaluate    500
    ${pktBurstNoCG1}              Evaluate    1
    FOR                           ${UEid}    IN RANGE    2    6
        Dated Log New Line        ${trcColor}=== Start packets sending on UE ${UEid} ${defColor}
        &{UEloop}                 copy dictionary    ${BASIC_UE_SA}
        ${UEloop.ue}              Set Variable       ${UEid}
        Send UE UL packets        ueSetting=${UEloop}
        ...                       duration=0
        ...                       period_ms=${pktPeriodNoCG1}
        ...                       size=${pktSizeNoCG1}
        ...                       burst=${pktBurstNoCG1}
        ...                       shouldBeStop=${False}
        ...                       shouldBeCheck=${False}
        ...                       deviation=${TputVolMargin}
    END
    ${TimeStart_UL_UEsNoCG1}      Set Variable           ${TIME_LAST_TRAFFIC_START}

    # Start UL on others noCG UEs of cell 1
    ${pktPeriodNoCG2}             Evaluate    6
    ${pktSizeNoCG2}               Evaluate    1000
    ${pktBurstNoCG2}              Evaluate    1
    FOR                           ${UEid}    IN RANGE    2    6
        Dated Log New Line        ${trcColor}=== Start packets sending on UE ${UEid} ${defColor}
        &{UEloop}                 copy dictionary    ${BASIC_UE_SA}
        ${UEloop.ue}              Set Variable       ${UEid}
        Send UE UL packets        ueSetting=${UEloop}
        ...                       duration=0
        ...                       period_ms=${pktPeriodNoCG2}
        ...                       size=${pktSizeNoCG2}
        ...                       burst=${pktBurstNoCG2}
        ...                       shouldBeStop=${False}
        ...                       shouldBeCheck=${False}
        ...                       deviation=${TputVolMargin}
    END
    ${TimeStart_UL_UEsNoCG2}      Set Variable           ${TIME_LAST_TRAFFIC_START}

    Dated Log New Line            ${trcColor}=== Start TTI trace capture ${defColor}
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

    Traced Sleep                  2    msg=TTI trace capture before CG activation

    Dated Log New Line            ${trcColor}=== Start packets sending on CG UE ${defColor}
    ${pktPeriodCG}                Evaluate    10
    ${pktSizeCG}                  Evaluate    400
    ${pktBurstCG}                 Evaluate    1
    Send UE UL packets            ueSetting=${BASIC_UE_SA}
    ...                           duration=0
    ...                           period_ms=${pktPeriodCG}
    ...                           size=${pktSizeCG}
    ...                           burst=${pktBurstCG}
    ...                           shouldBeStop=${False}
    ...                           shouldBeCheck=${False}
    ...                           deviation=${TputVolMargin}
    ${TimeStart_UL_UECG}          Set Variable           ${TIME_LAST_TRAFFIC_START}

    Traced Sleep                  10    msg=TTI trace capture with CG

    Dated Log New Line            ${trcColor}=== Stop TTI trace capture ${defColor}
    ${TTIpcap}                    Stop TTI Traces in Streaming mode
    ...                           tti_trace_path=${TTIdir}
    ...                           tti_trace_filename=TTITrace_F06

    Traced Sleep                  60    msg=UL traffic ongoing

    # Stop UL on noCG UEs of cell 3
    FOR                           ${UEid}    IN RANGE    6    16
        Dated Log New Line        ${trcColor}=== Stop UL on UE ${UEid} ${defColor}
        &{UEloop}                 copy dictionary    ${BASIC_UE_SA}
        ${UEloop.ue}              Set Variable       ${UEid}
        Traffic Stop              ueSetting=${UEloop}    dir=ul
    END

    # Stop UL on noCG UEs of cell 1
    FOR                           ${UEid}    IN RANGE    2    6
        Dated Log New Line        ${trcColor}=== Stop packets sending on UE ${UEid} ${defColor}
        &{UEloop}                 copy dictionary    ${BASIC_UE_SA}
        ${UEloop.ue}              Set Variable       ${UEid}
        Traffic Stop              ueSetting=${UEloop}    dir=ul
    END
    ${TimeStop_UL_UEsNoCG}        Set Variable           ${TIME_LAST_TRAFFIC_STOP}

    Dated Log New Line            ${trcColor}=== Stop packets sending on CG UE ${defColor}
    Traffic Stop                  ueSetting=${BASIC_UE_SA}    dir=ul
    ${TimeStop_UL_UECG}           Set Variable           ${TIME_LAST_TRAFFIC_STOP}

    Traced Sleep                  10    msg=waiting to detach UEs

    # Detach all Ues
    FOR                           ${UEid}    IN RANGE    1    16
        Dated Log New Line        ${trcColor}=== Detach UE ${UEid} ${defColor}
        UE Deregister             id=${UEid}
    END


    CB008124 get PM files

    ${TTIjson}                    Convert TTItrace from pcap to others
    ...                           input_file_path=${TTIpcap}
    ${TTIcsv}                     decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000

    ${allocatedUEcheck}           checkAllocatedRssWithUEpooling    jsonPathName=${TTIjson}

    ${cnt_NbCGactAttempt}           Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                             ${pm_path}    NRCELL    ${CGcounter_UL_CG_ACT_ATT}    object_id=${NRCELL_ID}
    ${cnt_NbCGactAttemptSucc}       Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                             ${pm_path}    NRCELL    ${CGcounter_UL_CG_ACT_ATT_SUCC}    object_id=${NRCELL_ID}
    ${cnt_NbCGdeactAttempt}         Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                             ${pm_path}    NRCELL    ${CGcounter_UL_CG_DEACT_ATT}    object_id=${NRCELL_ID}
    ${cnt_NbCGdeactAttempt_succ}    Retrieve Counter Sum of Values From Pm Files For Object With Name
    ...                             ${pm_path}    NRCELL    ${CGcounter_UL_CG_DEACT_ATT_SUCC}    object_id=${NRCELL_ID}

    ${timeDiffNoCG1}              Subtract Date From Date    ${TimeStop_UL_UEsNoCG}    ${TimeStart_UL_UEsNoCG1}
    ${trafficDurationNoCG1}       Convert To Integer    ${timeDiffNoCG1}
    ${ULtputNoCG1}                Evaluate       ${pktSizeNoCG1}*${pktBurstNoCG1}*8*1000/${pktPeriodNoCG1}
    ${expectedDataVolNoCG1}       Evaluate       ${ULtputNoCG1}*${trafficDurationNoCG1}/8
    ${timeDiffNoCG2}              Subtract Date From Date    ${TimeStop_UL_UEsNoCG}    ${TimeStart_UL_UEsNoCG2}
    ${trafficDurationNoCG2}       Convert To Integer    ${timeDiffNoCG2}
    ${ULtputNoCG2}                Evaluate       ${pktSizeNoCG2}*${pktBurstNoCG2}*8*1000/${pktPeriodNoCG2}
    ${expectedDataVolNoCG2}       Evaluate       ${ULtputNoCG2}*${trafficDurationNoCG2}/8
    ${timeDiffCG}                 Subtract Date From Date    ${TimeStop_UL_UECG}    ${TimeStart_UL_UECG}
    ${trafficDurationCG}          Convert To Integer    ${timeDiffCG}
    ${ULtputCG}                   Evaluate       ${pktSizeCG}*${pktBurstCG}*8*1000/${pktPeriodCG}
    ${expectedDataVolCG}          Evaluate       ${ULtputCG}*${trafficDurationCG}/8
    ${expectedDataVol}            Evaluate       2*${expectedDataVolNoCG1}+2*${expectedDataVolNoCG2}+${expectedDataVolCG}
    ${expectedDataVolMargin}      Evaluate       ${expectedDataVol} - ${expectedDataVol}*${TputVolMargin}/100
    ${status_UL_dataVolume}       CB008124 check UL Data Volume    expectedDataVolBytes=${expectedDataVolMargin}

    ${status_UL_BLER}             CB008124 check UL BLER    maxBLER=1

    Should Be True                ${cnt_NbCGactAttempt}>0 and ${cnt_NbCGactAttemptSucc}==${cnt_NbCGactAttempt}
    Should Be True                ${cnt_NbCGdeactAttempt}==${cnt_NbCGactAttempt} and ${cnt_NbCGdeactAttempt_succ}==${cnt_NbCGactAttempt}
    Should Be True                ${allocatedUEcheck} and ${status_UL_dataVolume} and ${status_UL_BLER}


########################  Step F KWs  ########################
CB008124F Define UEs F05
    Dated Log new line                 ${trcColor}=== Define 1 UE CG on cell 1, and 1 UEs nonCG on cell 2 and cell 3 ${defColor}
    CB008124 Create UECG UEnonCG        nbUECG=1        nbUEnonCG=2

    Modify UE Data in Cfg File          sa_or_nsa=SA    ue_id=2     cell_id=2
    Modify UE Data in Cfg File          sa_or_nsa=SA    ue_id=3     cell_id=3


CB008124F Disable interSubPool PRB pooling
    # Disable inter-subpool PRB pooling to avoid booking PRB from Cell2 for Cell1/Cell3
    # Once it's the case, this part may be removed.
    ${prd_SlowPrbPoolingRangeTddUl}     Create Dictionary    field=${RD_SlowPrbPoolingRangeTddUl}    value=0
    ${list_rad_param}                   Create List          ${prd_SlowPrbPoolingRangeTddUl}
    Set Fields in swconfig DU           param_list=${list_rad_param}


CB008124F Define UEs F06
    Dated Log new line                 ${trcColor}=== Define 1 UE CG and 4 UEs nonCG on cell 1, and 10 UEs nonCG on cell 3 ${defColor}
    Create UEs in Cfg File             nb_sa_ues=15

    ${UEcapa}                          Set Variable If    '${duplexModeTC}' == 'TDD'
    ...                                                   ${UEcapa_ConfiguredULGrantType2_enhancedSkipUplinkTxConfigured_r16_TDD}
    ...                                                   ${UEcapa_configuredUL_GrantType2_v1650_enhancedSkipUplinkTxConfigured_v1660_FDD}

    # Modify UE capa of UE1 CG
    Modify UE Data in Cfg File        sa_or_nsa=SA    ue_id=1    ue_nr_capa=${UEcapa}

    # Define cell 3 to UEs 6 to 15
    FOR                               ${UEid}    IN RANGE    15    5    -1
        Modify UE Data in Cfg File    sa_or_nsa=SA    ue_id=${UEid}    cell_id=3
    END


CB008124F pooling config
    [Arguments]                 ${scf_file}
    Dated Log new line          ${trcColor}=== Pooling configuration ${defColor}

    ${DU_SCF}                   Set Variable    ${scf_file}[0]
    SCF StartSession            scf_file=${DU_SCF}

    SCF Set element             dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                         element_name=actBbPoolTddFr1
    ...                         element_value=true

    @{list_fPdcchMonOccsnPoValue}    Create List    2
    FOR    ${NRCELLitem}    IN    @{NRCELL_DN_LIST}
        Run Keyword If    '${NRCELLitem}' != '${None}'    Run Keywords
        ...        SCF Set element    dist_name=${NRCELLitem}    element_name=actShortBsrLimitAdaptation    element_value=true
        ...        AND
        ...        SCF Remove list    dist_name=${NRCELLitem}    list_name=fPdcchMonOccsnPo
        ...        AND
        ...        SCF Add list       dist_name=${NRCELLitem}    list_name=fPdcchMonOccsnPo
        ...        AND
        ...        SCF Add elements to list    dist_name=${NRCELLitem}    list_name=fPdcchMonOccsnPo    elements=${list_fPdcchMonOccsnPoValue}
    END

    SCF Set element             dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRSYSINFO_PROFILE-1
    ...                         element_name=systemInformationTargetRate
    ...                         element_value=157

    SCF StopSession             scf_file=${DU_SCF}
