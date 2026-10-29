*** Settings ***
Documentation
...  author:  TBA
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Commisioning related keywords for performance testing
...
Library     taf.config.scf                                 WITH NAME    scf
Library     taf.sbts.oam.coam.admin                        WITH NAME    admin
Library     python/perf_timer.py
Library     python/perf_keywords.py
Library     python/perf_distnames.py
Library     python/scf_manager.py
Library     python/hasher.py

Resource    ../../../resources/Common/connect.robot
Resource    ../../../resources/Common/gnb.robot
Resource    ../../../resources/Common/bsr_package_installation.robot

Resource    performance_log_collection.robot
Resource    performance_egate.robot
Resource    performance_keywords.robot
Resource    performance_vendor.robot

*** Variables ***
${QC_PATH}=             testsuite/Ulm/ET/Performance_Test/resources/qc/ASOE_performance.qc
${GNB_SCF_IS_MODIFIED}  ${FALSE}
${TS_UPDATED_SCF}       ${none}

*** Keywords ***
Modify gNB SCF
    ${scf_path}    Catenate    ${P_resultTestDir}/scfc_updated_v1.xml
    IF    "${TP.SCF_ENABLE_COMMISSIONING}"=="false"
        Log to console    ${SPACE}- SCF_ENABLE_COMMISSIONING is disabled!
        scf.save_scf    ${scf_path}
        perf_log_collection.Queue Logs To Turandot    ${scf_path}    subfolder=${RL_PATH.final_config}
        Set Suite Variable       $TS_UPDATED_SCF    ${scf_path}
        Get Vendor File
        RETURN      ${none}
    END

    ${core_alias}     connect.Connect To Core
    ${cached_log}    ${scf_path_v2}          scf_manager.Modify SCF    ${P_ORIG_SCF}    scfc_updated_v2.xml    ${TP}    ${core_alias}
    ...                                      target=${P_resultTestDir}
    Log To Console    ${cached_log}
    Set Suite Variable   $P_UNIQUE_SCF    ${scf_path_v2}

    scf.Load SCF    ${scf_path_v2}

    # For Variants
    IF    "${TP.SCF_ENABLE_BEAMFORMING}"=="true"                   Enable Beamforming
    IF    "${TP.SCF_ENABLE_CB008246}"=="true"                      Enable CB008246
    IF    "${TP.SCF_ENABLE_BB_POOLING}"=="true"                    Enable BB Pooling
    IF    "${TP.SCF_CONFIGURE_PCMD}"=="true"                       Configure PCMD
    IF    "${TP.SCF_CONFIGURE_SRS}"=="true"                        Configure SRS
    IF    "${TP.SCF_CONFIGURE_PDCCH_RESOURCE_INCREASE}"=="true"    Configure PDCCH Resource Increase
    IF    "${TP.SCF_CONFIGURE_CA_RAMP}"=="true"                    Configure CA Ramp
    IF    "${TP.SCF_VENDOR_DEFAULT_PERF_VALUES}"=="true"           Set Vendor Default Perf Values

    # Single Values
    IF    "${TP.SCF_SET_BBMODBOARDCONFIGTYPE}"!="null"         Set bbmodBoardConfigType     ${TP.SCF_SET_BBMODBOARDCONFIGTYPE}

    # Pm counter
    IF    "${TP.SCF_SET_reportingIntervalPm}"!="null"          Set reportingIntervalPm value  ${TP.SCF_SET_reportingIntervalPm}

    # Converts Jenkins SCF params to robot friendly params
    ${scf_mods}    perf_keywords.Get SCF Mods From Dictionary    ${TP}    action=SET
    FOR    ${scf_mod}    IN     @{scf_mods}
        ${regex_form}=   Set Variable if    "MRBTS"!="${scf_mod['dist']}"    [a-zA-Z0-9\/-]*/${scf_mod['dist']}-${scf_mod['regex']}
        ...                                                                   ${scf_mod['dist']}-${scf_mod['regex']}
        IF    "${scf_mod['value']}"=="__remove__"
            Remove Regex SCF Element Values    ${scf_mod['pname']}    regex=${regex_form}
        ELSE IF    "${scf_mod['value']}"!="null"
            Set Regex SCF Element Values    ${scf_mod['pname']}    ${scf_mod['value']}    regex=${regex_form}
        END
    END
    # support modifying of lists
    ${scf_mods}    perf_keywords.Get SCF List Mods From Dictionary    ${TP}
    FOR    ${scf_mod}    IN     @{scf_mods}
        ${regex_form}=   Set Variable if    "MRBTS"!="${scf_mod['dist']}"    [a-zA-Z0-9\/-]*/${scf_mod['dist']}-${scf_mod['regex']}
        ...                                                                  ${scf_mod['dist']}-${scf_mod['regex']}
        IF    "${scf_mod['value']}"=="__remove__"
            Remove Regex SCF List Values    ${regex_form}    ${scf_mod['list']}    pname=${scf_mod['pname']}
        ELSE IF    "${scf_mod['value']}"!="null"
            Set Regex SCF List Values    ${regex_form}    ${scf_mod['list']}    ${scf_mod['value']}     p_name=${scf_mod['pname']}
        END
    END

    scf.Save Scf    ${scf_path}
    perf_log_collection.Queue Logs To Turandot    ${scf_path}    subfolder=${RL_PATH.final_config}
    Set Suite Variable       $TS_UPDATED_SCF    ${scf_path}

    ### start: VENDOR FILE ###
    ${vendor_mods}    perf_keywords.get_vendor_mods_from_dictionary    ${TP}
    FOR    ${vendor_mod}    IN     @{vendor_mods}
        IF    "${vendor_mod['value']}"!="null"
            performance_vendor.Modify Vendor File all pname    ${vendor_mod['pname']}    ${vendor_mod['value']}    path_class=${vendor_mod['dist']}
            ...                             original_value=${vendor_mod['prev_val']}
        END
    END
    ###   end: VENDOR FILE ###

    IF    not ${GNB_SCF_IS_MODIFIED} and not ${GNB_VENDOR_IS_MODIFIED} and "${TP.ENABLE_MARVIN}"!="true"
        Log to console    SCF is not modified, skipping commissioning.
        RETURN
    END

    ${OAM_ALIAS}           connect.Setup OAM HTTP Session

    ${_}    ${_}    Get Vendor File
    IF    ${GNB_VENDOR_IS_MODIFIED}    performance_vendor.Set Vendor File    ${OAM_ALIAS}

    ${commission_st}    perf_timer.Start
    Log to console    Perform commissioning...

    Wait for RU
    TRY
        admin.perform_commissioning  scf_file=${scf_path}  connection=${OAM_ALIAS}
        ...                          skip_parameter_relation_errors=${TP.SCF_skip_parameter_relation_errors}  timeout=600
    EXCEPT    AdminApiProcedureFailureException.*Configuration data validation is rejected because CPlane is busy    type=regexp    AS   ${error}
        Fail    commissioning failed: CPlane is busy!\n##########\n${error}\n
    EXCEPT    AdminApiProcedureFailureException.*niddValidationResult    type=regexp    AS   ${error}
        Fail    commissioning failed: niddValidationResult!\n##########\n${error}\n
    EXCEPT    AS   ${error}
        Fail    commissioning failed: unknown!\n##########\n${error}\n
    END

    perf_timer.Stop    msg=gNB SCF Commisioning:    start_time=${commission_st}

