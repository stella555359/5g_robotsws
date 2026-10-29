*** Settings ***
Documentation
...    Author: Dan Novacescu (dan.novacescu@nokia.com)
...    Maintainer: Dan Novacescu (dan.novacescu@nokia.com)
...    Group in charge: RAN_BOAM_VERIF_SG02
...    References: doors
...    Feature Description:5GC002181
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BTS_VERIF_ET2/CB008313/5GC002399/general.robot

Resource    ./resources/5GC002181.robot

Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all  SBTS22R3 #SBTS00
...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    CA_BTS_OAM_FMRECOV    #QCP_BTS_OAM    QCD_MN_BTS_OAM   #21A_classicalbts  #20Bb1_classicalbts  SBTS22R1  SBTS22R2

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
SFP parameters monitoring and display
    [Tags]   CRT
    Check maxTransmissionDistance



