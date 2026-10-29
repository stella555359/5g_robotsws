*** Settings ***

Documentation
...    author: VRF ULM T01 01 and VRF ULM T04 01
...    Team: 'MN RAN RD VRF ULM 1' and 'MN RAN RD VRF ULM 4'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: Commissioning for CB009267-A,-B and -D

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource  ./CB009267_Keywords.robot

*** Variables ***

${NIDD_VERSION}                  NRBTSCL25R2_2422_111

*** Keywords ***

Activating CB009267 Feature Flag
    [Documentation]   Activate CB009267 Feature Flag
    scf.load_scf          ${P_ORIG_SCF}
    Update feature flag   feature_flag=true
    Apply Delta SCF       ${P_ORIG_SCF}  scf_9267-D.xml

Updating Feature Activation flag
    [Arguments]    ${test_instance}  ${action}
    ${scf_file}=       Load current SCF
    IF        '${action}' == '_featureflag_disabled'
        Update feature flag   feature_flag=false
    ELSE IF   '${action}' == '_featureflag_enabled'
        Update feature flag   feature_flag=true
    END
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_${action}

Update feature flag
    [Documentation]    Updates the feature flag NRBTS/actCarAgPmCount of CB009267
    [Arguments]    ${feature_flag}
    Set Element    dist_name=MRBTS-1/NRBTS-1            p_name=actCarAgPmCount      value=${feature_flag}

