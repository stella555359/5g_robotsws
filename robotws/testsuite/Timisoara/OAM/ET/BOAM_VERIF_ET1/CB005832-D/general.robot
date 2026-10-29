*** Settings ***
Documentation
...    Author: Elena Sabau (elena.sabau@nokia.com)
...    Maintainer:
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001542-RA/general.robot

Resource    ./resources/CB005832.robot

#Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
#...    CLOUD_5G_CLASSICAL_ASIB_ABIO_ORAN_AZQI_eCPRI    SBTS00    SBTS22R3  SBTS22R4  SBTS23R1
#...    CA_RAN_BOAM_VERIF

Suite Setup       Run Keywords  UTE TL Preparation O-RU
...               AND           Suite Preconditions
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


O-DU_xNB_shall_support_Ethernet_Connectivity_Monitoring_for_C-U_sessions_with_O-RU
    [Tags]   CIT
    [Documentation]
    ...    ****************
    ...    - Test- LTE_OPR_REQ_29362 and LTE_OPR_REQ_30033 [TEST PURPOSE] .
    ...    -The Purpose of this case is to configured and check LBR received
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.06.2021  - Created
    ...    *******************
    ...    elena.sabau@nokia.com
    O-DU_xNB_shall_support_Ethernet_Connectivity_Monitoring_for_C-U_sessions_with_O-RU


