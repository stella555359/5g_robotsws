*** Settings ***
Documentation    Commissioning keywords for CB011006: changes for CA related IWKs
...     **************************** CA F+F (B06) ******************************
...                             ---------------
...                            |       TDD     |
...                            |       TDD     |
...                            |  /'\  FDD     |  (NRREL1 to FDD=cell3)
...     F+F (F as primary) --> |   |   FDD     |  (NRREL1 from FDD=cell4)
...                             ---------------
...     ******************************************************************
...
...     **************************** CA F+T (B07) ******************************
...                             ----------------
...                            |   /'\  TDD     |  (NRREL1 to TDD=cell1)
...                            |    |   TDD     |
...     F+T (F as primary) --> |    |   FDD     |  (NRREL1 from FDD=cell3)
...                            |        FDD     |
...                             ----------------
...     ******************************************************************
...
...     **************************** CA T+F (B08) ******************************
...                             ----------------
...     T+F (T as primary) --> |    |   TDD     |  (NRREL1 from TDD=cell1)
...                            |    |   TDD     |
...                            |   \./  FDD     |  (NRREL1 to FDD=cell3)
...                            |        FDD     |
...                             ----------------
...     ******************************************************************
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Activate UL CA for 2TDD+2FDD Setup
    Log  Activating CA in scf.xml  console=yes
    Activate CA in NRBTS
    Activate CA in NRCELL    dlAndUl
    Add NRREL    pcell_id=1    scell_id=3    dir=dlAndUl    nrrel_id=1
    Add NRREL    pcell_id=3    scell_id=1    dir=dlAndUl    nrrel_id=1
    Activate UL CA in NRDU
    Activate UL CA in NRDRB_RLC_AM
    Modify preconditions for B09_B10


Activate DL CA for 2TDD+2FDD Setup
    Log  Activating CA in scf.xml  console=yes
    Activate CA in NRBTS
    Activate CA in NRCELL    dlOnly
    Add NRREL    pcell_id=1    scell_id=3    dir=dlOnly    nrrel_id=1
    Add NRREL    pcell_id=3    scell_id=1    dir=dlOnly    nrrel_id=1
    Add NRREL    pcell_id=4    scell_id=3    dir=dlOnly    nrrel_id=1
    Add NRREL    pcell_id=3    scell_id=4    dir=dlOnly    nrrel_id=2
    Activate DL CA in NRDU
    Activate DL CA in NRDRB_RLC_AM
    IF        'B06' in '${SUITE_NAME}'
        Modify preconditions for B06
    ELSE IF   'B07' in '${SUITE_NAME}'
        Modify preconditions for B07
    ELSE IF   'B08' in '${SUITE_NAME}'
        Modify preconditions for B08
    END


Modify preconditions for B07
    ${distName_NRCELL}=     Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    Configure tdlte aligned frame structure    ${distName_NRCELL[${tdd_cell_1}-1]}
    Set Element    dist_name=${distName_NRCELL[${tdd_cell_1}-1]}    p_name=prachConfigurationIndex    value=97
    Configure tdlte aligned frame structure    ${distName_NRCELL[${tdd_cell_1}]}
    Set Element    dist_name=${distName_NRCELL[${tdd_cell_1}]}    p_name=prachConfigurationIndex    value=97


Modify preconditions for B08
    ${distName_NRBTS}=      Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${dist_name}                              ${p_name}                    ${value}         IN
    ...    ${distName_NRBTS[0]}                      actFdmEnhancedScheduling     true
    ...    ${distName_NRCELL[${tdd_cell_1}-1]}       actPrachMultiplexing         false         # <--- this is 1st TDD cell from 2TDD+2FDD Setup
    ...    ${distName_NRCELL[${tdd_cell_1}-0]}       actPrachMultiplexing         false         # <--- this is 2nd TDD cell from 2TDD+2FDD Setup
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}       actPrachMultiplexing         false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}       actPrachMultiplexing         false
    ...    ${distName_NRCELL[${tdd_cell_1}-1]}       actIncreasedFdmUsersPerSlot  false         # <--- this is 1st TDD cell from 2TDD+2FDD Setup
    ...    ${distName_NRCELL[${tdd_cell_1}-0]}       actIncreasedFdmUsersPerSlot  false         # <--- this is 2nd TDD cell from 2TDD+2FDD Setup
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}       actIncreasedFdmUsersPerSlot  false
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}       actIncreasedFdmUsersPerSlot  false
        Set Element    dist_name=${dist_name}        p_name=${p_name}             value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Configure tdlte aligned frame structure    ${distName_NRCELL[${tdd_cell_1}-1]}
    Set Element    dist_name=${distName_NRCELL[${tdd_cell_1}-1]}    p_name=prachConfigurationIndex    value=97
    Configure tdlte aligned frame structure    ${distName_NRCELL[${tdd_cell_1}]}
    Set Element    dist_name=${distName_NRCELL[${tdd_cell_1}]}    p_name=prachConfigurationIndex    value=97
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDU}=       Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    Set Element    dist_name=${distName_NRDU[0]}    p_name=flexibleCAMode    value=NumberCellAmount