Apply Configs for D_EI_B2_3
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    Set New List       dist_name=MRBTS-1/NRBTS-1    list_name=actMeasBasedSCellAdditionSa
    ${actMeasBasedSCellAdditionSa_list}=  create list   A1-based
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1   list_name=actMeasBasedSCellAdditionSa   elements=${actMeasBasedSCellAdditionSa_list}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-1
    Set Element    dist_name=${dist_name}     p_name=a1MeasSCellAddEnabled      value=rsrp
    Set New List                    dist_name=${dist_name}          list_name=a1MeasSCellAddSsbRsrp
    ${a1MeasRsrp_dict}              Create dictionary               a1ThresholdSCellAddSsbRsrpFDD          50
    ...                                                             a1ThresholdSCellAddSsbRsrpTDD          60
    ...                                                             a1TimeToTriggerSCellAddSsbRsrp         320ms
    ...                                                             a1HysteresisSCellAddSsbRsrp	           0
    scf.add_item_to_list            dist_name=${dist_name}          list_name=a1MeasSCellAddSsbRsrp        elements=${a1MeasRsrp_dict}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1
    FOR    ${cell_id}    IN RANGE    2  6
        Set Element             dist_name=${dist_name}/NRCELL-${cell_id}     p_name=a2MeasSCellRelEnabled            value=rsrp
        Set New List            dist_name=${dist_name}/NRCELL-${cell_id}     list_name=a2MeasSCellRelSsbRsrp
        ${list_elements}=       Create dictionary                            a2HysteresisSCellRelSsbRsrp             0
        ...                                                                  a2ThresholdSCellRelSsbRsrp              34
        ...                                                                  a2TimeToTriggerSCellRelSsbRsrp          2560ms
        scf.add_item_to_list    dist_name=${dist_name}/NRCELL-${cell_id}     list_name=a2MeasSCellRelSsbRsrp         elements=${list_elements}
    END
    ${dist_name}=               Set Variable                      MRBTS-1/NRBTS-1/NRCELL-1
    FOR    ${cell_index}    IN RANGE    1   5
        Set Element                 dist_name=${dist_name}/NRREL-${cell_index}           p_name=sCellAdditionMethod    value=covBasedA1
    END
    scf.remove_mo_with_descendant_mos               MRBTS-1/NRBTS-1/NRCELL-1/NRREL-5
    scf.remove_mo_with_descendant_mos               MRBTS-1/NRBTS-1/NRCELL-1/NRREL-6
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Apply Configs for D_EI_B2_2
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-4
    FOR    ${cell_index}    IN RANGE    1   5
        Set Element                 dist_name=${dist_name}/NRREL-${cell_index}           p_name=sCellAdditionMethod    value=covBasedA1
    END
    FOR    ${cell_index}    IN RANGE    3   5
        Set Element                 dist_name=${dist_name}/NRREL-${cell_index}           p_name=sCellOperationalMode    value=dlAndUl
    END
    Set Element      dist_name=MRBTS-1/NRBTS-1/NRCELL-1     p_name=maxNumOfSCellAlloc      value=0
    Set Element      dist_name=MRBTS-1/NRBTS-1/NRCELL-2     p_name=maxNumOfSCellAlloc      value=0
    Set Element      dist_name=MRBTS-1/NRBTS-1/NRCELL-5     p_name=maxNumOfSCellAlloc      value=0
    Set New List       dist_name=MRBTS-1/NRBTS-1    list_name=actMeasBasedSCellAdditionSa
    ${actMeasBasedSCellAdditionSa_list}=  create list   A1-based
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1   list_name=actMeasBasedSCellAdditionSa   elements=${actMeasBasedSCellAdditionSa_list}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-4
    Set Element    dist_name=${dist_name}     p_name=a1MeasSCellAddEnabled      value=rsrp
    Set New List                    dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp
    ${a1MeasRsrp_dict}              Create dictionary                    a1ThresholdSCellAddSsbRsrpFDD           50
    ...                                                                  a1ThresholdSCellAddSsbRsrpTDD           60
    ...                                                                  a1TimeToTriggerSCellAddSsbRsrp          320ms
    ...                                                                  a1HysteresisSCellAddSsbRsrp	         0
    scf.add_item_to_list            dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp         elements=${a1MeasRsrp_dict}
    Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-3           p_name=a2MeasSCellRelEnabled            value=rsrp
    Set New List            dist_name=MRBTS-1/NRBTS-1/NRCELL-3           list_name=a2MeasSCellRelSsbRsrp
    ${list_elements}=       Create dictionary                            a2HysteresisSCellRelSsbRsrp             0
    ...                                                                  a2ThresholdSCellRelSsbRsrp              34
    ...                                                                  a2TimeToTriggerSCellRelSsbRsrp          2560ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-3           list_name=a2MeasSCellRelSsbRsrp         elements=${list_elements}
    Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-6           p_name=a2MeasSCellRelEnabled            value=rsrp
    Set New List            dist_name=MRBTS-1/NRBTS-1/NRCELL-6           list_name=a2MeasSCellRelSsbRsrp
    ${list_elements}=       Create dictionary                            a2HysteresisSCellRelSsbRsrp             0
    ...                                                                  a2ThresholdSCellRelSsbRsrp              34
    ...                                                                  a2TimeToTriggerSCellRelSsbRsrp          2560ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-6           list_name=a2MeasSCellRelSsbRsrp         elements=${list_elements}
    Set New List            dist_name=MRBTS-1/NRBTS-1/NRDU-1             list_name=carrierAggregationSupportList
    ${param_list}=                  Create List    ca_Fdd_Any_Sa   ca_Fr1Tdd_Any_Sa   ca_Fr1Tdd_Fdd_Sa   ca_Fr1Tdd_Sa
    ...     ca_Fdd_Fr1Tdd_Sa  ca_Fdd_Fdd  ca_Fdd_Fr1Tdd_Sa_WithUl  ca_Fr1Tdd_Fdd_Sa_WithUl  ca_Fdd_Fdd_Sa_WithUl
    scf.add_elements_to_list        dist_name=MRBTS-1/NRBTS-1/NRDU-1      list_name=carrierAggregationSupportList   elements=${param_list}
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Apply Configs for A_EI_B101_2
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-4

    FOR    ${cell_index}    IN   1  2  3  4
        Set Element                 dist_name=${dist_name}/NRREL-${cell_index}           p_name=sCellAdditionMethod    value=covBasedA1
    END

    FOR    ${cell_index}    IN   1  2
        Set Element                 dist_name=${dist_name}/NRREL-${cell_index}           p_name=sCellOperationalMode    value=dlAndUl
    END

    FOR   ${dist_name}                              IN
    ...   MRBTS-1/NRBTS-1/NRCELL-3
    ...   MRBTS-1/NRBTS-1/NRCELL-5
    ...   MRBTS-1/NRBTS-1/NRCELL-6
          Set Element    dist_name=${dist_name}     p_name=maxNumOfSCellAlloc      value=0
    END

    Set New List     dist_name=MRBTS-1/NRBTS-1              list_name=actMeasBasedSCellAdditionSa
    ${actMeasBasedSCellAdditionSa_list}=  create list   A1-based
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1   list_name=actMeasBasedSCellAdditionSa   elements=${actMeasBasedSCellAdditionSa_list}

    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-4

    Set Element                 dist_name=${dist_name}               p_name=a1MeasSCellAddEnabled            value=rsrp

    Set New List                dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp
    ${a1MeasRsrp_dict}          Create dictionary                    a1ThresholdSCellAddSsbRsrpFDD           50
    ...                                                              a1ThresholdSCellAddSsbRsrpTDD           50
    ...                                                              a1TimeToTriggerSCellAddSsbRsrp          320ms
    ...                                                              a1HysteresisSCellAddSsbRsrp	         0
    scf.add_item_to_list        dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp         elements=${a1MeasRsrp_dict}

    Set Element                 dist_name=MRBTS-1/NRBTS-1                          p_name=actSCellSwapFr1                  value=a6BasedSa

    FOR   ${cell_index}   IN   1  2
        Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     p_name=a6MeasSCellSwapEnabled           value=rsrp
        Set New List            dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     list_name=a6MeasSCellSwapSsbRsrp
        ${list_elements}=       Create dictionary                                  a6HysteresisSCellSwapSsbRsrp             0
        ...                                                                        a6OffsetSCellSwapSsbRsrp                 3
        ...                                                                        a6TimeToTrigSCellSwapSsbRsrp             ms480
        ...                                                                        useAllowedCellListRsrp                   false
        scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     list_name=a6MeasSCellSwapSsbRsrp         elements=${list_elements}
        Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     p_name=thresholdSCellSwapSourceRsrp      value=56
    END

    FOR   ${dist_name}                              ${p_name}                      ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1          sCellPrio                      1
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-2          sCellPrio                      2
    ...   MRBTS-1/NRBTS-1/NRCELL-2                  gscnOrSsPbchArfcn              6486
    ...   MRBTS-1/NRBTS-1/NRCELL-2                  nrarfcn                        519000
          Set Element    dist_name=${dist_name}     p_name=${p_name}               value=${value}
    END

    FOR   ${cell_index}   IN   1  2
        Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     p_name=a2MeasSCellRelEnabled             value=rsrp
        Set New List            dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     list_name=a2MeasSCellRelSsbRsrp
        ${list_elements}=       Create dictionary                                  a2HysteresisSCellRelSsbRsrp              0
        ...                                                                        a2ThresholdSCellRelSsbRsrp               34
        ...                                                                        a2TimeToTriggerSCellRelSsbRsrp           2560ms
        scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     list_name=a2MeasSCellRelSsbRsrp         elements=${list_elements}
    END

    #Removing relation errors:
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1

    FOR   ${cell_index}   IN   1  2
        Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     p_name=reportAmountA6MeasSCellSwap             value=r4
        Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     p_name=reportIntervalA6MeasSCellSwap           value=ms1024
        scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-3/NRREL-${cell_index}
        scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-5/NRREL-${cell_index}
        scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-6/NRREL-${cell_index}
    END

    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Apply Configs for A_EI_B201-1
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    FOR   ${dist_name}                              IN
    ...   MRBTS-1/NRBTS-1/NRCELL-2
    ...   MRBTS-1/NRBTS-1/NRCELL-3
    ...   MRBTS-1/NRBTS-1/NRCELL-6
          Set Element    dist_name=${dist_name}     p_name=maxNumOfSCellAlloc      value=0
    END
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1
    FOR   ${p_name}                         ${value}                       IN
    ...   sCellActivationMethod             bufferBased
    ...   actOverheatingAssistance          true
    ...   timerOverheatIndProhibit          1s
    ...   timerPostOverheating              0
    ...   caBackoffTimerUeOh                60
    ...   actBufferBasedSCellAddition       oneShot_Dl_Fr1
    ...   actSCellReleaseForInactiveSCell   timer_based_Fr1
          Set Element    dist_name=${dist_name}     p_name=${p_name}               value=${value}
    END
    FOR   ${cell_index}   IN   1  2  3  4  5  6
        Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     p_name=sCellInactivityReleaseTimer             value=10
    END
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Apply Configs for A_EI_B201-2
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    FOR   ${dist_name}                              IN
    ...   MRBTS-1/NRBTS-1/NRCELL-2
    ...   MRBTS-1/NRBTS-1/NRCELL-3
    ...   MRBTS-1/NRBTS-1/NRCELL-6
          Set Element    dist_name=${dist_name}     p_name=maxNumOfSCellAlloc      value=0
    END
    Set Element             dist_name=MRBTS-1/NRBTS-1     p_name=sCellActivationMethod             value=bufferBased
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Apply Configs for A_EI_B201-3
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    FOR   ${dist_name}                              IN
    ...   MRBTS-1/NRBTS-1/NRCELL-2
    ...   MRBTS-1/NRBTS-1/NRCELL-3
    ...   MRBTS-1/NRBTS-1/NRCELL-6
          Set Element    dist_name=${dist_name}     p_name=maxNumOfSCellAlloc      value=0
    END
    Set Element             dist_name=MRBTS-1/NRBTS-1     p_name=sCellActivationMethod             value=bufferBased
    #Activating high reliability DRB functionality in Cell-1 (PCell) and Cell-4 (SCell-1): User Scenario ‘CB008246-K#6 : Successful DL SCell Release
    #procedure in SA PCELL due to High Reliability reasons’ is Enabled
    FOR   ${dist_name}                              ${p_name}                      ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  actLAForHiReliab               true
    ...   MRBTS-1/NRBTS-1/NRCELL-4                  actLAForHiReliab               true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  dlMcsDowngradeForHr            disabled
    ...   MRBTS-1/NRBTS-1/NRCELL-4                  dlMcsDowngradeForHr            disabled
    ...   MRBTS-1/NRBTS-1/NRCELL-1                  ulMcsDowngradeForHr            disabled
    ...   MRBTS-1/NRBTS-1/NRCELL-4                  ulMcsDowngradeForHr            disabled
          Set Element    dist_name=${dist_name}     p_name=${p_name}               value=${value}
    END
    ${dist_name}=               Set Variable                              MRBTS-1/NRBTS-1/NRCELL-4
    Set New List                dist_name=${dist_name}                    list_name=dlDataDmrsFdm
    ${list_elements}            Create dictionary                         actDlDataDmrsFdm                        false
    ...                                                                   dlDataDmrsFdmThres256QamMcs             20
    ...                                                                   dlDataDmrsFdmThres64QamMcs              20
    ...                                                                   redCap1RxUesEnabled	                  false
    ...                                                                   thres256QamMcsRedCap1Rx                 20
    scf.add_item_to_list        dist_name=${dist_name}                    list_name=dlDataDmrsFdm                elements=${list_elements}
    #User Scenario ‘CB008246-K#1: High reliability feature interworking with Carrier Aggregation in DL for SA UE’ is Enabled:
    FOR   ${dist_name}                              ${p_name}                      ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRDRB-12                  nrPdschHRLaDN                  MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
    ...   MRBTS-1/NRBTS-1/NRDRB-14                  nrPdschHRLaDN                  MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
    ...   MRBTS-1/NRBTS-1/NRDRB-12                  nrPuschHRLaDN                  MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
    ...   MRBTS-1/NRBTS-1/NRDRB-14                  nrPuschHRLaDN                  MRBTS-1/NRBTS-1/NRPUSCHHRLA-2
          Set Element    dist_name=${dist_name}     p_name=${p_name}               value=${value}
    END
    Add NRPDSCHHRLA    id=1
    Add NRPDSCHHRLA    id=2
    Add NRPUSCHHRLA    id=1
    Add NRPUSCHHRLA    id=2
    #Relation parameters
    FOR   ${dist_name}                              IN
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-31/PDCCH-1
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-73/PDCCH-1
          Set Element    dist_name=${dist_name}     p_name=dciDedicatedAggregationLevelHR      value=AL4
    END
    FOR   ${cell_index}   IN   1  4
        Set New List            dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     list_name=pdschHrLaConfig
        ${list_elements}=       Create dictionary                                  dllaCqiOffsetHR                          0
        ...                                                                        dllaDeltaCqiMaxHR                        150
        ...                                                                        dllaDeltaCqiMinHR                        -150
        ...                                                                        dllaDeltaCqiStepdownHR                   500
        ...                                                                        dllaIniDeltaCqiHR                        -30
        ...                                                                        dllaIniMcsHR                             3
        ...                                                                        dllaMcsMax64qamLowSERANK1HR              28
        ...                                                                        dllaMcsMax64qamLowSERANK2HR              28
        ...                                                                        dllaMcsMax64qamLowSERANK3HR              28
        ...                                                                        dllaMcsMax64qamLowSERANK4HR              28
        ...                                                                        dllaMcsMax64qamRANK1HR                   28
        ...                                                                        dllaMcsMax64qamRANK2HR                   28
        ...                                                                        dllaMcsMax64qamRANK3HR                   28
        ...                                                                        dllaMcsMax64qamRANK4HR                   28
        scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     list_name=pdschHrLaConfig         elements=${list_elements}
    END
    FOR   ${cell_index}   IN   1  4
        Set New List            dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     list_name=puschHrLaConfig
        ${list_elements}=       Create dictionary                                  iniDeltaSinrHR                           -50
        ...                                                                        ullaDeltaSinrMaxHR                       150
        ...                                                                        ullaDeltaSinrMinHR                       -300
        ...                                                                        ullaDeltaSinrStepdownHR                  2000
        ...                                                                        ullaIniMcsHR                             0
        ...                                                                        ullaMcsMax64qamLowSERANK1HR              28
        ...                                                                        ullaMcsMax64qamLowSERANK2HR              28
        ...                                                                        ullaMcsMax64qamRANK1HR                   28
        ...                                                                        ullaMcsMax64qamRANK2HR                   28
        ...                                                                        ullaSinrOffsetHR                         0
        scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_index}     list_name=puschHrLaConfig         elements=${list_elements}
    END
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Add NRPDSCHHRLA
   [Arguments]   ${id}=1
   ${dist_name}  Set Variable            MRBTS-1/NRBTS-1/NRPDSCHHRLA-${id}
   Set Object    dist_name=${dist_name}  class_name=NRPDSCHHRLA   version=${NIDD_VERSION}

    FOR   ${p_name}                                 ${value}                       IN
    ...   dlHRBlerOutageMcsThresh64qam              1
    ...   dlHRBlerOutageMcsThresh64qamLowSE         2
    ...   dlHRBlerOutagePercentage                  50
    ...   dlHRBlerOutagePeriod                      10
    ...   dlHRBlerRecoverMcsThresh64qam             5
    ...   dlHRBlerRecoverMcsThresh64qamLowSE        11
    ...   dlHRBlerRecoverPercentage                 60
    ...   dlHRBlerRecoverPeriod                     20
    ...   dllaBlerTargetHR                          10
    ...   scalFactorForHRGbrDl                      140
          Set Element    dist_name=${dist_name}     p_name=${p_name}               value=${value}
    END

