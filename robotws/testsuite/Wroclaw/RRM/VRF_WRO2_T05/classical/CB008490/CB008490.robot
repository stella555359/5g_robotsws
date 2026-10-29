*** Settings ***
Documentation
...                 author: Pawel Sniady
...                 contact: pawel.sniady@nokia.com

Library             DateTime
Library             ute_ue
Library             taf.sbts.oam.coam.admin    WITH NAME    oam
Library             resources/keywords.py
Library             resources/Positioner.py
Library             testsuite/Wroclaw/RRM/resources/scout_report.py
Resource            resources/keywords.robot
Resource            testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/tti/tti.robot


Suite Setup         Run Keywords
...                     Initialize RF Attenuator    AND
...                     oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
...                     oam.Perform Delta Recommissioning
...                     delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490.json    connection=MN    AND
...                     oam.Teardown Admin    connection=MN    AND
...                     oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
...                     oam.Perform Delta Recommissioning
...                     delta_file=${test_path}/resources/delta_scf/NIDD_SN_CB008490.json    connection=SN    AND
...                     oam.Teardown Admin    connection=SN    AND
...                     ute_ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE_1    AND
...                     ute_ue.Require Ue    UE_2    capabilities=REAL_ANDROID_UE_2    AND
...                     ute_ue.Require Ue    UE_3    capabilities=REAL_ANDROID_UE_3


Suite Teardown      Run Keywords
...                     Terminate RF Attenuator    AND
...                     oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
...                     oam.Perform Delta Recommissioning
...                     delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490_R.json    connection=MN    AND
...                     oam.Teardown Admin    connection=MN    AND
...                     oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
...                     oam.Perform Delta Recommissioning
...                     delta_file=${test_path}/resources/delta_scf/NIDD_SN_CB008490_R.json    connection=SN    AND
...                     oam.Teardown Admin    connection=SN


*** Variables ***
${traffic_duration}=        390s
${target_dl_tput}=          2000 Mbits/sec
${target_ul_tput}=          100 Mbits/sec
${tcp_rampup_time}=         30
${ue_inactivity_timer}=     65
${measurement_interval}=    ${5}
${test_path}=               /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008490
@{xn_messages}=
...                         SNodeAdditionRequest
...                         sn-terminated
...                         SNodeAdditionRequestAcknowledge
...                         dataforwardinginfoTarget
...                         XnUAddressIndication
...                         SNStatusTransfer
...                         pdcpStatusTransfer-UL
...                         pdcpStatusTransfer-DL
...                         SNodeReconfigurationComplete
...                         PDUSessionResourceModifyIndication
...                         PDUSessionResourceModifyConfirm


*** Test Cases ***
[1]CB008490-B#B3A1_Large_DL_data_transfer_in_NR-DC_-_TCP
    [Documentation]    This user scenario verifies downlink TCP data transfer in inter-gNB NR-DC.

    @{master_node_messages}=    Create List    InitialContextSetupRequest    IndexToRFSP    ueCapabilityEnquiry
    ...    "includeNR-DC": "true"    rrcReconfiguration    "freqBandIndicatorNR": 258    a4-Threshold    rsrp
    ...    gapUE    setup    rrcReconfigurationComplete    measurementReport    measResultNeighCells
    ...    "physCellId": 503    BearerContextModificationRequest    "pDCP-SN-Status-Request": "requested"
    ...    BearerContextModificationResponse    pDCP-SN-Status-Information    UEContextModificationRequest
    ...    "BearerTypeChange": "true"    UEContextModificationResponse    rrcReconfiguration    gapUE    release
    ...    masterCellGroup    "cellGroupId": 0    secondaryCellGroup    "cellGroupId": 1    "physCellId": 503
    ...    frequencyBandList    258    rrcReconfigurationComplete    BearerContextModificationRequest
    ...    cell-Group-To-Remove    "cell-Group-ID": 0    BearerContextModificationResponse

    @{mnCells}=    Create List    NRCELL_R-100
    @{snCells}=    Create List    NRCELL_R-503
    @{mn_logs}=    Create List    cp_5g    pmFiles
    @{sn_logs}=    Create List    pmFiles

    Set RF Attenuation    value=15
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    ute_ue.Attach UE    UE_1
    ute_ue.Start data transfer    dt_name=DT_DL_UE_1    ue_alias=UE_1
    ...    direction=dl    protocol=tcp    throughput=${target_dl_tput}    duration=65s
    ...    parallel_streams=4    max_segment_size=1350
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_1
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_1
    ...    tput_min=1750Mbits/sec    omit=5
    ute_ue.Detach UE    UE_1
    Wait Until Next PM Interval    ${measurement_interval}
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN
    ...    target_dir=_extracted
    ${json_file_path}=    Get From Dictionary    ${mn_log_files}    cp_5g
    Prepare Logs For Analysis    requested_logs=${sn_logs}    source_dir=SN    target_dir=_extracted
    Verify Message Sequence In Json    ${json_file_path}    ${master_node_messages}
    Verify Message Sequence In Json    ${json_file_path}    ${xn_messages}
    Verify M55156C00004 >=1 in BTS-50895.NRCELL-100 from ${TIMESTAMP}       # MAX_UE_NRDC_CAP
    Verify M55138C00038 SUM>45 in BTS-50895.NRCELL-100 from ${TIMESTAMP}   # SUM_UE_NRDC_CAP
    Verify M55156C00005 >=1 in BTS-50895.NRCELL-100 from ${TIMESTAMP}       # MAX_UE_NRDC_MN_CU
    Verify M55138C00039 SUM>45 in BTS-50895.NRCELL-100 from ${TIMESTAMP}   # SUM_UE_NRDC_MN_CU

    [Teardown]    Run Keywords
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data

