*** Settings ***
Documentation   This is a keyword file for CB013954, part parameter settings
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Anja Becher
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${text_M55139C01001}    Radio admission requests for the SCell in DU in SA mode
${text_M55139C01002}    Successful radio admissions for the SCell in DU in SA mode
${text_M55139C01003}    Radio admission requests for 1 SCell in DU in SA mode
${text_M55139C01004}    Successful radio admissions for 1 SCell addition in DU in SA mode
${text_M55118C05507}    Sum of CA UEs in the current cell configured as PCell with 1 configured SCell in DL
${text_M55118C05508}    Sum of CA UEs in the current cell configured as an SCell with 1 configured SCell in DL
${text_M55118C05505}    RRC_RECONF_ADD1DLSCELL_ATT_SA
${text_M55118C05506}    RRC_RECONF_ADD1DLSCELL_SUCC_SA

*** Keywords ***

Prepare Counters And Expected Values ${tc}
    [Documentation]    [PRIVATE]    set expected counter values for TC1 for sCell and pCell
    ...       :Autor: Anja Becher

    IF    '${tc}'=='TC1'
           Set Suite Variable      ${sCell_NRCELL}       NRCELL-4
           Set Suite Variable      ${pCell_NRCELL}       NRCELL-7
    END

    Log To Console    \nset counter values
    Set Test Variable    @{counter_1}             M55139C01001     ==1     ${sCell_NRCELL}    RSADU
    Set Test Variable    @{counter_2}             M55139C01002     ==1     ${sCell_NRCELL}    RSADU
    Set Test Variable    @{counter_3}             M55139C01003     ==1     ${pCell_NRCELL}    RSADU
    Set Test Variable    @{counter_4}             M55139C01004     ==1     ${pCell_NRCELL}    RSADU

    Set Test Variable    @{counter_5}             M55118C05507     >10      ${pCell_NRCELL}    NCAC
    Set Test Variable    @{counter_6}             M55118C05508     >10      ${sCell_NRCELL}    NCAC

    Set Test Variable    @{counter_7}             M55118C05505      ==1    ${pCell_NRCELL}    NCAC
    Set Test Variable    @{counter_8}             M55118C05506      ==1    ${pCell_NRCELL}    NCAC

    Set Test Variable    ${no_counters_to_check}  8




