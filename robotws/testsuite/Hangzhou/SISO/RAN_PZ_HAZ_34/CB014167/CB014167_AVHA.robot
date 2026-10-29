*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    allowed_faults_ids=4459,8000
Test Teardown        SISO Coam Test Teardown    allowed_faults_ids=4459,8000

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SG8_SISO_common_case/resources/SISO_common_case_keywords_SG8.robot
Resource    Resources/CB014167_common_keywords.robot
Library     lib/CB014167.py


Documentation
...    Feature: CB0014167
...    Author:qingjun quan
...    contact:qingjun.quan@nokia-sbell.com
...    squad group:SG_08

Force Tags            RAN_5G    5G_RAN    RAN_5G_FDD    5G_RAN_FDD    SBTS00    CRT_UTE    CRT_22R3    CRT_22R4
...    PY36

*** Variables ***
@{cell_id_common}    ${302}
@{cell_id_peak}    ${302}
@{modify_list_1}    'ssbFrequency'  'actBadUplinkRadioRedirect'
@{modify_list_2}    'ngSetupRespTmr'  'actDl256Qam'
@{modify_list_3}    'dllaTargetBlerVoNR'  'qRxLevMin'    'actDlDynSwitchAlloc'

*** Test Cases ***
[1]CB014167-SR-A_CR-A_3_ISTI_next_to_each_timestamp
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    AlarmWatchdog.add_allow_alarms    fault_id=4459
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    ISTI_next_to_each_timestamp    ru_index=7

[1]CB014167-SR-A_CR-A_4_Information_about_last_RU_resets
    [Tags]    CDRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    AlarmWatchdog.add_allow_alarms    fault_id=4459
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Information_about_last_RU_resets    ru_index=7

[1]CB014167-SR-B_CR-B_1_SFP_info_per_SFP_slot_update_with_RU_startup
   [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
   AlarmWatchdog.add_allow_alarms    fault_id=4459
   AlarmWatchdog.add_allow_alarms    fault_id=8000
   SFP_info_per_SFP_slot_update_with_RU_startup    ru_index=7

[1]CB014167-SR-A_CR-A_1_RU_blackbox_versioning
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    RU_blackbox_versioning

[1]CB014167-SR-D_CR-D_1_RU_configuration_data
    [Tags]    CDRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    RU_configuration_data    ru_index=7

[1]AVHA_EDSM_Check
    [Tags]    CRT_TRUNK
    AVHA_energysaving_EDSM_Check

[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_TRUNK
    General_SISO_Site_Reset_SG08    tput_self_define=${tput_define_CB014167}    Max_loop=${10}    target_avg_percent=0.8
    ...    min_percent=0.85    cell_id=${cell_id_peak}     duration=${300}

[1][1.0] General_SiSo_RAT_Reset
    [Tags]    CRT_TRUNK
    General_SISO_RAT_Reset_SG08    tput_self_define=${tput_define_CB014167}    Max_loop=${10}    target_avg_percent=0.8
    ...    min_percent=0.5    cell_id=${cell_id_common}    duration=${120}

ES Switching on IWK With Parameter change
    [Tags]    CRT_24R3   CRT_TRUNK
    Commissioning SCF And Check BTS On Air
    ES Switching on IWK With Parameter change    modify_list=${modify_list_3}    Max_loop=${3}
    Make L3 call in celL302