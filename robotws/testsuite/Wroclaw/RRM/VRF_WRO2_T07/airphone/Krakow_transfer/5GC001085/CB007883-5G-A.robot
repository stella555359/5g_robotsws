# Test transferred from Krakow, will be rewritten
*** Settings ***

Documentation
...   author: Justyna Gacek
...   contact: justyna.gacek@nokia.com
...   description: 5GC001085-D sub-feature:

Library    ute_fsmaccess
Library    ta5g_tshark
Library    ta5g_iphy
Library    ta5g_enb
Library    ute_wtssim
Library    ta5g_egate
Library    resources/suite_specific_keywords.py
Library    resources/egate_actions.py
Library    resources/syslog_validation.py
Library    resources/tcpdump_verify.py
Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   resources/keywords.robot

Force Tags      STATE_CONFIGURED    RAN_5G
...             CLOUD_5G_O_E_AP_LOO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD
...             CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup     Run Keywords    Set variables based on deployment and release in robot    feature=7883
...             AND    Perform recomissioning with delta   path_to_delta=${CURDIR}${/}resources${/}deltas${/}${DELTA_FILE}
...             AND    Perform recomissioning with delta
...                        path_to_delta=${CURDIR}${/}resources${/}deltas${/}${RELEASE}${/}DELTA_7883_SNSSAI_${UNIT_NAME}.json
...             AND    Configure VM interfaces for 7883
...             AND    Wait till admin is online

Test Setup     Prepare env and start collecting logs    wts_config_filename=${WTS_CONFIG_7883_FILENAME}
...                                                     sib1_reception_dict=${CELLS_1XSIM_1XREAL}
Test Teardown   Teardown collecting logs and ensure there are none NRRELs
Suite Teardown    Run Keyword And Ignore Error    Collect Admin Api Logs    subdir=${SUITE_NAME}
...                                                                         dir_name=admin_api_logs

Variables  resources/variables.py

*** Test Cases ***
[1]CB007883_5G_A_028_2287053_Ignore_Locked_AMF_-_trigger_SON_Configuration_Transfer_to_active_AMF
    [Tags]  CRT_ASIL
    [Timeout]  2h

    [Setup]     Run Keywords    Prepare SCF for customer AMF tests
    ...                  AND    Prepare environment    wts_config_filename=${WTS_CONFIG_7883_FILENAME}
    ...                                                sib1_reception_dict=${CELLS_1XSIM_1XREAL}
    ...                  AND    Start collecting logs

    Attach Ue and Establish Pdu Session    ue_id=1

    Send A3 Measurement Report With PCI     pci=49   nrsrp_nr=90    ho_type=inter   should_perform_ho=${True}

    Stop WTS and clear
    Delete XNLINK NRADJGNB and update SERVEDAMF1 and create SERVEDAMF2   amf1_administrative_state=Locked
    Reboot AP

    Reset units and wait for radio head online   ru_id=${0}   skip_reset=${True}

    Start wts and wait for ready state    wts_config_filename=${WTS_CONFIG_7883_FILENAME}
    ...                                   sib_reception_dict=${CELLS_1XSIM_1XREAL}    edaemon_port=${30000}    timeout=${720}

    Attach Ue and Establish Pdu Session    ue_id=1

    Send A3 Measurement Report With PCI     pci=49   nrsrp_nr=90    ho_type=inter   should_perform_ho=${False}

    ${list_of_present_objects} = 	Create List   ${FIRST_XNLINK_DIST_NAME}
    ...                                           ${FIRST_NRADJGNB_DIST_NAME}

    Assert existence of objects in SCF   list_of_present_objects=${list_of_present_objects}

    Assert values of NRADJGNB object  id_=${MIN_NRADJGNB_ID}     xnLinkRef=${MIN_XNLINK_ID}
    Assert values of XNLINK object  id_=${MIN_XNLINK_ID}

    [Teardown]    Run Keywords    Teardown collecting logs in robot
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-${MIN_NRADJGNB_ID}
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-${MIN_NRADJGNB_ID+1}
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/XNLINK-${MIN_XNLINK_ID}
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/SERVEDAMF-2
    ...                    AND    Update SERVEDAMF object   id_=1   amfIPAddress=10.0.1.1   administrativeState=Unlocked
    ...                    AND    Set actNgcFlexSaMode    value=${False}


[1]CB007883_5G_A_029_2287053_Ignore_Inactive_AMF_-_trigger_SON_Configuration_Transfer_to_active_AMF
    [Tags]  CRT_ASIL
    [Timeout]  2h

    [Setup]     Run Keywords    Prepare SCF for customer AMF tests
    ...                  AND    Prepare environment    wts_config_filename=${WTS_CONFIG_7883_FILENAME}
    ...                                                sib1_reception_dict=${CELLS_1XSIM_1XREAL}
    ...                  AND    Start collecting logs

    Attach Ue and Establish Pdu Session    ue_id=1

    Send A3 Measurement Report With PCI     pci=49   nrsrp_nr=90    ho_type=inter   should_perform_ho=${True}

    Stop WTS and clear
    Delete XNLINK NRADJGNB and update SERVEDAMF1 and create SERVEDAMF2   amf1_administrative_state=Unlocked
    Reboot AP

    Reset units and wait for radio head online   ru_id=${0}   skip_reset=${True}

    Start wts and wait for ready state    wts_config_filename=${WTS_CONFIG_7883_FILENAME}
    ...                                   sib_reception_dict=${CELLS_1XSIM_1XREAL}    edaemon_port=${30000}    timeout=${720}

    Attach Ue and Establish Pdu Session    ue_id=1

    Send A3 Measurement Report With PCI     pci=49   nrsrp_nr=90    ho_type=inter   should_perform_ho=${False}

    ${list_of_present_objects} = 	Create List   ${FIRST_XNLINK_DIST_NAME}
    ...                                           ${FIRST_NRADJGNB_DIST_NAME}

    Assert existence of objects in SCF   list_of_present_objects=${list_of_present_objects}

    Assert values of NRADJGNB object  id_=${MIN_NRADJGNB_ID}     xnLinkRef=${MIN_XNLINK_ID}
    Assert values of XNLINK object  id_=${MIN_XNLINK_ID}

    [Teardown]    Run Keywords    Teardown collecting logs in robot
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-1
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-${MIN_NRADJGNB_ID}
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-${MIN_NRADJGNB_ID+1}
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/XNLINK-${MIN_XNLINK_ID}
    ...                    AND    Delete object if it exists    dist_name=MRBTS-1/NRBTS-1/SERVEDAMF-2
    ...                    AND    Update SERVEDAMF object   id_=1   amfIPAddress=10.0.1.1   administrativeState=Unlocked
    ...                    AND    Set actNgcFlexSaMode    value=${False}
