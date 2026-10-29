*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../../resources/KRK/Robot/common_settings.robot
Resource    CB010544-common_keywords.robot
Resource    configuration.robot

*** Variables ***
${NRCELL_1_NRCELL_2_NRBTS} =                         ${CURDIR}/../config/yaml_config/NRCELL_1_NRCELL_2_NRBTS.yaml

*** Keywords ***
Prepare test environment CB010544-A-A2_1
    Set test variable    ${NRCELL-1.actInitialBWPFlexibility}    False
    Set test variable    ${NRCELL-1.msg1FrequencyStart}    26
    Set NRCELLs and NRBTS parameters

    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1

    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Prepare test environment CB010544-A-A2_2
    Set test variable    ${NRCELL-1.actInitialBWPFlexibility}    True
    Set test variable    ${NRCELL-1.msg1FrequencyStart}          60
    Set NRCELLs and NRBTS parameters

    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Prepare test environment CB010544-A-A3_1
    Set test variable    ${NRCELL-1.actInitialBWPFlexibility}    False
    Set test variable    ${NRCELL-2.actInitialBWPFlexibility}    False
    Set test variable    ${NRCELL-1.msg1FrequencyStart}          26
    Set test variable    ${NRCELL-2.msg1FrequencyStart}          26
    Set NRCELLs and NRBTS parameters

    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Prepare test environment CB010544-A-A3_2
    Set test variable    ${NRCELL-1.actInitialBWPFlexibility}    True
    Set test variable    ${NRCELL-2.actInitialBWPFlexibility}    False
    Set test variable    ${NRCELL-1.msg1FrequencyStart}    60
    Set test variable    ${NRCELL-2.msg1FrequencyStart}    26
    Set NRCELLs and NRBTS parameters

    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Prepare test environment CB010544-A-A4_1
    Set test variable    ${NRCELL-1.actInitialBWPFlexibility}    True
    Set test variable    ${NRCELL-2.actInitialBWPFlexibility}    True
    Set test variable    ${NRCELL-1.msg1FrequencyStart}          60
    Set test variable    ${NRCELL-2.msg1FrequencyStart}          36
    Set NRCELLs and NRBTS parameters

    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Prepare test environment CB010544-A-A4_2
    Set test variable    ${NRCELL-1.actInitialBWPFlexibility}    True
    Set test variable    ${NRCELL-2.actInitialBWPFlexibility}    True
    Set test variable    ${NRCELL-1.msg1FrequencyStart}          60
    Set test variable    ${NRCELL-2.msg1FrequencyStart}          36
    Set NRCELLs and NRBTS parameters

    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Prepare test environment CB010544-B_1
    Set test variable    ${NRBTS-1.actCarrierAggregation}         False
    Set test variable    ${NRBTS-1.caConfigurationSupport}        none
    Set test variable    ${NRCELL-1.msg1FrequencyStart}           60
    Set test variable    ${NRCELL-2.msg1FrequencyStart}           60
    Set test variable    ${NRCELL-1.actEnhMultipleDedicatedBWPs}  True
    Set test variable    ${NRCELL-2.actEnhMultipleDedicatedBWPs}  True
    Set NRCELLs and NRBTS parameters

    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]


Prepare test environment CB010544-B_2
    #Switch on CA on gNB
    Set test variable    ${NRBTS-1.actCarrierAggregation}         True
    Set test variable    ${NRBTS-1.caConfigurationSupport}        2CCDL_2CCUL
    Set test variable    ${NRCELL-1.msg1FrequencyStart}           60
    Set test variable    ${NRCELL-2.msg1FrequencyStart}           60
    Set test variable    ${NRCELL-1.actEnhMultipleDedicatedBWPs}  True
    Set test variable    ${NRCELL-2.actEnhMultipleDedicatedBWPs}  True
    Set NRCELLs and NRBTS parameters

    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Prepare test environment CB010544-B_3
#    Set test variable    ${NRCELL-1.msg1FrequencyStart}           60
#    Set test variable    ${NRCELL-2.msg1FrequencyStart}           60
#    Set NRCELLs and NRBTS parameters
#
#    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Prepare test environment CB010544-B_4
#    Set test variable    ${NRCELL-1.msg1FrequencyStart}           60
#    Set test variable    ${NRCELL-2.msg1FrequencyStart}           60
#    Set NRCELLs and NRBTS parameters
#
#    Configure    ${NRCELL_1_NRCELL_2_NRBTS}  node_id=1
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Prepare test environment CB010544-Robustness_2
    # Setup egate for RRC Inactive
    Setup CoreNetworkAssistanceInformationForInactive to be included in InitialContextSetupRequest
    Wait 30s for cells [1,2] operationalState change to [enabled,enabled]

Basic cleanup
    Trigger UEs from 1 to 20 to send deregister request

Set NRCELLs and NRBTS parameters
    Set NRCELL-1 parameters
    Set NRCELL-2 parameters
    Set NRBTS-1 parameters
