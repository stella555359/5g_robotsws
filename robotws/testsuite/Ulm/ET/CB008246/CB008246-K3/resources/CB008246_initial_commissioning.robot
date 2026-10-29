*** Settings ***
Documentation    Scenario specific keywords for subfeature CB008246-K#3 of "LA for HR DRBs"

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Change Reporting Interval for CB008246
    [Arguments]    ${interval_duration}
    ${distName_NRPMRNL}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRPMRNL-[0-9]+
    @{list_of_pm_groups}=  create list  miNrCellAvailability  miNrCellUtilization  miNrTimingAdvance  miNrUlSignalQuality
    ...                                 miNrDlHarq  miNrUlHarq
    ...                                 miNrDlHarqLowSEMCS  miNrUlHarqLowSEMCS  miNrSignalQualityLowSEMCS
    ...                                 miNrPdcch  miNrResourceUtilizationPerCell  miNrPdcch2
    FOR   ${pname}  IN   @{list_of_pm_groups}
        scf.modify scf element    value=${interval_duration}  dist_name=${distName_NRPMRNL[0]}  p_name=${pname}
    END
    ${distName_PMCADM}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MNL-[0-9]+/MNLENT-[0-9]+/PMCADM-[0-9]+
    scf.modify scf element    value=${interval_duration}  dist_name=${distName_PMCADM[0]}   p_name=reportingIntervalPm


Disable some Functionality according to CFAM
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        Set Element    dist_name=${dist_name}    p_name=actDl256Qam              value=false
        Set Element    dist_name=${dist_name}    p_name=actUl256Qam              value=false
        Set Element    dist_name=${dist_name}    p_name=actDlMuMimo              value=false
        Set Element    dist_name=${dist_name}    p_name=actUlMuMimo              value=false
        Set Element    dist_name=${dist_name}    p_name=actAdaptiveReTxResMcs    value=false
    END


Activate CB009267
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    Set Element    dist_name=${distName_NRBTS[0]}     p_name=actCarAgPmCount              value=true


Activate CB008246
    [Arguments]    ${ullaBlerTargetHR_1}=5    ${ullaBlerTargetHR_2}=10
    ...     ${NRPUSCHHRLA_2_5QI3}="NRPUSCHHRLA-1"     ${NRPUSCHHRLA_3_5QI9}="NRPUSCHHRLA-1"     ${NRPUSCHHRLA_4_5QI7}="NRPUSCHHRLA-1"
    ...     ${NRPUSCHHRLA_5_5QI71}="NRPUSCHHRLA-1"      ${NRPUSCHHRLA_6_5QI80}="NRPUSCHHRLA-1"
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRBTS[0]}     actMultiDrbNSA              true
    ...    ${distName_NRBTS[0]}     actCarAgPmCount             true
    ...    ${distName_NRCELL[0]}    actLAForHiReliab            false
    ...    ${distName_NRCELL[0]}    actCceSplit                 false
    ...    ${distName_NRCELL[2]}    actLAForHiReliab            false
    ...    ${distName_NRCELL[2]}    actCceSplit                 false
    ...    ${distName_NRCELL[3]}    actLAForHiReliab            false
    ...    ${distName_NRCELL[3]}    actCceSplit                 false
    ...    ${distName_NRCELL[4]}    actLAForHiReliab            true
    ...    ${distName_NRCELL[4]}    sCellBadChannelQualityThUL  4
    ...    ${distName_NRCELL[4]}    scalingStepdownHREnabled    true
    ...    ${distName_NRCELL[4]}    actCceSplit                 false
    ...    ${distName_NRCELL[4]}    pMaxNROwnCell               20
    ...    ${distName_NRCELL[1]}    actLAForHiReliab            true
    ...    ${distName_NRCELL[1]}    sCellBadChannelQualityThUL  4
    ...    ${distName_NRCELL[1]}    scalingStepdownHREnabled    true
    ...    ${distName_NRCELL[1]}    actCceSplit                 false
    ...    ${distName_NRCELL[1]}    pMaxNROwnCell               20
    ...    ${distName_NRCELL[1]}    nrBtsBeamRefinementP2       false
    ...    ${distName_NRCELL[0]}    actNonVoNRGbrService        true
    ...    ${distName_NRCELL[1]}    actNonVoNRGbrService        true
    ...    ${distName_NRCELL[2]}    actNonVoNRGbrService        true
    ...    ${distName_NRCELL[3]}    actNonVoNRGbrService        true
    ...    ${distName_NRCELL[4]}    actNonVoNRGbrService        true
    ...    ${distName_NRCELL[0]}    dlMcsDowngradeForHr         disabled
    ...    ${distName_NRCELL[0]}    ulMcsDowngradeForHr         disabled
    ...    ${distName_NRCELL[1]}    dlMcsDowngradeForHr         disabled
    ...    ${distName_NRCELL[1]}    ulMcsDowngradeForHr         disabled
    ...    ${distName_NRCELL[2]}    dlMcsDowngradeForHr         disabled
    ...    ${distName_NRCELL[2]}    ulMcsDowngradeForHr         disabled
    ...    ${distName_NRCELL[3]}    dlMcsDowngradeForHr         disabled
    ...    ${distName_NRCELL[3]}    ulMcsDowngradeForHr         disabled
    ...    ${distName_NRCELL[4]}    dlMcsDowngradeForHr         disabled
    ...    ${distName_NRCELL[4]}    ulMcsDowngradeForHr         disabled
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    FOR    ${dist_name}             ${index}        IN
    ...    ${distName_NRCELL[1]}    0
    ...    ${distName_NRCELL[1]}    1
    ...    ${distName_NRCELL[4]}    0
    ...    ${distName_NRCELL[4]}    1
        scf.modify scf element  dist_name=${dist_name}  p_name=actUpperThrAckNackHrFiltering  value=true  index=${index}
        scf.modify scf element  dist_name=${dist_name}  p_name=actUpperThrAckNackFiltering    value=true  index=${index}
    END
    Configure CB008246 on PDSCH
    Configure CB008246 on PUSCH    ${ullaBlerTargetHR_1}    ${ullaBlerTargetHR_2}   ${NRPUSCHHRLA_2_5QI3}
    ...     ${NRPUSCHHRLA_3_5QI9}     ${NRPUSCHHRLA_4_5QI7}     ${NRPUSCHHRLA_5_5QI71}      ${NRPUSCHHRLA_6_5QI80}
    Configure CB008246 on PDCCH
    Configure SCF File for subfeature CB008246-B
    Configure SCF File for dciDedicatedAggregationLevelHR


