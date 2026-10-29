# Test transferred from Krakow, will be rewritten
*** Settings ***

Documentation
...   author: Mateusz Plinta
...   contact: mateusz.plinta@nokia.com
...   description: 5GC001085-B sub-feature: Intra Frequency Inter-gNB neighbor NRREL addition
...                Previously established Xn (Include Error Handling)

Library    ute_fsmaccess
Library    ta5g_tshark
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_pm_counters
Library    ute_wtssim
Library    ta5g_egate
Library    resources/suite_specific_keywords.py
Library    resources/egate_actions.py
Library    resources/syslog_validation.py
Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   resources/keywords.robot

Force Tags      STATE_CONFIGURED    CIT    CDRT    RAN_5G
...             CLOUD_5G_I_LO_AP_LO
...             CLOUD_5G_I_MP_AP_LO


Suite Setup     Run Keywords    Set variables based on deployment and release in robot    feature=1085-B
...                      AND    Delete XNLINK If Unit Is ASOE
...                      AND    Perform recomissioning with delta    path_to_delta=${CURDIR}${/}resources${/}deltas${/}${DELTA_FILE}


Variables  resources/variables.py

*** Test Cases ***
[1]5GC001085_B_003_Empty_gnbIdLengthConfig_object_-_trigger_ANR
    [Timeout]  2h
    [Setup]    Run Keywords    Prepare environment    wts_config_filename=${WTS_CONFIG_B_FILENAME}
    ...                                               sib1_reception_dict=${CELLS_1XSIM_1XREAL}
    ...                                               xnlink_check=${True}
    ...                 AND    Set gnbIdLengthConfig    value=${GNB_ID_LENGTH_CONFIG_TC_B003}
    ...                 AND    Wait For Next Full PM Interval
    ...                 AND    Start collecting logs

    Attach Ue and Establish Pdu Session
    Send A3 measurement report with PCI    pci=49    nrsrp_nr=90    ho_type=inter    should_perform_ho=${True}

    Verify syslog ANR PCI resolution success for PCI    pci=49
    Verify syslog PCI identified
    Verify syslog HO succeeded

    Wait For Next Full PM Interval
    ${PM_COUNTER_FILE}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55147C00001  1  TOT_INTRA_FREQ_HO_DECISION_A3S
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTER_FILE}
    ...    report_pm_counter=True

    [Teardown]    Run Keywords    Teardown collecting logs in robot
    ...                    AND    Delete object if it exists    dist_name=${LAST_NRREL_DIST_NAME}
    ...                    AND    Delete object if it exists    dist_name=${LAST_NRADJNRCELL_DIST_NAME}
