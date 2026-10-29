*** Settings ***
Documentation
...           Description : Test Cases for 5GC000706, related to Scenario 5: Intra-DU, TDD->FDD, measurement A5
...
...              Author : Yves Gorjux          yves.gorjux@nokia.com
...                     : Jia Liao             jia.liao@nokia.com
...              last update : 31.08.2020
...
...        Hardware configuration:
...         - 1 gNB with 2 cells equipped with RU
...         - All RUs are connected to an attenuator
...         - UE Qualcomm with iperf3 installed
...         - Real Core Network for SA mode
...        In the SCF:
...         - Counter reporting interval is set to 5mn
...         - The two cells are configured with different frequencies
...         - A handover relation is defined under the source cell to the target cell
...         - The target frequency is to be detected via event A5 based on RSRP measurement
...         - Event A1 is configured so that it is possible to trigger this event by playing with attenuators
...         - Event A2 is configured so that it is possible to trigger this event by playing with attenuators
...         - Event A5 is configured in a way that on the source cell side once event A2 triggered the condition for
...           HO is always fulfilled, and on target cell side after the handover event A2 is not immediately triggered.
...         - The target cell is configured with contention free HO (cbraPreamblesPerSsb=n32)
...        In the custom.yaml:
...         - source_attenuations_attach: is set to a value allowing the attach on the source cell without triggering
...           event A2
...         - target_attenuations_attach: is set to maximum attenuation value to avoid interference for the attach on
...           the source cell
...         - source_attenuations_a2: is set to a value that allows to trigger event A2 on the source cell when
...           attenuation is increased from source_attenuations_attach to source_attenuations_a2.
...         - target_attenuations_a2:   is set to a value that does not allow the handover but that is not too far from
...           this point.
...         - source_attenuations_ho_trigger: same as source_attenuations_a2
...         - target_attenuations_ho_trigger: is set to a value that allows to trigger the handover on the target cell
...           when attenuation is decreased from target_attenuations_a2 to target_attenuations_ho_trigger.'
...         - The triggering of the events A2 and A5 shall be done during a reporting period of 5mn (300s).
...           Our attenuator needs around 12s to change the two paths of one cell for each step. Scenario implement step
...           of 2dB when changing the attenuation from one point to another point. We keep a margin of 60s.
...           For our custom.yaml, we use the following formula:
...           (source_xx_a2 - source_xx_attach + target_xx_ho_trigger - target_xx_a2) / 2dB * 12s +60 <= 300s
...

Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC000706_S5_IntraDU_MeasA5.robot

Force Tags           5G_RAN     STATE_ON_AIR

Suite Setup          5GC000706_Suite_Setup

Suite Teardown       5GC000706_Suite_Teardown



*** Test Case ***
[1]5GC000706_B_035_IntraDU_HO_based_on_event_A5_gNB_sends_UE_RRC_Reconfiguration
    [Tags]     QCT  B_35
    5GC000706_B_35


[1]5GC000706_B_036_IntraDU_HO_based_on_event_A5_contention_free_RACH_procedure
    [Tags]     QCT  B_36
    5GC000706_B_36


[1]5GC000706_B_037_IntraDU_HO_based_on_event_A5_with_downlink_traffic
    [Tags]     QCT  B_37
    5GC000706_B_37


[1]5GC000706_B_038_IntraDU_HO_based_on_event_A5_with_uplink_traffic
    [Tags]     QCT  B_38
    5GC000706_B_38