Configure CB008246 on PDSCH
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List      dist_name=${distName_NRCELL[1]}  list_name=pdschHrLaConfig
    ${pdschHrLaConfig_item}=  create dictionary
    ...    dllaCqiOffsetHR                  0
    ...    dllaDeltaCqiMaxHR              150
    ...    dllaDeltaCqiMinHR             -150
    ...    dllaDeltaCqiStepdownHR        2000
    ...    dllaIniDeltaCqiHR              -50
    ...    dllaIniMcsHR                     3
    ...    dllaMcsMax64qamLowSERANK1HR     25
    ...    dllaMcsMax64qamLowSERANK2HR     25
    ...    dllaMcsMax64qamLowSERANK3HR     20
    ...    dllaMcsMax64qamLowSERANK4HR     20
    ...    dllaMcsMax64qamRANK1HR          25
    ...    dllaMcsMax64qamRANK2HR          25
    ...    dllaMcsMax64qamRANK3HR          20
    ...    dllaMcsMax64qamRANK4HR          20
    scf.add_item_to_list    dist_name=${distName_NRCELL[1]}   list_name=pdschHrLaConfig   elements=${pdschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List      dist_name=${distName_NRCELL[3]}  list_name=pdschHrLaConfig
    ${pdschHrLaConfig_item}=  create dictionary
    ...    dllaCqiOffsetHR                  0
    ...    dllaDeltaCqiMaxHR              150
    ...    dllaDeltaCqiMinHR             -150
    ...    dllaDeltaCqiStepdownHR        2000
    ...    dllaIniDeltaCqiHR              -50
    ...    dllaIniMcsHR                     3
    ...    dllaMcsMax64qamLowSERANK1HR     25
    ...    dllaMcsMax64qamLowSERANK2HR     25
    ...    dllaMcsMax64qamLowSERANK3HR     20
    ...    dllaMcsMax64qamLowSERANK4HR     20
    ...    dllaMcsMax64qamRANK1HR          25
    ...    dllaMcsMax64qamRANK2HR          25
    ...    dllaMcsMax64qamRANK3HR          20
    ...    dllaMcsMax64qamRANK4HR          20
    scf.add_item_to_list    dist_name=${distName_NRCELL[3]}   list_name=pdschHrLaConfig   elements=${pdschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List      dist_name=${distName_NRCELL[4]}  list_name=pdschHrLaConfig
    ${pdschHrLaConfig_item}=  create dictionary
    ...    dllaCqiOffsetHR                  0
    ...    dllaDeltaCqiMaxHR              150
    ...    dllaDeltaCqiMinHR             -150
    ...    dllaDeltaCqiStepdownHR        2000
    ...    dllaIniDeltaCqiHR              -50
    ...    dllaIniMcsHR                     3
    ...    dllaMcsMax64qamLowSERANK1HR     25
    ...    dllaMcsMax64qamLowSERANK2HR     25
    ...    dllaMcsMax64qamLowSERANK3HR     20
    ...    dllaMcsMax64qamLowSERANK4HR     20
    ...    dllaMcsMax64qamRANK1HR          25
    ...    dllaMcsMax64qamRANK2HR          25
    ...    dllaMcsMax64qamRANK3HR          20
    ...    dllaMcsMax64qamRANK4HR          20
    scf.add_item_to_list    dist_name=${distName_NRCELL[4]}   list_name=pdschHrLaConfig   elements=${pdschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRPDSCHHRLA_1}=  set variable  ${distName_NRBTS[0]}/NRPDSCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPDSCHHRLA
    ...           dist_name=${distName_NRPDSCHHRLA_1}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    dlHRBlerOutageMcsThresh64qamLowSE       2
    ...    dlHRBlerOutagePercentage                50
    ...    dlHRBlerOutagePeriod                    20
    ...    dlHRBlerRecoverMcsThresh64qamLowSE      10
    ...    dlHRBlerRecoverPercentage               60
    ...    dlHRBlerRecoverPeriod                   30
    ...    dllaBlerTargetHR                        5
    ...    dlHRBlerOutageMcsThresh64qam            3
    ...    dlHRBlerRecoverMcsThresh64qam           5
    ...    scalFactorForHRGbrDl                    110
        Set Element   dist_name=${distName_NRPDSCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${dist_name}                    ${value}   IN
    ...   ${distName_NRBTS[0]}/NRDRB-17   ${distName_NRBTS[0]}/NRPDSCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-14   ${distName_NRBTS[0]}/NRPDSCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-12   ${distName_NRBTS[0]}/NRPDSCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-18   ${distName_NRBTS[0]}/NRPDSCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-19   ${distName_NRBTS[0]}/NRPDSCHHRLA-1
          Set Element   dist_name=${dist_name}   p_name=nrPdschHRLaDN   value=${value}
    END


Configure CB008246 on PUSCH
    [Arguments]    ${ullaBlerTargetHR_1}    ${ullaBlerTargetHR_2}   ${NRPUSCHHRLA_2_5QI3}   ${NRPUSCHHRLA_3_5QI9}
    ...     ${NRPUSCHHRLA_4_5QI7}     ${NRPUSCHHRLA_5_5QI71}      ${NRPUSCHHRLA_6_5QI80}
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List      dist_name=${distName_NRCELL[1]}  list_name=puschHrLaConfig
    ${puschHrLaConfig_item}=  create dictionary
    ...    iniDeltaSinrHR                  -50
    ...    ullaDeltaSinrMaxHR              150
    ...    ullaDeltaSinrMinHR             -300
    ...    ullaDeltaSinrStepdownHR        2000
    ...    ullaIniMcsHR                      0
    ...    ullaSinrOffsetHR                  0
    ...    ullaMcsMax64qamLowSERANK1HR      25
    ...    ullaMcsMax64qamLowSERANK2HR      25
    ...    ullaMcsMax64qamRANK1HR           25
    ...    ullaMcsMax64qamRANK2HR           25
    scf.add_item_to_list    dist_name=${distName_NRCELL[1]}   list_name=puschHrLaConfig   elements=${puschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List      dist_name=${distName_NRCELL[3]}  list_name=puschHrLaConfig
    ${puschHrLaConfig_item}=  create dictionary
    ...    iniDeltaSinrHR                  -50
    ...    ullaDeltaSinrMaxHR              150
    ...    ullaDeltaSinrMinHR             -300
    ...    ullaDeltaSinrStepdownHR        2000
    ...    ullaIniMcsHR                      0
    ...    ullaSinrOffsetHR                  0
    ...    ullaMcsMax64qamLowSERANK1HR      25
    ...    ullaMcsMax64qamLowSERANK2HR      25
    ...    ullaMcsMax64qamRANK1HR           25
    ...    ullaMcsMax64qamRANK2HR           25
    scf.add_item_to_list    dist_name=${distName_NRCELL[3]}   list_name=puschHrLaConfig   elements=${puschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List      dist_name=${distName_NRCELL[4]}  list_name=puschHrLaConfig
    ${puschHrLaConfig_item}=  create dictionary
    ...    iniDeltaSinrHR                  -50
    ...    ullaDeltaSinrMaxHR              150
    ...    ullaDeltaSinrMinHR             -300
    ...    ullaDeltaSinrStepdownHR        2000
    ...    ullaIniMcsHR                      0
    ...    ullaSinrOffsetHR                  0
    ...    ullaMcsMax64qamLowSERANK1HR      25
    ...    ullaMcsMax64qamLowSERANK2HR      25
    ...    ullaMcsMax64qamRANK1HR           25
    ...    ullaMcsMax64qamRANK2HR           25
    scf.add_item_to_list    dist_name=${distName_NRCELL[4]}   list_name=puschHrLaConfig   elements=${puschHrLaConfig_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRPUSCHHRLA_1}=  set variable  ${distName_NRBTS[0]}/NRPUSCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPUSCHHRLA
    ...           dist_name=${distName_NRPUSCHHRLA_1}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    ulHRBlerOutagePercentage                   50
    ...    ulHRBlerOutagePeriod                       20
    ...    ulHRBlerOutageTbsThresh                 18000
    ...    ulHRBlerRecoverPercentage                  60
    ...    ulHRBlerRecoverPeriod                      30
    ...    ulHRBlerRecoverTbsThresh                20000
    ...    ullaBlerTargetHR        ${ullaBlerTargetHR_1}
    ...    scalFactorForHRGbrUl                      110
    ...    ulHRBlerOutageTbsThresh64qam	            1000
    ...    ulHRBlerRecoverTbsThresh64qam            7000
        Set Element   dist_name=${distName_NRPUSCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRPUSCHHRLA_2}=  set variable  ${distName_NRBTS[0]}/NRPUSCHHRLA-2
    Set Object    class_name=com.nokia.srbts.nrbts:NRPUSCHHRLA
    ...           dist_name=${distName_NRPUSCHHRLA_2}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    ulHRBlerOutagePercentage                   50
    ...    ulHRBlerOutagePeriod                       20
    ...    ulHRBlerOutageTbsThresh                 18000
    ...    ulHRBlerRecoverPercentage                  60
    ...    ulHRBlerRecoverPeriod                      30
    ...    ulHRBlerRecoverTbsThresh                20000
    ...    ullaBlerTargetHR        ${ullaBlerTargetHR_2}
    ...    scalFactorForHRGbrUl                      110
    ...    ulHRBlerOutageTbsThresh64qam	            1000
    ...    ulHRBlerRecoverTbsThresh64qam            7000
        Set Element   dist_name=${distName_NRPUSCHHRLA_2}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${dist_name}                    ${value}   IN
    ...   ${distName_NRBTS[0]}/NRDRB-17   ${distName_NRBTS[0]}/${NRPUSCHHRLA_2_5QI3}
    ...   ${distName_NRBTS[0]}/NRDRB-14   ${distName_NRBTS[0]}/${NRPUSCHHRLA_3_5QI9}
    ...   ${distName_NRBTS[0]}/NRDRB-12   ${distName_NRBTS[0]}/${NRPUSCHHRLA_4_5QI7}
    ...   ${distName_NRBTS[0]}/NRDRB-18   ${distName_NRBTS[0]}/${NRPUSCHHRLA_5_5QI71}
    ...   ${distName_NRBTS[0]}/NRDRB-19   ${distName_NRBTS[0]}/${NRPUSCHHRLA_6_5QI80}
          Set Element   dist_name=${dist_name}   p_name=nrPuschHRLaDN   value=${value}
    END


Configure CB008246 on PDCCH
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRBTS}
    ${distName_NRPDCCHHRLA_1}=  set variable  ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRPDCCHHRLA
    ...           dist_name=${distName_NRPDCCHHRLA_1}
    ...           version=NRBTSCL23R2_2302_100
    FOR    ${p_name}    ${value}    IN
    ...    pdcchHRBlerOutagePercentage             90
    ...    pdcchHRBlerOutagePeriod                 50
    ...    pdcchHRBlerRecoverPercentage            60
        Set Element   dist_name=${distName_NRPDCCHHRLA_1}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR   ${dist_name}                    ${value}   IN
    ...   ${distName_NRBTS[0]}/NRDRB-16   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-17   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-14   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-12   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-18   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
    ...   ${distName_NRBTS[0]}/NRDRB-19   ${distName_NRBTS[0]}/NRPDCCHHRLA-1
          Set Element   dist_name=${dist_name}   p_name=nrPdcchHRLaDN   value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]


Configure SCF File for subfeature CB008246-B
    Configure BWP_PDCCH
#    Configure BWP_PDCCH_CONFIG_DEDICATED


Configure BWP_PDCCH
    ${distName_PDCCH_BWP_31}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...                                                           regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-31/PDCCH-1
    Set Element    dist_name=${distName_PDCCH_BWP_31[0]}    p_name=alSelection    value=dynamic
    Set List    dist_name=${distName_PDCCH_BWP_31[0]}    list_name=dynamicAggregationLevelSet
    ${dynamicAggregationLevelSet_item}=  create dictionary
    ...    aggregationLevelList      AL1_AL2_AL4_AL8_AL16
    ...    cqiCorrectionUp                            100
    ...    cqiDciCssAl1                               130
    ...    cqiDciCssAl2                               100
    ...    cqiDciCssAl4                                70
    ...    cqiDciCssAl8                                40
    ...    cqiDciCssAl16                               20
    ...    highOlcCqiOffset                             1
    ...    lowOlcCqiOffset                              1
    ...    pCqiErasureActTimer                        160
    ...    pCqiErasureReduction                        50
    scf.add_item_to_list  dist_name=${distName_PDCCH_BWP_31[0]}  list_name=dynamicAggregationLevelSet  elements=${dynamicAggregationLevelSet_item}
    Set List        dist_name=${distName_PDCCH_BWP_31[0]}      list_name=dynamicAggregationLevelHRSet
    ${dynamicAggregationLevelHRSet_item}=  create dictionary
    ...    aggregationLevelListHR             AL2_AL4_AL8
    ...    cqiCorrectionUpHR                           20
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
    scf.add_item_to_list  dist_name=${distName_PDCCH_BWP_31[0]}
    ...                   list_name=dynamicAggregationLevelHRSet
    ...                   elements=${dynamicAggregationLevelHRSet_item}
    ${distName_PDCCH_BWP_4}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}
    ...                                                              regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-4/PDCCH-1
    Set Element    dist_name=${distName_PDCCH_BWP_4[0]}    p_name=alSelection    value=dynamic
    Set List    dist_name=${distName_PDCCH_BWP_4[0]}    list_name=dynamicAggregationLevelSet
    ${dynamicAggregationLevelSet_item}=  create dictionary
    ...    aggregationLevelList      AL1_AL2_AL4_AL8_AL16
    ...    cqiCorrectionUp                            100
    ...    cqiDciCssAl1                               130
    ...    cqiDciCssAl2                               100
    ...    cqiDciCssAl4                                70
    ...    cqiDciCssAl8                                40
    ...    cqiDciCssAl16                               20
    ...    highOlcCqiOffset                             1
    ...    lowOlcCqiOffset                              1
    ...    pCqiErasureActTimer                        160
    ...    pCqiErasureReduction                        50
    scf.add_item_to_list  dist_name=${distName_PDCCH_BWP_4[0]}  list_name=dynamicAggregationLevelSet  elements=${dynamicAggregationLevelSet_item}
    Set List        dist_name=${distName_PDCCH_BWP_4[0]}      list_name=dynamicAggregationLevelHRSet
    ${dynamicAggregationLevelHRSet_item}=  create dictionary
    ...    aggregationLevelListHR             AL2_AL4_AL8
    ...    cqiCorrectionUpHR                           20
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
    scf.add_item_to_list    dist_name=${distName_PDCCH_BWP_4[0]}
    ...                     list_name=dynamicAggregationLevelHRSet
    ...                     elements=${dynamicAggregationLevelHRSet_item}
    ${distName_PDCCH_BWP_7}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...                                                           regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-7/PDCCH-1
    Set Element    dist_name=${distName_PDCCH_BWP_7[0]}    p_name=alSelection    value=dynamic
    Set List    dist_name=${distName_PDCCH_BWP_7[0]}    list_name=dynamicAggregationLevelSet
    ${dynamicAggregationLevelSet_item}=  create dictionary
    ...    aggregationLevelList      AL1_AL2_AL4_AL8_AL16
    ...    cqiCorrectionUp                            100
    ...    cqiDciCssAl1                               130
    ...    cqiDciCssAl2                               100
    ...    cqiDciCssAl4                                70
    ...    cqiDciCssAl8                                40
    ...    cqiDciCssAl16                               20
    ...    highOlcCqiOffset                             1
    ...    lowOlcCqiOffset                              1
    ...    pCqiErasureActTimer                        160
    ...    pCqiErasureReduction                        50
    scf.add_item_to_list  dist_name=${distName_PDCCH_BWP_7[0]}  list_name=dynamicAggregationLevelSet  elements=${dynamicAggregationLevelSet_item}
    Set List        dist_name=${distName_PDCCH_BWP_7[0]}      list_name=dynamicAggregationLevelHRSet
    ${dynamicAggregationLevelHRSet_item}=  create dictionary
    ...    aggregationLevelListHR             AL2_AL4_AL8
    ...    cqiCorrectionUpHR                           20
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
    scf.add_item_to_list  dist_name=${distName_PDCCH_BWP_7[0]}
    ...                   list_name=dynamicAggregationLevelHRSet
    ...                   elements=${dynamicAggregationLevelHRSet_item}
    ${distName_PDCCH_BWP_73}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...                                                           regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-73/PDCCH-1
    Set Element    dist_name=${distName_PDCCH_BWP_73[0]}    p_name=alSelection    value=dynamic
    Set List    dist_name=${distName_PDCCH_BWP_73[0]}    list_name=dynamicAggregationLevelSet
    ${dynamicAggregationLevelSet_item}=  create dictionary
    ...    aggregationLevelList      AL1_AL2_AL4_AL8_AL16
    ...    cqiCorrectionUp                            100
    ...    cqiDciCssAl1                               130
    ...    cqiDciCssAl2                               100
    ...    cqiDciCssAl4                                70
    ...    cqiDciCssAl8                                40
    ...    cqiDciCssAl16                               20
    ...    highOlcCqiOffset                             1
    ...    lowOlcCqiOffset                              1
    ...    pCqiErasureActTimer                        160
    ...    pCqiErasureReduction                        50
    scf.add_item_to_list  dist_name=${distName_PDCCH_BWP_73[0]}  list_name=dynamicAggregationLevelSet  elements=${dynamicAggregationLevelSet_item}
    Set List        dist_name=${distName_PDCCH_BWP_73[0]}      list_name=dynamicAggregationLevelHRSet
    ${dynamicAggregationLevelHRSet_item}=  create dictionary
    ...    aggregationLevelListHR             AL2_AL4_AL8
    ...    cqiCorrectionUpHR                           20
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
    scf.add_item_to_list  dist_name=${distName_PDCCH_BWP_73[0]}
    ...                   list_name=dynamicAggregationLevelHRSet
    ...                   elements=${dynamicAggregationLevelHRSet_item}


Configure BWP_PDCCH_CONFIG_DEDICATED
    ${distName_PDCCH_CONFIG_DEDICATED}=  Get distNames from Local SCF File
    ...                                      scf_path=${original_gnb_scf}
    ...                                      regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]+/PDCCH-[0-9]+/PDCCH_CONFIG_DEDICATED-[0-9]+
    Set List   dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                                     0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                                      1
    ...      monitoringSymbolWithinSlot           symbol_0_1
    ...      numOfPdcchCandidatesInAL1                    n0
    ...      numOfPdcchCandidatesInAL2                    n1
    ...      numOfPdcchCandidatesInAL4                    n2
    ...      numOfPdcchCandidatesInAL8                    n0
    ...      numOfPdcchCandidatesInAL16                   n0
    ...      periodicity                                 sl1
    ...      searchSpaceId                                 7
    ...      searchSpaceType                           Type3
    ...      slotOffset                                    0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    ${searchSpaceDedicated_item2}=  create dictionary
    ...      coresetId                                     1
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                                      1
    ...      monitoringSymbolWithinSlot           symbol_0_1
    ...      numOfPdcchCandidatesInAL1                    n5
    ...      numOfPdcchCandidatesInAL2                    n4
    ...      numOfPdcchCandidatesInAL4                    n3
    ...      numOfPdcchCandidatesInAL8                    n2
    ...      numOfPdcchCandidatesInAL16                   n1
    ...      periodicity                                 sl1
    ...      searchSpaceId                                 8
    ...      searchSpaceType                     UE-Specific
    ...      slotOffset                                    0
    scf.add_item_to_list  dist_name=${distName_PDCCH_CONFIG_DEDICATED[0]}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}


