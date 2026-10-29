*** Settings ***
Documentation
    ...  This test case is created to monitoring SFP from Diagnostic Tab via Mobile.
    ...  Verify if all cells on SBTS are working.
    ...  Open SFP Monitoring from Diagnostic Tab via Mobile.
    ...  Check parameters for the first table.
    ...  Specific parameters for different modules are: Source, Destination, Link Speed, Fiber Length, Physical Port, Serial Number,
    ...  Transceiver Identifier, Vendor, Connector Type, SFP Nominal Signalling Rate.
    ...  Common Parameters for all modules are: Link Type, SFP Wavelength and SFP Transmission Rate.
    ...  Save Link Status.
    ...  Open SFP Monitoring from Diagnostic Tab via Mobile.
    ...  Check parameters for the second table.
    ...  Specific parameters for module are: Source, Physical Port, Serial Number, Transceiver Identifier, Vendor, Connector Type,
    ...  SFP Nominal Signalling Rate.
    ...  Common Parameters for all modules are: Link Type, SFP Wavelength and SFP Transmission Rate.
    ...  Save Link Status.
    ...  For each parameter it is checked that it is not empty.
    ...  Open SFP Monitoring from Diagnostic Tab via Mobile.
    ...  Save All Status.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Keywords ***
TC__WebEM__SFP_Monitoring_Mobile
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27166
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27166 - Initial TAT creation
    ...  - 25.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29087 - Timeout added for click element kw

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24

    Step1: Set Parameter And Open SFP Monitoring Via Mobile
    Step2: Check Parameters For The First Table
    Step3: Check Parameters For The Second Table
    Step4: Save All Status


Step1: Set Parameter And Open SFP Monitoring Via Mobile
    Log  \nStep1: Set parameter and open SFP Monitoring via Mobile  console=true
    Open SFP Monitoring From Diagnostic Tab Via Mobile


Step2: Check Parameters For The First Table
    Log  \nStep2: Check parameters for the first table  console=true
    ${xpath_input}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel
    ...  /div[2]/p-accordion[1]/div/p-accordiontab
    ${count}  SeleniumLibrary.Get Element Count  ${xpath_input}
    ${fist_table}  Get Text  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/div[1]
    Log  Check table ${fist_table}  console=true
    FOR  ${index}  IN RANGE  1  ${count}+1
        Log  For row ${index} parameters are:\n  console=true
        ${button}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel
        ...  /div[2]/p-accordion[1]/div/p-accordiontab[${index}]
        Wait Until Element Is Clicked For Mobile  ${button}  120
        Get All Parameters From First Table  ${index}
        Save Link Status  ${RMOD_NAME}  ${BBMOD_NAME}  ${DETAILS_BUTTON}
        Go To Site View Via Mobile
        Sleep  5s
        Open SFP Monitoring From Diagnostic Tab Via Mobile
    END


