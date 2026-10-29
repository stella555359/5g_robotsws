*** Settings ***
Documentation   :copyright: Nokia
...             :author/s: fabrice.delecroix@nokia.com, denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :contact/s: denis.taupin@nokia.com, gerard.bonhaure@nokia.com
...             :description: Generic resource widely used by transversal robustness test suites


*** Variables ***
${DELTA_COMMISSIONING_JSON_03}          ${CURDIR}/../../config/commissioning/TMO_5GC00937/TMO_5GC00937_deactivate.json
${DELTA_COMMISSIONING_JSON_04}          ${CURDIR}/../../config/commissioning/TMO_5GC00937/TMO_5GC00937_activate.json


*** Keywords ***
Online Oam Activate Deactivate Feature robot
    # Change cells parameter without gNB reset
    # ----------------------------------------
    [Arguments]                    ${activation_flag}
    ${comm_file}=                  Run Keyword If    '${activation_flag}' == 'activate'
    ...                            Set Variable      ${DELTA_COMMISSIONING_JSON_04}
    ...                            ELSE IF           '${activation_flag}' == 'deactivate'
    ...                            Set Variable      ${DELTA_COMMISSIONING_JSON_03}
    ...                            ELSE              Fail    Unknown activation_flag value: ${activation_flag}. Expected 'activate' or 'deactivate'.
                                   write_to_report   INF: Online Oam Activate Deactivate Feature robot - activation_flag = ${activation_flag}
                                   write_to_report   INF: Online Oam Activate Deactivate Feature robot - comm_file = ${comm_file}
    ${commissioning_result}=       Run Keyword and Ignore Error
    ...                            Json Recommissioning                 delta_file=${comm_file}
                                   write_to_report   INF: Activation result = ${commissioning_result}