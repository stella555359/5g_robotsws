*** Settings ***
Documentation   This is a keyword file for CB013024, part parameter settings
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Anja Becher
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${text_M55139C01001}    Radio admission requests for the SCell in DU in SA mode
${text_M55139C01002}    Successful radio admissions for the SCell in DU in SA mode
${text_M55139C01003}    Radio admission requests for 1 SCell in DU in SA mode
${text_M55139C01004}    Successful radio admissions for 1 SCell addition in DU in SA mode
${text_M55118C05507}    Sum of CA UEs in the current cell configured as PCell with 1 configured SCell in DL
${text_M55118C05508}    Sum of CA UEs in the current cell configured as an SCell with 1 configured SCell in DL
${text_M55118C10005}    Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in UL
${text_M55118C10006}    Sum of CA UEs in the current cell configured as SCell that have 1 configured SCell in UL

*** Keywords ***

Prepare Counters And Expected Values ${tc}
    [Documentation]    [PRIVATE]    set expected counter values for TC1 for sCell and pCell
    ...       :Autor: Anja Becher

    IF    '${tc}'=='TC1'
           Set Suite Variable      ${sCell_NRCELL}       NRCELL-2
           Set Suite Variable      ${pCell_NRCELL}       NRCELL-6
    END

    IF    '${tc}'=='TMO'
           Set Suite Variable      ${sCell_NRCELL}       NRCELL-3
           Set Suite Variable      ${pCell_NRCELL}       NRCELL-8
    END

    Log To Console    \nset counter values
    Set Test Variable    @{counter_1}             M55139C01001     ==1     ${sCell_NRCELL}    RSADU
    Set Test Variable    @{counter_2}             M55139C01002     ==1     ${sCell_NRCELL}    RSADU
    Set Test Variable    @{counter_3}             M55139C01003     ==1     ${pCell_NRCELL}    RSADU
    Set Test Variable    @{counter_4}             M55139C01004     ==1     ${pCell_NRCELL}    RSADU

    Set Test Variable    @{counter_5}             M55118C05507     >1      ${pCell_NRCELL}    NCAC
    Set Test Variable    @{counter_6}             M55118C05508     >1      ${sCell_NRCELL}    NCAC

    Set Test Variable    @{counter_7}             M55118C10005      ==0    ${pCell_NRCELL}    NCAC
    Set Test Variable    @{counter_8}             M55118C10006      ==0    ${sCell_NRCELL}    NCAC

    Set Test Variable    ${no_counters_to_check}  8




