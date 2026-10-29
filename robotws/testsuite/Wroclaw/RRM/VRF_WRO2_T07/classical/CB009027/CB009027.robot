*** Settings ***
Documentation
...   author: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com
...   This is the TESTSUITE file for feature CB009027, based on the sister feature CB008021


Library         taf.sbts.oam.coam.admin    WITH NAME    coam
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009027/resources/keywords_9027.robot


Suite Setup      Run Keywords
...              Initialise Attenuator


*** Test Cases ***


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH
    [Documentation]   Setup for CB009027 testcases using PRACH and PUCCH F1 measurement
    [Setup]        Run Keywords
    ...            Nullify attenuation on all ports
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH
    [Teardown]     Nullify attenuation on all ports

CB009027-1_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1_ABIP
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements for PRACH and PUCCH F1 channel
    CB009027-1_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1_ABIP


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    [Documentation]   Setup for CB009027 testcases using interference measurement without PRACH
    [Setup]        Run Keywords
    ...            Nullify attenuation on all ports
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
    [Teardown]     Nullify attenuation on all ports

CB009027-2_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH_ABIP
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PRACH channel
    CB009027-2_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH_ABIP


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    [Documentation]   Setup for CB009027 testcases using interference measurement without PUCCH
    [Setup]        Run Keywords
    ...            Nullify attenuation on all ports
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
    [Teardown]     Nullify attenuation on all ports

CB009027-3_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1_ABIP
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PUCCH channel
    CB009027-3_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1_ABIP


UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    [Documentation]   Setup for CB009027 testcases using interference measurement without PUCCH and PRACH
    [Setup]        Run Keywords
    ...            Nullify attenuation on all ports
    UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
    [Teardown]     Nullify attenuation on all ports

CB009027-4_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1_ABIP
    [Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements with PRACH and PUCCH channel disabled
    CB009027-4_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1_ABIP
