*** Settings ***
Library     taf.sbts.oam.coam.admin    WITH NAME   COAM

Documentation    :copyright: Nokia
...              :authors: Kamil Galczynski
...              :contact: kamil.galczynski@nokia.com

*** Variables ***
${PRIVATE_LOCAL_PATH}        /home/ute/kiss_files/private/
${PRIVATE_CONFIG_ADDRESS}     "https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git"

*** Keywords ***
Get and Update BSR File
    [Arguments]     ${bsr_file_name}
    Run    git clone ${PRIVATE_CONFIG_ADDRESS} ${PRIVATE_LOCAL_PATH}
    ${ret}    COAM.Update Software    ${PRIVATE_LOCAL_PATH}/BSR_FILE/${bsr_file_name}
    COAM.teardown admin

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

Download and Modify Vendor File and perform commissioning
	[Arguments]  ${scf}
    ${oam_alias}=    connect.Setup OAM session
    ${vendor_path}=    Set Variable    ${OUTPUT_DIR}/vendor_lte.xml
    Find And Fix Scfc   scfc_filename=${scf}.xml
    admin.download_vendor_file    target_file_name=${vendor_path}    connection=${oam_alias}
    Backup Vendor File  file_path=${vendor_path}
    Modify Vendor
    admin.set_vendor_file  vendor_file=${vendor_path}  connection=${oam_alias}
    ${paths} =    List Directory    ${OUTPUT_DIR}    ${scf}*MOD*.xml
    admin.perform_commissioning    scf_file=${OUTPUT_DIR}/${paths}[0]
    ...                            connection=${oam_alias}
    ...                            skip_parameter_relation_errors=True
    ...                            timeout=600
    connect.Teardown OAM session    connection=${oam_alias}

Backup Vendor File
    [Arguments]  ${file_path}
    Copy File	${file_path}  ${file_path}.orig

Modify Vendor
    ${filter_criteria}=    Create Dictionary
    ...  xEc=20

    ${data_to_be_modified}=    Create Dictionary
    ...  xEc=14


    ${path_in_xml}=  vendor_file_modifier.get_xml_path_for_xec
    vendor_file_modifier.modify_vendor_file
    ...  filter_criteria=${filter_criteria}
    ...  data_to_be_modified=${data_to_be_modified}
    ...  path_to_reference_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  path_to_modified_vendor_file=${OUTPUT_DIR}/vendor_lte.xml
    ...  xml_path=${path_in_xml}
