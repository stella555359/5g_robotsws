*** Settings ***

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Commissioning for CB012118

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library   taf.config.scf
Resource  CB012118_Keywords.robot

*** Keywords ***

Commissioning for A
    [Documentation]    Activate B1 measurement
    ${config_dir}=    Get test suite config directory
    scf.load_scf    ${P_ORIG_SCF}
    Get Val from SCF
    FOR   ${dist_name}                                     ${p_name}                                          ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                  actRedirect                                        true
    ...   MRBTS-1/NRBTS-1                                  actVoFallBackLteB1MeaBaRedir                       true
    ...   MRBTS-1/NRBTS-1                                  b1RedirSupervisionTimer                            1000
    ...   MRBTS-1/NRBTS-1                                  actInterRatHoSA                                    true
    ...   MRBTS-1/NRBTS-1                                  actPCMDReport                                      true
    ...   MRBTS-1/NRBTS-1                                  drbInactivityTimerSA                               600
    ...   MRBTS-1/NRBTS-1/NRCELL-1                         voiceFBMode                                        redirection
    ...   MRBTS-1/NRBTS-1/NRCELL-1                         actCDrx                                            true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                         actVoNR                                            false
    ...   MRBTS-1/NRBTS-1                                  actNormVCFallback                                  true
    ...   MRBTS-1/NRBTS-1/NRPMRNL-1                        miNrRRCC                                           5min
    ...   MRBTS-1/NRBTS-1/NRCELL-1                         measGapSelectionSA                                 favourUeThroughput
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Add NRHOIR to NRBTS-1  cell_index=1
    Add NRRELE-1 to NRCELL  cell_index=1
    Add NRADJECELL-1 to NRBTS-1
    Add Trace Control Entity
    Add Radio CU Trace Session
    scf.save_scf                    ${config_dir}/scf_12118-A.xml
    Execute full commissioning      ${config_dir}/scf_12118-A.xml

Commissioning for Sub-feature B
    [Documentation]
    ${config_dir}=    Get test suite config directory
    scf.load_scf    ${P_ORIG_SCF}
    Get Val from SCF
    FOR   ${dist_name}                              ${p_name}                                       ${value}                   IN
    ...   MRBTS-1/NRBTS-1                           actRedirect                                     true
    ...   MRBTS-1/NRBTS-1                           actNormVCFallback                               true
    ...   MRBTS-1/NRBTS-1                           actVoFallBackLteB1MeaBaRedir                    true
    ...   MRBTS-1/NRBTS-1                           b1RedirSupervisionTimer                         5000
    ...   MRBTS-1/NRBTS-1                           actMeasurementProfile                           SA+NSA
    ...   MRBTS-1/NRBTS-1                           actRfspIndex                                    true
    ...   MRBTS-1/NRBTS-1                           actRanSharing                                   true
    ...   MRBTS-1/NRBTS-1                           actMobilityProfile                              false
    ...   MRBTS-1/NRBTS-1                           actEmergencyFallback                            true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  emergencyFBMode                                 redirection
    ...   MRBTS-1/NRBTS-1/NRCELL-2                  emergencyFBMode                                 redirection
    ...   MRBTS-1/NRBTS-1/NRCELL-3                  emergencyFBMode                                 redirection
    ...   MRBTS-1/NRBTS-1/NRCELL-4                  emergencyFBMode                                 redirection
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  voiceFBMode                                     redirection
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  actCDrx                                         true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  actVoNR                                         false
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  actEnhancedVoNR                                 false
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  actMaxInitDeltaCqiClampVoNR                     false
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  actTargetBlerVoNR                               false
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  actVoNRIncCodingGain                            false
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  measGapSelectionSA                              favourUeThroughput
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  a2MeasRedirectEnabled                           rsrpCombined
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  nrDefMoPrSaDN                                   MRBTS-1/NRBTS-1/NRMOPR_SA-2
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  nrDefMoPrNsaDN                                  MRBTS-1/NRBTS-1/NRMOPR_NSA-1
    ...   MRBTS-1/NRBTS-1/NRCELL-2                  nrDefMoPrNsaDN                                  MRBTS-1/NRBTS-1/NRMOPR_NSA-1
    ...   MRBTS-1/NRBTS-1/NRCELL-3                  nrDefMoPrNsaDN                                  MRBTS-1/NRBTS-1/NRMOPR_NSA-1
    ...   MRBTS-1/NRBTS-1/NRCELL-4                  nrDefMoPrNsaDN                                  MRBTS-1/NRBTS-1/NRMOPR_NSA-1
          Set Element    dist_name=${dist_name}     p_name=${p_name}   value=${value}
    END
    scf.Remove Element From SCF     dist_name=MRBTS-1/NRBTS-1/NRCELL-1     p_name=n310VoNR
    ${dist_name}=                   Set Variable                    MRBTS-1/NRBTS-1/NRCELL-1
    Set New List                    dist_name=${dist_name}          list_name=b1RedirectList
    ${b1RedirectList_dict}          Create dictionary               b1measPriority                      2
    ...                                                             nrhoirRedirDN                       MRBTS-1/NRBTS-1/NRHOIR-1
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1RedirectList            elements=${b1RedirectList_dict}
    ${b1RedirectList_dict}          Create dictionary               b1measPriority                      1
    ...                                                             nrhoirRedirDN                       MRBTS-1/NRBTS-1/NRHOIR-2
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1RedirectList            elements=${b1RedirectList_dict}
    Set New List                    dist_name=${dist_name}          list_name=nrhoirDNList
    ${param_list}=                  Create List                     MRBTS-1/NRBTS-1/NRHOIR-1
    scf.add_elements_to_list        dist_name=${dist_name}          list_name=nrhoirDNList              elements=${param_list}
    ${param_list}=                  Create List                     MRBTS-1/NRBTS-1/NRHOIR-2
    scf.add_elements_to_list        dist_name=${dist_name}          list_name=nrhoirDNList              elements=${param_list}
    ${param_list}=                  Create List                     MRBTS-1/NRBTS-1/NRHOIR-3
    scf.add_elements_to_list        dist_name=${dist_name}          list_name=nrhoirDNList              elements=${param_list}
    ${param_list}=                  Create List                     MRBTS-1/NRBTS-1/NRHOIR-4
    scf.add_elements_to_list        dist_name=${dist_name}          list_name=nrhoirDNList              elements=${param_list}
    ${param_list}=                  Create List                     MRBTS-1/NRBTS-1/NRHOIR-5
    scf.add_elements_to_list        dist_name=${dist_name}          list_name=nrhoirDNList              elements=${param_list}
    Set New List                    dist_name=${dist_name}          list_name=measPrMaSAList
    ${measPrMaSAList_dict}          Create dictionary               measPrPriority                 1
    ...                                                             nrMeasPrMaSADN                 MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1
    scf.add_item_to_list            dist_name=${dist_name}          list_name=measPrMaSAList       elements=${measPrMaSAList_dict}
    ${measPrMaSAList_dict}          Create dictionary               measPrPriority                 2
    ...                                                             nrMeasPrMaSADN                 MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2
    scf.add_item_to_list            dist_name=${dist_name}          list_name=measPrMaSAList       elements=${measPrMaSAList_dict}
    ${measPrMaSAList_dict}          Create dictionary               measPrPriority                 3
    ...                                                             nrMeasPrMaSADN                 MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=measPrMaSAList       elements=${measPrMaSAList_dict}
    ${measPrMaSAList_dict}          Create dictionary               measPrPriority                 4
    ...                                                             nrMeasPrMaSADN                 MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-4
    scf.add_item_to_list            dist_name=${dist_name}          list_name=measPrMaSAList       elements=${measPrMaSAList_dict}
    Add NRHOIR Instance to NRBTS   id=1   earfcnValue=2000   widebandRsrqMeas=true   b1MeasRedirectEnabled=rsrpCombined
    Add NRHOIR Instance to NRBTS   id=2   earfcnValue=3000   widebandRsrqMeas=false   b1MeasRedirectEnabled=rsrqCombined
    Add NRHOIR Instance to NRBTS   id=3   earfcnValue=1350   widebandRsrqMeas=true   b1MeasRedirectEnabled=none
    Add NRHOIR Instance to NRBTS   id=4   earfcnValue=300   widebandRsrqMeas=false   b1MeasRedirectEnabled=rsrpCombined
    Add NRHOIR Instance to NRBTS   id=5   earfcnValue=900   widebandRsrqMeas=true   b1MeasRedirectEnabled=rsrqCombined
    Enable A2 and B1 measurement configuration for Sub-feature B   id=1
    Add NRRELE Instance to NRCELL  cell_id=1   rele_id=1   lcrId=1
    Add NRRELE Instance to NRCELL  cell_id=1   rele_id=2   lcrId=2
    Add NRRELE Instance to NRCELL  cell_id=1   rele_id=3   lcrId=3
    Add NRRELE Instance to NRCELL  cell_id=1   rele_id=4   lcrId=4
    Add NRRELE Instance to NRCELL  cell_id=1   rele_id=5   lcrId=5
    Add NRADJECELL Instance to NRBTS-1   id=1   earfcnValue=2000   lcrId=1   physCellId=11
    Add NRADJECELL Instance to NRBTS-1   id=2   earfcnValue=3000   lcrId=2   physCellId=12
    Add NRADJECELL Instance to NRBTS-1   id=3   earfcnValue=1350   lcrId=3   physCellId=13
    Add NRADJECELL Instance to NRBTS-1   id=4   earfcnValue=300   lcrId=4   physCellId=14
    Add NRADJECELL Instance to NRBTS-1   id=5   earfcnValue=900   lcrId=5   physCellId=15
    Add NRMEAS_PROFILE to NRBTS-1  id=1
    Add SNSSAI to NRBTS-1 and Update MOC in TA  id=2  sd=13714342   ta=MRBTS-1/NRBTS-1/TRACKINGAREA-200
    Add SNSSAI to NRBTS-1 and Update MOC in TA  id=3  sd=13714343   ta=MRBTS-1/NRBTS-1/TRACKINGAREA-200
    Add Mobility Profile to NRBTS-1
    Add A1 and A2 measurement SSB RSRP RSRQ for handover SA at NRCELLs  cell_count=4
    scf.save_scf                    ${config_dir}/scf_12118-B_mod.xml
    Execute full commissioning      ${config_dir}/scf_12118-B_mod.xml

Add A1 and A2 measurement SSB RSRP RSRQ for handover SA at NRCELLs
    [Arguments]    ${cell_count}
    FOR    ${cell_id}    IN RANGE    1    ${${cell_count}+1}
        ${dist_name}=                   Set Variable                    MRBTS-1/NRBTS-1/NRCELL-${cell_id}
        Set New List                    dist_name=${dist_name}          list_name=a1MeashoSsbRsrpSA
        ${a1MeashoSsbRsrpSA}            Create dictionary               a1HysteresishoSsbRsrpSA             0
        ...                                                             a1ThresholdhoSsbRsrpSA              60
        ...                                                             a1TimeToTriggerhoSsbRsrpSA          ms480
        scf.add_item_to_list            dist_name=${dist_name}          list_name=a1MeashoSsbRsrpSA         elements=${a1MeashoSsbRsrpSA}
        Set New List                    dist_name=${dist_name}          list_name=a1MeashoSsbRsrqSA
        ${a1MeashoSsbRsrqSA}            Create dictionary               a1HysteresishoSsbRsrqSA             0
        ...                                                             a1ThresholdhoSsbRsrqSA              63
        ...                                                             a1TimeToTriggerhoSsbRsrqSA          ms480
        scf.add_item_to_list            dist_name=${dist_name}          list_name=a1MeashoSsbRsrqSA         elements=${a1MeashoSsbRsrqSA}
        Set New List                    dist_name=${dist_name}          list_name=a2MeashoSsbRsrpSA
        ${a2MeashoSsbRsrpSA}            Create dictionary               a2HysteresishoSsbRsrpSA             0
        ...                                                             a2ThresholdhoSsbRsrpSA              34
        ...                                                             a2TimeToTriggerhoSsbRsrpSA          ms480
        scf.add_item_to_list            dist_name=${dist_name}          list_name=a2MeashoSsbRsrpSA         elements=${a2MeashoSsbRsrpSA}
        Set New List                    dist_name=${dist_name}          list_name=a2MeashoSsbRsrqSA
        ${a2MeashoSsbRsrqSA}            Create dictionary               a2HysteresishoSsbRsrqSA             0
        ...                                                             a2ThresholdhoSsbRsrqSA              49
        ...                                                             a2TimeToTriggerhoSsbRsrqSA          ms480
        scf.add_item_to_list            dist_name=${dist_name}          list_name=a2MeashoSsbRsrqSA         elements=${a2MeashoSsbRsrqSA}
    END

Add Mobility Profile to NRBTS-1
    Add NRMORED MOC to NRBTS-1   id=1   redirFreqEutra=6300   redirPrio=2
    Add NRMORED MOC to NRBTS-1   id=2   redirFreqEutra=3625   redirPrio=1
    Add NRMEASCFG_IR MOC to NRBTS-1   id=1   b1MeasRedirectEnabled=rsrqCombined   earfcnValue=2000
    Add NRMEASCFG_IR MOC to NRBTS-1   id=2   b1MeasRedirectEnabled=rsrpCombined   earfcnValue=3000
    Add NRMEASCFG_IR MOC to NRBTS-1   id=3   b1MeasRedirectEnabled=rsrqCombined   earfcnValue=300
    Add NRMEASCFG_IR MOC to NRBTS-1   id=4   b1MeasRedirectEnabled=rsrpCombined   earfcnValue=900
    Add NRMOPR_SA MOC to NRBTS-1   id=1  voiceFBMode=redirection  nrmeascfg_ir1=3  nrmeascfg_ir2=4  nrmored_id=1  a2MeasRedirectEnabled=rsrpCombined
    Add NRMOPR_SA MOC to NRBTS-1   id=2  voiceFBMode=redirection  nrmeascfg_ir1=4  nrmeascfg_ir2=2  nrmored_id=2  a2MeasRedirectEnabled=rsrqCombined
    Add NRMOPR_SA MOC to NRBTS-1   id=3  voiceFBMode=disabled  nrmeascfg_ir1=3  nrmeascfg_ir2=1  nrmored_id=1  a2MeasRedirectEnabled=rsrpAndRsrq
    Add NRMOPR_SA MOC to NRBTS-1   id=4  voiceFBMode=redirection  nrmeascfg_ir1=1  nrmeascfg_ir2=4  nrmored_id=1  a2MeasRedirectEnabled=rsrp
    Add NRMOPR_SA MOC to NRBTS-1   id=5  voiceFBMode=redirection  nrmeascfg_ir1=2  nrmeascfg_ir2=3  nrmored_id=1  a2MeasRedirectEnabled=rsrq
    Add NRMOPRMA_SA MOC to NRBTS-1   id=1   mobilityProfilePriority=1  slice_id=1  rfspIndex=100  rfspIndexLast=110
    Add NRMOPRMA_SA MOC to NRBTS-1   id=2   mobilityProfilePriority=10  slice_id=1  rfspIndex=100  rfspIndexLast=110
    Add NRMOPRMA_SA MOC to NRBTS-1   id=3   mobilityProfilePriority=2  slice_id=2  rfspIndex=100  rfspIndexLast=110
    Add NRMOPRMA_SA MOC to NRBTS-1   id=4   mobilityProfilePriority=3  slice_id=3  rfspIndex=100  rfspIndexLast=110
    Add NRMOPRMA_SA MOC to NRBTS-1   id=5   mobilityProfilePriority=4  slice_id=3  rfspIndex=1  rfspIndexLast=10
    Add NRMOPRMA_NSA MOC to NRBTS-1   id=1   mobilityProfilePriority=15
    Add NRMOPR_NSA MOC to NRBTS-1   id=1

