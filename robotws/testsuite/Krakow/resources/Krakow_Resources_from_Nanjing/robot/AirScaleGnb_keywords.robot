*** Settings ***
Documentation
...    author: Agnieszka Bylica
...    contact: agnieszka.bylica@nokia.com
...    Common Robot keywords for AirScaleGnb.

Resource    Common.robot
Library     ${CURDIR}/../python/keywords/AirScaleGnb_keywords.py

*** Variables ***
${config_dir}=  ${OUTPUT DIR}/config/gnb1/
${debug_dir}=  ${OUTPUT DIR}/debug/gnb1/


*** Keywords ***

Check If CPRI Link State Is ${required_state}
    Verify Cpri Link Status    ${required_state}

Preform GNB Commissioning
    RestAPI.Perform Commissioning   ${config_dir}/Current_SCF.xml

Get GNB Current Commissioning
    RestAPI.Get Current Commissioning   ${config_dir}
