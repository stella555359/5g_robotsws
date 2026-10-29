# @Time    : 2022/1/7 19:20
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB008313_precondition.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Resource    CB008313_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot

*** Keywords ***
Case 201 Precondition
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Convert BTS Mode To SA
    Recommission CB008313 Parameters    chBwDl_except=20MHz    chBwUl_except=20MHz

Case 202 Precondition
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Convert BTS Mode To SA
    Recommission CB008313 Parameters    chBwDl_except=5MHz    chBwUl_except=5MHz

Case 206 Precondition
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Convert BTS Mode To NSA
    Recommission CB008313 Parameters    chBwDl_except=20MHz    chBwUl_except=20MHz

Case 207 Precondition
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Convert BTS Mode To NSA
    Recommission CB008313 Parameters    chBwDl_except=15MHz    chBwUl_except=15MHz

Case 208 Precondition
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Convert BTS Mode To NSA
    Recommission CB008313 Parameters    chBwDl_except=5MHz    chBwUl_except=5MHz

Case 209 Precondition
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Convert BTS Mode To NSA
    Recommission CB008313 Parameters    chBwDl_except=5MHz    chBwUl_except=5MHz

Modify Cell Paramater
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${parameter}    ${value}    ${connection}
    ...    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${GLOBAL_CELL_ID}
    coam.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=${parameter}    operation=update
    ...    value=${value}    connection=${connection}
    ...    skip_parameter_relation_errors=True

Modify PrachConfigurationIndex With Cell Lock Unlock
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${value}    ${connection}=GNB_OAM    ${dist_name}=default
    Connect to gnb coam via ssl
    Modify Cell Paramater    parameter=administrativeState    value=Locked    connection=${connection}
    Modify Cell Paramater    parameter=prachConfigurationIndex    value=${value}    connection=${connection}
    Modify Cell Paramater    parameter=administrativeState    value=Unlocked    connection=${connection}
    [Teardown]    COAM Teardown gnb connections

