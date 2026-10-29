*** Settings ***
Documentation    Commissioning keywords for CB013715

...               Version   Date          Author                                   Notes
...               0.1       03-20-2025    christophe.samson@nokia.com              Creation
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library      resources/TARF/python/Dev_lib.py
Library      ./resources/python/CB013715_tools.py

Resource     resources/TARF/robot/GenericSuiteTest.robot
Resource     resources/TARF/robot/ute-wtssim-ue-Keywords.robot
Resource     resources/TARF/robot/scf-common-keywords.robot
Resource     resources/TARF/robot/Scenario-Common-Keywords.robot
Resource     ./CB013715-FDD_initial_commissioning.robot

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

#-----------For SCF.xml Changes For DSS-----------------------------------------------------------------------------------------------[150 characters]
Modify scf.xml for 2FDD Setup with Cell1 FDD Dss 10MHz
    [Arguments]       ${testParam}    ${gnb_scf}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${type0SearchSpaceConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell_wa.type0SearchSpaceConfigurationIndex}
    ${type0CoresetConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 drbInactivityTimerSA                 7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                dmrsTypeAPosition                    pos3
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  71
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0CoresetConfigurationIndex       ${type0CoresetConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0SearchSpaceConfigurationIndex   ${type0SearchSpaceConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                msg1FrequencyStart                   ${testParam.scfFile.nrcell.msg1FrequencyStart}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Set List Value    ${distName_NRCELL[${fdd_cell_1}-1]}     fPdcchMonOccsnPo                 0  # required
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    # update sibPeriodicity with rf64
    ${nrSysInfoProfileDN}=     scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=nrSysInfoProfileDN
    Modify sibSchedulingList    dist_name=${nrSysInfoProfileDN}    sibPeriodicity=rf64
    Modify dynamic pdcch parameters for FDD DSS 10MHz bandwidth    gnb_scf=${gnb_scf}

Modify dynamic pdcch parameters for FDD DSS 10MHz bandwidth
    [Arguments]    ${gnb_id}=${0}    ${gnb_scf}=${None}
    ${distName_NRBTS}=      Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...   regex=MRBTS-[0-9]+/NRBTS-[0-9]+

    ${object_BWP_PROFILE-1_exists}=    scf.is object in scf    dist_name=NRBTS-2/BWP_PROFILE-1
    Run keyword if    not ${object_BWP_PROFILE-1_exists}    Update BWP_PROFILE objects for FDD DSS 10MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/NRCELL-1    gnb_id=${gnb_id}
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-11    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

# ABIP case , FDD pooling activated
Update BWP_PROFILE objects for FDD DSS 10MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-4    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-1
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl80  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=47  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=slotOffset

    scf.modify scf element    value=6    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=periodicity
    scf.modify scf element    value=3  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=slotOffset

    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl40  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity
    scf.modify scf element    value=27  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=slotOffset

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-33    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-11
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl80  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=47  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=slotOffset

    scf.modify scf element    value=6    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=periodicity
    scf.modify scf element    value=3  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=slotOffset

    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl40  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity
    scf.modify scf element    value=27  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=slotOffset

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=nonInterleaved    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=cceToRegMapping
    scf.modify scf element    value=4    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=coresetId
    scf.modify scf element    value=0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=cRbStart
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=duration
    scf.modify scf element    value=none    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=interleaverSize
    scf.modify scf element    value=n6    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=regBundleSize
    scf.modify scf element    value=48    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size

    Set List with Log   dist_name=${distName_PDCCH_CONFIG_DEDICATED}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                7
    ...      searchSpaceType              Type3
    ...      slotOffset                   3
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    ${searchSpaceDedicated_item2}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     3
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                8
    ...      searchSpaceType              Type3
    ...      slotOffset                   6
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}
    ${searchSpaceDedicated_item3}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                9
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   3
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item3}
    ${searchSpaceDedicated_item4}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     3
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                10
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   6
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item4}
    ${searchSpaceDedicated_item5}=  Create Dictionary
    ...      coresetId                    4
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     2
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                11
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   4
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item5}
    ${searchSpaceDedicated_item6}=  Create Dictionary
    ...      coresetId                    4
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     4
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                12
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   9
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item6}

# for NSA Only
Modify scf.xml for 2FDD Setup with Cell1 cellDepType=NSA FDD Dss 10MHz
    [Arguments]       ${testParam}    ${gnb_scf}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${type0SearchSpaceConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell_wa.type0SearchSpaceConfigurationIndex}
    ${type0CoresetConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 drbInactivityTimerSA                 7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    # when cellDepType=NSA
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                cellDepType                          NSA
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actSib1ForNsaCell                    false
    # ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actSib1ForNsaCell                    true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actFullPwrMode                       false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actNonVoNRGbrService                 false
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actGBRAdmissionControl               off
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actRrcReconfProcessingDelay          false
    # end when cellDepType=NSA
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                dmrsTypeAPosition                    pos3
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  71
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0CoresetConfigurationIndex       ${type0CoresetConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0SearchSpaceConfigurationIndex   ${type0SearchSpaceConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                msg1FrequencyStart                   ${testParam.scfFile.nrcell.msg1FrequencyStart}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Set List Value    ${distName_NRCELL[${fdd_cell_1}-1]}     fPdcchMonOccsnPo                 0  # required
    Remove Object with Log    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRPLMNSET_SA-1
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Modify dynamic pdcch parameters for cellDepType=NSA FDD DSS 10MHz bandwidth    gnb_scf=${gnb_scf}

Modify dynamic pdcch parameters for cellDepType=NSA FDD DSS 10MHz bandwidth
    [Arguments]    ${gnb_id}=${0}    ${gnb_scf}=${None}
    ${distName_NRBTS}=      Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...   regex=MRBTS-[0-9]+/NRBTS-[0-9]+

    ${object_BWP_PROFILE-6_exists}=    scf.is object in scf    dist_name=NRBTS-2/BWP_PROFILE-6
    Run keyword if  not ${object_BWP_PROFILE-6_exists}  Update BWP_PROFILE objects for cellDepType=NSA FDD DSS 10MHz bandwidth    gnb_id=${gnb_id}
    ...                                                                                                                           gnb_scf=${gnb_scf}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/NRCELL-${fdd_cell_1}    gnb_id=${gnb_id}
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-6    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-66    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

# ABIP case , FDD pooling activated
Update BWP_PROFILE objects for cellDepType=NSA FDD DSS 10MHz bandwidth
    [Arguments]    ${gnb_id}=${0}    ${gnb_scf}=${None}

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-4    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-6
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG}=    Set variable    ${target_mo_dist_name}/PDCCH-1
    scf.modify_scf_element    dist_name=${distName_PDCCH_CONFIG}   p_name=dciDedicatedAggregationLevel       value=AL2
    scf.modify_scf_element    dist_name=${distName_PDCCH_CONFIG}   p_name=dciDedicatedAggregationLevelHR     value=AL2
    scf.modify_scf_element    dist_name=${distName_PDCCH_CONFIG}   p_name=dciRaCompletionAggregationLevel    value=AL2
    scf.modify_scf_element    dist_name=${distName_PDCCH_CONFIG}   p_name=dciRaMsg2AggregationLevel          value=AL2

    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    Remove List with Log   dist_name=${distName_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon
    ${bwpDN_init}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    list_name=cellBwpList    p_name=bwpDN    index=0
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbStartUl    value=crb0
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbSizeUl     value=n52
    # csamson : comment 2 below lines to force Coreset0 for InitBWP!! to have NSA call OK - PRECHECK en cours...
    # scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthDl    p_name=cRbStartDl    value=crb0
    # scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthDl    p_name=cRbSizeDl     value=n52

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-33    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-66
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG}=    Set variable    ${target_mo_dist_name}/PDCCH-1
    scf.modify_scf_element    dist_name=${distName_PDCCH_CONFIG}   p_name=dciDedicatedAggregationLevel       value=AL2
    scf.modify_scf_element    dist_name=${distName_PDCCH_CONFIG}   p_name=dciDedicatedAggregationLevelHR     value=AL2
    scf.modify_scf_element    dist_name=${distName_PDCCH_CONFIG}   p_name=dciRaCompletionAggregationLevel    value=AL2
    scf.modify_scf_element    dist_name=${distName_PDCCH_CONFIG}   p_name=dciRaMsg2AggregationLevel          value=AL2

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1

    Set List with Log   dist_name=${distName_PDCCH_CONFIG_COMMON}   list_name=coresetCommon
    ${coresetCommon_item1}=  Create Dictionary
    ...      cceToRegMapping              nonInterleaved
    ...      coresetId                    4
    ...      cRbStart                     0
    ...      duration                     1
    ...      interleaverSize              none
    ...      regBundleSize                n6
    ...      size                         48
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_COMMON}  list_name=coresetCommon  elements=${coresetCommon_item1}

    Set List with Log   dist_name=${distName_PDCCH_CONFIG_COMMON}   list_name=searchSpaceCommon
    ${searchSpaceCommon_item1}=  Create Dictionary
    ...      coresetId                    4
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     6
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                1
    ...      searchSpaceType              Type1
    ...      slotOffset                   3
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_COMMON}  list_name=searchSpaceCommon  elements=${searchSpaceCommon_item1}

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    # scf.modify scf element    value=nonInterleaved    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    # ...    p_name=cceToRegMapping
    # scf.modify scf element    value=4    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    # ...    p_name=coresetId
    # scf.modify scf element    value=0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    # ...    p_name=cRbStart
    # scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    # ...    p_name=duration
    # scf.modify scf element    value=none    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    # ...    p_name=interleaverSize
    # scf.modify scf element    value=n6    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    # ...    p_name=regBundleSize
    # scf.modify scf element    value=48    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    # ...    p_name=size

    Set List with Log   dist_name=${distName_PDCCH_CONFIG_DEDICATED}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                    4
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n0
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                2
    ...      searchSpaceType              Type3
    ...      slotOffset                   0
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    ${searchSpaceDedicated_item2}=  Create Dictionary
    ...      coresetId                    4
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl1
    ...      searchSpaceId                3
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   0
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}


Modify scf.xml for 2FDD Setup with Cell1 FDD Dss 15MHz
    [Arguments]       ${testParam}    ${gnb_scf}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${type0SearchSpaceConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell_wa.type0SearchSpaceConfigurationIndex}
    ${type0CoresetConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 drbInactivityTimerSA                 7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                dmrsTypeAPosition                    pos3
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  71
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0CoresetConfigurationIndex       ${type0CoresetConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0SearchSpaceConfigurationIndex   ${type0SearchSpaceConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                msg1FrequencyStart                   ${testParam.scfFile.nrcell.msg1FrequencyStart}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Set List Value    ${distName_NRCELL[${fdd_cell_1}-1]}     fPdcchMonOccsnPo                 0  # required
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    # update sibPeriodicity with rf64
    ${nrSysInfoProfileDN}=     scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=nrSysInfoProfileDN
    Modify sibSchedulingList    dist_name=${nrSysInfoProfileDN}    sibPeriodicity=rf64
    Modify dynamic pdcch parameters for FDD DSS 15MHz bandwidth    gnb_scf=${gnb_scf}

Modify dynamic pdcch parameters for FDD DSS 15MHz bandwidth
    [Arguments]    ${gnb_id}=${0}    ${gnb_scf}=${None}
    ${distName_NRBTS}=      Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...   regex=MRBTS-[0-9]+/NRBTS-[0-9]+

    ${object_BWP_PROFILE-3_exists}=    scf.is object in scf    dist_name=NRBTS-2/BWP_PROFILE-3
    Run keyword if    not ${object_BWP_PROFILE-3_exists}    Update BWP_PROFILE objects for FDD DSS 15MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/NRCELL-1    gnb_id=${gnb_id}
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-3    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-22    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

# to update with FDD pooling activated (ABIP case)
Update BWP_PROFILE objects for FDD DSS 15MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-4    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-3
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl80  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=47  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=slotOffset

    scf.modify scf element    value=6    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=periodicity
    scf.modify scf element    value=3  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=slotOffset

    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl40  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity
    scf.modify scf element    value=27  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=slotOffset

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-33    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-22
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl80  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=47  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=slotOffset

    scf.modify scf element    value=6    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=periodicity
    scf.modify scf element    value=3  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=slotOffset

    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl40  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity
    scf.modify scf element    value=27  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=slotOffset

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=nonInterleaved    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=cceToRegMapping
    scf.modify scf element    value=4    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=coresetId
    scf.modify scf element    value=0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=cRbStart
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=duration
    scf.modify scf element    value=none    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=interleaverSize
    scf.modify scf element    value=n6    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=regBundleSize
    scf.modify scf element    value=78    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size

    Set List with Log   dist_name=${distName_PDCCH_CONFIG_DEDICATED}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n2
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                7
    ...      searchSpaceType              Type3
    ...      slotOffset                   3
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    ${searchSpaceDedicated_item2}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     3
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n2
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                8
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   6
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}
    ${searchSpaceDedicated_item3}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n2
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                9
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   3
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item3}
    ${searchSpaceDedicated_item4}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     3
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n3
    ...      numOfPdcchCandidatesInAL4    n3
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                10
    ...      searchSpaceType              Type3
    ...      slotOffset                   6
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item4}
    ${searchSpaceDedicated_item5}=  Create Dictionary
    ...      coresetId                    4
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     2
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n3
    ...      numOfPdcchCandidatesInAL4    n3
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                11
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   4
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item5}
    ${searchSpaceDedicated_item6}=  Create Dictionary
    ...      coresetId                    4
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     4
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n3
    ...      numOfPdcchCandidatesInAL4    n3
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                12
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   9
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item6}

