*** Settings ***
Documentation
...           Description : Test Cases for 5GC000706, related to Scenario 3: Inter-gNB, measurement A3 without traffic
...
...              Author : Yves Gorjux          yves.gorjux@nokia.com
...                     : Jia Liao             jia.liao@nokia.com
...              last update : 31.08.2020
...
...        Hardware configuration:
...         - 2 gNBs with at least 1 cell each equipped with RU
...         - All RUs are connected to an attenuator
...         - UE Qualcomm with iperf3 installed
...         - Real Core Network for SA mode
...        In the SCF:
...         - Counter reporting interval is set to 5mn
...         - The two cells are configured with different frequencies
...         - A handover relation is defined under the source cell to the target cell
...         - The target frequency is to be detected via event A3 based on RSRP measurement
...         - Event A1 is configured so that it is possible to trigger this event by playing with attenuators
...         - Event A2 is configured so that it is possible to trigger this event by playing with attenuators
...         - Event A3 is configured so that after the handover the event A2 is not immediately triggered when arriving
...           on the target cell
...        In the custom.yaml:
...         - source_attenuations_attach: set to a value allowing the attach on source cell without triggering event A2
...         - target_attenuations_attach: set to maximum attenuation to avoid interference for the attach on source cell
...         - source_attenuations_a2: set to a value that allows to trigger event A2 on the source cell when attenuation
...           is increased from source_attenuations_attach to source_attenuations_a2.
...         - target_attenuations_a2: set to a value that does not allow the handover but not too far from this point.
...         - source_attenuations_ho_trigger:   same as source_attenuations_a2
...         - target_attenuations_ho_trigger:   is set to a value that allows to trigger the handover on the target cell
...           when attenuation is decreased from target_attenuations_a2 to target_attenuations_ho_trigger.'
...         - The triggering of the events A2 and A3 shall be done during a reporting period of 5mn (300s).
...           Our attenuator needs around 12s to change the two paths of one cell for each step. Scenario implement
...           step of 2dB when changing the attenuation from one point to another point. We keep a margin of 60s.
...           For our custom.yaml, we use the following formula:
...           (source_xx_a2 - source_xx_attach + target_xx_ho_trigger - target_xx_a2) / 2dB * 12s +60 <= 300s
...

Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC000706_S3b_IntergNB_MeasA3.robot

Force Tags           5G_RAN     STATE_ON_AIR

Suite Setup          5GC000706_Suite_Setup

Suite Teardown       5GC000706_Suite_Teardown


*** Test Case ***
[1]5GC000706_B_040_Check_counter_TOT_INTER_FREQ_HO_DECISION_A3_PI_M55147C00024
    [Tags]     QCT  B_40
    5GC000706_B_40


[1]5GC000706_B_055_InterGnb_HO_based_on_event_A3_gNB_sends_UE_RRC_Reconfiguration
    [Tags]     QCT  B_55
    5GC000706_B_55


[1]5GC000706_J_260_Check_counter_ATT_OG_IF_INTER_GNB_HO_SA_PLMN_PI_M55145C00351
    [Tags]     QCT  J_260
    5GC000706_J_260


[1]5GC000706_J_261_Check_counter_SUCC_OG_IF_INTERGNB_HO_SA_PLMN_PI_M55145C00352
    [Tags]     QCT  J_261
    5GC000706_J_261


[1]5GC000706_J_262_Check_counter_SUCC_IC_INTER_GNB_HOP_SA_PLMN_PI_M55145C00361
    [Tags]     QCT  J_262
    5GC000706_J_262


[1]5GC000706_J_263_Check_counter_SUCC_IC_INTER_GNB_HO_SA_PLMN_PI_M55145C00362
    [Tags]     QCT  J_263
    5GC000706_J_263


[1]5GC000706_J_264_Check_counter_ATT_IF_INTER_GNB_HO_SLICE_PI_M55149C00570
    [Tags]     QCT  J_264
    5GC000706_J_264