Step3: Check Parameters For The Second Table
    Log  Step3: Check parameters for the second table  console=true
    ${status_second_table}  Run Keyword And Return Status
    ...  Element Should Be Visible  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/div[2]/div
    IF  ${status_second_table}==${FALSE}
        Log  The second table does not exist, test will continue!  console=true
        RETURN
    END
    ${second_table}  Get Text  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/div[2]/div
    Log  Check table ${second_table}  console=true
    ${count_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel
    ...  /div[2]/p-accordion[2]/div/p-accordiontab
    ${count}  SeleniumLibrary.Get Element Count  ${count_text}
    FOR  ${index}  IN RANGE  1  ${count}+1
        Log  For row ${index} parameters are:\n  console=true
        ${button}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel
        ...  /div[2]/p-accordion[2]/div/p-accordiontab[${index}]
        Wait Until Element Is Clicked For Mobile  ${button}  120
        Get All Parameters From Second Table  ${index}
        Save Link Status  ${SMOD_NAME}  ${BTS_ID}  ${DETAILS_BUTTON_SECOND}
        Go To Site View Via Mobile
        Sleep  5s
        Open SFP Monitoring From Diagnostic Tab Via Mobile
    END


Step4: Save All Status
    Log  \nStep4: Save All Status  console=true
    ${status}  Run Keyword And Return Status
    ...  Click Element  xpath=//*[contains(text(), ' Save All Status')]
    Sleep  5s
    IF  ${status}
        Log  Saving All Status has been performed successfully!  console=true
    ELSE
        Set Test Restriction  Save All Status action was not performed!
    END
    Move File  /home/ute/Downloads/SFP_Monitoring_MRBTS-${BTS_ID}_*.txt  ${BTS_FILES}/SFP_Monitoring_MRBTS-${BTS_ID}_SBTS-${BTS_ID}.txt


Open SFP Monitoring From Diagnostic Tab Via Mobile
    Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  120
    Wait Until Element Is Clicked For Mobile  ${DIAGNOSTIC_MENU_MOBILE}  120
    Wait Until Element Is Clicked For Mobile  ${SFP_MONITORING_MOBILE}  120


Get All Parameters From First Table
    [Arguments]  ${index}

    ${rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel
    ...  /div[2]/p-accordion[1]/div/p-accordiontab[${index}]/div/div[1]/a/p-header/div/div/div[1]
    ${rmod}  Get Text  ${rmod_text}
    Log  In table is visible: ${rmod}  console=true
    ${rmod_name}  Fetch From Left  ${rmod}  /
    Set Test Variable  ${RMOD_NAME}
    ${details_button}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel
    ...  /div[2]/p-accordion[1]/div/p-accordiontab[${index}]/div/div[1]/a/p-header/div/p-button/button
    Set Test Variable  ${DETAILS_BUTTON}
    Wait Until Element Is Clicked For Mobile  ${DETAILS_BUTTON}  120
    ${source}  Get Text  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]/div/h2[1]
    Log  In Details is visible: ${source}  console=true
    Wait Until Element Is Clicked For Mobile  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[1]/i  120
    ${bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel
    ...  /div[2]/p-accordion[1]/div/p-accordiontab[${index}]/div/div[1]/a/p-header/div/div/div[2]
    ${bbmod}  Get Text  ${bbmod_text}
    Log  In table is visible: ${bbmod}  console=true
    ${bbmod}  Fetch From Left  ${bbmod}  /
    ${bbmod_name}  Fetch From Right  ${bbmod}  /
    Set Test Variable  ${BBMOD_NAME}
    ${link_speed_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/div[2]/p-accordion[1]/div/p-accordiontab[${index}]/div/div[2]/div/div[2]/measurement-with-unit/div
    ${link_speed_sfp}  Get Text  ${link_speed_text}
    Check Parameter Value And Display Message  ${link_speed_sfp}  Link Speed in SFP for Monitoring via Diagnostic for ${RMOD_NAME}
    ${fiber_length_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/div[2]/p-accordion[1]/div/p-accordiontab[${index}]/div/div[2]/div/div[3]/measurement-with-unit/div
    ${fiber_length_sfp}  Get Text  ${fiber_length_text}
    Check Parameter Value And Display Message  ${fiber_length_sfp}  Fiber Length in SFP Monitoring via Diagnostic for ${RMOD_NAME}
    Wait Until Element Is Clicked For Mobile  ${DETAILS_BUTTON}  120
    ${destination}  Get Text  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]/div/h2[2]
    Log  In Details is visible: ${destination}  console=true
    ${physical_port_rmod}  Fetch From Right  ${source}  /
    ${physical_port_bbmod}  Fetch From Right  ${destination}  /
    ${status_source}  Run Keyword And Return Status
    ...  Should Contain  ${source}  ${rmod}
    ${status_destination}  Run Keyword And Return Status
    ...  Should Contain  ${destination}  ${bbmod}
    IF  ${status_source} and ${status_destination}
        Log  The source and the destination are the same in Details as in table![OK]  console=true
    ELSE
        Set Test Restriction  The source and the destination are not the same in Details as in table![NOK]
    END
    ${physical_port_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/sfp-details/div/div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[1]/td[2]
    ${physical_port_rmod_details}  Get Text  ${physical_port_rmod_text}
    ${physical_port_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/sfp-details/div/div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[1]/td[3]
    ${physical_port_bbmod_details}  Get Text  ${physical_port_bbmod_text}
    ${status_rmod}  Run Keyword And Return Status
    ...  Should Be Equal  ${physical_port_rmod_details}  ${physical_port_rmod}
    ${status_bbmod}  Run Keyword And Return Status
    ...  Should Be Equal  ${physical_port_bbmod_details}  ${physical_port_bbmod}
    IF  ${status_rmod} and ${status_bbmod}
        Log  Physical Ports are the same in Details as in table![OK]  console=true
    ELSE
        Set Test Restriction  Physical Ports are not the same in Sateils as in table![NOK]
    END
    ${serial_number_sfp_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-
    ...  details/div/div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[4]/td[2]
    ${serial_number_sfp_rmod}  Get Text  ${serial_number_sfp_rmod_text}
    Check Parameter Value And Display Message  ${serial_number_sfp_rmod}  SFP Serial number for the first module: ${RMOD_NAME}
    ${serial_number_sfp_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details
    ...  /div/div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[4]/td[3]
    ${serial_number_sfp_bbmod}  Get Text  ${serial_number_sfp_bbmod_text}
    Check Parameter Value And Display Message  ${serial_number_sfp_bbmod}  SFP Serial number for the second module: ${BBMOD_NAME}
    ${transceiver_identifier_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details
    ...  /div/div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[6]/td[2]
    ${transceiver_identifier_rmod}  Get Text  ${transceiver_identifier_rmod_text}
    Check Parameter Value And Display Message  ${transceiver_identifier_rmod}  Transceiver identifier for the first module: ${RMOD_NAME}
    ${transceiver_identifier_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div
    ...  /div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[6]/td[3]
    ${transceiver_identifier_bbmod}  Get Text  ${transceiver_identifier_bbmod_text}
    Check Parameter Value And Display Message  ${transceiver_identifier_bbmod}  Transceiver identifier for the second module: ${BBMOD_NAME}
    ${vendor_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/sfp-details/div/div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[8]/td[2]
    ${vendor_rmod}  Get Text  ${vendor_rmod_text}
    Check Parameter Value And Display Message  ${vendor_rmod}  Vendor for the first module: ${RMOD_NAME}
    ${vendor_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/sfp-details/div/div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[8]/td[3]
    ${vendor_bbmod}  Get Text  ${vendor_bbmod_text}
    Check Parameter Value And Display Message  ${vendor_bbmod}  Vendor for the second module: ${BBMOD_NAME}
    ${connector_type_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[1]/div/ng-transclude/table/tbody/tr[2]/td[2]
    ${connector_type_rmod}  Get Text  ${connector_type_rmod_text}
    Check Parameter Value And Display Message  ${connector_type_rmod}  Connector type for the first module: ${RMOD_NAME}
    ${connector_type_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[1]/div/ng-transclude/table/tbody/tr[2]/td[3]
    ${connector_type_bbmod}  Get Text  ${connector_type_bbmod_text}
    Check Parameter Value And Display Message  ${connector_type_bbmod}  Connector type for the second module: ${BBMOD_NAME}
    ${sfp_transmission_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[3]/div/ng-transclude/table/tbody/tr[2]/td[2]
    ${sfp_transmission_rate_rmod}  Get Text  ${sfp_transmission_rmod_text}
    Check Parameter Value And Display Message  ${sfp_transmission_rate_rmod}  SFP transmission rate for the first module: ${RMOD_NAME}
    ${sfp_transmission_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[3]/div/ng-transclude/table/tbody/tr[2]/td[3]
    ${sfp_transmission_rate_bbmod}  Get Text  ${sfp_transmission_bbmod_text}
    Check Parameter Value And Display Message  ${sfp_transmission_rate_bbmod}  SFP transmission rate for the second module: ${BBMOD_NAME}
    ${sfp_nominal_signalling_rmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[3]/div/ng-transclude/table/tbody/tr[3]/td[2]
    ${sfp_nominal_signalling_rate_rmod}  Get Text  ${sfp_nominal_signalling_rmod_text}
    Check Parameter Value And Display Message  ${sfp_nominal_signalling_rate_rmod}  SFP nominal signalling rate for the first module: ${RMOD_NAME}
    ${sfp_nominal_signalling_bbmod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[3]/div/ng-transclude/table/tbody/tr[3]/td[3]
    ${sfp_nominal_signalling_rate_bbmod}  Get Text  ${sfp_nominal_signalling_bbmod_text}
    Check Parameter Value And Display Message  ${sfp_nominal_signalling_rate_bbmod}  SFP nominal signalling rate for the second module: ${BBMOD_NAME}
    Check Common Parameters
    Click Element  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[1]/i


Check Parameter Value And Display Message
    [Arguments]  ${parameter}  ${message}

    IF  '${parameter}'=='-' or '${parameter}'==''
        Set Test Restriction  ${message} is empty.[NOK]
    ELSE
        Log  ${message} is ${parameter}  console=true
    END


Check Common Parameters
    ${link_type_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/
    ...  sfp-panel/sfp-details/div/div[2]/div/ui-table[2]/div/ng-transclude/table/tbody/tr[1]/td[2]
    ${link_type}  Get Text  ${link_type_text}
    Check Parameter Value And Display Message  ${link_type}  Link type for module: ${RMOD_NAME}
    ${sfp_wavelength_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/
    ...  sfp-panel/sfp-details/div/div[2]/div/ui-table[3]/div/ng-transclude/table/tbody/tr[1]/td[2]/measurement-with-unit/div
    Set Test Variable  ${SFP_WAVELENGTH_TEXT}
    ${sfp_wavelength}  Get Text  ${SFP_WAVELENGTH_TEXT}
    Check Parameter Value And Display Message  ${sfp_wavelength}  SFP Wavelength for module: ${RMOD_NAME}


Get All Parameters From Second Table
    [Arguments]  ${index}

    ${smod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel
    ...  /div[2]/p-accordion[2]/div/p-accordiontab[${index}]/div/div[1]/a/p-header/div/div/div
    ${smod}  Get Text  ${smod_text}
    Log  In table is visible: ${smod}  console=true
    ${smod_name}  Fetch From Left  ${smod}  /
    Set Test Variable  ${SMOD_NAME}
    ${details_button_second}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/div[2]/p-accordion[2]/div/p-accordiontab[${index}]/div/div[1]/a/p-header/div/p-button/button
    Set Test Variable  ${DETAILS_BUTTON_SECOND}
    Wait Until Element Is Clicked For Mobile  ${DETAILS_BUTTON_SECOND}  120
    ${source}  Get Text  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]/div/h2
    Log  In Details is visible: ${source}  console=true
    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${source}  ${smod}
    IF  ${status}
        Log  The source is the same in Details as in table![OK]  console=true
    ELSE
        Set Test Restriction  The source is not the same in Details as in table![NOK]
    END
    ${physical_port_smod}  Fetch From Right  ${source}  /
    ${physical_port_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/sfp-details/div/div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[1]/td[2]
    ${physical_port_smod_details}  Get Text  ${physical_port_smod_text}
    ${status_smod}  Run Keyword And Return Status
    ...  Should Be Equal  ${physical_port_smod_details}  ${physical_port_smod}
    IF  ${status_smod}
        Log  Physical Port is the same in Details as in table![OK]  console=true
    ELSE
        Set Test Restriction  Physical Port is not the same in Sateils as in table![NOK]
    END
    ${serial_number_sfp_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[1]/div/ng-transclude/table/tbody/tr[4]/td[2]
    ${serial_number_sfp_smod}  Get Text  ${serial_number_sfp_smod_text}
    Check Parameter Value And Display Message  ${serial_number_sfp_smod}  SFP Serial number for the module: ${SMOD_NAME}
    ${transceiver_identifier_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[1]/div/ng-transclude/table/tbody/tr[6]/td[2]
    ${transceiver_identifier_smod}  Get Text  ${transceiver_identifier_smod_text}
    Check Parameter Value And Display Message  ${transceiver_identifier_smod}  Transceiver identifier for the module: ${SMOD_NAME}
    ${vendor_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/sfp-details/div/div[2]/div/ui-table[1]/div/ng-transclude/table/tbody/tr[8]/td[2]
    ${vendor_smod}  Get Text  ${vendor_smod_text}
    Check Parameter Value And Display Message  ${vendor_smod}  Vendor for the module: ${SMOD_NAME}
    ${connector_type_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[1]/div/ng-transclude/table/tbody/tr[2]/td[2]
    ${connector_type_smod}  Get Text  ${connector_type_smod_text}
    Check Parameter Value And Display Message  ${connector_type_smod}  Connector type for the module: ${SMOD_NAME}
    ${sfp_transmission_rate_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[2]
    ...  /div/ui-table[3]/div/ng-transclude/table/tbody/tr[2]/td[2]/measurement-with-unit/div
    ${sfp_transmission_rate_smod}  Get Text  ${sfp_transmission_rate_smod_text}
    Check Parameter Value And Display Message  ${sfp_transmission_rate_smod}  SFP transmission rate for the module: ${SMOD_NAME}
    ${sfp_wavelength}  Get Text  ${SFP_WAVELENGTH_TEXT}
    Check Parameter Value And Display Message  ${sfp_wavelength}  SFP Wavelength for the module: ${SMOD_NAME}
    ${sfp_nominal_signalling_smod_text}  Catenate  SEPARATOR=  //*[contains(@class, 'sfp-panel-container')]
    ...  /sfp-panel/sfp-details/div/div[2]/div/ui-table[3]/div/ng-transclude/table/tbody/tr[3]/td[2]/measurement-with-unit/div
    ${sfp_nominal_signalling_rate_smod}  Get Text  ${sfp_nominal_signalling_smod_text}
    Check Parameter Value And Display Message  ${sfp_nominal_signalling_rate_smod}  SFP nominal signalling rate for module: ${SMOD_NAME}
    Wait Until Element Is Clicked For Mobile  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[1]/i  120


Save Link Status
    [Arguments]  ${module1}  ${module2}  ${details_button}

    Log  \nSave Link Status  console=true
    Click Element  ${details_button}
    ${status}  Run Keyword And Return Status
    ...  Click Element  xpath=//*[contains(text(), ' Save Link Status')]
    Sleep  10s
    IF  ${status}
        Log  Saving Link status has been performed successfully!  console=true
    ELSE
        Set Test Restriction  Save Link Status action was not performed!
    END
    Move File  /home/ute/Downloads/SFP_Monitoring_*.txt  ${BTS_FILES}/SFP_Monitoring_${module1}_${module2}.txt
    Click Element  //*[contains(@class, 'sfp-panel-container')]/sfp-panel/sfp-details/div/div[1]/i


TC Setup
    Common Test Setup
    WebEM Setup Via Mobile


TC Teardown
    WebEM Teardown Via Mobile
    Common Test Teardown
