*** Settings ***
Documentation
...         Description : Test Cases for 5GC000706, related to Scenario 7: Intra-DU, interband n41->n7, measurement A3
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
...         - The target frequency is to be detected via event A3 /A5 based on RSRP measurement
...         - Event A1 is configured so that it is possible to trigger this event by playing with attenuators
...         - Event A2 is configured so that it is possible to trigger this event by playing with attenuators
...         - Configure event A3 or event A5 in the following way:
...         - Event A3 is configured so that after the handover the event A2 is not immediately triggered when
...           arriving on the target cell
...         - Event A5 is configured in a way that on the source cell side once event A2 triggered the condition for
...          HO is always fulfilled, and on target cell side after the handover event A2 is not immediately triggered.
...         - DRX is deactivated at source cell side (actCDrx=false) and activated at target cell side
...           (actCDrx=true & actProactUlScheduling=false)
...        In the custom.yaml:
...         - source_attenuations_attach: set to a value allowing the attach on source cell without triggering event A2
...         - target_attenuations_attach: set to maximum attenuation to avoid interference for the attach on source cell
...         - source_attenuations_a2: set to a value that allows to trigger event A2 on the source cell when attenuation
...           is increased from source_attenuations_attach to source_attenuations_a2.
...         - target_attenuations_a2: set to a value that does not allow the handover but not too far from this point.
...         - source_attenuations_ho_trigger: same as source_attenuations_a2
...         - target_attenuations_ho_trigger: is set to a value that allows to trigger the handover on the target cell
...           when attenuation is decreased from target_attenuations_a2 to target_attenuations_ho_trigger.'
...         - The triggering of the events A2 and A3 /A5 shall be done during a reporting period of 5mn (300s).
...           Our attenuator needs around 12s to change the two paths of one cell for each step. Scenario implement
...           step of 2dB when changing the attenuation from one point to another point. We keep a margin of 60s.
...           For our custom.yaml, we use the following formula:
...           (source_xx_a2 - source_xx_attach + target_xx_ho_trigger - target_xx_a2) / 2dB * 12s +60 <= 300s
...

Variables         ../../../../resources/ST/python/custom.py
Resource          ../Resources/robot/5GC000706_S3DRX_IntergNB.robot

Force Tags           5G_RAN     STATE_ON_AIR

Suite Setup          5GC000706_Suite_Setup

Suite Teardown       5GC000706_Suite_Teardown


*** Test Case ***
[1]5GC000706_C_386_Successful inter-frequency inter-gNB handover from no DRX to DRX in TDD
    [Tags]     QCT      C_386
    5GC000706_C_386