Add NRPUSCHHRLA
   [Arguments]   ${id}=1
   ${dist_name}  Set Variable            MRBTS-1/NRBTS-1/NRPUSCHHRLA-${id}
   Set Object    dist_name=${dist_name}  class_name=NRPUSCHHRLA   version=${NIDD_VERSION}

    FOR   ${p_name}                                 ${value}                       IN
    ...   scalFactorForHRGbrUl                      170
    ...   ulHRBlerOutagePercentage                  50
    ...   ulHRBlerOutagePeriod                      10
    ...   ulHRBlerOutageTbsThresh                   500
    ...   ulHRBlerOutageTbsThresh64qam              1000
    ...   ulHRBlerRecoverPercentage                 60
    ...   ulHRBlerRecoverPeriod                     20
    ...   ulHRBlerRecoverTbsThresh                  4000
    ...   ulHRBlerRecoverTbsThresh64qam             7000
    ...   ullaBlerTargetHR                          10
          Set Element    dist_name=${dist_name}     p_name=${p_name}               value=${value}
    END

Apply Configs for A_EI_B3_1
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-4     p_name=longPucchConfigType             value=nonCaPucchConfig
    FOR   ${dist_name}                              IN
    ...   MRBTS-1/NRBTS-1/NRCELL-1
    ...   MRBTS-1/NRBTS-1/NRCELL-2
    ...   MRBTS-1/NRBTS-1/NRCELL-5
          Set Element    dist_name=${dist_name}     p_name=maxNumOfSCellAlloc      value=0
    END
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Apply Configs for A_EI_B3_2
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    FOR   ${dist_name}                              IN
    ...   MRBTS-1/NRBTS-1/NRCELL-2
    ...   MRBTS-1/NRBTS-1/NRCELL-3
    ...   MRBTS-1/NRBTS-1/NRCELL-6
          Set Element    dist_name=${dist_name}     p_name=maxNumOfSCellAlloc      value=0
    END
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Apply Config for measurement-based Inter gNB CA  # B202: PCell:3, SCell:rel5
    [Arguments]   ${dist_name}=MRBTS-1/NRBTS-1/NRCELL-3
    ${scf_file}=          Load current SCF
    FOR   ${nr_rel}       IN  1  2  3  4  5
        Set Element       dist_name=${dist_name}/NRREL-${nr_rel}   p_name=sCellAdditionMethod          value=covBasedA1
    END
    Enable Measurement Based CA
    Set Element           dist_name=${dist_name}                   p_name=a1MeasSCellAddEnabled        value=rsrp

    Set New List          dist_name=${dist_name}                   list_name=a1MeasSCellAddSsbRsrp
    ${a1MeasRsrp_dict}    Create dictionary                        a1ThresholdSCellAddSsbRsrpFDD       50
    ...                                                            a1ThresholdSCellAddSsbRsrpTDD       60
    ...                                                            a1TimeToTriggerSCellAddSsbRsrp      80ms
    ...                                                            a1HysteresisSCellAddSsbRsrp         0
    scf.add_item_to_list  dist_name=${dist_name}                   list_name=a1MeasSCellAddSsbRsrp     elements=${a1MeasRsrp_dict}
    Remove Element        dist_name=${dist_name}/NRREL-6           p_name=sCellAdditionMethod          # disable SCell 2
    Remove Element        dist_name=${dist_name}/NRREL-6           p_name=sCellOperationalMode         # disable SCell 2
    Apply Delta SCF       ${scf_file}  scf_interGnbCA

