*** Settings ***
Documentation
...     Author: Marek Bodziony, marek.bodziony@nokia.com
...     Author: Dominik Baran, dominik.baran@nokia.com
...     Maintainer: Marek Bodziony, marek.bodziony@nokia.com
...
...     CB007271-A is a parity feature of 5GC000614 for ABIN.
...     This feature has been introduced to cover SFP and QSFP monitoring that is mainly used for troubleshooting
...     purposes or on new installation in case of SFP/QSFP optical interface problem between (a) Radio Units and BB
...     capacity (b) CU & DU (c) Radio Units. The diagnostics information gives a very good indication of the fibre link
...     quality between (a) radio and RAU (b) CU & DU. This feature supports all types of: SFP/SFP+/SFP28/QSFP which is
...     used by Nokia.

Resource    testsuite/Krakow/resources/RAN_VRF_KRK3/SFP/sfp_common.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Suite Setup         Suite Setup With OnAir Test Line Preparation and Get SFP links details
Test Setup          Common Preconditions
Test Teardown       Common Postconditions

Force Tags      STATE_SW_UPLOADED    CRT    PY36
...  RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABINB4_AHLOA_NETACT
...  RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABINB4_AHLOA_NETACT
...  RAN_5G__WITH__SBTS23R1__WITH__CLOUD_5G_CLASSICAL_ASIBR_ABINB4_AHLOA_NETACT

*** Variables ***
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  LMP access via port 3600
...                  Diagnostic Files collected
...                  Radio Diagnostic Files collected
...                  BTS Reset Cause
...                  Service account root access is enabled
...                  Ethernet port security is disabled
...                  ToP reference missing
...                  Sanity Check Error
...                  Diagnostic Check Error
...                  No X2 link available
...                  No X2 link available for a specific LTEENB
...                  No connection to unit
...                  Cell blocked

*** Test Cases ***
[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_ABIN(dynamic_data)
    ${sfp_for_BBMOD}=     Get SFP links details for BBMOD
    Check if SFP dynamic parameters have a valid values     ${sfp_for_BBMOD}
    sleep   1min
    ${sfp_for_BBMOD}=     Get SFP links details for BBMOD
    Check if SFP dynamic parameters have a valid values     ${sfp_for_BBMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_CPRI-N_RU(dynamic_data)
    ${sfp_for_RMOD}=     Get SFP links details for RMOD
    Check if SFP dynamic parameters have a valid values     ${sfp_for_RMOD}
    sleep   1min
    ${sfp_for_RMOD}=     Get SFP links details for RMOD
    Check if SFP dynamic parameters have a valid values     ${sfp_for_RMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_ABIN(static_data-Rx_parameters)
    ${sfps_for_BBMOD}=     Get SFP links details for BBMOD
    Check if SFP static RX parameters have a valid values   ${sfps_for_BBMOD}    ${sfps_hw_BBMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_CPRI-N_RU(static_data-Rx_parameters)
    ${sfps_for_RMOD}=     Get SFP links details for RMOD
    Check if SFP static RX parameters have a valid values   ${sfps_for_RMOD}     ${sfps_hw_RMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_ABIN(static_data-Tx_parameters)
    ${sfps_for_BBMOD}=     Get SFP links details for BBMOD
    Check if SFP static TX parameters have a valid values     ${sfps_for_BBMOD}  ${sfps_hw_BBMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_CPRI-N_RU(static_data-Tx_parameters)
    ${sfps_for_RMOD}=     Get SFP links details for RMOD
    Check if SFP static TX parameters have a valid values  ${sfps_for_RMOD}      ${sfps_hw_RMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_ABIN(static_data-SFP_QSFP_parameters)
    ${sfps_for_BBMOD}=     Get SFP links details for BBMOD
    Check if SFP static HW parameters have a valid values for BBMOD    ${sfps_for_BBMOD}    ${sfps_hw_BBMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_CPRI-N_RU(static_data-SFP_QSFP_parameters)
    ${sfps_for_RMOD}=     Get SFP links details for RMOD
    Check if SFP static HW parameters have a valid values for RMOD    ${sfps_for_RMOD}      ${sfps_hw_RMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_ABIN(static_data-Temperature_parameters)
    ${sfps_for_BBMOD}=     Get SFP links details for BBMOD
    Check if SFP static Temperature parameters have a valid values    ${sfps_for_BBMOD}    ${sfps_hw_BBMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_WebEM_for_CPRI-N_RU(static_data-Temperature_parameters)
    ${sfps_for_RMOD}=     Get SFP links details for RMOD
    Check if SFP static Temperature parameters have a valid values    ${sfps_for_RMOD}    ${sfps_hw_RMOD}

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_NetAct_for_ABIN(static_data)
    Check if SFP static parameters from NetAct have a valid values    ${sfps_hw_BBMOD}    bbmod

[1][1.0]CB007271-A-5GC000614-Initiate_SFP_QSFP_Monitoring_from_NetAct_for_CPRI-N_RU(static_data)
    Check if SFP static parameters from NetAct have a valid values    ${sfps_hw_RMOD}    rmod

[1][1.0]CB007271-A-5GC000614-Retrieve_periodic_SFP_QSFP_Snapshot_data
    ${sfps_for_RMOD}=     Get SFP links details from Snapshot
    Check if SFP dynamic parameters retrieved from Snapshot have a valid values    ${sfps_for_RMOD}
    sleep   1min
    ${sfps_for_RMOD}=     Get SFP links details from Snapshot
    Check if SFP dynamic parameters retrieved from Snapshot have a valid values     ${sfps_for_RMOD}
    [Teardown]      Remove Snapshot TEMP_DIR after test

[1][1.0]CB007271-A-5GC000614-Dynamic_SFP_QSFP_Parameters_saved_into_PM_counters_for_ABIN
    ${sfps_for_BBMOD}=     Get SFP dynamic parameters from PM counters for BBMOD
    Check if SFP dynamic parameters retrieved from PM counters have a valid values for BBMOD   ${sfps_for_BBMOD}
    sleep   15min
    ${sfps_for_BBMOD}=     Get SFP dynamic parameters from PM counters for BBMOD
    Check if SFP dynamic parameters retrieved from PM counters have a valid values for BBMOD     ${sfps_for_BBMOD}
    [Teardown]      Remove Snapshot TEMP_DIR after test

[1][1.0]CB007271-A-5GC000614-Dynamic_SFP_QSFP_Parameters_saved_into_PM_counters_for_CPRI-N_RU
    ${sfps_for_RMOD}=     Get SFP dynamic parameters from PM counters for RMOD
    Check if SFP dynamic parameters retrieved from PM counters have a valid values for RMOD    ${sfps_for_RMOD}
    sleep   15min
    ${sfps_for_RMOD}=     Get SFP dynamic parameters from PM counters for RMOD
    Check if SFP dynamic parameters retrieved from PM counters have a valid values for RMOD     ${sfps_for_RMOD}
    [Teardown]      Remove Snapshot TEMP_DIR after test
