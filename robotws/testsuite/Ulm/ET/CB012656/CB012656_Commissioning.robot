*** Settings ***

Documentation
...    author: VRF ULM T01 01
...    Team: 'MN RAN RD VRF ULM VT1'
...    Email: 'I_MN_RAN_RD_VRF_ULM_VT1@internal.nsn.com'
...    Description: Commissioning for CB012656 Test Scenarios

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource                    CB012656_Keywords.robot
Resource                    ../resources/SQD65/sqd65_commissioning.robot

*** Keywords ***

Common Commissioning for all Sub-Features
    [Documentation]  Initial full commisioning without activating 5GC000710, CB008696, CB012149, CB008225 and CB006597. However, added the required
    ...   parameters as part of full commisioning and FAF should be enabled when interworking with those features. Also, idleMMSteeringAlgo and
    ...   idleMMSteeringWRREnabledSec are set to 'UL CA aware' and this should be changed via delta commissioning depends on the user scenario.
    ${config_dir}=      Get test suite config directory
    scf.load_scf        ${P_ORIG_SCF}
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actUlCaAwareIMMSteering                 true             #'true' to enable feature
    ...   MRBTS-1/NRBTS-1                                   actIdleMMSteering                       true             #Legacy CB007516
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          idleMMSteeringAlgo                      UL CA aware
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          idleMMSteeringAlgo                      UL CA aware
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          idleMMSteeringPercentageOfUes           100
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          idleMMSteeringPercentageOfUes           100
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          idleMMSteeringWRREnabled                true
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          idleMMSteeringWRREnabled                true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          idleMMServCelResWeight                  70
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          idleMMSteeringWRREnabledSec             UL CA aware
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          idleMMSteeringWRREnabledSec             UL CA aware
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          ulCaAwareIMMServCelResWeight            100
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          t320                                    min180
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          idleMMEnDcSteeringWRREnabled            true
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          idleMMEnDcSteeringPercentageOfUes       100
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          a4ReportTimerEnDc                       6000
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          idleMMEnDcSteeringSsbFrequency          2079167
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    @{pcell_list}    Create List    531870   636576   431090   127450   518910   392410   655968   428410   368910   531850   159630   516990
    ${nrcaimp_moc_id}   Set Variable   1
    FOR  ${pcell}   IN  @{pcell_list}
        Add NRCAIMP MOC to NRBTS-1  id=${nrcaimp_moc_id}  nrarfcn=${pcell}
        @{scell_list}    Create List    127450    518910    531870    636576    431090    655968
        ${nrcaims_moc_id}   Set Variable   1
        FOR  ${scell}   IN  @{scell_list}
            Add NRCAIMS MOC to NRCAIMP  ${nrcaimp_moc_id}  ${nrcaims_moc_id}  ${scell}
            ${nrcaims_moc_id}=    Evaluate    ${nrcaims_moc_id}+1
        END
        ${nrcaimp_moc_id}=    Evaluate    ${nrcaimp_moc_id}+1
    END
    @{scell_targets} =  Create List  [1, 2, 392410]  [1, 3, 127450]  [1, 4, 368910, 431090]  [1, 5, 518910, 392410]  [1, 6, 392410, 127450, 431090]
    ...   [2, 1, 518910]  [2, 2, 531870]  [2, 3, 127450, 392410, 159630]  [2, 6, 127450, 518910, 531850, 431090]  [3, 2, 531870, 636576, 127450]
    ...   [3, 3, 431090]  [3, 4, 127450, 655968, 516990]  [3, 5, 159630, 518910, 392410]  [5, 2, 516990, 636576, 127450]  [5, 3, 431090]
    ...   [5, 4, 127450, 655968, 428410]  [5, 5, 318910, 531850, 392410]  [5, 6, 531870, 636576, 127450]  [6, 3, 431090]
    ...   [6, 4, 127450, 655968, 531870]  [6, 5, 127450, 518910, 392410]  [7, 2, 531870, 636576, 127450]  [8, 1, 431090]
    ...   [8, 2, 127450, 655968, 431090]  [8, 3, 431090, 368910, 392410]  [9, 4, 431090]  [8, 4, 531870, 636576, 127450]  [8, 5, 127450]
    ...   [8, 6, 127450, 159630, 516990]  [9, 1, 392410]  [9, 2, 431090]  [9, 3, 127450]  [9, 5, 127450]  [9, 6, 159630]
    ...   [10, 1, 431090, 518910, 392410]  [10, 3, 431090]  [10, 4, 127450, 655968, 428410]  [11, 1, 531870, 636576]  [11, 2, 431090, 127450]
    ...   [11, 3, 127450, 655968]  [11, 4, 428410, 368910, 531850]  [11, 5, 127450, 392410]  [11, 6, 516990, 518910]

    FOR  ${target}  IN  @{scell_targets}
        ${target_list}=    Evaluate    list(${target})
        ${imp_id}=    Set Variable    ${target_list}[0]
        ${ims_id}=    Set Variable    ${target_list}[1]
        @{nrarfcn_list}=    Create List    @{target_list}[2:]
        Add More Scell Targets in NRCAIMS MOC  ${imp_id}  ${ims_id}  @{nrarfcn_list}
    END
    Modify Existing Parameters in MOCs Under NRSYSINFO_PROFILE
    Apply Configuration for RRC Inactve State Transition Feature CB008225 and CB006597
    Apply Configuration for UL Tx Switching Feature CB012149
    Apply Configuration for ENDC Steering CB008696
    Apply Configuration for Mobility Profile 5GC000710
    Add NRIRFIM MOC to NRSYSINFO_PROFILE  id=2  prio=5  sub_prio=oDot4  freq=531870  band=41  weight=75  scs=30 KHz
    Add NRIRFIM MOC to NRSYSINFO_PROFILE  id=3  prio=6  sub_prio=oDot2  freq=127450  band=71  weight=15  scs=15KHz  ca_weight=30
    Add NRIRFIM MOC to NRSYSINFO_PROFILE  id=4  prio=1  sub_prio=oDot6  freq=655968  band=77  weight=1  scs=30 KHz  ca_weight=45
    Add NRIRFIM MOC to NRSYSINFO_PROFILE  id=5  prio=7  sub_prio=oDot2  freq=368910  band=3  scs=15KHz  ca_weight=70
    Add NRIRFIM MOC to NRSYSINFO_PROFILE  id=6  prio=2  freq=516990  band=38  weight=55  scs=30 KHz  ca_weight=2
    Add NRIRFIM MOC to NRSYSINFO_PROFILE  id=7  prio=4  freq=392410  band=25  weight=100  scs=15KHz  ca_weight=100
    Add NRIRFIM MOC to NRSYSINFO_PROFILE  id=8  prio=4  sub_prio=oDot8  freq=636576  band=78  scs=30 KHz  ca_weight=80
    Add NRLIM MOC to NRSYSINFO_PROFILE  id=2  freq=2175  resel_prio=6  sub_prio=oDot4  cell_weight=45  endc_weight=76
    Add NRLIM MOC to NRSYSINFO_PROFILE  id=3  freq=3100  resel_prio=6  endc_weight=10
    Add NRLIM MOC to NRSYSINFO_PROFILE  id=4  freq=1575  sub_prio=oDot4  cell_weight=100  endc_weight=10
    Add NRLIM MOC to NRSYSINFO_PROFILE  id=5  freq=7000  resel_prio=3  sub_prio=oDot2  cell_weight=15  endc_weight=100
    Add NRLIM MOC to NRSYSINFO_PROFILE  id=6  freq=900  cell_weight=100  endc_weight=25
    Add NRLIM MOC to NRSYSINFO_PROFILE  id=7  freq=66886  resel_prio=3  cell_weight=70
    Add NRLIM MOC to NRSYSINFO_PROFILE  id=8  freq=3625  resel_prio=3  sub_prio=oDot8  cell_weight=5  endc_weight=70
    Apply Configuration for Multi Plmn and Slicing
    Perform Additional Configuration to Match Cutomer Specific Config
    Enable from Simulated to Real Inter GNB Handover Configuration
    scf.save_scf                    ${config_dir}/CB012656_SCF.xml
    Execute full commissioning      ${config_dir}/CB012656_SCF.xml

