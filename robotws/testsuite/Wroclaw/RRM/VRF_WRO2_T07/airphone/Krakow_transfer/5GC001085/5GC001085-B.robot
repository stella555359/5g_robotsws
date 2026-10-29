# Test transferred from Krakow, will be rewritten
*** Settings ***

Documentation
...   author: Mateusz Plinta
...   contact: mateusz.plinta@nokia.com
...   description: 5GC001085-B sub-feature: Intra Frequency Inter-gNB neighbor NRREL addition
...                Previously established Xn (Include Error Handling)

Library    Collections
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
Library    resources/tcpdump_verify.py
Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   resources/keywords.robot

Force Tags      STATE_CONFIGURED    RAN_5G    PY36
...             CLOUD_5G_O_E_AP_LOO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
...             CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE


Suite Setup     Run keywords    Set variables based on deployment and release in robot    feature=1085-B
...                      AND    Delete XNLINK If Unit Is ASOE
...                      AND    Perform recomissioning with delta    path_to_delta=${CURDIR}${/}resources${/}deltas${/}${DELTA_FILE}

Test Setup      Prepare env and start collecting logs    wts_config_filename=${WTS_CONFIG_B_FILENAME}
...                                                      sib1_reception_dict=${CELLS_1XSIM_1XREAL}
Test Teardown   Teardown collecting logs and ensure there are none NRRELs
Suite Teardown   Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                        dir_name=admin_api_logs

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

[1]5GC001085_B_017_Unsupported_PLMN_received_in_cgi-info
    [Tags]     CRT_ASIL
    [Timeout]  2h
    [Setup]    Run Keywords    Add IP addr on VM    ip_addr=10.0.2.20/24    interface=eth4
    ...                 AND    Add IP addr on VM    ip_addr=10.0.3.1/24    interface=eth3
    ...                 AND    Change NRADJGNB parameters   change_plmn=${True}
    ...                 AND    Delete object if it exists   dist_name=MRBTS-1/NRBTS-1/NRPLMN-2    timeout=${480}
    ...                 AND    Prepare environment    wts_config_filename=${WTS_CONFIG_B_FILENAME_TC11_TC17}
    ...                                               sib1_reception_dict=${CELLS_1XSIM_1XREAL}
    ...                                               xnlink_check=${True}
    ...                 AND    Start collecting logs

    Attach Ue and Establish Pdu Session

    Send A3 measurement report with PCI    pci=49    nrsrp_nr=90    should_perform_ho=${False}
    Verify syslog PCI identified
    Verify XnAP HandoverRequestAcknowledge packet nonexistence

    Wait for OAM config update

    Assert absence of an object    dist_name=${LAST_NRADJNRCELL_DIST_NAME}
    Assert absence of an object    dist_name=${LAST_NRREL_DIST_NAME}

    [Teardown]    Run Keywords    Teardown collecting logs in robot
    ...                    AND    Delete object if it exists    dist_name=${LAST_NRREL_DIST_NAME}
    ...                    AND    Delete object if it exists    dist_name=${LAST_NRADJNRCELL_DIST_NAME}
    ...                    AND    Delete IP addr on VM    ip_addr=10.0.2.20/24    interface=eth4
    ...                    AND    Delete IP addr on VM    ip_addr=10.0.3.1/24    interface=eth3
    ...                    AND    Set default values for NRADJGNB parameters
    ...                    AND    Create NRPLMN object    id_=2


[1]5GC001085_B_026_Duplicated_PCIs_on_Target_gNB
    [Tags]     CRT_ASIL
    [Timeout]  2h
    [Setup]    Run Keywords    Configure vm interfaces for additional ransim cells
    ...                 AND    Prepare environment    wts_config_filename=${WTS_CONFIG_B_FILENAME_TC26}
    ...                                               sib1_reception_dict=${CELLS_3XSIM_2XREAL}
    ...                                               xnlink_check=${True}
    ...                 AND    Adjust parameters for 1085 B TC026
    ...                 AND    Start collecting logs

    Attach Ue and Establish Pdu Session
    Send A3 measurement report with PCI    pci=401    nrsrp_nr=90    ho_type=inter    should_perform_ho=${True}


    Verify syslog ANR PCI resolution success for PCI    pci=401
    Verify syslog PCI duplicate detection
    Verify inter gNB HO
    Verify NRCGI HO request

    Wait for OAM config update
    Assert values in NRREL and NRADJNRCELL  nrrel_id=256  nradjnrcell_id=12288  gNbId=2  gNbIdLength=25
    ...                                     lcrId=1  cellDepType=SA  physCellId=401
    ...                                     mcc=311  mnc=489  mncLength=3  ssbFrequency=636576


    [Teardown]    Run Keywords    Teardown collecting logs in robot
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-2
    ...                    AND    Delete object if it exists    dist_name=${LAST_NRREL_DIST_NAME}
    ...                    AND    Delete object if it exists    dist_name=${LAST_NRADJNRCELL_DIST_NAME}


[1]5GC001085_B_027_Check_potential_excessive_ADJ_NRPLMNSET_MOCs_removal
    [Tags]     CRT_ASIL
    [Timeout]  2h
    [Setup]    Run Keywords    Prepare environment    wts_config_filename=${WTS_CONFIG_B_FILENAME}
    ...                                               sib1_reception_dict=${CELLS_1XSIM_1XREAL}
    ...                                               xnlink_check=${True}
    ...                 AND    Set cellDepMode    value=SA+NSA
    ...                 AND    Perform recomissioning with delta
    ...                            path_to_delta=${CURDIR}${/}resources${/}deltas${/}${RELEASE}${/}DELTA_1085-B_RCA.json
    ...                 AND    Start collecting logs

    ${nrFirstPlmnDNList} =    Create List    MRBTS-1/NRBTS-1/NRPLMN-1
    ${nrSecondPlmnDNList} =    Create List    MRBTS-1/NRBTS-1/NRPLMN-2

    Attach Ue and Establish Pdu Session
    Trigger sending MR with CGI info with 2 PLMN entries on identityInfoList
    Send A3 measurement report with PCI    pci=49    ho_type=inter    should_perform_ho=${True}

    Verify syslog ANR PCI resolution success for PCI    pci=49
    Verify syslog PCI identified
    Verify syslog HO succeeded

    Wait for OAM config update
    Assert values in NRREL and NRADJNRCELL    gNbId=2    gNbIdLength=25    lcrId=1    physCellId=49     cellDepType=${CELL_DEP_TYPE_BOTH}
    Assert values of ADJ_NRPLMNSET_SA object    adj_nr_plmn_set_id=1    nrPlmnDNList=${nrFirstPlmnDNList}   fiveGsTac=0
    Assert values of ADJ_NRPLMNSET_SA object    adj_nr_plmn_set_id=2    nrPlmnDNList=${nrSecondPlmnDNList}  fiveGsTac=1
    Assert values of ADJ_NRPLMNSET_NSA object    nrPlmnDNList=${nrFirstPlmnDNList}

    [Teardown]    Run Keywords    Teardown collecting logs in robot
    ...                    AND    Delete object if it exists    dist_name=${LAST_NRREL_DIST_NAME}
    ...                    AND    Delete object if it exists    dist_name=${LAST_NRADJNRCELL_DIST_NAME}
    ...                    AND    Set cellDepMode    value=SA
