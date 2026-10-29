*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Anca Secea (anca.secea@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001525-SA-TA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001525-SA-TA/general.robot

Resource    ./resources/5GC001525-SA-TA.robot
#Resource    ./resources/keyword.robot

#Force Tags   STATE_CONFIGURED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN    master_classicalbts_all     SBTS00   SBTS22R4  SBTS23R1 
#...    CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_TDD              #21A_classicalbts     
#...    CA_BTS_OAM_FMRECOV   #QCP_BTS_OAM  QCD_MN_BTS_OAM       # 20Bb1_classicalbts  SBTS21B    SBTS22R1  SBTS22R2  SBTS22R3 

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
5GC001525-SA-TA-Fault_generation_1936
    [Tags]   CRT                      #merged with Fault_generation_1940
    [Documentation]
    ...
    Fault_generation_1936

#5GC001525-SA-TA-Fault_generation_1937
#    [Tags]   CRT
#    [Documentation]
#    ...
#    Fault_generation_1937

#5GC001525-SA-TA-Fault_generation_1940
#    [Tags]   CRT  SBTS00   SBTS22R3
#    [Documentation]
#    ...
#    Fault_generation_1940

#5GC001525-SA-TA-Fault_generation_10
#    [Tags]   CRT
#    [Documentation]
#    ...
#    Fault_generation_10
#
#5GC001525-SA-TA-Fault_generation_4383
#    [Tags]   CRT
#    [Documentation]
#    ...
#    Fault_generation_4383
#
#
#5GC001525-SA-TA-Fault_generation_23
#    [Tags]   CRT
#    [Documentation]
#    ...
#    Fault_generation_23


#5GC001525-SA-TA-Fault_generation_1850
#    [Tags]   CRT   SBTS22R3   #Regression Optimization – part 2 – July 2022
#    [Documentation]
#    ...
#    Fault_generation_1850


#5GC001525-SA-TA-Fault_generation_28
#    [Tags]   CRT   SBTS22R3   #Regression Optimization – part 2 – July 2022
#    [Documentation]
#    ...
#    Fault_generation_28


