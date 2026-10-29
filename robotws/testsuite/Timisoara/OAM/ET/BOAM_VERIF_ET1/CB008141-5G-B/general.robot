*** Settings ***
Documentation
...    Author:Sabau Elena
...    Maintainer:elena.sabau@nokia.com
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_VERIF_ET1/CB008141-5G-B/general.robot

Resource    ./resources/CB008141-5G-B.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_CLASSICAL_ASIL_ABIO_2xO-RU    SBTS00  SBTS22R4  SBTS23R1
...    CA_RAN_BOAM_VERIF

Suite Setup       Run Keywords  UTE TL Preparation O-RU
...               AND           Suite Preconditions
Suite Teardown    Run Keywords  Default_oru_image_FR1
...               AND           Suite Postconditions
Test Setup        Test Preconditions
Test Teardown     Test Postconditions

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True


*** Test Cases ***
Test16_LTE_OPR_REQ_30638_BTS_shall_successfully_setup_NR_cell_with_O-RAN_flexible_beam-group_mapping
#Test1.BTS shall successfully setup NR cell with O-RAN flexible beam-group mapping
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    Test 16. LTE_OPR_REQ_30638
    ...    - [TEST PURPOSE] - This test case is to verify that BTS is able to setup NR cell
    ...    with O-RAN flexible beam-group mapping.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.12.2021  - Created

    BTS shall successfully setup NR cell with O-RAN flexible beam-group mapping

Test17_LTE_OPR_REQ_30639_Cell_setup_fails_when_flexible_beam-group_mapping_is_wrong_FID_4664
#Test2.Cell setup fails when flexible beam-group mapping is wrong FID 4664
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    Test 17.  LTE_OPR_REQ_30639
    ...    - [TEST PURPOSE] -This test case is to verify that cell setup fails and FID 4664 occurs when
    ...    flexible beam-group mapping is not correct
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.12.2021  - Created

    Cell setup fails when flexible beam-group mapping is wrong FID 4664

Test5_LTE_OPR_REQ_30507_Number_of_configured_beams_in_the_beam_mapping_table_is_bigger_than_the_number_of_beams_supported_by_FR2
#Test3.Number of configured beams in the beam mapping table is bigger than the number of beams supported by O-RU_beams muted 5GC002001 enabled_FR2
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    Test 5.  LTE_OPR_REQ_30507
    ...    - [TEST PURPOSE] - This test case is to verify that gNB is able to mute some of the beams when the
    ...    number of configured beams in the beam mapping table is bigger than the number of beams supported by O-RU.
    ...    Both cell and O-RU are configured for FR2.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.12.2021  - Created

    The beam mapping table is bigger than the number of beams supported by O-RU_beams muted 5GC002001 enabled_FR2

Test7_LTE_OPR_REQ_30512_Number_of_configured_beams_in_the_beam_mapping_table_is_bigger_than_the_number_of_beams_supported_by_cell setup fails_4664
#Test4.Number of configured beams in the beam mapping table is bigger than the number of beams supported by O-RU cell setup fails _ FID 4664_FR2
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    Test 7.  LTE_OPR_REQ_30512
    ...    - [TEST PURPOSE] - This test case is to verify that gNB fails the cell setup when the number of
    ...    configured beams in the beam mapping table is bigger than the number of beams supported by O-RU and feature
    ...    5GC002001 is disabled. Both cell and O-RU are configured for FR2. Once 5GC002001 is enabled, cell setup
    ...    is resumed and successful.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.12.2021  - Created

    The beam mapping table is bigger than the number of beams supported by O-RU cell setup fails _ FID 4664_FR2
