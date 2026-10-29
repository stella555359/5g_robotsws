*** Settings ***
Documentation    This file contains 5GC001200 keywords

Library           ute_wtssim
Library           XML
Library           taf.analyzer.pdml    WITH NAME    pdml_analyser
Library           ../../../Resources/Python/Utilities.py    WITH NAME    utilities
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/robot/swconfig_keywords.robot
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot
Resource          ../Resources/Common_Keywords.robot
Resource          ./5GC001200_ConfigManagement_Admin.robot
Resource          ./5GC001200_Delta_Keywords.robot

*** Variables ***
${WTS_CFG_PATH}                          ${CURDIR}/cfg
${WAIT_TIME_FOR_TESTMODE}                5s
${WAIT_TIME_AFTER_UL_SWITCH}             30s
${WAIT_AFTER_TRAFFIC}                    60s
${MAX_SCG_PKTS_DIFF_NR}                  400
${MAX_SCG_PKTS_DIFF_NR+LTE}              4000
${EXPECTED_MCG_PKTS_BEFORE_UL_SWITCH}    0
@{DTX_ELEMENTS}                          enablePuschDtx,1,forcedDtxConfig/forcedDtx
...                                      puschTotalDtxOccurrence,3200,forcedDtxConfig/forcedDtx
...                                      puschDtxInterval,2,forcedDtxConfig/forcedDtx
...                                      enablePucchDtx,1,forcedDtxConfig/forcedDtx
...                                      pucchDtxOccurrence,3200,forcedDtxConfig/forcedDtx
...                                      pucchDtxInterval,2,forcedDtxConfig/forcedDtx
@{PHR_ELEMENTS}                          powerHeadroomLevelMode,0,phrOverrideTestModeConfig/phrOverrideTestMode
...                                      powerHeadroomLevelStart,-23,phrOverrideTestModeConfig/phrOverrideTestMode
...                                      powerHeadroomLevelMin,-24,phrOverrideTestModeConfig/phrOverrideTestMode
...                                      powerHeadroomLevelMax,40,phrOverrideTestModeConfig/phrOverrideTestMode
...                                      powerHeadroomLevelStepSize,-63,phrOverrideTestModeConfig/phrOverrideTestMode
...                                      powerHeadroomLevelPeriod,1,phrOverrideTestModeConfig/phrOverrideTestMode
...                                      pcMax,35,phrOverrideTestModeConfig/phrOverrideTestMode

*** Keywords ***
Suite Setup
    Suite Common Keywords    feature_folder=5GC001200
    Store Original Dynamic UL Data Split Mode Parameter In GNB For Revert
    Store Original Radio Link Detection Parameter In GNB For Revert
    Enable Dynamic UL Data Split Mode Feature Flag in GNB
    Enable Radio Link Detection in GNB
    Wait for gNB To Be Ready

Suite Teardown
    Common Suite Teardown Keywords
    Run Keyword and Ignore Error    UE Detach    ue_id=${UE_ID}
    Revert Dynamic UL Data Split Mode Parameter In GNB to Original Value
    Revert Radio Link Detection Parameter In GNB to Original Value

Test Setup
    [Arguments]    ${primary_path}    ${data_split_threshold}=infinity
    Prepare Environment Based On Run Type    cfg_type=custom
    Store Original Primary Path and Data Split Threshold Parameters in GNB For Revert
    Configure Primary Path and Data Split Threshold in GNB    ${primary_path}    ${data_split_threshold}
    Store Original Measurement Threshold Parameters in GNB For Revert
    Configure Measurement Thresholds in GNB
    Store Original DTX Parameters in GNB For Revert
    Configure DTX Parameters in GNB
    Enable DTX Parameters in GNB Swconfig File
    Update PHR Parameters in Airphone Config XML File
    Add DTX Parameters in Airphone Config XML File
    Configure SIGNR Parameter in Airphone Config XML File
    Reboot Components after swconfig update
    Wait for gNB To Be Ready
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Start WTS And Extablish X2 Link

Test Teardown
    Stop All Data Transfer    ue_id=${UE_ID}   bearer=${BEARER_ID}
    UE Detach    ue_id=${UE_ID}
    Common Test Teardown
    Restore Original GNB swconfig File
    Revert Primary Path and Data Split Threshold in GNB to Original Value
    Revert Measurement Threshold Parameters in GNB to Original Value
    Revert DTX Parameters in GNB to Original Value

