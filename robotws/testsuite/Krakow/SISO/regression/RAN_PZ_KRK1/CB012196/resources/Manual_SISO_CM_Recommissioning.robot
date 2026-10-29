*** Settings ***
Documentation
...   Test CB012196 - Manual_SiSo_CM_Recommissioning
...   author: Marek Szłapa
...   contact: marek.szlapa@nokia.com


*** Variables ***
@{X2link_alarms}    No X2 link available    No X2 link available for a specific LTEENB


*** Keywords ***
CB012196_Manual_SiSo_CM_Recommissioning
    gnbscf.change_parameter         dist_name=MRBTS-{}/NRBTS-{}/NRPMRNL-1
    ...                             parameter=NR Paging
    ...                             value=disabled
    gnbscf.activate_plan
    wait_for_site_to_be_onair
    gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/NRBTS-{}/NRPMRNL-1
    ...                                     parameter=NR Paging
    ...                                     value=disabled
    Perform NSA L3 Call on all cells

    gnbscf.change_parameter         dist_name=MRBTS-{}/NRBTS-{}/NRCELL-3
    ...                             parameter=PRACH configuration index
    ...                             value=190
    gnbscf.activate_plan
    wait_for_site_to_be_onair
    gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/NRBTS-{}/NRCELL-3
    ...                                     parameter=PRACH configuration index
    ...                                     value=190
    Perform NSA L3 Call on all cells

    gnbalarm.allow_alarm    ${X2link_alarms}
    gnbscf.change_parameter         dist_name=MRBTS-{}/MNL-1/MNLENT-1/SYNC-1
    ...                             parameter=Manual frame timing adjustment
    ...                             value=1
    gnbscf.activate_plan
    wait_for_site_to_be_onair
    gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/MNL-1/MNLENT-1/SYNC-1
    ...                                     parameter=Manual frame timing adjustment
    ...                                     value=1 µs
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
    gnbalarm.disallow_alarm    ${X2link_alarms}
    Perform NSA L3 Call on all cells

    gnbscf.change_parameter         dist_name=MRBTS-{}/NRBTS-{}/NRCELL-3
    ...                             parameter=Maximum output power
    ...                             value=14
    gnbscf.activate_plan
    wait_for_site_to_be_onair
    gnbscf.verify_parameter_after_change   dist_name=MRBTS-{}/NRBTS-{}/NRCELL-3
    ...                                    parameter=Maximum output power
    ...                                    value=14 dBm
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
    Perform NSA L3 Call on all cells

    gnblog.save_and_verify_report
    gnbscf.verify_parameters_value_can_be_set_incorrectly   dist_name=MRBTS-{}/NRBTS-{}/NRCELL-3
    ...                                                     parameter=Maximum output power
    ...                                                     value=100
    gnbscf.verify_parameter_after_change    dist_name=MRBTS-{}/NRBTS-{}/NRCELL-3
    ...                                     parameter=Maximum output power
    ...                                     value=14 dBm
