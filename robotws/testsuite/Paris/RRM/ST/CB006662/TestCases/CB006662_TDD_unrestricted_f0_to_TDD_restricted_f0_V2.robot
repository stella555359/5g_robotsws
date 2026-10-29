*** Settings ***
Documentation
...           Description : Test Cases for CB006662, related to scenario mobility TDD prach f0 to TDD prach f0
...
...              Author : Anne Dutheillet         anne.dutheillet_lamonthe@nokia.com
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
...         - The target frequency is to be detected via event A3 based on RSRP measurement
...         - Event A1 is configured so that it is possible to trigger this event by playing with attenuators
...         - Event A2 is configured so that it is possible to trigger this event by playing with attenuators
...         - Event A3 is configured so that after the handover the event A2 is not immediately triggered when arriving
...           on the target cell
...        In the custom.yaml:
...         - source_attenuations_attach: is set to a value allowing the attach on the source cell without triggering
...           event A2
...         - target_attenuations_attach: is set to maximum attenuation value to avoid interference for the attach on
...           the source cell
...         - source_attenuations_a2: is set to a value that allows to trigger event A2 on the source cell when
...           attenuation is increased from source_attenuations_attach to source_attenuations_a2.
...         - target_attenuations_a2:   is set to a value that does not allow the handover but that is not too far from
...           this point.
...         - source_attenuations_ho_trigger:   same as source_attenuations_a2
...         - target_attenuations_ho_trigger:   is set to a value that allows to trigger the handover on the target cell
...           when attenuation is decreased from target_attenuations_a2 to target_attenuations_ho_trigger.
...         - The triggering of the events A2 and A3 shall be done during a reporting period of 5mn (300s). Our
...           attenuator needs around 12s to change the two paths of one cell for each step. Scenario implement step
...           of 2dB when changing the attenuation from one point to another point. We keep a margin of 60s.
...           For our custom.yaml, we use the following formula:
...           (source_xx_a2 - source_xx_attach + target_xx_ho_trigger - target_xx_a2) / 2dB * 12s +60 <= 300s
...

Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/CB006662_S0_IntraDU_MeasA3_TU_to_TRf0_V2.robot

Force Tags           5G_RAN     STATE_ON_AIR

Suite Setup          CB006662_Suite_Setup

Suite Teardown       CB006662_Suite_Teardown


*** Test Case ***

[1]CB006662_5G_A_B_003_BRANCH_Intra_gNB_IntraFreq_HO_from_Restricted_TDD_PRACH_F0_to_Restricted_TDD_PRACH_F1
    [Tags]     QCT  T_U
    CB006662_T_U