Add NRMOPRMA_NSA MOC to NRBTS-1
    [Arguments]    ${id}   ${mobilityProfilePriority}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPRMA_NSA-${id}
    Set Object    class_name=NRMOPRMA_NSA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   mobilityProfilePriority       ${mobilityProfilePriority}
    ...   nrMoPrNsaDN                   MRBTS-1/NRBTS-1/NRMOPR_NSA-${id}
    ...   spid                          1
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRMOPR_NSA MOC to NRBTS-1
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPR_NSA-${id}
    Set Object    class_name=NRMOPR_NSA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   a1MeashoEnabled               none
    ...   a2MeashoEnabled               none
    ...   a3MeasEnabled                 none
    ...   a5MeasEnabled                 none
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRMOPRMA_SA MOC to NRBTS-1
    [Arguments]    ${id}   ${mobilityProfilePriority}   ${slice_id}   ${rfspIndex}   ${rfspIndexLast}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPRMA_SA-${id}
    Set Object    class_name=NRMOPRMA_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   mobilityProfilePriority       ${mobilityProfilePriority}
    ...   nrMoPrSaDN                    MRBTS-1/NRBTS-1/NRMOPR_SA-${id}
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    IF    ${id} != 2
        Set Element    dist_name=${dist_name}    p_name=rfspIndex        value=${rfspIndex}
        Set Element    dist_name=${dist_name}    p_name=rfspIndexLast    value=${rfspIndexLast}
    END
    Set New List                    dist_name=${dist_name}      list_name=snssaiList
    ${snssaiList_dict}              Create dictionary           snssaiDN                            MRBTS-1/NRBTS-1/SNSSAI-${slice_id}
    scf.add_item_to_list            dist_name=${dist_name}      list_name=snssaiList                elements=${snssaiList_dict}
    Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-1
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}

Add NRMOPR_SA MOC to NRBTS-1
    [Arguments]    ${id}  ${nrmeascfg_ir1}  ${nrmeascfg_ir2}  ${nrmored_id}  ${a2MeasRedirectEnabled}  ${voiceFBMode}=${None}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPR_SA-${id}
    Set Object    class_name=NRMOPR_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   a1MeashoEnabledSA             none
    ...   a2MeashoEnabledSA             none
    ...   a2MeasRedirectEnabled         ${a2MeasRedirectEnabled}
    ...   voiceFBMode                   ${voiceFBMode}
    ...   emergencyCallFails            disabled
    ...   emergencyFBMode               redirection
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    IF    ${id}==1 or ${id}==2 or ${id}==4
    ...   Config b1RedirectList in NRMOPR_SA MOC  id=${id}  nrmeascfg_ir1=${nrmeascfg_ir1}  nrmeascfg_ir2=${nrmeascfg_ir2}
    Config nrMoRedDNList at NRMOPR_SA MOC  id=${id}  nrmored_id=${nrmored_id}

Config b1RedirectList in NRMOPR_SA MOC
    [Arguments]    ${id}  ${nrmeascfg_ir1}  ${nrmeascfg_ir2}
    ${dist_name}=    Set Variable   MRBTS-1/NRBTS-1/NRMOPR_SA-${id}
    Set New List                    dist_name=${dist_name}          list_name=b1RedirectList
    ${list_elements}=               Create dictionary               b1measPriority                  1
    ...                                                             nrMeasCfgIrRedirDN              MRBTS-1/NRBTS-1/NRMEASCFG_IR-${nrmeascfg_ir1}
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1RedirectList        elements=${list_elements}
    ${list_elements}=               Create dictionary               b1measPriority                  2
    ...                                                             nrMeasCfgIrRedirDN              MRBTS-1/NRBTS-1/NRMEASCFG_IR-${nrmeascfg_ir2}
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1RedirectList        elements=${list_elements}

Config nrMoRedDNList at NRMOPR_SA MOC
    [Arguments]    ${id}  ${nrmored_id}
    ${dist_name}=    Set Variable   MRBTS-1/NRBTS-1/NRMOPR_SA-${id}
    Set New List                    dist_name=${dist_name}          list_name=nrMoRedDNList
    ${nrMoRedDNList_list}=          Create List                     MRBTS-1/NRBTS-1/NRMORED-${nrmored_id}
    scf.add_elements_to_list        dist_name=${dist_name}          list_name=nrMoRedDNList         elements=${nrMoRedDNList_list}
    ${nrMoRedDNList_2}=             Create List                     MRBTS-1/NRBTS-1/NRMORED-2
    IF    ${nrmored_id} == 1
    ...   scf.add_elements_to_list        dist_name=${dist_name}    list_name=nrMoRedDNList         elements=${nrMoRedDNList_2}

Add NRMEASCFG_IR MOC to NRBTS-1
    [Arguments]    ${id}   ${b1MeasRedirectEnabled}   ${earfcnValue}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEASCFG_IR-${id}
    Set Object    class_name=NRMEASCFG_IR    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   b1MeasRedirectEnabled         ${b1MeasRedirectEnabled}
    ...   b2MeashoEnabled               none
    ...   earfcnValue                   ${earfcnValue}
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRMORED MOC to NRBTS-1
    [Arguments]    ${id}   ${redirFreqEutra}   ${redirPrio}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMORED-${id}
    Set Object    class_name=NRMORED    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   redirFreqEutra                ${redirFreqEutra}
    ...   redirPrio                     ${redirPrio}
    ...   redirRat                      eutra
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add SNSSAI to NRBTS-1 and Update MOC in TA
    [Arguments]    ${id}   ${sd}   ${ta}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/SNSSAI-${id}
    Set Object    class_name=SNSSAI    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}      IN
    ...   administrativeState           Unlocked
    ...   sd                            ${sd}
    ...   sst                           1
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-1
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}
    ${snssaiList_dict}              Create dictionary           snssaiDN                            MRBTS-1/NRBTS-1/SNSSAI-${id}
    scf.add_item_to_list            dist_name=${ta}             list_name=snssaiList                elements=${snssaiList_dict}

Add NRADJECELL Instance to NRBTS-1
    [Arguments]    ${id}   ${earfcnValue}   ${lcrId}   ${physCellId}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRADJECELL-${id}
    Set Object    class_name=NRADJECELL    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                  ${value}      IN
    ...   earfcnValue                ${earfcnValue}
    ...   eNodeBId                   1
    ...   ePSTrackingAreaCode        222
    ...   iRatDataForwardingMethod   indirectDataFwd
    ...   lcrId                      ${lcrId}
    ...   physCellId                 ${physCellId}
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}          list_name=ecgiPlmn
    ${ecgiPlmn_dict}                Create dictionary               mcc                               311
    ...                                                             mnc                               489
    ...                                                             mncLength                         3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=ecgiPlmn                elements=${ecgiPlmn_dict}
    Set New List                    dist_name=${dist_name}          list_name=enbPlmn
    ${enbPlmn_dict}                 Create dictionary               mcc                               311
    ...                                                             mnc                               489
    ...                                                             mncLength                         3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=enbPlmn                 elements=${enbPlmn_dict}

