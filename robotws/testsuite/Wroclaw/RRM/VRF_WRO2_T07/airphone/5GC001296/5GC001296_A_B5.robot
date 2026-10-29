*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    PY310
...           CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Michal Fluder, Adrian Wojtyna
...              :maintainer: marcin.plawny@nokia.com

Resource   5GC001296_Keywords.robot
Library    5GC001296_Keywords.py
Variables    ta5g_global_var

Suite Setup    Run Keywords    Start Default Logging     output_dirpath=${OUTPUT_DIR}/Suite_Setup_logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_1296_A_B5_2.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_1296_sansa_config.lua
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                               delta_scf_filename=delta_1296_A_B5_2.json

*** Test Cases ***
5GC001296_A_B5_2_Intra_Frequency_Intra_Du_Measurement_Report_Handling_Of_Known_PCI_With_Status_Recheck_Different_CGI
    [Documentation]    This test case verifies gNB behaviour when the selected PCI (for PCI resolution) has a status of
    ...                RE-CHECK, and the NRCGI reported by the UE is different from what was known previously.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach UE To Enb And Gnb  ue_id=2
    Ue Rrc Reconf Param    ue_id=2    if_contains=report_cgi    action=tester_filled_cgi_info    nr_cgi_info_plmn=311:489   nr_cgi_info_ci=49155
    Send Ue Measurement Nr    ue_id=2     meas_id=2    index=0    get_ue_meas_cfg=1     event=A5
    ...                       phycell_id=51    nrsrp_nr=125     srsrp_nr=17    nrs_result=125:125:0
    ...                       pass_regexp=UE\\d+: Could not find cell with gnb_id=0x3 and plmn=311:489 in the neighbour list
    Verify UeSim Sent Given NrCGI
    Verify Traces For Failed Handover
    Sleep  5s   reason=Problem with establishing x2ap link
    Attach Ue To Enb    ue_id=1    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=1    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages       packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}    number_of_messages=2
    Verify No Nrrel Object Is Created Nor Pci In Nradjnrcell Is Updated
    Send Ue Measurement Nr    ue_id=1    meas_id=2    index=0    get_ue_meas_cfg=1    event=A5
    ...                       phycell_id=51    nrsrp_nr=125    srsrp_nr=17    nrs_result=125:125:0
    ...                       pass_regexp=Proxy \\(eNB 2 cell 2\\) reported successful RA
    Verify Traces For Successful Handover
    Verify Measurement Report For Successful HO
    Verify NRREL Object Is Created

    [Teardown]    Run Keywords    Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${NRCGI_49155}=    00:00:0c:00:30
${NRCGI_16386}=    00:00:04:00:20
${PCI_51_IN_RECONFIGURATION_WITH_SYNC_ON_X2AP}=   ${RECONFIGURATION_WITH_SYNC} && nr-rrc.spCellConfigCommon_element && nr-rrc.physCellId==51
${RRC_RECONFIGURATION_COMPLETE_ON_X2AP}=          ${RRC_RECONFIGURATION_COMPLETE} && x2ap.MeNBtoSgNBContainer == 40
${MEASUREMENT_REPORT_FOR_SUCCESSSFUL_HO}=         ${RRC_MEASUREMENT_REPORT} && ${RRC_CELL_IDENTITY} == ${NRCGI_16386} && nr-rrc.physCellId==51

*** Keywords ***
Verify No Nrrel Object Is Created Nor Pci In Nradjnrcell Is Updated
    Dont Find Object In Time Interval    object_name=NRREL_A-256    time_min=0    time_max=${NRREL_OBJECT_CREATION_TIME}    moc=NRREL_A
    &{NRADJNRCELL}=    Get Managed Object    object_name=NRADJNRCELL_A-1    moc=NRADJNRCELL_A
    ${number_of_nrrel_objects}=    Get Number Of Defined Objects    moc=NRREL_A
    Should Be Equal    ${number_of_nrrel_objects}    ${0}     msg=NRREL object shouldn't be created
    Should Be Equal    ${NRADJNRCELL.physCellId}    ${150}    msg=physCellId in NRADJNRCELL object should not be updated

Verify NRREL Object Is Created
    Wait For Object To Exist    object_name=NRREL_A-256    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}
    &{NRREL}=    Get Managed Object    object_name=NRREL_A-256    moc=NRREL_A
    Verify Created NRREL Object    NRREL=&{NRREL}    mcc=311    mnc=489    mncLength=3    gNbId=1    gNbIdLength=22    lcrId=2

Verify Measurement Report For Successful HO
    &{NRBTS}=    Get Managed Object    object_name=NRBTS_A-1    moc=NRBTS_A
    @{mcc_mnc}=    Get Mcc And Mnc    packet_filter=${MEASUREMENT_REPORT_FOR_SUCCESSSFUL_HO}
    ...            alias=${DEFAULT_TCPDUMP_ALIAS}  pcap_file_path=${OUTPUT_DIR}/${TEST_NAME}/tshark/${DEFAULT_TCP_PCAP}
    Should Be Equal As Integers   ${NRBTS.mcc}    ${mcc_mnc}[0]
    Should Be Equal As Integers   ${NRBTS.mnc}    ${mcc_mnc}[1]

Verify UeSim Sent Given NrCGI
    Verify Tcpdump Log    packet_filter=${RRC_MEASUREMENT_REPORT} && ${RRC_CELL_IDENTITY} == ${NRCGI_49155}

Verify Traces For Failed Handover
     Verify Ngap Messages    packet_filter=${X2AP_SGNB_CHANGE_REQUIRED}
     Verify Ngap Messages    packet_filter=${X2AP_SGNB_CHANGE_CONFIRM}    number_of_messages=0

Verify Traces For Successful Handover
    Verify Ngap Messages    ${X2AP_SGNB_MODIFICATION_REQUIRED}    number_of_messages=2    relation_symbol= >=
    Verify Ngap Messages    ${X2AP_SGNB_MODIFICATION_CONFIRM}     number_of_messages=2    relation_symbol= >=
    Verify Ngap Messages    ${PCI_51_IN_RECONFIGURATION_WITH_SYNC_ON_X2AP}    number_of_messages=2    relation_symbol= >=
    Verify Ngap Messages    ${RRC_RECONFIGURATION_COMPLETE_ON_X2AP}    number_of_messages=2    relation_symbol= >=
