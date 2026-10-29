# Test transferred from Krakow, will be rewritten
*** Settings ***

Documentation
...   author: Mateusz Plinta
...   contact: mateusz.plinta@nokia.com
...   Description: 5GC001085-C Intra Frequency NRREL deletion (Pruning) based on Measurement Reports

Library    ute_fsmaccess
Library    ta5g_tshark
Library    ta5g_iphy
Library    ta5g_enb
Library    ute_wtssim
Library    ta5g_egate
Library    resources/suite_specific_keywords.py
Library    resources/egate_actions.py
Library    resources/syslog_validation.py
Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   resources/keywords.robot

Force Tags      STATE_CONFIGURED   RAN_5G    PY36
...             CLOUD_5G_O_E_AP_LOO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
...             CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup     Run Keywords    Set variables based on deployment and release in robot    feature=1085-C
...                      AND    Delete XNLINK If Unit Is ASOE
...                      AND    Configure VM interfaces for additional ransim cells
...                      AND    Change duration of periodic removal cycle via aashell    value=${PERIODIC_REMOVAL_CYCLE_DURATION}
...                      AND    Perform recomissioning with delta    path_to_delta=${CURDIR}${/}resources${/}deltas${/}${DELTA_FILE}


Test Teardown    Teardown collecting logs and ensure there are none NRRELs
Suite Teardown   Teardown suite for 1085_C

Variables  resources/variables.py

*** Test Cases ***
[1]5GC001085_C_003_Check_periodic_removal_of_various_NRREL_and_NRADJNRCELL
    [Tags]     CRT_ASIL    CRT_ASOE
    [Timeout]  2h
    [Setup]    Run Keywords    Prepare environment    wts_config_filename=${WTS_CONFIG_C_FILENAME}
    ...                                               sib1_reception_dict=${CELLS_3XSIM_2XREAL}
    ...                 AND    Assert rdNeighRemovalEvaluationTime via aashell    value=${PERIODIC_REMOVAL_CYCLE_DURATION}
    ...                 AND    Set actAutoNrNbRemoval    value=${False}
    ...                 AND    Set idleTimeForNrNbRemoval    value=${3}
    ...                 AND    Create NRRELs and NRADJNRCELLs for C003
    ...                 AND    Start collecting logs

    ${release} =    Get Variable Value     ${RELEASE}
    ${baseline} =    Establish baseline for periodic removal cycle

    Attach Ue and Establish Pdu Session
    Send A3 measurement report with PCI    pci=49    ho_type=inter    should_perform_ho=${True}

    Verify syslog ANR PCI resolution success for PCI    pci=49
    Verify syslog PCI identified
    Verify syslog HO succeeded
    Wait for next periodic removal cycle and OAM update    ${baseline}

    Set actAutoNrNbRemoval    value=${True}
    Wait for next periodic removal cycle and OAM update    ${baseline}

    Wait for next periodic removal cycle and OAM update    ${baseline}

    Attach Ue and Establish Pdu Session    ue_id=2
    Send A3 measurement report with PCI    ue_id=2    pci=51   ho_type=intra   should_perform_ho=${True}
    Verify syslog HO succeeded     number_of_messages=${2}
    Wait for next periodic removal cycle and OAM update    ${baseline}

    ${list_of_present_objects} = 	Create List   MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...                                           MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    ...                                           MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3
    ...                                           MRBTS-1/NRBTS-1/NRCELL-1/NRREL-4
    ...                                           ${LAST_NRREL_DIST_NAME}
    ...                                           MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                                           MRBTS-1/NRBTS-1/NRADJNRCELL-2
    ...                                           MRBTS-1/NRBTS-1/NRADJNRCELL-3
    ...                                           ${LAST_NRADJNRCELL_DIST_NAME}
    Assert existence of objects in SCF   list_of_present_objects=${list_of_present_objects}
    Wait for next periodic removal cycle and OAM update    ${baseline}

    ${list_of_present_objects} = 	Create List    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...                                            MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    ...                                            MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3
    ...                                            MRBTS-1/NRBTS-1/NRCELL-1/NRREL-4
    ...                                            MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                                            MRBTS-1/NRBTS-1/NRADJNRCELL-2
    ...                                            MRBTS-1/NRBTS-1/NRADJNRCELL-3
    ...                                            ${LAST_NRADJNRCELL_DIST_NAME}

    ${list_of_absent_objects} = 	Create List    ${LAST_NRREL_DIST_NAME}

    ${list_of_present_objects_22R3} = 	Create List    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...                                                MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    ...                                                MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3
    ...                                                MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                                                MRBTS-1/NRBTS-1/NRADJNRCELL-2
    ...                                                MRBTS-1/NRBTS-1/NRADJNRCELL-3
    ...                                                ${LAST_NRADJNRCELL_DIST_NAME}

    ${list_of_absent_objects_22R3} = 	Create List    ${LAST_NRREL_DIST_NAME}
    ...                                                MRBTS-1/NRBTS-1/NRCELL-1/NRREL-4

    Run Keyword If     '${release}' == 'SBTS22R3'     Assert existence of objects in SCF   list_of_present_objects=${list_of_present_objects_22R3}
    ...                                                                                  list_of_absent_objects=${list_of_absent_objects_22R3}
    ...       ELSE    Assert existence of objects in SCF   list_of_present_objects=${list_of_present_objects}
    ...                                          list_of_absent_objects=${list_of_absent_objects}

    Wait for next periodic removal cycle and OAM update    ${baseline}

    ${list_of_present_objects} = 	Create List    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    ...                                            MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3
    ...                                            MRBTS-1/NRBTS-1/NRCELL-1/NRREL-4
    ...                                            MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                                            MRBTS-1/NRBTS-1/NRADJNRCELL-2
    ...                                            MRBTS-1/NRBTS-1/NRADJNRCELL-3

    ${list_of_absent_objects} = 	Create List    ${LAST_NRREL_DIST_NAME}
    ...                                            MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...                                            ${LAST_NRADJNRCELL_DIST_NAME}

    ${list_of_present_objects_22R3} = 	Create List    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    ...                                                MRBTS-1/NRBTS-1/NRCELL-1/NRREL-3
    ...                                                MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                                                MRBTS-1/NRBTS-1/NRADJNRCELL-2


    ${list_of_absent_objects_22R3} = 	Create List    ${LAST_NRREL_DIST_NAME}
    ...                                                MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...                                                MRBTS-1/NRBTS-1/NRCELL-1/NRREL-4
    ...                                                ${LAST_NRADJNRCELL_DIST_NAME}
    ...                                                MRBTS-1/NRBTS-1/NRADJNRCELL-3

    Run Keyword If     '${release}' == 'SBTS22R3'     Assert existence of objects in SCF   list_of_present_objects=${list_of_present_objects_22R3}
    ...                                                                                  list_of_absent_objects=${list_of_absent_objects_22R3}
    ...       ELSE    Assert existence of objects in SCF   list_of_present_objects=${list_of_present_objects}
    ...                                          list_of_absent_objects=${list_of_absent_objects}

    [Teardown]    Run Keywords    Teardown collecting logs and ensure there are none NRRELs
    ...                    AND    Delete object if it exists   dist_name=dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                    AND    Delete object if it exists   dist_name=dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-2
    ...                    AND    Delete object if it exists   dist_name=dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-3
    ...                    AND    Delete object if it exists   dist_name=${LAST_NRADJNRCELL_DIST_NAME}
    ...                    AND    Set idleTimeForNrNbRemoval    value=${MAX_IDLETIMEFORNRNBREMOVAL}
    ...                    AND    Run Keyword If Test Failed    Set actAutoNrNbRemoval    value=${True}


