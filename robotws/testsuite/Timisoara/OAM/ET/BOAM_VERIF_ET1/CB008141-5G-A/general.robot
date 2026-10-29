*** Settings ***
Documentation
...    Author:Moldovan Dan
...    Maintainer:dan.moldovan@nokia.com
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/CB008141-5G-A/general.robot

Resource    ./resources/CB008141-5G-A.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_CLASSICAL_ASIB_ABIO_ORAN_AZQI_eCPRI    SBTS00  SBTS22R4  SBTS23R1
...    CA_RAN_BOAM_VERIF

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

Test14_LTE_OPR_REQ_30507_O-RU_beams_matches_cell_beams_FR1_TDD_SUCCESS
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...     Test 14. LTE_OPR_REQ_30507
    ...    - [TEST PURPOSE] - This test case is to verify that cell setup is successful when number of configured
    ...      beams in the pre-defined beam-set matches the number of O-RU supported beams
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 24.08.2021  - Created

    Number of configured beams in the pre-defined beam-set matches the number of beams supported by O-RU

Test8_LTE_OPR_REQ_30512_O-RU_beams_less_than_cell_beams-FID_4664_FR1_TDD
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    Test 8. LTE_OPR_REQ_30512
    ...    - [TEST PURPOSE] - T he Purpose of this case is to test that the number of configured beams
    ...      in the beam mapping table is bigger than the number of beams supported by O-RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 23.08.2021  - Created

    Bigger_Configured_beams_in_beam_mapping_table

Test6_LTE_OPR_REQ_30507_O-RU_beams_less_than_cell_beams-beams_muted_FR1_TDD
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    Test 6. LTE_OPR_REQ_30512
    ...    - [TEST PURPOSE] - The Purpose of this case is to verify if gNB is able to mute some of the beams when the
    ...    number of configured beams in the beam mapping table is bigger than the number of beams supported by O-RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 30.08.2021  - Created

    Mute_beams_if_number_bigger_than_supported



