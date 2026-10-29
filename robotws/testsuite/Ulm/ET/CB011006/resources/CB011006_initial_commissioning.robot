*** Settings ***
Documentation    Commissioning keywords for CB011006: common changes



*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Modify scf.xml for 2TDD+2FDD Setup
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                 actAutoPrachConfigIndexFdd           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  7
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwDl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwUl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnDl                            531000
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnUl                            507000
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_2}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  3
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwDl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwUl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnDl                            368500
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnUl                            349500
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n270
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl}=  create dictionary
    ...    cRbSizeUl             sameAsDl
    ...    cRbStartUl            sameAsDl
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthUl   elements=${locationAndBandwidthUl}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
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


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Modify scf.xml for 2TDD+2FDD only n7 Setup
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  7
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwDl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwUl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnDl                            531000
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnUl                            507000
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  7
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwDl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwUl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnDl                            531000
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnUl                            507000
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n270
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl}=  create dictionary
    ...    cRbSizeUl             sameAsDl
    ...    cRbStartUl            sameAsDl
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthUl   elements=${locationAndBandwidthUl}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
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


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Modify scf.xml for 1FDD Setup
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  7
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwDl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwUl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnDl                            531000
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnUl                            507000
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n270
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthUl
    ${locationAndBandwidthUl}=  create dictionary
    ...    cRbSizeUl             sameAsDl
    ...    cRbStartUl            sameAsDl
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthUl   elements=${locationAndBandwidthUl}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
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

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Modify scf.xml for 1FDD+3TDD Setup
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                         ${p_name}                            ${value}         IN
    ...    ${distName_NRBTS[0]}                 nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                 actIpThpt                            true
    ...    ${distName_NRBTS[0]}                 actEnhancedLinkAdaptation            true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  7
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwDl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwUl                               50MHz
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnDl                            531000
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnUl                            507000
        Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Set List    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl
    ${locationAndBandwidthDl}=  create dictionary
    ...    cRbSizeDl             n270
    ...    cRbStartDl            crb0
    scf.add_item_to_list    dist_name=${distName_NRBTS[0]}/BWP_PROFILE-4    list_name=locationAndBandwidthDl   elements=${locationAndBandwidthDl}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
