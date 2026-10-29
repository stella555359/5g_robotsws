*** Settings ***
Documentation
...   contact: Jakub Magier

Library     taf.sw.reporting_portal
Library     taf.sw.scout  WITH NAME  scout
Resource    ../../feature_resources/CNI152560/CNI-152560_Feature_activation_and_deactivation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/ca_IWK.robot
Resource    ../../resources/attenuator.robot


Suite Setup  QRXLEVMIN Suite Setup


*** Variables ***
${SCOUT_TL_NAME}                  7_16_MRBTS-55341      # Name of TL from SCOUT
${USE_SCOUT_INTERNAL_ID}          False                 # Parameter for 'Request SCF' keyword from taf.sw.scout library
${ABSTRACT_LIB_CONFIG}            /home/ute/testline_configuration/7_16_UTE5GCLOUDU096/ta_ue_config.yaml

*** Keywords ***
QRXLEVMIN Suite Setup
    Log To Console   Common Suite Setup
    Load Attenuation Config And Require Attenuator Setup    ${ABSTRACT_LIB_CONFIG}
    Set Suite Variable  ${CLOUD}                        False

    &{qrxlevmin_cni-152560} =  Create Dictionary
    ...  MRBTS-55341/NRBTS-55341/NRCELL-48=-22
    Set Suite Variable  &{QRXLEVMIN_CNI-152560}  &{qrxlevmin_cni-152560}


Save Original qRxLevMin Values
    &{original_qrxlevmin_values} =  Get qRxLevMin Values of NR Cells  connection=gNB
    Set Test Variable  &{ORIGINAL_QRXLEVMIN_VALUES}  &{original_qrxlevmin_values}


Attenuator Teardown
    Log To Console   Attenuator Teardown
    Set Attenuation For All Cells  100%


*** Test Cases ***
CNI-152560_Feature_activation_and_deactivation
    [Setup]  Run Keywords
    ...  Add Configuration ID to Reporting Portal Report
    ...  scout_testline_name=${SCOUT_TL_NAME}
    ...  AND  Set Attenuation  AVQA_1  0dB
    ...  AND  Set Library Search Order  CNI-152560_Feature_activation_and_deactivation  admin  process
    ...  AND  Set Test Variable  ${CELL_ID_FOR_CALL}  906706944
    ...  AND  Set Test Variable  ${NR_UE_CAPABILITY}  NR_L3_CALL
    ...  AND  Set Test Variable  ${TPUT_DL}  750Mbits/sec
    ...  AND  Set Test Variable  ${TPUT_UL}  110Mbits/sec
    ...  AND  Set Test Variable  ${DELTA_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CNI152560/resources/delta.json
    ...  AND  TC Setup
    ...  AND  Save Original qRxLevMin Values
    ...  AND  Set qRxLevMin Values of NR Cells  ${QRXLEVMIN_CNI-152560}  connection=gNB
    Run keyword  TC__CNI-152560_Feature_activation_and_deactivation
    Map Testcase  [1]CNI-152560_Feature_activation_and_deactivation
    [Teardown]  Run Keywords
    ...  Set qRxLevMin Values of NR Cells  ${ORIGINAL_QRXLEVMIN_VALUES}  connection=gNB
    ...  AND  TC Teardown
    ...  AND  Attenuator Teardown
