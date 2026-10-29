*** Settings ***
Documentation   This is a keyword file for CB013024, part parameter settings
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${text_M55118C10001}    RRC Reconfigurations attempts for 1 SCell Addition in UL for SA mode
${text_M55118C10002}    Successful RRC Reconfigurations attempts for 1 SCell Addition in UL for SA mode
${text_M55138C00048}    Number of radio admission requests for 4 SCells in SA mode
${text_M55138C00049}    Number of successful radio admissions for 4 SCells addition in SA mode
${text_M55139C00023}    Number of radio admission requests for 4 SCells in SA mode in DU
${text_M55139C00024}    Number of successful radio admissions for 4 SCells addition in SA mode in DU
${text_M55118C02014}    Number of successful RRC Reconfiguration attempts configuring 4 SCells in DL for SA mode
${text_M55118C02015}    Number of RRC Reconfiguration attempts with 4 SCells in DL for SA mode
${text_M55118C02016}    Sum of CA UEs in the cell configured as a PCell with 4 configured SCells in DL
${text_M55118C07510}    Sum of CA UEs in the current cell configured as an SCell that have 4 configured SCells in DL
${text_M55316C03004}    P(S)Cell UEs with 4 activated SCells in DL
${text_M55118C10005}    Sum of CA UEs in the current cell configured as a PCell, which have 1 configured SCell in UL
${text_M55118C10006}    Sum of CA UEs in the current cell configured as SCell that have 1 configured SCell in UL

*** Keywords ***

Prepare Counters And Expected Values T1
    [Documentation]    [PRIVATE]    set expected counter values
    ...       :Autor: Shruthi Shivaprasad

    Log To Console    \nset counter values
    set test variable    @{counter_1}             M55118C10001     ==1     NRCELL-4   NCAC
    set test variable    @{counter_2}             M55118C10002     ==1     NRCELL-4   NCAC
    set test variable    @{counter_3}             M55138C00048     ==1     NRCELL-4   RSACU
    set test variable    @{counter_4}             M55138C00049     ==1     NRCELL-4   RSACU
    set test variable    @{counter_5}             M55139C00023     ==1     NRCELL-4   RSADU
    set test variable    @{counter_6}             M55139C00024     ==1     NRCELL-4   RSADU
    set test variable    @{counter_7}             M55118C02014     ==1     NRCELL-4   NCAC
    set test variable    @{counter_8}             M55118C02015     ==1     NRCELL-4   NCAC

    set test variable    @{counter_9}             M55118C02016     >1     NRCELL-4   NCAC
    set test variable    @{counter_10}            M55118C07510     >1     NRCELL-1   NCAC
    set test variable    @{counter_11}            M55118C07510     >1     NRCELL-2   NCAC
    set test variable    @{counter_12}            M55118C07510     >1     NRCELL-3   NCAC
    set test variable    @{counter_13}            M55118C07510     >1     NRCELL-5   NCAC
    set test variable    @{counter_14}            M55316C03004     >1     NRCELL-4   NCADU
    set test variable    @{counter_15}            M55118C10005     >1     NRCELL-4   NCAC
    set test variable    @{counter_16}            M55118C10006     >1     NRCELL-5   NCAC
    set test variable    ${no_counters_to_check}  16