Apply Configuration for RRC Inactve State Transition Feature CB008225 and CB006597
    [Documentation]  User Scenario CB008225-B#B2: Successful transition of UE in RRC_CONNECTED state to RRC_INACTIVE state (Suspend) - UE Assistance
    ...   information based and CB006597 UE Power Saving: UE Assistance Information for UE preferred RRC state
    [Arguments]
    FOR   ${dist_name}                                  ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                               actRrcInactState                        none        #'intra-gNB' to enable this feature
    ...   MRBTS-1/NRBTS-1                               drbRrcInactInactivityTimerSA            5
    ...   MRBTS-1/NRBTS-1                               maxUeRrcInactTime                       60
    ...   MRBTS-1/NRBTS-1                               rrcInactIMMSteeringEnabled              true
    ...   MRBTS-1/NRBTS-1                               rrcInactLocationReportEnabled           true
    ...   MRBTS-1/NRBTS-1                               actLocationReportingSA                  true
    ...   MRBTS-1/NRBTS-1                               rrcInactPreferredStateEnabled           true
    ...   MRBTS-1/NRBTS-1                               actRrcReleasePreference                 true
    ...   MRBTS-1/NRBTS-1                               outOfConnectedPreference                idle        #"inactive" to enable this feature
    ...   MRBTS-1/NRBTS-1                               timerReleasePreferenceProhibit          s4
    ...   MRBTS-1/NRBTS-1                               tRanPagingGuard                         4
    ...   MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-1       ranAC                                   0
    ...   MRBTS-1/NRBTS-1                               t380                                    30min
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

Apply Configuration for ENDC Steering CB008696
    [Documentation]  User Scenario CB008696-A#B1: Idle mode Traffic Steering from NR SA to LTE EN-DC carrier without mobility profiles.
    [Arguments]
    FOR   ${dist_name}                                  ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                               actIdlMMEnDcSteering                    false       #'true' to enable feature
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      idleMMEnDcSteeringSsbFrequency          2079167
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      idleMMEnDcSteeringWRREnabled            true
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      idleMMEnDcSteeringPercentageOfUes       100
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      t320EnDc                                min5
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      a4ReportTimerEnDc                       6000
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1   idleMMEutraCelResWeightEnDc             100
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Add NRHOIF MOC to NRCELL  id=1

Apply Configuration for UL Tx Switching Feature CB012149
    [Documentation]  Configuration for the successful operation of the TDD FR1 + FDD UL TX switching (Option 1) feature activation. Once feature is
    ...   activated and carrier aggregation relations are defined, already connected UEs will remain configured without R16 UL TX switching. New UEs
    ...   connecting to the TDD PCell (either as new connection or as incoming HO) and supporting R16 UL TX switching capability within gNB
    ...   configured bands will be configured with R16 UL TX switching with FDD cell as DL and UL SCell. Additionally, maximum another 3 DL only
    ...   SCells can be configured.
    [Arguments]
    Set New List                dist_name=MRBTS-1/NRBTS-1/NRDU-1        list_name=ulTxSwitchingSupportList
    ${ulTxSwitch_list}=         Create List                             none                            #'ca_Fr1T_F_Sa_switchedUl' to enable feature
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1/NRDU-1        list_name=ulTxSwitchingSupportList          elements=${ulTxSwitch_list}
    Set New List                dist_name=MRBTS-1/NRBTS-1/NRDU-1        list_name=carrierAggregationSupportList
    ${ca_support_list}=         Create List                             ca_Fr1Tdd_Fdd_Sa
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1/NRDU-1        list_name=carrierAggregationSupportList     elements=${ca_support_list}
    ${ca_support_list}=         Create List                             ca_Fr1Tdd_Any_Sa
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1/NRDU-1        list_name=carrierAggregationSupportList     elements=${ca_support_list}
    ${ca_support_list}=         Create List                             ca_Fr1Tdd_Sa
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1/NRDU-1        list_name=carrierAggregationSupportList     elements=${ca_support_list}
    ${ca_support_list}=         Create List                             ca_Fr1Tdd_Fdd_Sa_WithUl
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1/NRDU-1        list_name=carrierAggregationSupportList     elements=${ca_support_list}
    Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-1      list_name=allowUnsuppBcOrBcs
    ${allowUnsuppBcOrBcs}=      Create List                             accept unknown band combinations
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-1      list_name=allowUnsuppBcOrBcs                elements=${allowUnsuppBcOrBcs}
    Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-2      list_name=allowUnsuppBcOrBcs
    ${allowUnsuppBcOrBcs}=      Create List                             accept unknown band combinations
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1/NRCELL-2      list_name=allowUnsuppBcOrBcs                elements=${allowUnsuppBcOrBcs}
    FOR   ${dist_name}                                  ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRDU-1                        actInterNumerologyCa                    true
    ...   MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1                ulTReassemblyIBCA                       40
    ...   MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2                ulTReassemblyIBCA                       40
    ...   MRBTS-1/NRBTS-1                               sCellActivationMethod                   blind
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      sCellDeactivationTimerGNB               infinity
    ...   MRBTS-1/NRBTS-1/NRCELL-2                      sCellDeactivationTimerGNB               infinity
    ...   MRBTS-1/NRBTS-1/NRDU-1                        dlToUlContributionRatio                 50
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      maxNumScellsDlFr1                       4
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      actCDrx                                 true
    ...   MRBTS-1/NRBTS-1/NRCELL-2                      actCDrx                                 true
    ...   MRBTS-1/NRBTS-1/NRDU-1                        flexibleCAMode                          NumberCellAmount
    ...   MRBTS-1/NRBTS-1/NRDU-1                        actConnectedModeMobilityCA              true
    ...   MRBTS-1/NRBTS-1                               actSlowPrbPooling                       true
    ...   MRBTS-1/NRBTS-1                               actScheUePooling                        true
    ...   MRBTS-1/NRBTS-1                               actConnRrcPooling                       true
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

