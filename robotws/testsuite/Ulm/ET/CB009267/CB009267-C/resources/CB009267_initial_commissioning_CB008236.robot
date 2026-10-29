*** Settings ***
Documentation    Commissioning keywords for CB009267: 5G_PM_1077 specific changes



*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Activate CB008236
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                                   ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                           caConfigurationSupport               4CCDL_2CCUL
    ...    ${distName_NRBTS[0]}                           sCellActivationMethod                bufferBased
    ...    ${distName_NRBTS[0]}                           maxNumScellsDl                       2
    ...    ${distName_NRBTS[0]}                           maxNumScellsUl                       2
    ...    ${distName_NRBTS[0]}                           actLteNrDss                          false
    ...    ${distName_NRBTS[0]}                           actFdmScheduling                     true
    ...    ${distName_NRBTS[0]}                           actMultipleDedicatedBWPs             false
    ...    ${distName_NRBTS[0]}                           actHighestEstNrTputBcSel             true
    ...    ${distName_NRCELL[1-1]}/NRREL-1                sCellOperationalMode                 dlOnly
    ...    ${distName_NRCELL[1-1]}/NRREL-2                sCellOperationalMode                 dlOnly
    ...    ${distName_NRCELL[3-1]}/NRREL-1                sCellOperationalMode                 dlOnly
    ...    ${distName_NRCELL[4-1]}/NRREL-1                sCellOperationalMode                 dlOnly
        Set Element   dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
