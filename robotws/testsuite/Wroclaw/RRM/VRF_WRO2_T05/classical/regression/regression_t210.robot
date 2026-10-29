*** Settings ***
Documentation    Suite description
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB011031/CB011031.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot  # Beucause of Connect to coam kw, will
# be moved to common_keywords.robot

Force Tags      CA_5G_RRM  RAN_5G  RAN_5G_FDD  RAN_5G_FDD_MP  RAN_5G_FDD_CD  RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CRT
...             RAN_5GSC_CRT    RAN_5G_CRT    CLOUD_5G_CLASSICAL_QC_ASILL_ABIOB1_1xAVQL

Suite Setup     Run keywords
...             Reset RMOD In Case Of Software Downgrade    AND
...             Prepare and check TL  AND
...             Require Ue    UE_1    capabilities=QUALCOMM_LAHAINA_SA  AND
...             Require Ue    UE_2    capabilities=SAMSUNG_NSA  AND
...             Set Suite Variables


Test Setup      Run keywords
...             Connect To Coam   AND
...             Run Keyword and Ignore Error   Start syslog collection

Test Teardown   Run keywords
...             Make snapshot in case of error    AND
...             Disconnect coam    AND
...             ute_ue.Detach Ue     UE_1      AND
...             ute_ue.Detach Ue     UE_2      AND
...             Run keyword and ignore error    Stop syslog collection  AND
...             Verify Crash occurrence In Syslog  AND
...             Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
...             Sleeping cell test   AND
...             Disconnect coam

*** Test Cases ***

USCCB011031-A#5_Paging_broadcast_for_Idle_state_UE_with_DL_throughput
    [Tags]   SBTS00
    USCCB011031-A#5_Paging_broadcast_for_Idle_state_UE_with_DL_throughput

USCCB011031-B3#_Interworking_with_power_saving_BWP_(5GC000937)
    [Tags]   SBTS00
    ...      SBTS24R2
    ...      SBTS24R1
    USCCB011031-B3#_Interworking_with_power_saving_BWP_(5GC000937)

USCCB011031-A#4_HO_Intra_Freq_event_A3_between_5G_cells_from_cell_with_CB011031_off_to_cell_with_CB011031_on_SA
    [Tags]   SBTS00
    ...      SBTS24R2
    USCCB011031-A#4_HO_Intra_Freq_event_A3_between_5G_cells_from_cell_with_CB011031_off_to_cell_with_CB011031_on_SA

USCCB011031-A#4_HO_Inter_Freq_event_A5_between_5G_cells_from_cell_with_CB011031_on_to_cell_with_CB011031_off_NSA
    [Tags]   SBTS00
    USCCB011031-A#4_HO_Inter_Freq_event_A5_between_5G_cells_from_cell_with_CB011031_on_to_cell_with_CB011031_off_NSA