[1]CB008490-D#B2_Inter-gNB_NR-DC_PSCell_Addition_upon_receiption_of_A4_MR_with_multiple_PSCell_candidate_cells_of_adjacent_gNB
    [Documentation]    Test scenario verifies the inter-gNB NR-DC PSCell addition procedure upon receipt of
    ...    A4 Measurement Report with multiple NR-DC PSCell candidate cells of one adjacent gNB from a UE.
    ...    The strongest cell is not selected as target PSCell due to RAC (maximum number of NR-DC Sn users reached)

    [Setup]    positioner.Initialize Positioner

    @{master_node_messages}=    Create List    measurementReport    measResultNeighCells    measResultListNR
    ...    "physCellId": 502    measResult    "physCellId": 503    measResult    rrcReconfiguration
    ...    mrdc-SecondaryCellGroup    nr-SCG    "physCellId": 503    rrcReconfigurationComplete
    ...    scg-Response    nr-SCG-Response    rrcReconfigurationComplete

    @{mnCells}=    Create List    NRCELL_R-100
    @{snCells}=    Create List    NRCELL_R-502    NRCELL_R-503
    @{mn_logs}=    Create List    cp_5g    pmFiles
    @{sn_logs}=    Create List    pmFiles

    Set Angle    0
    Set RF Attenuation    value=15
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    ute_ue.Attach UE    UE_1
    ute_ue.Start data transfer    dt_name=DT_UL_UE_1    ue_alias=UE_1
    ...    direction=ul    protocol=udp    packet_size=1350
    ...    throughput=${target_ul_tput}    duration=${traffic_duration}
    ute_ue.Start data transfer    dt_name=DT_DL_UE_1    ue_alias=UE_1
    ...    direction=dl    protocol=udp    packet_size=1350
    ...    throughput=${target_dl_tput}    duration=${traffic_duration}
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_1
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_1
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_UL_UE_1
    ...    tput_min=50Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_1
    ...    tput_min=500Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    ute_ue.Detach UE    UE_1
    Wait Until Next PM Interval    ${measurement_interval}
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN
    ...    target_dir=_extracted
    Prepare Logs For Analysis    requested_logs=${sn_logs}    source_dir=SN    target_dir=_extracted
    ${json_file_path}=    Get From Dictionary    ${mn_log_files}    cp_5g
    Verify Message Sequence In Json    ${json_file_path}    ${master_node_messages}
    Verify Message Sequence In Json    ${json_file_path}    ${xn_messages}
    Verify M55116C00037 >=1 in BTS-50895.NRCELL-100 from ${TIMESTAMP}   # NRDC_MN_A4_MEASUR_ACT
    Verify M55116C00038 >=1 in BTS-50895.NRCELL-100 from ${TIMESTAMP}   # IE_NRDC_MN_SNODE_ADD_REQ
    Verify M55116C00039 >=1 in BTS-55107.NRCELL-503 from ${TIMESTAMP}   # IE_NRDC_SN_SNODE_ADD_REQ
    Verify M55116C00047 >=1 in BTS-55107.NRCELL-503 from ${TIMESTAMP}   # IE_NRDC_SN_SNODE_ADD_ACK
    Verify M55116C00048 >=1 in BTS-50895.NRCELL-100 from ${TIMESTAMP}   # IE_NRDC_MN_SNODE_ADD_ACK
    Verify M55116C00049 >=1 in BTS-50895.NRCELL-100 from ${TIMESTAMP}   # IE_NRDC_MN_RRC_RECONF_ATT
    Verify M55116C00050 >=1 in BTS-50895.NRCELL-100 from ${TIMESTAMP}   # IE_NRDC_MN_SNODE_RECNF_COMP
    Verify M55116C00051 >=1 in BTS-55107.NRCELL-503 from ${TIMESTAMP}   # IE_NRDC_SN_SNODE_RECNF_COMP
    Verify M55116C00052 >=1 in BTS-50895.NRCELL-100 from ${TIMESTAMP}   # IE_NRDC_MN_SNODE_ADD_SUC
    Verify M55116C00053 >=1 in BTS-55107.NRCELL-503 from ${TIMESTAMP}   # IE_NRDC_SN_SNODE_ADD_SUC
    Verify M55138C00071 >=1 in BTS-55107.NRCELL-502 from ${TIMESTAMP}   # NRDC_SN_CU_AC_ATT
    Verify M55138C00044 >=1 in BTS-55107.NRCELL-502 from ${TIMESTAMP}   # NRDC_SN_CU_AC_REJ_USER_CELL

    [Teardown]    Run Keywords
    ...           positioner.Teardown Positioner    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data