Restore SCF
    Log to Console    ${SPACE} - Restore SCF
    IF    "${TP.SCF_ENABLE_COMMISSIONING}"=="false"
        Log to console    ${SPACE}- SCF_ENABLE_COMMISSIONING is disabled!
        RETURN    ${none}
    END
    ${OAM_ALIAS}           connect.Setup OAM HTTP Session
    Wait for RU
    admin.perform_commissioning  scf_file=${P_ORIG_SCF}  connection=${OAM_ALIAS}
    ...  skip_parameter_relation_errors=${TP.SCF_skip_parameter_relation_errors}  timeout=600
    Run Keyword And Warn On Failure    Wait For Minimum Required State For Cell Setup    timeout=10min

Store SCF hash
    [Arguments]    ${scf_path}
    ${scf_path_common_id}    scf_manager.Change MRBTS NRBTS Index    ${scf_path}    1    1    scf_name=scfc_common_id.xml
    ${hash_scf}    hasher.Get SCF Sha256sum    ${scf_path_common_id}
    performance_database.Insert testcase parameter2    hash_scf     ${hash_scf}
    IF    "${hash_scf}"=="null"
        Log    SCF not generated!    level=WARN
        RETURN    null    null
    END
    ${scf_content}    Get File    ${scf_path}
    ${hash_scf_db}                performance_database.Insert hash    hash_scf     ${hash_scf}    ${scf_content}
    RETURN    ${hash_scf}    ${hash_scf_db}

Store current iphy hash
    ${ap_alias}    connect.Connect to Airphone Common Unit
    ssh.Download File    /rom/simmode/iphy.xml    ${P_resultTestDir}/iphy.xml    connection=${ap_alias}
    ${iphy_content}    Get File    ${P_resultTestDir}/iphy.xml
    ${hash_iphy}      hasher.get_iphy_sha256sum    ${iphy_content}
    performance_database.Insert testcase parameter2    hash_iphy     ${hash_iphy}
    ${hash_testcase_db}        performance_database.Insert hash    hash_iphy                 ${hash_iphy}        ${iphy_content}
    RETURN    ${hash_iphy}    ${hash_testcase_db}

Configure PCMD
    [Arguments]     ${actCellTraceReport}=true    ${actPCMDReport}=true
    ...    ${tcePortNumber}=49151     ${tceIpAddress}=10.0.1.1    ${traceall}=${TP.SCF_SET_CELL_TRACEALL}

    Set NRBTS Values    actPCMDReport         ${actPCMDReport}
    Set NRBTS Values    actCellTraceReport    ${actCellTraceReport}

    Log to console     ${SPACE}- Configure PCMD

    ${trace_dict}     Create dictionary
    ...    traceE1Setting        all
    ...    traceF1Setting        none
    ...    traceNGAPSetting      none
    ...    traceNRRRCSetting     none
    ...    traceX2Setting        none
    ...    traceXNSetting        none
    ${traceall}    Split String    ${traceall}    separator=,
    FOR     ${tracing}    IN     @{traceall}
         Set to Dictionary     ${trace_dict}    ${tracing}    all
    END

    ${distname_NRMTRACECU}    Set Variable     MRBTS-1/NRBTS-1/NRCTRLTS-1/NRMTRACECU-1
    ${distname_NRMTRACEDU}    Set Variable     MRBTS-1/NRBTS-1/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1
    ${distname_TCE}           Set Variable     MRBTS-1/MNL-1/TCEADM-1/TCE-1

    Set Object    class_name=com.nokia.srbts.nrbts:NRCTRLTSDU
    ...           dist_name=MRBTS-1/NRBTS-1/NRDU-1/NRCTRLTSDU-1
    ...           version=NRBTSCL24R3_2412_101

    Set Object    class_name=com.nokia.srbts.nrbts:NRCTRLTS
    ...           dist_name=MRBTS-1/NRBTS-1/NRCTRLTS-1
    ...           version=NRBTSCL24R3_2412_101

    Set Object    class_name=com.nokia.srbts.mnl:TCEADM
    ...           dist_name=MRBTS-1/MNL-1/TCEADM-1
    ...           version=MNL24R3_2412_100

    ${nrRanTraceReference_items}=  create dictionary
    ...    mcc                    311
    ...    mnc                    489
    ...    mncLength              3
    ...    traceId                1

    Set Object    class_name=com.nokia.srbts.nrbts:NRMTRACECU
    ...           dist_name=${distname_NRMTRACECU}
    ...           version=NRBTSCL24R3_2412_101
    FOR    ${p_name}    ${value}    IN
    ...    actCellTraceReportingCU    ${actCellTraceReport}
    ...    actPCMDReporting           ${actPCMDReport}
    ...    cellMaxActiveUEsTraced     100
    ...    jobType                    TraceOnly
    ...    nrTceIdentifier            1
    ...    scope                      allResources
    ...    traceE1Setting             ${trace_dict.traceE1Setting}
    ...    traceF1Setting             ${trace_dict.traceF1Setting}
    ...    traceNGAPSetting           ${trace_dict.traceNRRRCSetting}
    ...    traceNRRRCSetting          ${trace_dict.traceNRRRCSetting}
    ...    traceX2Setting             ${trace_dict.traceX2Setting}
    ...    traceXNSetting             ${trace_dict.traceXNSetting}
        Set Element    dist_name=${distname_NRMTRACECU}    p_name=${p_name}    value=${value}
    END
    Set List            dist_name=${distname_NRMTRACECU}     list_name=nrRanTraceReference
    Add Dict to List    dist_name=${distname_NRMTRACECU}     list_name=nrRanTraceReference          elements=${nrRanTraceReference_items}

    Set Object    class_name=com.nokia.srbts.nrbts:NRMTRACEDU
    ...           dist_name=${distname_NRMTRACEDU}
    ...           version=NRBTSCL24R3_2412_101
    FOR    ${p_name}    ${value}    IN
    ...    actPCMDReporting           ${actPCMDReport}
    ...    actRIReporting             false
    ...    cellMaxActiveUEsTraced     100
    ...    jobType                    TraceOnly
    ...    nrTceIdentifier            1
    ...    riReportInterval           s5
    ...    scope                      allResources
        Set Element    dist_name=${distname_NRMTRACEDU}    p_name=${p_name}    value=${value}
    END
    Set List            dist_name=${distname_NRMTRACEDU}     list_name=nrRanTraceReference
    Add Dict to List    dist_name=${distname_NRMTRACEDU}     list_name=nrRanTraceReference          elements=${nrRanTraceReference_items}

    Set Object    class_name=com.nokia.srbts.mnl:TCE
    ...           dist_name=${distname_TCE}
    ...           version=MNL24R3_2412_100
    FOR    ${p_name}    ${value}    IN
    ...    certTypeForTlsAuth         RSA
    ...    tceIdentifier              1
    ...    tceIpAddress               ${tceIpAddress}
    ...    tcePortNumber              ${tcePortNumber}
    ...    tlsEnabled                 false
        Set Element    dist_name=${distname_TCE}    p_name=${p_name}    value=${value}
    END


