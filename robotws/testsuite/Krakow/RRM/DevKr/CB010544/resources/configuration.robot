*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot

*** Variables ***
#DEFAULT VALUES:
#NRBTS-1:
# CB007552
${actMultipleDedicatedBWPs_def}      True

#Carrier Aggregation
${actCarrierAggregation_def}         False
${caConfigurationSupport_def}        none


#NRCELL:
# CB010544
${actInitialBWPFlexibility_def}      True
# CB008541
${actEnhMultipleDedicatedBWPs_def}   False

${msg1FrequencyStart_def}            26

${allowUnsuppBcOrBcs_def}            2


*** Keywords ***
Set NRCELL-${id} parameters
    ${actInitialBWPFlexibility}    get variable value      ${NRCELL-${id}.actInitialBWPFlexibility}  ${actInitialBWPFlexibility_def}
    set enb parameter value
    ...  param_path=NRCELL-${id}.actInitialBWPFlexibility
    ...  value=${actInitialBWPFlexibility}
    ...  bts_id=1

    ${actEnhMultipleDedicatedBWPs}    get variable value      ${NRCELL-${id}.actEnhMultipleDedicatedBWPs}  ${actEnhMultipleDedicatedBWPs_def}
    set enb parameter value
    ...  param_path=NRCELL-${id}.actEnhMultipleDedicatedBWPs
    ...  value=${actEnhMultipleDedicatedBWPs}
    ...  bts_id=1

    ${msg1FrequencyStart}    get variable value      ${NRCELL-${id}.msg1FrequencyStart}  ${msg1FrequencyStart_def}
    set enb parameter value
    ...  param_path=NRCELL-${id}.msg1FrequencyStart
    ...  value=${msg1FrequencyStart}
    ...  bts_id=1

Set NRBTS-${id} parameters
    ${actMultipleDedicatedBWPs}    get variable value    ${NRBTS-${id}.actMultipleDedicatedBWPs}    ${actMultipleDedicatedBWPs_def}
    set enb parameter value
    ...  param_path=NRBTS-${id}.actMultipleDedicatedBWPs
    ...  value=${actMultipleDedicatedBWPs}
    ...  bts_id=1

    ${actCarrierAggregation}    get variable value    ${NRBTS-${id}.actCarrierAggregation}    ${actCarrierAggregation_def}
    set enb parameter value
    ...  param_path=NRBTS-${id}.actCarrierAggregation
    ...  value=${actCarrierAggregation}
    ...  bts_id=1

    ${caConfigurationSupport}    get variable value    ${NRBTS-${id}.caConfigurationSupport}    ${caConfigurationSupport_def}
    set enb parameter value
    ...  param_path=NRBTS-${id}.caConfigurationSupport
    ...  value=${caConfigurationSupport}
    ...  bts_id=1
