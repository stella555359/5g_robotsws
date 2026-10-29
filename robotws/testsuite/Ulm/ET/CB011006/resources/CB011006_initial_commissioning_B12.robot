*** Settings ***
Documentation    Commissioning keywords for CB011006: B12 CA IWKs

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Initial commissioning for IWK12
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                                       ${p_name}                            ${value}                        IN
    ...    ${distName_NRBTS[0]}                               gNbCuType                            SA
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  ${band_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwDl                               ${chBw_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwUl                               ${chBw_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnDl                            ${arfcnDl_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnUl                            ${arfcnUl_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  ${band_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwDl                               ${chBw_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwUl                               ${chBw_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnDl                            ${arfcnDl_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnUl                            ${arfcnUl_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_3}
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                freqBandIndicatorNR                  ${band_fdd_cell_3}
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}/NRCELL_FDD-1   chBwDl                               ${chBw_fdd_cell_3}
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}/NRCELL_FDD-1   chBwUl                               ${chBw_fdd_cell_3}
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}/NRCELL_FDD-1   nrarfcnDl                            ${arfcnDl_fdd_cell_3}
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}/NRCELL_FDD-1   nrarfcnUl                            ${arfcnUl_fdd_cell_3}
        Set Element   dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Activate 1F3T DL CA for 3FDD+4TDD Setup


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate 1F3T DL CA for 3FDD+4TDD Setup
    Log  Activating CA in scf.xml  console=yes
    Activate 4CC CA in NRBTS
    Activate 4CC CA in NRCELL
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Activate 4CC CA in NRREL    pcell_id=1    scell_id=4    dir=dlOnly    nrrel_id=1
    Activate 4CC CA in NRREL    pcell_id=1    scell_id=5    dir=dlOnly    nrrel_id=2
    Activate 4CC CA in NRREL    pcell_id=1    scell_id=6    dir=dlOnly    nrrel_id=3
    Activate 4CC CA in NRREL    pcell_id=4    scell_id=1    dir=dlOnly    nrrel_id=1
    Activate 4CC CA in NRREL    pcell_id=5    scell_id=1    dir=dlOnly    nrrel_id=1
    Activate 4CC CA in NRREL    pcell_id=6    scell_id=1    dir=dlOnly    nrrel_id=1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Activate 4CC CA in NRREL    pcell_id=2    scell_id=4    dir=dlOnly    nrrel_id=1
    Activate 4CC CA in NRREL    pcell_id=2    scell_id=5    dir=dlOnly    nrrel_id=2
    Activate 4CC CA in NRREL    pcell_id=2    scell_id=6    dir=dlOnly    nrrel_id=3
    Activate 4CC CA in NRREL    pcell_id=4    scell_id=2    dir=dlOnly    nrrel_id=2
    Activate 4CC CA in NRREL    pcell_id=5    scell_id=2    dir=dlOnly    nrrel_id=2
    Activate 4CC CA in NRREL    pcell_id=6    scell_id=2    dir=dlOnly    nrrel_id=2
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Activate 4CC CA in NRREL    pcell_id=3    scell_id=4    dir=dlOnly    nrrel_id=1
    Activate 4CC CA in NRREL    pcell_id=3    scell_id=5    dir=dlOnly    nrrel_id=2
    Activate 4CC CA in NRREL    pcell_id=3    scell_id=6    dir=dlOnly    nrrel_id=3
    Activate 4CC CA in NRREL    pcell_id=4    scell_id=3    dir=dlOnly    nrrel_id=3
    Activate 4CC CA in NRREL    pcell_id=5    scell_id=3    dir=dlOnly    nrrel_id=3
    Activate 4CC CA in NRREL    pcell_id=6    scell_id=3    dir=dlOnly    nrrel_id=3
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Activate 4CC CA in NRDU
    Activate 4CC CA in NRDRB_RLC_AM



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate 4CC CA in NRBTS
    ${distName_NRBTS}=     Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                    ${value}         IN
    ...    actCarrierAggregation        true
    ...    caConfigurationSupport       4CCDL_2CCUL
    ...    sCellActivationMethod        blind
    ...    maxNumScellsDl               1
    ...    maxNumScellsUl               1
    ...    actLteNrDss                  false
    ...    actFdmScheduling             true
    ...    actMultipleDedicatedBWPs     false
    ...    actHighestEstNrTputBcSel     false
        Set Element   dist_name=${distName_NRBTS[0]}    p_name=${p_name}    value=${value}
    END


Activate 4CC CA in NRCELL
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    ${distName_NRCELLGRP}=  Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELLGRP-[0-9]+
    sort list   ${distName_NRCELLGRP}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure each Cell for 4CC CA     ${NRCELL}
    END
    #--- CB011006 Specific Changes: -------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${dist_name}              ${p_name}                    ${value}         IN
    ...    ${distName_NRCELL[3]}     actBeamforming               false                        # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[4]}     actBeamforming               false                        # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[5]}     actBeamforming               false                        # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[6]}     actBeamforming               false                        # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[3]}     increasePUSCHPrepTimeULCA    false                        # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[4]}     increasePUSCHPrepTimeULCA    false                        # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[5]}     increasePUSCHPrepTimeULCA    false                        # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[6]}     increasePUSCHPrepTimeULCA    false                        # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELLGRP[3]}  numberOfTransmittedSsBlocks  1 beam                       # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELLGRP[4]}  numberOfTransmittedSsBlocks  1 beam                       # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELLGRP[5]}  numberOfTransmittedSsBlocks  1 beam                       # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELLGRP[6]}  numberOfTransmittedSsBlocks  1 beam                       # <--- this is TDD cell from 3FDD+4TDD Setup
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    FOR    ${dist_name}              ${p_name}                    ${value}         IN
    ...    ${distName_NRCELL[3]}     basicBeamSet                 beamSet_1                    # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[4]}     basicBeamSet                 beamSet_1                    # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[5]}     basicBeamSet                 beamSet_1                    # <--- this is TDD cell from 3FDD+4TDD Setup
    ...    ${distName_NRCELL[6]}     basicBeamSet                 beamSet_1                    # <--- this is TDD cell from 3FDD+4TDD Setup
        scf.modify_scf_element   dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


Configure each Cell for 4CC CA
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
        Set Element   dist_name=${distName}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName}  list_name=allowUnsuppBcOrBcs
    ${param_list}=    create list  accept unknown band combinations
    scf.add_elements_to_list  dist_name=${distName}  list_name=allowUnsuppBcOrBcs   elements=${param_list}


Activate 4CC CA in NRREL
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
        Set Element   dist_name=${distName_NRREL}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRREL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRREL}   list_name=gnbPlmn   elements=${gnbPlmn_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]


Activate 4CC CA in NRDU
    ${distName_NRDU}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element   dist_name=${distName_NRDU[0]}    p_name=flexibleCAMode                      value=NumberCellAmount
    Set Element   dist_name=${distName_NRDU[0]}    p_name=dlToUlContributionRatio             value=50
    Set Element   dist_name=${distName_NRDU[0]}    p_name=actInterNumerologyCa                value=true
    Set Element   dist_name=${distName_NRDU[0]}    p_name=actConnectedModeMobilityCA          value=true
    Set List      dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList
    ${param_list}=    create list    ca_Fdd_Fdd  ca_Fdd_Fr1Tdd_Sa  ca_Fr1Tdd_Sa  ca_Fr1Tdd_Fdd_Sa  ca_Fdd_Any_Sa  ca_Fr1Tdd_Any_Sa
    scf.add_elements_to_list    dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList   elements=${param_list}


Activate 4CC CA in NRDRB_RLC_AM
    ${distName_RLC_AM}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB_RLC_AM-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element   dist_name=${distName_RLC_AM[0]}    p_name=dlTReassemblyIBCA     value=40
    Set Element   dist_name=${distName_RLC_AM[1]}    p_name=dlTReassemblyIBCA     value=40

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
