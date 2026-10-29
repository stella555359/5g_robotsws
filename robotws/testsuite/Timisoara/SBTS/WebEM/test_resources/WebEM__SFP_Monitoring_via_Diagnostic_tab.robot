*** Settings ***
Documentation
    ...  This test case is created to monitoring SFP via Diagnostic Tab
    ...  Verify if all cells on SBTS are working.
    ...  Open SFP Monitoring via Diagnostic Tab.
    ...  Check parameters for the first table.
    ...  Specific parameters for different modules are: Source, Destination, Link Speed, Fiber Length, Physical Port, Serial Number,
    ...  Transceiver Identifier, Vendor, Connector Type.
    ...  Common Parameters for all modules are: Link Type, SFP Wavelength and SFP Transmission Rate.
    ...  Save Link Status.
    ...  Go to Detailed Site View and check all parameters for specific module.
    ...  Open SFP Monitoring via Diagnostic Tab.
    ...  Check parameters for the second table.
    ...  Specific parameters for module are: Source, Physical Port, Serial Number, Transceiver Identifier, Vendor, Connector Type.
    ...  Common Parameters for all modules are: Link Type, SFP Wavelength and SFP Transmission Rate.
    ...  Save Link Status.
    ...  Go to Detailed Site View and check all parameters for specific module.
    ...  Open SFP Monitoring via Diagnostic Tab.
    ...  Save All Status.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__SFP_Monitoring_via_Diagnostic_tab
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21627
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21627 - Initial TAT creation
    ...  - 30.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23215 - SFP nominal transmission rate changed position
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 20.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24124 - Linkspeed display differs in Details Site View and SFP monitoring
    ...  - 08.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25475 - SFP Transmission rate value is not visible correct in Detailed Site View
    ...  - 15.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28103 - First module is not visible in Detailed Site View
    ...  - 28.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28512 - Adding check for Q/S_RF SFP Type

    Set Tags  CA-WebEM  OWNER-emina.stefanovici@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B

    Step1: Verify Cells On SBTS And Open SFP Monitoring
    Step2: Check Parameters For The First Table
    Step3: Check Parameters For The Second Table
    Step4: Save All Status


Step1: Verify Cells On SBTS And Open SFP Monitoring
    Log  Step1: Verify cells on SBTS  console=true
    Check All Cells From WebEM
    Open SFP Monitoring


Step2: Check Parameters For The First Table
    Log  Step2: Check parameters for the first table  console=true
    ${count}  SeleniumLibrary.Get Element Count
    ...  //*[contains(@class, "sfp-panel-container")]/div/div/div[1]/sfp-table/div[2]/table/tbody/tr
    ${fist_table}  Get Text  //*[contains(@class, "sfp-panel-container")]/div/div/div[1]/sfp-table/div[1]
    Log  Check table ${fist_table}  console=true
    FOR  ${index}  IN RANGE  1  ${count}+1
        Log  For row ${index} parameters are:\n  console=true
        ${button}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-panel-container")]/div/div/
        ...  div[1]/sfp-table/div[2]/table/tbody/tr[${index}]
        Click Element  ${button}
        Get All Parameters From First Table  ${index}
        Save Link Status  ${RMOD_NAME}  ${BBMOD_NAME}
        Go To Site View
        Click Element  ${DETAILED_SITE_VIEW}
        Sleep  5s
        Check Parameters From Detailed Site View For The First Table
        Open SFP Monitoring
    END