Add NRRELE Instance to NRCELL
    [Arguments]    ${cell_id}    ${rele_id}    ${lcrId}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRRELE-${rele_id}
    Set Object    class_name=NRRELE    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                  ${value}      IN
    ...   cellIndividualOffset       0dB
    ...   eNodeBId                   1
    ...   eutranCellExcluded         false
    ...   lcrId                      ${lcrId}
    ...   removeNotAllowed           false
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}          list_name=ecgiPlmn
    ${ecgiPlmn_dict}                Create dictionary               mcc                               311
    ...                                                             mnc                               489
    ...                                                             mncLength                         3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=ecgiPlmn                elements=${ecgiPlmn_dict}

Add NRMEAS_PROFILE to NRBTS-1
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-${id}
    Set Object    class_name=NRMEAS_PROFILE    dist_name=${dist_name}   version=${NIDD_VERSION}
    Add NRMEASPR_MA_SA-1 to NRMEAS_PROFILE-1  id=1
    Add NRMEASPR_MA_SA-2 to NRMEAS_PROFILE-1  id=2
    Add NRMEASPR_MA_SA-3 to NRMEAS_PROFILE-1  id=3
    Add NRMEASPR_MA_SA-4 to NRMEAS_PROFILE-1  id=4
    Add NRMEASPR_IAF to NRMEAS_PROFILE-1  id=1
    Add NRMEASPR_IRF to NRMEAS_PROFILE-1  id=1  b1HysRsrp=0   b1ThrRsrp=28   b1TimeRsrp=ms100  b1HysRsrq=2   b1ThrRsrq=12   b1TimeRsrq=ms128
    Add NRMEASPR_IRF to NRMEAS_PROFILE-1  id=2  b1HysRsrp=4   b1ThrRsrp=33   b1TimeRsrp=ms160  b1HysRsrq=6   b1ThrRsrq=17   b1TimeRsrq=ms256

Add NRMEASPR_MA_SA-1 to NRMEAS_PROFILE-1
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}
    Set Object    class_name=NRMEASPR_MA_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    Set Element    dist_name=${dist_name}       p_name=nrMeasPrIafDN               value=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    Set New List                    dist_name=${dist_name}      list_name=pcCapabilityList
    ${pcCapabilityList_dict}        Create dictionary           freqBandIndicatorNR                 78
    ...                                                         uePowerClass                        ue-PowerClass1
    scf.add_item_to_list            dist_name=${dist_name}      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}

Add NRMEASPR_MA_SA-2 to NRMEAS_PROFILE-1
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}
    Set Object    class_name=NRMEASPR_MA_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    Set Element    dist_name=${dist_name}       p_name=nrMeasPrIrfDN               value=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IRF-1
    Set New List                    dist_name=${dist_name}      list_name=pcCapabilityList
    ${pcCapabilityList_dict}        Create dictionary           freqBandIndicatorNR                 41
    ...                                                         uePowerClass                        ue-PowerClass2
    scf.add_item_to_list            dist_name=${dist_name}      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}
    ${pcCapabilityList_dict}        Create dictionary           freqBandIndicatorNR                 77
    ...                                                         uePowerClass                        ue-PowerClass2
    scf.add_item_to_list            dist_name=${dist_name}      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}
    ${pcCapabilityList_dict}        Create dictionary           freqBandIndicatorNR                 78
    ...                                                         uePowerClass                        ue-PowerClass2
    scf.add_item_to_list            dist_name=${dist_name}      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}
    ${pcCapabilityList_dict}        Create dictionary           freqBandIndicatorNR                 79
    ...                                                         uePowerClass                        ue-PowerClass2
    scf.add_item_to_list            dist_name=${dist_name}      list_name=pcCapabilityList          elements=${pcCapabilityList_dict}

Add NRMEASPR_MA_SA-3 to NRMEAS_PROFILE-1
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}
    Set Object    class_name=NRMEASPR_MA_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    Set Element    dist_name=${dist_name}       p_name=nrMeasPrIafDN               value=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-1
    Set New List                    dist_name=${dist_name}      list_name=snssaiList
    ${snssaiList_dict}              Create dictionary           snssaiDN                            MRBTS-1/NRBTS-1/SNSSAI-3
    scf.add_item_to_list            dist_name=${dist_name}      list_name=snssaiList                elements=${snssaiList_dict}

Add NRMEASPR_MA_SA-4 to NRMEAS_PROFILE-1
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-${id}
    Set Object    class_name=NRMEASPR_MA_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    Set Element    dist_name=${dist_name}       p_name=nrMeasPrIrfDN                value=MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IRF-2
    Set Element    dist_name=${dist_name}       p_name=rfspIndex                    value=1
    Set Element    dist_name=${dist_name}       p_name=rfspIndexLast                value=10
    Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-1
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}
    Set New List                    dist_name=${dist_name}      list_name=snssaiList
    ${snssaiList_dict}              Create dictionary           snssaiDN                            MRBTS-1/NRBTS-1/SNSSAI-2
    scf.add_item_to_list            dist_name=${dist_name}      list_name=snssaiList                elements=${snssaiList_dict}

Add NRMEASPR_IAF to NRMEAS_PROFILE-1
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IAF-${id}
    Set Object    class_name=NRMEASPR_IAF    dist_name=${dist_name}   version=${NIDD_VERSION}
    Set New List                    dist_name=${dist_name}      list_name=a2MeasRedirectSsbRsrp
    ${a2MeasRedirectSsbRsrp_dict}   Create dictionary           a2HysteresisRedirectSsbRsrp         4
    ...                                                         a2ThresholdRedirectSsbRsrp          39
    ...                                                         a2TimeToTriggerRedirectSsbRsrp      ms320
    scf.add_item_to_list            dist_name=${dist_name}      list_name=a2MeasRedirectSsbRsrp     elements=${a2MeasRedirectSsbRsrp_dict}
    Set New List                    dist_name=${dist_name}      list_name=a2MeasRedirectSsbRsrq
    ${a2MeasRedirectSsbRsrq_dict}   Create dictionary           a2HysteresisRedirectSsbRsrq         4
    ...                                                         a2ThresholdRedirectSsbRsrq          54
    ...                                                         a2TimeToTriggerRedirectSsbRsrq      ms320
    scf.add_item_to_list            dist_name=${dist_name}      list_name=a2MeasRedirectSsbRsrq     elements=${a2MeasRedirectSsbRsrq_dict}

Add NRMEASPR_IRF to NRMEAS_PROFILE-1
    [Arguments]    ${id}   ${b1HysRsrp}   ${b1ThrRsrp}   ${b1TimeRsrp}   ${b1HysRsrq}   ${b1ThrRsrq}   ${b1TimeRsrq}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMEAS_PROFILE-1/NRMEASPR_IRF-${id}
    Set Object    class_name=NRMEASPR_IRF    dist_name=${dist_name}   version=${NIDD_VERSION}
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrp
    ${b1MeasRedirectRsrp_dict}      Create dictionary           b1HysteresisRedirectRsrp            ${b1HysRsrp}
    ...                                                         b1ThresholdRedirectRsrp             ${b1ThrRsrp}
    ...                                                         b1TimeToTriggerRedirectRsrp         ${b1TimeRsrp}
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrp        elements=${b1MeasRedirectRsrp_dict}
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrq
    ${b1MeasRedirectRsrq_dict}      Create dictionary           b1HysteresisRedirectRsrq            ${b1HysRsrq}
    ...                                                         b1ThresholdRedirectRsrq             ${b1ThrRsrq}
    ...                                                         b1TimeToTriggerRedirectRsrq         ${b1TimeRsrq}
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrq        elements=${b1MeasRedirectRsrq_dict}

