*** Settings ***
Documentation
...    Author:
...    Maintainer:
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001542-RA/general.robot

Resource    ./resources/CB007058.robot

Force Tags   STATE_SW_UPLOADED  RAN_5G   RAN_5G_TDD  5G_RAN_TDD  5G_RAN  master_classicalbts_all
...    CLOUD_5G_CLASSICAL_ASIB_ABIO_ORAN_AZQI_eCPRI
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

Connect_to_O-RU
    [Tags]   CRT  SBTS22R4
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] -The Purpose of this case is to connect to O-RU.
    ...    -TC verifies that command sudo docker ps -a works on O-RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.06.2021  - Created
    ...    *******************
    ...    elena.sabau@nokia.com

    Connect_to_O-RU


16_NIDD_relationship_between_actORuBeamforming_actBeamforming_and_actNcYgMPlane
    [Tags]   CRT  SBTS22R4
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify that O-RU beamforming can only be set to "true" if
    ...    actNcYgMplane and actBeamforming parameters are both "true"
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.06.2021 - - Created
    ...    *******************
    ...    elena.sabau@nokia.com

    16_NIDD_relationship_between_actORuBeamforming_actBeamforming_and_actNcYgMPlane

4_To_setup_BF_cell_with_BF_supported_O-RU_ORUBeamFormingSupport_is_true_success_US2
    [Tags]   CRT   SBTS00  SBTS22R4  SBTS23R1
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify that  setup of BF cell with BF supported O-RU is successful.
    ...    ******************
    ...    History of  changes
    ...    ******************
    ...    - 17.06.2021 - - Created
    ...    *******************
    ...    elena.sabau@nokia.com

    4_To_setup_BF_cell_with_BF_supported_O-RU_ORUBeamFormingSupport_is_true_success_US2

13_O-RU_BF=false_cell_BF_configured_O-RU_supporting_BF_Beam_Set!=1_configured
    [Tags]   CRT   SBTS00  SBTS22R4  SBTS23R1
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify that fault ID 1868 is raised.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.06.2021 - - Created
    ...    *******************
    ...    elena.sabau@nokia.com

    13_O-RU_BF=false_cell_BF_configured_O-RU_supporting_BF_Beam_Set!=1_configured