Modify scf.xml for 2FDD Setup with Cell1 FDD Dss 20MHz
    [Arguments]      ${testParam}    ${gnb_scf}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${type0SearchSpaceConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell_wa.type0SearchSpaceConfigurationIndex}
    ${type0CoresetConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 drbInactivityTimerSA                 7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                dmrsTypeAPosition                    pos3
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  71
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0CoresetConfigurationIndex       ${type0CoresetConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0SearchSpaceConfigurationIndex   ${type0SearchSpaceConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                msg1FrequencyStart                   ${testParam.scfFile.nrcell.msg1FrequencyStart}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Set List Value    ${distName_NRCELL[${fdd_cell_1}-1]}     fPdcchMonOccsnPo                 0  # required
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    # update sibPeriodicity with rf64
    ${nrSysInfoProfileDN}=     scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=nrSysInfoProfileDN
    Modify sibSchedulingList    dist_name=${nrSysInfoProfileDN}    sibPeriodicity=rf64
    Modify dynamic pdcch parameters for FDD DSS 20MHz bandwidth    gnb_scf=${gnb_scf}

Modify scf.xml for 2FDD Setup with Cell2 FDD Dss 20MHz
    [Arguments]      ${testParam}    ${gnb_scf}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${type0SearchSpaceConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell_wa.type0SearchSpaceConfigurationIndex}
    ${type0CoresetConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 drbInactivityTimerSA                 7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                dmrsTypeAPosition                    pos3
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  71
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                type0CoresetConfigurationIndex       ${type0CoresetConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                type0SearchSpaceConfigurationIndex   ${type0SearchSpaceConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                msg1FrequencyStart                   ${testParam.scfFile.nrcell.msg1FrequencyStart}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    # update sibPeriodicity with rf64
    ${nrSysInfoProfileDN}=     scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=nrSysInfoProfileDN
    Modify sibSchedulingList    dist_name=${nrSysInfoProfileDN}    sibPeriodicity=rf64
    Modify dynamic pdcch parameters for FDD DSS 20MHz bandwidth For Cell2    gnb_scf=${gnb_scf}

Modify scf.xml for 2FDD Setup with Cell3 FDD Dss 20MHz
    [Arguments]      ${testParam}    ${gnb_scf}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${type0SearchSpaceConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell_wa.type0SearchSpaceConfigurationIndex}
    ${type0CoresetConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 drbInactivityTimerSA                 7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_3}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                dmrsTypeAPosition                    pos3
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  71
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0CoresetConfigurationIndex       ${type0CoresetConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0SearchSpaceConfigurationIndex   ${type0SearchSpaceConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                msg1FrequencyStart                   ${testParam.scfFile.nrcell.msg1FrequencyStart}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    # update sibPeriodicity with rf64
    ${nrSysInfoProfileDN}=     scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=nrSysInfoProfileDN
    Modify sibSchedulingList    dist_name=${nrSysInfoProfileDN}    sibPeriodicity=rf64
    Modify dynamic pdcch parameters for FDD DSS 20MHz bandwidth    gnb_scf=${gnb_scf}

Modify scf.xml for 2TDD+2FDD Setup with Cell3 FDD Dss 20MHz
    [Arguments]      ${testParam}    ${gnb_scf}
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    ${type0SearchSpaceConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell_wa.type0SearchSpaceConfigurationIndex}
    ${type0CoresetConfigurationIndex_value}=    set variable     ${testParam.scfFile.nrcell.type0CoresetConfigurationIndex}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 drbInactivityTimerSA                 7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                dmrsTypeAPosition                    pos3
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  71
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0CoresetConfigurationIndex       ${type0CoresetConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                type0SearchSpaceConfigurationIndex   ${type0SearchSpaceConfigurationIndex_value}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                msg1FrequencyStart                   ${testParam.scfFile.nrcell.msg1FrequencyStart}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                numOfPagingFrames                    quaterT    # required
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                pagingOffset                         2    # required
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                numPagingOccsnPagingFrame            one    # required
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Set List Value    ${distName_NRCELL[${fdd_cell_1}-1]}     fPdcchMonOccsnPo                 0  # required
    # update sibPeriodicity with rf64 and siWindowLength with s160
    # sibPeriodicity with rf8 and siWindowLength with s40
    ${nrSysInfoProfileDN}=     scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    p_name=nrSysInfoProfileDN
    Modify sibSchedulingList    dist_name=${nrSysInfoProfileDN}    sibPeriodicity=rf64
    Set Element     dist_name=${nrSysInfoProfileDN}    p_name=siWindowLength    value=s160
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Modify dynamic pdcch parameters for FDD DSS 20MHz bandwidth    gnb_scf=${gnb_scf}

Modify sibSchedulingList_TO_REMOVE
    [Arguments]    ${dist_name}=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    ...            ${sibPeriodicity}=rf8
    ${list_name}                        Set Variable                    sibSchedulingList
    Set List                            dist_name=${dist_name}          list_name=${list_name}

    FOR    ${sibtype}    IN RANGE    2    9
        ${sibSchedulingList_dict}       Create dictionary               sibBroadcastStatus                broadcasting
        ...                                                             sibPeriodicity                    ${sibPeriodicity}
        ...                                                             sibScope                          cellSpecific
        ...                                                             sibType                           sibType${sibtype}
        scf.add_item_to_list            dist_name=${dist_name}          list_name=${list_name}            elements=${sibSchedulingList_dict}
    END

    ${sibSchedulingList_dict}           Create dictionary               sibBroadcastStatus                broadcasting
    ...                                                                 sibPeriodicity                    ${sibPeriodicity}
    ...                                                                 sibScope                          cellSpecific
    ...                                                                 sibType                           sibType8
    scf.add_item_to_list                dist_name=${dist_name}          list_name=${list_name}            elements=${sibSchedulingList_dict}

Modify dynamic pdcch parameters for FDD DSS 20MHz bandwidth
    [Arguments]    ${gnb_id}=${0}    ${gnb_scf}=${None}
    ${distName_NRBTS}=      Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...   regex=MRBTS-[0-9]+/NRBTS-[0-9]+

    ${object_BWP_PROFILE-5_exists}=    scf.is object in scf    dist_name=NRBTS-2/BWP_PROFILE-5
    Run keyword if    not ${object_BWP_PROFILE-5_exists}    Update BWP_PROFILE objects for FDD DSS 20MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/NRCELL-${fdd_cell_1}    gnb_id=${gnb_id}
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-5    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-55    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

Modify dynamic pdcch parameters for FDD DSS 20MHz bandwidth For Cell2
    [Arguments]    ${gnb_id}=${0}    ${gnb_scf}=${None}
    ${distName_NRBTS}=      Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...   regex=MRBTS-[0-9]+/NRBTS-[0-9]+

    ${object_BWP_PROFILE-5_exists}=    scf.is object in scf    dist_name=NRBTS-2/BWP_PROFILE-5
    Run keyword if    not ${object_BWP_PROFILE-5_exists}    Update BWP_PROFILE objects for FDD DSS 20MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/NRCELL-2    gnb_id=${gnb_id}
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-5    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-55    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

Modify dynamic pdcch parameters for FDD DSS 20MHz bandwidth For Cell3
    [Arguments]    ${gnb_id}=${0}    ${gnb_scf}=${None}
    ${distName_NRBTS}=      Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${gnb_scf}
    ...   regex=MRBTS-[0-9]+/NRBTS-[0-9]+

    ${object_BWP_PROFILE-5_exists}=    scf.is object in scf    dist_name=NRBTS-2/BWP_PROFILE-5
    Run keyword if    not ${object_BWP_PROFILE-5_exists}    Update BWP_PROFILE objects for FDD DSS 20MHz bandwidth    gnb_id=${gnb_id}

    ${distName_NRCELL}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/NRCELL-3    gnb_id=${gnb_id}
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-5    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=0
    scf.modify scf element    value=0    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=0
    scf.modify scf element    value=${distName_NRBTS[0]}/BWP_PROFILE-55    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList
    ...    p_name=bwpDN    index=1
    scf.modify scf element    value=1    dist_name=${distName_NRCELL[0]}    list_name=cellBwpList    p_name=cellBwpId    index=1

Update BWP_PROFILE objects for FDD DSS 20MHz bandwidth
    [Arguments]    ${gnb_id}=${0}
    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-4    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-5
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl80  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=47  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=slotOffset

    scf.modify scf element    value=6    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=periodicity
    scf.modify scf element    value=3  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=slotOffset

    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl40  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity
    scf.modify scf element    value=27  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=slotOffset

    ${distName_BWP_PROFILE}=    Scenario-Common-Keywords.Get distNames from gNB SCF    regex=NRBTS-\\d+/BWP_PROFILE-33    gnb_id=${gnb_id}
    ${target_mo_dist_name}=    Replace string using regexp    string=${distName_BWP_PROFILE[0]}    pattern=BWP_PROFILE-\\d+
    ...    replace_with=BWP_PROFILE-55
    scf.clone mo with descendant mos    source_mo_dist_name=${distName_BWP_PROFILE[0]}    target_mo_dist_name=${target_mo_dist_name}

    ${distName_PDCCH_CONFIG_COMMON}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl80  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=periodicity
    scf.modify scf element    value=47  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=0
    ...    p_name=slotOffset

    scf.modify scf element    value=6    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl10  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=periodicity
    scf.modify scf element    value=3  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=1
    ...    p_name=slotOffset

    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=duration
    scf.modify scf element    value=symbol_2  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=monitoringSymbolWithinSlot
    scf.modify scf element    value=sl40  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=periodicity
    scf.modify scf element    value=27  dist_name=${distName_PDCCH_CONFIG_COMMON}    list_name=searchSpaceCommon    index=2
    ...    p_name=slotOffset

    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${target_mo_dist_name}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    scf.modify scf element    value=nonInterleaved    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=cceToRegMapping
    scf.modify scf element    value=4    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=coresetId
    scf.modify scf element    value=0    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=cRbStart
    scf.modify scf element    value=1    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=duration
    scf.modify scf element    value=none    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=interleaverSize
    scf.modify scf element    value=n6    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=regBundleSize
    scf.modify scf element    value=96    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size

    Set List with Log   dist_name=${distName_PDCCH_CONFIG_DEDICATED}   list_name=searchSpaceDedicated
    ${searchSpaceDedicated_item1}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n2
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                7
    ...      searchSpaceType              Type3
    ...      slotOffset                   3
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item1}
    ${searchSpaceDedicated_item2}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-0-And-1-0
    ...      duration                     3
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n4
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                8
    ...      searchSpaceType              Type3
    ...      slotOffset                   6
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item2}
    ${searchSpaceDedicated_item3}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     1
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n2
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                9
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   3
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item3}
    ${searchSpaceDedicated_item4}=  Create Dictionary
    ...      coresetId                    0
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     3
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n2
    ...      numOfPdcchCandidatesInAL2    n2
    ...      numOfPdcchCandidatesInAL4    n2
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                10
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   6
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item4}
    ${searchSpaceDedicated_item5}=  Create Dictionary
    ...      coresetId                    4
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     2
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n4
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                11
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   4
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item5}
    ${searchSpaceDedicated_item6}=  Create Dictionary
    ...      coresetId                    4
    ...      dciFormat                    formats0-1-And-1-1
    ...      duration                     4
    ...      monitoringSymbolWithinSlot   symbol_2
    ...      numOfPdcchCandidatesInAL1    n4
    ...      numOfPdcchCandidatesInAL2    n4
    ...      numOfPdcchCandidatesInAL4    n4
    ...      numOfPdcchCandidatesInAL8    n0
    ...      numOfPdcchCandidatesInAL16   n0
    ...      periodicity                  sl10
    ...      searchSpaceId                12
    ...      searchSpaceType              UE-Specific
    ...      slotOffset                   9
    Add Dict to List  dist_name=${distName_PDCCH_CONFIG_DEDICATED}  list_name=searchSpaceDedicated  elements=${searchSpaceDedicated_item6}

#-----------For SCF.xml Changes Prb Blanking case------------------------------------------------------------------------------------[150 characters]
Get FDD Channel Bandwidth With PRB
    [Documentation]   Description: return PRBs from channal bandwidth
    ...              Bandwidth    5 (25), 10 (52), 15 (79), 20 (106), 25 (133), 30 (160), 35 (188)
    [Arguments]    ${chbw}
    ${chbw_prb} =    run keyword if    '${chbw}' == '35MHz'    set variable    ${188}
    ...    ELSE IF    '${chbw}' == '25MHz'    set variable    ${133}
    ...    ELSE IF    '${chbw}' == '20MHz'    set variable    ${106}
    ...    ELSE IF    '${chbw}' == '15MHz'    set variable    ${79}
    ...    ELSE IF    '${chbw}' == '10MHz'    set variable    ${52}
    ...    ELSE IF    '${chbw}' == '5MHz'    set variable    ${25}
    ...    ELSE       BuiltIn.Log    Error: channel bandwidth is larger than 100M, please confirm form RRC message/SIB1    level=ERROR
    nps_trf_tools.log_to_console_with_time_prefix    Get FDD Channel ${chbw} Bandwidth with PRB: ${chbw_prb}    level=INFO
    [Return]    ${chbw_prb}

Initial commissioning for Cell1 with PRB Blanking
    [Arguments]      ${testParam}    ${gnb_scf}

    return from Keyword if     "${w_actPRBBlanking}" == 'False'
    ${actPRBBlanking}=    set variable    ${parameters_PrbBlanking['actPRBBlanking']}
    ${nbrOfBlankedPRBsLowEdgeDL}=    set variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeDL']}
    ${nbrOfBlankedPRBsLowEdgeUL}=    set variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeUL']}
    ${nbrOfBlankedPRBsHighEdgeDL}=    set variable    ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeDL']}
    ${nbrOfBlankedPRBsHighEdgeUL}=    set variable    ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeUL']}
    ${type0CoresetConfigurationIndex}=       set variable    ${parameters_PrbBlanking['type0CoresetConfigurationIndex']}
    ${aggregationLevel}=       set variable    ${parameters_PrbBlanking['aggregationLevel']}
    ${aggregationLevel}=       set variable    ${parameters_PrbBlanking['aggregationLevel']}
    ${msg1FrequencyStart}=       set variable    ${parameters_PrbBlanking['msg1FrequencyStart']}
    nps_trf_tools.log_to_console_with_time_prefix   [Cell${fdd_cell_1}] actPRBBlanking=${actPRBBlanking}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   [Cell${fdd_cell_1}] nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   [Cell${fdd_cell_1}] nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   [Cell${fdd_cell_1}] nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   [Cell${fdd_cell_1}] nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   [Cell${fdd_cell_1}] aggregationLevel=${aggregationLevel}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   [Cell${fdd_cell_1}] type0CoresetConfigurationIndex=${type0CoresetConfigurationIndex}  level=INFO
    nps_trf_tools.log_to_console_with_time_prefix   [Cell${fdd_cell_1}] msg1FrequencyStart=${msg1FrequencyStart}    level=INFO

    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

    # Apply preconditions from test description for first FDD cell
    FOR    ${dist_name}                                       ${p_name}                      ${value}         IN
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      actPRBBlanking                 true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      nbrOfBlankedPRBsLowEdgeUL      ${nbrOfBlankedPRBsLowEdgeUL}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      nbrOfBlankedPRBsLowEdgeDL      ${nbrOfBlankedPRBsLowEdgeDL}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      nbrOfBlankedPRBsHighEdgeDL     ${nbrOfBlankedPRBsHighEdgeDL}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      nbrOfBlankedPRBsHighEdgeUL     ${nbrOfBlankedPRBsHighEdgeUL}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      type0CoresetConfigurationIndex  ${type0CoresetConfigurationIndex}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      aggregationLevel               ${aggregationLevel}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      msg1FrequencyStart             ${msg1FrequencyStart}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    ${chBwUl}	 scf.get_value_from_scf   p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1
    ${bwPrb}=    Get FDD Channel Bandwidth With PRB    chbw=${chBwUl}
    ${cRbStartUl}=     catenate    SEPARATOR=    crb       ${nbrOfBlankedPRBsLowEdgeUL}
    ${cRbSizeUl}=     Evaluate    ${bwPrb} - ${nbrOfBlankedPRBsLowEdgeUL} - ${nbrOfBlankedPRBsHighEdgeUL}
    ${cRbSizeUl}=     catenate    SEPARATOR=    n       ${cRbSizeUl}
    nps_trf_tools.log_to_console_with_time_prefix    Initial cRbStartUl: ${cRbStartUl}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    Initial cRbSizeUl: ${cRbSizeUl}    level=INFO

    ${bwpDN_init}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    list_name=cellBwpList    p_name=bwpDN    index=0
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbStartUl    value=${cRbStartUl}
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbSizeUl     value=${cRbSizeUl}
    # scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbStartUl    value=crb4
    # scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbSizeUl     value=n48

    ${cRbStart}=    CB013715_tools.calculate_coreset4_cRbStart    nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}
    ${size}=        CB013715_tools.calculate_coreset4_size        bwPrb=${bwPrb}
    ...                                                           nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}
    ...                                                           nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL}
    nps_trf_tools.log_to_console_with_time_prefix    coresetId_4 cRbStart: ${cRbStart}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    coresetId_4 size: ${size}    level=INFO

    ${bwpDN_dedic}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    list_name=cellBwpList    p_name=bwpDN    index=1
    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${bwpDN_dedic}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    # scf.modify scf element    value=6    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    scf.modify scf element    value=${cRbStart}    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=cRbStart
    # scf.modify scf element    value=42    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    scf.modify scf element    value=${size}    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size

Initial commissioning for Cell1 with PRB Blanking for cellDepType=NSA
    [Arguments]      ${testParam}    ${gnb_scf}

    return from Keyword if     "${w_actPRBBlanking}" == 'False'
    ${actPRBBlanking}=    set variable    ${parameters_PrbBlanking['actPRBBlanking']}
    ${nbrOfBlankedPRBsLowEdgeDL}=    set variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeDL']}
    ${nbrOfBlankedPRBsLowEdgeUL}=    set variable     ${parameters_PrbBlanking['nbrOfBlankedPRBsLowEdgeUL']}
    ${nbrOfBlankedPRBsHighEdgeDL}=    set variable    ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeDL']}
    ${nbrOfBlankedPRBsHighEdgeUL}=    set variable    ${parameters_PrbBlanking['nbrOfBlankedPRBsHighEdgeUL']}
    ${type0CoresetConfigurationIndex}=       set variable    ${parameters_PrbBlanking['type0CoresetConfigurationIndex']}
    ${aggregationLevel}=       set variable    ${parameters_PrbBlanking['aggregationLevel']}
    ${aggregationLevel}=       set variable    ${parameters_PrbBlanking['aggregationLevel']}
    ${msg1FrequencyStart}=       set variable    ${parameters_PrbBlanking['msg1FrequencyStart']}
    nps_trf_tools.log_to_console_with_time_prefix    [Cell${fdd_cell_1}] actPRBBlanking=${actPRBBlanking}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell${fdd_cell_1}] nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell${fdd_cell_1}] nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell${fdd_cell_1}] nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell${fdd_cell_1}] nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell${fdd_cell_1}] aggregationLevel=${aggregationLevel}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell${fdd_cell_1}] type0CoresetConfigurationIndex=${type0CoresetConfigurationIndex}  level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell${fdd_cell_1}] msg1FrequencyStart=${msg1FrequencyStart}    level=INFO

    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

    # Apply preconditions from test description for first FDD cell
    FOR    ${dist_name}                                       ${p_name}                      ${value}         IN
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      actPRBBlanking                 true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      nbrOfBlankedPRBsLowEdgeUL      ${nbrOfBlankedPRBsLowEdgeUL}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      nbrOfBlankedPRBsLowEdgeDL      ${nbrOfBlankedPRBsLowEdgeDL}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      nbrOfBlankedPRBsHighEdgeDL     ${nbrOfBlankedPRBsHighEdgeDL}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      nbrOfBlankedPRBsHighEdgeUL     ${nbrOfBlankedPRBsHighEdgeUL}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      type0CoresetConfigurationIndex  ${type0CoresetConfigurationIndex}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      aggregationLevel               ${aggregationLevel}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}      msg1FrequencyStart             ${msg1FrequencyStart}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    ${chBwUl}	 scf.get_value_from_scf   p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1
    ${bwPrb}=    Get FDD Channel Bandwidth With PRB    chbw=${chBwUl}
    ${cRbStartUl}=     catenate    SEPARATOR=    crb       ${nbrOfBlankedPRBsLowEdgeUL}
    ${cRbSizeUl}=     Evaluate    ${bwPrb} - ${nbrOfBlankedPRBsLowEdgeUL} - ${nbrOfBlankedPRBsHighEdgeUL}
    ${cRbSizeUl}=     catenate    SEPARATOR=    n       ${cRbSizeUl}
    ${cRbStartDl}=     catenate    SEPARATOR=    crb       ${nbrOfBlankedPRBsLowEdgeDL}
    ${cRbSizeDl}=     Evaluate    ${bwPrb} - ${nbrOfBlankedPRBsLowEdgeDL} - ${nbrOfBlankedPRBsHighEdgeDL}
    ${cRbSizeDl}=     catenate    SEPARATOR=    n       ${cRbSizeDl}
    nps_trf_tools.log_to_console_with_time_prefix    Initial cRbStartUl: ${cRbStartUl}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    Initial cRbSizeUl: ${cRbSizeUl}    level=INFO
    # csamson : comment 2 below lines to force Coreset0 for InitBWP!! to have NSA call OK - PRECHECK en cours...
    # nps_trf_tools.log_to_console_with_time_prefix    Initial cRbStartDl: ${cRbStartDl}    level=INFO
    # nps_trf_tools.log_to_console_with_time_prefix    Initial cRbSizeDl: ${cRbSizeDl}    level=INFO

    ${bwpDN_init}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    list_name=cellBwpList    p_name=bwpDN    index=0
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbStartUl    value=${cRbStartUl}
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbSizeUl     value=${cRbSizeUl}
    # csamson : comment 2 below lines to force Coreset0 for InitBWP!! to have NSA call OK - PRECHECK en cours...
    # scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthDl    p_name=cRbStartDl    value=${cRbStartDl}
    # scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthDl    p_name=cRbSizeDl     value=${cRbSizeDl}

    ${cRbStart}=    CB013715_tools.calculate_coreset4_cRbStart    nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}
    ${size}=        CB013715_tools.calculate_coreset4_size        bwPrb=${bwPrb}
    ...                                                           nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}
    ...                                                           nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL}
    nps_trf_tools.log_to_console_with_time_prefix    coresetId_4 cRbStart: ${cRbStart}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    coresetId_4 size: ${size}    level=INFO

    ${bwpDN_dedic}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_1}-1]}    list_name=cellBwpList    p_name=bwpDN    index=1
    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${bwpDN_dedic}/PDCCH-1/PDCCH_CONFIG_COMMON-1
    scf.modify scf element    value=${cRbStart}    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetCommon    index=0
    ...    p_name=cRbStart
    scf.modify scf element    value=${size}    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetCommon    index=0
    ...    p_name=size