Add NRHOIR Instance to NRBTS
    [Arguments]    ${id}   ${earfcnValue}   ${widebandRsrqMeas}   ${b1MeasRedirectEnabled}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRHOIR-${id}
    Set Object    class_name=NRHOIR    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                     ${value}            IN
    ...   allowedMeasBandwidth          mbw50
    ...   b1MeasRedirectEnabled         ${b1MeasRedirectEnabled}
    ...   b2MeashoEnabled               none
    ...   earfcnValue                   ${earfcnValue}
    ...   eutraFreqQOffsetRange         0dB
    ...   presenceAntennaPort1          false
    ...   reportAmount                  r8
    ...   reportInterval                ms240
    ...   widebandRsrqMeas              ${widebandRsrqMeas}
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                dist_name=${dist_name}              list_name=nrPlmnDNList
    ${param_list}=              Create List                         MRBTS-1/NRBTS-1/NRPLMN-1
    scf.add_elements_to_list    dist_name=${dist_name}              list_name=nrPlmnDNList     elements=${param_list}

Enable A2 and B1 measurement configuration for Sub-feature B
    [Arguments]    ${id}
    ${dist_name}=    Set Variable   MRBTS-1/NRBTS-1/NRCELL-${id}
    Set New List                    dist_name=${dist_name}      list_name=a2MeasRedirectSsbRsrp
    ${a2MeasRedirectSsbRsrp_dict}   Create dictionary           a2HysteresisRedirectSsbRsrp         0
    ...                                                         a2ThresholdRedirectSsbRsrp          34
    ...                                                         a2TimeToTriggerRedirectSsbRsrp      ms480
    scf.add_item_to_list            dist_name=${dist_name}      list_name=a2MeasRedirectSsbRsrp     elements=${a2MeasRedirectSsbRsrp_dict}
    Set New List                    dist_name=${dist_name}      list_name=a2MeasRedirectSsbRsrq
    ${a2MeasRedirectSsbRsrq_dict}   Create dictionary           a2HysteresisRedirectSsbRsrq         0
    ...                                                         a2ThresholdRedirectSsbRsrq          49
    ...                                                         a2TimeToTriggerRedirectSsbRsrq      ms480
    scf.add_item_to_list            dist_name=${dist_name}      list_name=a2MeasRedirectSsbRsrq     elements=${a2MeasRedirectSsbRsrq_dict}
    ${dist_name}=    Set Variable   MRBTS-1/NRBTS-1/NRHOIR-1
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrp
    ${b1MeasRedirectRsrp_dict}      Create dictionary           b1HysteresisRedirectRsrp            8
    ...                                                         b1ThresholdRedirectRsrp             38
    ...                                                         b1TimeToTriggerRedirectRsrp         ms320
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrp        elements=${b1MeasRedirectRsrp_dict}
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrq
    ${b1MeasRedirectRsrq_dict}      Create dictionary           b1HysteresisRedirectRsrq            10
    ...                                                         b1ThresholdRedirectRsrq             22
    ...                                                         b1TimeToTriggerRedirectRsrq         ms480
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrq        elements=${b1MeasRedirectRsrq_dict}
    ${dist_name}=    Set Variable   MRBTS-1/NRBTS-1/NRHOIR-2
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrp
    ${b1MeasRedirectRsrp_dict}      Create dictionary           b1HysteresisRedirectRsrp            12
    ...                                                         b1ThresholdRedirectRsrp             43
    ...                                                         b1TimeToTriggerRedirectRsrp         ms512
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrp        elements=${b1MeasRedirectRsrp_dict}
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrq
    ${b1MeasRedirectRsrq_dict}      Create dictionary           b1HysteresisRedirectRsrq            14
    ...                                                         b1ThresholdRedirectRsrq             27
    ...                                                         b1TimeToTriggerRedirectRsrq         ms640
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrq        elements=${b1MeasRedirectRsrq_dict}
    ${dist_name}=    Set Variable   MRBTS-1/NRBTS-1/NRHOIR-4
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrp
    ${b1MeasRedirectRsrp_dict}      Create dictionary           b1HysteresisRedirectRsrp            16
    ...                                                         b1ThresholdRedirectRsrp             48
    ...                                                         b1TimeToTriggerRedirectRsrp         ms1024
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrp        elements=${b1MeasRedirectRsrp_dict}
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrq
    ${b1MeasRedirectRsrq_dict}      Create dictionary           b1HysteresisRedirectRsrq            18
    ...                                                         b1ThresholdRedirectRsrq             32
    ...                                                         b1TimeToTriggerRedirectRsrq         ms1280
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrq        elements=${b1MeasRedirectRsrq_dict}
    ${dist_name}=    Set Variable   MRBTS-1/NRBTS-1/NRHOIR-5
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrp
    ${b1MeasRedirectRsrp_dict}      Create dictionary           b1HysteresisRedirectRsrp            20
    ...                                                         b1ThresholdRedirectRsrp             53
    ...                                                         b1TimeToTriggerRedirectRsrp         ms2560
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrp        elements=${b1MeasRedirectRsrp_dict}
    Set New List                    dist_name=${dist_name}      list_name=b1MeasRedirectRsrq
    ${b1MeasRedirectRsrq_dict}      Create dictionary           b1HysteresisRedirectRsrq            22
    ...                                                         b1ThresholdRedirectRsrq             34
    ...                                                         b1TimeToTriggerRedirectRsrq         ms5120
    scf.add_item_to_list            dist_name=${dist_name}      list_name=b1MeasRedirectRsrq        elements=${b1MeasRedirectRsrq_dict}

Get Val from SCF
    ${freqBandIndicatorNR}=  scf.get_value_from_scf        dist_name=NRBTS-1/NRCELL-1                p_name=freqBandIndicatorNR
    Set Suite Variable       ${freqBandIndicatorNR}

Add NRHOIR to NRBTS-1
    [Arguments]    ${cell_index}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRHOIR-${cell_index}
    Set Object    class_name=NRHOIR    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                  ${value}      IN
    ...   allowedMeasBandwidth       mbw50
    ...   b1MeasRedirectEnabled      rsrp
    ...   earfcnValue                1000
    ...   b2MeashoEnabled            rsrq
    ...   presenceAntennaPort1       false
    ...   reportAmount               r8
    ...   reportInterval             ms240
    ...   widebandRsrqMeas           true
    ...   b2Threshold1hoRsrp         35
    ...   b2Threshold1hoRsrq         50
    ...   eutraFreqQOffsetRange      0dB
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}          list_name=b1MeasRedirectRsrp
    ${b1MeasRsrp_dict}              Create dictionary               b1ThresholdRedirectRsrp           18
    ...                                                             b1HysteresisRedirectRsrp          0
    ...                                                             b1TimeToTriggerRedirectRsrp       ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1MeasRedirectRsrp      elements=${b1MeasRsrp_dict}
    Set New List                    dist_name=${dist_name}          list_name=b1MeasRedirectRsrq
    ${b1MeasRsrq_dict}              Create dictionary               b1ThresholdRedirectRsrq           34
    ...                                                             b1HysteresisRedirectRsrq          0
    ...                                                             b1TimeToTriggerRedirectRsrq       ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1MeasRedirectRsrq      elements=${b1MeasRsrq_dict}
    Set New List                    dist_name=${dist_name}          list_name=eutraB2MeashoRsrp
    ${eutraB2MeashoRsrp_dict}       Create dictionary               b2HysteresishoRsrp                5
    ...                                                             b2HysteresishoRsrpVoNr            0
    ...                                                             b2Threshold2hoRsrp                18
    ...                                                             b2Threshold2hoRsrpVoNr            18
    ...                                                             b2TimeToTriggerhoRsrp             ms480
    ...                                                             b2TimeToTriggerhoRsrpVoNr         ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=eutraB2MeashoRsrp       elements=${eutraB2MeashoRsrp_dict}
    Set New List                    dist_name=${dist_name}          list_name=eutraB2MeashoRsrq
    ${eutraB2MeashoRsrq_dict}       Create dictionary               b2HysteresishoRsrq                0
    ...                                                             b2HysteresishoRsrqVoNr            0
    ...                                                             b2Threshold2hoRsrq                18
    ...                                                             b2Threshold2hoRsrqVoNr            2
    ...                                                             b2TimeToTriggerhoRsrq             ms480
    ...                                                             b2TimeToTriggerhoRsrqVoNr         ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=eutraB2MeashoRsrq       elements=${eutraB2MeashoRsrq_dict}
    ${dist_name}=                   Set Variable                    MRBTS-1/NRBTS-1/NRCELL-${cell_index}
    Set New List                    dist_name=${dist_name}          list_name=b1RedirectList
    ${list_elements}=               Create dictionary               b1measPriority                    1
    ...                                                             nrhoirRedirDN                     MRBTS-1/NRBTS-1/NRHOIR-${cell_index}
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1RedirectList          elements=${list_elements}
    Set New List                    dist_name=${dist_name}          list_name=nrhoirDNList
    ${param_list}=                  Create List                     MRBTS-1/NRBTS-1/NRHOIR-${cell_index}
    scf.add_elements_to_list        dist_name=${dist_name}          list_name=nrhoirDNList            elements=${param_list}

