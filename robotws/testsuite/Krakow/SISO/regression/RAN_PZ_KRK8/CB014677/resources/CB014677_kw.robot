*** Settings ***
Documentation
...   Keywords for testing CB014677 feature
...   Author: Natalia Czech, Bartosz Odziomek
...   Contact: natalia.czech@nokia.com, bartosz.odziomek@nokia.com


Library      on_air_tl_preparation.testline_preparation              WITH NAME     tl_prep
Library      taf.sbts.oam.coam.admin            WITH NAME   admin
Library      taf.rfrl.bts.commissioning
Resource     taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Resource     taf/rfrl/procedures/resources/robot/TestModels/Common.robot
Resource     taf/rfrl/procedures/SISO/test_models/5g/Downlink/General_SiSo_Auto_DL_Test_Model_Activation_Admin.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${logs_path}                /home/ute/logs
@{CUSTOM_ALLOWED_ALARMS}    Incorrect cell parameter configuration      BTS configuration error (not enough HW for LCR)
${7_7_T11SK056}             81056-ABIO-AWKUD-1-cell-configured
${7_7_UTE5GCLOUDT8SK111}    79111-ABIO-AWKUD-1-cell-configured
${sw_config_path}           testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB014273/resources/asoh_specific_swconfig.txt

*** Keywords ***
Test Suite Setup
    logger.log_info_to_console    --Start Suite Setup--\n
    Verify if BTS and RMODs are Online
    Get BTS Instance Id
    Run Keyword If  '${bts_instance_id}'=='81056'
    ...         Perform Commissioning on BTS    prefix_tag=${7_7_T11SK056}
    ...     ELSE IF  '${bts_instance_id}'=='79111'
    ...         Perform Commissioning on BTS    prefix_tag=${7_7_UTE5GCLOUDT8SK111}
    ...     ELSE    logger.log_info_to_console    ---- This is unknown BTS! --\n
    Upload Swconfig On Classical Gnb      sw_config_path=${sw_config_path}
    logger.log_info_to_console    ----Common Suite Setup...--\n
    Common Suite Setup
    logger.log_info_to_console    --Test Suite Setup DONE--\n

Test Teardown with TDS exit
    Run Keywords    Exit Test Dedicated State And Close Connections     AND
    ...             admin.teardown_admin   connection=admin    AND
    ...             Test Teardown