Initial commissioning for Cell2 with PRB Blanking
    [Arguments]      ${testParam}    ${gnb_scf}

    return from Keyword if     "${w_actPRBBlanking}" == 'False'
    ${actPRBBlanking}=    set variable    ${parameters_PrbBlanking_Cell2['actPRBBlanking']}
    ${nbrOfBlankedPRBsLowEdgeDL}=    set variable     ${parameters_PrbBlanking_Cell2['nbrOfBlankedPRBsLowEdgeDL']}
    ${nbrOfBlankedPRBsLowEdgeUL}=    set variable     ${parameters_PrbBlanking_Cell2['nbrOfBlankedPRBsLowEdgeUL']}
    ${nbrOfBlankedPRBsHighEdgeDL}=    set variable    ${parameters_PrbBlanking_Cell2['nbrOfBlankedPRBsHighEdgeDL']}
    ${nbrOfBlankedPRBsHighEdgeUL}=    set variable    ${parameters_PrbBlanking_Cell2['nbrOfBlankedPRBsHighEdgeUL']}
    ${type0CoresetConfigurationIndex}=       set variable    ${parameters_PrbBlanking_Cell2['type0CoresetConfigurationIndex']}
    ${aggregationLevel}=       set variable    ${parameters_PrbBlanking['aggregationLevel']}
    nps_trf_tools.log_to_console_with_time_prefix    [Cell2] actPRBBlanking=${actPRBBlanking}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell2] nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell2] nbrOfBlankedPRBsLowEdgeUL=${nbrOfBlankedPRBsLowEdgeUL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell2] nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell2] nbrOfBlankedPRBsHighEdgeUL=${nbrOfBlankedPRBsHighEdgeUL}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell2] aggregationLevel=${aggregationLevel}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    [Cell2] type0CoresetConfigurationIndex=${type0CoresetConfigurationIndex}    level=INFO

    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}

    # Apply preconditions from test description for first FDD cell
    FOR    ${dist_name}                                       ${p_name}                      ${value}         IN
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}      actPRBBlanking                 true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}      nbrOfBlankedPRBsLowEdgeUL      ${nbrOfBlankedPRBsLowEdgeUL}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}      nbrOfBlankedPRBsLowEdgeDL      ${nbrOfBlankedPRBsLowEdgeDL}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}      nbrOfBlankedPRBsHighEdgeDL     ${nbrOfBlankedPRBsHighEdgeDL}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}      nbrOfBlankedPRBsHighEdgeUL     ${nbrOfBlankedPRBsHighEdgeUL}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}      type0CoresetConfigurationIndex  ${type0CoresetConfigurationIndex}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}      aggregationLevel               ${aggregationLevel}
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END

    ${chBwUl}	 scf.get_value_from_scf   p_name=chBwUl    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1
    ${bwPrb}=    Get FDD Channel Bandwidth With PRB    chbw=${chBwUl}
    ${cRbStartUl}=     catenate    SEPARATOR=    crb       ${nbrOfBlankedPRBsLowEdgeUL}
    ${cRbSizeUl}=     Evaluate    ${bwPrb} - ${nbrOfBlankedPRBsLowEdgeUL} - ${nbrOfBlankedPRBsHighEdgeUL}
    ${cRbSizeUl}=     catenate    SEPARATOR=    n       ${cRbSizeUl}
    nps_trf_tools.log_to_console_with_time_prefix    Initial cRbStartUl: ${cRbStartUl}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    Initial cRbSizeUl: ${cRbSizeUl}    level=INFO

    ${bwpDN_init}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}    list_name=cellBwpList    p_name=bwpDN    index=0
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbStartUl    value=${cRbStartUl}
    scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbSizeUl     value=${cRbSizeUl}
    # scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbStartUl    value=crb4
    # scf.modify_scf_element    dist_name=${bwpDN_init}    list_name=locationAndBandwidthUl    p_name=cRbSizeUl     value=n48

    ${cRbStart}=    CB013715_tools.calculate_coreset4_cRbStart    nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}
    ${size}=        CB013715_tools.calculate_coreset4_size        bwPrb=${bwPrb}
    ...                                                           nbrOfBlankedPRBsLowEdgeDL=${nbrOfBlankedPRBsLowEdgeDL}
    ...                                                           nbrOfBlankedPRBsHighEdgeDL=${nbrOfBlankedPRBsHighEdgeDL}
    nps_trf_tools.log_to_console_with_time_prefix    coresetId_4 cRbStart: ${cRbStart}    level=INFO
    nps_trf_tools.log_to_console_with_time_prefix    coresetId_4 size: ${size}    level=INFO

    ${bwpDN_dedic}=    scf.get_value_from_scf    dist_name=${distName_NRCELL[${fdd_cell_2}-1]}    list_name=cellBwpList    p_name=bwpDN    index=1
    ${distName_PDCCH_CONFIG_DEDICATED}=    Set variable    ${bwpDN_dedic}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    # scf.modify scf element    value=6    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    scf.modify scf element    value=${cRbStart}    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=cRbStart
    # scf.modify scf element    value=42    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    scf.modify scf element    value=${size}    dist_name=${distName_PDCCH_CONFIG_DEDICATED}    list_name=coresetDedicated    index=0
    ...    p_name=size

