*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the TESTSUITE file for feature CB008021


Library         taf.sbts.oam.coam.admin    WITH NAME    coam
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008021/resources/keywords_8021.robot


Suite Setup      Run Keywords
...              testline_preparation.Prepare Testline            AND
...              Initialise Attenuator


*** Test Cases ***
UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1
    [Documentation]   Setup for CB008021 testcases using PRACH and PUCCH F1 measurement
    [Setup]        Run Keywords
    ...            Nullify attenuation on all ports      AND
    ...            Set attenuation    90    ${cell_3_attenuator_ports}
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1
    [Teardown]     Nullify attenuation on all ports

CB008021-A_1_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements for PRACH and PUCCH channel
    CB008021-A_1_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_1_enabledWithPRACH_PUCCH_F1

CB008021-A_8_FDD_Activation_of_L1_measurements_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements for PRACH and PUCCH F1 channel
    CB008021-A_8_FDD_Activation_of_L1_measurements_for_1_enabledWithPRACH_PUCCH_F1

CB008021-A_17_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (with PRACH AND PUCCH_F1).
    CB008021-A_17_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_1_enabledWithPRACH_PUCCH_F1

UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1_ADDITIONAL_COUNTERS
    [Documentation]   Setup for CB008021 testcases using PRACH and PUCCH F1 measurement with additional counters
    [Setup]        Run Keywords
    ...            Nullify attenuation on all ports      AND
    ...            Set attenuation    90    ${cell_3_attenuator_ports}
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH_F1_ADDITIONAL_COUNTERS
    [Teardown]     Nullify attenuation on all ports

CB008021-A_9_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements for PRACH and PUCCH F1 channel
    CB008021-A_9_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1

UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    [Documentation]   Setup for CB008021 testcases using interference measurement without PRACH
    [Setup]        Run Keywords
    ...            Nullify attenuation on all ports      AND
    ...            Set attenuation    90    ${cell_3_attenuator_ports}
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    [Teardown]     Nullify attenuation on all ports

CB008021-A_2_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_2_enabledWithoutPRACH
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements without PRACH channel
    CB008021-A_2_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_2_enabledWithoutPRACH

CB008021-A_6_FDD_Activation_of_L1_measurements_for_2_enabledWithoutPRACH
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements without PRACH channel
    CB008021-A_6_FDD_Activation_of_L1_measurements_for_2_enabledWithoutPRACH

CB008021-A_10_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PRACH channel
    CB008021-A_10_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH

CB008021-A_18_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_2_enabledWithoutPRACH
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (without PRACH channel).
    CB008021-A_18_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_2_enabledWithoutPRACH


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    [Documentation]   Setup for CB008021 testcases using interference measurement without PUCCH
    [Setup]        Run Keywords
    ...            Nullify attenuation on all ports      AND
    ...            Set attenuation    90    ${cell_3_attenuator_ports}
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    [Teardown]     Nullify attenuation on all ports

CB008021-A_3_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements without PUCCH channel
    CB008021-A_3_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_3_enabledWithoutPUCCH_F1

CB008021-A_5_FDD_Activation_of_L1_measurements_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements for PUCCH channel
    CB008021-A_5_FDD_Activation_of_L1_measurements_for_3_enabledWithoutPUCCH_F1

CB008021-A_11_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PUCCH channel
    CB008021-A_11_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1

CB008021-A_19_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_3_enabledWithoutPUCCH_F1
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (without PUCCH channel).
    CB008021-A_19_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_3_enabledWithoutPUCCH_F1


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    [Documentation]   Setup for CB008021 testcases using interference measurement without PUCCH and PRACH
    [Setup]        Run Keywords
    ...            Nullify attenuation on all ports      AND
    ...            Set attenuation    90    ${cell_3_attenuator_ports}
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    [Teardown]     Nullify attenuation on all ports

CB008021-A_4_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This testcase is checking PM counters collection for uplink interference
     ...              and noise measurements without PRACH and PUCCH channel
    CB008021-A_4_FDD_Activation_PM_Counters_for_UL_interference_and_noise_measurements_for_4_enabledWithoutPRACH_PUCCH_F1

CB008021-A_7_FDD_Activation_of_L1_measurements_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This testcase is checking L1 logs for uplink interference
     ...              and noise measurements with PRACH and PUCCH channel disabled
    CB008021-A_7_FDD_Activation_of_L1_measurements_for_4_enabledWithoutPRACH_PUCCH_F1

CB008021-A_12_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements with PRACH and PUCCH channel disabled
    CB008021-A_12_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1

CB008021-A_20_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_4_enabledWithoutPRACH_PUCCH_F1
    [Documentation]   This user scenario aims at verification of counter requirements related
     ...              to verification of DTX transmission, when the gNB expects that UL transmission
     ...              from the UE shall happen, but nothing is received (without PRACH and PUCCH F1).
   CB008021-A_20_Verification_of_ghost_preambles_DTX_or_DTXes_during_regular_UL_transmission_for_4_enabledWithoutPRACH_PUCCH_F1