Set Vendor Default Perf Values
    performance_vendor.Modify Vendor File All Pname    miNrL2OvldRlcMac         5min    path_class=NRPMRNL     original_value=15min
    performance_vendor.Modify Vendor File All Pname    miNrL2PsOvldNrCellGrp    5min    path_class=NRPMRNL     original_value=15min


Set bbmodBoardConfigType
    [Arguments]    ${value}
    ${regex}    Set Variable    MRBTS-[0-9]+/EQM-[0-9]+/APEQM-[0-9]+/CABINET-[0-9]+/BBMOD-[0-9]+
    Set Regex SCF Element Values    bbmodBoardConfigType    ${value}    regex=${regex}

Set NRCELL Values
    [Arguments]    ${pname}    ${value}    ${mrbts}=[0-9]+    ${nrbts}=[0-9]+    ${nrcell}=[0-9]+    &{args}
    ${regex}    Set Variable    MRBTS-${mrbts}/NRBTS-${nrbts}/NRCELL-${nrcell}
    Set Regex SCF Element Values    ${pname}    ${value}    regex=${regex}

Set NRBTS Values
    [Arguments]    ${pname}    ${value}    ${mrbts}=[0-9]+    ${nrbts}=[0-9]+    &{args}
    ${regex}    Set Variable    MRBTS-${mrbts}/NRBTS-${nrbts}
    Set Regex SCF Element Values    ${pname}    ${value}    regex=${regex}

Set reportingIntervalPm value
    [Arguments]    ${value}=5min
    ${value}    Set Variable If    "${value}"=="true"    5min    ${value}
    ${regex}    Set Variable    MRBTS-[0-9]+/MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    Set Regex SCF Element Values    reportingIntervalPm    ${value}    regex=${regex}

Set tddFrameStructure
    [Arguments]    ${cell}=[0-9]+
    ...            ${frameStructureType}=tdLte
    ...            ${guardPeriodLength}=4Symbols
    ...            ${lteToNrFrameShift}=0ms
    ...            ${tdLteUlDlConfig}=tdLteConfig2
    ...            ${ulDlDataSlotRatio}=2/8
    ${distNames_NRCELL}=      Get distNames from Local SCF File  scf_path=${P_ORIG_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell}
    sort list    ${distNames_NRCELL}
    ${tddFrameStructure_items}=  create dictionary
    ...    frameStructureType                    ${frameStructureType}
    ...    guardPeriodLength                     ${guardPeriodLength}
    ...    lteToNrFrameShift                     ${lteToNrFrameShift}
    ...    tdLteUlDlConfig                       ${tdLteUlDlConfig}
    ...    ulDlDataSlotRatio                     ${ulDlDataSlotRatio}
    FOR  ${dist_name}  IN  @{distNames_NRCELL}
        Set List       dist_name=${dist_name}     list_name=tddFrameStructure
        Add Dict to List    dist_name=${dist_name}   list_name=tddFrameStructure   elements=${tddFrameStructure_items}
    END

Enable Beamforming
    Log to console     ${SPACE}- Enable Beamforming
    ${distNames_NRCELL}=      Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distNames_NRCELLGRP}=   Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELLGRP-[0-9]+
    sort list    ${distNames_NRCELL}
    sort list    ${distNames_NRCELLGRP}

    ${beamSet_items}=  create dictionary
    ...    basicBeamSet                    beamSet_6
    ...    leftEdgeAngle                   60            # default
    ...    lowerEdgeAngle                  135
    ...    nrBtsBeamRefinementP2           false         # default
    ...    rightEdgeAngle                  60            # default
    ...    upperEdgeAngle                  80

    FOR  ${dist_name}  IN  @{distNames_NRCELL}
        Set Element    dist_name=${dist_name}     p_name=actBeamforming                 value=true
        Set Element    dist_name=${dist_name}     p_name=numberOfRxBeamforming          value=4Rx

        Set List       dist_name=${dist_name}     list_name=beamSet
        Add Dict to List    dist_name=${dist_name}   list_name=beamSet   elements=${beamSet_items}
    END
    FOR  ${dist_name}  IN  @{distNames_NRCELLGRP}
        Set Element    dist_name=${dist_name}     p_name=numberOfTransmittedSsBlocks    value=6 beams
    END