Add NRRELE-1 to NRCELL
    [Arguments]    ${cell_index}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell_index}/NRRELE-1
    Set Object    class_name=NRRELE    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                  ${value}      IN
    ...   cellIndividualOffset       0dB
    ...   eNodeBId                   1
    ...   eutranCellExcluded         false
    ...   lcrId                      1
    ...   removeNotAllowed           false
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}          list_name=ecgiPlmn
    ${ecgiPlmn_dict}                Create dictionary               mcc                               311
    ...                                                             mnc                               489
    ...                                                             mncLength                         3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=ecgiPlmn                elements=${ecgiPlmn_dict}

Add NRADJECELL-1 to NRBTS-1
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRADJECELL-1
    Set Object    class_name=NRADJECELL    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                  ${value}      IN
    ...   eNodeBId                   1
    ...   ePSTrackingAreaCode        222
    ...   iRatDataForwardingMethod   indirectDataFwd
    ...   earfcnValue                1
    ...   lcrId                      1
    ...   physCellId                 11
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}          list_name=ecgiPlmn
    ${ecgiPlmn_dict}                Create dictionary               mcc                               311
    ...                                                             mnc                               489
    ...                                                             mncLength                         3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=ecgiPlmn                elements=${ecgiPlmn_dict}
    Set New List                    dist_name=${dist_name}          list_name=enbPlmn
    ${enbPlmn_dict}                 Create dictionary               mcc                               311
    ...                                                             mnc                               489
    ...                                                             mncLength                         3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=enbPlmn                 elements=${enbPlmn_dict}

Apply Config for A_B3_4
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-1
    FOR   ${p_name}                            ${value}      IN
    ...   actEmergencyCall                     true
    ...   actEnhancedVoNR                      true
    ...   actVoNR                              true
    ...   emergencyCallFails                   true
    ...   numOfRadioResReservForEmergency      1
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    ${list_name}=                   Set Variable                    emergencyCallRestrictions
    Set New List                    dist_name=${dist_name}          list_name=${list_name}
    ${emergencyCall_dict}           Create dictionary               emergencyCallMrListIgnore         true
    ...                                                             emergencyCallPlmnHoAllowed        true
    scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${emergencyCall_dict}
    Set Element    dist_name=MRBTS-1/NRBTS-1/NRDU-1    p_name=numOfDrbsReservForEmergency   value=1
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Apply Config for A_B3_5
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1
    FOR   ${p_name}                            ${value}      IN
    ...   actMFBIEutra                         true
    ...   excludedEutranCellPeriod             10
    ...   excludedEutranCellThreshold          5
    ...   excludedEutranCellTimeWindow         10
    Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-1
    FOR   ${p_name}                            ${value}      IN
    ...   measGapSelectionSA                   favourUeThroughput
    ...   mgta                                 ms0
    ...   gapOffset                            0
    ...   a1MeashoEnabledSA                    rsrp
    ...   a2MeashoEnabledSA                    rsrp
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    ${list_name}=                   Set Variable                    a1MeashoSsbRsrpSA
    Set New List                    dist_name=${dist_name}          list_name=${list_name}
    ${a1MeashoSsbRsrpSA_dict}       Create dictionary               a1HysteresishoSsbRsrpSA            0
    ...                                                             a1ThresholdhoSsbRsrpSA             36
    ...                                                             a1TimeToTriggerhoSsbRsrpSA         ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}             elements=${a1MeashoSsbRsrpSA_dict}
    ${list_name}=                   Set Variable                    a1MeashoSsbRsrq
    Set New List                    dist_name=${dist_name}          list_name=${list_name}
    ${a1MeashoSsbRsrq_dict}       Create dictionary                 a1HysteresishoSsbRsrq              0
    ...                                                             a1ThresholdhoSsbRsrq               36
    ...                                                             a1TimeToTriggerhoSsbRsrq           ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}             elements=${a1MeashoSsbRsrq_dict}
    ${list_name}=                   Set Variable                    a2MeasRedirectSsbRsrp
    Set New List                    dist_name=${dist_name}          list_name=${list_name}
    ${a2MeasRedirectSsbRsrp_dict}       Create dictionary           a2HysteresisRedirectSsbRsrp        0
    ...                                                             a2ThresholdRedirectSsbRsrp         34
    ...                                                             a2TimeToTriggerRedirectSsbRsrp     ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}             elements=${a2MeasRedirectSsbRsrp_dict}
    ${list_name}=                   Set Variable                    a2MeasRedirectSsbRsrq
    Set New List                    dist_name=${dist_name}          list_name=${list_name}
    ${a2MeasRedirectSsbRsrq_dict}       Create dictionary           a2HysteresisRedirectSsbRsrq        0
    ...                                                             a2ThresholdRedirectSsbRsrq         31
    ...                                                             a2TimeToTriggerRedirectSsbRsrq     ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}             elements=${a2MeasRedirectSsbRsrq_dict}
    ${list_name}=                   Set Variable                    a2MeashoSsbRsrp
    Set New List                    dist_name=${dist_name}          list_name=${list_name}
    ${a2MeashoSsbRsrp_dict}       Create dictionary                 a2HysteresishoSsbRsrp              0
    ...                                                             a2ThresholdhoSsbRsrp               34
    ...                                                             a2TimeToTriggerhoSsbRsrp           ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}             elements=${a2MeashoSsbRsrp_dict}
    ${list_name}=                   Set Variable                    a2MeashoSsbRsrpSA
    Set New List                    dist_name=${dist_name}          list_name=${list_name}
    ${a2MeashoSsbRsrpSA_dict}       Create dictionary               a2HysteresishoSsbRsrpSA            0
    ...                                                             a2ThresholdhoSsbRsrpSA             34
    ...                                                             a2TimeToTriggerhoSsbRsrpSA         ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}             elements=${a2MeashoSsbRsrpSA_dict}
    ${list_name}=                   Set Variable                    a2MeashoSsbRsrq
    Set New List                    dist_name=${dist_name}          list_name=${list_name}
    ${a2MeashoSsbRsrq_dict}       Create dictionary                 a2HysteresishoSsbRsrq              0
    ...                                                             a2ThresholdhoSsbRsrq               31
    ...                                                             a2TimeToTriggerhoSsbRsrq           ms480
    scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}             elements=${a2MeashoSsbRsrq_dict}
    ${list_name}=                   Set Variable                    drxProfile1
    Set New List                    dist_name=${dist_name}          list_name=${list_name}
    ${drxProfile1_dict}             Create dictionary               drxInactivityTimer                 40ms
    ...                                                             drxLongCycle                       40ms
    ...                                                             drxRetransTimerDl                  16slot
    ...                                                             drxRetransTimerUl                  16slot
    ...                                                             drxHarqRttTimerDl                  0symbols
	...                                                             drxHarqRttTimerUl                  0symbols
    ...                                                             drxOnDurationTimer                 10ms
    scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}             elements=${drxProfile1_dict}
    Apply Delta SCF    ${scf_file}    ${test_instance}_modified_scf

