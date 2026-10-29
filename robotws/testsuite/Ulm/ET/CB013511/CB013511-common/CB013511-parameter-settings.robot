*** Settings ***
Documentation   This is a keyword file for CB013511, part parameter settings
...             Team: 'MI MN RAN RD VRF ULM 4'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${text_M55187C00001}    Number of UE configuration attempts for intra-frequency measurement profiles
${text_M55191C00001}    Number of selected measurement profiles for NSA

*** Keywords ***

Prepare Counters And Expected Values A_SE_TC02_B2_ALT1
    [Documentation]    [PRIVATE]    Prepare Counters And Expected Values A_SE_TC02_B2_ALT1
    ...       :Author: Sylvia Schneider

    Set Test Variable    @{text_M55187C00001-1}             ${text_M55187C00001}     1    NRCELL-1   NRMIAF-1    MIAF
    Set Test Variable    @{text_M55187C00001-2}             ${text_M55187C00001}     0    NRCELL-6   NRMIAF-2    MIAF
    Set Test Variable    @{text_M55187C00001-3}             ${text_M55187C00001}     1    NRCELL-6   NRMIAF-3    MIAF

    Set Test Variable    &{dict_miaf_counter}
    ...                                              M55187C00001-1=${text_M55187C00001-1}
    ...                                              M55187C00001-2=${text_M55187C00001-2}
    ...                                              M55187C00001-3=${text_M55187C00001-3}

    Set Test Variable    @{text_M55191C00001-1}             ${text_M55191C00001}     1    NRCELL-1   NRMNSA-1    MNSA
    Set Test Variable    @{text_M55191C00001-2}             ${text_M55191C00001}     0    NRCELL-6   NRMNSA-2    MNSA
    Set Test Variable    @{text_M55191C00001-3}             ${text_M55191C00001}     1    NRCELL-6   NRMNSA-3    MNSA

    Set Test Variable    &{dict_mnsa_counter}
    ...                                              M55191C00001-1=${text_M55191C00001-1}
    ...                                              M55191C00001-2=${text_M55191C00001-2}
    ...                                              M55191C00001-3=${text_M55191C00001-3}