Configure GBR for SA UEs in SCF File
    ${distName_NRCELL}=    Get distNames from Local SCF File   scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR  ${dist_name}  IN  @{distName_NRCELL}
        Set Element    dist_name=${dist_name}    p_name=actGBRAdmissionControl            value=GBRService
        Set Element    dist_name=${dist_name}    p_name=actVoNR                           value=false
        Set Element    dist_name=${dist_name}    p_name=actNonVoNRGbrService              value=true
        Set Element    dist_name=${dist_name}    p_name=maxNumOfGBRBearersSA              value=30
        Set Element    dist_name=${dist_name}    p_name=actGbrRacTdEnhResourcePriority    value=false
    END


Configure SCF File for dciDedicatedAggregationLevelHR
    ${distName_PDCCH}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...                                                    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/BWP_PROFILE-[0-9]+/PDCCH-[0-9]+
    sort list   ${distName_PDCCH}
    # BWP_PROFILE-0/4:
    Set Element     dist_name=${distName_PDCCH[4]}      p_name=dciDedicatedAggregationLevelHR      value=AL4
    # BWP_PROFILE-44:
    Set Element     dist_name=${distName_PDCCH[1]}      p_name=dciDedicatedAggregationLevelHR      value=AL4


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Configure new NRDRB-16
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB16}=  Set variable  ${distName_NRBTS[0]}/NRDRB-16
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB
    ...           dist_name=${distName_NRDRB16}
    ...           version=NRBTSCL25R3_2506_112
    FOR    ${p_name}    ${value}    IN
    ...    actDddsReduction                  false
    ...    actLostPduFastRetx                false
    ...    allowedPdcchPowerBoostALDueCce    none
    ...    allowedPdcchPowerBoostALDueCfg    None
    ...    caPduReSendingDelayMargin         2
    ...    discardTimer                      100ms
    ...    discardTimerUl                    100ms
    ...    dlAllowMinDelayLinkXxCalib        false
    ...    dlFlowControlAlgo                 3gppFlowControl
    ...    dscp                              26
    ...    durationThresDiscardDlMacSdu      40
    ...    durationThresDiscardDlPdcpPdu5GLeg     40
    ...    durationThresDiscardDlPdcpPduLteLeg    40
    ...    endMarkerTimer                    2000
    ...    l2OHFactorDl                      16
    ...    l2OHFactorUl                      35
    ...    maxDataRateGbrDl                  30720
    ...    maxDataRateGbrUl                  30720
    ...    maxDddsPeriodCpuOvld              40
    ...    maxRlcQueueingDelayGbr            20
    ...    maxTransferDelayGbr               20
    ...    nrDrbMacDN                        MRBTS-1/NRBTS-1/NRDRB_MAC-5
    ...    nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-2
    ...    nrDrbRlcUmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...    nrDrxDN                           MRBTS-1/NRBTS-1/NRDRX-1
    ...    numSduDiscard                     1
    ...    queuingDelayDiscarding            Disabled
    ...    queuingDelaySduDiscardThreshold   750
    ...    queuingDelayDiscardStart          5
    ...    resType                           GBR
    ...    rlcMode                           RLC_UM
    ...    rlcPduDelayThCa                   30
    ...    schedulWeight                     1
    ...    sduDiscardIntervalTmr             500
    ...    volThresDiscardDlMacSdu           8000
    ...    volThresDiscardDlPdcpPdu5GLeg     8000
    ...    volThresDiscardDlPdcpPduLteLeg    8000
    ...    actDlTxResumeOnPdcpStatRep        false
    ...    durationThresDiscardDl            40
    ...    durationThresDiscardUl            20
    ...    volThresDiscardDl                 8000
    ...    volThresDiscardUl                 800
    ...    actOptDataFlowRateEst             false
    ...    maxForwardTimeLimitXx            50
    ...    minForwardTputXx                 100
    ...    srsStaticUeDoublePeriodicity     false
        Set Element   dist_name=${distName_NRDRB16}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName_NRDRB16}  list_name=cellAggrLevel
    ${param_list}=    create list    Not FR1 CA eligible
    scf.add_elements_to_list    dist_name=${distName_NRDRB16}    list_name=cellAggrLevel    elements=${param_list}