Add NRCAIMP MOC to NRBTS-1
    [Arguments]    ${id}   ${nrarfcn}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCAIMP-${id}
    Set Object    class_name=NRCAIMP    dist_name=${dist_name}   version=${NIDD_VERSION}
    Set New List                    dist_name=${dist_name}          list_name=pCellConfig
    ${pCellConfig_dict}             Create dictionary               nrarfcnDl                           ${nrarfcn}
    scf.add_item_to_list            dist_name=${dist_name}          list_name=pCellConfig               elements=${pCellConfig_dict}

Add NRCAIMS MOC to NRCAIMP
    [Arguments]    ${imp_id}   ${ims_id}   @{nrarfcn_list}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCAIMP-${imp_id}/NRCAIMS-${ims_id}
    Set Object    class_name=NRCAIMS    dist_name=${dist_name}   version=${NIDD_VERSION}
    Set New List                    dist_name=${dist_name}          list_name=sCellConfig
    FOR   ${nrarfcn}    IN    @{nrarfcn_list}
        ${sCellConfig_dict}             Create dictionary               nrarfcnDl                           ${nrarfcn}
        scf.add_item_to_list            dist_name=${dist_name}          list_name=sCellConfig               elements=${sCellConfig_dict}
    END

Add More Scell Targets in NRCAIMS MOC
    [Arguments]    ${imp_id}   ${ims_id}   @{nrarfcn_list}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCAIMP-${imp_id}/NRCAIMS-${ims_id}
    FOR   ${nrarfcn}    IN    @{nrarfcn_list}
        ${sCellConfig_dict}             Create dictionary               nrarfcnDl                           ${nrarfcn}
        scf.add_item_to_list            dist_name=${dist_name}          list_name=sCellConfig               elements=${sCellConfig_dict}
    END

Modify Existing Parameters in MOCs Under NRSYSINFO_PROFILE
    [Documentation]  This keyword is used to change the priority and sub priority of different NRARFCNs and LTE ARFCNs.
    [Arguments]
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1     cellReselectionPriority                 6
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1     cellReselectionSubPriority              oDot6
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1     dlCarrierFreq                           518910
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1     freqBandIndicatorNR                     41
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1     ulCaIdleMMNrCelResWeight                97
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1       carrierFreq                             300
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1       cellReselectionPriority                 2
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1       cellReselectionSubPriority              oDot4
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1       idleMMEutraCelResWeight                 100
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1       idleMMEutraCelResWeightEnDc             100
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

Apply Configuration for Mobility Profile 5GC000710
    [Arguments]
    FOR   ${dist_name}                      ${p_name}                       ${value}                   IN
    ...   MRBTS-1/NRBTS-1                   actMobilityProfile              false      #Enable "true"
    ...   MRBTS-1/NRBTS-1                   actRfspIndex                    true
    ...   MRBTS-1/NRBTS-1/NRCELL-1          nrDefMoPrNsaDN                  MRBTS-1/NRBTS-1/NRMOPR_NSA-1
    ...   MRBTS-1/NRBTS-1/NRCELL-1          nrDefMoPrSaDN                   MRBTS-1/NRBTS-1/NRMOPR_SA-8
    ...   MRBTS-1/NRBTS-1/NRCELL-2          nrDefMoPrNsaDN                  MRBTS-1/NRBTS-1/NRMOPR_NSA-1
    ...   MRBTS-1/NRBTS-1/NRCELL-2          nrDefMoPrSaDN                   MRBTS-1/NRBTS-1/NRMOPR_SA-4
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Add Mobility Profile Mapping for SA to NRBTS  id=4  prio=18  sa_dn=6  slice=3  plmn=1  rfsp=40  rfspLast=50
    Add Mobility Profile Mapping for SA to NRBTS  id=8  prio=3  sa_dn=3  slice=2  plmn=2  rfsp=20  rfspLast=30
    Add Mobility Profile Mapping for SA to NRBTS  id=10  prio=15  sa_dn=5  slice=2  plmn=2  rfsp=10
    Add Mobility Profile Mapping for SA to NRBTS  id=11  prio=96  sa_dn=4  slice=3  plmn=2  rfsp=55  rfspLast=85
    Add Mobility Profile Mapping for SA to NRBTS  id=24  prio=7  sa_dn=2  slice=1  plmn=1
    Add Mobility Profile Mapping for SA to NRBTS  id=25  prio=68  sa_dn=7  slice=2  plmn=1  rfsp=100
    Add Mobility Profile Mapping for NSA to NRBTS  id=1
    FOR  ${mopr_id}   IN RANGE  1  9
        Add New Radio Mobility Profile for SA  id=${mopr_id}
    END
    Add New Radio Mobility Profile for NSA  id=1
    Add Network Slicing to NRBTS  id=2  sd=13714342  nrPlmnDNList=1
    Add Network Slicing to NRBTS  id=3  sd=13714343  nrPlmnDNList=1
    Add New Radio PLMN to NRBTS  id=2
    Add NRMOIMP_SA MOC to Mobility Profile  endc_steer=true  idle_steer_algo=UL CA aware  steer_wrr_enable=true  steer_wrr_sec_enable=UL CA aware

Add Mobility Profile Mapping for SA to NRBTS
    [Arguments]    ${id}   ${prio}   ${sa_dn}   ${slice}   ${plmn}   ${rfsp}=${EMPTY}   ${rfspLast}=${EMPTY}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPRMA_SA-${id}
    Set Object    class_name=NRMOPRMA_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                             ${value}      IN
    ...   mobilityProfilePriority               ${prio}
    ...   nrMoPrSaDN                            MRBTS-1/NRBTS-1/NRMOPR_SA-${sa_dn}
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}      list_name=snssaiList
    ${snssaiList_dict}              Create dictionary           snssaiDN                            MRBTS-1/NRBTS-1/SNSSAI-${slice}
    scf.add_item_to_list            dist_name=${dist_name}      list_name=snssaiList                elements=${snssaiList_dict}
    Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-${plmn}
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}
    IF    '${rfsp}'!='${EMPTY}'
    ...   sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=rfspIndex         value=${rfsp}
    IF    '${rfspLast}'!='${EMPTY}'
    ...   sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=rfspIndexLast     value=${rfspLast}

Add Mobility Profile Mapping for NSA to NRBTS
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPRMA_NSA-${id}
    Set Object    class_name=NRMOPRMA_NSA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                             ${value}      IN
    ...   mobilityProfilePriority               9
    ...   nrMoPrNsaDN                           MRBTS-1/NRBTS-1/NRMOPR_NSA-1
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-1
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}

