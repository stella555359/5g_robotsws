*** Settings ***
Documentation    Feature specific keywords for Tranversal Robustness

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    ../../L2/libraries/tools.py
Resource   ../../../resources/Common/gnb.robot

*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Activate CA if needed
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    # IMPORTANT: the following based on LO_AP_LO + AEQE_GMC (TDD + TDD + FDD + FDD) setup
    FOR    ${dist_name}                                       ${p_name}                            ${value}         IN
    ...    ${distName_NRCELL[1]}                              gscnOrSsPbchArfcn                    7995
    ...    ${distName_NRCELL[1]}                              nrarfcn                              647666
    ...    ${distName_NRCELL[3]}                              gscnOrSsPbchArfcn                    5275
    ...    ${distName_NRCELL[3]}                              freqBandIndicatorNR                  66
    ...    ${distName_NRCELL[3]}/NRCELL_FDD-1                 nrarfcnDl                            422000
    ...    ${distName_NRCELL[3]}/NRCELL_FDD-1                 nrarfcnUl                            342000
        Set Element   dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    IF   'CA' not in '${SUITE_NAME}'   RETURN
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Log  Activating CA in scf.xml  console=yes
    IF    'CA FDD' in '${SUITE_NAME}'    Modify SCF for CA FDD+FDD     # <--- mixed-cell-setup
    ...  ELSE                            Modify SCF for CA TDD+TDD


Modify SCF for CA TDD+TDD
    Activate CA in NRBT
    Activate CA in NRCELL
    Add NRREL    pcell=${1}    scell=${2}
    Activate CA in NRDU    ca_list=ca_Fr1Tdd_Sa


Modify SCF for CA FDD+FDD
    Activate CA in NRBT
    Activate CA in NRCELL for FDD+FDD
    ${scell}=   evaluate   ${fdd_cell_1}+1
    Add NRREL    pcell=${fdd_cell_1}    scell=${scell}
    Activate CA in NRDU    ca_list=ca_Fdd_Fdd


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Activate CA In NRBT
    ${distName_NRBTS}=     gnb.Get DistNames From Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${p_name}                    ${value}         IN
    ...    actCarrierAggregation        true
    ...    caConfigurationSupport       2CCDL_2CCUL
    ...    sCellActivationMethod        bufferBased
    ...    maxNumScellsDl               1
    ...    maxNumScellsUl               1
    ...    actCarAgPmCount              true
        tools.Set Element   dist_name=${distName_NRBTS[0]}    p_name=${p_name}    value=${value}
    END


Activate CA in NRCELL
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure each Cell for CA     ${NRCELL}
    END


Activate CA in NRCELL for FDD+FDD
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure each Cell for CA     ${NRCELL}    # <--- needed for ALL cells not only PCell and SCell
    END


Configure each Cell for CA
    [Arguments]  ${distName}
    FOR    ${p_name}                    ${value}         IN
    ...    actK1Opt                     intra-gNB
    ...    sCellDeactivationTimerGNB    infinity
        Set Element   dist_name=${distName}    p_name=${p_name}    value=${value}
    END
    Set List    dist_name=${distName}  list_name=allowUnsuppBcOrBcs
    ${param_list}=    create list  accept unknown band combinations
    scf.add_elements_to_list  dist_name=${distName}  list_name=allowUnsuppBcOrBcs   elements=${param_list}


Add NRREL
    [Arguments]    ${pcell}   ${scell}
    ${distName_NRCELL}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRREL}=  Set variable  ${distName_NRCELL[${pcell}-1]}/NRREL-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRREL
    ...           dist_name=${distName_NRREL}
    ...           version=NRBTSCL23R4_2312_101
    FOR    ${p_name}                        ${value}    IN
    ...    cellIndividualSsbRsrpOffset                       0dB
    ...    cellIndividualSsbRsrqOffset                       0dB
    ...    gNbId                                             1
    ...    gNbIdLength                                       22
    ...    handoverAllowedSA                                 allowed
    ...    handoverAllowedSARedCap                           forbidden
    ...    isRplCellForPSCell                                false
    ...    lcrId                                             ${scell}
    ...    nrDcAllowed                                       false
    ...    removeNotAllowed                                  false
    ...    sCellAdditionMethod                               blind
    ...    sCellOperationalMode                              dlOnly
        Set Element   dist_name=${distName_NRREL}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRREL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRREL}   list_name=gnbPlmn   elements=${gnbPlmn_item}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRREL}=  Set variable  ${distName_NRCELL[${scell}-1]}/NRREL-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRREL
    ...           dist_name=${distName_NRREL}
    ...           version=NRBTSCL23R4_2312_101
    FOR    ${p_name}                        ${value}    IN
    ...    cellIndividualSsbRsrpOffset                       0dB
    ...    cellIndividualSsbRsrqOffset                       0dB
    ...    gNbId                                             1
    ...    gNbIdLength                                       22
    ...    handoverAllowedSA                                 allowed
    ...    handoverAllowedSARedCap                           forbidden
    ...    isRplCellForPSCell                                false
    ...    lcrId                                             ${pcell}
    ...    nrDcAllowed                                       false
    ...    removeNotAllowed                                  false
    ...    sCellAdditionMethod                               blind
    ...    sCellOperationalMode                              dlOnly
        Set Element   dist_name=${distName_NRREL}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRREL}  list_name=gnbPlmn
    ${gnbPlmn_item}=  create dictionary
    ...    mcc              311
    ...    mnc              489
    ...    mncLength        3
    scf.add_item_to_list    dist_name=${distName_NRREL}   list_name=gnbPlmn   elements=${gnbPlmn_item}


Activate CA in NRDU
    [Arguments]    ${ca_list}
    ${distName_NRDU}=    Get distNames from Local SCF File    scf_path=${original_gnb_scf}    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDU-[0-9]+
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.modify_scf_element    dist_name=${distName_NRDU[0]}    list_name=carrierAggregationSupportList   value=${ca_list}
    IF    'CA FDD' in '${SUITE_NAME}'
    ...    Set Element    dist_name=${distName_NRDU[0]}    p_name=flexibleCAMode    value=ConfigurationIndependent



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
