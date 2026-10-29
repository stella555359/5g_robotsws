*** Settings ***
Documentation   This is a keyword file for CB012121-A-B13, part counter
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***


${counter_name}              M55142C00526
${counter_id}                TOT_MEASREPORT_RECVD_MEASPRI
${counter_text}              Total number of measurement reports received for measurement prioritization
${counter_expectedValue}     3


*** Keywords ***

Verify counter CB012121-A-B13
    [Documentation]    [PRIVATE]   Verify counter CB012121-A-B13
    ...     :Autor: Sylvia Schneider
    Log to console    \Verify M55142C00526 ${counter_id}
    set test variable    @{M55142C00526}    ${counter_text}     ${counter_expectedValue}    NRCELL-1   NRMO
    Collect PM Counters
    ${parsed_xml}    parse xml    ${pmCounter_xml_file}
    Verify Counter    M55142C00526    ${M55142C00526}    ${parsed_xml}