Enable DTX Parameters in GNB Swconfig File
    [Documentation]    This Keyword will enable the 1200 Feature R&D Parameters
    ...    which will be helpful to detect UL Radio problems in GNB.
    ...    #1200 R&D:
    ...    #rdDlHarqDtxEnabled=true
    ...    0x580149=1
    ...    #rdCsiDtxEnabled=true
    ...    0x580150=1
    ...    #rdPuschDataDtxEnabled=true
    ...    0x580151=1
    ...    #rdUlSplitWaiterExpiryTime=1000
    ...    0x580152=1000
    ${original_swconfig_path}    Download SWConfig File From GNB    sw_config_path=/tmp/
    ${updated_swconfig_path_gnb}    Modify SWConfig File For GNB    sw_config_filepath=${original_swconfig_path}
    ...    0x580149=1    0x580150=1    0x580151=1    0x580152=1000
    Upload Swconifg File to GNB And Perform Signature    ${updated_swconfig_path_gnb}
    Set Test Variable    ${original_swconfig_path}

Add DTX Parameters in Airphone Config XML File
    [Documentation]    Set DTX configurable parameters in Airphone conifg xml file
    ${ap_xml_file_obj}    XML.Parse Xml    ${AP_XML_PATH}
    Add Element    source=${ap_xml_file_obj}    element=<forcedDtxConfig/>
    Add Element    source=${ap_xml_file_obj}    element=<forcedDtx/>    index=0    xpath=forcedDtxConfig
    Set Element Attribute    source=${ap_xml_file_obj}    name=index    value=0    xpath=forcedDtxConfig/forcedDtx
    Add XML Element with Element Text And Save XML File    ${DTX_ELEMENTS}    ${ap_xml_file_obj}    ${AP_XML_PATH}

Reboot Components after swconfig update
    Reboot GNB
    Reboot Airphone For Recovery

Restore Original GNB swconfig File
    Upload Swconifg File to GNB And Perform Signature    ${original_swconfig_path}
    Reboot GNB
    Reboot Airphone For Recovery
    Wait for gNB To Be Ready

Modify PHR Parameters in Airphone Config XML File
    [Documentation]    Set PowerHeadRoom parameters in Airphone conifg xml file
    ${ap_xml_file_obj}    XML.Parse Xml    ${AP_XML_PATH}
    Update XML Element Text and Save XML File    ${PHR_ELEMENTS}    ${ap_xml_file_obj}    ${AP_XML_PATH}

Update XML Element Text and Save XML File
    [Documentation]    This Keyword can be used to update element text for already existing
    ...                elements in XML File and Save the XML File with changes.
    [Arguments]    ${element_type}    ${xml_obj}    ${xml_path}
    FOR    ${element_entry}    IN    @{element_type}
        ${element}    ${text}    ${xpath}    Evaluate    "${element_entry}".split(',')
        Set Element Text    source=${xml_obj}    text=${text}    xpath=${xpath}/${element}
    END
    Save XML    source=${xml_obj}    path=${xml_path}

Add PHR Parameters in Airphone Config XML File
    [Documentation]    Adds PowerHeadRoom parameters in Airphone conifg xml file
    ${ap_xml_file_obj}    XML.Parse Xml    ${AP_XML_PATH}
    Add Element    source=${ap_xml_file_obj}    element=<phrOverrideTestModeConfig/>
    Add Element    source=${ap_xml_file_obj}    element=<phrOverrideTestMode/>    index=0
    ...    xpath=phrOverrideTestModeConfig
    Set Element Attribute    source=${ap_xml_file_obj}    name=index    value=0
    ...    xpath=phrOverrideTestModeConfig/phrOverrideTestMode
    Add XML Element with Element Text And Save XML File    ${PHR_ELEMENTS}    ${ap_xml_file_obj}    ${AP_XML_PATH}

Configure SIGNR Parameter in Airphone Config XML File
    [Documentation]    Set SIGNR parameter in Airphone conifg xml file
    ${ap_xml_file_obj}    XML.Parse Xml    ${AP_XML_PATH}
    Set Element Text    source=${ap_xml_file_obj}    text=20    xpath=srsTestModeConfig/srsTestMode/sinrTargetSrs
    Save XML    source=${ap_xml_file_obj}    path=${AP_XML_PATH}