Configure new NRDRB-17
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB17}=  Set variable  ${distName_NRBTS[0]}/NRDRB-17
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB
    ...           dist_name=${distName_NRDRB17}
    ...           version=NRBTSCL25R3_2506_112
    FOR    ${p_name}    ${value}    IN
    ...    actDddsReduction                  false
    ...    actLostPduFastRetx                false
    ...    allowedPdcchPowerBoostALDueCce    none
    ...    allowedPdcchPowerBoostALDueCfg    None
    ...    caPduReSendingDelayMargin         2
    ...    discardTimer                      100ms
    ...    discardTimerUl                    100ms
    ...    dlAllowMinDelayLinkXxCalib        false
    ...    dlFlowControlAlgo                 3gppFlowControl
    ...    dscp                              26
    ...    durationThresDiscardDlMacSdu      40
    ...    durationThresDiscardDlPdcpPdu5GLeg     40
    ...    durationThresDiscardDlPdcpPduLteLeg    40
    ...    endMarkerTimer                    2000
    ...    l2OHFactorDl                      50
    ...    l2OHFactorUl                      50
    ...    maxDataRateGbrDl                  1024
    ...    maxDataRateGbrUl                  1024
    ...    maxDddsPeriodCpuOvld              40
    ...    maxRlcQueueingDelayGbr            20
    ...    maxTransferDelayGbr               20
    ...    nrDrbMacDN                        MRBTS-1/NRBTS-1/NRDRB_MAC-5
    ...    nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-2
    ...    nrDrbRlcUmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...    nrDrxDN                           MRBTS-1/NRBTS-1/NRDRX-1
    ...    numSduDiscard                     1
    ...    queuingDelayDiscarding            Disabled
    ...    queuingDelaySduDiscardThreshold   750
    ...    queuingDelayDiscardStart          5
    ...    resType                           GBR
    ...    rlcMode                           RLC_UM
    ...    rlcPduDelayThCa                   30
    ...    schedulWeight                     1
    ...    sduDiscardIntervalTmr             500
    ...    volThresDiscardDlMacSdu           8000
    ...    volThresDiscardDlPdcpPdu5GLeg     8000
    ...    volThresDiscardDlPdcpPduLteLeg    8000
    ...    actDlTxResumeOnPdcpStatRep        false
    ...    durationThresDiscardDl            40
    ...    durationThresDiscardUl            20
    ...    volThresDiscardDl                 8000
    ...    volThresDiscardUl                 800
    ...    actOptDataFlowRateEst             false
    ...    maxForwardTimeLimitXx            50
    ...    minForwardTputXx                 100
    ...    srsStaticUeDoublePeriodicity     false
        Set Element   dist_name=${distName_NRDRB17}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName_NRDRB17}  list_name=cellAggrLevel
    ${param_list}=    create list    Not FR1 CA eligible
    scf.add_elements_to_list    dist_name=${distName_NRDRB17}    list_name=cellAggrLevel    elements=${param_list}


