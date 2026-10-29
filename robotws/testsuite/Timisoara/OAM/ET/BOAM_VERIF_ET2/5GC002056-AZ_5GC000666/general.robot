*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Maintainer: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002056-AZ_5GC000666
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/5GC002056-AZ_5GC000666/general.robot

Resource    ./resources/5GC000666.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN   master_classicalbts_all
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   CA_BTS_OAM_FMRECOV
#QCP_BTS_OAM    QCD_MN_BTS_OAM   #21A_classicalbts  SBTS21B  SBTS22R1  SBTS22R2

Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions


*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

*** Test Cases ***
5GC000666_ABION_Check_that_BTS_log_filenames_can_be_generated_and_are_uniquely_identified
    [Tags]   CRT   SBTS00   SBTS22R4  #SBTS22R3
    [Documentation]
    ...
    5GC000666_ABION_Check_that_BTS_log_filenames_can_be_generated_and_are_uniquely_identified

5GC000666_ABION_Check_that_the_WebEM_generate_a_list_file_with_the_snapshot_content
    [Tags]   CRT   #SBTS22R3
    [Documentation]
    ...
    5GC000666_ABION_Check_that_the_WebEM_generate_a_list_file_with_the_snapshot_content

5GC000666_ABION_Check_the_InfoModel_snapshot_is_saved_on_Operator_PC
    [Tags]   CRT   #SBTS22R3
    [Documentation]
    ...
    5GC000666_ABION_Check_the_InfoModel_snapshot_is_saved_on_Operator_PC
