*** Settings ***
Documentation   CRT regression

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           CRT   CLOUD_5G_CLASSICAL_QC_ASIBL_ABIOB1_3xAHCA_ENB
...           SBTS00

Library          taf.ue
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py    WITH NAME    t099_crt_btslog
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009027/resources/keywords_9027.robot
Resource         taf/rfrl/common_resources/common_step/interface.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Suite Setup      initialise_attenuator

Test Setup       Run Keywords
...              nullify_attenuation_on_all_ports       AND
...              start_btslog_on_local_machine

Test Teardown    Run Keywords
...              Detach UE    UE_1                                AND
...              teardown_btslog                                  AND
...              nullify_attenuation_on_all_ports                 AND
...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

Suite Teardown   Common step Trigger

*** Test Cases ***
CB009027-1_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1_ABIP
	[Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements for PRACH and PUCCH F1 channel
     UL_INTERFERENCE_AND_NOISE_MEASUREMENT_PRACH_PUCCH
     CB009027-1_Verification_of_scheduled_PRB_values_for_1_enabledWithPRACH_PUCCH_F1_ABIP

CB009027-2_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH_ABIP
	[Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PRACH channel
	UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PRACH
	CB009027-2_Verification_of_scheduled_PRB_values_for_2_enabledWithoutPRACH_ABIP

CB009027-3_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1_ABIP
	[Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements without PUCCH channel
     UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH
     CB009027-3_Verification_of_scheduled_PRB_values_for_3_enabledWithoutPUCCH_F1_ABIP

CB009027-4_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1_ABIP
	[Documentation]   This testcase is checking scheduled PRB values for uplink interference
     ...              and noise measurements with PRACH and PUCCH channel disabled
     UL_INTERFERENCE_AND_NOISE_MEASUREMENT_WITHOUT_PUCCH_AND_PRACH
     CB009027-4_Verification_of_scheduled_PRB_values_for_4_enabledWithoutPRACH_PUCCH_F1_ABIP
