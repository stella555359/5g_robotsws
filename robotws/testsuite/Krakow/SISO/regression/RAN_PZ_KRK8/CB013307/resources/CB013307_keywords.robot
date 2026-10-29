*** Settings ***
Documentation
...     Keywords for testing CB013307 feature
...     Author: Natalia Czech
...     Contact: natalia.czech@nokia.com


Library      on_air_tl_preparation.testline_preparation              WITH NAME     tl_prep
Library      taf.sbts.oam.coam.admin            WITH NAME   admin
Library      taf.rfrl.bts.commissioning
Resource     taf/rfrl/procedures/SISO/setups_teardowns/TestSetupTeardown.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_PZ_KRK8/keywords.robot
Resource     taf/rfrl/procedures/resources/robot/TestModels/Common.robot
Resource     taf/rfrl/procedures/SISO/test_models/lte/Downlink/General_SiSo_Auto_LTE_DL_Test_Model_Activation_Admin.robot
Resource     taf/rfrl/procedures/SISO/test_models/lte/Uplink/General_SiSo_Auto_LTE_UL_Test_Model_Activation_Admin.robot
Resource     taf/rfrl/procedures/SISO/test_models/5g/Performance/General_SiSo_Auto_PRACH_Performance_Test_Model_Verification_Admin.robot
Resource     taf/rfrl/procedures/SISO/test_models/5g/Performance/General_SiSo_Auto_PUCCH_Performance_Test_Model_Verification_Admin.robot
Resource     taf/rfrl/procedures/SISO/test_models/5g/Performance/General_SiSo_Auto_PUSCH_Performance_Test_Model_Verification_Admin.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py



*** Variables ***
${logs_path}                /home/ute/logs
${sw_config_path}           commissionings/Krakow/swconfig/default_swconfig.txt
@{CUSTOM_ALLOWED_ALARMS}    Incorrect cell parameter configuration
${LOKI_5MHz}                         CB013307-AHLOA-TL234-5MHz
${LOKI_10MHz}                        CB013307-AHLOA-TL234-10MHz

*** Keywords ***
Test Suite Setup
    logger.log_info_to_console    --Start Suite Setup--\n
    tl_prep.Power On All Pdu Ports
    Verify if BTS and RMODs are Online
    Upload Swconfig On Classical Gnb      sw_config_path=${sw_config_path}
    Get BTS Instance Id
    Run Keyword If  '${bts_instance_id}'=='75234'
    ...         Perform Commissioning on BTS    prefix_tag=${LOKI_5MHz}
    ...     ELSE IF  '${bts_instance_id}'=='75044'
    ...         Perform Commissioning on BTS    prefix_tag=${THOR_5MHz}
    ...     ELSE    logger.log_info_to_console    ---- This is unknown BTS! --\n
    logger.log_info_to_console    ----Common Suite Setup...--\n
    Common Suite Setup
    logger.log_info_to_console    --Test Suite Setup DONE--\n

Test Teardown with TDS exit
    Run Keywords    Exit Test Dedicated State And Close Connections     AND
    ...             admin.teardown_admin   connection=admin    AND
    ...             Test Teardown