Add New Radio Mobility Profile for SA
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPR_SA-${id}
    Set Object    class_name=NRMOPR_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                             ${value}      IN
    ...   a1MeashoEnabledSA                     rsrp
    ...   a2MeashoEnabledSA                     rsrpCombined
    ...   a3MeasEnabled                         rsrq
    ...   a5MeasEnabled                         rsrqCombined
    ...   a2MeasRedirectEnabled                 none
    ...   emergencyCallFails                    disabled
    ...   emergencyFBMode                       disabled
    ...   voiceFBMode                           disabled
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add New Radio Mobility Profile for NSA
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPR_NSA-${id}
    Set Object    class_name=NRMOPR_NSA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                             ${value}      IN
    ...   a1MeashoEnabled                       none
    ...   a2MeashoEnabled                       none
    ...   a3MeasEnabled                         none
    ...   a5MeasEnabled                         none
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add Network Slicing to NRBTS
    [Arguments]    ${id}   ${sd}   ${nrPlmnDNList}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/SNSSAI-${id}
    Set Object    class_name=SNSSAI    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                             ${value}      IN
    ...   administrativeState                   Unlocked
    ...   sd                                    ${sd}
    ...   sst                                   1
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-${nrPlmnDNList}
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}
    ${snssaiList_dict}              Create dictionary           snssaiDN                            MRBTS-1/NRBTS-1/SNSSAI-${id}
    scf.add_item_to_list            dist_name=MRBTS-1/NRBTS-1/TRACKINGAREA-200      list_name=snssaiList        elements=${snssaiList_dict}

Add New Radio PLMN to NRBTS
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRPLMN-${id}
    Set Object    class_name=NRPLMN    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}             ${value}      IN
    ...   mcc                   311
    ...   mnc                   488
    ...   mncLength             3
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END

Add NRMOIMP_SA MOC to Mobility Profile
    [Arguments]    ${endc_steer}   ${idle_steer_algo}   ${steer_wrr_enable}   ${steer_wrr_sec_enable}
    FOR  ${mo_pr_id}   IN RANGE  1  9
        ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPR_SA-${mo_pr_id}/NRMOIMP_SA-1
        Set Object    class_name=NRMOIMP_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
        FOR   ${p_name}                             ${value}      IN
        ...   idleMMEnDcSteeringPercentageOfUes     100
        ...   idleMMEnDcSteeringWRREnabled          ${endc_steer}
        ...   idleMMSteeringAlgo                    ${idle_steer_algo}
        ...   idleMMSteeringPercentageOfUes         100
        ...   idleMMSteeringWRREnabled              ${steer_wrr_enable}
        ...   idleMMSteeringWRREnabledSec           ${steer_wrr_sec_enable}
        sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
        END
        IF    ${mo_pr_id} in [1, 2, 3, 4, 7, 8]
        ...   Add EUTRA carrier list for idle mode mobility ENDC steering  mo_pr_id=${mo_pr_id}
        Set New List                    dist_name=${dist_name}          list_name=dlCarFreqNrList
    END
    @{freq_targets} =  Create List  [1, 431090, 40, 70]  [1, 127450, 15, 30]  [1, 518910, 10, 10]  [1, 392410, 70, 20]  [1, 655968, 100, 100]
    ...   [1, 428410, 1, 99]  [1, 643296, 17, 47]  [1, 531870, 55, 100]  [2, 518910, 99, 1]  [2, 655968, 87, ${None}]  [2, 643296, 14, 66]
    ...   [2, 2079167, 18, 17]  [2, 2056987, 79, 97]  [2, 516990, ${None}, ${None}]  [2, 516990, ${None}, 64]  [2, 392410, 66, 34]
    ...   [3, 431090, ${None}, 74]  [3, 518910, 36, 36]  [3, 127450, 58, ${None}]  [3, 392410, 75, 86]  [3, 428410, 2, 89]  [3, 531870, 76, ${None}]
    ...   [3, 516990, 14, ${None}]  [4, 392410, ${None}, 81]  [4, 127450, 90, 78]  [4, 655968, ${None}, 63]  [4, 428410, 30, 70]
    ...   [4, 643296, 100, 100]  [4, 531850, 12, ${None}]  [4, 153630, 26, 78]  [5, 127450, 46, ${None}]  [5, 127450, ${None}, 24]
    ...   [5, 518910, 18, 19]  [5, 531850, 24, 76]  [5, 531870, 38, ${None}]  [5, 518990, 81, 19]  [5, 655968, ${None}, ${None}]
    ...   [5, 428410, ${None}, 29]  [6, 392410, 37, 96]  [6, 516990, 100, ${None}]  [6, 516990, 47, ${None}]  [6, 531870, 5, 70]  [6, 428410, 18, 98]
    ...   [6, 2056987, ${None}, 49]  [6, 655968, 56, ${None}]  [6, 127450, 74, 83]  [7, 516990, 18, ${None}]  [7, 428410, ${None}, 80]
    ...   [7, 392410, 34, 86]  [7, 127450, ${None}, ${None}]  [7, 531870, 87, 86]  [7, 2056987, 85, 86]  [7, 431090, 90, 2]  [7, 655968, 3, 89]
    ...   [8, 127450, ${None}, 86]  [8, 392410, 19, ${None}]  [8, 516990, 87, ${None}]  [8, 655968, ${None}, 86]  [8, 531870, 90, ${None}]
    ...   [8, 431090, ${None}, 89]

    FOR  ${frequncy}  IN  @{freq_targets}
        ${target_list}=     Evaluate    list(${frequncy})
        ${mo_prof_id}=        Set Variable    ${target_list}[0]
        ${CarFreqNr}=          Set Variable    ${target_list}[1]
        ${CelReselWeight}=    Set Variable If    isinstance(${target_list}[2], int)    ${target_list}[2]    ${EMPTY}
        ${ulCacelReselWeight}=    Set Variable If    isinstance(${target_list}[3], int)    ${target_list}[3]    ${EMPTY}
        Add Additional DL Carrier Frequency NR List in NRMOIMP_SA  mo_pr_id=${mo_prof_id}  FreqNr=${CarFreqNr}  CelResWeight=${CelReselWeight}
        ...   ulCaWeight=${ulCacelReselWeight}
    END

Add EUTRA carrier list for idle mode mobility ENDC steering
    [Arguments]   ${mo_pr_id}
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-${mo_pr_id}/NRMOIMP_SA-1    p_name=idleMMEnDcSteeringSsbFrequency
    ...    value=2079167
    Set New List        dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-${mo_pr_id}/NRMOIMP_SA-1      list_name=dlCarFreqEutraList
    @{freq_targets} =  Create List  [300, 40, 70]  [2175, 15, 30]  [3100, 10, 10]  [1575, 70, 20]  [7000, 100, 100]  [900, 1, 99]  [66886, 17, 47]
    ...   [3625, 55, 100]
    FOR  ${frequncy}  IN  @{freq_targets}
        ${target_list}=     Evaluate    list(${frequncy})
        ${CarFreqEutra}=            Set Variable    ${target_list}[0]
        ${Eutra_CelReselWeight}=    Set Variable If    isinstance(${target_list}[1], int)    ${target_list}[1]    ${EMPTY}
        ${Endc_celReselWeight}=     Set Variable If    isinstance(${target_list}[2], int)    ${target_list}[2]    ${EMPTY}
        Add Additional DL Carrier Frequency EUTRA List in NRMOIMP_SA  mo_pr_id=${mo_pr_id}  FreqEutra=${CarFreqEutra}
        ...   EutraWeight=${Eutra_CelReselWeight}  EndcWeight=${Endc_celReselWeight}
    END