Step3: Check Parameters For The Second Table
    Log  Step3: Check parameters for the second table  console=true
    ${status_second_table}  Run Keyword And Return Status
    ...  Element Should Be Visible
    ...  //*[contains(@class, "sfp-panel-container")]/div/div/div[1]/sfp-table/div[4]
    Run Keyword If  ${status_second_table}==${FALSE}
    ...  Run Keywords
    ...  Log  The second table does not exist, test will continue!  console=true
    ...  AND
    ...  Return From Keyword
    ${second_table}  Get Text
    ...  //*[contains(@class, "sfp-panel-container")]/div/div/div[1]/sfp-table/div[4]
    Log  Check table ${second_table}  console=true
    ${count}  SeleniumLibrary.Get Element Count
    ...  //*[contains(@class, "sfp-panel-container")]/div/div/div[1]/sfp-table/div[5]/table/tbody/tr
    FOR  ${index}  IN RANGE  1  ${count}+1
        Log  For row ${index} parameters are:\n  console=true
        ${button}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-panel-container")]/div/div/
        ...  div[1]/sfp-table/div[5]/table/tbody/tr[${index}]
        Click Element  ${button}
        Get All Parameters From Second Table  ${index}
        Save Link Status  ${SMOD_NAME}  ${BTS_ID}
        Go To Site View
        Click Element  ${DETAILED_SITE_VIEW}
        Sleep  5s
        Check Parameters From Detailed Site View For The Second Table
        Open SFP Monitoring
    END


Step4: Save All Status
    Log  \nStep4: Save All Status  console=true
    ${status}  Run Keyword And Return Status
    ...  Click Element  xpath=//*[contains(@a-text, 'Save All Status')]
    Sleep  5s
    Run Keyword If  ${status}
    ...  Log  Saving All Status has been performed successfully!  console=true
    ...  ELSE
    ...  Set Test Restriction  Save All Status action was not performed!
    Move File  /home/ute/Downloads/SFP_Monitoring_MRBTS-${BTS_ID}_*.txt  ${BTS_FILES}/SFP_Monitoring_MRBTS-${BTS_ID}_SBTS-${BTS_ID}.txt