#-----------For SCF.xml Changes -----------------------------------------------------------------------------------------------------[150 characters]
BWPs commissioning for A32
    Return From Keyword If    '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'
    ${scf_file}=    Load SCF
        ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
        sort list    ${distName_NRCELL}
        ${distName_1st_TDD_cell}=    set variable    ${distName_NRCELL[${tdd_cell_1}-1]}

        scf-common-keywords.Activate multiple BWPs feature
        scf-common-keywords.Change small BWP    ${distName_1st_TDD_cell}    n217
        scf-common-keywords.Add BWP to cell     ${distName_1st_TDD_cell}    n217
        Set Element     dist_name=${distName_1st_TDD_cell}    p_name=msg1FrequencyStart           value=20
        Set Element     dist_name=${distName_1st_TDD_cell}    p_name=actDynPdcchTdMode            value=perBWP
        Set Element     dist_name=${distName_1st_TDD_cell}    p_name=actDlRbgRandomization        value=disabled
        Set Element     dist_name=${distName_1st_TDD_cell}    p_name=actRat1Alloc                 value=true
        Set Element     dist_name=${distName_1st_TDD_cell}    p_name=actDlInterferenceAvoidance   value=false

    scf-common-keywords.Save SCF, delta commissioning and wait for onair    ${scf_file}

Apply Config for Sub-Feature-G
    [Arguments]     ${nrEcidMeas_SupervisionTimer}=3000
    @{distName_NRBTS}=    Scenario-Common-Keywords.Get distNames from Local SCF File
    ...    scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...                                                                               regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR   ${dist_name}                              ${p_name}                               ${value}                            IN
    ...   ${distName_NRBTS[0]}                      actMeasurementProfile                   deactivated
    ...   ${distName_NRBTS[0]}                      nrEcidMeasSupervisionTimer              ${nrEcidMeas_SupervisionTimer}
    ...   ${distName_NRCELL[${tdd_cell_1}-1]}       actUlNrEcIdPosMethod                    true
    ...   ${distName_NRCELL[${tdd_cell_1}-1]}       actUlNrEcIdTAdv                         true
    ...   ${distName_NRCELL[${tdd_cell_2}-1]}       actUlNrEcIdPosMethod                    true
    ...   ${distName_NRCELL[${tdd_cell_2}-1]}       actUlNrEcIdTAdv                         true
    ...   ${distName_NRCELL[${tdd_cell_3}-1]}       actUlNrEcIdPosMethod                    true
    ...   ${distName_NRCELL[${tdd_cell_3}-1]}       actUlNrEcIdTAdv                         true
          Set Element    dist_name=${dist_name}     p_name=${p_name}   value=${value}
    END

Unlock All Cells
    # Return From Keyword If    '${SHOULD_BE_COMMISSIONED_GNB_FIRST}'=='0'
    ${scf_file}=    Load SCF
        ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-3]+
        sort list    ${distName_NRCELL}
        ${distName_1st_TDD_cell}=    set variable    ${distName_NRCELL[${tdd_cell_1}-1]}
        ${distName_2nd_TDD_cell}=    set variable    ${distName_NRCELL[${tdd_cell_2}-1]}
        ${distName_3rd_TDD_cell}=    set variable    ${distName_NRCELL[${tdd_cell_3}-1]}

        Set Element     dist_name=${distName_1st_TDD_cell}    p_name=administrativeState           value=Unlocked
        Set Element     dist_name=${distName_2nd_TDD_cell}    p_name=administrativeState           value=Unlocked
        Set Element     dist_name=${distName_3rd_TDD_cell}    p_name=administrativeState           value=Unlocked

    scf-common-keywords.Save SCF, delta commissioning and wait for onair    ${scf_file}

# for TdLte 3ms
Add BWP_PROFILE-7 to SCF
    #Cloning BWP_PROFILE-7 from BWP_PROFILE-0
    scf.clone_mo_with_descendant_mos   source_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-0
    ...   target_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-7

    #Modifying List "searchSpaceCommon" in MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${list_name}=             Set Variable              searchSpaceCommon
    Set New List              dist_name=${dist_name}    list_name=${list_name}
    #Adding Item # 1
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        5
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl10
    ...                                                 searchSpaceId                   1
    ...                                                 searchSpaceType                 Type0A
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 2
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        1
    ...                                                 monitoringSymbolWithinSlot      symbol_0_1
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl1
    ...                                                 searchSpaceId                   2
    ...                                                 searchSpaceType                 Type1
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 3
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        5
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl10
    ...                                                 searchSpaceId                   3
    ...                                                 searchSpaceType                 Type2
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}

Add BWP_PROFILE-77 to SCF
    #Cloning BWP_PROFILE-77 from BWP_PROFILE-44
    scf.clone_mo_with_descendant_mos   source_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-44
    ...   target_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-77

    #Modifying List "searchSpaceCommon" in MRBTS-1/NRBTS-1/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${list_name}=             Set Variable              searchSpaceCommon
    Set New List                  dist_name=${dist_name}    list_name=${list_name}
    #Adding Item # 1
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        5
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl10
    ...                                                 searchSpaceId                   4
    ...                                                 searchSpaceType                 Type0A
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 2
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        1
    ...                                                 monitoringSymbolWithinSlot      symbol_0_1
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl1
    ...                                                 searchSpaceId                   5
    ...                                                 searchSpaceType                 Type1
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 3
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        5
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl10
    ...                                                 searchSpaceId                   6
    ...                                                 searchSpaceType                 Type2
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}