Add Additional DL Carrier Frequency EUTRA List in NRMOIMP_SA
    [Arguments]    ${mo_pr_id}   ${FreqEutra}   ${EutraWeight}   ${EndcWeight}
    ${dist_name}=    Set Variable       MRBTS-1/NRBTS-1/NRMOPR_SA-${mo_pr_id}/NRMOIMP_SA-1
    ${dlCarFreqEutraList_items}         Create dictionary               dlCarFreqEutra                      ${FreqEutra}
    IF    '${EutraWeight}'!=''
    ...   Set to dictionary             ${dlCarFreqEutraList_items}     idleMMEutraCelResWeight             ${EutraWeight}
    IF    '${EndcWeight}'!=''
    ...   Set to dictionary             ${dlCarFreqEutraList_items}     idleMMEutraCelResWeightEnDc         ${EndcWeight}
    scf.add_item_to_list                dist_name=${dist_name}          list_name=dlCarFreqEutraList        elements=${dlCarFreqEutraList_items}

Add Additional DL Carrier Frequency NR List in NRMOIMP_SA
    [Arguments]    ${mo_pr_id}   ${FreqNr}   ${CelResWeight}   ${ulCaWeight}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRMOPR_SA-${mo_pr_id}/NRMOIMP_SA-1
    ${dlCarFreqNrList_items}        Create dictionary               dlCarFreqNr                         ${FreqNr}
    IF    '${CelResWeight}'!=''
    ...   Set to dictionary         ${dlCarFreqNrList_items}        idleMMNrCelResWeight                ${CelResWeight}
    IF    '${ulCaWeight}'!=''
    ...   Set to dictionary         ${dlCarFreqNrList_items}        ulCaIdleMMNrCelResWeight            ${ulCaWeight}
    scf.add_item_to_list            dist_name=${dist_name}          list_name=dlCarFreqNrList           elements=${dlCarFreqNrList_items}

Add NRHOIF MOC to NRCELL
    [Arguments]    ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-${id}
    Set Object    class_name=NRHOIF    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                            ${value}      IN
    ...   a1BasedPCellSwitchEnabled            false
    ...   a2BasedPCellSwitchEnabled            false
    ...   a3MeasEnabled                        none
    ...   a4MeasEnDcSteeringEnabled            rsrpCombined
    ...   a4MeasHigherPrioFreqEnabled          none
    ...   a4MeasNrDcEnabled                    none
    ...   a4MeasSCellAddEnabled                none
    ...   a5MeasEnabled                        none
    ...   cellDepType                          NSA
    ...   deriveSsbIndexFromCell               true
    ...   freqBandIndicatorNR                  257
    ...   ifhoSsbScs                           120 KHz
    ...   ifhoSsbSmtcDuration                  sf4
    ...   ifhoSsbSmtcPeriodicity               sf5
    ...   numberOfTransmittedSsBlocks          1 beam
    ...   ssbFrequency                         2079167
    ...   ssBurstSetPeriod                     20
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}          list_name=a4MeasEnDcSteeringSsbRsrp
    ${a4MeasEnDcSteer_rsrp}         Create dictionary               a4HysteresisEnDcSteeringSsbRsrp             0
    ...                                                             a4ThresholdEnDcSteeringSsbRsrp              34
    ...                                                             a4TimeToTriggerEnDcSteeringSsbRsrp          ms40
    scf.add_item_to_list            dist_name=${dist_name}          list_name=a4MeasEnDcSteeringSsbRsrp         elements=${a4MeasEnDcSteer_rsrp}
    Set New List                    dist_name=${dist_name}          list_name=a4MeasEnDcSteeringSsbRsrq
    ${a4MeasEnDcSteer_rsrq}         Create dictionary               a4HysteresisEnDcSteeringSsbRsrq             0
    ...                                                             a4ThresholdEnDcSteeringSsbRsrq              34
    ...                                                             a4TimeToTriggerEnDcSteeringSsbRsrq          ms40
    scf.add_item_to_list            dist_name=${dist_name}          list_name=a4MeasEnDcSteeringSsbRsrq         elements=${a4MeasEnDcSteer_rsrq}
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    p_name=measGapSelectionSA   value=favourUeThroughput

Perform Additional Configuration to Match Cutomer Specific Config
    [Arguments]
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actInterFreqHoSA                        true
    ...   MRBTS-1/NRBTS-1                                   actIntraFreqHoSA                        true
    ...   MRBTS-1/NRBTS-1                                   timerXnDataFwdGuard                     250
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          a1MeashoEnabledSA                       rsrpCombined
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          a2MeashoEnabledSA                       rsrp
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          a3MeasEnabled                           rsrpAndRsrq
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          a5MeasEnabled                           rsrqCombined
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          absThreshSsbRsrpConsolidation           0
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          absThreshSsbRsrqConsolidation           0
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          sMeasConfigSsbRsrp                      87
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          a1MeashoEnabledSA                       rsrq
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          a2MeashoEnabledSA                       rsrpCombined
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          a3MeasEnabled                           rsrqCombined
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          a5MeasEnabled                           rsrpAndRsrq
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          absThreshSsbRsrpConsolidation           0
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          absThreshSsbRsrqConsolidation           0
    ...   MRBTS-1/NRBTS-1/NRCELL-2                          sMeasConfigSsbRsrp                      87
    ...   MRBTS-1/NRBTS-1/NRPMRNL-1                         miNrRelReportCu                         5min
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    FOR  ${id}   IN RANGE  1  3
        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a1MeashoSsbRsrpSA
        ${a1MeashoSsbRsrp}          Create dictionary                           a1HysteresishoSsbRsrpSA                 0
        ...                                                                     a1ThresholdhoSsbRsrpSA                  60
        ...                                                                     a1TimeToTriggerhoSsbRsrpSA              ms480
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a1MeashoSsbRsrpSA             elements=${a1MeashoSsbRsrp}
        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a1MeashoSsbRsrqSA
        ${a1MeashoSsbRsrq}          Create dictionary                           a1HysteresishoSsbRsrqSA                 0
        ...                                                                     a1ThresholdhoSsbRsrqSA                  63
        ...                                                                     a1TimeToTriggerhoSsbRsrqSA              ms480
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a1MeashoSsbRsrqSA             elements=${a1MeashoSsbRsrq}
        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a2MeashoSsbRsrpSA
        ${a2MeashoSsbRsrp}          Create dictionary                           a2HysteresishoSsbRsrpSA                 0
        ...                                                                     a2ThresholdhoSsbRsrpSA                  34
        ...                                                                     a2TimeToTriggerhoSsbRsrpSA              ms480
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a2MeashoSsbRsrpSA             elements=${a2MeashoSsbRsrp}
        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a2MeashoSsbRsrqSA
        ${a2MeashoSsbRsrq}          Create dictionary                           a2HysteresishoSsbRsrqSA                 0
        ...                                                                     a2ThresholdhoSsbRsrqSA                  34
        ...                                                                     a2TimeToTriggerhoSsbRsrqSA              ms480
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a2MeashoSsbRsrqSA             elements=${a2MeashoSsbRsrq}
        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a3MeasSsbRsrp
        ${a3MeasSsbRsrp}            Create dictionary                           a3HysteresisSsbRsrp                     0
        ...                                                                     a3OffsetSsbRsrp                         6
        ...                                                                     a3TimeToTriggerSsbRsrp                  ms320
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a3MeasSsbRsrp                 elements=${a3MeasSsbRsrp}
        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a3MeasSsbRsrq
        ${a3MeasSsbRsrq}            Create dictionary                           a3HysteresisSsbRsrq                     0
        ...                                                                     a3OffsetSsbRsrq                         6
        ...                                                                     a3TimeToTriggerSsbRsrq                  ms320
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a3MeasSsbRsrq                 elements=${a3MeasSsbRsrq}
        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a5MeasSsbRsrp
        ${a5MeasSsbRsrp}            Create dictionary                           a5HysteresisSsbRsrp                     0
        ...                                                                     a5Threshold1SsbRsrp                     52
        ...                                                                     a5Threshold2SsbRsrp                     54
        ...                                                                     a5TimeToTriggerSsbRsrp                  ms100
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a5MeasSsbRsrp                 elements=${a5MeasSsbRsrp}
        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a5MeasSsbRsrq
        ${a5MeasSsbRsrq}            Create dictionary                           a5HysteresisSsbRsrq                     0
        ...                                                                     a5Threshold1SsbRsrq                     52
        ...                                                                     a5Threshold2SsbRsrq                     54
        ...                                                                     a5TimeToTriggerSsbRsrq                  ms100
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a5MeasSsbRsrq                 elements=${a5MeasSsbRsrq}
    END
    Add NREL MOC to NRCELL  cell_id=1  moc_id=1  lcrId=2
    Add NREL MOC to NRCELL  cell_id=2  moc_id=1  lcrId=1