[1]5GC001085_C_005_ANR_disabled_-_check_removal_due_to_Handover_failures
    [Tags]     CRT_ASIL
    [Timeout]  2h
    [Setup]    Run Keywords    Prepare environment    wts_config_filename=${WTS_CONFIG_C_FILENAME}
    ...                                               sib1_reception_dict=${CELLS_3XSIM_2XREAL}
    ...                 AND    Set consecRecheckForNrNbRemoval    value=${1}
    ...                 AND    Start collecting logs

    Attach Ue and Establish Pdu Session
    Send A3 measurement report with PCI    pci=51    ho_type=intra    should_perform_ho=${True}
    Wait for OAM config update
    Assert existence of an object    dist_name=${LAST_NRREL_DIST_NAME}
    Deactivate feature flag

    Attach Ue and Establish Pdu Session    ue_id=2
    Trigger failure of next handover       ue_id=2
    Send A3 measurement report with PCI    ue_id=2    pci=51    ho_type=intra    should_perform_ho=${False}

    Attach Ue and Establish Pdu Session    ue_id=3
    Trigger failure of next handover       ue_id=3
    Send A3 measurement report with PCI    ue_id=3    pci=51    ho_type=intra    should_perform_ho=${False}

    Attach Ue and Establish Pdu Session    ue_id=4
    Trigger failure of next handover       ue_id=4
    Send A3 measurement report with PCI    ue_id=4    pci=51    ho_type=intra    should_perform_ho=${False}

    Wait for OAM config update
    Assert existence of an object    dist_name=${LAST_NRREL_DIST_NAME}

    [Teardown]    Run Keywords    Teardown collecting logs and ensure there are none NRRELs
    ...                    AND    Set consecRecheckForNrNbRemoval    value=${5}
    ...                    AND    Activate feature flag
