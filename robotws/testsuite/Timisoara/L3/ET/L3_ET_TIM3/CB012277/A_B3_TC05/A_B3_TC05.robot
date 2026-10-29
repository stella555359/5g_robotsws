*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           CONFIGURED    CIT    RAN_5G_FDD    RAN_5G    PY39
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Andrei Maria
...              :contact: andrei.maria@nokia.com

Resource    ../CB012277_keywords_and_variables.robot

Suite Setup    Run Keywords    Start Default Logging
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/../initial_scfc.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_A_B3_TC05.lua
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_A_B3_TC05.json
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/SCF_after_suite_setup_delta.xml
...            AND             Setup X2 Link    initiator_device=1    complementary_device=3
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_scfc.xml

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Get Scfc File   output_filepath=${OUTPUT_DIR}/SCF_after_test_end.xml
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
TC05_CB012277_A_B3_Intra_Frequency_inter_en_gNB_PSCell_change_with_CGI_provisioning_with_ANR_for_NSA_Opt_3x

    [Documentation]    This user scenario describes the cgi-Info provisioning in the successful NW based Intra-Frequency inter en-gNB PSCell
    ...    change preparation and execution of a NSA call from a source en-gNB to a target en-gNB when Intra-NR Intra-Frequency
    ...    UE based ANR for EN-DC is enabled. It shares all info from 5GC001296-B#B1(5G_RAN_USR_RRM_3244), only newly
    ...    additional info from this feature will be described in detail.

    Attach UE To Enb And Gnb    ue_id=1    target_cell=1
    Send Throughput     ue_id=1
    Send Custom Ue Measurement Nr    id=1    meas_id=2    index=0    nrs_result=125:125:0    event=A5    phycell_id=150
    ...                       nrsrq_nr=125    srsrq_nr=17
    Verify Created NRADJNRCELL And NRREL Objects
    Verify Successful Inter Gnb Pscell Change
    Verify Tcpdump Log    packet_filter=${CGI_INFO_PCI_150}    number_of_messages=1     relation_symbol= >=