Add NREL MOC to NRCELL
    [Arguments]    ${cell_id}   ${moc_id}   ${lcrId}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRREL-${moc_id}
    Set Object    class_name=NRREL    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                            ${value}      IN
    ...   actA4ToA1BasedSCellFallbackNsa        false
    ...   cellIndividualSsbRsrpOffset           0dB
    ...   cellIndividualSsbRsrqOffset           0dB
    ...   gNbId                                 1
    ...   gNbIdLength                           22
    ...   handoverAllowedSA                     allowed
    ...   handoverAllowedSARedCap               forbidden
    ...   isRplCellForPSCell                    false
    ...   lcrId                                 ${lcrId}
    ...   nrDcAllowed                           false
    ...   removeNotAllowed                      false
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}          list_name=gnbPlmn
    ${gnbPlmn_dict}                 Create dictionary               mcc                             311
    ...                                                             mnc                             489
    ...                                                             mncLength                       3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=gnbPlmn               elements=${gnbPlmn_dict}

Add NRIRFIM MOC to NRSYSINFO_PROFILE
    [Arguments]    ${id}   ${prio}   ${freq}   ${band}   ${scs}   ${sub_prio}=${EMPTY}   ${weight}=${EMPTY}   ${ca_weight}=${EMPTY}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-${id}
    Set Object    class_name=NRIRFIM    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                             ${value}      IN
    ...   cellReselectionPriority               ${prio}
    ...   dlCarrierFreq                         ${freq}
    ...   dssCellsDeployed                      false
    ...   freqBandIndicatorNR                   ${band}
    ...   qOffsetFreq                           -20dB
    ...   qRxLevMin                             -60
    ...   ssbScs                                ${scs}
    ...   tReselectionNr                        1
    ...   threshXHighP                          30
    ...   threshXHighQ                          30
    ...   threshXLowP                           22
    ...   threshXLowQ                           22
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    IF    '${sub_prio}'!='${EMPTY}'
    ...   sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=cellReselectionSubPriority     value=${sub_prio}
    IF    '${weight}'!='${EMPTY}'
    ...   sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=idleMMNrCelResWeight     value=${weight}
    IF    '${ca_weight}'!='${EMPTY}'
    ...   sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=ulCaIdleMMNrCelResWeight     value=${ca_weight}

Add NRLIM MOC to NRSYSINFO_PROFILE
    [Arguments]    ${id}   ${freq}   ${resel_prio}=${EMPTY}   ${sub_prio}=${EMPTY}   ${cell_weight}=${EMPTY}   ${endc_weight}=${EMPTY}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-${id}
    Set Object    class_name=NRLIM    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                             ${value}      IN
    ...   allowedMeasBw                         mbw100
    ...   carrierFreq                           ${freq}
    ...   pMaxEutra                             23
    ...   presenceAntPort1                      false
    ...   qQualMin                              -34
    ...   qRxLevMin                             -22
    ...   threshXHigh                           0
    ...   threshXLow                            0
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    IF    '${resel_prio}'!='${EMPTY}'
    ...   sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=cellReselectionPriority     value=${resel_prio}
    IF    '${sub_prio}'!='${EMPTY}'
    ...   sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=cellReselectionSubPriority     value=${sub_prio}
    IF    '${cell_weight}'!='${EMPTY}'
    ...   sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=idleMMEutraCelResWeight     value=${cell_weight}
    IF    '${endc_weight}'!='${EMPTY}'
    ...   sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=idleMMEutraCelResWeightEnDc     value=${endc_weight}

