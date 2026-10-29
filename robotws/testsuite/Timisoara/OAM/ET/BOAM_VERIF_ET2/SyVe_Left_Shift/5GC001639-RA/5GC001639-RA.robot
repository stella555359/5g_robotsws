*** Settings ***
Documentation
...    Author: Irina Tanasoiu (irina.tanasoiu@nokia.com)
...    Maintainer: Irina Tanasoiu (irina.tanasoiu@nokia.com)
...    Group in charge: RAN_BOAM_VERIF
...    References: doors
...    Feature Description:5GC001639-RA
...    Sample execution: /opt/ute/python3/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d results/
...    /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/SyVe_Left_Shift/5GC001639-RA/5GC001639-RA.robot

Resource    ./resources/keywords.robot
Resource    ./resources/PreTest.robot


#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    #CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_TDD   #21A_classicalbts
#...    CA_BTS_OAM_FMRECOV   CA_RAN_BOAM_VERIF   #QCP_BTS_OAM    QCD_MN_BTS_OAM   #SBTS21B  SBTS22R1

#Remove Force tags - regression transfer OSS (06 Sept 2022)
#Regression Optimization – part 2 – July 2022(test 03 has been merged with test 04)

Suite Setup       1639-RA Suite Preconditions
Suite Teardown    1639-RA Suite Postconditions
Test Setup        1639-RA Test Preconditions
Test Teardown     1639-RA Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True

*** Test Cases ***
5GC001639_RA_01_5G_Snapshot_collection_in_WebEM
    [Tags]   CIT   CIT__WITH__SBTS00   SBTS22R1   SBTS22R2  SBTS00   SBTS22R3   SBTS22R4
    01_Snapshot_collection_in_WebEM

5GC001639_RA_02_Snapshot_content
    [Tags]   CIT   CIT__WITH__SBTS00   SBTS22R1   SBTS22R2  SBTS00   SBTS22R3   SBTS22R4
    02_Snapshot_content

5GC001639_RA_03_Declaration_of_the_default_external_server
    [Tags]   CRT  SBTS00  SBTS22R4   #SBTS22R3
    03_Declaration_of_the_default_external_server

5GC001639_RA_04_Triggering_snapshot_to_external_server
    [Tags]   CRT  SBTS00   SBTS22R4   #SBTS22R3
    04_Triggering_snapshot_to_external_server

5GC001639_RA_05_Snapshot_Summary_File
    [Tags]   CRT  SBTS00   SBTS22R4   #SBTS22R3
    05_Snapshot_Summary_File