Apply Config for A_B3_6
     [Arguments]         ${test_instance}
     ${scf_file}=        Load current SCF
     ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1
     FOR   ${p_name}                            ${value}      IN
     ...   actInterFreqHoSA                    true
     ...   actIntraFreqHoSA                    true
     ...   actIpThpt                           true
     ...   actNrpmqapProfiles                  false
     ...   actPucchF3BasedTaGrantsRed          true
     ...   tNgRelocExecDeltL                   5000
     ...   thpTimeCalc                         enabled
     ...   timerXnDataFwdGuard                 250
     Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
     END
     Set Element    dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1    p_name=miNrRelReportCu   value=15min
     ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRADJNRCELL-1
     Set Object    class_name=NRADJNRCELL    dist_name=${dist_name}   version=${NIDD_VERSION}
     FOR   ${p_name}                            ${value}      IN
     ...   cellDepType                          SA
     ...   cellReservedForOperatorUse           notReserved
     ...   fiveGsTac                            0
     ...   freqBandIndicatorNR                  78
     ...   gNbId                                3
     ...   gNbIdLength                          22
     ...   lcrId                                1
     ...   nrarfcn                              633408
     ...   physCellId                           48
     ...   ssbFrequency                         635676
     Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
     END
     ${list_name}=                   Set Variable                    gnbPlmn
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${gnbPlmn_dict}       Create dictionary                         mcc             311
     ...                                                             mnc             489
     ...                                                             mncLength       3
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}          elements=${gnbPlmn_dict}
     ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-1
     FOR   ${p_name}                            ${value}      IN
     ...   cellDepType                          SA+NSA
     ...   measGapSelectionSA                   balancedChoice
     ...   measGapSelection                     balancedChoice
     ...   mgta                                 ms0
     ...   a1MeashoEnabled                      rsrp
     ...   a1MeashoEnabledSA                    rsrp
     ...   a2MeashoEnabledSA                    rsrp
     ...   a2MeasRedirectEnabled                rsrp
     ...   a2MeasReleaseEnabled                 rsrp
     ...   a2MeashoEnabled                      rsrp
     ...   a3MeasEnabled                        rsrp
     ...   absThreshSsbRsrpConsolidation        10
     ...   absThreshSsbRsrqConsolidation        10
     ...   cbraPreamblesPerSsb                  n40
     ...   sMeasConfigSsbRsrp                   0
           Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
     END
     Add a1MeashoSsbRsrp to Cell     dist_name=MRBTS-1/NRBTS-1/NRCELL-1
     Add a1MeashoSsbRsrq to Cell     dist_name=MRBTS-1/NRBTS-1/NRCELL-1
     Add a2MeashoSsbRsrp to Cell     dist_name=MRBTS-1/NRBTS-1/NRCELL-1
     Add a2MeashoSsbRsrq to Cell     dist_name=MRBTS-1/NRBTS-1/NRCELL-1
     ${list_name}=                   Set Variable                    a1MeashoSsbRsrpSA
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a1MeashoSsbRsrpSA_dict}       Create dictionary               a1HysteresishoSsbRsrpSA           0
     ...                                                             a1HysteresisHoSsbRsrpVoNr         0
     ...                                                             a1ThresholdhoSsbRsrpSA            104
     ...                                                             a1TimeToTriggerhoSsbRsrpSA        ms480
     ...                                                             a1TimeToTriggerHoSsbRsrpVoNr      ms480
     ...                                                             a1ThresholdHoSsbRsrpVoNr          63
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${a1MeashoSsbRsrpSA_dict}
     ${list_name}=                   Set Variable                    a1MeashoSsbRsrqSA
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a1MeashoSsbRsrqSA_dict}       Create dictionary               a1HysteresishoSsbRsrqSA           0
     ...                                                             a1HysteresisHoSsbRsrqVoNr         0
     ...                                                             a1ThresholdhoSsbRsrqSA            104
     ...                                                             a1TimeToTriggerhoSsbRsrqSA        ms480
     ...                                                             a1TimeToTriggerHoSsbRsrqVoNr      ms480
     ...                                                             a1ThresholdHoSsbRsrqVoNr          63
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${a1MeashoSsbRsrqSA_dict}
     ${list_name}=                   Set Variable                    a2MeasRedirectSsbRsrp
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a2MeasRedirectSsbRsrp_dict}       Create dictionary           a2HysteresisRedirectSsbRsrp       0
     ...                                                             a2ThresholdRedirectSsbRsrp        92
     ...                                                             a2TimeToTriggerRedirectSsbRsrp    ms480
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${a2MeasRedirectSsbRsrp_dict}
     ${list_name}=                   Set Variable                    a2MeasRedirectSsbRsrq
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a2MeasRedirectSsbRsrq_dict}       Create dictionary           a2HysteresisRedirectSsbRsrq       0
     ...                                                             a2ThresholdRedirectSsbRsrq        92
     ...                                                             a2TimeToTriggerRedirectSsbRsrq    ms480
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${a2MeasRedirectSsbRsrq_dict}
     ${list_name}=                   Set Variable                    a2MeasReleaseSsbRsrp
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a2MeasReleaseSsbRsrp_dict}       Create dictionary            a2HysteresisReleaseSsbRsrp        0
     ...                                                             a2ThresholdReleaseSsbRsrp         88
     ...                                                             a2TimeToTriggerReleaseSsbRsrp     ms480
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${a2MeasReleaseSsbRsrp_dict}
     ${list_name}=                   Set Variable                    a2MeasReleaseSsbRsrq
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a2MeasReleaseSsbRsrq_dict}       Create dictionary            a2HysteresisReleaseSsbRsrq        0
     ...                                                             a2ThresholdReleaseSsbRsrq         88
     ...                                                             a2TimeToTriggerReleaseSsbRsrq     ms480
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${a2MeasReleaseSsbRsrq_dict}
     ${list_name}=                   Set Variable                    a2MeashoSsbRsrpSA
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a2MeashoSsbRsrpSA_dict}       Create dictionary               a2HysteresishoSsbRsrpSA           0
     ...                                                             a2HysteresisHoSsbRsrpVoNr         0
     ...                                                             a2ThresholdhoSsbRsrpSA            100
     ...                                                             a2TimeToTriggerhoSsbRsrpSA        ms480
     ...                                                             a2TimeToTriggerHoSsbRsrpVoNr      ms480
     ...                                                             a2ThresholdHoSsbRsrpVoNr          100
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${a2MeashoSsbRsrpSA_dict}
     ${list_name}=                   Set Variable                    a2MeashoSsbRsrqSA
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a2MeashoSsbRsrqSA_dict}       Create dictionary               a2HysteresishoSsbRsrqSA           0
     ...                                                             a2HysteresisHoSsbRsrqVoNr         0
     ...                                                             a2ThresholdhoSsbRsrqSA            100
     ...                                                             a2TimeToTriggerhoSsbRsrqSA        ms480
     ...                                                             a2TimeToTriggerHoSsbRsrqVoNr      ms480
     ...                                                             a2ThresholdHoSsbRsrqVoNr          100
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${a2MeashoSsbRsrqSA_dict}
     ${list_name}=                   Set Variable                    a3MeasSsbRsrp
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a3MeasSsbRsrp_dict}       Create dictionary                   a3HysteresisSsbRsrp              0
     ...                                                             a3OffsetSsbRsrp                  0
     ...                                                             a3TimeToTriggerSsbRsrp           ms320
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}           elements=${a3MeasSsbRsrp_dict}
     ${list_name}=                   Set Variable                    a3MeasSsbRsrq
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a3MeasSsbRsrq_dict}       Create dictionary                   a3HysteresisSsbRsrq              0
     ...                                                             a3OffsetSsbRsrq                  0
     ...                                                             a3TimeToTriggerSsbRsrq           ms320
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}           elements=${a3MeasSsbRsrq_dict}
     ${list_name}=                   Set Variable                    a5MeasSsbRsrp
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a5MeasSsbRsrp_dict}       Create dictionary                   a5HysteresisSsbRsrp              0
     ...                                                             a5Threshold1SsbRsrp              82
     ...                                                             a5Threshold2SsbRsrp              87
     ...                                                             a5TimeToTriggerSsbRsrp           ms100
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}           elements=${a5MeasSsbRsrp_dict}
     Add NRHOIF
     ${dist_name} =                  Set Variable                    NRBTS-1/NRCELL-1/NRHOIF-1
     ${list_name}=                   Set Variable                    a3MeasSsbRsrq
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a3MeasSsbRsrq_dict}       Create dictionary                   a3HysteresisSsbRsrq              2
     ...                                                             a3OffsetSsbRsrq                  10
     ...                                                             a3TimeToTriggerSsbRsrq           ms40
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}           elements=${a3MeasSsbRsrq_dict}
     ${list_name}=                   Set Variable                    a5MeasSsbRsrq
     Set New List                    dist_name=${dist_name}          list_name=${list_name}
     ${a5MeasSsbRsrq_dict}       Create dictionary                   a5HysteresisSsbRsrq              0
     ...                                                             a5Threshold1SsbRsrq              40
     ...                                                             a5Threshold2SsbRsrq              30
     ...                                                             a5TimeToTriggerSsbRsrq           ms480
     scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}           elements=${a5MeasSsbRsrq_dict}
     Apply Delta SCF    ${scf_file}    ${test_instance}_modified_scf