[1]CB008490-DC#PM10_NR-DC_loadbalancing_in_case_1st_PSCell_candidate_is_non-optimal_and_2nd_PSCell_candidate_fails_RAC
    [Documentation]    Test scenario verifies correct counter update on Inter-gNB NR-DC configured BTS, in case when
    ...    the first PSCell candidate is non-optimal, and admission control check failed for the second PSCell
    ...    candidate and the third PSCell candidate passes all checks.

    [Setup]    Run Keywords
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN

    @{master_node_messages}=    Create List    measurementReport    measResultNeighCells    measResultListNR
    ...    "physCellId": 503    measResult    rrcReconfiguration    mrdc-SecondaryCellGroup    nr-SCG
    ...    "physCellId": 523    rrcReconfigurationComplete    scg-Response    nr-SCG-Response
    ...    rrcReconfigurationComplete

    @{mnCells}=    Create List    NRCELL_R-100
    @{snCells}=    Create List    NRCELL_R-503    NRCELL_R-513    NRCELL_R-523
    @{mn_logs}=    Create List    cp_5g    pmFiles
    @{sn_logs}=    Create List    pmFiles

    Set RF Attenuation    value=0
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    ute_ue.Attach UE    UE_1
    ute_ue.Start data transfer    dt_name=DT_UL_UE_1    ue_alias=UE_1
    ...    direction=ul    protocol=udp    packet_size=1350
    ...    throughput=50Mbits/sec    duration=${traffic_duration}
    ute_ue.Start data transfer    dt_name=DT_DL_UE_1    ue_alias=UE_1
    ...    direction=dl    protocol=udp    packet_size=1350
    ...    throughput=950Mbits/sec    duration=${traffic_duration}
    ute_ue.Attach UE    UE_2
    ute_ue.Start data transfer    dt_name=DT_UL_UE_2    ue_alias=UE_2
    ...    direction=ul    protocol=udp    packet_size=1350
    ...    throughput=50Mbits/sec    duration=${traffic_duration}
    ute_ue.Start data transfer    dt_name=DT_DL_UE_2    ue_alias=UE_2
    ...    direction=dl    protocol=udp    packet_size=1350
    ...    throughput=950Mbits/sec    duration=${traffic_duration}
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_1
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_1
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_2
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_2
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_UL_UE_1
    ...    tput_min=30Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_1
    ...    tput_min=500Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_UL_UE_2
    ...    tput_min=30Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_2
    ...    tput_min=500Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    ute_ue.Detach UE    UE_1
    ute_ue.Detach UE    UE_2
    Wait Until Next PM Interval    ${measurement_interval}
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN
    ...    target_dir=_extracted
    Prepare Logs For Analysis    requested_logs=${sn_logs}    source_dir=SN    target_dir=_extracted
    ${json_file_path}=    Get From Dictionary    ${mn_log_files}    cp_5g
    Verify Message Sequence In Json    ${json_file_path}    ${master_node_messages}
    Verify M55138C00071 >=2 in BTS-55107.NRCELL-503 from ${TIMESTAMP}   # NRDC_SN_CU_AC_ATT
    Verify M55138C00072 >=1 in BTS-55107.NRCELL-503 from ${TIMESTAMP}   # NRDC_SN_CU_AC_LB
    Verify M55138C00073 >=2 in BTS-55107.NRCELL-503 from ${TIMESTAMP}   # NRDC_SN_CU_AC_SUC
    Verify M55138C00071 >=1 in BTS-55107.NRCELL-513 from ${TIMESTAMP}   # NRDC_SN_CU_AC_ATT
    Verify M55138C00073 =0 in BTS-55107.NRCELL-513 from ${TIMESTAMP}    # NRDC_SN_CU_AC_SUC
    Verify M55138C00045 >=1 in BTS-55107.NRCELL-513 from ${TIMESTAMP}   # NRDC_SN_CU_AC_REJ_NGBR_CELL
    Verify M55138C00071 >=1 in BTS-55107.NRCELL-523 from ${TIMESTAMP}   # NRDC_SN_CU_AC_ATT
    Verify M55138C00073 >=1 in BTS-55107.NRCELL-523 from ${TIMESTAMP}   # NRDC_SN_CU_AC_SUC

    [Teardown]    Run Keywords
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
    ...           oam.Teardown Admin    connection=MN    AND
    ...           oam.Teardown Admin    connection=SN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data

[1]CB008490-N#B4A2_[T+F]_Deconfiguration_of_FR1_SCell(s)_and_configuration_of_FR2_SCell(s)_upon_NR-DC_Setup
    [Documentation]    This test scenario verifies that reception of Measurement Report for NR-DC A4 event
    ...    from a UE operating in FR1 CA will trigger a deconfiguration of FR1 SCells and
    ...    NR-DC setup with configuration of FR2 SCells afterward.

    [Setup]    Run Keywords
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
    ...        oam.Perform Delta Recommissioning
    ...        delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-N_B4A2.json    connection=MN    AND
    ...        oam.Perform Delta Recommissioning
    ...        delta_file=${test_path}/resources/delta_scf/NIDD_SN_CB008490-N_B4A2.json    connection=SN    AND
    ...        positioner.Initialize Positioner

    @{master_node_messages}=    Create List    measurementReport    rrcReconfiguration    sCellToAddModList
    ...    "sCellIndex": 1    uplinkConfig    "sequenceId": 101    rrcReconfigurationComplete    measurementReport
    ...    measResultNeighCells    measResultListNR    rrcReconfiguration    mrdc-SecondaryCellGroup    nr-SCG
    ...    sCellToAddModList    "sCellIndex": 8    rrcReconfigurationComplete    scg-Response    nr-SCG-Response
    ...    rrcReconfigurationComplete    rrcReconfiguration    mrdc-SecondaryCellGroupConfig    release
    ...    rrcReconfigurationComplete    measurementReport    rrcReconfiguration    sCellToAddModList    "sCellIndex": 1
    ...    uplinkConfig    "sequenceId": 101    rrcReconfigurationComplete

    @{mnCells}=    Create List    NRCELL-110
    @{snCells}=    Create List    NRCELL-503    NRCELL-513    NRCELL-523    NRCELL-533    NRCELL-543
    ...    NRCELL-553    NRCELL-563    NRCELL-573
    @{mn_logs}=    Create List    cp_5g    pmFiles
    @{sn_logs}=    Create List    pmFiles

    Set Angle    -30
    Set RF Attenuation    radio_module_id=0    value=35
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-N_B4A2_A4.json    connection=MN
    oam.Block Cell    MRBTS-50895/NRBTS-50895/NRCELL-101    connection=MN
    ute_ue.Attach UE    UE_2
    ute_ue.Start data transfer    dt_name=DT_UL_UE_1    ue_alias=UE_2
    ...    direction=ul    protocol=udp    packet_size=1350
    ...    throughput=200Mbits/sec    duration=${traffic_duration}
    ute_ue.Start data transfer    dt_name=DT_DL_UE_1    ue_alias=UE_2
    ...    direction=dl    protocol=udp    packet_size=1350
    ...    throughput=3500Mbits/sec    duration=${traffic_duration}
    oam.Unblock Cell    MRBTS-50895/NRBTS-50895/NRCELL-101    connection=MN
    Sleep    10s
    Set RF Attenuation    radio_module_id=0    value=10
    Set RF Attenuation    radio_module_id=1    value=0
    Sleep    15s
    Set Angle    30
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-N_B4A2_A4_R.json    connection=MN
    Sleep    15s
    Set Angle    -30
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-N_B4A2_A4.json    connection=MN
    Modify Qos Flow    310260560002769    test_3_drb    add6internet
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_1
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_1
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_UL_UE_1
    ...    tput_min=50Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_1
    ...    tput_min=900Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    ute_ue.Detach UE    UE_2
    Wait Until Next PM Interval    ${measurement_interval}
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN
    ...    target_dir=_extracted
    Prepare Logs For Analysis    requested_logs=${sn_logs}    source_dir=SN    target_dir=_extracted
    ${json_file_path}=    Get From Dictionary    ${mn_log_files}    cp_5g
    Verify Message Sequence In Json    ${json_file_path}    ${master_node_messages}
    Verify M55118C00042 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # DL_RRC_FSCELL_REL_ATT_SA
    Verify M55118C00043 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # DL_RRC_FSCELL_REL_SUC_SA
    Verify M55118C10503 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # DL_RRC_1SCELL_REL_ATT_SA
    Verify M55118C10504 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # DL_RRC_1SCELL_REL_SUC_SA
    Verify M55118C11095 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # UL_RRC_FSCELL_REL_ATT_SA
    Verify M55118C11096 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # UL_RRC_FSCELL_REL_SUC_SA
    Verify M55118C10505 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # UL_RRC_1SCELL_REL_ATT_SA
    Verify M55118C10506 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # UL_RRC_1SCELL_REL_SUC_SA
    Verify M55118C00083 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # DL_NRDC_STP_REL_SCELL_ATT_SA
    Verify M55118C00084 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # DL_NRDC_STP_REL_SCELL_SUC_SA
    Verify M55118C00085 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # UL_NRDC_STP_REL_SCELL_ATT_SA
    Verify M55118C00086 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # UL_NRDC_STP_REL_SCELL_SUC_SA