Enable Measurement Based CA
    [Arguments]   ${ca_meas}=A1-based
    Set New List       dist_name=MRBTS-1/NRBTS-1    list_name=actMeasBasedSCellAdditionSa
    ${actMeasBasedSCellAdditionSa_list}=  create list   ${ca_meas}
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1   list_name=actMeasBasedSCellAdditionSa   elements=${actMeasBasedSCellAdditionSa_list}

Add NRPDCCHHRLA
    [Arguments]   ${id}=1
    ${dist_name}  Set Variable            MRBTS-1/NRBTS-1/NRPDCCHHRLA-${id}
    Set Object    dist_name=${dist_name}  class_name=NRPDCCHHRLA   version=${NIDD_VERSION}
    FOR   ${p_name}                                 ${value}                       IN
    ...   pdcchHRBlerOutagePercentage               50
    ...   pdcchHRBlerOutagePeriod                   10
    ...   pdcchHRBlerRecoverPercentage              60
          Set Element    dist_name=${dist_name}     p_name=${p_name}               value=${value}
    END


Apply Configs for B_B201
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    Add NRPUSCHHRLA     id=1
    Add NRPDSCHHRLA     id=1
    Add NRPDCCHHRLA     id=1
    Set Element             dist_name=MRBTS-1/NRBTS-1     p_name=sCellActivationMethod             value=bufferBased
    Set New List            dist_name=MRBTS-1/NRBTS-1/NRDU-1             list_name=carrierAggregationSupportList
    ${param_list}=                  Create List    ca_Fdd_Any_Sa   ca_Fr1Tdd_Any_Sa  ca_Fr1Tdd_Fdd_Sa  ca_Fr1Tdd_Sa   ca_Fdd_Fr1Tdd_Sa
    ...         ca_Fdd_Fdd   ca_Fdd_Fr1Tdd_Sa_WithUl  ca_Fr1Tdd_Fdd_Sa_WithUl  ca_Fdd_Fr1Tdd_Nsa   ca_Fdd_Fdd_Sa_WithUl   ca_Fr1Tdd_Nsa
     ...  ca_Fr1Tdd_Fr1Tdd_Sa_WithUl    ca_Fr1Tdd_Fdd_Nsa
    scf.add_elements_to_list        dist_name=MRBTS-1/NRBTS-1/NRDU-1      list_name=carrierAggregationSupportList   elements=${param_list}
    FOR   ${dist_name}                              IN
    ...   MRBTS-1/NRBTS-1/NRCELL-2
    ...   MRBTS-1/NRBTS-1/NRCELL-3
    ...   MRBTS-1/NRBTS-1/NRCELL-5
          Set Element    dist_name=${dist_name}     p_name=maxNumOfSCellAlloc      value=0
    END
    FOR   ${dist_name}                              ${p_name}                      ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-4                  actLAForHiReliab               true
    ...   MRBTS-1/NRBTS-1/NRCELL-4                  dlMcsDowngradeForHr            disabled
    ...   MRBTS-1/NRBTS-1/NRCELL-4                  ulMcsDowngradeForHr            disabled
          Set Element    dist_name=${dist_name}     p_name=${p_name}               value=${value}
    END
    Set Element                dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-31/PDCCH-1     p_name=dciDedicatedAggregationLevelHR     value=AL4
    Set Element                dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-33/PDCCH-1     p_name=dciDedicatedAggregationLevelHR     value=AL4
    Set Element                dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1      p_name=dciDedicatedAggregationLevelHR     value=AL4
    Set Element                dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1      p_name=dciDedicatedAggregationLevelHR     value=AL4
    Set Element               dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-71/PDCCH-1     p_name=dciDedicatedAggregationLevelHR      value=AL4
    Set Element               dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-73/PDCCH-1     p_name=dciDedicatedAggregationLevelHR      value=AL4
    FOR   ${dist_name}                              IN
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-31/PDCCH-1
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-33/PDCCH-1
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-4/PDCCH-1
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-71/PDCCH-1
    ...   MRBTS-1/NRBTS-1/BWP_PROFILE-73/PDCCH-1
          Set Element    dist_name=${dist_name}     p_name=alSelection      value=dynamic
    END
    FOR    ${BWP_index}    IN   4    31
      Set New List          dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-${BWP_index}/PDCCH-1          list_name=dynamicAggregationLevelHRSet
      ${param_list}=                  Create dictionary        aggregationLevelListHR            AL2_AL4_AL8
      ...                                                      cqiCorrectionUpHR                 1
      ...                                                      cqiDciCssAl16HR                   159
      ...                                                      cqiDciCssAl1HR                    159
      ...                                                      cqiDciCssAl2HR                    159
      ...                                                      cqiDciCssAl4HR                    159
      ...                                                      cqiDciCssAl8HR                    159
      ...                                                      highOlcCqiOffsetHR                1
      ...                                                      lowOlcCqiOffsetHR                 1
      ...                                                      pCqiErasureActTimerHR             0
      ...                                                      pCqiErasureReductionHR            0
      ...                                                      pdcchCqiOffsetHR                 10
      scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-${BWP_index}/PDCCH-1    list_name=dynamicAggregationLevelHRSet
      ...  elements=${param_list}
    END
    FOR    ${BWP_index}    IN   4  7  31  73  71  33
       Set New List          dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-${BWP_index}/PDCCH-1               list_name=dynamicAggregationLevelSet
       ${param_list}=                  Create dictionary        aggregationLevelList          AL2_AL4
       ...                                                      cqiCorrectionUp               10
       ...                                                      cqiDciCssAl1                 159
       ...                                                      cqiDciCssAl16                159
       ...                                                      cqiDciCssAl2                 159
       ...                                                      cqiDciCssAl4                 159
       ...                                                      cqiDciCssAl8                 159
       ...                                                      highOlcCqiOffset             1
       ...                                                      lowOlcCqiOffset              1
       ...                                                      pCqiErasureActTimer          0
       ...                                                      pCqiErasureReduction         0
       scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-${BWP_index}/PDCCH-1       list_name=dynamicAggregationLevelSet
       ...  elements=${param_list}
    END
    Set New List            dist_name=MRBTS-1/NRBTS-1/NRCELL-4     list_name=pdschHrLaConfig
    ${list_elements}=       Create dictionary                                  dllaCqiOffsetHR                          0
    ...                                                                        dllaDeltaCqiMaxHR                        150
    ...                                                                        dllaDeltaCqiMinHR                        -150
    ...                                                                        dllaDeltaCqiStepdownHR                   500
    ...                                                                        dllaIniDeltaCqiHR                        -30
    ...                                                                        dllaIniMcsHR                             3
    ...                                                                        dllaMcsMax64qamLowSERANK1HR              28
    ...                                                                        dllaMcsMax64qamLowSERANK2HR              28
    ...                                                                        dllaMcsMax64qamLowSERANK3HR              28
    ...                                                                        dllaMcsMax64qamLowSERANK4HR              28
    ...                                                                        dllaMcsMax64qamRANK1HR                   28
    ...                                                                        dllaMcsMax64qamRANK2HR                   28
    ...                                                                        dllaMcsMax64qamRANK3HR                   28
    ...                                                                        dllaMcsMax64qamRANK4HR                   28
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-4     list_name=pdschHrLaConfig         elements=${list_elements}
    Set New List            dist_name=MRBTS-1/NRBTS-1/NRCELL-4     list_name=puschHrLaConfig
    ${list_elements}=       Create dictionary                                  iniDeltaSinrHR                           -50
    ...                                                                        ullaDeltaSinrMaxHR                       150
    ...                                                                        ullaDeltaSinrMinHR                       -300
    ...                                                                        ullaDeltaSinrStepdownHR                  2000
    ...                                                                        ullaIniMcsHR                             0
    ...                                                                        ullaMcsMax64qamLowSERANK1HR              28
    ...                                                                        ullaMcsMax64qamLowSERANK2HR              28
    ...                                                                        ullaMcsMax64qamRANK1HR                   28
    ...                                                                        ullaMcsMax64qamRANK2HR                   28
    ...                                                                        ullaSinrOffsetHR                         0
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-4     list_name=puschHrLaConfig         elements=${list_elements}
    @{cellBwpList}=         Create List    [0, 4]  [1, 31]
    Set New List           dist_name=MRBTS-1/NRBTS-1/NRCELL-4     list_name=cellBwpList
    FOR    ${BWP_index}    IN   @{cellBwpList}
        ${bwp_list}=      Evaluate             list(${BWP_index})
        ${param_list}=                  create dictionary
        ...                                                actPdcchCceFragmentControl              false
        ...                                                actUpperThrAckNackFiltering             true
        ...                                                actUpperThrAckNackHrFiltering           true
        ...                                                bwpDN                                   MRBTS-1/NRBTS-1/BWP_PROFILE-${bwp_list}[1]
        ...                                               cellBwpId                                ${bwp_list}[0]
        ...                                               pdcchResourcePreference                  peakRate
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-4     list_name=cellBwpList   elements=${param_list}
    END
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRCELL-4               p_name=actDl256Qam                       value=false
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRCELL-4               p_name=actUl256Qam                       value=false
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRCELL-4               p_name=actCDrx                           value=false
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRDRB-3            p_name=nrPdschHRLaDN           value=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRDRB-3            p_name=nrPuschHRLaDN           value=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
    Set Element           dist_name=MRBTS-1/NRBTS-1/NRDRB-3           p_name=nrPdcchHRLaDN           value=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1
    ${dist_name}=               Set Variable                              MRBTS-1/NRBTS-1/NRCELL-4
    Set New List                dist_name=${dist_name}                    list_name=dlDataDmrsFdm
    ${list_elements}            Create dictionary                         actDlDataDmrsFdm                        true
    ...                                                                   dlDataDmrsFdmThres256QamMcs             20
    ...                                                                   dlDataDmrsFdmThres64QamMcs              20
    ...                                                                   redCap1RxUesEnabled	                  false
    ...                                                                   thres256QamMcsRedCap1Rx                 20
    ...                                                                   dlDataDmrsFdmThres64QamLowSEMcs         20
    scf.add_item_to_list        dist_name=${dist_name}                    list_name=dlDataDmrsFdm                elements=${list_elements}
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf
    gnb.Wait Until All gNBs To Be Onair State