Validate UL Primary path switches to LTE
    [Arguments]    ${lte_cellgroup_index}=0
    ${pdml_file}    Stop pcap and convert X2AP to pdml
    ${rrc_pdml_entries}    pdml_analyser.get_pdml_entries   file_name=${pdml_file}  field_name=x2ap.SgNBModificationRequired_element
    ...    attrib_name=showname    attrib_value=SgNBModificationRequired
    ${attr_value}    pdml_analyser.get_attrib_value_from_pdml_entries    pdml_entries=${rrc_pdml_entries}
    ...    field_name=nr-rrc.cellGroup    attrib_name=showname
    Should Contain    ${attr_value}[0]    cellGroup: ${lte_cellgroup_index}
    ...    msg= pdml attribute value: "${attr_value}" doesnot contain expected cause.

Store Original Dynamic UL Data Split Mode Parameter In GNB For Revert
    ${original_ul_data_splitmode_parameter}=    Get Dynamic UL Data Split Mode Parameter From GNB
    Set Suite Variable    ${original_ul_data_splitmode_parameter}

Revert Dynamic UL Data Split Mode Parameter In GNB to Original Value
    Update Dynamic UL Data Split Mode Parameter in gNB    ${original_ul_data_splitmode_parameter}

Store Original Radio Link Detection Parameter In GNB For Revert
    ${original_radio_link_parameter}=    Get Radio Link Detection Parameter From GNB
    Set Suite Variable    ${original_radio_link_parameter}

Revert Radio Link Detection Parameter In GNB to Original Value
    Update Radio Link Detection Parameter in gNB    ${original_radio_link_parameter}

Store Original Primary Path and Data Split Threshold Parameters in GNB For Revert
    ${nrdrb_object_dict}    Get Primary Path and Data Split Threshold From GNB
    Set Suite Variable    ${nrdrb_object_dict}

Revert Primary Path and Data Split Threshold in GNB to Original Value
    Update Primary Path and Data Split Threshold in gNB    ${nrdrb_object_dict}

Store Original Measurement Threshold Parameters in GNB For Revert
    ${measurement_threshold_dict}    Get Measurement Threshold Parameters From GNB
    Set Suite Variable    ${measurement_threshold_dict}

Revert Measurement Threshold Parameters in GNB to Original Value
    Update Measurement Threshold Parameters in gNB    ${measurement_threshold_dict}

Store Original DTX Parameters in GNB For Revert
    ${dtx_params_dict}    Get DTX Parameters From GNB
    Set Suite Variable    ${dtx_params_dict}

Revert DTX Parameters in GNB to Original Value
    Update DTX Parameters in gNB    ${dtx_params_dict}

Verify UL Data Transmission on LTE
    [Arguments]    ${primary_path}
    UL Data Transmission Should not happen on SCG    ${primary_path}
    UL Data Transmission Should happen on MCG

Store Packets Sent Before UL NR Bad Quality Detection
    ${total_pkts_sent_scg_before_ul_switch}    ${total_pkts_recieved_scg_before_ul_switch}
    ...    ${total_pkts_sent_mcg_before_ul_switch}    ${total_pkts_recieved_mcg_before_ul_switch}
    ...    Get Packets Sent And Received For SCG and MCG
    Set Test Variable    ${total_pkts_sent_scg_before_ul_switch}
    Set Test Variable    ${total_pkts_sent_mcg_before_ul_switch}

UL Data Transmission Should not happen on SCG
    [Arguments]    ${primary_path}
    Packet Difference Should be With In Range    ${total_pkts_sent_scg_after_ul_switch}
    ...    ${total_pkts_sent_scg_before_ul_switch}    ${primary_path}

Store Packets Sent After UL Switches to LTE
    ${total_pkts_sent_scg_after_ul_switch}    ${total_pkts_recieved_scg_after_ul_switch}
    ...    ${total_pkts_sent_mcg_after_ul_switch}    ${total_pkts_recieved_mcg_after_ul_switch}
    ...    Get Packets Sent And Received For SCG and MCG
    Set Test Variable    ${total_pkts_sent_scg_after_ul_switch}
    Set Test Variable    ${total_pkts_sent_mcg_after_ul_switch}

UL Data Transmission Should happen on MCG
    Should be True    ${${total_pkts_sent_mcg_after_ul_switch}} > ${${total_pkts_sent_mcg_before_ul_switch}}
    ...    msg = UL Data is flowing over Sgnb

Packet Difference Should be With In Range
    [Arguments]    ${test_end_packet_count}    ${test_start_packet_count}    ${primary_path}
    ${allowed_difference}    Set Variable If    "${primary_path}"=="NR"    ${MAX_SCG_PKTS_DIFF_NR}
    ...    ${MAX_SCG_PKTS_DIFF_NR+LTE}
    ${diff_packets}    Evaluate    ${${test_end_packet_count}} - ${${test_start_packet_count}}
    Should Be True    ${${diff_packets}} <= ${${allowed_difference}}
    ...    msg = UL Data Transfer is happening on SCG even after UL Switches to LTE.

Validate Packets Sent in MCG Should Be Zero Before LTE Switch
    Should Be Equal As Integers    ${${total_pkts_sent_mcg_before_ul_switch}}
    ...    ${${EXPECTED_MCG_PKTS_BEFORE_UL_SWITCH}}
    ...    msg = UL Data Packets on MCG is not equal to ${${EXPECTED_MCG_PKTS_BEFORE_UL_SWITCH}}

Start Uplink Traffic towards NR
    [Documentation]    This keyord can be used to start the uplink traffic based on burst and size.
    ...                For example: If "ulDataSplitThreshold" parameter is set to b800
    ...                then above 800 burst, traffic will flow in NR and below 800 burst
    ...                traffic will flow in LTE.
    Start Custom Data Transfer    bearer=2    ue=1    dir=ul    trf_id=1    burst=20
    ...    size=799    period_ms=4ms

Start Uplink Traffic towarss LTE
    Start Custom Data Transfer    bearer=2    ue=1    dir=ul    trf_id=2    mbps=2

Start Custom Data Transfer
    [Documentation]    This Keyword can be used to start a data transfer with custom options
    ...                Availale Options are dir, trf_id, burst, size, period_ms, mbps
    [Arguments]    ${bearer}    ${ue}   &{kwargs}
    ${command}    utilities.prepare_custom_egate_command    bearer=${bearer}    ue=${ue}    &{kwargs}
    Execute Egate Command    ${command}
    [Return]

Validate Packets Sent in MCG and SCG Should Not Be Zero Before LTE Switch
    ${status}    Evaluate    ${${total_pkts_sent_mcg_before_ul_switch}} > ${0}
    Should Be Equal As Strings    ${status}    True
    ...    msg = UL Data Packets on MCG ${${total_pkts_sent_mcg_before_ul_switch}} is equal to Zero.
    ${status}    Evaluate    ${${total_pkts_sent_scg_before_ul_switch}} > ${0}
    Should Be Equal As Strings    ${status}    True
    ...    msg = UL Data Packets on SCG ${${total_pkts_sent_scg_before_ul_switch}} is equal to Zero.

Update PHR Parameters in Airphone Config XML File
    [Documentation]    This Keyword can be used to add or modify PHR parameters in Airphone conifg xml file
    ${ap_xml_file_obj}    XML.Parse Xml    ${AP_XML_PATH}
    ${status}    Run Keyword and Return Status    Element Should Exist    source=${ap_xml_file_obj}
    ...    xpath=phrOverrideTestModeConfig
    Run Keyword If    ${status}    Modify PHR Parameters in Airphone Config XML File    ELSE
    ...    Add PHR Parameters in Airphone Config XML File

Add XML Element with Element Text And Save XML File
    [Documentation]    This Keyword can be used to add new xml elements and also to set text for the
    ...                elements in XML File and Save the XML File with changes.
    [Arguments]    ${element_type}    ${xml_obj}    ${xml_path}
    FOR    ${element_entry}    IN    @{element_type}
        ${element}    ${text}    ${xpath}    Evaluate    "${element_entry}".split(',')
        Add Element    source=${xml_obj}    element=<${element}/>    xpath=${xpath}
        Set Element Text    source=${xml_obj}    text=${text}    xpath=${xpath}/${element}
    END
    Save XML    source=${xml_obj}    path=${xml_path}
