*** Settings ***
Documentation    Commissioning keywords for CB011006: B17 Pooling IWK

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    ./../../L2/libraries/vendor_file_modifier.py         WITH NAME   vendor_file_modifier


*** Keywords ***

#-----------For SCF.xml Changes------------------------------------------------------------------------------------------------------[150 characters]

Initial commissioning for IWK17
    Download and Modify Vendor File
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${distName_NRBTS}=      Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+
    ${distName_NRCELL}=     Get distNames from Local SCF File  scf_path=${original_gnb_scf}  regex=NRBTS-[0-9]+/NRCELL-[0-9]+
    sort list    ${distName_NRCELL}
    FOR    ${dist_name}                                       ${p_name}                            ${value}                        IN
    ...    ${distName_NRBTS[0]}                               nsaInactivityTimer                   7200
    ...    ${distName_NRBTS[0]}                               actIpThpt                            true
    ...    ${distName_NRBTS[0]}                               actEnhancedLinkAdaptation            true
    ...    ${distName_NRBTS[0]}                               actScheUePooling                     true
    ...    ${distName_NRBTS[0]}                               actBbPoolTddFr1                      true
    ...    ${distName_NRBTS[0]}                               actBbPoolTddFr1AlgEnh                true
    ...    ${distName_NRBTS[0]}                               actConnRrcPooling                    true
    ...    ${distName_NRBTS[0]}                               actSlowPrbPooling                    true
    ...    ${distName_NRBTS[0]}                               actSlowPrbPoolingFddFr1Enh           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actShortBsrLimitAdaptation           true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}                freqBandIndicatorNR                  7
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwDl                               50MHz     # to be changed to 50MHz later
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   chBwUl                               50MHz     # to be changed to 50MHz later
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnDl                            531000
    ...    ${distName_NRCELL[${fdd_cell_1}-1]}/NRCELL_FDD-1   nrarfcnUl                            507000
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actShortBsrLimitAdaptation           true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}                freqBandIndicatorNR                  7
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwDl                               50MHz     # to be changed to 50MHz later
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   chBwUl                               50MHz     # to be changed to 50MHz later
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnDl                            531000
    ...    ${distName_NRCELL[${fdd_cell_2}-1]}/NRCELL_FDD-1   nrarfcnUl                            507000
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                actShortBsrLimitAdaptation           true
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                actDl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                actUl256Qam                          true
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                gscnOrSsPbchArfcn                    ${gscn_fdd_cell_1}
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}                freqBandIndicatorNR                  7
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}/NRCELL_FDD-1   chBwDl                               50MHz     # to be changed to 50MHz later
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}/NRCELL_FDD-1   chBwUl                               50MHz     # to be changed to 50MHz later
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}/NRCELL_FDD-1   nrarfcnDl                            531000
    ...    ${distName_NRCELL[${fdd_cell_3}-1]}/NRCELL_FDD-1   nrarfcnUl                            507000
        Set Element   dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Download and Modify Vendor File
    ${oam_alias}=    connect.Setup OAM http session
    #configuration_directory is a suite variable defined in common_keywords.robot
    ${vendor_file_path}=    set variable    ${configuration_directory}/vendor_lte.xml
    admin.download_vendor_file    target_file_name=${vendor_file_path}    connection=${oam_alias}
       copy file  ${vendor_file_path}  ${vendor_file_path}.bkp
       run keyword and ignore error    Modify Vendor File for CS Size    64    100     200    #  820    1640
       run keyword and ignore error    Modify Vendor File for CS Size    48    100     200    #  615    1230
       run keyword and ignore error    Modify Vendor File for CS Size    32    100     200    #  410     820
       run keyword and ignore error    Modify Vendor File for CS Size    24    100     200    #  864     424
       run keyword and ignore error    Modify Vendor File for CS Size    72    100     200    # 1728     864
    admin.set_vendor_file  vendor_file=${vendor_file_path}  connection=${oam_alias}
    connect.Teardown OAM http session


Modify Vendor File for CS Size
    [Arguments]  ${csSize}  ${maxNumLayerPrbL1Sp}  ${maxNumStreamPrbL1Sp}
    ${filter_criteria}=    create dictionary
    ...  bbHwVariant=ABIO
    ...  csSize=${csSize}
    ${data_to_be_modified}=    create dictionary
    ...  maxNumLayerPrbL1Sp=${maxNumLayerPrbL1Sp}
    ...  maxNumStreamPrbL1Sp=${maxNumStreamPrbL1Sp}
    ...  maxNumWbStreamPrbL1Sp=${maxNumStreamPrbL1Sp}
    ${path_in_xml}=  vendor_file_modifier.get_xml_path_for_list  listname=bbL1SpPrbInitCapacity
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${configuration_directory}/vendor_lte.xml
    ...  xml_path=${path_in_xml}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