Configure SRS
    [Arguments]    ${cell}=[0-9]+
    Log to console     ${SPACE}- Configure SRS for cell ${cell}
    ${distNames_NRCELL}=      Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-${cell}
    ${distNames_NRBTS}=    Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${srsForBeamMgmt_items}=  create dictionary
    ...        bSRS                       2
    ...        comb                       comb2
    ...        cSRS                       63
    ...        srsPowerThresholdForDlBm   -127
    ...        srsPowerThresholdForUlBm   -132
    ...        srsTypeAllocForDlBm        antenna switching or codebook
    ...        srsUePeriodicity           slots40
    ...        srsDlBeamFallbackOption    fallback once
    ...        srsUlBeamFallbackOption    fallback once
    FOR  ${dist_name}  IN  @{distNames_NRCELL}
        Set Element         dist_name=${dist_name}     p_name=actUlSrsBm                 value=false
        Set Element         dist_name=${dist_name}     p_name=actDlSrsBm                 value=false
        Set Element         dist_name=${dist_name}     p_name=dftBeamDiffThresholdH      value=15
        Set Element         dist_name=${dist_name}     p_name=dftBeamDiffThresholdV      value=15
        Set Element         dist_name=${dist_name}     p_name=mMimoAntArrayMode          value=Full 64TRX Array (4x8x2)

        Set List            dist_name=${dist_name}     list_name=srsForBeamMgmt
        Add Dict to List    dist_name=${dist_name}     list_name=srsForBeamMgmt          elements=${srsForBeamMgmt_items}
    END
    Set Element         dist_name=${distNames_NRBTS[0]}     p_name=actFdmEnhancedScheduling                 value=true

Enable CB008246
    Log to console     ${SPACE}- Enable CB008246
    Change Reporting Interval
    Enable CB008246 in SCF
    Update UE Capabilities for CB008246

Enable CB008246 in SCF
    ${distNames_NRCELL}=   Get distNames from Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distNames_NRCELL}
    Set Element    dist_name=${distNames_NRCELL[0]}    p_name=actLAForHiReliab            value=true
    Set Element    dist_name=${distNames_NRCELL[0]}    p_name=actCceSplit                 value=false
    Set Element    dist_name=${distNames_NRCELL[0]}    p_name=actUl256Qam                 value=false
    Set Element    dist_name=${distNames_NRCELL[0]}    p_name=actDl256Qam                 value=false
    Set Element    dist_name=${distNames_NRCELL[0]}    p_name=scalingStepdownHREnabled    value=true
    Configure CB008246 on PDSCH
    Configure CB008246 on PUSCH
    Configure CB008246 on PDCCH
    IF    "${TP.SCF_ENABLE_CB008246_STATIC}"=="true"
        Configure Static PDCCH
    ELSE
        Configure Dynamic PDCCH
    END

Enable BB Pooling
    Log to console     ${SPACE}- Enable BB Pooling
    Expect Duplex    TDD    msg=Enable BB Pooling

    ${distNames_NRBTS}=    Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distNames_NRCELL}=   Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distNames_NRBTS}
    sort list    ${distNames_NRCELL}
    Set Element    dist_name=${distNames_NRBTS[0]}     p_name=actBbPoolTddFr1                 value=true
    Set Element    dist_name=${distNames_NRBTS[0]}     p_name=actBbPoolTddFr1AlgEnh           value=true

    FOR  ${dist_name}  IN  @{distNames_NRCELL}
        Set Element      dist_name=${dist_name}      p_name=maxNumPdschAllocationPerSlot    value=16
        Set Element      dist_name=${dist_name}      p_name=maxNumPuschAllocationPerSlot    value=16
        Set Element      dist_name=${dist_name}      p_name=actShortBsrLimitAdaptation      value=true
        Set List Value   dist_name=${dist_name}      list_name=fPdcchMonOccsnPo             value=2
    END

    IF     "${TL_DATA['GNB_CU_TYPE']}" in ["ASOE"]      Enable BB Pooling Ext ASOE
    IF     "${TL_DATA['GNB_CU_TYPE']}" in ["ASOH"]      Enable BB Pooling Ext ASOH
    IF     "${TL_DATA['GNB_CU_TYPE']}" in ["ABIP"]      Enable BB Pooling Ext ABIP

Enable BB Pooling Ext ASOH
    Log to console     ${SPACE}- Enable BB Pooling Ext ASOH
    ${distNames_NRBTS}=    Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    sort list    ${distNames_NRBTS}
    Set Element    dist_name=${distNames_NRBTS[0]}                            p_name=actBbPoolTddFr1AlgEnh          value=true
    Set Element    dist_name=${distNames_NRBTS[0]}                            p_name=actLargeBbPoolTddFr1           value=true
    Set Element    dist_name=${distNames_NRBTS[0]}                            p_name=actBbPoolExtensionTddFr1       value=true
    Set Element    dist_name=${distNames_NRBTS[0]}/BWP_PROFILE-44/PDCCH-1     p_name=dciDedicatedAggregationLevel   value=AL2

Enable BB Pooling Ext ASOE
    Log to console     ${SPACE}- Enable BB Pooling Ext ASOE
    ${distNames_NRBTS}=    Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    sort list    ${distNames_NRBTS}
    Set Element    dist_name=${distNames_NRBTS[0]}                            p_name=actBbPoolTddFr1AlgEnh          value=true
    Set Element    dist_name=${distNames_NRBTS[0]}                            p_name=actLargeBbPoolTddFr1           value=true
    Set Element    dist_name=${distNames_NRBTS[0]}                            p_name=actBbPoolExtensionTddFr1       value=true
    Set Element    dist_name=${distNames_NRBTS[0]}/BWP_PROFILE-44/PDCCH-1     p_name=dciDedicatedAggregationLevel   value=AL2

Enable BB Pooling Ext ABIP
    Log to console     ${SPACE}- Enable BB Pooling Ext ABIP
    ${distNames_NRBTS}=    Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    Set Element    dist_name=${distNames_NRBTS[0]}     p_name=actLargeBbPoolTddFr1          value=true
    Set Element    dist_name=${distNames_NRBTS[0]}     p_name=actBbPoolExtensionTddFr1      value=true

