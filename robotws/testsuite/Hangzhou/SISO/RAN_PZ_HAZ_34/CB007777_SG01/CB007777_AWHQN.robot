*** Settings ***
Suite Setup          SISO Suite Setup
Suite Teardown       SISO Suite Teardown
Test Setup           SISO Test Setup
Test Teardown        SISO Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource          Resources/CB007777_Resouce.robot

Documentation
...    Author:xiangli kong
...    contact:xiangli.kong@nokia-sbell.com
...    squad group:SG_01
...    Feature CB007777

Force Tags            RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED  SBTS00   SBTS22R4
...    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABINB1_2xAEQE
...    CLOUD_5G_CLASSICAL_FULLRACK_QC_SA_ASIBL_ABIOB1_AWHQN-ASIBR_ABINB4_AWHQX     PY36

*** Variables ***

*** Test Cases ***
[1]CB007777-5G-L_02_01_General_SiSo_Power_Meter_counter_update_for_energy_consumption_on_AWHQN
    [Tags]    CRT_TRUNK    CRT_UTE    CRT_22R4    CRT_23R2
    General_SiSo_Power_Meter_counter_update_for_energy_consumption

*** Keywords ***