#    Verify M55316C03007 >0 in BTS-55107.NRCELL-503 from ${TIMESTAMP}   # PSCELL_UE_7_ACT_SCELL_DL
#    Verify M55316C04000 >0 in BTS-50895.NRCELL-110 from ${TIMESTAMP}   # PSCELL_UE_3_ACT_SCELL_UL

    [Teardown]    Run Keywords
    ...           Set RF Attenuation    radio_module_id=1    value=90    AND
    ...           oam.Perform Delta Recommissioning
    ...           delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-N_B4A2_R.json    connection=MN    AND
    ...           oam.Teardown Admin    connection=MN    AND
    ...           oam.Teardown Admin    connection=SN    AND
    ...           positioner.Teardown Positioner    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data

[1]CB008490-DB#B3_Sk-Counter_reset_after_Successful_transition_of_UE_in_RRC-INACTIVE_state_to_RRC-CONNECTED_state
    [Documentation]    This test scenario verifies the MN gNB behaviour for UE in RRC_INACTIVE state that is
    ...    successfully transitioned to RRC_CONNECTED state. After successful resume procedure MN gNB-CU-CP sets the
    ...    SN Counter to 0 when a new AS root key, KNG-RAN, in the associated 5G AS security context is established.

    [Setup]    Run Keywords
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN

    @{master_node_messages}=    Create List    rrcReconfiguration    mrdc-SecondaryCellGroup    nr-SCG
    ...    "integrityProtection": "enabled"    "sk-Counter": 2    rrcReconfigurationComplete
    ...    rrcRelease    rrcResumeRequest1    rrcResume    rrcResumeComplete
    ...    rrcReconfiguration    mrdc-SecondaryCellGroup    nr-SCG    "integrityProtection": "enabled"
    ...    "sk-Counter": 0    rrcReconfigurationComplete    scg-Response    nr-SCG-Response
    ...    rrcReconfigurationComplete

    @{mnCells}=    Create List    NRCELL-100
    @{snCells}=    Create List    NRCELL-500
    @{mn_logs}=    Create List    cp_5g    pmFiles
    @{sn_logs}=    Create List    pmFiles

    Set RF Attenuation    value=15
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ute_ue.Attach UE    UE_3
    ute_ue.Start data transfer    dt_name=DT_UL_UE_3    ue_alias=UE_3
    ...    direction=ul    protocol=tcp
    ...    throughput=${target_ul_tput}    duration=60s
    ...    parallel_streams=2    max_segment_size=1350
    ...    linux_congestion=cubic
    ute_ue.Start data transfer    dt_name=DT_DL_UE_3    ue_alias=UE_3
    ...    direction=dl    protocol=tcp
    ...    throughput=${target_dl_tput}    duration=60s
    ...    parallel_streams=4    max_segment_size=1350
    Modify Qos Flow    310260560002049    test_3_drb    add6internet
    Sleep    15s
    Modify Qos Flow    310260560002049    test_3_drb    rm6internet
    Sleep    15s
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-DB_B3.json    connection=MN
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_3
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_3
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_UL_UE_3
    ...    tput_min=35Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_3
    ...    tput_min=800Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    Modify Qos Flow    310260560002049    test_3_drb    add6internet
    Sleep    ${ue_inactivity_timer}
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-DB_B3_R.json    connection=MN
    ute_ue.Start data transfer    dt_name=DT_UL_UE_4    ue_alias=UE_3
    ...    direction=dl    protocol=tcp
    ...    throughput=${target_ul_tput}    duration=60s
    ...    parallel_streams=2    max_segment_size=1350
    ute_ue.Start data transfer    dt_name=DT_DL_UE_4    ue_alias=UE_3
    ...    direction=dl    protocol=tcp
    ...    throughput=${target_dl_tput}    duration=60s
    ...    parallel_streams=4    max_segment_size=1350
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_4
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_4
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_UL_UE_4
    ...    tput_min=35Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_4
    ...    tput_min=800Mbits/sec
    ...    omit=${tcp_rampup_time}    tput_collection_src=control_app
    ute_ue.Detach UE    UE_3
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN
    ...    target_dir=_extracted
    Prepare Logs For Analysis    requested_logs=${sn_logs}    source_dir=SN    target_dir=_extracted
    ${json_file_path}=    Get From Dictionary    ${mn_log_files}    cp_5g
    Verify Message Sequence In Json    ${json_file_path}    ${master_node_messages}

    [Teardown]    Run Keywords
    ...           oam.Teardown Admin    connection=MN    AND
    ...           oam.Teardown Admin    connection=SN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data


