*** Settings ***
Documentation
...    Author: Elena Sabau (elena.sabau@nokia.com)
...    Maintainer: Elena Sabau (elena.sabau@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007058
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001542-RA/general.robot

Resource    ./resources/CB007058.robot

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
10_Predefined_beam_set_mapping_Case4
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify successful beamset mapping when:
	...    NRCELL.beamSequenceDirectionHorizontal=RightToLeft;
	...    NRCELL.beamSequenceDirectionVertical=BottomToTop;
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.06.2021 - - Created
    ...    *******************
    ...    elena.sabau@nokia.com

    10_Predefined_beam_set_mapping_Case4

6_BF_cell_config_not_matching_O-RU_BF_config_FID_4664
    [Tags]   CRT
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to verify that fault 4664 is raised when pre-defined beam set
    ...    is not supported by the O-RU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.06.2021 - - Created
    ...    *******************
    ...    elena.sabau@nokia.com

    6_BF_cell_config_not_matching_O-RU_BF_config_FID_4664