Modify Idle mode mobility steering algorithm and Inactivity Timer Value
    [Arguments]       ${algo}   ${test_instance}   ${timer}=20   ${cell_id}=1
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                          ${p_name}                   ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRCELL-${cell_id}     idleMMSteeringAlgo          ${algo}
    ...   MRBTS-1/NRBTS-1                       drbInactivityTimerSA        ${timer}
    ...   MRBTS-1/NRBTS-1                       srbInactivityTimerSA        ${timer}
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Apply Delta Configuration for PR789735 Verification
    [Arguments]       ${test_instance}
    ${scf_file}=      Load current SCF
    scf.remove_mo_with_descendant_mos        MRBTS-1/NRBTS-1/NRCAIMP-11
    FOR    ${id}    IN    1   6
        scf.remove_element_from_scf         dist_name=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-${id}     p_name=ulCaIdleMMNrCelResWeight
    END
    FOR   ${p_name}                   ${value}                   IN
    ...   dlCarrierFreq               159630
    ...   idleMMNrCelResWeight        60
          sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-5    p_name=${p_name}    value=${value}
    END
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Apply Configuration for Sub-Feature A_B2
    [Arguments]       ${algo}   ${test_instance}   ${cell_id}=1
    ${scf_file}=      Load current SCF
    sqd65_commissioning.Set Element       dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}     p_name=idleMMSteeringAlgo     value=${algo}
    scf.remove_element_from_scf         dist_name=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1      p_name=ulCaIdleMMNrCelResWeight
    scf.remove_element_from_scf         dist_name=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-6      p_name=ulCaIdleMMNrCelResWeight
    FOR  ${id}   IN RANGE  1  7
        scf.remove_mo_with_descendant_mos        MRBTS-1/NRBTS-1/NRCAIMP-2/NRCAIMS-${id}
        scf.remove_mo_with_descendant_mos        MRBTS-1/NRBTS-1/NRCAIMP-4/NRCAIMS-${id}
        scf.remove_mo_with_descendant_mos        MRBTS-1/NRBTS-1/NRCAIMP-6/NRCAIMS-${id}
        scf.remove_mo_with_descendant_mos        MRBTS-1/NRBTS-1/NRCAIMP-7/NRCAIMS-${id}
    END
    @{scell_targets} =  Create List  [2, 2, 636576, 655968]  [2, 3, 531870]  [2, 4, 518910, 655968, 636576]  [2, 5, 531870, 516990, 655968, 636576]
    ...    [4, 1, 127450]  [4, 2, 392410, 127450]  [4, 3, 392410, 431090]  [4, 4, 392410, 431090, 428410]  [4, 5, 431090, 428410, 392410, 368910]
    ...    [4, 6, 431090]  [6, 1, 518910, 531870, 636576]  [6, 2, 518910, 655968]  [6, 3, 636576]  [6, 4, 531870, 655968]
    ...    [6, 5, 518910, 655968, 636576, 655968]  [7, 1, 431090, 127450, 392410]  [7, 2, 159630]  [7, 3, 392410, 159630, 368910, 431090]
    ...    [7, 4, 368910]  [7, 5, 159630, 127450]  [7, 6, 127450, 431090, 392410]
    FOR  ${target}  IN  @{scell_targets}
        ${target_list}=    Evaluate    list(${target})
        ${imp_id}=    Set Variable    ${target_list}[0]
        ${ims_id}=    Set Variable    ${target_list}[1]
        @{nrarfcn_list}=    Create List    @{target_list}[2:]
        Set Object    class_name=NRCAIMS    dist_name=MRBTS-1/NRBTS-1/NRCAIMP-${imp_id}/NRCAIMS-${ims_id}   version=${NIDD_VERSION}
        Set New List    dist_name=MRBTS-1/NRBTS-1/NRCAIMP-${imp_id}/NRCAIMS-${ims_id}    list_name=sCellConfig
        Add More Scell Targets in NRCAIMS MOC  ${imp_id}  ${ims_id}  @{nrarfcn_list}
    END
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Enable from Simulated to Real Inter GNB Handover Configuration
    [Arguments]
    FOR   ${p_name}                             ${value}      IN
    ...   actIntraNrNgHo                        sourceAndTarget
    ...   tNgRelocExecDeltN                     3000
    ...   tNgRelocCancelN                       2000
    ...   tNgRelocOverallN                      3000
    ...   tNgRelocPrepN                         2000
    ...   suppCnPartialAdNgHo                   false
    sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1    p_name=${p_name}   value=${value}
    END

Apply Configuration for Multi Plmn and Slicing
    Add NRPLMNSET_SA to NRCELL-1  id=2  tac=400  plmn_id=2
    Add Tracking Area to NRBTS  id=400
    ${nrPlmnDNList_list}=       Create List                             MRBTS-1/NRBTS-1/NRPLMN-2
    FOR  ${slice_id}   IN RANGE  2  4
        scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1/SNSSAI-${slice_id}      list_name=nrPlmnDNList      elements=${nrPlmnDNList_list}
    END

