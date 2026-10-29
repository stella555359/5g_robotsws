*** Settings ***
Documentation    TOL TMO tests to cover SFP Monitoring funcionality. Test cases basically check infomrations returned
...              from WEBEM tool and verify if values from SFP Monitoring exist and are not zeros.
...              From TOL TMO excel file we need to cover
...              - OAM_154 SFP_Monitoring_ASIB_AHFIB_Webem -> LTE
...              - OAM_155 SFP_Monitoring_ASIB_AHLOA_Webem -> LTE
...              - OAM_156 SFP_Monitoring_ASIL_AHFIB_Webem -> NR
...              - OAM_157 SFP_Monitoring_ASIL_AHLOA_Webem -> NR
...              Target TL -> TMO TOL To be filled when cloud resources are available


Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T01/TOL/sfp_monitoring/keywords.py


*** Variables ***
${enb_mplane}  ${tl.enbs[0].oam_ip.v4}


*** Test Cases ***
SFP_Monitoring_ASIB_AHFIB_Webem
    ${res}    generic_webem_call    get_sfp_data    enb_host=${enb_mplane}
    validate_sfp_monitoring_status    ${res}    AHFIB    source
    validate_sfp_monitoring_status    ${res}    AHFIB    destination

SFP_Monitoring_ASIB_AHLOA_Webem
    ${res}    generic_webem_call    get_sfp_data    enb_host=${enb_mplane}
    validate_sfp_monitoring_status    ${res}    AHLOA    source
    validate_sfp_monitoring_status    ${res}    AHLOA    destination

SFP_Monitoring_ASIL_AHFIB_Webem
    ${res}    generic_webem_call    get_sfp_data
    validate_sfp_monitoring_status    ${res}    AHFIB    source
    validate_sfp_monitoring_status    ${res}    AHFIB    destination

SFP_Monitoring_ASIL_AHLOA_Webem
    ${res}    generic_webem_call    get_sfp_data
    validate_sfp_monitoring_status    ${res}    AHLOA    source
    validate_sfp_monitoring_status    ${res}    AHLOA    destination