Get All Parameters From First Table
    [Arguments]  ${index}

    ${rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-panel-container")]/div/div/
    ...  div[1]/sfp-table/div[2]/table/tbody/tr[${index}]/td/table/tbody/tr[1]/td[1]
    ${rmod}  Get Text  ${rmod_text}
    Log  In table is visible: ${rmod}  console=true
    ${rmod_name}  Fetch From Left  ${rmod}  (
    Set Test Variable  ${RMOD_NAME}
    ${source}  Get Text
    ...  //*[contains(@class, "sfp-details-container")]/h2[1]
    Log  In Details is visible: ${source}  console=true
    ${bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-panel-container")]/div/div/
    ...  div[1]/sfp-table/div[2]/table/tbody/tr[${index}]/td/table/tbody/tr[2]/td[1]
    ${bbmod}  Get Text  ${bbmod_text}
    Log  In table is visible: ${bbmod}  console=true
    ${bbmod}  Fetch From Left  ${bbmod}  (
    ${bbmod_name}  Fetch From Right  ${bbmod}  /
    Set Test Variable  ${BBMOD_NAME}
    ${destination}  Get Text
    ...  //*[contains(@class, "sfp-details-container")]/h2[2]
    Log  In Details is visible: ${destination}  console=true
    ${status_source}  Run Keyword And Return Status
    ...  Should Contain  ${source}  ${rmod}
    ${status_destination}  Run Keyword And Return Status
    ...  Should Contain  ${destination}  ${bbmod}
    Run Keyword If  ${status_source} and ${status_destination}
    ...  Log  The source and the destination are the same in Details as in table![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  The source and the destination are not the same in Details as in table![NOK]
    ${link_speed_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-panel-container")]/div/div
    ...  /div[1]/sfp-table/div[2]/table/tbody/tr[${index}]/td/table/tbody/tr[1]/td[2]
    ${link_speed_sfp}  Get Text  ${link_speed_text}
    Log  Link Speed in SFP Monitoring via Diagnostic is ${link_speed_sfp}  console=true
    Set Test Variable  ${LINK_SPEED_SFP}
    ${fiber_length_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-panel-container")]/div/
    ...  div/div[1]/sfp-table/div[2]/table/tbody/tr[${index}]/td/table/tbody/tr[1]/td[3]
    ${fiber_length_sfp}  Get Text  ${fiber_length_text}
    Log  Fiber Length in SFP Monitoring via Diagnostic is ${fiber_length_sfp}  console=true
    Set Test Variable  ${FIBER_LENGTH_SFP}
    ${physical_port_rmod}  Fetch From Right  ${source}  )/
    Set Test Variable  ${PHYSICAL_PORT_RMOD}
    ${physical_port_bbmod}  Fetch From Right  ${destination}  )/
    Set Test Variable  ${PHYSICAL_PORT_BBMOD}
    ${physical_port_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[1]/td[2]
    ${physical_port_rmod_details}  Get Text  ${physical_port_rmod_text}
    ${physical_port_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[1]/td[3]
    ${physical_port_bbmod_details}  Get Text  ${physical_port_bbmod_text}
    ${status_rmod}  Run Keyword And Return Status
    ...  Should Be Equal  ${physical_port_rmod_details}  ${PHYSICAL_PORT_RMOD}
    ${status_bbmod}  Run Keyword And Return Status
    ...  Should Be Equal  ${physical_port_bbmod_details}  ${PHYSICAL_PORT_BBMOD}
    Run Keyword If  ${status_rmod} and ${status_bbmod}
    ...  Log  Physical Ports are the same in Details as in table![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Physical Ports are not the same in Sateils as in table![NOK]
    ${serial_number_sfp_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[4]/td[2]
    ${serial_number_sfp_rmod}  Get Text  ${serial_number_sfp_rmod_text}
    Log  SFP Serial number for the first module: ${serial_number_sfp_rmod}  console=true
    Set Test Variable  ${SERIAL_NUMBER_SFP_RMOD}
    ${serial_number_sfp_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[4]/td[3]
    ${serial_number_sfp_bbmod}  Get Text  ${serial_number_sfp_bbmod_text}
    Log  SFP Serial number for the second module: ${serial_number_sfp_bbmod}  console=true
    Set Test Variable  ${SERIAL_NUMBER_SFP_BBMOD}
    ${transceiver_identifier_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[6]/td[2]
    ${transceiver_identifier_rmod}  Get Text  ${transceiver_identifier_rmod_text}
    Log  Transceiver identifier for the first module: ${transceiver_identifier_rmod}  console=true
    Set Test Variable  ${TRANSCEIVER_IDENTIFIER_RMOD}
    ${transceiver_identifier_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[6]/td[3]
    ${transceiver_identifier_bbmod}  Get Text  ${transceiver_identifier_bbmod_text}
    Log  Transceiver identifier for the second module: ${transceiver_identifier_bbmod}  console=true
    Set Test Variable  ${TRANSCEIVER_IDENTIFIER_BBMOD}
    ${vendor_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[8]/td[2]
    ${vendor_rmod}  Get Text  ${vendor_rmod_text}
    Log  Vendor for the first module: ${vendor_rmod}  console=true
    Set Test Variable  ${VENDOR_RMOD}
    ${vendor_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[8]/td[3]
    ${vendor_bbmod}  Get Text  ${vendor_bbmod_text}
    Log  Vendor for the second module: ${vendor_bbmod}  console=true
    Set Test Variable  ${VENDOR_BBMOD}
    ${connector_type_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[2]/td[2]
    ${connector_type_rmod}  Get Text  ${connector_type_rmod_text}
    Log  Connector type for the first module: ${connector_type_rmod}  console=true
    Set Test Variable  ${CONNECTOR_TYPE_RMOD}
    ${connector_type_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[1]/div/ng-transclude/table/tbody/tr[2]/td[3]
    ${connector_type_bbmod}  Get Text  ${connector_type_bbmod_text}
    Log  Connector type for the second module: ${connector_type_bbmod}  console=true
    Set Test Variable  ${CONNECTOR_TYPE_BBMOD}
    ${sfp_transmission_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[3]/div/ng-transclude/table/tbody/tr[2]/td[2]
    ${sfp_transmission_rate_rmod}  Get Text  ${sfp_transmission_rmod_text}
    Log  SFP transmission rate for the first module: ${sfp_transmission_rate_rmod}  console=true
    Set Test Variable  ${SFP_TRANSMISSION_RATE_RMOD}
    ${sfp_transmission_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[3]/div/ng-transclude/table/tbody/tr[2]/td[3]
    ${sfp_transmission_rate_bbmod}  Get Text  ${sfp_transmission_bbmod_text}
    Log  SFP transmission rate for the second module: ${sfp_transmission_rate_bbmod}  console=true
    Set Test Variable  ${SFP_TRANSMISSION_RATE_BBMOD}
    Get Common Parameters


Get Common Parameters
    ${link_type_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[2]/div/ng-transclude/table/tbody/tr[1]/td[2]
    ${link_type}  Get Text  ${link_type_text}
    Log  Link type: ${link_type}  console=true
    Set Test Variable  ${LINK_TYPE}
    ${sfp_wavelength_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-details-container")]
    ...  /ui-table[3]/div/ng-transclude/table/tbody/tr[1]/td[2]/measurement-with-unit/span
    ${sfp_wavelength}  Get Text  ${sfp_wavelength_text}
    Log  SFP Wavelength: ${sfp_wavelength}  console=true
    Set Test Variable  ${SFP_WAVELENGTH}


Check Parameters From Detailed Site View For The First Table
    ${module_number}  SeleniumLibrary.Get Element Count
    ...  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-site-physical-cabinet')]/div[3]/div
    ${rmods_number}  SeleniumLibrary.Get Element Count  xpath=//*[contains(@class, 'RMOD-column')]/div
    ${rmod_site_view_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
    FOR  ${index}  IN RANGE  1  ${rmods_number}+1
        Click Element  xpath=//*[contains(@class, 'RMOD-column')]/div[${index}]/div
        Sleep  5s
        ${rmod_site_view}  Get Text  ${rmod_site_view_text}
        Run Keyword If  '${rmod_site_view}' == '${RMOD_NAME}'
        ...  Run Keywords
        ...  Check Parameters For RMOD  ${index}
        ...  AND
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END
    FOR  ${index}  IN RANGE  1  ${module_number}+1
        ${command_text}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET
        ...  _R runtime-site-physical-cabinet')]/div[3]/div[${index}]/div
        Run Keyword And Ignore Error  Scroll Element Into View  ${command_text}
        Click Element  ${command_text}
        Sleep  5s
        ${text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${bbmod_site_view}  Get Text  ${text}
        Run Keyword If  '${bbmod_site_view}' == '${BBMOD_NAME}'
        ...  Run Keywords
        ...  Check Parameters For BBMOD  ${index}
        ...  AND
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END


Check Parameters For RMOD
    [Arguments]  ${index}

    ${sfp}  SeleniumLibrary.Get Element Count
    ...  xpath=//*[contains(@class, 'RMOD-column')]/div[${index}]/div[1]/div[2]/div[1]/div[2]/div[1]/div/div/div
    ${name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[2]
    FOR  ${sfp_number}  IN RANGE  1  ${sfp}+1
        Click Element  xpath=//*[contains(@class, 'RMOD-column')]/div[${index}]/div[1]/div[2]/div[1]/div[2]/div[1]/div/div/div[${sfp_number}]
        ${name}  Get Text  ${name_text}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${name}  ${PHYSICAL_PORT_RMOD}
        Continue For Loop If  not(${status})
        Log  \nCheck parameters from Detailed Site View for ${RMOD_NAME}:\n  console=true
        Get All Parameters From Detailed Site View  ${VENDOR_RMOD}
        ...  ${PHYSICAL_PORT_RMOD}
        ...  ${SERIAL_NUMBER_SFP_RMOD}
        ...  ${CONNECTOR_TYPE_RMOD}
        ...  ${TRANSCEIVER_IDENTIFIER_RMOD}
        ...  ${SFP_WAVELENGTH}
        ...  ${SFP_TRANSMISSION_RATE_RMOD}
        ...  ${LINK_TYPE}
        RMODs And BBMODs Parameters  ${LINK_SPEED_SFP}  ${FIBER_LENGTH_SFP}
        Exit For Loop
    END


Check Parameters For BBMOD
    [Arguments]  ${index}

    ${sfp_column_count}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-
    ...  site-physical-cabinet')]/div[3]/div[${index}]/div/div[2]/div[2]/div
    ${sfp_column}  SeleniumLibrary.Get Element Count  ${sfp_column_count}
    Run Keyword If  ${sfp_column} == 1
    ...  Check Parameters from RF SFP  ${index}
    ...  ELSE
    ...  Check Parameters from Q/S_RF SFP  ${sfp_column}  ${index}


Check Parameters from RF SFP
    [Arguments]  ${index}

    ${sfp_count}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-
    ...  site-physical-cabinet')]/div[3]/div[${index}]/div/div[2]/div[2]/div/div/div
    ${sfp}  SeleniumLibrary.Get Element Count  ${sfp_count}
    FOR  ${sfp_number}  IN RANGE  1  ${sfp}+1
        ${xpath}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-site
        ...  -physical-cabinet')]/div[3]/div[${index}]/div/div[2]/div[2]/div/div/div[${sfp_number}]
        Run Keyword And Ignore Error  Scroll Element Into View  ${xpath}
        Click Element  ${xpath}
        ${text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[2]
        ${name}  Get Text  ${text}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${name}  ${PHYSICAL_PORT_BBMOD}
        Continue For Loop If  not(${status})
        Log  \nCheck parameters from Detailed Site View for ${BBMOD_NAME}:\n  console=true
        Get All Parameters From Detailed Site View  ${VENDOR_BBMOD}
        ...  ${PHYSICAL_PORT_BBMOD}
        ...  ${SERIAL_NUMBER_SFP_BBMOD}
        ...  ${CONNECTOR_TYPE_BBMOD}
        ...  ${TRANSCEIVER_IDENTIFIER_BBMOD}
        ...  ${SFP_WAVELENGTH}
        ...  ${SFP_TRANSMISSION_RATE_BBMOD}
        ...  ${LINK_TYPE}
        RMODs And BBMODs Parameters  ${LINK_SPEED_SFP}  ${FIBER_LENGTH_SFP}
        Exit For Loop
    END


Check Parameters from Q/S_RF SFP
    [Arguments]  ${sfp_column}  ${index}

    FOR  ${sfp_col}  IN RANGE  1  ${sfp_column}+1
        ${sfp_count}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-
        ...  site-physical-cabinet')]/div[3]/div[${index}]/div/div[2]/div[2]/div[${sfp_col}]/div/div
        ${sfp}  SeleniumLibrary.Get Element Count  ${sfp_count}
        Check Q/S_RF SFP  ${sfp}  ${index}  ${sfp_col}
    END


Check Q/S_RF SFP
    [Arguments]  ${sfp}  ${index}  ${sfp_col}

    FOR  ${sfp_number}  IN RANGE  1  ${sfp}+1
        ${xpath}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-site
        ...  -physical-cabinet')]/div[3]/div[${index}]/div/div[2]/div[2]/div[${sfp_col}]/div/div[${sfp_number}]
        Run Keyword And Ignore Error  Scroll Element Into View  ${xpath}
        Click Element  ${xpath}
        ${text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
        ...  details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[2]
        ${name}  Get Text  ${text}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${name}  ${PHYSICAL_PORT_BBMOD}
        Continue For Loop If  not(${status})
        Log  \nCheck parameters from Detailed Site View for ${BBMOD_NAME}:\n  console=true
        Get All Parameters From Detailed Site View  ${VENDOR_BBMOD}
        ...  ${PHYSICAL_PORT_BBMOD}
        ...  ${SERIAL_NUMBER_SFP_BBMOD}
        ...  ${CONNECTOR_TYPE_BBMOD}
        ...  ${TRANSCEIVER_IDENTIFIER_BBMOD}
        ...  ${SFP_WAVELENGTH}
        ...  ${SFP_TRANSMISSION_RATE_BBMOD}
        ...  ${LINK_TYPE}
        RMODs And BBMODs Parameters  ${LINK_SPEED_SFP}  ${FIBER_LENGTH_SFP}
        Exit For Loop
    END


Get All Parameters From Detailed Site View
    [Arguments]  ${vendor}  ${physical_port}  ${sn}  ${connector_type}  ${transceiver_identifier}  ${wave_length}  ${transmission_rate}  ${link_type}

    Sleep  5s
    ${status_vendor}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${vendor}")]
    Run Keyword If  ${status_vendor}
    ...  Log  Vendor: ${vendor} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  Vendor: ${vendor} is not visible in Detailed Site View![NOK]
    ${status_physical_port}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${physical_port}")]
    Run Keyword If  ${status_physical_port}
    ...  Log  Physical Port: ${physical_port} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  Physical Port: ${physical_port} is not visible in Detailed Site View![NOK]
    ${status_sn}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${sn}")]
    Run Keyword If  ${status_sn}
    ...  Log  SFP Serial Number: ${sn} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  SFP Serial Number: ${sn} is not visible in Detailed Site View![NOK]
    ${status_connector_type}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${connector_type}")]
    Run Keyword If  ${status_connector_type}
    ...  Log  Connector type: ${connector_type} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  Connector type: ${connector_type} is not visible in Detailed Site View![NOK]
    ${status_transceiver_identifier}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${transceiver_identifier}")]
    Run Keyword If  ${status_transceiver_identifier}
    ...  Log  Transceiver identifier: ${transceiver_identifier} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  Transceiver identifier: ${transceiver_identifier} is not visible in Detailed Site View![NOK]
    ${status_wave_length}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${wave_length}")]
    Run Keyword If  ${status_wave_length}
    ...  Log  Wave length: ${wave_length} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  Wave length: ${wave_length} is not visible in Detailed Site View![NOK]
    ${status_transmission_rate}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${transmission_rate}")]
    Run Keyword If  ${status_transmission_rate}
    ...  Log  Transmission rate: ${transmission_rate} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  Transmission rate: ${transmission_rate} is not visible in Detailed Site View![NOK]
    ${status_link_type}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${link_type}")]
    Run Keyword If  ${status_link_type}
    ...  Log  Link type: ${link_type} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  Link type: ${link_type} is not visible in Detailed Site View![NOK]


RMODs And BBMODs Parameters
    [Arguments]  ${link_speed}  ${fiber_length}

    Run Keyword If  '${link_speed}'=='3072.0 Mb/s'
    ...  Verify Link Speed From Detailed Site View  Obsai3Gbps
    ...  ELSE IF  '${link_speed}'=='1228.8 Mb/s'
    ...  Verify Link Speed From Detailed Site View  Cpri2
    ...  ELSE IF  '${link_speed}'=='2457.6 Mb/s'
    ...  Verify Link Speed From Detailed Site View  Cpri3
    ...  ELSE IF  '${link_speed}'=='4915.2 Mb/s'
    ...  Verify Link Speed From Detailed Site View  Cpri5
    ...  ELSE IF  '${link_speed}'=='9830.4 Mb/s'
    ...  Verify Link Speed From Detailed Site View  Cpri7
    ...  ELSE IF  '${link_speed}'=='6144.0 Mb/s'
    ...  Verify Link Speed From Detailed Site View  Cpri6  Obsai6Gbps
    ...  ELSE IF  '${link_speed}'=='eCPRI over 10GE'
    ...  Verify Link Speed From Detailed Site View  eCpri10
    ...  ELSE IF  '${link_speed}'=='eCPRI over 25GE'
    ...  Verify Link Speed From Detailed Site View  eCpri25
    ${status_fiber_length}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${fiber_length}")]
    Run Keyword If  ${status_fiber_length}
    ...  Log  Fiber Length: ${fiber_length} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  Fiber Length: ${fiber_length} is not visible in Detailed Site View![NOK]


Verify Link Speed From Detailed Site View
    [Arguments]  ${link_speed}  ${link_speed_version_2}=${EMPTY}

    ${status_link_speed}  Run Keyword And Return Status
    ...  Page Should Contain Element  //*[contains(text(), "${link_speed}")]
    Run Keyword If  '${link_speed_version_2}'=='Obsai6Gbps' and ${status_link_speed}==${FALSE}
    ...  Run Keywords
    ...  Page Should Contain Element  //*[contains(text(), "${link_speed_version_2}")]
    ...  AND
    ...  Log  Link speed: ${link_speed_version_2} is visible in Detailed Site View![OK]  console=true
    Run Keyword If  ${status_link_speed}
    ...  Log  Link speed: ${link_speed} is visible in Detailed Site View![OK]  console=true
    ...  ELSE
    ...  Fail  Link speed: ${link_speed} is not visible in Detailed Site View![NOK]


Get All Parameters From Second Table
    [Arguments]  ${index}

    ${smod_text}  Catenate  SEPARATOR=  //*[contains(@class, "sfp-panel-container")]/div/div/div[1]
    ...  /sfp-table/div[5]/table/tbody/tr[${index}]/td/table/tbody/tr/td[1]
    ${smod}  Get Text  ${smod_text}
    Log  In table is visible: ${smod}  console=true
    ${smod_name}  Fetch From Left  ${smod}  (
    Set Test Variable  ${SMOD_NAME}
    ${source}  Get Text
    ...  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/details-panel-content/div/sfp-details/div/h2
    Log  In Details is visible: ${source}  console=true
    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${source}  ${smod}
    Run Keyword If  ${status}
    ...  Log  The source is the same in Details as in table![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  The source is not the same in Details as in table![NOK]
    ${physical_port_smod}  Fetch From Right  ${source}  )/
    Set Test Variable  ${PHYSICAL_PORT_SMOD}
    ${physical_port_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/
    ...  div/details-panel-content/div/sfp-details/div/ui-table[1]/div/ng-transclude/table/tbody/tr[1]/td[2]
    ${physical_port_smod_details}  Get Text  ${physical_port_smod_text}
    ${status_smod}  Run Keyword And Return Status
    ...  Should Be Equal  ${physical_port_smod_details}  ${PHYSICAL_PORT_SMOD}
    Run Keyword If  ${status_smod}
    ...  Log  Physical Port is the same in Details as in table![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Physical Port is not the same in Sateils as in table![NOK]
    ${serial_number_sfp_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section
    ...  /div/div/details-panel-content/div/sfp-details/div/ui-table[1]/div/ng-transclude/table/tbody/tr[4]/td[2]
    ${serial_number_sfp_smod}  Get Text  ${serial_number_sfp_smod_text}
    Log  SFP Serial number for the module: ${serial_number_sfp_smod}  console=true
    Set Test Variable  ${SERIAL_NUMBER_SFP_SMOD}
    ${transceiver_identifier_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/
    ...  wf-panel-section/div/div/details-panel-content/div/sfp-details/div/ui-table[1]/div/ng-transclude/table/tbody/tr[6]/td[2]
    ${transceiver_identifier_smod}  Get Text  ${transceiver_identifier_smod_text}
    Log  Transceiver identifier for the module: ${transceiver_identifier_smod}  console=true
    Set Test Variable  ${TRANSCEIVER_IDENTIFIER_SMOD}
    ${vendor_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/
    ...  div/details-panel-content/div/sfp-details/div/ui-table[1]/div/ng-transclude/table/tbody/tr[8]/td[2]
    ${vendor_smod}  Get Text  ${vendor_smod_text}
    Log  Vendor for the module: ${vendor_smod}  console=true
    Set Test Variable  ${VENDOR_SMOD}
    ${connector_type_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div/
    ...  details-panel-content/div/sfp-details/div/ui-table[1]/div/ng-transclude/table/tbody/tr[2]/td[2]
    ${connector_type_smod}  Get Text  ${connector_type_smod_text}
    Log  Connector type for the module: ${connector_type_smod}  console=true
    Set Test Variable  ${CONNECTOR_TYPE_SMOD}
    ${sfp_transmission_rate}  Get Text  xpath=//*[contains(@unit, 'staticParameters.transmissionRate.unit')]
    Log  SFP transmission rate: ${sfp_transmission_rate}  console=true
    Set Test Variable  ${SFP_TRANSMISSION_RATE}
    Get Common Parameters


Check Parameters From Detailed Site View For The Second Table
    ${module_number}  SeleniumLibrary.Get Element Count
    ...  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-site-physical-cabinet')]/div[3]/div
    FOR  ${index}  IN RANGE  1  ${module_number}+1
        ${command_text}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-
        ...  site-physical-cabinet')]/div[3]/div[${index}]/div
        Run Keyword And Ignore Error  Scroll Element Into View  ${command_text}
        Wait Until Element Is Clicked  xpath=${command_text}
        Sleep  5s
        ${smod_site_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/
        ...  div/details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[1]/span
        ${smod_site_view}  Get Text  ${smod_site_text}
        Run Keyword If  '${smod_site_view}' == '${SMOD_NAME}'
        ...  Run Keywords
        ...  Check Parameters For SMOD  ${index}
        ...  AND
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END


Check Parameters For SMOD
    [Arguments]  ${index}

    ${sfp_text}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-
    ...  site-physical-cabinet')]/div[3]/div[${index}]/div/div[2]/div[2]/div/div/div
    ${sfp}  SeleniumLibrary.Get Element Count  ${sfp_text}
    FOR  ${sfp_number}  IN RANGE  1  ${sfp}+1
        ${button}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'site-widget-container has-smod-fan-group CABINET_R runtime-site
        ...  -physical-cabinet')]/div[3]/div[${index}]/div/div[2]/div[2]/div/div/div[${sfp_number}]
        Click Element  ${button}
        ${name_text}  Catenate  SEPARATOR=  //*[contains(@class, "details-panel-container")]/wf-panel/wf-panel-section/div/div
        ...  /details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div[2]
        ${name}  Get Text  ${name_text}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${name}  Port label: ${PHYSICAL_PORT_SMOD}
        Run Keyword If  ${status}
        ...  Run Keywords
        ...  Log  \nCheck parameters from Detailed Site View for ${SMOD_NAME}:\n  console=true
        ...  AND
        ...  Get All Parameters From Detailed Site View  ${VENDOR_SMOD}
        ...  ${PHYSICAL_PORT_SMOD}
        ...  ${SERIAL_NUMBER_SFP_SMOD}
        ...  ${CONNECTOR_TYPE_SMOD}
        ...  ${TRANSCEIVER_IDENTIFIER_SMOD}
        ...  ${SFP_WAVELENGTH}
        ...  ${SFP_TRANSMISSION_RATE}
        ...  ${LINK_TYPE}
        ...  AND
        ...  Exit For Loop
        ...  ELSE
        ...  Continue For Loop
    END


Save Link Status
    [Arguments]  ${module1}  ${module2}

    Log  \nSave Link Status  console=true
    ${status}  Run Keyword And Return Status
    ...  Click Element  xpath=//*[contains(@a-text, 'Save Link Status')]
    Sleep  10s
    Run Keyword If  ${status}
    ...  Log  Saving Link status has been performed successfully!  console=true
    ...  ELSE
    ...  Set Test Restriction  Save Link Status action was not performed!
    Move File  /home/ute/Downloads/SFP_Monitoring_*.txt  ${BTS_FILES}/SFP_Monitoring_${module1}_${module2}.txt


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