Change Reporting Interval
    ${distName_NRPMRNL}=    Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrDlHarqLowSEMCS  miNrUlHarqLowSEMCS  miNrSignalQualityLowSEMCS
    FOR   ${pname}  IN   @{list_of_pm_groups}
        Set Element    dist_name=${distName_NRPMRNL[0]}    p_name=${pname}    value=5min
    END

Configure CB008246 on PDSCH
    ${distNames_NRBTS}=    Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distNames_NRCELL}=   Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distNames_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List      dist_name=${distNames_NRCELL[0]}  list_name=pdschHrLaConfig
    ${pdschHrLaConfig_item}=  create dictionary
    ...    dllaCqiOffsetHR                    0
    ...    dllaDeltaCqiMaxHR                150
    ...    dllaDeltaCqiMinHR               -150
    ...    dllaDeltaCqiStepdownHR            20
    ...    dllaIniDeltaCqiHR                -30
    ...    dllaIniMcsHR                       3
    ...    dllaMcsMax64qamLowSERANK1HR       28
    ...    dllaMcsMax64qamLowSERANK2HR       28
    ...    dllaMcsMax64qamLowSERANK3HR       28
    ...    dllaMcsMax64qamLowSERANK4HR       28
    ...    dllaMcsMax64qamRANK1HR            28
    ...    dllaMcsMax64qamRANK2HR            28
    ...    dllaMcsMax64qamRANK3HR            28
    ...    dllaMcsMax64qamRANK4HR            28
    Add Dict to List    dist_name=${distNames_NRCELL[0]}   list_name=pdschHrLaConfig   elements=${pdschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRPDSCHHRLA_1}=  Set Variable  ${distNames_NRBTS[0]}/NRPDSCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPDSCHHRLA
    ...           dist_name=${distName_NRPDSCHHRLA_1}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    dlHRBlerOutageMcsThresh64qamLowSE       2
    ...    dlHRBlerOutagePercentage               50
    ...    dlHRBlerOutagePeriod                   20
    ...    dlHRBlerRecoverMcsThresh64qamLowSE     11
    ...    dlHRBlerRecoverPercentage              60
    ...    dlHRBlerRecoverPeriod                  30
    ...    dllaBlerTargetHR                       10
    ...    dlHRBlerOutageMcsThresh64qam            1
    ...    dlHRBlerRecoverMcsThresh64qam           5
    ...    scalFactorForHRGbrDl                  110
        Set Element    dist_name=${distName_NRPDSCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element   dist_name=${distNames_NRBTS[0]}/NRDRB-11   p_name=nrPdschHRLaDN   value=${distNames_NRBTS[0]}/NRPDSCHHRLA-1


Configure CB008246 on PUSCH
    ${distNames_NRBTS}=    Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distNames_NRCELL}=   Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distNames_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List      dist_name=${distNames_NRCELL[0]}  list_name=puschHrLaConfig
    ${puschHrLaConfig_item}=  create dictionary
    ...    iniDeltaSinrHR                  -50
    ...    ullaDeltaSinrMaxHR              150
    ...    ullaDeltaSinrMinHR             -300
    ...    ullaDeltaSinrStepdownHR          20
    ...    ullaIniMcsHR                      0
    ...    ullaSinrOffsetHR                  0
    ...    ullaMcsMax64qamLowSERANK1HR      28
    ...    ullaMcsMax64qamLowSERANK2HR      28
    ...    ullaMcsMax64qamRANK1HR           28
    ...    ullaMcsMax64qamRANK2HR           28
    Add Dict to List    dist_name=${distNames_NRCELL[0]}   list_name=puschHrLaConfig   elements=${puschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRPUSCHHRLA_1}=  Set Variable  ${distNames_NRBTS[0]}/NRPUSCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPUSCHHRLA
    ...           dist_name=${distName_NRPUSCHHRLA_1}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    ulHRBlerOutagePercentage           50
    ...    ulHRBlerOutagePeriod               20
    ...    ulHRBlerOutageTbsThresh           500
    ...    ulHRBlerRecoverPercentage          60
    ...    ulHRBlerRecoverPeriod              30
    ...    ulHRBlerRecoverTbsThresh         4000
    ...    ullaBlerTargetHR                   10
    ...    scalFactorForHRGbrUl              110
    ...    ulHRBlerOutageTbsThresh64qam     1000
    ...    ulHRBlerRecoverTbsThresh64qam    7000
        Set Element    dist_name=${distName_NRPUSCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element   dist_name=${distNames_NRBTS[0]}/NRDRB-11   p_name=nrPuschHRLaDN   value=${distNames_NRBTS[0]}/NRPUSCHHRLA-1


Configure Static PDCCH
    ${distNames_PDCCH}=  Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}
    ...                                                    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]+/PDCCH-[0-9]+
    Sort List   ${distNames_PDCCH}
    FOR  ${dist_name}  IN  @{distNames_PDCCH}
        Set Element    dist_name=${dist_name}    p_name=alSelection                       value=static
        Set Element    dist_name=${dist_name}    p_name=dciDedicatedAggregationLevelHR    value=AL4
    END


