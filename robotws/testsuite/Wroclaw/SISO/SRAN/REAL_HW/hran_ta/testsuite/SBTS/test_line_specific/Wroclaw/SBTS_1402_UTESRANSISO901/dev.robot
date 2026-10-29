*** Settings ***
Documentation
...  Test Suite Author: Patryk Niewiejski
...  Test Suite Owner: Patryk Niewiejski
...  Responsible Tester: patryk.niewiejski@nokia.com

Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NLWG_1ASIB_1ABIO_1ABIA_1AHEB_1FXDB    SBTS00
Library           XML    use_lxml=True
Resource          ../../../test_resources/STATE/STATE__Site_reset.robot
Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource          ../../..//test_resources/SWM/SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode.robot

*** Variables ***
${HW_LOCATION_CODE}  Wroclaw
${TESTLINE_NAME}  10_16_UTESRANSISO901
${COMMISSIONING_PATH}  /home/ute/testline_configuration/10_16_UTESRANSISO901/node1/SBTS00/CONF_AHEB_FXDB_AHFII.xml
${COLLECT_SNAPSHOT_FLAG}  Never
${ADDITIONAL_IGNORED_ALARMS}  4073,4078,6450
${ENABLE_TRUCK_ROLL_FLAG}    ${False}

*** Test Cases ***
[DEV]SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
   [Setup]    Run Keywords  Set Test Variable  ${COMMISSIONING_PATH}
   ...    AND    Set Test Variable    ${RMOD_SN}    BL2221N4069
   ...    AND    Set Test Variable    ${ENABLE_TRUCK_ROLL_FLAG}    ${False}
   ...    AND    SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode.TC Setup
   ...    AND    Set Library Search Order    SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
   [Timeout]    14400
   TC__SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
   [Teardown]    Run Keywords    SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode.TC Teardown


