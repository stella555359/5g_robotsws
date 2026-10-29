*** Settings ***
Resource    ../test_resources/WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports.robot

*** Test Cases ***
WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports
