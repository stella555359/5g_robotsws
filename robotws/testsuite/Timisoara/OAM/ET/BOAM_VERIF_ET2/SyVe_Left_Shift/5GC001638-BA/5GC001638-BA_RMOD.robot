*** Settings ***

Resource    ./resources/5GC001638_CommonKeywords.robot
Resource    ../../resources/pretest_posttest.robot


Documentation
...   author: Sergiu Alecu
...   contact: sergiu.alecu@nokia.com
...   Feature 5GC001638-5GC000952
...   Current implementation requies ASIK and ABIL HW.


#Force Tags   STATE_ON_AIR  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all   SBTS00   SBTS22R4   SBTS23R1
...    CLOUD_5G_CLASSICAL_ASIK_ABIL_AEQN_eCPRI    #21A_classicalbts
...    CA_BTS_OAM_FMRECOV     #QCP_BTS_OAM    QCD_MN_BTS_OAM   #SBTS21B  SBTS22R1  SBTS22R2  SBTS22R3


Suite Setup       Suite Preconditions
Suite Teardown    Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True


*** Test Cases ***
5GC001638_BA_Autonomous_recovery_reset_counter_with_RMOD_fault
    [Tags]   CRT
    [Documentation]
    ...                      Configuration:  A5G-TD-1S-1CC-2DL-2UL-FR1-CPRI-5GC000703-8
    ...                      Fault: "1912" EFaultId_FrTxOutOfOrder
    [Setup]  Run Keywords    Trunk or Branch  AND
    ...                      Check All Components While OnAir without cell status   AND
    ...                      Fault Should Not Be Present   1901
    Fault 1901 cycle and overload
    Wait For OnAir
    Fault Should Not Be Present      1901
    [Teardown]  Run Keywords     Run Keyword if test failed    Wait Until Keyword Succeeds  600  20  Cancel Fault 1901   AND
    ...                          Reset Site    AND
    ...                          Wait Until Keyword Succeeds   900    30    Check All Components While OnAir
