*** Settings ***
Documentation
...  author:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com
...  maintainer:  Dawid Chuchnowski, dawid.chuchnowski@nokia.com

Library     ute_wtssim
Library     resources/CB014024_keywords.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Prepare Test Environment

*** Variables ***
${WTS_DIR} =    /opt/wts/latest
${SCF}=    ${CURDIR}/config/CB014024_wrong_values_for_frozen_parameters.xml
@{FROZEN_PARAMETERS_A}=    scellblockingloadlevel     pathlossdeltaactscelldl    pathlossdeltaactscellul    dataflowresumethrfr2
@{FROZEN_PARAMETERS_C}=    forgettingRatioFR2     maxNackFloodBurstSizeFR2
@{FROZEN_PARAMETERS}=    @{FROZEN_PARAMETERS_A}    @{FROZEN_PARAMETERS_C}
@{ADDITIONAL_ALLOWED_ALARMS}=    4334       #Serial console activated
*** Test Cases ***
CB014024-SR-C_01_Frozen_FR2_parameters_verification_via_WebEM
    [Documentation]    Verifies that part frozen FR2 RRM parameters can not be modified
    [Setup]    Common Preconditions
    @{relation_errors}=    Validate SCF and return relation errors    scf_filepath=${SCF}
    Check relation errors for specified parameters    ${FROZEN_PARAMETERS}    ${relation_errors}
    [Teardown]  Common Postconditions

*** Keywords ***
Prepare Test Environment
    [Documentation]    Configures interfaces required for WTS, setups edameon and egate processes, loads wts cfg file
    ...                and establishes x2 link
    Configure UTE ETH3
    Setup Edaemon                  edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    Start Edaemon Process          alias=edaemon
    Setup Egate                    egate_port=20000    tool_dir=${WTS_DIR}
    Start Egate Process
    Execute Egate Command          cfg file\=${CURDIR}/config/basic.cfg
    Wait Until Keyword Succeeds    60sec    15sec
    ...                            Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE
    Execute Egate Command          cmd=enb_x2_link_up enb=1 target=2

Configure UTE ETH3
    [Documentation]    Configures interfaces required for WTS
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