Configure Dynamic PDCCH
    ${distNames_PDCCH}=  Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}
    ...                                                    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]+/PDCCH-[0-9]+
    Sort List   ${distNames_PDCCH}
    Set Element    dist_name=${distNames_PDCCH[1]}    p_name=alSelection                       value=dynamic
    Set Element    dist_name=${distNames_PDCCH[1]}    p_name=dciDedicatedAggregationLevel      value=AL4
    Set Element    dist_name=${distNames_PDCCH[1]}    p_name=dciDedicatedAggregationLevelHR    value=AL8
    Set List       dist_name=${distNames_PDCCH[1]}    list_name=dynamicAggregationLevelHRSet
    ${dynamicAggregationLevelHRSet_item}=  create dictionary
    ...    aggregationLevelListHR             AL2_AL4_AL8
    ...    cqiCorrectionUpHR                            2
    ...    cqiDciCssAl1HR                             106
    ...    cqiDciCssAl2HR                              74
    ...    cqiDciCssAl4HR                              45
    ...    cqiDciCssAl8HR                              37
    ...    cqiDciCssAl16HR                              0
    ...    highOlcCqiOffsetHR                          50
    ...    lowOlcCqiOffsetHR                         1100
    ...    pCqiErasureActTimerHR                      160
    ...    pCqiErasureReductionHR                      10
    ...    pdcchCqiOffsetHR                            10
    Add Dict to List   dist_name=${distNames_PDCCH[1]}   list_name=dynamicAggregationLevelHRSet   elements=${dynamicAggregationLevelHRSet_item}
    Set List      dist_name=${distNames_PDCCH[1]}  list_name=dynamicAggregationLevelSet
    ${dynamicAggregationLevelSet_item}=  create dictionary
    ...    aggregationLevelList                   AL4_AL8
    ...    cqiCorrectionUp                             10
    ...    cqiDciCssAl1                                80
    ...    cqiDciCssAl2                                40
    ...    cqiDciCssAl4                                20
    ...    cqiDciCssAl8                                10
    ...    cqiDciCssAl16                                0
    ...    highOlcCqiOffset                             1
    ...    lowOlcCqiOffset                              1
    ...    pCqiErasureActTimer                          0
    ...    pCqiErasureReduction                         0
    Add Dict to List    dist_name=${distNames_PDCCH[1]}   list_name=dynamicAggregationLevelSet   elements=${dynamicAggregationLevelSet_item}


Configure CA Ramp
    [Documentation]    ramp test, only cell 1 and 3
    Log to console     ${SPACE}- Configure CA Ramp
    Expect Duplex    TDD    msg=Configure CA Ramp
    Set Regex SCF Element Values    caConfigurationSupport    2CCDL_2CCUL    regex=MRBTS-[0-9]+/NRBTS-[0-9]+                     padding=${4}
    Set Regex SCF Element Values    actCarrierAggregation     true           regex=MRBTS-[0-9]+/NRBTS-[0-9]+                     padding=${4}
    Set Regex SCF Element Values    lcrId                     3              regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-1/NRREL-1    padding=${4}
    ${nrbts}    perf_distnames.Get NRBTS Distnames
    Remove Object                   ${nrbts[0]}/NRCELL-1/NRREL-2
    Remove Object                   ${nrbts[0]}/NRCELL-2/NRREL-1

    ${nrcell3nrrel1}    Set Variable    MRBTS-1/NRBTS-1/NRCELL-3/NRREL-1
    Set Object    com.nokia.srbts.nrbts:NRREL    ${nrcell3nrrel1}    version="NRBTSCL25R1_2416_101"
    FOR    ${p_name}    ${value}    IN
    ...    cellIndividualSsbRsrpOffset             0dB
    ...    cellIndividualSsbRsrqOffset             0dB
    ...    gNbId                                   1
    ...    gNbIdLength                             22
    ...    handoverAllowedSA                       allowed
    ...    handoverAllowedSARedCap                 forbidden
    ...    isRplCellForPSCell                      false
    ...    lcrId                                   1
    ...    nrDcAllowed                             false
    ...    removeNotAllowed                        false
    ...    sCellAdditionMethod                     blind
    ...    sCellOperationalMode                    dlOnly
    ...    gNbId                                   1
    ...    gNbId                                   1
        Set Element    dist_name=${nrcell3nrrel1}    p_name=${p_name}    value=${value}
    END
    Set List   dist_name=${nrcell3nrrel1}   list_name=gnbPlmn
    ${gnbPlmn_item1}=  Create Dictionary
    ...      mcc                    311
    ...      mnc                    489
    ...      mncLength              3
    Add Dict to List  dist_name=${nrcell3nrrel1}  list_name=gnbPlmn  elements=${gnbPlmn_item1}


