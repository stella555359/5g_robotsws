*** Settings ***
Documentation    Keywords for the UUF test

Library     taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations    WITH NAME    ru_operation
Library     ta5g_egate
Library     ta5g_cell_operations
Resource    testsuite/Wroclaw/RRM/WRO_2/keywords/messaging.robot
Resource    testsuite/Wroclaw/RRM/WRO_2/keywords/L3_Call.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/testline_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/wts.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/gnb.robot
Library     taf.transport.ssh           WITH NAME    taf_ssh
Library     ta5g_enb
Library     taf.sw.scout    WITH NAME     scout
Library     ute_wtssim
Library     OperatingSystem


*** Variables ***
@{ETH3_IPs}=    131    132    133    134    135    136    137    138    139    140    101    102    103    104    105    106

*** Keywords ***
Configure Wts Environment
    [Arguments]    ${wts_config}    ${edaemon_port}
    Stop Edaemon And Egate Processes
    Log To Console    Starting WTS...
    Setup Edaemon And Egate    ${edaemon_port}
    Execute Egate Command And Wait For Data    cmd=cfg file\=${wts_config}
    ...                                        pass_regexp=(SimMode is ready now|UEC-1 is active)
    ...                                        timeout=300

Configure ETH3 Interfaces
    Configure Interfaces    eth=eth3    ips_range=${ETH3_IPs}

Install Bsr Package For UUF Test
    [Arguments]    ${bsr_package}
    Log To Console    BSR package uploading...
    ${artifactory_location}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${bsr_target_filepath}    Set Variable     ${OUTPUT_DIR}
    Install Bsr Package    bsr_file_path=${artifactory_location}/${bsr_package}
    ...                    target_file_path=${bsr_target_filepath}/${bsr_package}