Apply Configs for B_B301
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    FOR   ${cell_idx}   IN   1   2   3   5
        Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_idx}     p_name=maxNumOfSCellAlloc      value=0
    END
    Set New List            dist_name=MRBTS-1/NRBTS-1/NRDU-1             list_name=carrierAggregationSupportList
    ${param_list}=                  Create List    ca_Fdd_Any_Sa   ca_Fr1Tdd_Any_Sa  ca_Fr1Tdd_Fdd_Sa  ca_Fr1Tdd_Sa   ca_Fdd_Fr1Tdd_Sa
    ...         ca_Fdd_Fdd   ca_Fdd_Fr1Tdd_Sa_WithUl  ca_Fr1Tdd_Fdd_Sa_WithUl  ca_Fdd_Fr1Tdd_Nsa   ca_Fdd_Fdd_Sa_WithUl   ca_Fr1Tdd_Nsa
    ...     ca_Fr1Tdd_Fr1Tdd_Sa_WithUl    ca_Fr1Tdd_Fdd_Nsa
    scf.add_elements_to_list        dist_name=MRBTS-1/NRBTS-1/NRDU-1      list_name=carrierAggregationSupportList   elements=${param_list}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-4
    FOR    ${cell_index}    IN RANGE    1   5
        Set Element                 dist_name=${dist_name}/NRREL-${cell_index}           p_name=sCellAdditionMethod    value=covBasedA1
    END
    Set Element           dist_name=MRBTS-1/NRBTS-1    p_name=sCellActivationMethod             value=bufferBased
    Set Element        	dist_name=MRBTS-1/NRBTS-1      p_name=actBufferBasedSCellAddition        value=oneShot_Dl_Fr1
    FOR    ${cell_index}    IN RANGE    1   2
        Set Element                 dist_name=${dist_name}/NRREL-${cell_index}           p_name=sCellOperationalMode    value=dlAndUl
    END
    Enable Measurement Based CA
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-4
    Set Element    dist_name=${dist_name}     p_name=a1MeasSCellAddEnabled      value=rsrp
    Set New List                    dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp
    ${a1MeasRsrp_dict}              Create dictionary                    a1ThresholdSCellAddSsbRsrpFDD           50
    ...                                                                  a1ThresholdSCellAddSsbRsrpTDD           60
    ...                                                                  a1TimeToTriggerSCellAddSsbRsrp          320ms
    ...                                                                  a1HysteresisSCellAddSsbRsrp	         0
    scf.add_item_to_list            dist_name=${dist_name}               list_name=a1MeasSCellAddSsbRsrp         elements=${a1MeasRsrp_dict}
    Set Element             dist_name=MRBTS-1/NRBTS-1/NRCELL-1           p_name=a2MeasSCellRelEnabled            value=rsrp
    Set New List            dist_name=MRBTS-1/NRBTS-1/NRCELL-1           list_name=a2MeasSCellRelSsbRsrp
    ${list_elements}=       Create dictionary                            a2HysteresisSCellRelSsbRsrp             0
    ...                                                                  a2ThresholdSCellRelSsbRsrp              34
    ...                                                                  a2TimeToTriggerSCellRelSsbRsrp          2560ms
    scf.add_item_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-1           list_name=a2MeasSCellRelSsbRsrp         elements=${list_elements}
    Set Element             dist_name=MRBTS-1/NRBTS-1      p_name=actMeasBasedSCellAdditionNsa      value=true
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf
