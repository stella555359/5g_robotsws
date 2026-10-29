*** Settings ***
Documentation    This file contains 5GC001301 keywords

Library           OperatingSystem
Library           XML
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/robot/airphone.robot
Resource          ./5GC001301_ConfigManagement_Admin.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot
Resource          ../../../Resources/robot/swconfig_keywords.robot
Library           taf.analyzer.pdml    WITH NAME    pdml_analyser

*** Variables ***
${prach_config_index}    196
${wait_time}               5s

*** Keywords ***
Suite Setup
    Suite Common Keywords    feature_folder=5GC001301
    Wait for gNB To Be Ready
    Store Original Prach Parameters in GNB For Revert

Suite Teardown
    Common Suite Teardown Keywords
    Revert FrameFormat in GNB to original Value
    Reboot GNB
    Check GNB Status before WTS Start
    Restore APSwconifg File to Original
    Reboot Airphone For Recovery

Store Original Prach Parameters in GNB For Revert
    Get List of Prach Parameters From gNB

Update PRACH params in WTS xml
    [Arguments]    &{prach_params}
    [Documentation]    Set PRACH configurable parameters in WTS .xml file
    ${ap_xml_file_obj}    XML.Parse Xml    ${AP_XML_PATH}
    Set Element Text    source=${ap_xml_file_obj}    text=${prach_params['prachPreambleFormat']}
    ...    xpath=rachConfigConfig/rachConfig/prachPreambleFormat
    Set Element Text    source=${ap_xml_file_obj}    text=${prach_params['prachStartSymbol']}
    ...    xpath=rachConfigConfig/rachConfig/prachStartSymbol
    Set Element Text    source=${ap_xml_file_obj}    text=${prach_params['ssBurstSetPeriod']}
    ...    xpath=cellGroupConfig/cellGroup/ssBurstSetPeriod
    Set Element Text    source=${ap_xml_file_obj}    text=${prach_params['dlBandwidth']}
    ...    xpath=cellGroupConfig/cellGroup/dlBandwidth
    Set Element Text    source=${ap_xml_file_obj}    text=${prach_params['ulBandwidth']}
    ...    xpath=cellGroupConfig/cellGroup/ulBandwidth
    Save XML    source=${ap_xml_file_obj}    path=${AP_XML_PATH}

Generate AP swconfig file for desired AP Framerate
    [Arguments]    ${apframe}
    ${downloaded_swconfig_path}    Download SWConfig File From AP    sw_config_path=/tmp/
    set suite variable    ${downloaded_swconfig_path}
    ${updated_swconfig_path_ap}    Modify SWConfig File For AP    sw_config_filepath=${downloaded_swconfig_path}
    ...    0x70645=${Apframe}
    Upload Swconifg File to AP And Perform Signature    ${updated_swconfig_path_ap}

Restore APSwconifg File to Original
    Upload Swconifg File to AP And Perform Signature    ${downloaded_swconfig_path}

Validate Prachconfigindex in SgNBadditionReqAck msg From Pcap
   [Arguments]    ${prach_config_index}
    ${pdml_file}    Stop pcap and convert X2AP to pdml
    ${pdml_entries}    pdml_analyser.get_pdml_entries   file_name=${pdml_file}  field_name=x2ap.SgNBAdditionRequestAcknowledge_element
    ...    attrib_name=showname    attrib_value=SgNBAdditionRequestAcknowledge
    ${attr_value}    pdml_analyser.get_attrib_value_from_pdml_entries    pdml_entries=${pdml_entries}
    ...    field_name=nr-rrc.prach_ConfigurationIndex    attrib_name=showname
    Should Contain    ${attr_value}[0]    ${prach_config_index}
    ...    msg= pdml attribute value: "${attr_value}[0]" doesnot contain expected value: ${prach_config_index}

Wait before Validation
    Sleep    ${wait_time}