[1]CB008490-QNN#B3_S-Node_Addition_blocking_after_reception_of_Measurement_report_from_unauthorized_gNB
    [Documentation]    This test scenario verifies case where there are two neighbor gNBS - one authenticated
    ...    as Nokia-gNB (SN-gNB-1), second one not autheticated (SN-gNB-2). MN gNB will setup NR-DC A4 measurements
    ...    for a frequency of SNGNB cells. Cells of SN-gNB-1 and SN-gNB-2 are configured to the same frequency, so it is
    ...    possible that UE will send measurement report containing results from SN-gNB-2 cell. In such case,
    ...    the MN shall filter out such measurement report and not trigger NR-DC setup.

    [Setup]    Run Keywords
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
    ...        oam.Perform Delta Recommissioning
    ...        delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-QNN_B3.json    connection=MN    AND
    ...        oam.Perform Delta Recommissioning
    ...        delta_file=${test_path}/resources/delta_scf/NIDD_SN_CB008490-QNN_B3.json    connection=SN
    ...        skip_parameter_relation_errors=True

    @{mnCells}=    Create List    NRCELL_R-100
    @{snCells}=    Create List    NRCELL_R-503
    @{mn_logs}=    Create List    cp_5g    pmFiles    ipCapture
    @{sn_logs}=    Create List    pmFiles
    @{master_node_messages}=    Create List    measurementReport    measResultNeighCells    "physCellId": 503
    ${xn_setup_req_find_by}=    Create List    has:nokiaxnap.XnSetupRequest_element
    ${xn_setup_resp_find_by}=    Create List    has:nokiaxnap.XnSetupResponse_element
    ${snode_add_req_find_by}=    Create List    has:nokiaxnap.SNodeAdditionRequest_element
    ${xn_setup_auth_verify_by}=    Create List    has:nokiaxnap.nokiaXnChallenge_element
    ...    has:nokiaxnap.nokiaXnSelfAuth
    ${xn_setup_verify_by}=    Create List    not_has:nokiaxnap.nokiaXnChallenge_element
    ...    not_has:nokiaxnap.nokiaXnSelfAuth
    ${xn_setup_req_auth}=    Create Awaited Message
    ...    XnSetupRequest
    ...    ${xn_setup_req_find_by}
    ...    ${xn_setup_auth_verify_by}
    ${xn_setup_resp_auth}=    Create Awaited Message
    ...    XnSetupResponse
    ...    ${xn_setup_resp_find_by}
    ...    ${xn_setup_auth_verify_by}
    ${xn_setup_resp}=    Create Awaited Message    XnSetupResponse    ${xn_setup_resp_find_by}    ${xn_setup_verify_by}
    ${snode_add_req}=    Create Awaited Message    SNodeAdditionRequest    ${snode_add_req_find_by}
    ${awaited_messages_1}=    Create List    ${xn_setup_req_auth}    ${xn_setup_resp_auth}
    ${awaited_messages_2}=    Create List    ${xn_setup_req_auth}    ${xn_setup_resp}
    ${forbidden_messages}=    Create List    ${snode_add_req}

    Set RF Attenuation    value=15
    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-QNN_B3_R.json    connection=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ute_ue.Attach UE    UE_2
    ute_ue.Start data transfer    dt_name=DT_DL_UE_2    ue_alias=UE_2
    ...    direction=dl    protocol=tcp
    ...    throughput=${target_dl_tput}    duration=35s
    ...    parallel_streams=4    max_segment_size=1350    linux_congestion=cubic
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_2
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_2
    ...    tput_min=500Mbits/sec
    ...    omit=5    tput_collection_src=control_app
    ute_ue.Detach UE    UE_2
    Wait Until Next PM Interval    ${measurement_interval}
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN
    ...    target_dir=_extracted
    ${sn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${sn_logs}
    ...    source_dir=SN
    ...    target_dir=_extracted
    ${json_file_path}=    Get From Dictionary    ${mn_log_files}    cp_5g
    ${pcap_file_path}=    Get From Dictionary    ${mn_log_files}    ipCapture
    Verify Message Sequence In Json    ${json_file_path}    ${master_node_messages}
    Verify Message Sequence In Pcap    file_path=${pcap_file_path}
    ...    display_filter=nokiaxnap and !(ip.addr == ${tl.gnbs[1].cu.xnc.v4})
    ...    awaited_messages=${awaited_messages_1}
    Verify Message Sequence In Pcap    file_path=${pcap_file_path}
    ...    display_filter=nokiaxnap and ip.addr == ${tl.gnbs[1].cu.xnc.v4}
    ...    awaited_messages=${awaited_messages_2}
    ...    forbidden_messages=${forbidden_messages}
    Verify M55126C00035 SUM>=2 in BTS-50895.NRBTS-50895 from ${TIMESTAMP}   # XN_SETUP_REQUEST_SENT
    Verify M55126C00005 SUM>=2 in BTS-50895.NRBTS-50895 from ${TIMESTAMP}   # XN_SETUP_RESPONSE_RECEIVED
    Verify M55126C00003 SUM>=1 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # XN_SETUP_REQUEST_RECEIVED
    Verify M55126C00004 SUM>=1 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # XN_SETUP_RESPONSE_SENT

    [Teardown]    Run Keywords
    ...           oam.Perform Delta Recommissioning
    ...           delta_file=${test_path}/resources/delta_scf/NIDD_SN_CB008490-QNN_B3_R.json    connection=SN    AND
    ...           oam.Perform Delta Recommissioning
    ...           delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-QNN_B3.json    connection=MN    AND
    ...           oam.Perform Delta Recommissioning
    ...           delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-QNN_B3_R.json    connection=MN    AND
    ...           oam.Teardown Admin    connection=MN    AND
    ...           oam.Teardown Admin    connection=SN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data


[1]CB008490-DCA#B1_SN_Flow_Control_PM_counters_verification_for_NR-DC
    [Documentation]    This scenario aims to verify the F1 and XN flow control related PM counters at the
    ...    Master Node (MN) and Secondary Node (SN) for Inter-gNB NR-DC split bearer packets.
    [Setup]    Run Keywords
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
    ...        oam.Perform Delta Recommissioning
    ...        delta_file=${test_path}/resources/delta_scf/NIDD_SN_CB008490-DCA_B1.json    connection=SN

    @{mnCells}=    Create List    NRCELL_R-100
    @{snCells}=    Create List    NRCELL_R-503
    @{mn_logs}=    Create List    cp_5g    pmFiles    ipCapture
    @{sn_logs}=    Create List    pmFiles
    @{bandwidth_list}=    Create List    500Kbits/sec    5Mbits/sec    15Mbits/sec    35Mbits/sec    75Mbits/sec
    ...    300Mbits/sec    750Mbits/sec    1200Mbits/sec    2Gbits/sec

    Set RF Attenuation    value=15
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    ute_ue.Attach UE    UE_1
    ute_ue.Start data transfer    dt_name=DT_UL_UE_1    ue_alias=UE_1
    ...    direction=ul    protocol=udp    throughput=170Mbits/sec    duration=330s    packet_size=1350
    FOR    ${bandwidth}    IN    @{bandwidth_list}
        ute_ue.Start data transfer    dt_name=DT_DL_UE_1    ue_alias=UE_1
        ...    direction=dl    protocol=udp    throughput=${bandwidth}    duration=30s    packet_size=1350
        ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_1
    END
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_1
    Sleep    ${ue_inactivity_timer}
    ute_ue.Detach UE    UE_1
    Wait Until Next PM Interval    ${measurement_interval}
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN
    ...    target_dir=_extracted
    ${sn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${sn_logs}
    ...    source_dir=SN
    ...    target_dir=_extracted
    Verify M55362C00017 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # IE_NRDC_PSCELL_DL_VOL_F1_PMQP
    Verify M55333C00002 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # IE_NRDC_PSCELL_UL_VOL_XN_PMQP
    Verify M55362C00018 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # IE_NRDC_PSCELL_UL_VOL_F1_PMQP
    Verify M55333C00003 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # IE_NRDC_PSCELL_DL_PDU_XN_PMQP
    Verify M55362C00019 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # IE_NRDC_PSCELL_DL_PDU_F1_PMQP
    Verify M55333C00004 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # IE_NRDC_PSCELL_UL_PDU_XN_PMQP
    Verify M55362C00020 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # IE_NRDC_PSCELL_UL_PDU_F1_PMQP
    Verify M55378C00006 >0 in BTS-50895.NRBTS-50895 from ${TIMESTAMP}   # IE_NRDC_PCELL_DL_PDU_XN_PMQP
    Verify M55378C00007 >0 in BTS-50895.NRBTS-50895 from ${TIMESTAMP}   # IE_NRDC_PCELL_UL_PDU_XN_PMQP
    Verify M55334C00010 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # EST_XN_TPUT_BIN_01
    Verify M55334C00011 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # EST_XN_TPUT_BIN_02
    Verify M55334C00012 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # EST_XN_TPUT_BIN_03
    Verify M55334C00013 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # EST_XN_TPUT_BIN_04
    Verify M55334C00014 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # EST_XN_TPUT_BIN_05
    Verify M55334C00015 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # EST_XN_TPUT_BIN_06
    Verify M55334C00016 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # EST_XN_TPUT_BIN_07
    Verify M55334C00017 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # EST_XN_TPUT_BIN_08
    Verify M55334C00022 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # MEAS_PERIOD_NR_XN_CU_REPORT
    Verify M55334C00023 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # NUM_OF_XN_DDDS_RCVD
    Verify M55352C00009 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # NUM_OPPT_DL_DAT_SPT_F1_XN_PMQP
    Verify M55333C00016 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # UL_PDCP_PDU_XN_PMQAP
    Verify M55333C00013 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # DL_PDCP_SDU_VOL_UE_TPT_XN_PMQP
    Verify M55333C00014 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # DL_PDCP_PDU_VOL_UE_TPT_XN_PMQP
    Verify M55333C00015 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # DL_PDCP_PDU_TIM_UE_TPT_XN_PMQP
    Verify M55378C00004 >0 in BTS-50895.NRBTS-50895 from ${TIMESTAMP}   # IE_NRDC_PCELL_DL_VOL_XN_PMQP
    Verify M55378C00005 >0 in BTS-50895.NRBTS-50895 from ${TIMESTAMP}   # IE_NRDC_PCELL_UL_VOL_XN_PMQP
    Verify M55333C00013 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # DL_PDCP_SDU_VOL_UE_TPT_XN_PMQP
    Verify M55333C00014 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # DL_PDCP_PDU_VOL_UE_TPT_XN_PMQP
    Verify M55333C00015 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # DL_PDCP_PDU_TIM_UE_TPT_XN_PMQP

    [Teardown]    Run Keywords
    ...           oam.Perform Delta Recommissioning
    ...           delta_file=${test_path}/resources/delta_scf/NIDD_SN_CB008490-DCA_B1_R.json    connection=SN    AND
    ...           oam.Teardown Admin    connection=MN    AND
    ...           oam.Teardown Admin    connection=SN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data


[1]CB008490-Q#B7_Forced_NR-DC-SN_cell_switch_off_and_on_based_on_time_of_day
    [Documentation]    This scenario describes the deactivation of NR-DC-SN cells triggered by time of day
    ...                (interaction with CB012087)
    ...                The original scenario has been simplified in the following way:
    ...                - Limited to single UE (UE-1)
    ...                - No explicit checks for A4 NR-DC measurements configuration/deconfiguration
    ...                - No explicit checks for monitored message sequence during the OAM procedure
    ...                  of enabling/disabling energy saving on cells
    ...                - UE bulk release is expected rather than NR-DC bearer takeback due to PSCell RF signal strength

    [Setup]    Run Keywords
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN

    @{mnCells}=    Create List    NRCELL_R-100
    @{snCells}=    Create List    NRCELL_R-503
    @{mn_logs}=    Create List    cp_5g
    @{sn_logs}=    Create List    pmFiles
    @{cells}=    Create List    NRCELL-503    NRCELL-513    NRCELL-523

    @{master_node_messages}=    Create List    rrcReconfiguration    mrdc-SecondaryCellGroup    nr-SCG
    ...    "sk-Counter": 0    rrcReconfigurationComplete    rrcReestablishmentRequest    rrcSetup    rrcSetupComplete
    ...    rrcReconfiguration    mrdc-SecondaryCellGroup    nr-SCG    "sk-Counter": 0    rrcReconfigurationComplete
    ...    scg-Response    nr-SCG-Response    rrcReconfigurationComplete

    Set RF Attenuation    value=15
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    ute_ue.Attach UE    UE_1
    ute_ue.Start data transfer    dt_name=DT_DL_UE_1    ue_alias=UE_1
    ...    direction=dl    protocol=udp    throughput=3200Mbits/sec   duration=180s    packet_size=1350
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_SN_CB008490-Q_B7.json    connection=SN
    Sleep    75s    # shutdownWindow + 15s buffer
    FOR    ${cell}    IN    @{cells}
        ${cell_info}=    oam.Get Cell Specific Info    MRBTS-55107/NRBTS-55107/${cell}    connection=SN
        ${energy_saving_state}=    Set Variable    ${cell_info['energySavingState']}
        Should Be Equal As Strings    ${energy_saving_state}   energySaving
    END
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_SN_CB008490-Q_B7_R.json    connection=SN
    Sleep    15s
    FOR    ${cell}    IN    @{cells}
        ${cell_info}=    oam.Get Cell Specific Info    MRBTS-55107/NRBTS-55107/${cell}    connection=SN
        ${energy_saving_state}=    Set Variable    ${cell_info['energySavingState']}
        Should Be Equal As Strings    ${energy_saving_state}   notEnergySaving
    END
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_1
    ute_ue.Detach UE    UE_1
    Wait Until Next PM Interval    ${measurement_interval}
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN
    ...    target_dir=_extracted
    ${sn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${sn_logs}
    ...    source_dir=SN
    ...    target_dir=_extracted
    ${json_file_path}=    Get From Dictionary    ${mn_log_files}    cp_5g
    Verify Message Sequence In Json    ${json_file_path}    ${master_node_messages}
    Verify M55601C00506 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # SAMPLES_NR_CELL_POWER_SAV_T_D
    Verify M55601C00501 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # SAMPLES_NR_CELL_POWER_SAVING
    Verify M55601C01001 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # NR_CELL_PLAN_UNAVAIL_SAMPLES
    Verify M55601C00502 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # CHNG_TO_NR_CELL_POWER_SAVING
    Verify M55601C01002 >0 in BTS-55107.NRBTS-55107 from ${TIMESTAMP}   # NR_CELL_PLAN_UNAVAIL_CHNG_TO

    [Teardown]    Run Keywords
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
    ...           oam.Teardown Admin    connection=MN    AND
    ...           oam.Teardown Admin    connection=SN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data

[1]CB008490-W-1166#1_NR-DC_Call_Setup_time
    [Documentation]    This user scenario validates the NR-DC call setup time.

    [Setup]    Run Keywords
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-513    connection=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-523    connection=SN    AND
    ...        oam.Perform Delta Recommissioning
    ...            delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-W.json    connection=MN

    ${mnCells}=    Create List    NRCELL_R-100
    ${snCells}=    Create List    NRCELL_R-503

    Set RF Attenuation    value=15
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ${mn}    ${sn}=    Start PCAP collection on nodes
    ute_ue.Attach UE    UE_2
    ute_ue.Start data transfer    dt_name=DT_DL_UE_2    ue_alias=UE_2
    ...    direction=dl    protocol=tcp    throughput=${target_dl_tput}    duration=60s
    ...    parallel_streams=4    max_segment_size=1350
    ute_ue.Start data transfer    dt_name=DT_UL_UE_2    ue_alias=UE_2
    ...    direction=ul    protocol=tcp    throughput=${target_ul_tput}    duration=60s
    ...    parallel_streams=2    max_segment_size=1350
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-W_R.json    connection=MN
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_2
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_2
    ute_ue.Detach UE    UE_2
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    @{log_path}=    Generate And Download PCAP files from nodes    ${mn}    ${sn}
    Calculate NR-DC Call Setup Time    target=${62.0}    file_name=${log_path}[0]

    [Teardown]    Run Keywords
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-513    connection=SN    AND
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-523    connection=SN    AND
    ...           oam.Teardown Admin    connection=MN   AND
    ...           oam.Teardown Admin    connection=SN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data

[1]CB008490-W-1166#2_MN_initiated_NR-DC_bearer_takeback_time
    [Documentation]    This user scenario validates the Master Node initiated NR-DC bearer takeback time

    [Setup]    Run Keywords
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-513    connection=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-523    connection=SN

    ${mnCells}=    Create List    NRCELL_R-100
    ${snCells}=    Create List    NRCELL_R-503

    Set RF Attenuation    value=15
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ute_ue.Attach UE    UE_2
    ute_ue.Start data transfer    dt_name=DT_DL_UE_2    ue_alias=UE_2
    ...    direction=dl    protocol=tcp    throughput=${target_dl_tput}    duration=90s
    ...    parallel_streams=4    max_segment_size=1350
    ute_ue.Start data transfer    dt_name=DT_UL_UE_2    ue_alias=UE_2
    ...    direction=ul    protocol=tcp    throughput=${target_ul_tput}    duration=90s
    ...    parallel_streams=2    max_segment_size=1350
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-W.json    connection=MN
    ${mn}    ${sn}=    Start PCAP collection on nodes
    Sleep    10
    Modify Qos Flow    310260560002769    test_3_drb    add6internet
    Sleep    10
    @{log_path}=    Generate And Download PCAP files from nodes    ${mn}    ${sn}
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_2
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_2
    ute_ue.Detach UE    UE_2
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-W_R.json    connection=MN
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    Calculate MN Inititated NR-DC Bearer Takeback Time
    ...    target=${337.2}
    ...    mn_file_name=${log_path}[0]
    ...    sn_file_name=${log_path}[1]

    [Teardown]    Run Keywords
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-513    connection=SN    AND
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-523    connection=SN    AND
    ...           oam.Teardown Admin    connection=MN   AND
    ...           oam.Teardown Admin    connection=SN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data

[1]CB008490-W-1167#2_NR-DC_call_setup_data_interruption_time_when_initial_DL_traffic_is_configured_over_MCG
    [Documentation]    This user scenario validates the NR-DC call setup data interruption time when MCG is selected
    ...    for the initial downlink traffic routing.

    [Setup]    Run Keywords
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-513    connection=SN    AND
    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-523    connection=SN    AND
    ...        oam.Perform Delta Recommissioning
    ...            delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-W.json    connection=MN

    ${mnCells}=    Create List    NRCELL_R-100
    ${snCells}=    Create List    NRCELL_R-503

    Set RF Attenuation    value=15
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
    ute_ue.Attach UE    UE_2
    ute_ue.Start data transfer    dt_name=DT_DL_UE_2    ue_alias=UE_2
    ...    direction=dl    protocol=udp    throughput=${target_dl_tput}   duration=90s    packet_size=1350
    Start TTI trace streaming
    oam.Perform Delta Recommissioning
    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-W_R.json    connection=MN
    Sleep    16    # a4RetryTimer + a4SupervisionTimer
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_2
    ute_ue.Detach UE    UE_2
    Stop TTI trace
    Stop UTF Lab Tracing    alias=MN
    Stop UTF Lab Tracing    alias=SN
    Calculate NR-DC Data Interruption Time
    ...    target=${47}
    ...    lcId_before=${4}
    ...    lcId_after=${5}
    ...    minBytes=${1500}
    ...    file_path=${OUTPUT DIR}/TTI/${TEST NAME}.json

    [Teardown]    Run Keywords
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-513    connection=SN    AND
    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-523    connection=SN    AND
    ...           oam.Teardown Admin    connection=MN   AND
    ...           oam.Teardown Admin    connection=SN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data

#[1]CB008490-W-1167#3_MN_initiated_NR-DC_bearer_takeback_data_interruption_time
#    [Documentation]    This user scenario validates the Master Node initiated NR-DC bearer takeback
#    ...    data interruption time.
#
#    [Setup]    Run Keywords
#    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
#    ...        oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
#    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
#    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-513    connection=SN    AND
#    ...        oam.Block Cell    MRBTS-55107/NRBTS-55107/NRCELL-523    connection=SN
#
#    ${mnCells}=    Create List    NRCELL_R-100
#    ${snCells}=    Create List    NRCELL_R-503
#
#    Set RF Attenuation    value=15
#    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
#    Start UTF Lab Tracing    gnb_id=1    cells=${snCells}    alias=SN
#    ute_ue.Attach UE    UE_2
#    ute_ue.Start data transfer    dt_name=DT_DL_UE_2    ue_alias=UE_2
#    ...    direction=dl    protocol=tcp    throughput=${target_dl_tput}    duration=90s
#    ...    parallel_streams=4    max_segment_size=1350
#    ute_ue.Start data transfer    dt_name=DT_UL_UE_2    ue_alias=UE_2
#    ...    direction=ul    protocol=tcp    throughput=${target_ul_tput}    duration=90s
#    ...    parallel_streams=2    max_segment_size=1350
#    oam.Perform Delta Recommissioning
#    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-W.json    connection=MN
#    Start TTI trace streaming
#    Sleep    10
#    Modify Qos Flow    310260560002769    test_3_drb    add6internet
#    Sleep    10
#    Stop TTI trace
#    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_2
#    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_2
#    ute_ue.Detach UE    UE_2
#    oam.Perform Delta Recommissioning
#    ...    delta_file=${test_path}/resources/delta_scf/NIDD_MN_CB008490-W_R.json    connection=MN
#    Stop UTF Lab Tracing    alias=MN
#    Stop UTF Lab Tracing    alias=SN
#    Calculate NR-DC Data Interruption Time
#    ...    target=${49.5}
#    ...    lcId_before=${5}
#    ...    lcId_after=${6}
#    ...    minBytes=${0}
#    ...    file_path=${OUTPUT DIR}/TTI/${TEST NAME}.json

#
#    [Teardown]    Run Keywords
#    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-502    connection=SN    AND
#    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-513    connection=SN    AND
#    ...           oam.Unblock Cell    MRBTS-55107/NRBTS-55107/NRCELL-523    connection=SN    AND
#    ...           oam.Teardown Admin    connection=MN   AND
#    ...           oam.Teardown Admin    connection=SN    AND
#    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
#    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=SN    AND
#    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data