Configure PDCCH Resource Increase
    [Documentation]    ramp tests
    ${distNames_PDCCH_CONFIG_DEDICATED}=  Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}
    ...                                  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+/PDCCH_CONFIG_DEDICATED-[0-9]+

    Set List   dist_name=${distNames_PDCCH_CONFIG_DEDICATED[0]}   list_name=coresetDedicated
    ${coresetDedicated_item1}=  Create Dictionary
    ...      cceToRegMapping                    nonInterleaved
    ...      coresetId                          1
    ...      cRbStart                           0
    ...      duration                           1
    ...      interleaverSize                    none
    ...      regBundleSize                      n6
    ...      size                               264
    Add Dict to List  dist_name=${distNames_PDCCH_CONFIG_DEDICATED[0]}  list_name=coresetDedicated  elements=${coresetDedicated_item1}

    Set List   dist_name=${distNames_PDCCH_CONFIG_DEDICATED[0]}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0_1
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n1
    ...      numOfPdcchCandidatesInAL8    n0
    ...      periodicity                  sl1
    ...      searchSpaceId                7
    ...      searchSpaceType              Type3
    ...      slotOffset                   0
    Add Dict to List  dist_name=${distNames_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    ${searchSpaceDedicated_item2}=  Create Dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0_1
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      numOfPdcchCandidatesInAL2    n6
    ...      numOfPdcchCandidatesInAL4    n1
    ...      numOfPdcchCandidatesInAL8    n0
    ...      periodicity                  sl1
    ...      searchSpaceId                8
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   0
    Add Dict to List  dist_name=${distNames_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}


Configure BWP_PDCCH_CONFIG_DEDICATED
    ${distNames_PDCCH_CONFIG_DEDICATED}=  Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}
    ...                                  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]{2}/PDCCH-[0-9]+/PDCCH_CONFIG_DEDICATED-[0-9]+

    Set List   dist_name=${distNames_PDCCH_CONFIG_DEDICATED[0]}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0_1
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                7
    ...      searchSpaceType              Type3
    ...      slotOffset                   0
    Add Dict to List  dist_name=${distNames_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    ${searchSpaceDedicated_item2}=  Create Dictionary
    ...      coresetId                    1
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_0_1
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n5
    ...      numOfPdcchCandidatesInAL4    n5
    ...      numOfPdcchCandidatesInAL8    n1
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                8
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   0
    Add Dict to List  dist_name=${distNames_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}

Configure CB008246 on PDCCH
    ${distNames_NRBTS}=    Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    sort list    ${distNames_NRBTS}
    ${distName_NRPDCCHHRLA_1}=  set variable  ${distNames_NRBTS[0]}/NRPDCCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPDCCHHRLA
    ...           dist_name=${distName_NRPDCCHHRLA_1}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    pdcchHRBlerOutagePercentage             50
    ...    pdcchHRBlerOutagePeriod                 20
    ...    pdcchHRBlerRecoverPercentage            60
        Set Element    dist_name=${distName_NRPDCCHHRLA_1}    p_name=${p_name}    value=${value}
    END

    Set Element   dist_name=${distNames_NRBTS[0]}/NRDRB-11   p_name=nrPdcchHRLaDN   value=${distNames_NRBTS[0]}/NRPDCCHHRLA-1

Set Regex SCF List Values
    [Arguments]    ${regex}    ${list_name}    ${value}     ${p_name}=${none}    ${padding}=${1}
    ${msg}    Format String    {: >${padding}}- Set {} to {}    ${EMPTY}    ${list_name}/${p_name}    ${value}
    Log    ${msg}    console=${P_scf_console}
    ${dist_names}=      Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=${regex}
    Should Not Be Empty    ${dist_names}    msg=distname cannot be empty!
    Sort List    ${distNames}
    FOR    ${dist_name}    IN     @{dist_names}
        Set List Value    ${dist_name}    ${list_name}    ${value}    p_name=${p_name}    padding=${padding+4}
    END

Set Regex SCF Element Values
    [Arguments]    ${p_name}    ${value}    ${regex}    ${scf_path}=${P_UNIQUE_SCF}    ${padding}=${1}
    ${msg}    Format String    {: >${padding}}- Set {} to {}    ${EMPTY}    ${p_name}    ${value}
    Log    ${msg}    console=${P_scf_console}
    ${distNames}=      Get DistNames From Local SCF File  scf_path=${scf_path}    regex=${regex}
    Should Not Be Empty    ${dist_names}    msg=distname cannot be empty!
    Sort List    ${distNames}

    FOR  ${dist_name}  IN  @{distNames}
        Set Element         dist_name=${dist_name}     p_name=${p_name}    value=${value}    padding=${padding+4}
    END

Remove Regex SCF List Values
    [Arguments]    ${regex}    ${list_name}     ${p_name}=${none}    ${padding}=${1}
    ${msg}    Format String    {: >${padding}}- Remove {}    ${EMPTY}    ${list_name}/${p_name}
    Log    ${msg}    console=${P_scf_console}
    ${dist_names}=      Get DistNames From Local SCF File  scf_path=${P_UNIQUE_SCF}    regex=${regex}
    Should Not Be Empty    ${dist_names}    msg=distname cannot be empty!
    Sort List    ${distNames}
    FOR    ${dist_name}    IN     @{dist_names}
        Remove List    ${dist_name}    ${list_name}    padding=${padding+4}
    END

Remove Regex SCF Element Values
    [Arguments]    ${p_name}    ${regex}    ${scf_path}=${P_UNIQUE_SCF}    ${padding}=${1}
    ${msg}    Format String    {: >${padding}}- Remove {}    ${EMPTY}    ${p_name}
    Log    ${msg}    console=${P_scf_console}
    ${distNames}=      Get DistNames From Local SCF File  scf_path=${scf_path}    regex=${regex}
    Should Not Be Empty    ${dist_names}    msg=distname cannot be empty!
    Sort List    ${distNames}

    FOR  ${dist_name}  IN  @{distNames}
        Remove Element    dist_name=${dist_name}     p_name=${p_name}    padding=${padding+4}
    END

Set Element
    [Documentation]    modify parameter if exists, otherwise add it
    [Arguments]      ${dist_name}   ${p_name}   ${value}       ${padding}=${4}
    ${element_exist}=         scf.Is Element In Object  dist_name=${dist_name}    p_name=${p_name}
    ${status}   ${readValue}   Run Keyword And Ignore Error   scf.Get Value From Scf
    ...                                                       dist_name=${dist_name}
    ...                                                       p_name=${p_name}
    ${readValue}    Set Variable If     "${status}"=="PASS"    ${readValue}    ${empty}
    IF    ${element_exist}
        scf.Modify Scf Element    dist_name=${dist_name}    p_name=${p_name}     value=${value}
    ELSE
        scf.Add Element To Scf    dist_name=${dist_name}    p_name=${p_name}     value=${value}
    END

    ${msg}    Format String    {: >${padding}}- Set {} to {} {}    ${EMPTY}    ${dist_name}/${p_name}    ${value}    (orig.: ${readValue})
    Log    ${msg}    console=${P_scf_console}
    Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Set List
    [Arguments]      ${dist_name}   ${list_name}    ${padding}=${4}
    ${list_exist}=            scf.Is List In Object     dist_name=${dist_name}         list_name=${list_name}
    IF    ${list_exist}             scf.Remove List From Scf       dist_name=${dist_name}        list_name=${list_name}
    scf.Add List To Scf       dist_name=${dist_name}    list_name=${list_name}
    ${msg}    Format String    {: >${padding}}- Reset {}      ${EMPTY}    ${dist_name}/${list_name}
    Log    ${msg}    console=${P_scf_console}
    Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Set Object
    [Arguments]      ${class_name}   ${dist_name}   ${version}=${NIDD_VERSION}    ${padding}=${4}
    ${mo_exist}=              scf.is_object_in_scf      dist_name=${dist_name}
    IF    ${mo_exist}    scf.remove_mo_with_descendant_mos  dist_name=${dist_name}
    scf.Add Object To Scf     class_name=${class_name}  dist_name=${dist_name}             version=${version}
    ${msg}    Format String    {: >${padding}}- Reset {}      ${EMPTY}    (${class_name}) ${dist_name}
    Log    ${msg}    console=${P_scf_console}
    Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Set List Value
    [Arguments]      ${dist_name}    ${list_name}    ${value}    ${p_name}=${none}    ${padding}=${4}
    Log    dist_name:${dist_name}, list_name:${list_name}, value:${value}, p_name:${p_name}    console=False    level=DEBUG
    ${list_exist}=            scf.Is List In Object  dist_name=${dist_name}     list_name=${list_name}

    IF    not ${list_exist}
        Log    [Set List Value Failed] list_name:${dist_name}, list_name:${list_name}, value:${value}, p_name:${p_name}    level=WARN
        RETURN    ${none}
    END

    ${status}   ${readValue}   Run Keyword And Ignore Error   scf.Get All Values From Scf
    ...                                                       dist_name=${dist_name}    list_name=${list_name}
    ...                                                       p_name=${p_name}
    ${readValue}    Set Variable If     "${status}"=="PASS"    ${readValue}    ${empty}

    scf.Modify Scf Element    dist_name=${dist_name}    list_name=${list_name}    p_name=${p_name}     value=${value}

    ${msg}    Format String    {: >${padding}}- Set {} to {} {}    ${EMPTY}    ${dist_name}/${list_name}/${p_name}
    ...                                                            ${value}    (orig.: ${readValue})
    Log    ${msg}    console=${P_scf_console}
    Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Add Dict to List
    [Arguments]    ${dist_name}    ${list_name}    ${elements}    ${padding}=${4}
    ${msg}    Format String    {: >${padding}}- Add to list {}:     ${EMPTY}    ${dist_name}/${list_name}
    Log    ${msg}    console=${P_scf_console}
    FOR    ${key}    IN    @{elements}
        ${status}   ${readValue}   Run Keyword And Ignore Error   scf.Get Value From Scf
        ...                                                       dist_name=${dist_name}
        ...                                                       list_name=${list_name}
        ...                                                       p_name=${key}
        ${readValue}    Set Variable If     "${status}"=="PASS"    ${readValue}    ${empty}

        ${msg}    Format String    {: >${padding+4}}- Set {} to {} {}     ${EMPTY}    ${dist_name}/${list_name}/${key}
        ...                                                               ${elements['${key}']}    (orig.: ${readValue})
        Log    ${msg}    console=${P_scf_console}
    END
    scf.Add Item To List  dist_name=${dist_name}  list_name=${list_name}  elements=${elements}
    Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Remove List
    [Arguments]      ${dist_name}    ${list_name}    ${padding}=${4}
    ${list_exist}=            scf.Is List In Object  dist_name=${dist_name}     list_name=${list_name}
    IF    not ${list_exist}
        ${msg}    Format String    {: >${padding}}- Remove {}    ${EMPTY}    ${dist_name}/${list_name} (not exists!)
        Log    ${msg}    console=${P_scf_console}
        RETURN    ${none}
    END
    scf.Remove List From Scf    dist_name=${dist_name}    list_name=${list_name}
    ${msg}    Format String    {: >${padding}}- Remove {}    ${EMPTY}    ${dist_name}/${list_name}
    Log    ${msg}    console=${P_scf_console}
    Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Remove Object
    [Arguments]               ${dist_name}    ${padding}=${4}
    ${mo_exist}=              scf.is_object_in_scf      dist_name=${dist_name}
    IF    not ${mo_exist}
        Log    [Remove Object Failed] dist_name:${dist_name}    level=WARN
        RETURN    ${none}
    END

    scf.remove_mo_with_descendant_mos  dist_name=${dist_name}
    ${msg}    Format String    {: >${padding}}- Remove {}    ${EMPTY}    ${dist_name}
    Log    ${msg}    console=${P_scf_console}
    Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Remove Element
    [Documentation]   removes element if exists
    [Arguments]      ${dist_name}   ${p_name}    ${padding}=${4}
    ${element_exist}=         scf.Is Element In Object       dist_name=${dist_name}    p_name=${p_name}
    IF    not ${element_exist}
        ${msg}    Format String    {: >${padding}}- Remove {}    ${EMPTY}    ${dist_name}/${p_name} (not exists!)
        Log    ${msg}    console=${P_scf_console}
        RETURN    ${none}
    END
    scf.Remove Element From Scf    dist_name=${dist_name}    p_name=${p_name}
    ${msg}    Format String    {: >${padding}}- Remove {}    ${EMPTY}    ${dist_name}/${p_name}
    Log    ${msg}    console=${P_scf_console}
    Set Suite Variable    $GNB_SCF_IS_MODIFIED    ${TRUE}

Wait for RU
    [Arguments]    ${timeout}=5min
    Log                           \nWaiting for RU    console=${P_console}
    TRY
        Wait Until Keyword Succeeds   ${timeout}   20s    Verify All Radios Are Online    connection=${OAM_ALIAS}
    EXCEPT    AssertionError.*AdminApiProcedureFailureException
        Fail    Radio Unit is not ready after ${timeout}!
    END


Activate BSR
    [Arguments]    ${BSR_package}=auto
    IF    "${BSR_package}"=="auto"
        bsr_package_installation.Install All BSR Packages Found In SCF
    ELSE
        Log    BSR Package: ${BSR_package}
        bsr_package_installation.Install All BSR Packages Found In SCF    force_zip=${BSR_package}
    END


Admin Command
    [Arguments]    ${distname_regex}    ${command}    ${timeout}=60    &{kwargs}
    ${oam_alias}        connect.Setup OAM HTTP Session
    ${distnames}        gnb.Get DistNames From Local SCF File      scf_path=${P_ORIG_SCF}
    ...                 regex=${distname_regex}
    Sort List           ${distnames}

    Wait For RU
    Log to Console      \nadmin.${command}: \n${SPACE}- ${distnames}
    Run Keyword         admin.${command}    dist_name=${distnames}
    ...                                     connection=${oam_alias}
    ...                                     detailed_output=${True}
    ...                                     timeout=${timeout}
    ...                                     &{kwargs}


Realtime Update SCF Parameter
    [Arguments]    ${regex}    ${parameter}    ${value}    ${index}=0    &{kwargs}
    ${dist_names}=    gnb.Get DistNames From Local SCF File    scf_path=${P_ORIG_SCF}    regex=${regex}
    Sort List         ${dist_names}
    Log to console    Update SCF Parameter:\n - ${dist_names[${index}]}/${parameter}/${value}
    coam_ulm.Update SCF Parameter    ${value}    dist_name=${dist_names[${index}]}    parameter=${parameter}    &{kwargs}