# for TdLte 0ms
Add BWP_PROFILE-5 to SCF
    #Cloning BWP_PROFILE-5 from BWP_PROFILE-0
    scf.clone_mo_with_descendant_mos   source_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-0
    ...   target_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-5

    #Modifying List "searchSpaceCommon" in MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${list_name}=             Set Variable              searchSpaceCommon
    Set New List              dist_name=${dist_name}    list_name=${list_name}
    #Adding Item # 1
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        9
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl10
    ...                                                 searchSpaceId                   1
    ...                                                 searchSpaceType                 Type0A
    ...                                                 slotOffset                      4
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 2
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        1
    ...                                                 monitoringSymbolWithinSlot      symbol_0_1
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl1
    ...                                                 searchSpaceId                   2
    ...                                                 searchSpaceType                 Type1
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 3
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        3
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl5
    ...                                                 searchSpaceId                   3
    ...                                                 searchSpaceType                 Type2
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}

Add BWP_PROFILE-55 to SCF
    #Cloning BWP_PROFILE-55 from BWP_PROFILE-44
    scf.clone_mo_with_descendant_mos   source_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-44
    ...   target_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-55

    #Modifying List "searchSpaceCommon" in MRBTS-1/NRBTS-1/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/BWP_PROFILE-55/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${list_name}=             Set Variable              searchSpaceCommon
    Set New List                  dist_name=${dist_name}    list_name=${list_name}
    #Adding Item # 1
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        9
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl10
    ...                                                 searchSpaceId                   4
    ...                                                 searchSpaceType                 Type0A
    ...                                                 slotOffset                      4
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 2
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        1
    ...                                                 monitoringSymbolWithinSlot      symbol_0_1
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl1
    ...                                                 searchSpaceId                   5
    ...                                                 searchSpaceType                 Type1
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 3
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        3
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl5
    ...                                                 searchSpaceId                   6
    ...                                                 searchSpaceType                 Type2
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}

# for SemiStatic 3/7
Add BWP_PROFILE-2 to SCF
    #Cloning BWP_PROFILE-2 from BWP_PROFILE-0
    scf.clone_mo_with_descendant_mos   source_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-0
    ...   target_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-2

    #Modifying List "searchSpaceCommon" in MRBTS-1/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${list_name}=             Set Variable              searchSpaceCommon
    Set New List              dist_name=${dist_name}    list_name=${list_name}
    #Adding Item # 1
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        2
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl5
    ...                                                 searchSpaceId                   1
    ...                                                 searchSpaceType                 Type0A
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 2
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        1
    ...                                                 monitoringSymbolWithinSlot      symbol_0_1
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl1
    ...                                                 searchSpaceId                   2
    ...                                                 searchSpaceType                 Type1
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 3
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        2
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl5
    ...                                                 searchSpaceId                   3
    ...                                                 searchSpaceType                 Type2
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}

Add BWP_PROFILE-22 to SCF
    #Cloning BWP_PROFILE-22 from BWP_PROFILE-44
    scf.clone_mo_with_descendant_mos   source_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-44
    ...   target_mo_dist_name=MRBTS-1/NRBTS-1/BWP_PROFILE-22

    #Modifying List "searchSpaceCommon" in MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/BWP_PROFILE-22/PDCCH-1/PDCCH_CONFIG_COMMON-1
    ${list_name}=             Set Variable              searchSpaceCommon
    Set New List                  dist_name=${dist_name}    list_name=${list_name}
    #Adding Item # 1
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        2
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl5
    ...                                                 searchSpaceId                   4
    ...                                                 searchSpaceType                 Type0A
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 2
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        1
    ...                                                 monitoringSymbolWithinSlot      symbol_0_1
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl1
    ...                                                 searchSpaceId                   5
    ...                                                 searchSpaceType                 Type1
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}
    #Adding Item # 3
    ${list_elements}=         Create dictionary         coresetId                       0
    ...                                                 dciFormat                       formats0-0-And-1-0
    ...                                                 duration                        2
    ...                                                 monitoringSymbolWithinSlot      symbol_0
    ...                                                 numOfPdcchCandidatesInAL16      n0
    ...                                                 numOfPdcchCandidatesInAL2       n0
    ...                                                 numOfPdcchCandidatesInAL4       n2
    ...                                                 numOfPdcchCandidatesInAL8       n0
    ...                                                 periodicity                     sl5
    ...                                                 searchSpaceId                   6
    ...                                                 searchSpaceType                 Type2
    ...                                                 slotOffset                      0
    scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}          elements=${list_elements}

#-----------For UL/DL MUMIMO Changes-------------------------------------------------------------------------------------------------[150 characters]

Activate MU-MIMO
    Configure UL MU-MIMO - CB008360
    Configure DL MU-MIMO Enhancement - CB008305
    Enable Beamforming
    Configure Channels for 8DL4UL

Configure DL MU-MIMO
    ${distName_NRCELL}=   Scenario-Common-Keyword.Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=actDlMuMimo                 value=true
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=dlMuLowSinrThreshold        value=-6
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=dlMuLowSinrThreshold        value=5
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=dlMuPairingThreshold        value=5
    Configure new NRDLMUMIMO Managed Object


Configure UL MU-MIMO - CB008360
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=actUlMuMimo                 value=true
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=actUlSrsBm                  value=true
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=mMimoAntArrayMode           value=Full 64TRX Array (4x8x2)
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=dftBeamDiffThresholdH      value=15
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=dftBeamDiffThresholdV      value=15
    Configure new NRULMUMIMO Managed Object


Configure DL MU-MIMO Enhancement - CB008305
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...    regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=actDlMuMimoEnh              value=true
    Set Element    dist_name=${distName_NRCELL[0]}    p_name=actDlSrsBm                  value=true
    Configure new NRDLMUMIMO Managed Object


Enable Beamforming
    ${distName_NRBTS}=      Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...   regex=MRBTS-[0-9]+/NRBTS-[0-9]+
    ${distName_NRCELL}=     Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...   regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    ${distName_NRCELLGRP}=  Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...   regex=NRBTS-[0-9]+/NRCELLGRP-[0-9]+
    ${distName_NRSYSINFO}=  Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}
    ...   regex=NRBTS-[0-9]+/NRSYSINFO_PROFILE-[0-9]+
    sort list    ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_NRBTS[0]}       p_name=actCustomBsr                 value=true
    Set Element    dist_name=${distName_NRBTS[0]}       p_name=actFdmEnhancedScheduling     value=true
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${NRCELL}    IN   @{distName_NRCELL}
        Set Element    dist_name=${NRCELL}    p_name=actBeamforming               value=true
        Set Element    dist_name=${NRCELL}    p_name=numberOfRxBeamforming        value=4Rx
        Set Element    dist_name=${NRCELL}    p_name=actIncreasedFdmUsersPerSlot  value=false
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        Set List       dist_name=${NRCELL}    list_name=ulPtrs
        ${ulPtrs}=  create dictionary
        ...    actUlPtrs                        false
        ...    ulPtrsFreqDensityThresNrb0       277
        ...    ulPtrsFreqDensityThresNrb1       24
        scf.add_item_to_list    dist_name=${NRCELL}   list_name=ulPtrs   elements=${ulPtrs}
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        Set List       dist_name=${NRCELL}    list_name=beamSet
        ${beamSet}=  create dictionary
        ...    basicBeamSet            beamSet_6
        ...    customBeamSetName       BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
        ...    leftEdgeAngle           60
        ...    lowerEdgeAngle          120
        ...    nrBtsBeamRefinementP2   false
        ...    rightEdgeAngle          60
        ...    upperEdgeAngle          60
        scf.add_item_to_list    dist_name=${NRCELL}   list_name=beamSet   elements=${beamSet}
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        Set List       dist_name=${NRCELL}    list_name=srsForBeamMgmt
        # to improve later &{cSrs} based on BW info from SCF
        ${srsForBeamMgmt}=  create dictionary
        ...    bSRS                      0
        ...    cSRS                      63
        ...    comb                      comb2
        ...    srsPowerThresholdForDlBm  -1200
        ...    srsPowerThresholdForUlBm  -1200
        ...    srsTypeAllocForDlBm       antenna switching or codebook
        ...    srsUePeriodicity          slots20
        scf.add_item_to_list    dist_name=${NRCELL}   list_name=srsForBeamMgmt   elements=${srsForBeamMgmt}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    FOR    ${NRCELLGRP}    IN   @{distName_NRCELLGRP}
        Set Element    dist_name=${NRCELLGRP}   p_name=ssBurstSetPeriod             value=20
        Set Element    dist_name=${NRCELLGRP}   p_name=numberOfTransmittedSsBlocks  value=6 beams
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set Element    dist_name=${distName_NRSYSINFO[0]}   p_name=systemInformationTargetRate  value=157


Configure new NRDLMUMIMO Managed Object
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRDLMUMIMO}=  Set variable  ${distName_NRCELL[0]}/NRDLMUMIMO-1
    Set Object    class_name=com.nokia.srbts.nrbts:NRDLMUMIMO
    ...           dist_name=${distName_NRDLMUMIMO}
    ...           version=NRBTSCL23R3_2305_100
    FOR    ${p_name}    ${value}    IN
    ...    dlMuMaxNumLayerPerMuRbg           8
    ...    dlMuMimoCorrThd                   33
    ...    dlMuMimoCqiThd                    1
    ...    dlMuMimoRankAdaption              adaptive
    ...    dlMuMimoSpectralEffThd            10
    ...    dlMuMimoTaperingH                 25dB
    ...    dlMuMimoTaperingV                 NoTapering
    ...    actExcludeLowBufferUser           false
    ...    dlMuPairingPrbRatio               100
    ...    dlMuAwarePrbRatio                 100
    ...    dlMuAwareCorrThd                  1
    ...    actMuAwareTdSch                   false
        Set Element    dist_name=${distName_NRDLMUMIMO}    p_name=${p_name}    value=${value}
    END


Configure new NRULMUMIMO Managed Object
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list   ${distName_NRCELL}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRULMUMIMO}=  Set variable  ${distName_NRCELL[0]}/NRULMUMIMO-0
    Set Object    class_name=com.nokia.srbts.nrbts:NRULMUMIMO
    ...           dist_name=${distName_NRULMUMIMO}
    ...           version=NRBTSCL23R3_2305_100
    FOR    ${p_name}    ${value}    IN
    ...    actUlMuMimoTapering              false
    ...    ulMaxMuMimoLayer                 2
    ...    ulMinPrbThreshold                50
    ...    ulMuMimoCorrThd                  50
    ...    ulMuMimoCorrThd2                 15
    ...    ulMuMimoLinkAdaptionSwitch       MU-SINR estimation
    ...    ulMuMimoPrbThresholdAbsolute     15
    ...    ulMuMimoSinrThd                  5
    ...    ulMuMimoSpectralEffThd           0
    ...    ulMuMimoTaperingH                25dB
    ...    ulMuMimoTaperingV                0dB
    ...    ulSinrDiffThreshold              -10
    ...    actUlMuMimoGroupPairing          false
    ...    ulCandidatePrbRatio              100
        Set Element    dist_name=${distName_NRULMUMIMO}    p_name=${p_name}    value=${value}
    END
    Set List      dist_name=${distName_NRULMUMIMO}  list_name=ulMuMimoFoThreshold
    ${ulMuMimoFoThreshold}=  create dictionary
    ...    foThresh256Qam                   300
    ...    foThreshNon256Qam                600
    scf.add_item_to_list    dist_name=${distName_NRULMUMIMO}   list_name=ulMuMimoFoThreshold   elements=${ulMuMimoFoThreshold}
    Set List      dist_name=${distName_NRULMUMIMO}  list_name=ulMuMimoMcsOffsetGroup
    ${ulMuMimoMcsOffsetGroup}=  create dictionary
    ...    mcsOffsetLayerDiffOne            -1
    ...    mcsOffsetLayerDiffThree          -2
    ...    mcsOffsetLayerDiffTwo            -2
    ...    mcsOffsetLayerDiffZero           0
    scf.add_item_to_list    dist_name=${distName_NRULMUMIMO}   list_name=ulMuMimoMcsOffsetGroup   elements=${ulMuMimoMcsOffsetGroup}
    Set List      dist_name=${distName_NRULMUMIMO}  list_name=ulMuMimoPrbThresholdRatio
    ${ulMuMimoPrbThresholdRatio}=  create dictionary
    ...    prbThreshRangeOne                20
    ...    prbThreshRangeThree              20
    ...    prbThreshRangeTwo                20
    scf.add_item_to_list    dist_name=${distName_NRULMUMIMO}   list_name=ulMuMimoPrbThresholdRatio   elements=${ulMuMimoPrbThresholdRatio}



