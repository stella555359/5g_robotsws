*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Bem <konrad.bem@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB006598-common_keywords.robot

*** Variables ***
${lowMobilityEvaluation}=            ${CURDIR}/../config/yaml_config/lowMobilityEvaluation_configuration.yaml
${cellEdgeEvaluation}=               ${CURDIR}/../config/yaml_config/cellEdgeEvaluation_configuration.yaml
${nrsys_profile2}=                   ${CURDIR}/../config/yaml_config/nrsysinfo_profile-2.yaml

*** Keywords ***
Prepare test environment A_1
    ${yaml_paths_to_configure}      Create List
    append to list      ${yaml_paths_to_configure}      ${lowMobilityEvaluation}     ${cellEdgeEvaluation}
    Configure    ${yaml_paths_to_configure}

Prepare test environment A_2
    Prepare test environment A_1
    Set NRCELL-1.actUeRelaxedMeasSA to true

Prepare test environment A_3
    Configure    ${cellEdgeEvaluation}
    Set NRCELL-1.actUeRelaxedMeasSA to true

Prepare test environment A_4
    Configure    ${lowMobilityEvaluation}
    Set NRCELL-1.actUeRelaxedMeasSA to true

Prepare test environment A_5
    Prepare test environment A_1
    Set NRCELL-1.actUeRelaxedMeasSA to true

Prepare test environment A_6
    Prepare test environment A_1
    Configure  ${nrsys_profile2}

Basic cleanup
    Deconfigure all
    Run Keyword And Ignore Error   Unblock NRCELL-1
    Run Keyword And Ignore Error   Unblock NRCELL-2
    Unset common verifier
