*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      -   <.@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../resources/Robot/common_settings.robot
Resource    ../resources/verifiers.robot
Resource    ../resources/yaml_config_paths.robot
Library     taf.ul.ue.sim.env_setup
Library     resources/tnl_verification.py
Library     resources/qosflow_verification.py
Library     ta5g_tshark
Library     ute_tshark

Resource    ../CB008717/resources/CB008717-common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
    ...    CLOUD_5G_I_BOO_AP_LOO

Suite Setup  Run Setup  ute-ca=True  GBR_nonGBR=True

*** Variables ***
${LUA_CFG}=                ${CURDIR}/../CB008717/config/M/6c_FDD_n66_n5_FR2_n260_n261_NRDC.lua
${SCFC}=                   ${CURDIR}/../../../../../custom-config/Krakow/CB008717/DE/SCFC_FS_6C_n5_n66_n260_n261.xml
${AP_XML}=                 ${CURDIR}/../../../../../custom-config/Krakow/CB008717/DE/iphy_FS_6c_n5_n66_n260_n261.xml

*** Test Cases ***
CB008126-A-B8_interaction_with_CB008717_setup
    [Documentation]
    ...  DESCRIPTION: This file allows to configure feature CB008717 (NR-DC) to test interaction with this feature in CB008126

    [Setup]  Prepare test environment
    Log to console    Prepare test environment for CB008126-A-B8 interaction with CB008717 (NR-DC)

*** Keywords ***
Prepare test environment
    Wait Until Keyword Succeeds  5 min   5 sec  Check SA cell state for NRCELL: 1,2,4,5 and NRDCSN cell state for NRCELL: 3,6

