*** Settings ***
Documentation
...    copyright: Nokia


*** Keywords ***
Check DL PRB Allocated by BBRM
    [Documentation]     Check that the number of DL PRB allocated by BBRM for UE5(NRCELL=54, low tput) is lower than
    ...                UE1(NRCELL=50, high tput)

    ${Average_PRB_Allocated_Cell_50_Dl}     Avg PRB Alloc For Cell DL
    ...                            file_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_switch/TTI_TRACE_dl
    ...                            cell_id=50

    ${Average_PRB_Allocated_Cell_54_Dl}     Avg PRB Alloc For Cell DL
    ...                            file_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_switch/TTI_TRACE_dl
    ...                            cell_id=54

    should be true      ${Average_PRB_Allocated_Cell_50_Dl} > ${Average_PRB_Allocated_Cell_54_Dl}

Check UL PRB Allocated by BBRM
    [Documentation]     Check that the number of UL PRB allocated by BBRM for UE5(NRCELL=54, low tput) is lower than
    ...                UE1(NRCELL=50, high tput)

    ${Average_PRB_Allocated_Cell_50_Ul}     Avg PRB Alloc For Cell UL
    ...                            file_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_switch/TTI_TRACE_ul
    ...                            cell_id=50

    ${Average_PRB_Allocated_Cell_54_Ul}     Avg PRB Alloc For Cell UL
    ...                            file_path=${OUTPUT_DIR}/TTI_TRACE_CB008367_switch/TTI_TRACE_ul
    ...                            cell_id=54

    should be true      ${Average_PRB_Allocated_Cell_50_Ul} > ${Average_PRB_Allocated_Cell_54_Ul}

OAM Run Command
    [Documentation]                 Execute an OAM admin command and return the output
    ...                             It's up to the caller to analyze the output and to extract needed data
    ...
    ...                             *Argument details:*
    ...                              - oam : Oam identity (ex: ${GNB_DU.oam} or ${GNB_CU.oam}).
    ...                              - cmd : the command to be run (available commands are provided in the following URL
    ...                                      https://docs.taf.nsn-rdnet.net/taf.sbts.oam.coam.admin/)
    ...                                      documentation see TAF documentation for list
    ...                              - cmdArgs : dictionary containing the list of parameters needed to run the command
    [Arguments]                     ${oam}=${GNB_DU.oam}
    ...                             ${cmd}=${None}
    ...                             ${cmd_args}=${None}

    return from keyword if          '${cmd}' == '${None}'                   ${None}
    ${result}                           Call Method
    ...                                 ${oam}                              runOamCmd
    ...                                 ${cmd}                              ${cmd_args}
    [Return]                        ${result}

Download and Modify L1Pool Vendor File and perform commissioning
    [Arguments]    ${scf}
    ${oam_alias}=    connect.Setup OAM session
    ${vendor_path}=    Set Variable    ${OUTPUT_DIR}/vendor_lte.xml
    fix_vlan_id_in_scfc   input_filepath=${scf}
    admin.download_vendor_file    target_file_name=${vendor_path}    connection=${oam_alias}
    Backup Vendor Files  file_path=${vendor_path}
    Modify L1Pool Vendor File
    admin.set_vendor_file  vendor_file=${vendor_path}  connection=${oam_alias}
    ${paths} =    List Directory    ${OUTPUT_DIR}    full_CB008367_IWK3_2_ABIP_100_MHz_Large_Small_PWS_BWP*MOD*.xml
    admin.perform_commissioning    scf_file=${OUTPUT_DIR}/${paths}[0]
    ...                            connection=${oam_alias}
    ...                            skip_parameter_relation_errors=True
    ...                            timeout=600
    connect.Teardown OAM session    connection=${oam_alias}

Modify L1Pool Vendor File
    ${filter_criteria}=    Create Dictionary
    ...  bbHwVariant=ABIP
    ...  csSize=4811
    ...  direction=DL
    ...  l1PoolType=NR_L1Pool_Thor_TDD_FR1_eCPRI

    ${data_to_be_modified}=    Create Dictionary
    ...  maxNumLayerPrbL1Sp=1000
    ...  maxNumStreamPrbL1Sp=1000
    ...  maxNumWbStreamPrbL1Sp=900


    ${path_in_xml}=  vendor_file_modifier.get_xml_path_with_given_list  listname=bbL1SpPrbInitCapacity
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  xml_path=${path_in_xml}
