*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   maintainer:    marcin.wolczynski@nokia.com
...   Description:   Feature CB008409


Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/keywords_8409.robot
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py


Suite Setup     Run keywords
...             Prepare Attenuator                                    AND
...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}      AND
...             AdminUtils.unlock_all_cells


Test Setup      Run Keywords
...             Wait for next counter interval 8409                   AND
...             Start syslog capture

Test Teardown   Run Keywords
...             Stop All Data Transfers 8409                          AND
...             Stop syslog capture   alias=${SYSLOG_ALIAS}           AND
...             Stop syslog capture                                   AND
...             AdminUtils.collect_snapshot

Suite Teardown  Run Keywords
...             Stop Using Ue               ${UE_ALIAS}              AND
...             AdminUtils.unlock_all_cells                          AND
...             Set Scout Configuration ID


*** Test Cases ***
[1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL
    [Tags]  CRT  24R2  A1
    [1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             Dectivate feature A2                                    AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}              AND
    ...             Stop syslog capture

[]CB133099_Comparison_with_CB008409_test
    [Tags]  CRT  26R1
    [1]CB133099 Comparison With CB008409
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             deactivation_cni_CB0133099                              AND
    ...             Dectivate feature A2                                    AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}              AND
    ...             Stop syslog capture

[1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL_pooling_off
    [Tags]  CRT  25R1 CNI
    [1]CB008409_A_2_CSI_IM_randomization_in_FDD_cell_with_DRX_configured_ASOE_2DL_2UL_pooling_off
     [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             Dectivate feature A2 pooling                            AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}              AND
    ...             Stop syslog capture

CB008409_B_17_FDD_BW15_DL_power_boosting_of_retransmission_for_VoNR_data_with_PRB_Pooling
    [Tags]  CRT  25R1  8409 B
    CB008409_B_17_FDD_BW15_DL_power_boosting_of_retransmission_for_VoNR_data_with_PRB_Pooling_test
    [Teardown]  Run keywords
    ...             Detach Ue                  ${UE_ALIAS}                  AND
    ...             test_specific_keywords_8409.Stop Syslog Collection      AND
    ...             Stop syslog capture  alias=${SYSLOG_ALIAS}              AND
    ...             Stop syslog capture                                     AND
    ...             Dectivate feature B