Configure Channels for 8DL4UL
    ${distName_NRCELL}=   Scenario-Common-Keywords.Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    FOR    ${NRCELL}    IN    @{distName_NRCELL}
        Configure each Cell for 8DL4UL     ${NRCELL}
        ${cellNumber}=    get substring    ${NRCELL}    -1
        Modify CHANNELGROUP-1 for 8DL4UL   ${cellNumber}
        Create CHANNELGROUP-2 for 8DL4UL   ${cellNumber}
    END


Configure each Cell for 8DL4UL
    [Arguments]  ${distName}
    FOR    ${p_name}    ${value}    IN
    ...    dlMimoMode                            4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...    nrCellType                            8DL4UL
        Set Element    dist_name=${distName}    p_name=${p_name}    value=${value}
    END
    return from keyword


Modify CHANNELGROUP-1 for 8DL4UL
    [Arguments]  ${cellNumber}
    FOR  ${channelId}  IN RANGE  1   5
        ${distName_CHANNEL}=  Set variable  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellNumber}/CHANNELGROUP-1/CHANNEL-${channelId}
        Set Object    class_name=com.nokia.srbts.mnl:CHANNEL
        ...           dist_name=${distName_CHANNEL}
        ...           version=MNL22R4_2214_101
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
        ...           version=MNL22R4_2214_101
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=direction
        ...           value=RX
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=resourceDN
        ...           value=MRBTS-1/EQM-1/APEQM-1/RMOD-${cellNumber}/PHYANT-1
    END

Create CHANNELGROUP-2 for 8DL4UL
    [Arguments]  ${cellNumber}
    Set Object    class_name=com.nokia.srbts.mnl:CHANNELGROUP
    ...           dist_name=MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellNumber}/CHANNELGROUP-2
    ...           version=MNL23R3_2305_110
    FOR  ${channelId}  IN RANGE  1   5
        ${distName_CHANNEL}=  Set variable  MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cellNumber}/CHANNELGROUP-2/CHANNEL-${channelId}
        Set Object    class_name=com.nokia.srbts.mnl:CHANNEL
        ...           dist_name=${distName_CHANNEL}
        ...           version=MNL22R4_2214_101
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=direction
        ...           value=TX
        Set Element   dist_name=${distName_CHANNEL}
        ...           p_name=resourceDN
        ...           value=MRBTS-1/EQM-1/APEQM-1/RMOD-${cellNumber}/PHYANT-1
    END

#-----------End UL/DL MUMIMO Changes-------------------------------------------------------------------------------------------------[150 characters]

Private Force WTS To Init State
    [Documentation]
    ...    Used to bring WTS from e.g. ACTIVE to INIT state.
    ...
    ...    *Scope* Internal
    ...
    ...    | wts_alias      | alias name to handle egate for ute_wtssim     |
    ...
    [Arguments]   ${wts_alias}=ap_egate
    Run Keyword And Return Status
    ...   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=re   pass_regexp=.*   wts_alias=${wts_alias}
    BuiltIn.Sleep   1s   Guard time until WTS reaches INIT state
    ${sim_status}   Run Keyword And Return Status
    ...   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=sim_state_disp   pass_regexp=The state is INIT   wts_alias=${wts_alias}
    [Return]    ${sim_status}

Light Bring Airphone TL to on Air status without reboot
    [arguments]     ${w_Config_WTS_for_Airphone}=True
    GenericSuiteTest.Step      Scenario-Common-Keywords.Wait For Minimum Required State For Cell Setup    timeout=10min
    IF    '${w_Config_WTS_for_Airphone}'=='True'
        ${sim_status}=    Private Force WTS To Init State
    ELSE
        ${sim_status}   Run Keyword And Return Status
        ...   ute-wtssim-ue-Keywords.Send Egate Command and verify output   cmd=sim_state_disp   pass_regexp=The state is INIT   wts_alias=ap_egate
    END
    nps_trf_tools.log_to_console_with_time_prefix    WTS To Init State is ${sim_status}    level=INFO
    IF    '${w_Config_WTS_for_Airphone}'=='True'
        ute-wtssim-ue-Keywords.Config WTS for Airphone   pass_regexp=NB 2 cell 1.*SystemInformationBlockType1-NR updated
        ...                                              timeout=60   cfg_file=${tl.core.cfg_filename}
    END
    GenericSuiteTest.Step     Scenario-Common-Keywords.Verify Cell Setup