Apply Config for A_B4
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    ${dist_name}=    Set Variable     MRBTS-1/NRBTS-1
    Set Element                    dist_name=${dist_name}           p_name=actNormVCFallbackEnh        value=true
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Apply Config for A_B5
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    Set Element         dist_name=MRBTS-1/NRBTS-1               p_name=actEmergencyFallback       value=true
    Set Element         dist_name=MRBTS-1/NRBTS-1               p_name=actNormVCFallbackEnh       value=true
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRCELL-1      p_name=emergencyFBMode            value=redirection
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRCELL-2      p_name=emergencyFBMode            value=redirection
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRCELL-3      p_name=emergencyFBMode            value=redirection
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRCELL-4      p_name=emergencyFBMode            value=redirection
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Apply Config for A_B6
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    Set Element         dist_name=MRBTS-1/NRBTS-1               p_name=actEmergencyFallback       value=true
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRCELL-1      p_name=emergencyFBMode            value=redirection
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRCELL-2      p_name=emergencyFBMode            value=redirection
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRCELL-3      p_name=emergencyFBMode            value=redirection
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRCELL-4      p_name=emergencyFBMode            value=redirection
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Apply Config for A_B8
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    Set Element         dist_name=MRBTS-1/NRBTS-1/NRHOIR-1               p_name=b1MeasRedirectEnabled       value=rsrpCombined
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Activate Mobility Profile
    [Arguments]       ${test_instance}
    ${scf_file}=      Load current SCF
    Set Element       dist_name=MRBTS-1/NRBTS-1     p_name=actMobilityProfile     value=true
    IF    $test_instance in ['B_B2', 'B_B2_1', 'B_B2_4']
    ...    Set Element       dist_name=MRBTS-1/NRBTS-1     p_name=actMeasurementProfile     value=deactivated
    ${dist_name}=                   Set Variable                    MRBTS-1/NRBTS-1/NRCELL-1
    ${b1RedirectList_dict}          Create dictionary               b1measPriority                      3
    ...                                                             nrhoirRedirDN                       MRBTS-1/NRBTS-1/NRHOIR-5
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1RedirectList            elements=${b1RedirectList_dict}
    ${b1RedirectList_dict}          Create dictionary               b1measPriority                      4
    ...                                                             nrhoirRedirDN                       MRBTS-1/NRBTS-1/NRHOIR-4
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1RedirectList            elements=${b1RedirectList_dict}
    IF    $test_instance in ['B_B2_1', 'B_B3_1']
          Change RedirPrio of Eutra Freq
          Swap b1measPriority in b1RedirectList
    END
    IF    '${test_instance}' == 'B_B2_4'
    ...   Deconfigure voiceFBMode from Mobility Profiles
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Swap b1measPriority in b1RedirectList
    ${dist_name}=    Set Variable   MRBTS-1/NRBTS-1/NRMOPR_SA-1
    Set New List                    dist_name=${dist_name}          list_name=b1RedirectList
    ${list_elements}=               Create dictionary               b1measPriority                  2
    ...                                                             nrMeasCfgIrRedirDN              MRBTS-1/NRBTS-1/NRMEASCFG_IR-3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1RedirectList        elements=${list_elements}
    ${list_elements}=               Create dictionary               b1measPriority                  1
    ...                                                             nrMeasCfgIrRedirDN              MRBTS-1/NRBTS-1/NRMEASCFG_IR-4
    scf.add_item_to_list            dist_name=${dist_name}          list_name=b1RedirectList        elements=${list_elements}

Change RedirPrio of Eutra Freq
    [Arguments]
    FOR   ${dist_name}                      ${p_name}                   ${value}                IN
    ...   MRBTS-1/NRBTS-1/NRMORED-1         redirPrio                   1
    ...   MRBTS-1/NRBTS-1/NRMORED-2         redirPrio                   2
          Set Element    dist_name=${dist_name}     p_name=${p_name}    value=${value}
    END

Deconfigure voiceFBMode from Mobility Profiles
    [Arguments]
    FOR    ${nrmopr_sa}    IN RANGE    1  6
        scf.remove_element_from_scf         dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-${nrmopr_sa}      p_name=emergencyCallFails
        scf.remove_element_from_scf         dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-${nrmopr_sa}      p_name=emergencyFBMode
        scf.remove_element_from_scf         dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-${nrmopr_sa}      p_name=voiceFBMode
    END

Apply Delta Config for Sub-Feature-G
    [Arguments]       ${test_instance}     ${nrEcidMeas_SupervisionTimer}
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                              ${p_name}                               ${value}                            IN
    ...   MRBTS-1/NRBTS-1                           actMeasurementProfile                   deactivated
    ...   MRBTS-1/NRBTS-1                           nrEcidMeasSupervisionTimer              ${nrEcidMeas_SupervisionTimer}
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  actUlNrEcIdPosMethod                    true
          Set Element    dist_name=${dist_name}     p_name=${p_name}   value=${value}
    END
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf
