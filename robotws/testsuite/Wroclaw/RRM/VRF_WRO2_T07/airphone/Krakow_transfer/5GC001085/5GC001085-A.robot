# Test transferred from Krakow, will be rewritten
*** Settings ***

Documentation
...   author: Mateusz Plinta
...   contact: mateusz.plinta@nokia.com
...   description: 5GC001085-A sub-feature: Intra Frequency Intra-gNB neighbor NRREL addition (Include Error Handling)

Library    ute_fsmaccess
Library    ta5g_tshark
Library    ta5g_iphy
Library    ta5g_enb
Library    ute_wtssim
Library    ta5g_egate
Library    resources/suite_specific_keywords.py
Library    resources/egate_actions.py
Library    resources/syslog_validation.py
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/pm_counters.py
Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   resources/keywords.robot


Force Tags      STATE_CONFIGURED   RAN_5G    PY36
...             CLOUD_5G_O_E_AP_LOO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
...             CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE


Suite Setup     Run Keywords    Set variables based on deployment and release in robot    feature=1085-A
...                      AND    Perform recomissioning with delta    path_to_delta=${CURDIR}${/}resources${/}deltas${/}${DELTA_FILE}

Test Setup      Prepare env and start collecting logs    wts_config_filename=${WTS_CONFIG_A_FILENAME}
Test Teardown   Teardown collecting logs and ensure there are none NRRELs
Suite Teardown   Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                        dir_name=admin_api_logs

Variables  resources/variables.py

*** Test Cases ***
[1]5GC001085_A_001_Feature_flag_activation_and_deactivation
    [Tags]     CRT_ASIL    CRT_ASOE
    [Timeout]  2h
    [Setup]  Run Keywords    Change GSCN In Iphy    gscn_value=7915    cell_id=${1}
    ...               AND    Change GSCN In Iphy    gscn_value=8019    cell_id=${2}
    ...               AND    Perform recomissioning with delta
    ...                      path_to_delta=${CURDIR}${/}resources${/}deltas${/}${RELEASE}${/}DELTA_1085-A_CA.json
    ...               AND    Prepare environment   wts_config_filename=${WTS_CONFIG_A_FILENAME_TC1}
    ...                      sib1_reception_dict=${CELLS_2XREAL}
    ...               AND    Wait For First Counters Values To Arrive
    ...               AND    Start collecting logs

    ${list_of_states} = 	Create List 	Commissioned    Configured    OnAir
    ${STATE} =    Assert gNB in either of the following states    ${list_of_states}
    ${NUM_OF_ALARMS}  ${ALARMS_SET} =    Get critical or major alarms
    ${ignored_alarms_list} =   Create List    7100    7300    4707    7107
    ${ue_1}=    Set Variable    1
    ${ue_2}=    Set Variable    2
    ${pm_interval}=    Set Variable    ${PM_PERIOD}
    ${GNB_DU_SCELL_ADMI_SUCC_SA}=    Set Variable     M55139C01002

    Attach Ue and Establish Pdu Session    ue_id=${ue_1}
    Send A1 measurement report for UE    ue_id=${ue_1}
    Wait For Next Pm Period    interval=${pm_interval}

    ${counters_list} =   Create List    ${GNB_DU_SCELL_ADMI_SUCC_SA}
    ${counters_data} =   get_pm_counters_values    counter_ids_list=${counters_list}
    Verify any counters extended   {"${GNB_DU_SCELL_ADMI_SUCC_SA}": "NRCELL-2/RSADU"} > 0
    ...                            counters_data=${counters_data}    timestamp_offset=${0}

    Deactivate feature flag
    Assert feature flag deactivated
    Assert gNB did not drop to lower state    ${STATE}
    Assert no new major or critical alarms appeared    previous_num_of_alarms=${NUM_OF_ALARMS}
    ...                                                previous_alarms_set=${ALARMS_SET}
    ...                                                ignored_alarms=${ignored_alarms_list}

    Attach Ue and Establish Pdu Session    ue_id=${ue_2}
    Send A1 measurement report for UE    ue_id=${ue_2}
    Wait For Next Pm Period    interval=${pm_interval}

    ${counters_data} =   get_pm_counters_values    counter_ids_list=${counters_list}
    Verify any counters extended   {"${GNB_DU_SCELL_ADMI_SUCC_SA}": "NRCELL-2/RSADU"} > 0
    ...                            counters_data=${counters_data}    timestamp_offset=${0}

    Activate feature flag
    Assert feature flag activated
    Assert gNB did not drop to lower state    ${STATE}
    Assert no new major or critical alarms appeared    previous_num_of_alarms=${NUM_OF_ALARMS}
    ...                                                previous_alarms_set=${ALARMS_SET}
    ...                                                ignored_alarms=${ignored_alarms_list}

    [Teardown]  Run Keywords    Teardown collecting logs and ensure feature flag is activated in the end
    ...                  AND    Change GSCN In Iphy    gscn_value=7880    cell_id=${1}
    ...                  AND    Change GSCN In Iphy    gscn_value=7880    cell_id=${2}
    ...                  AND    Perform recomissioning with delta
    ...                         path_to_delta=${CURDIR}${/}resources${/}deltas${/}${RELEASE}${/}DELTA_1085-A_CA_anty.json


[1]5GC001085_A_012_Resolved_unknown_cell_forbidden_by_MRL
    [Tags]     CRT_ASIL
    [Timeout]  2h

    ${UE1_ID}=       Set Variable    1
    ${UE2_ID}=       Set Variable    2
    Create mobility restriction list on AMF
    Assign mobility restriction list to UEs    ue_ids=${UE1_ID}
    Attach Ue and Establish Pdu Session    ue_id=${UE1_ID}
    Attach Ue and Establish Pdu Session    ue_id=${UE2_ID}
    Send A3 measurement report with PCI    pci=51    ue_id=${UE1_ID}
    Verify syslog HO to cell 51 failed because of MRL restricted
    Send A3 measurement report with PCI    pci=51    ue_id=${UE2_ID}    should_perform_ho=${True}
    Verify syslog HO completed
    Wait for OAM config update
    Assert existance of more than n NRRELs in SCF    ${0}


[1]5GC001085_A_017_Re-Check_and_Unknown_PCI_received_in_A3_Measurement_Report_-_Two_combinations
    [Tags]     CRT_ASIL    CRT_ASOE
    [Timeout]  2h

    ${UE1_ID}=       Set Variable    1
    ${UE2_ID}=       Set Variable    2
    ${UE3_ID}=       Set Variable    3
    ${UE4_ID}=       Set Variable    4
    ${UE5_ID}=       Set Variable    5

    Attach Ue and Establish Pdu Session    ue_id=${UE1_ID}
    Attach Ue and Establish Pdu Session    ue_id=${UE2_ID}
    Attach Ue and Establish Pdu Session    ue_id=${UE3_ID}
    Attach Ue and Establish Pdu Session    ue_id=${UE4_ID}
    Attach Ue and Establish Pdu Session    ue_id=${UE5_ID}

    Send A3 measurement report with PCI    pci=51    ue_id=${UE1_ID}    should_perform_ho=${True}
    Verify syslog ANR PCI resolution success for PCI    pci=51
    Verify syslog pci identified
    Verify syslog HO succeeded

    Trigger failure of next handover    ue_id=${UE2_ID}
    Send A3 measurement report with PCI    pci=51    ue_id=${UE2_ID}    should_perform_ho=${False}

    Trigger failure of next handover    ue_id=${UE3_ID}
    Send A3 measurement report with PCI    pci=51    ue_id=${UE3_ID}    should_perform_ho=${False}

    Trigger failure of next handover    ue_id=${UE4_ID}
    Send A3 measurement report with PCI    pci=51    ue_id=${UE4_ID}    should_perform_ho=${False}

    Send A3 measurement report with 51 and 60 PCIs with higher RSRP for 60  ue_id=${UE5_ID}  should_perform_ho=${False}
    Verify syslog RRCReconfigurationComplete timeout

    Send A3 measurement report with 51 and 60 PCIs with higher RSRP for 51  ue_id=${UE5_ID}  should_perform_ho=${True}
    Verify syslog pci confirmed
    Verify syslog HO succeeded      number_of_messages=${2}

    Wait for OAM config update
    Assert existance of more than n NRRELs in SCF    ${0}


[1]5GC001085_A_020_NRREL_Creation_failed_-_maxNumAnrNrrelAllowed_exceeded
    [Tags]     CRT_ASIL    CRT_ASOE
    [Setup]  Run Keywords    Create fake NRREL and NRADJNRCELL objects and set maxNumAnrNrrelAllowed to 1
    ...               AND    set variables for 1085 a tc20
    ...               AND    Create NRANRPR NRREL and NRADJNRCELL objects for fdd cells
    ...               AND    Create inter frequency relation to band 66
    ...               AND    Prepare env and start collecting logs    wts_config_filename=${WTS_CONFIG_A_FILENAME}

    Attach Ue and Establish Pdu Session
    Attach Ue and Establish Pdu Session    ue_id=20
    Send A3 measurement report with PCI    pci=51    should_perform_ho=${True}
    Send A3 measurement report with PCI    ue_id=20    pci=${FIRST_PCI_FDD}    pass_regexp=${FIRST_FDD_HO_REGEX}
    Send A3 measurement report with PCI    ue_id=20    pci=${SECOND_PCI_FDD}    pass_regexp=${SECOND_FDD_HO_REGEX}
    Wait for OAM config update
    Assert values of NRREL object    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1    id_=1
    ...                              gNbId=2005    gNbIdLength=22    lcrId=1
    Assert values of NRREL object    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-256    id_=256
    ...                              gNbId=1   gNbIdLength=22    lcrId=2
    Assert values of NRREL object    dist_name=MRBTS-1${/}NRBTS-1${/}NRCELL-${THIRD_CELL_ID}${/}NRREL-1    id_=1
    ...                              gNbId=2005   gNbIdLength=22    lcrId=2
    Assert values of NRREL object    dist_name=MRBTS-1${/}NRBTS-1${/}NRCELL-${FOURTH_CELL_ID}/NRREL-256    id_=256
    ...                              gNbId=1   gNbIdLength=22    lcrId=${THIRD_CELL_ID}
    Assert values of NRREL object    dist_name=MRBTS-1${/}NRBTS-1${/}NRCELL-${FOURTH_CELL_ID}/NRREL-1   id_=1
    ...                              gNbId=2005   gNbIdLength=22    lcrId=3

    [Teardown]    Run keywords     Teardown collecting logs in robot
    ...                    AND     Delete object    dist_name=${FIRST_NRREL_DIST_NAME}
    ...                    AND     Delete object    dist_name=${FIRST_NRADJNRCELL_DIST_NAME}
    ...                    AND     Delete object    dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-2
    ...                    AND     Delete object    dist_name=MRBTS-1/NRBTS-1/NRANRPR-2
    ...                    AND     Delete object    dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-3
    ...                    AND     Delete object    dist_name=MRBTS-1${/}NRBTS-1${/}NRCELL-${FOURTH_CELL_ID}${/}NRHOIF-1
    ...                    AND     Delete all nrrels
    ...                    AND     Set maxNumAnrNrrelAllowed    ${50}