Add NRPLMNSET_SA to NRCELL-1
    [Arguments]       ${id}   ${tac}   ${plmn_id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-${id}
    Set Object    class_name=NRPLMNSET_SA    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${dist_name}                                      ${p_name}                                   ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-${id}       cellReservedForOperatorUse                  notReserved
    ...   MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-${id}       cellReservedForOperatorUseUacAutoMax        notReserved
    ...   MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-${id}       ranAC                                       0
    ...   MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-${id}       trackingAreaDN                              MRBTS-1/NRBTS-1/TRACKINGAREA-${tac}
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Set New List                    dist_name=${dist_name}      list_name=nrPlmnDNList
    ${nrPlmnDNList_list}=           Create List                 MRBTS-1/NRBTS-1/NRPLMN-${plmn_id}
    scf.add_elements_to_list        dist_name=${dist_name}      list_name=nrPlmnDNList              elements=${nrPlmnDNList_list}

Add Tracking Area to NRBTS
    [Arguments]       ${id}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/TRACKINGAREA-${id}
    Set Object    class_name=TRACKINGAREA    dist_name=${dist_name}   version=${NIDD_VERSION}
    sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=fiveGsTac    value=${id}
    Set New List                    dist_name=${dist_name}          list_name=snssaiList
    FOR  ${slice_id}   IN RANGE  1  4
        ${snssaiList_dict}              Create dictionary               snssaiDN                    MRBTS-1/NRBTS-1/SNSSAI-${slice_id}
        scf.add_item_to_list            dist_name=${dist_name}          list_name=snssaiList        elements=${snssaiList_dict}
    END

Apply Delta Config to Enable RRC Inactive State Transition and Modify NRIRFIM Params
    [Arguments]   ${test_instance}
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actRrcInactState                        intra-gNB
    ...   MRBTS-1/NRBTS-1                                   outOfConnectedPreference                inactive
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Modify NRIRFIM Parameters
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Modify NRIRFIM Parameters
    [Arguments]
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-8     dlCarrierFreq                           431090
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-8     freqBandIndicatorNR                     66
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-8     ssbScs                                  15KHz
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1     idleMMNrCelResWeight                    19
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-6     cellReselectionSubPriority              oDot2
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    FOR   ${dist_name}                                      ${p_name}                               IN
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2     idleMMNrCelResWeight
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          idleMMServCelResWeight
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          ulCaAwareIMMServCelResWeight
          scf.remove_element_from_scf         dist_name=${dist_name}      p_name=${p_name}
    END

Apply Delta Config to Enable Steering from NR SA to ENDC
    [Arguments]   ${test_instance}
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                      ${p_name}                           ${value}                   IN
    ...   MRBTS-1/NRBTS-1                   actIdlMMEnDcSteering                true
    ...   MRBTS-1/NRBTS-1                   drbInactivityTimerSA                20
    ...   MRBTS-1/NRBTS-1                   srbInactivityTimerSA                20
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Modify NRIRFIM Parameters
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Apply Configuration for Sub-Feature B_B2
    [Arguments]   ${test_instance}   ${algo}   ${mob_prof}
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                                  ${p_name}                       ${value}                   IN
    ...   MRBTS-1/NRBTS-1                               actMobilityProfile              ${mob_prof}
    ...   MRBTS-1/NRBTS-1/NRMOPR_SA-6/NRMOIMP_SA-1      idleMMSteeringAlgo              ${algo}
    ...   MRBTS-1/NRBTS-1/NRMOPR_SA-5/NRMOIMP_SA-1      idleMMSteeringAlgo              ${algo}
    ...   MRBTS-1/NRBTS-1                               drbInactivityTimerSA            30
    ...   MRBTS-1/NRBTS-1                               srbInactivityTimerSA            30
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Activate Mobility Profile and RRC Inactive State Transition
    [Arguments]   ${test_instance}
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                  ${p_name}                       ${value}                   IN
    ...   MRBTS-1/NRBTS-1               actMobilityProfile              true
    ...   MRBTS-1/NRBTS-1               actRrcInactState                intra-gNB
    ...   MRBTS-1/NRBTS-1               outOfConnectedPreference        inactive
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    scf.remove_mo_with_descendant_mos        MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-6
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Activate Mobility Profile and ENDC Steering
    [Arguments]   ${test_instance}
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                  ${p_name}                       ${value}                   IN
    ...   MRBTS-1/NRBTS-1               actMobilityProfile              true
    ...   MRBTS-1/NRBTS-1               actIdlMMEnDcSteering            true
    ...   MRBTS-1/NRBTS-1               drbInactivityTimerSA            20
    ...   MRBTS-1/NRBTS-1               srbInactivityTimerSA            20
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Modify NRIRFIM Parameters
    IF    '${test_instance}'=='B_B4_2'    Enable Idle mode mobility steering algorithm with UL and DL CA Aware
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Enable Idle mode mobility steering algorithm with UL and DL CA Aware
    FOR   ${dist_name}                                      ${p_name}                       ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRMOPR_SA-3/NRMOIMP_SA-1          idleMMSteeringAlgo              UL and DL CA aware
    ...   MRBTS-1/NRBTS-1/NRMOPR_SA-4/NRMOIMP_SA-1          idleMMSteeringAlgo              UL and DL CA aware
    ...   MRBTS-1/NRBTS-1/NRMOPR_SA-8/NRMOIMP_SA-1          idleMMSteeringAlgo              UL and DL CA aware
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

Apply Configuration for Sub-Feature C User Scenario
    [Arguments]   ${test_instance}   ${algo}   ${mob_prof}   ${timer}=20   ${mo_prof_id}=6
    ${scf_file}=      Load current SCF
    Set New List                dist_name=MRBTS-1/NRBTS-1/NRDU-1        list_name=ulTxSwitchingSupportList
    ${ulTxSwitch_list}=         Create List                             ca_Fr1T_F_Sa_switchedUl
    scf.add_elements_to_list    dist_name=MRBTS-1/NRBTS-1/NRDU-1        list_name=ulTxSwitchingSupportList          elements=${ulTxSwitch_list}
    FOR   ${dist_name}                  ${p_name}                       ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRCELL-1      idleMMSteeringAlgo              ${algo}
    ...   MRBTS-1/NRBTS-1               actMobilityProfile              ${mob_prof}
    ...   MRBTS-1/NRBTS-1               drbInactivityTimerSA            ${timer}
    ...   MRBTS-1/NRBTS-1               srbInactivityTimerSA            ${timer}
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    FOR   ${dist_name}                                      ${p_name}                               IN
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-4     ulCaIdleMMNrCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-6     ulCaIdleMMNrCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-4     idleMMNrCelResWeight
          scf.remove_element_from_scf         dist_name=${dist_name}      p_name=${p_name}
    END
    IF    '${test_instance}' in ['C_B2_1', 'C_B2_2']
    ...  sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-${mo_prof_id}/NRMOIMP_SA-1    p_name=idleMMSteeringAlgo
    ...  value=${algo}
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Apply Configuration for Sub-Feature D_B01 CB007516 User Scenario
    [Arguments]   ${test_instance}   ${algo}   ${WRR_Sec}   ${EnDcSteer}   ${timer}=20
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                  ${p_name}                       ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRCELL-1      idleMMSteeringAlgo              ${algo}
    ...   MRBTS-1/NRBTS-1/NRCELL-1      idleMMSteeringWRREnabledSec     ${WRR_Sec}
    ...   MRBTS-1/NRBTS-1               actIdlMMEnDcSteering            ${EnDcSteer}
    ...   MRBTS-1/NRBTS-1               drbInactivityTimerSA            ${timer}
    ...   MRBTS-1/NRBTS-1               srbInactivityTimerSA            ${timer}
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    FOR   ${dist_name}                                      ${p_name}                               IN
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-6     idleMMNrCelResWeight
    ...   MRBTS-1/NRBTS-1/NRCELL-1                          idleMMServCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-4     idleMMNrCelResWeight
          scf.remove_element_from_scf         dist_name=${dist_name}      p_name=${p_name}
    END
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Apply Configuration for Sub-Feature D_B02 CB007516 User Scenario
    [Arguments]   ${test_instance}   ${UlCaAware}   ${algo}   ${WRR_Sec}   ${mob_prof}   ${timer}=20
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                                  ${p_name}                       ${value}                   IN
    ...   MRBTS-1/NRBTS-1                               actUlCaAwareIMMSteering         ${UlCaAware}
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      idleMMSteeringAlgo              ${algo}
    ...   MRBTS-1/NRBTS-1/NRCELL-1                      idleMMSteeringWRREnabledSec     Disabled
    ...   MRBTS-1/NRBTS-1/NRCELL-2                      idleMMSteeringAlgo              ${algo}
    ...   MRBTS-1/NRBTS-1/NRCELL-2                      idleMMSteeringWRREnabledSec     Disabled
    ...   MRBTS-1/NRBTS-1                               actMobilityProfile              ${mob_prof}
    ...   MRBTS-1/NRBTS-1                               drbInactivityTimerSA            ${timer}
    ...   MRBTS-1/NRBTS-1                               srbInactivityTimerSA            ${timer}
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    FOR  ${nrmopr_id}   IN RANGE  1  9
          sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-${nrmopr_id}/NRMOIMP_SA-1    p_name=idleMMSteeringAlgo
          ...    value=${algo}
          sqd65_commissioning.Set Element    dist_name=MRBTS-1/NRBTS-1/NRMOPR_SA-${nrmopr_id}/NRMOIMP_SA-1    p_name=idleMMSteeringWRREnabledSec
          ...    value=${WRR_Sec}
    END
    scf.remove_mo_with_descendant_mos        MRBTS-1/NRBTS-1/NRCAIMP-1
    scf.remove_element_from_scf         dist_name=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2      p_name=cellReselectionSubPriority
    Apply Delta SCF   ${scf_file}    ${test_instance}_modified_scf

Apply Configuration for Sub-Feature D_B01 to get UE Steered to LTE Frequency
    [Arguments]
    ${scf_file}=      Load current SCF
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-8     dlCarrierFreq                           431090
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-8     freqBandIndicatorNR                     66
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-8     ssbScs                                  15KHz
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-6     cellReselectionSubPriority              oDot2
          sqd65_commissioning.Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    FOR   ${dist_name}                                      ${p_name}                               IN
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2     idleMMNrCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3     idleMMNrCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-7     idleMMNrCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2       idleMMEutraCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-4       idleMMEutraCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-5       idleMMEutraCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-6       idleMMEutraCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-7       idleMMEutraCelResWeight
    ...   MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-8       idleMMEutraCelResWeight
          scf.remove_element_from_scf         dist_name=${dist_name}      p_name=${p_name}
    END
    Apply Delta SCF   ${scf_file}    modified_scf_for_steer_to_LTE_Freq