Configure new NRDRB-18
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB18}=  Set variable  ${distName_NRBTS[0]}/NRDRB-18
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB
    ...           dist_name=${distName_NRDRB18}
    ...           version=NRBTSCL25R3_2506_112
    FOR    ${p_name}    ${value}    IN
    ...    actDddsReduction                  false
    ...    actLostPduFastRetx                false
    ...    allowedPdcchPowerBoostALDueCce    none
    ...    allowedPdcchPowerBoostALDueCfg    None
    ...    caPduReSendingDelayMargin         2
    ...    discardTimer                      100ms
    ...    discardTimerUl                    100ms
    ...    dlAllowMinDelayLinkXxCalib        false
    ...    dlFlowControlAlgo                 3gppFlowControl
    ...    dscp                              26
    ...    durationThresDiscardDlMacSdu      40
    ...    durationThresDiscardDlPdcpPdu5GLeg     40
    ...    durationThresDiscardDlPdcpPduLteLeg    40
    ...    endMarkerTimer                    2000
    ...    l2OHFactorDl                      50
    ...    l2OHFactorUl                      50
    ...    maxDataRateGbrDl                  30720
    ...    maxDataRateGbrUl                  30720
    ...    maxDddsPeriodCpuOvld              40
    ...    maxRlcQueueingDelayGbr            20
    ...    maxTransferDelayGbr               20
    ...    nrDrbMacDN                        MRBTS-1/NRBTS-1/NRDRB_MAC-5
    ...    nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-2
    ...    nrDrbRlcUmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...    nrDrxDN                           MRBTS-1/NRBTS-1/NRDRX-1
    ...    numSduDiscard                     1
    ...    queuingDelayDiscarding            Disabled
    ...    queuingDelaySduDiscardThreshold   750
    ...    queuingDelayDiscardStart          5
    ...    resType                           GBR
    ...    rlcMode                           RLC_UM
    ...    rlcPduDelayThCa                   30
    ...    schedulWeight                     1
    ...    sduDiscardIntervalTmr             500
    ...    volThresDiscardDlMacSdu           8000
    ...    volThresDiscardDlPdcpPdu5GLeg     8000
    ...    volThresDiscardDlPdcpPduLteLeg    8000
    ...    actDlTxResumeOnPdcpStatRep        false
    ...    durationThresDiscardDl            40
    ...    durationThresDiscardUl            20
    ...    volThresDiscardDl                 8000
    ...    volThresDiscardUl                 800
    ...    actOptDataFlowRateEst             false
    ...    maxForwardTimeLimitXx            50
    ...    minForwardTputXx                 100
    ...    srsStaticUeDoublePeriodicity     false
        Set Element   dist_name=${distName_NRDRB18}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName_NRDRB18}  list_name=cellAggrLevel
    ${param_list}=    create list    Not FR1 CA eligible
    scf.add_elements_to_list    dist_name=${distName_NRDRB18}    list_name=cellAggrLevel    elements=${param_list}


Configure new NRDRB-19
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB19}=  Set variable  ${distName_NRBTS[0]}/NRDRB-19
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB
    ...           dist_name=${distName_NRDRB19}
    ...           version=NRBTSCL25R3_2506_112
    FOR    ${p_name}    ${value}    IN
    ...    actDddsReduction                  false
    ...    actLostPduFastRetx                false
    ...    allowedPdcchPowerBoostALDueCce    none
    ...    allowedPdcchPowerBoostALDueCfg    None
    ...    caPduReSendingDelayMargin         2
    ...    discardTimer                      infinity
    ...    discardTimerUl                    infinity
    ...    dlAllowMinDelayLinkXxCalib        false
    ...    dlFlowControlAlgo                 3gppFlowControl
    ...    dscp                              0
    ...    durationThresDiscardDlMacSdu      40
    ...    durationThresDiscardDlPdcpPdu5GLeg     40
    ...    durationThresDiscardDlPdcpPduLteLeg    40
    ...    endMarkerTimer                    2000
    ...    maxDataRateGbrDl                  1000
    ...    maxDataRateGbrUl                  1000
    ...    maxDddsPeriodCpuOvld              40
    ...    maxRlcQueueingDelayGbr            20
    ...    maxTransferDelayGbr               20
    ...    nrDrbMacDN                        MRBTS-1/NRBTS-1/NRDRB_MAC-2
    ...    nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-2
    ...    nrDrbRlcAmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
    ...    nrDrxDN                           MRBTS-1/NRBTS-1/NRDRX-1
    ...    numSduDiscard                     1
    ...    queuingDelayDiscarding            Disabled
    ...    queuingDelaySduDiscardThreshold   750
    ...    queuingDelayDiscardStart          5
    ...    resType                           nonGBR
    ...    rlcMode                           RLC_AM
    ...    rlcPduDelayThCa                   30
    ...    schedulWeight                     1
    ...    sduDiscardIntervalTmr             500
    ...    volThresDiscardDlMacSdu           8000
    ...    volThresDiscardDlPdcpPdu5GLeg     8000
    ...    volThresDiscardDlPdcpPduLteLeg    8000
    ...    actDlTxResumeOnPdcpStatRep        false
    ...    durationThresDiscardDl            40
    ...    durationThresDiscardUl            20
    ...    volThresDiscardDl                 8000
    ...    volThresDiscardUl                 800
    ...    actOptDataFlowRateEst             false
    ...    maxForwardTimeLimitXx            50
    ...    minForwardTputXx                 100
    ...    srsStaticUeDoublePeriodicity     false
        Set Element   dist_name=${distName_NRDRB19}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName_NRDRB19}  list_name=cellAggrLevel
    ${param_list}=    create list    FR1 CA eligible
    scf.add_elements_to_list    dist_name=${distName_NRDRB19}    list_name=cellAggrLevel    elements=${param_list}


Configure new 5QI-7 and set it to 2 and connect it to NRDRB-16
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
	${distName_NRDRB5QI7}=  Set variable  ${distName_NRBTS[0]}/NRDRB_5QI-7
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...           dist_name=${distName_NRDRB5QI7}
    ...           version=NRBTSCL23R3_2305_100
    Set Element   dist_name=${distName_NRDRB5QI7}  p_name=nrDrbDN                           value=MRBTS-1/NRBTS-1/NRDRB-16
    Set List      dist_name=${distName_NRDRB5QI7}  list_name=fiveqiValueList
    ${param_list}=    create list  2
    scf.add_elements_to_list  dist_name=${distName_NRDRB5QI7}  list_name=fiveqiValueList   elements=${param_list}
    Set Element   dist_name=${distName_NRDRB5QI7}    p_name=dataForwarding    value=IRATDataFwd


Configure new 5QI-8 and set it to 3 and connect it to NRDRB-17
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
	${distName_NRDRB5QI8}=  Set variable  ${distName_NRBTS[0]}/NRDRB_5QI-8
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...           dist_name=${distName_NRDRB5QI8}
    ...           version=NRBTSCL23R3_2305_100
    Set Element   dist_name=${distName_NRDRB5QI8}  p_name=nrDrbDN                           value=MRBTS-1/NRBTS-1/NRDRB-17
    Set List      dist_name=${distName_NRDRB5QI8}  list_name=fiveqiValueList
    ${param_list}=    create list  3
    scf.add_elements_to_list  dist_name=${distName_NRDRB5QI8}  list_name=fiveqiValueList   elements=${param_list}
    Set Element   dist_name=${distName_NRDRB5QI8}    p_name=dataForwarding    value=IRATDataFwd


Configure new 5QI-9 and set it to 71 and connect it to NRDRB-18
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB5QI9}=  Set variable  ${distName_NRBTS[0]}/NRDRB_5QI-9
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...           dist_name=${distName_NRDRB5QI9}
    ...           version=NRBTSCL23R3_2305_100
    Set Element   dist_name=${distName_NRDRB5QI9}  p_name=nrDrbDN                           value=MRBTS-1/NRBTS-1/NRDRB-18
    Set List      dist_name=${distName_NRDRB5QI9}  list_name=fiveqiValueList
    ${param_list}=    create list  71
    scf.add_elements_to_list  dist_name=${distName_NRDRB5QI9}  list_name=fiveqiValueList   elements=${param_list}
    Set Element   dist_name=${distName_NRDRB5QI9}    p_name=dataForwarding    value=IRATDataFwd


Configure new 5QI-10 and set it to 80 and connect it to NRDRB-19
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDRB5QI10}=  Set variable  ${distName_NRBTS[0]}/NRDRB_5QI-10
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_5QI
    ...           dist_name=${distName_NRDRB5QI10}
    ...           version=NRBTSCL23R3_2305_100
    Set Element   dist_name=${distName_NRDRB5QI10}  p_name=nrDrbDN                           value=MRBTS-1/NRBTS-1/NRDRB-19
    Set List      dist_name=${distName_NRDRB5QI10}  list_name=fiveqiValueList
    ${param_list}=    create list  80
    scf.add_elements_to_list  dist_name=${distName_NRDRB5QI10}  list_name=fiveqiValueList   elements=${param_list}
    Set Element   dist_name=${distName_NRDRB5QI10}    p_name=dataForwarding    value=IRATDataFwd


Configure new MAC-5
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
	${distName_NRDRBMAC5}=  Set variable  ${distName_NRBTS[0]}/NRDRB_MAC-5
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_MAC
    ...           dist_name=${distName_NRDRBMAC5}
    ...           version=NRBTSCL23R3_2305_100
    FOR    ${p_name}    ${value}    IN
    ...    delayTarget                       150
    ...    lcgid                             5
    ...    prioritisedBitRate                16kBps
    ...    schedulBSD                        100ms
    ...    schedulPrio                       7
        Set Element   dist_name=${distName_NRDRBMAC5}    p_name=${p_name}    value=${value}
    END

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Configure Channels for 4DL4UL
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure each Cell for 4DL4UL     ${NRCELL}
        ${cellNumber}=    get substring    ${NRCELL}    -1
        Modify CHANNELGROUP-1 for 4DL4UL   ${cellNumber}
    END


Configure each Cell for 4DL4UL
    [Arguments]  ${distName}
    FOR    ${p_name}    ${value}    IN
    ...    dlMimoMode                            4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    nrCellType                            4DL4UL
        Set Element   dist_name=${distName}    p_name=${p_name}    value=${value}
    END


Modify CHANNELGROUP-1 for 4DL4UL
    [Arguments]  ${cellNumber}
    FOR  ${channelId}  IN RANGE  1   5
        ${distName_CHANNEL}=  Set variable  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellNumber}/CHANNELGROUP-1/CHANNEL-${channelId}
        Set Object    class_name=com.nokia.srbts.mnl:CHANNEL
        ...           dist_name=${distName_CHANNEL}
        ...           version=NRBTSCL23R3_2305_100
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=direction
        ...           value=TX
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=resourceDN
        ...           value=MRBTS-1/EQM-1/APEQM-1/RMOD-${cellNumber}/PHYANT-1
    END
    FOR  ${channelId}  IN RANGE  5   9
        ${distName_CHANNEL}=  Set variable  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellNumber}/CHANNELGROUP-1/CHANNEL-${channelId}
        Set Object    class_name=com.nokia.srbts.mnl:CHANNEL
        ...           dist_name=${distName_CHANNEL}
        ...           version=NRBTSCL23R3_2305_100
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=direction
        ...           value=RX
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=resourceDN
        ...           value=MRBTS-1/EQM-1/APEQM-1/RMOD-${cellNumber}/PHYANT-1
    END


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate 5GC002271
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                            ${value}    IN
    ...    actAdaptiveSr                            true
    ...    adaptiveSrBlockingMinimization             20
    ...    adaptiveSrLoadThresholdDown                50
    ...    adaptiveSrLoadThresholdUp                  80
    ...    srPeriodicityMin                      slots40
    ...    vonrReservation                             0
        Set Element   dist_name=${distName_NRCELL[0]}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                            ${value}    IN
    ...    actUlTxSkip                              false
    ...    payloadSizeProactiveTxSkip                 80
    ...    ulProGrantTimerTxSkip                    1200
    ...    ulSchedTimeIntervalTxSkip                 150
        Set Element   dist_name=${distName_NRCELL[0]}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                            ${value}    IN
    ...    actProactUlScheduling                    true
    ...    payloadSizeProactiveDrx                    64
    ...    payloadSizeProactiveNonDrx                 16
        Set Element   dist_name=${distName_NRCELL[0]}    p_name=${p_name}    value=${value}
    END

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Configure new NRDRB_PDCP-2
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRDRB_PDCP_2}=  Set variable  ${distName_NRBTS[0]}/NRDRB_PDCP-2
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_PDCP
    ...           dist_name=${distName_NRDRB_PDCP_2}
    ...           version=NRBTSCL23R3_2305_100
    FOR    ${p_name}                    ${value}    IN
    ...    cuFlowControlProfId          1
    ...    pdcpBufDiscardEnabled        false
    ...    pdcpBufDiscardThreshold      20000
    ...    pdcpDelayThreshRetxMode      disabled
    ...    tReorderingDl                ms100
    ...    tReorderingUl                ms100
    ...    x2FlowControlProfIdForCu     1
        Set Element   dist_name=${distName_NRDRB_PDCP_2}    p_name=${p_name}    value=${value}
    END

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Configure new NRDRB_RLC_UM-1
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRDRB_RLC_UM-1}=  Set variable  ${distName_NRBTS[0]}/NRDRB_RLC_UM-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRDRB_RLC_UM
    ...           dist_name=${distName_NRDRB_RLC_UM-1}
    ...           version=NRBTSCL23R3_2305_100
    FOR    ${p_name}                    ${value}        IN
    ...    dlTReassemblyUm              ms50
    ...    rlcUMDrbSNLength             rlcUm12bitSN
    ...    ulTReassemblyUm              ms50
        Set Element   dist_name=${distName_NRDRB_RLC_UM-1}    p_name=${p_name}    value=${value}
    END


Activate ACSI and DFT-S-OFDM Functionality
    ${distName_NRBTS}=    Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Get distNames from Local SCF File  scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}             ${p_name}                   ${value}        IN
    ...    ${distName_NRBTS[0]}     sCellActivationMethod       blind
    ...    ${distName_NRCELL[0]}    actDl256Qam                 true
    ...    ${distName_NRCELL[1]}    actDl256Qam                 true
    ...    ${distName_NRCELL[2]}    actDl256Qam                 true
    ...    ${distName_NRCELL[3]}    actDl256Qam                 true
    ...    ${distName_NRCELL[4]}    actDl256Qam                 true
    ...    ${distName_NRCELL[0]}    actUl256Qam                 true
    ...    ${distName_NRCELL[1]}    actUl256Qam                 true
    ...    ${distName_NRCELL[2]}    actUl256Qam                 true
    ...    ${distName_NRCELL[3]}    actUl256Qam                 true
    ...    ${distName_NRCELL[4]}    actUl256Qam                 true
    ...    ${distName_NRCELL[0]}    actAperCsi                  true
    ...    ${distName_NRCELL[1]}    actAperCsi                  true
    ...    ${distName_NRCELL[2]}    actAperCsi                  true
    ...    ${distName_NRCELL[3]}    actAperCsi                  true
    ...    ${distName_NRCELL[4]}    actAperCsi                  true
    ...    ${distName_NRCELL[0]}    actUlDftSOfdm                  true
    ...    ${distName_NRCELL[1]}    actUlDftSOfdm                  true
    ...    ${distName_NRCELL[2]}    actUlDftSOfdm                  true
    ...    ${distName_NRCELL[3]}    actUlDftSOfdm                  true
    ...    ${distName_NRCELL[4]}    actUlDftSOfdm                  true
    ...    ${distName_NRCELL[0]}    a2MeasSCellRelEnabled                  none
    ...    ${distName_NRCELL[1]}    a2MeasSCellRelEnabled                  none
    ...    ${distName_NRCELL[2]}    a2MeasSCellRelEnabled                  none
    ...    ${distName_NRCELL[3]}    a2MeasSCellRelEnabled                  none
    ...    ${distName_NRCELL[4]}    a2MeasSCellRelEnabled                  none
    ...    ${distName_NRCELL[0]}    SCellBadChannelQualityThUL                  1
    ...    ${distName_NRCELL[1]}    SCellBadChannelQualityThUL                  1
    ...    ${distName_NRCELL[2]}    SCellBadChannelQualityThUL                  1
    ...    ${distName_NRCELL[3]}    SCellBadChannelQualityThUL                  1
    ...    ${distName_NRCELL[4]}    SCellBadChannelQualityThUL                  1
    ...    ${distName_NRCELL[0]}    actUlLaOllaForRetxInDft                  true
    ...    ${distName_NRCELL[1]}    actUlLaOllaForRetxInDft                  true
    ...    ${distName_NRCELL[2]}    actUlLaOllaForRetxInDft                  true
    ...    ${distName_NRCELL[3]}    actUlLaOllaForRetxInDft                  true
    ...    ${distName_NRCELL[4]}    actUlLaOllaForRetxInDft                  true
    ...    ${distName_NRCELL[0]}    sCellDeactivationTimerGNB   infinity
    ...    ${distName_NRCELL[1]}    sCellDeactivationTimerGNB   infinity
    ...    ${distName_NRCELL[2]}    sCellDeactivationTimerGNB   infinity
    ...    ${distName_NRCELL[3]}    sCellDeactivationTimerGNB   infinity
    ...    ${distName_NRCELL[4]}    sCellDeactivationTimerGNB   infinity
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