Modify preconditions for B06
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${dist_name}                                       ${p_name}                            ${value}                      IN
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  ${band_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwDl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwUl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnDl                            ${arfcnDl_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnUl                            ${arfcnUl_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  ${band_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwDl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwUl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnDl                            ${arfcnDl_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnUl                            ${arfcnUl_fdd_cell_2}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n106
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl}=  create dictionary
    ...    cRbSizeUl             sameAsDl
    ...    cRbStartUl            sameAsDl
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthUl   elements=${locationAndBandwidthUl}
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-33    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n270
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-33    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    Set List      dist_name=${distName_NRBTS[0]}/BWP_PROFILE-33    list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl}=  create dictionary
    ...    cRbSizeUl             sameAsDl
    ...    cRbStartUl            sameAsDl
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-33    list_name=locationAndBandwidthUl   elements=${locationAndBandwidthUl}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    # Since the following changes are applicable only to USCB011006-B#IWK.6, these shall be at the end to ensure that the values are overwritten
    Activate multiple BWPs feature
    Set Element    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=actEnhMultipleDedicatedBWPs    value=true
    Set Element    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}    p_name=actEnhMultipleDedicatedBWPs    value=true
    Set List    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}  list_name=allowUnsuppBcOrBcs
    ${param_list}=    create list  complete BCS check
    scf.add_elements_to_list  dist_name=${distName_NRCELL[${fdd_cell_1}-1]}  list_name=allowUnsuppBcOrBcs   elements=${param_list}
    ${src_bwp_mo}  ${target_bwp_mo}  ${max_cellBwpId} =    Get new BWP for cell    ${distName_NRCELL[${fdd_cell_1}-1]}
    Map BWP to cell  ${distName_NRCELL[${fdd_cell_1}-1]}  ${target_bwp_mo}  ${max_cellBwpId}
    Add BWP  ${src_bwp_mo}  ${target_bwp_mo}  n106  dedicated
    Map BWP to cell  ${distName_NRCELL[${fdd_cell_2}-1]}  ${target_bwp_mo}  ${max_cellBwpId}

Modify preconditions for B09_B10
    ${distName_NRCELL}=     Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    Configure tdlte aligned frame structure    ${distName_NRCELL[${tdd_cell_1}-1]}
    Set Element    dist_name=${distName_NRCELL[${tdd_cell_1}-1]}    p_name=prachConfigurationIndex    value=97
    Configure tdlte aligned frame structure    ${distName_NRCELL[${tdd_cell_1}]}
    Set Element    dist_name=${distName_NRCELL[${tdd_cell_1}]}    p_name=prachConfigurationIndex    value=97


Configure tdlte aligned frame structure
    [Arguments]  ${tdd_cell_distname}
    Set List    dist_name=${tdd_cell_distname}    list_name=tddFrameStructure
    ${tddFrameStructure}=  create dictionary
    ...    frameStructureType             tdLte
    ...    guardPeriodLength              6Symbols
    ...    lteToNrFrameShift              0ms
    ...    tdLteUlDlConfig                tdLteConfig2
    ...    ulDlDataSlotRatio              1/4
    scf.add_item_to_list    dist_name=${tdd_cell_distname}    list_name=tddFrameStructure   elements=${tddFrameStructure}


Activate CA in NRBTS
    ${distName_NRBTS}=     Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                    ${value}         IN
    ...    actCarrierAggregation        true
    ...    caConfigurationSupport       2CCDL_2CCUL
    ...    sCellActivationMethod        blind
    ...    maxNumScellsDl               1
    ...    maxNumScellsUl               1
    ...    actLteNrDss                  false
    ...    actFdmScheduling             true
    ...    actMultipleDedicatedBWPs     false
    ...    actCarAgPmCount              true
        Set Element    dist_name=${distName_NRBTS[0]}    p_name=${p_name}    value=${value}
    END


Activate CA in NRCELL
    [Arguments]  ${dir}
    ${ul_value} =    set variable if    '${dir}'=='dlOnly'    false    true
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure each Cell for CA     ${NRCELL}
    END
    #--- CB011006 Specific Changes: -------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${dist_name}              ${p_name}                    ${value}         IN
    ...    ${distName_NRCELL[0]}     actBeamforming               false                        # <--- this is TDD cell from 2TDD+2FDD Setup
    ...    ${distName_NRCELL[1]}     actBeamforming               false                        # <--- this is TDD cell from 2TDD+2FDD Setup
    ...    ${distName_NRCELL[0]}     increasePUSCHPrepTimeULCA    ${ul_value}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


Configure each Cell for CA
    [Arguments]  ${distName}
    FOR    ${p_name}                    ${value}         IN
    ...    actK1Opt                     intra-gNB
    ...    sCellDeactivationTimerGNB    infinity
    ...    pMaxNROwnCell                20
    ...    pucchModeSelect              longPucch
    ...    lteNrDssMode                 none
    ...    actCDrx                      false
    ...    actUlClosedLoopPwrCtrl       disabled
    ...    actEnhMultipleDedicatedBWPs  false
    ...    actPowerSavingBWP            false
    ...    timingAdvanceOffset          n25600
        Set Element    dist_name=${distName}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName}  list_name=allowUnsuppBcOrBcs
    ${param_list}=    create list  accept unknown band combinations
    scf.add_elements_to_list  dist_name=${distName}  list_name=allowUnsuppBcOrBcs   elements=${param_list}