01_CB007491_BW_100_80_60_5GC001208_6ssb_80sl
    # 5GC001208 means SemiStatic 1:4
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    dated log    Activate Config [5GC001208 5GC001208 5GC001208] => OK
    dated log    Activate Config [01_CB007491_BW_100_80_60_5GC001208_6ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable   @{msg1FrequencyStart}      23      23      23
    # prach=97 in case of 5GC001116_0
    set suite variable   @{prach}                   93      93      93
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted

    CB007491-TDD_initial_commissioning.Prepare testCase Execution    set_active_configuration=01_CB007491_BW_100_80_60_5GC001208_6ssb_80sl
    ...                                                              w_set_config=False
    Light Bring Airphone TL to on Air status without reboot

02_CB007491_BW_100_80_60_5GC001070_6ssb_80sl
    # 5GC001208 means SemiStatic 1:4
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    dated log    Activate Config [02_CB007491_BW_100_80_60_5GC001070_6ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001070    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-2  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-2
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-22  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-22
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable   @{msg1FrequencyStart}      23      23      23
    # prach=97 in case of 5GC001116_0
    set suite variable   @{prach}                   93      93      93
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted

    CB007491-TDD_initial_commissioning.Prepare testCase Execution    set_active_configuration=02_CB007491_BW_100_80_60_5GC001070_6ssb_80sl
    ...                                                              w_set_config=False
    ${full_file_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    Light Bring Airphone TL to on Air status without reboot
    # Dev_lib.start_to_capture_infomodel_log
    # All Available Cells Should Be Onair
    # [teardown]    Dev_lib.stop_to_capture_infomodel_log


03_CB007491_BW_100_80_60_5GC001116_3_6ssb_80sl
    # 5GC001208 means SemiStatic 1:4
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    dated log    Activate Config [03_CB007491_BW_100_80_60_5GC001116_3_6ssb_80sl]
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_3    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-2
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-22
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable   @{msg1FrequencyStart}      23      23      23
    # prach=97 in case of 5GC001116_0
    set suite variable   @{prach}                   93      93      93
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted

    CB007491-TDD_initial_commissioning.Prepare testCase Execution    set_active_configuration=03_CB007491_BW_100_80_60_5GC001116_3_6ssb_80sl
    ...                                                              w_set_config=False
    ${full_file_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    Light Bring Airphone TL to on Air status without reboot
    # Dev_lib.start_to_capture_infomodel_log
    # All Available Cells Should Be Onair
    # [teardown]    Dev_lib.stop_to_capture_infomodel_log


04_CB007491_BW_100_80_60_5GC001116_0_6ssb_80sl
    # 5GC001208 means SemiStatic 1:4
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    dated log    Activate Config [04_CB007491_BW_100_80_60_5GC001116_0_6ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_0    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-2
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-22
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable   @{msg1FrequencyStart}      23      23      23
    # prach=97 in case of 5GC001116_0
    set suite variable   @{prach}                   97      93      93
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted

    CB007491-TDD_initial_commissioning.Prepare testCase Execution    set_active_configuration=04_CB007491_BW_100_80_60_5GC001116_0_6ssb_80sl
    ...                                                              w_set_config=False
    ${full_file_path}  COAM Get SCF   local_dir_path=${configuration_directory}   file=scf_${scenario_name}.xml   alias=coam_gnb
    Light Bring Airphone TL to on Air status without reboot
    # Dev_lib.start_to_capture_infomodel_log
    # All Available Cells Should Be Onair
    # [teardown]    Dev_lib.stop_to_capture_infomodel_log

05_CB007491_BW_100_80_60_5GC001116_0_5GC001070_5GC001070_2ssb_80sl
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [05_CB007491_BW_100_80_60_5GC001116_0_5GC001070_5GC001070_2ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_0    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_2  beamSet_2  beamSet_2
    set suite variable   @{beams}     2 beams  2 beams  2 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    set suite variable   @{msg1FrequencyStart}      23      23      23
    set suite variable   @{ulDMRSAdditionalPosition}         Automatic     Two additional DMRS    Two additional DMRS
    set suite variable   @{dlDMRSAdditionalPosition}         No additional DMRS     No additional DMRS    Two additional DMRS
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    set suite variable   @{prach}                   9      7      104
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted
    set suite variable   @{zeroCorrelationZoneConfig}       14    14    14

05_01_CB007491_BW_100_80_60_5GC001116_0_5GC001070_5GC001070_2ssb_80sl
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [05_01_CB007491_BW_100_80_60_5GC001116_0_5GC001070_5GC001070_2ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_0    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_2  beamSet_2  beamSet_2
    set suite variable   @{beams}     2 beams  2 beams  2 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    set suite variable    @{nrCellType}          4DL4UL      4DL4UL      4DL4UL
    set suite variable   @{msg1FrequencyStart}      23      23      23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    set suite variable   @{prach}                   9      7      7
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{ulDMRSAdditionalPosition}         Automatic     Two additional DMRS    Two additional DMRS
    set suite variable   @{dlDMRSAdditionalPosition}         No additional DMRS     No additional DMRS    No additional DMRS
    set suite variable   @{prachSequenceType}       RestrictedTypeA    Unrestricted    Unrestricted
    set suite variable   @{zeroCorrelationZoneConfig}       0            14               14
    set suite variable   @{actUlPtrs}                        true        false      false
    set suite variable   @{actDlPtrs}                        false        false      false
    set suite variable   @{actUlSrsBm}                       false        false      false
    set suite variable   @{actDlSrsBm}                       false        false      false
    set suite variable   @{actHighSpeedCell}                 true         true       true


06_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_3 5GC001070 5GC001070] => OK
    dated log    Activate Config [06_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_3    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable    @{nrCellType}          4DL4UL      4DL4UL      4DL4UL
    set suite variable   @{msg1FrequencyStart}      23      23      23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   97      104      104
    set suite variable   @{prach}                   7      7      5
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{ulDMRSAdditionalPosition}         Two additional DMRS    Two additional DMRS    Two additional DMRS
    set suite variable   @{dlDMRSAdditionalPosition}         No additional DMRS     No additional DMRS    No additional DMRS
    set suite variable   @{prachSequenceType}                RestrictedTypeA    Unrestricted    Unrestricted
    # set suite variable   @{prachSequenceType}               Unrestricted    Unrestricted    Unrestricted
    set suite variable   @{zeroCorrelationZoneConfig}            0                 14               14
    set suite variable   @{type0CoresetConfigurationIndex}        10   10    10
    set suite variable   @{type0SearchSpaceConfigurationIndex}    5    5    5
    set suite variable   @{actUlPtrs}                        false        false      false
    set suite variable   @{actDlPtrs}                        false        false      false
    set suite variable   @{actUlSrsBm}                       false        false      false
    set suite variable   @{actDlSrsBm}                       false        false      false

06_TC74_CB007491_BW_10_80_60_5GC001116_3_5GC001070_5GC001070_2ssb_80sl
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_3 5GC001070 5GC001070] => OK
    dated log    Activate Config [06_TC74_CB007491_BW_10_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     10MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_3    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-1  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-11  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_2  beamSet_2  beamSet_2
    set suite variable   @{beams}     2 beams  2 beams  2 beams
    set suite variable   @{customBeamSetName}    BSR_AEHC_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEHC_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEHC_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    set suite variable    @{nrCellType}          4DL4UL      4DL4UL      4DL4UL
    set suite variable   @{msg1FrequencyStart}      6         23          23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   93      104      104
    set suite variable   @{prach}                     7      104        5
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{actHighSpeedCell}                 true          false                true
    set suite variable   @{ulDMRSAdditionalPosition}         Two additional DMRS    No additional DMRS    Two additional DMRS
    set suite variable   @{dlDMRSAdditionalPosition}         No additional DMRS     No additional DMRS    No additional DMRS
    set suite variable   @{prachSequenceType}               RestrictedTypeB    Unrestricted    RestrictedTypeB
    # set suite variable   @{zeroCorrelationZoneConfig}            0          14            14
    set suite variable   @{zeroCorrelationZoneConfig}              0          14            12
    set suite variable   @{type0CoresetConfigurationIndex}         5          10            10
    set suite variable   @{type0SearchSpaceConfigurationIndex}     4           5            5
    set suite variable   @{dmrsTypeAPosition}                     pos3        pos2         pos2
    set suite variable   @{actUlPtrs}                        false        false      false
    set suite variable   @{actDlPtrs}                        false        false      false
    set suite variable   @{actUlSrsBm}                       false        false      false
    set suite variable   @{actDlSrsBm}                       false        false      false


06_01_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl_8DL_4UL
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_3 5GC001070 5GC001070] => OK
    dated log    Activate Config [06_01_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl_8DL_4UL]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_3    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable    @{nrCellType}          8DL4UL      8DL4UL      8DL4UL
    set suite variable    @{msg1FrequencyStart}      23      23      23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   97      104      104
    set suite variable   @{prach}                   5      7      7
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{ulDMRSAdditionalPosition}         Automatic     Two additional DMRS    Two additional DMRS
    set suite variable   @{dlDMRSAdditionalPosition}         No additional DMRS     No additional DMRS    No additional DMRS
    set suite variable   @{prachSequenceType}                RestrictedTypeA    Unrestricted    Unrestricted
    set suite variable   @{zeroCorrelationZoneConfig}            0                 14               14
    set suite variable   @{type0CoresetConfigurationIndex}        10   10    10
    set suite variable   @{type0SearchSpaceConfigurationIndex}    5    5    5
    set suite variable   @{actUlPtrs}                        true        false      false
    set suite variable   @{actDlPtrs}                        false        false      false
    set suite variable   @{actUlSrsBm}                       false        false      false
    set suite variable   @{actDlSrsBm}                       false        false      false

07_CB007491_BW_10_80_60_5GC001116_3_5GC001070_5GC001070_2ssb_80sl_6Cells
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-1 and BWP_PROFILE-11 - 10Mhz - 5GC001116_3
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_3 5GC001070 5GC001070 5GC001070 5GC001070 5GC001070] => OK
    dated log    Activate Config [07_CB007491_BW_10_80_60_5GC001116_3_5GC001070_5GC001070_2ssb_80sl_6Cells]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    # limited to 2 different FS (PDL rule)
    set suite variable   @{chBw}     10MHz       80MHz       60MHz    100MHz     100MHz    100MHz
    set suite variable   @{frameStructure_cell}      5GC001116_3    5GC001070   5GC001070
    ...                                              5GC001070      5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-1  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-2  ${mrbts}/${nrbts}/BWP_PROFILE-2
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-11  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-22  ${mrbts}/${nrbts}/BWP_PROFILE-22
    set suite variable   @{beamSet}   beamSet_2  beamSet_2  beamSet_2    beamSet_2    beamSet_2    beamSet_2
    set suite variable   @{beams}     2 beams  2 beams  2 beams    2 beams    2 beams    2 beams
    set suite variable   @{customBeamSetName}    BSR_AEHC_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    set suite variable   @{msg1FrequencyStart}      6      23      23    23    23    23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   97      104      104
    set suite variable   @{prach}                   5      7      104    104    104    104
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80    slots80    slots80    slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted
    ...                                             Unrestricted    Unrestricted    Unrestricted
    set suite variable    @{type0CoresetConfigurationIndex}        5      10       10     10       10      10
    set suite variable    @{type0SearchSpaceConfigurationIndex}    4       5       5       5       5        5
    # BEWARE that for 10MHz Tdd BW , type0CoresetConfigurationIndex = 5 setting which maps to coreset0 duration = 3
    # with coreset0 duration = 3, dmrsTypeAPostion shall be "pos3"
    set suite variable    @{dmrsTypeAPosition}                pos3    pos2    pos2    pos2    pos2    pos2
    set suite variable    @{nrCellType}                       4DL4UL      4DL4UL      4DL4UL    4DL4UL    4DL4UL    4DL4UL
    set suite variable    @{dlMimoMode}    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...                                    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...                                    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    set suite variable    @{ulDMRSAdditionalPosition}         Automatic     Two additional DMRS    Two additional DMRS
    ...                                                       Two additional DMRS    Two additional DMRS    Two additional DMRS
    set suite variable    @{dlDMRSAdditionalPosition}         Two additional DMRS     Two additional DMRS    Two additional DMRS
    ...                                                       Two additional DMRS     Two additional DMRS    Two additional DMRS
    set suite variable    @{actUlPtrs}                        true        false      false
    ...                                                       false       false      false
    set suite variable    @{actDlPtrs}                        false        false      false
    ...                                                       false        false      false
    set suite variable    @{actUlSrsBm}                       false        false      false
    ...                                                       false        false      false
    set suite variable    @{actDlSrsBm}                       false        false      false
    ...                                                       false        false      false
    set suite variable    @{actHighSpeedCell}                 true    true    true
    ...                                                       true    true    true
    set suite variable    @{zeroCorrelationZoneConfig}        14            14               14
    ...                                                       14            14               14

# need to review PROFILE-1 en PROFILE-11 for 5GC001116_0
07_2_CB007491_BW_10_80_60_5GC001116_0_5GC001070_5GC001070_2ssb_80sl_6Cells
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-1 and BWP_PROFILE-11 - 10Mhz - 5GC001116_3
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_3 5GC001070 5GC001070 5GC001070 5GC001070 5GC001070] => OK
    dated log    Activate Config [07_2_CB007491_BW_10_80_60_5GC001116_0_5GC001070_5GC001070_2ssb_80sl_6Cells]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    # limited to 2 different FS (PDL rule)
    set suite variable   @{chBw}     10MHz       80MHz       60MHz    100MHz     100MHz    100MHz
    set suite variable   @{frameStructure_cell}      5GC001116_3    5GC001070   5GC001070
    ...                                              5GC001070      5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-1  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-2  ${mrbts}/${nrbts}/BWP_PROFILE-2
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-11  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-22  ${mrbts}/${nrbts}/BWP_PROFILE-22
    set suite variable   @{beamSet}   beamSet_2  beamSet_2  beamSet_2    beamSet_2    beamSet_2    beamSet_2
    set suite variable   @{beams}     2 beams  2 beams  2 beams    2 beams    2 beams    2 beams
    set suite variable   @{customBeamSetName}    BSR_AEHC_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    set suite variable   @{msg1FrequencyStart}      6      23      23    23    23    23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   97      104      104
    set suite variable   @{prach}                   5      7      104    104    104    104
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80    slots80    slots80    slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted
    ...                                             Unrestricted    Unrestricted    Unrestricted
    set suite variable    @{type0CoresetConfigurationIndex}        5   10    10    10    10    10
    set suite variable    @{type0SearchSpaceConfigurationIndex}    4    5    5     5     5     5
    # BEWARE that for 10MHz Tdd BW , type0CoresetConfigurationIndex = 5 setting which maps to coreset0 duration = 3
    # with coreset0 duration = 3, dmrsTypeAPostion shall be "pos3"
    set suite variable    @{dmrsTypeAPosition}                pos3    pos2    pos2    pos2    pos2    pos2
    set suite variable    @{nrCellType}                       4DL4UL      4DL4UL      4DL4UL    4DL4UL    4DL4UL    4DL4UL
    set suite variable    @{dlMimoMode}    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...                                    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...                                    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    set suite variable    @{ulDMRSAdditionalPosition}         Automatic     Two additional DMRS    Two additional DMRS
    ...                                                       Two additional DMRS    Two additional DMRS    Two additional DMRS
    set suite variable    @{dlDMRSAdditionalPosition}         Two additional DMRS     Two additional DMRS    Two additional DMRS
    ...                                                       Two additional DMRS     Two additional DMRS    Two additional DMRS
    set suite variable    @{actUlPtrs}                        true        false      false
    ...                                                       false       false      false
    set suite variable    @{actDlPtrs}                        false        false      false
    ...                                                       false        false      false
    set suite variable    @{actUlSrsBm}                       false        false      false
    ...                                                       false        false      false
    set suite variable    @{actDlSrsBm}                       false        false      false
    ...                                                       false        false      false
    set suite variable    @{actHighSpeedCell}                 true    true    true
    ...                                                       true    true    true
    set suite variable    @{zeroCorrelationZoneConfig}        14            14               14
    ...                                                       14            14               14

# need to review PROFILE-1 en PROFILE-11 for 5GC001116_0
08_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_2ssb_80sl_6Cells
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-1 and BWP_PROFILE-11 - 10Mhz - 5GC001116_3
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_0 5GC001070 5GC001070 5GC001070 5GC001070 5GC001070] => OK
    dated log    Activate Config [08_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_2ssb_80sl_6Cells]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    # limited to 2 different FS (PDL rule)
    set suite variable   @{chBw}     100MHz       80MHz       60MHz    100MHz     100MHz    100MHz
    set suite variable   @{frameStructure_cell}      5GC001116_0    5GC001070   5GC001070
    ...                                              5GC001070      5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-2  ${mrbts}/${nrbts}/BWP_PROFILE-2
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-22  ${mrbts}/${nrbts}/BWP_PROFILE-22
    set suite variable   @{beamSet}   beamSet_2  beamSet_2  beamSet_2    beamSet_2    beamSet_2    beamSet_2
    set suite variable   @{beams}     2 beams  2 beams  2 beams    2 beams    2 beams    2 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    set suite variable   @{msg1FrequencyStart}      23      23      23    23    23    23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   97      104      104
    set suite variable   @{prach}                   9      7      104    104    104    104
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80    slots80    slots80    slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted
    ...                                             Unrestricted    Unrestricted    Unrestricted
    set suite variable    @{type0CoresetConfigurationIndex}        10   10    10    10    10    10
    set suite variable    @{type0SearchSpaceConfigurationIndex}    5    5    5     5     5     5
    # BEWARE that for 10MHz Tdd BW , type0CoresetConfigurationIndex = 5 setting which maps to coreset0 duration = 3
    # with coreset0 duration = 3, dmrsTypeAPostion shall be "pos3"
    set suite variable    @{dmrsTypeAPosition}                pos2    pos2    pos2    pos2    pos2    pos2
    set suite variable    @{nrCellType}                       4DL4UL      4DL4UL      4DL4UL    4DL4UL    4DL4UL    4DL4UL
    set suite variable    @{dlMimoMode}    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...                                    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...                                    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    set suite variable    @{ulDMRSAdditionalPosition}         Automatic     Two additional DMRS    Two additional DMRS
    ...                                                       Two additional DMRS    Two additional DMRS    Two additional DMRS
    set suite variable    @{dlDMRSAdditionalPosition}         Two additional DMRS     Two additional DMRS    Two additional DMRS
    ...                                                       Two additional DMRS     Two additional DMRS    Two additional DMRS
    set suite variable    @{actUlPtrs}                        true        false      false
    ...                                                       false       false      false
    set suite variable    @{actDlPtrs}                        false        false      false
    ...                                                       false        false      false
    set suite variable    @{actUlSrsBm}                       false        false      false
    ...                                                       false        false      false
    set suite variable    @{actDlSrsBm}                       false        false      false
    ...                                                       false        false      false
    set suite variable    @{actHighSpeedCell}                 true    true    true
    ...                                                       true    true    true
    set suite variable    @{zeroCorrelationZoneConfig}        14            14               14
    ...                                                       14            14               14

09_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl_6Cells
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-1 and BWP_PROFILE-11 - 10Mhz - 5GC001116_3
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_0 5GC001070 5GC001070 5GC001070 5GC001070 5GC001070] => OK
    dated log    Activate Config [09_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl_6Cells]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    # limited to 2 different FS (PDL rule)
    set suite variable   @{chBw}     100MHz       80MHz       60MHz    100MHz     100MHz    100MHz
    set suite variable   @{frameStructure_cell}      5GC001116_0    5GC001070   5GC001070
    ...                                              5GC001070      5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-5  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-2  ${mrbts}/${nrbts}/BWP_PROFILE-2
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-55  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-22  ${mrbts}/${nrbts}/BWP_PROFILE-22
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6    beamSet_6    beamSet_6    beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams    6 beams    6 beams    6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable   @{msg1FrequencyStart}      23      23      23    23    23    23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   97      104      104
    set suite variable   @{prach}                   9      7      104    104    104    104
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80    slots80    slots80    slots80
    set suite variable   @{prachSequenceType}       Unrestricted    Unrestricted    Unrestricted
    ...                                             Unrestricted    Unrestricted    Unrestricted
    set suite variable    @{type0CoresetConfigurationIndex}        10   10    10    10    10    10
    set suite variable    @{type0SearchSpaceConfigurationIndex}    5    5    5     5     5     5
    # BEWARE that for 10MHz Tdd BW , type0CoresetConfigurationIndex = 5 setting which maps to coreset0 duration = 3
    # with coreset0 duration = 3, dmrsTypeAPostion shall be "pos3"
    set suite variable     @{dmrsTypeAPosition}               pos2    pos2    pos2    pos2    pos2    pos2
    set suite variable    @{nrCellType}                       8DL4UL      8DL4UL      8DL4UL    8DL4UL    8DL4UL    8DL4UL
    set suite variable    @{dlMimoMode}    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...                                    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...                                    4x4 or 4x2 Closed Loop Spatial Multiplexing    4x4 or 4x2 Closed Loop Spatial Multiplexing
    set suite variable    @{ulDMRSAdditionalPosition}         Two additional DMRS     Two additional DMRS    Two additional DMRS
    ...                                                       Two additional DMRS    Two additional DMRS    Two additional DMRS
    set suite variable    @{dlDMRSAdditionalPosition}         Two additional DMRS     Two additional DMRS    Two additional DMRS
    ...                                                       Two additional DMRS     Two additional DMRS    Two additional DMRS
    set suite variable    @{actUlPtrs}                        false       false      false
    ...                                                       false       false      false
    set suite variable    @{actDlPtrs}                        false        false      false
    ...                                                       false        false      false
    set suite variable    @{actUlSrsBm}                       true       false      false
    ...                                                       false       false      false
    set suite variable    @{actDlSrsBm}                       true        false      false
    ...                                                       false        false      false
    set suite variable    @{actHighSpeedCell}                 true    true    true
    ...                                                       true    true    true
    set suite variable    @{zeroCorrelationZoneConfig}        14            14               14
    ...                                                       14            14               14


# for -H
06_CB007491_H_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_3 5GC001070 5GC001070] => OK
    dated log    Activate Config [06_CB007491_H_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_3    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable   @{nrCellType}          4DL4UL      4DL4UL      4DL4UL
    set suite variable   @{msg1FrequencyStart}      23      23      23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   97      104      104
    set suite variable   @{prach}                   7      7      5
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{ulDMRSAdditionalPosition}         Two additional DMRS    Two additional DMRS    Two additional DMRS
    set suite variable   @{dlDMRSAdditionalPosition}         No additional DMRS     No additional DMRS    No additional DMRS
    set suite variable   @{prachSequenceType}                RestrictedTypeA    Unrestricted    Unrestricted
    # set suite variable   @{prachSequenceType}               Unrestricted    Unrestricted    Unrestricted
    set suite variable   @{zeroCorrelationZoneConfig}            0                 14               14
    set suite variable   @{type0CoresetConfigurationIndex}        10   10    10
    set suite variable   @{type0SearchSpaceConfigurationIndex}    5    5    5
    set suite variable   @{dmrsTypeAPosition}                     pos2        pos2         pos2
    set suite variable   @{actUlPtrs}                        false        false      false
    set suite variable   @{actDlPtrs}                        false        false      false
    set suite variable   @{actUlSrsBm}                       false        false      false
    set suite variable   @{actDlSrsBm}                       false        false      false
    # activate config
    set suite variable   ${w_force_active_config}     True
    CB007491-TDD_initial_commissioning.Prepare testCase Execution
    ...      set_active_configuration=06_CB007491_H_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl
    ...      w_set_config=False
    Light Bring Airphone TL to on Air status without reboot    w_Config_WTS_for_Airphone=False

06_CB007491_H_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_2ssb_80sl
# 06_TC74_CB007491_BW_10_80_60_5GC001116_3_5GC001070_5GC001070_2ssb_80sl
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_3 5GC001070 5GC001070] => OK
    dated log    Activate Config [06_CB007491_H_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_2ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_3    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_2  beamSet_2  beamSet_2
    set suite variable   @{beams}     2 beams  2 beams  2 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    ...                                          BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
    set suite variable    @{nrCellType}          4DL4UL      4DL4UL      4DL4UL
    set suite variable   @{msg1FrequencyStart}      23         23          23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   93      104      104
    set suite variable   @{prach}                     7      104        5
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{actHighSpeedCell}                 true          false                true
    set suite variable   @{ulDMRSAdditionalPosition}         Two additional DMRS    No additional DMRS    Two additional DMRS
    set suite variable   @{dlDMRSAdditionalPosition}         No additional DMRS     No additional DMRS    No additional DMRS
    set suite variable   @{prachSequenceType}               RestrictedTypeB    Unrestricted    RestrictedTypeB
    # set suite variable   @{zeroCorrelationZoneConfig}            0          14            14
    set suite variable   @{zeroCorrelationZoneConfig}              0          14            12
    set suite variable   @{type0CoresetConfigurationIndex}         10          10            10
    set suite variable   @{type0SearchSpaceConfigurationIndex}     5           5            5
    set suite variable   @{dmrsTypeAPosition}                     pos2        pos2         pos2
    set suite variable   @{actUlPtrs}                        false        false      false
    set suite variable   @{actDlPtrs}                        false        false      false
    set suite variable   @{actUlSrsBm}                       false        false      false
    set suite variable   @{actDlSrsBm}                       false        false      false
    # activate config
    set suite variable   ${w_force_active_config}     True
    CB007491-TDD_initial_commissioning.Prepare testCase Execution
    ...      set_active_configuration=06_CB007491_H_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_2ssb_80sl
    ...      w_set_config=False
    Light Bring Airphone TL to on Air status without reboot    w_Config_WTS_for_Airphone=False

10_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl
    [Arguments]   ${w_activate_config}=false
    # 5GC001208 means SemiStatic 1:4 (HST dont support FS 5GC001208)
    # 5GC001070 means SemiStatic 3:7
    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # Cell1 is 100MHz, Cell2 is 80MHz and Cell3 is 60MHz
    # BWP_PROFILE-0 and BWP_PROFILE-44 - 100Mhz - 5GC001208
    # BWP_PROFILE-6 and BWP_PROFILE-36 - 80Mhz - 5GC001208
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001208    => remove as to not test with HTS!!!
    # BWP_PROFILE-7 and BWP_PROFILE-77 - 100Mhz - 5GC001116_3
    # BWP_PROFILE-2 and BWP_PROFILE-22 - 100Mhz - 5GC001070
    # BWP_PROFILE-8 and BWP_PROFILE-31 - 60Mhz - 5GC001070
    # BWP_PROFILE-5 and BWP_PROFILE-55 - 100Mhz - 5GC001116_0
    # BWP_PROFILE-9 and BWP_PROFILE-99 - 100Mhz - 5GC001116_3_Canada - to do
    # set suite variable   @{frameStructure_cell}      5GC001208    5GC001208   5GC001208
    # set test variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-0  ${mrbts}/${nrbts}/BWP_PROFILE-6
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-8
    # set test variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-44  ${mrbts}/${nrbts}/BWP_PROFILE-36
    # ...                           ${mrbts}/${nrbts}/BWP_PROFILE-31

    # dated log    Activate Config [5GC001116_3 5GC001070 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001116_0 5GC001208] => KO[Cell not deployed due to excessive number of different Frame Structures]
    # dated log    Activate Config [5GC001116_3 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001070 5GC001208 5GC001208] => OK
    # dated log    Activate Config [5GC001116_0 5GC001070 5GC001070] => OK
    dated log    Activate Config [5GC001116_3 5GC001070 5GC001070] => OK
    dated log    Activate Config [10_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl]
    ${mrbts}=    Set Variable     MRBTS-${MRBTS_ID}
    ${nrbts}=    Set Variable     NRBTS-${NRBTS_ID}
    set suite variable   @{chBw}     100MHz       80MHz       60MHz
    set suite variable   @{frameStructure_cell}      5GC001116_3    5GC001070   5GC001070
    set suite variable   @{bwp0}   ${mrbts}/${nrbts}/BWP_PROFILE-7  ${mrbts}/${nrbts}/BWP_PROFILE-2
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-8
    set suite variable   @{bwp1}   ${mrbts}/${nrbts}/BWP_PROFILE-77  ${mrbts}/${nrbts}/BWP_PROFILE-22
    ...                            ${mrbts}/${nrbts}/BWP_PROFILE-31
    set suite variable   @{beamSet}   beamSet_6  beamSet_6  beamSet_6
    set suite variable   @{beams}     6 beams  6 beams  6 beams
    set suite variable   @{customBeamSetName}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ...                                          BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    set suite variable    @{nrCellType}          4DL4UL      4DL4UL      4DL4UL
    set suite variable   @{msg1FrequencyStart}      23      23      23
    # for rach short format, prach=97 in case of 5GC001116_0
    # for rach short format, prach=93 in case of other FS
    # set suite variable   @{prach}                   97      104      104
    set suite variable   @{prach}                   5      7      7
    set suite variable   @{csiReportPeriodicity}    slots80   slots80  slots80
    set suite variable   @{ulDMRSAdditionalPosition}         Two additional DMRS    Two additional DMRS    Two additional DMRS
    set suite variable   @{dlDMRSAdditionalPosition}         No additional DMRS     No additional DMRS    No additional DMRS
    set suite variable   @{prachSequenceType}                RestrictedTypeA    RestrictedTypeB    Unrestricted
    set suite variable   @{type0CoresetConfigurationIndex}        10   10    10
    set suite variable   @{type0SearchSpaceConfigurationIndex}    5    5    5
    set suite variable   @{actUlPtrs}                        false        false      false
    set suite variable   @{actDlPtrs}                        false        false      false
    set suite variable   @{actUlSrsBm}                       false        false      false
    set suite variable   @{actDlSrsBm}                       false        false      false
    set suite variable   @{actHighSpeedCell}                 true         true       true
    set suite variable   @{zeroCorrelationZoneConfig}        0            12          14
    return from keyword if    '${w_activate_config}'!='true'
    # activate config
    set suite variable   ${w_force_active_config}     True
    CB007491-TDD_initial_commissioning.Prepare testCase Execution
    ...      set_active_configuration=10_CB007491_BW_100_80_60_5GC001116_3_5GC001070_5GC001070_6ssb_80sl
    ...      w_set_config=False
    Light Bring Airphone TL to on Air status without reboot    w_Config_WTS_for_Airphone=False
