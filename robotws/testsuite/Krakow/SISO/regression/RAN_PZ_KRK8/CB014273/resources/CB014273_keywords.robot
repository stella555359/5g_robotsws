*** Settings ***
Documentation
...     Keywords for testing CB014273 feature
...     Author: Natalia Czech
...     Contact: natalia.czech@nokia.com


Library      on_air_tl_preparation.testline_preparation              WITH NAME     tl_prep
Library      taf.sbts.oam.coam.admin            WITH NAME   admin
Library      taf.rfrl.bts.commissioning
Resource     taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Resource     taf/rfrl/procedures/resources/robot/TestModels/Common.robot
Resource     taf/rfrl/procedures/SISO/test_models/5g/Performance/General_SiSo_Auto_PRACH_Performance_Test_Model_Verification_Admin.robot
Resource     taf/rfrl/procedures/SISO/test_models/5g/Performance/General_SiSo_Auto_PUCCH_Performance_Test_Model_Verification_Admin.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${logs_path}                /home/ute/logs
${sw_config_path}           testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB014273/resources/asoh_specific_swconfig.txt
@{CUSTOM_ALLOWED_ALARMS}    Incorrect cell parameter configuration
${80MHz-B}                          ASOH-AVQQ-80MHz-B
${50MHz-B}                          ASOH-AVQQ-50MHz-B
${100MHz-B}                        ASOH-AVQQ-100MHz-B
${100MHz-A}                        ASOH-AVQQ-100MHz-A
@{beam_id}      969     970     971     972

*** Keywords ***
Test Suite Setup
    logger.log_info_to_console    --Start Suite Setup--\n
#    tl_prep.Power On All Pdu Ports
    Verify if BTS and RMODs are Online
    Upload Swconfig On Classical Gnb      sw_config_path=${sw_config_path}
    Get BTS Instance Id
    Perform Commissioning on BTS    prefix_tag=ASOH-AVQQ-80MHz-B
    logger.log_info_to_console    ----Common Suite Setup...--\n
    Common Suite Setup
    logger.log_info_to_console    --Test Suite Setup DONE--\n

Test Teardown with TDS exit
    Run Keywords    Exit Test Dedicated State And Close Connections     AND
    ...             admin.teardown_admin   connection=admin    AND
    ...             Test Teardown
