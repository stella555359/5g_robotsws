*** Settings ***
Documentation
...   Test suite for regression testing of feature CB012649
...   author: Malgorzata Pietka
...   contact: malgorzata.pietka@nokia.com

*** Keywords ***
Manual_SiSo_CM_Recommissioning
    [Arguments]     @{cell_ids}
    Logger.Log Info To Console         === NR paging ===
    gnbscf.change_parameter         dist_name=MRBTS-{}/NRBTS-{}
    ...                             parameter=Activate Paging
    ...                             value=true
    gnbscf.change_parameter         dist_name=MRBTS-{}/NRBTS-{}/NRPMRNL-1
    ...                             parameter=NR Paging
    ...                             value=5min
    gnbscf.activate_plan
    wait_for_site_to_be_onair
    gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/NRBTS-{}
    ...                                     parameter=Activate Paging
    ...                                     value=true
    gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/NRBTS-{}/NRPMRNL-1
    ...                                     parameter=NR Paging
    ...                                     value=5min
    Logger.Log Info To Console          === NR paging activated ===

    Logger.Log Info To Console    === PRACH configuration index===
    FOR     ${cell_ids}      IN      @{cell_ids}
        gnbscf.change_parameter         dist_name=MRBTS-{}/NRBTS-{}/${cell_ids}
        ...                             parameter=PRACH configuration index
        ...                             value=182
    END
    gnbscf.activate_plan
    wait_for_site_to_be_onair
    FOR     ${cell_ids}      IN      @{cell_ids}
        gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/NRBTS-{}/${cell_ids}
         ...                                     parameter=PRACH configuration index
         ...                                     value=182
    END
    Logger.Log Info To Console         === PRACH 162 activated ===

    Logger.Log Info To Console         === Manual frame timing adjustment ===
    gnbscf.change_parameter         dist_name=MRBTS-{}/MNL-1/MNLENT-1/SYNC-1
    ...                             parameter=Manual frame timing adjustment
    ...                             value=1 µs
    gnbscf.activate_plan
    wait_for_site_to_be_onair

    gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/MNL-1/MNLENT-1/SYNC-1
    ...                                     parameter=Manual frame timing adjustment
    ...                                     value=1 µs
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
    Logger.Log Info To Console         === Manual frame timing activated ===

    Logger.Log Info To Console         === Maximum output power ===
    FOR     ${cell_ids}      IN      @{cell_ids}
        gnbscf.change_parameter         dist_name=MRBTS-{}/NRBTS-{}/${cell_ids}
        ...                             parameter=Maximum output power
        ...                             value=21
    END
    gnbscf.activate_plan
    wait_for_site_to_be_onair
    FOR     ${cell_ids}      IN      @{cell_ids}
        gnbscf.verify_parameter_after_change   dist_name=MRBTS-{}/NRBTS-{}/${cell_ids}
        ...                                    parameter=Maximum output power
        ...                                    value=21
    END
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
    Logger.Log Info To Console         === Maximum output power activated ===

    Logger.Log Info To Console         === Maximum output power incorrect value===
    gnbscf.verify_parameters_value_can_be_set_incorrectly   dist_name=MRBTS-{}/NRBTS-{}/NRCELL-0
    ...                                                     parameter=Maximum output power
    ...                                                     value=100
    gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/NRBTS-{}/NRCELL-0
    ...                                     parameter=Maximum output power
    ...                                     value=17 dBm
     Logger.Log Info To Console         === Maximum output power incorrect value finished===
