*** Settings ***
Documentation
...   author: Mateusz Nykiel
...   contact: sergiu.alecu@nokia.com
...   Feature 5GC001542-CA in 5G19A program


Library     String
Library     Process
Library     DateTime
Library     Collections

Library     taf.sbts.oam.coam.admin     WITH NAME   admin_cli

Resource    ./resources/keywords.robot
Resource    ./resources/PrePostTest.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_al
...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD   CA_BTS_OAM_FMRECOV    #CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD  
#21A_classicalbts  CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD  QCP_BTS_OAM    QCD_MN_BTS_OAM   #SBTS21B   SBTS22R1   SBTS22R2

Suite Setup       1546-CA Suite Preconditions
Suite Teardown    1546-CA Suite Postconditions
Test Setup        1546-CA Test Preconditions
Test Teardown     1546-CA Test Postconditions

*** Variables ***
${counter_id_main}   M55110C000
${numer_of_measurements}   33
${parameter_name}   miNrX2CB
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True


*** Test Cases ***
#5GC001542_CA_Measurement_collection_and_storing_on_cOAM_BTS
#    [Tags]       CRT   #SBTS22R3
#    [Documentation]  This includes only one PM counter and can be expanded later if necessary
#    ...   For checking of mechanism it should be sufficient check
#    ...   MRBTS-50399/NRBTS-50399/NRPMRNL-1.miNrX2CB == 15 min     |    suported counters: M55110C00001-M55110C00033
#    ...   #TODO: Not covered are the parts that check WebEM abilities to present counters
#    ${status}    Run Keyword And Return Status
#    ...    Check if counter is configured    expected_value=15min    parameter_name=${parameter_name}
#    Run Keyword Unless    ${status}
#    ...    Modify the SCF for measurement to be gathered in minute intervals    interval=15min    parameter_name=${parameter_name}
#    Wait for counter to be gathered after guard peroid    interval=15
#    Wait for counter peroid end    interval=15
#    Check if counter group is fully collected    counter_id_main=${counter_id_main}
#    ...   numer_of_measurements=${numer_of_measurements}    interval=15


#5GC001542_CA_Configuration_of_measurement_and_reporting_interval
#    [Tags]       CRT   #SBTS22R3
#    [Documentation]  This test case shall check if modifying the reporting interval is working fine
#    Modify the SCF for measurement to be gathered in minute intervals    interval=5min    parameter_name=${parameter_name}
#    Wait for counter to be gathered after guard peroid    interval=15
#    Wait for counter peroid end    interval=5
#    Check if counter group is fully collected    counter_id_main=${counter_id_main}
#    ...   numer_of_measurements=${numer_of_measurements}    interval=5


#5GC001542_CA_Collecting_R&D_counters
#    [Tags]       CRT   SBTS00   SBTS22R4   #SBTS22R3
#    [Documentation]   TODO: Expand check of PM files to checking XML content in snapshot
#    Collect and unzip snapshot   path=/home/ute/snapshot
#    Sleep  900
#    Assert that snapshot contains counters from last update   path=/home/ute/snapshot
#    Clean up snapshot   path=/home/ute/snapshot
#    [Teardown]  run keyword if test failed  Clean up snapshot   path=/home/ute/snapshot