Recommission CB008313 Parameters
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${prachSequenceType_expect}=Unrestricted
    ...    ${zeroCorrelationZoneConfig_except}=${13}    ${cbraPreamblesPerSsb_except}=n64
    ...    ${chBwDl_except}=20MHz    ${chBwUl_except}=20MHz
    ...    ${raResponseWindow_except}=sl20    ${msg1FrequencyStart_except}=${10}
    ...    ${nbrOfSsbPerRachOccasion_except}=one    ${powerRampingStep_except}=dB2
    ...    ${powerRampingStepHighPriorityCfra_except}=dB2    ${prachRootSequenceIndex_except}=${0}
    ...    ${initialPreambleReceivedTargetPower_except}=${-104}    ${preambleTransMax_except}=n10
    ...    ${totalNumberOfRAPreambles_except}=${64}    ${raContentionResolutionTmr_expect}=sf64
    ...    ${rsrpThresholdSSB_expect}=${19}    ${maxHarqMsg3Tx_except}=${5}    ${maxUlHarqTx_except}=${5}
    @{MOs}    coam.get_managed_objects    class_name=NRCELL_A    connection=GNB_OAM
    FOR    ${cell}    IN  @{MOs}
        ${dist_name}    Set Variable    ${cell['distName']}
        ${first}    ${cell_name}    Split String From Right    ${dist_name}    /    1
        Exit For Loop If    '${cell_name}' == 'NRCELL_A-1'
    END

    &{dict_pattern}    coam.get_parameters    dist_name=${dist_name}   connection=GNB_OAM

    Run Keyword If    '${dict_pattern['prachSequenceType']}' != '${prachSequenceType_expect}'
    ...    Modify Cell Paramater    parameter=prachSequenceType    value=${prachSequenceType_expect}    connection=GNB_OAM
    Run Keyword If    ${dict_pattern['zeroCorrelationZoneConfig']} != ${zeroCorrelationZoneConfig_except}
    ...    Modify Cell Paramater    parameter=zeroCorrelationZoneConfig    value=${zeroCorrelationZoneConfig_except}    connection=GNB_OAM
    Run Keyword If    '${dict_pattern['cbraPreamblesPerSsb']}' != '${cbraPreamblesPerSsb_except}'
    ...    Modify Cell Paramater    parameter=cbraPreamblesPerSsb    value=${cbraPreamblesPerSsb_except}    connection=GNB_OAM
    Run Keyword If    '${dict_pattern['raResponseWindow']}' != '${raResponseWindow_except}'
    ...    Modify Cell Paramater    parameter=raResponseWindow    value=${raResponseWindow_except}    connection=GNB_OAM
    Run Keyword If    ${dict_pattern['msg1FrequencyStart']} != ${msg1FrequencyStart_except}
    ...    Modify Cell Paramater    parameter=msg1FrequencyStart    value=${msg1FrequencyStart_except}    connection=GNB_OAM
    Run Keyword If    '${dict_pattern['nbrOfSsbPerRachOccasion']}' != '${nbrOfSsbPerRachOccasion_except}'
    ...    Modify Cell Paramater    parameter=nbrOfSsbPerRachOccasion    value=${nbrOfSsbPerRachOccasion_except}    connection=GNB_OAM
    Run Keyword If    '${dict_pattern['powerRampingStep']}' != '${powerRampingStep_except}'
    ...    Modify Cell Paramater    parameter=powerRampingStep    value=${powerRampingStep_except}    connection=GNB_OAM
    Run Keyword If    '${dict_pattern['powerRampingStepHighPriorityCfra']}' != '${powerRampingStepHighPriorityCfra_except}'
    ...    Modify Cell Paramater    parameter=powerRampingStepHighPriorityCfra    value=${powerRampingStepHighPriorityCfra_except}
    ...    connection=GNB_OAM
    Run Keyword If    ${dict_pattern['prachRootSequenceIndex']} != ${prachRootSequenceIndex_except}
    ...    Modify Cell Paramater    parameter=prachRootSequenceIndex    value=${prachRootSequenceIndex_except}    connection=GNB_OAM
    Run Keyword If    ${dict_pattern['initialPreambleReceivedTargetPower']} != ${initialPreambleReceivedTargetPower_except}
    ...    Modify Cell Paramater    parameter=initialPreambleReceivedTargetPower    value=${initialPreambleReceivedTargetPower_except}
    ...    connection=GNB_OAM
    Run Keyword If    '${dict_pattern['preambleTransMax']}' != '${preambleTransMax_except}'
    ...    Modify Cell Paramater    parameter=preambleTransMax    value=${preambleTransMax_except}    connection=GNB_OAM
    Run Keyword If    ${dict_pattern['totalNumberOfRAPreambles']} != ${totalNumberOfRAPreambles_except}
    ...    Modify Cell Paramater    parameter=totalNumberOfRAPreambles    value=${totalNumberOfRAPreambles_except}    connection=GNB_OAM
    Run Keyword If    '${dict_pattern['raContentionResolutionTmr']}' != '${raContentionResolutionTmr_expect}'
    ...    Modify Cell Paramater    parameter=raContentionResolutionTmr    value=${raContentionResolutionTmr_expect}    connection=GNB_OAM
    Run Keyword If    '${dict_pattern['rsrpThresholdSSB']}' != '${rsrpThresholdSSB_expect}'
    ...    Modify Cell Paramater    parameter=rsrpThresholdSSB    value=${rsrpThresholdSSB_expect}    connection=GNB_OAM

    Modify Cell Paramater    parameter=maxHarqMsg3Tx    value=${maxHarqMsg3Tx_except}    connection=GNB_OAM
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    Modify Cell Paramater    parameter=maxUlHarqTx    value=${maxUlHarqTx_except}    connection=GNB_OAM
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0

    # [4-21] patch: solve conflict between actPdschAtSsbSlots and chbwul&chbwdl
    ${actPdschAtSsbSlots_value}    Run Keyword If    '${chBwDl_except}'=='5MHz'    Set Variable    false
    ...    ELSE    Set Variable    true
    Modify Cell Paramater    parameter=actPdschAtSsbSlots    value=${actPdschAtSsbSlots_value}    connection=GNB_OAM
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${GLOBAL_CELL_ID}
    Wait Until Keyword Succeeds    10min    20s    COAM Check BTS OnAir    connection=GNB_OAM
    # [4-21] patch: solve conflict between actPdschAtSsbSlots and chbwul&chbwdl

    ${chbwdl}    Create Dictionary    parameterName=chBwDl    value=${chBwDl_except}   operation=update
    ${chbwul}    Create Dictionary    parameterName=chBwUl    value=${chBwUl_except}    operation=update
    @{bandwidth}    Create List    ${chbwdl}    ${chbwul}
    coam.perform_object_recommissioning    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${GLOBAL_CELL_ID}/NRCELL_FDD-1
    ...    parameter=${bandwidth}    operation=update    skip_parameter_relation_errors=true    connection=GNB_OAM

    Wait Until Keyword Succeeds    10min    20s    COAM Check BTS OnAir    connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections
