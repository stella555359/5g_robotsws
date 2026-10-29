*** Settings ***
Documentation    Example usage of the tools
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/vendorfile_tools/vendorfile_manager.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot


*** Keywords ***

Modify single parameter
    Download Default Vendorfile    local_path=${LOG_PATH}
    ${filter_criteria}=    Create Dictionary
    ...  bbPoolMode=load-metric
    ${data_to_be_modified}=    Create Dictionary
    ...  bbPoolMode=round-robin
    ${path_to_xml}=  Get Xml Path For Parameter
    ...  parametername=bbPoolMode
    Modify Vendorfile        local_path=${LOG_PATH}
    ...                      filter_criteria=${filter_criteria}
    ...                      data_to_be_modified=${data_to_be_modified}
    ...                      xml_path=${path_to_xml}
    Upload Vendorfile        local_path=${LOG_PATH}


Modify multiple parameters
    Download Default Vendorfile      local_path=${LOG_PATH}
    ${filter_criteria}=     Create Dictionary
    ...     bbHwVariant=ABIP
    ...     csSize=48
    ${data_to_be_modified}=     Create Dictionary
    ...     maxNumLayerPrbL1Sp=648
    ...     maxNumStreamPrbL1Sp=648
    ${path_to_xml}=   Get Xml Path For List
    ...     listname=bbL1SpPrbCapacity

    ${filter_criteria_bbPool}=    Create Dictionary
    ...  bbPoolMode=load-metric
    ${data_to_be_modified_bbPool}=    Create Dictionary
    ...  bbPoolMode=round-robin
    ${path_to_xml_bbPool}=  Get Xml Path For Parameter
    ...  parametername=bbPoolMode

    Modify Vendorfile        local_path=${LOG_PATH}
    ...                      filter_criteria=${filter_criteria}
    ...                      data_to_be_modified=${data_to_be_modified}
    ...                      xml_path=${path_to_xml}

    Modify Vendorfile        local_path=${LOG_PATH}
    ...                      filter_criteria=${filter_criteria_bbPool}
    ...                      data_to_be_modified=${data_to_be_modified_bbPool}
    ...                      xml_path=${path_to_xml_bbPool}

    Upload Vendorfile        local_path=${LOG_PATH}

*** Test Cases ***

Modify Single
    Modify Single Parameter

Modify Multiple
    Modify Multiple Parameters