Add NRREL
    [Arguments]  ${pcell_id}  ${scell_id}  ${dir}  ${nrrel_id}
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRREL}=  Set variable  ${distName_NRCELL[${pcell_id}-1]}/NRREL-${nrrel_id}
    Set Object    class_name=com.nokia.srbts.nrbts:NRREL
    ...           dist_name=${distName_NRREL}
    ...           version=NRBTSCL23R4_2312_101
    FOR    ${p_name}                                         ${value}    IN
    ...    cellIndividualSsbRsrpOffset                       0dB
    ...    cellIndividualSsbRsrqOffset                       0dB
    ...    gNbId                                             1
    ...    gNbIdLength                                       22
    ...    handoverAllowedSA                                 allowed
    ...    handoverAllowedSARedCap                           forbidden
    ...    isRplCellForPSCell                                false
    ...    lcrId                                             ${scell_id}
    ...    nrDcAllowed                                       false
    ...    removeNotAllowed                                  false
    ...    sCellAdditionMethod                               blind
    ...    sCellOperationalMode                              ${dir}
        Set Element    dist_name=${distName_NRREL}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRREL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRREL}   list_name=gnbPlmn   elements=${gnbPlmn_item}


Activate UL CA in NRDU
    ${distName_NRDU}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_NRDU[0]}    p_name=flexibleCAMode                      value=NumberCellAmount
    Set Element    dist_name=${distName_NRDU[0]}    p_name=dlToUlContributionRatio             value=50
    Set Element    dist_name=${distName_NRDU[0]}    p_name=actInterNumerologyCa                value=true
    Set List      dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList
    ${param_list}=    create list    ca_Fdd_Fr1Tdd_Sa_WithUl   ca_Fr1Tdd_Fdd_Sa    ca_Fr1Tdd_Fdd_Sa_WithUl    ca_Fdd_Fr1Tdd_Sa
    scf.add_elements_to_list    dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList   elements=${param_list}


Activate UL CA in NRDRB_RLC_AM
    ${distName_RLC_AM}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB_RLC_AM-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_RLC_AM[0]}    p_name=ulTReassemblyIBCA     value=40
    Set Element    dist_name=${distName_RLC_AM[1]}    p_name=ulTReassemblyIBCA     value=40


Activate DL CA in NRDU
    ${distName_NRDU}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_NRDU[0]}    p_name=flexibleCAMode                      value=NumberCellAmount
    Set Element    dist_name=${distName_NRDU[0]}    p_name=dlToUlContributionRatio             value=50
    Set Element    dist_name=${distName_NRDU[0]}    p_name=actInterNumerologyCa                value=true
    Set Element    dist_name=${distName_NRDU[0]}    p_name=actConnectedModeMobilityCA          value=true
    Set List      dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList
    ${param_list}=    create list    ca_Fr1Tdd_Fdd_Sa    ca_Fdd_Fr1Tdd_Sa    ca_Fdd_Fdd
    scf.add_elements_to_list    dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList   elements=${param_list}


Activate DL CA in NRDRB_RLC_AM
    ${distName_RLC_AM}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB_RLC_AM-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_RLC_AM[0]}    p_name=dlTReassemblyIBCA     value=40
    Set Element    dist_name=${distName_RLC_AM[1]}    p_name=dlTReassemblyIBCA     value=40

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
