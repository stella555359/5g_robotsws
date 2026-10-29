*** Settings ***
Suite Setup          CB009919 CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CB009919 CBRS Test Setup
Test Teardown        LTE TL CBRS Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/SBTS_Setup_And_Teardown.robot
Resource     resources/CB009919_common_keyword.robot

Documentation
...    Author: shufei.chen
...    Contact: shufei.chen@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009919

Force Tags            RAN_5G_TDD    5G_RAN_TDD    SBTS00    RAN_5G    5G_RAN    CRT_UTE	   STATE_SW_UPLOADED
...   PY36
...    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQN_5GC002374

*** Variables ***

*** Test Cases ***
[1][1.0] General_SiSo_Beamforming_Calibration_Cal_Software_Component_Operation_Verification_20Mhz_frame_configuration1_5
   [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
   Calibration_Cal_Software_Component_Operation_Verification_20Mhz_frame_configuration1_5

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_10Mhz_20Mhz_frame_configuration1_7
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_10Mhz_20Mhz_frame_configuration1_7
