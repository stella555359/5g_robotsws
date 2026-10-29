*** Settings ***
Documentation
...                 author: Pawel Sniady
...                 contact: pawel.sniady@nokia.com

Library             DateTime
Library             ute_ue
Library             taf.sbts.oam.coam.admin    WITH NAME    oam
Library             testsuite/Wroclaw/RRM/resources/scout_report.py
Library             testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008490/resources/keywords.py
Resource            testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008490/resources/keywords.robot


Suite Setup         Run Keywords
...                     Initialize RF Attenuator    AND
...                     oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
...                     oam.Block Rat    NR    connection=SN    AND
...                     oam.Teardown Admin    connection=SN


Suite Teardown      Run Keywords
...                     Terminate RF Attenuator    AND
...                     oam.Setup Admin    ${tl.gnbs[1].cu.backhaul_site_oam_ip.v4}    name=SN    AND
...                     oam.Unblock Rat    NR    connection=SN    AND
...                     oam.Teardown Admin    connection=SN


*** Variables ***
${traffic_duration}=        390s
${tcp_rampup_time}=         30
${ue_inactivity_timer}=     65
${measurement_interval}=    ${5}
${test_path}=               /home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717


*** Test Cases ***
[1]CB008717-5G-D#B2_UL_data_transfer_over_MCGSCG
    [Documentation]    The user scenario verifies DL and UL data split in the intra-gNB NR-DC configuration.

    [Setup]    Run Keywords
    ...        ute_ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE_1    AND
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Perform Delta Recommissioning
    ...        delta_file=${test_path}/resources/delta_scf/NIDD_CB008717.json    connection=MN
    ...        skip_parameter_relation_errors=True    AND
    ...        Sleep    10s    AND
    ...        Wait Until Keyword Succeeds    10 min    1 min    Assert BTS On Air Status   connection=MN    AND
    ...        Sleep    30s   # Temp W/A until Cell Status verification is not implemented

    @{message_sequence}=    Create List    InitialContextSetupRequest    IndexToRFSP
    ...    "includeNR-DC": "true"    rrcReconfiguration    "freqBandIndicatorNR": 260    a4-Threshold    rsrp
    ...    gapUE    setup    rrcReconfigurationComplete    measurementReport    measResultNeighCells
    ...    "physCellId": 300    SNodeAdditionRequest    mn-terminated    "uL-PDCP": "shared"
    ...    SNodeAdditionRequestAcknowledge    rrcReconfiguration    gapUE    release    masterCellGroup
    ...    "cellGroupId": 0    secondaryCellGroup    "cellGroupId": 1    "physCellId": 300    frequencyBandList    260
    ...    rrcReconfigurationComplete    SNodeReconfigurationComplete

    @{mnCells}=    Create List    NRCELL_R-100    NRCELL_R-300
    @{mn_logs}=    Create List    cp_5g    pmFiles

    Set RF Attenuation    value=15
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    ute_ue.Attach UE    UE_1
    ute_ue.Start data transfer    dt_name=DT_UL_UE_1    ue_alias=UE_1
    ...    direction=ul    protocol=tcp    throughput=240Mbits/sec    duration=65s
    ...    parallel_streams=2    max_segment_size=1350
    ute_ue.Await Data Transfer Finish    dt_name=DT_UL_UE_1
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_UL_UE_1
    ...    tput_min=200Mbits/sec
    ute_ue.Start data transfer    dt_name=DT_DL_UE_1    ue_alias=UE_1
    ...    direction=dl    protocol=tcp    throughput=2000Mbits/sec    duration=65s
    ...    parallel_streams=4    max_segment_size=1350
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_1
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_1
    ...    tput_min=1750Mbits/sec
    ute_ue.Detach UE    UE_1
    Wait Until Next PM Interval    ${measurement_interval}
    Stop UTF Lab Tracing    alias=MN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN
    ...    target_dir=_extracted
    ${json_file_path}=    Get From Dictionary    ${mn_log_files}    cp_5g
    Verify Message Sequence In Json    ${json_file_path}    ${message_sequence}
    Verify M55156C00004 >=1 in BTS-50895.NRCELL-100 from ${TIMESTAMP}       # MAX_UE_NRDC_CAP
    Verify M55138C00038 SUM>45 in BTS-50895.NRCELL-100 from ${TIMESTAMP}    # SUM_UE_NRDC_CAP
    Verify M55116C00016 >0 in BTS-50895.NRCELL-100 from ${TIMESTAMP}    	# NRDC_IA_MN_CU_ADD_REQ
    Verify M55116C00017 >0 in BTS-50895.NRCELL-100 from ${TIMESTAMP}    	# NRDC_IA_MN_CU_ADD_RESP
    Verify M55116C00020 >0 in BTS-50895.NRCELL-100 from ${TIMESTAMP}    	# NRDC_IA_MN_CU_ADD_RCF_CMPL
    Verify M55124C00020 >0 in BTS-50895.NRCELL-100 from ${TIMESTAMP}    	# IA_NRDC_MN_CU_DRB_STP_ATT
    Verify M55124C00021 >0 in BTS-50895.NRCELL-100 from ${TIMESTAMP}		# IA_NRDC_MN_CU_DRB_STP_SUC
    [Teardown]    Run Keywords
    ...           oam.Perform Delta Recommissioning
    ...           delta_file=${test_path}/resources/delta_scf/NIDD_CB008717_R.json    connection=MN    AND
    ...           Sleep    10s    AND
    ...           Wait Until Keyword Succeeds    10 min    1 min    Assert BTS On Air Status   connection=MN    AND
    ...           Sleep    30s    AND    # Temp W/A until Cell Status verification is not implemented
    ...           oam.Teardown Admin    connection=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data

[1]CB008717-5G-T#B1a_Verification_of_ENDC_preferred_path_selection_-_TCP_over_F1-U
    [Documentation]    This test case validates the handling of the DL Preferred path functionality in the ENDC.
    ...    In this case, F1-U is selected as the preferred path for TCP traffic.

    [Setup]    Run Keywords
    ...        ute_ue.Require Ue    UE_2    capabilities=REAL_ANDROID_UE_2    AND
    ...        oam.Setup Admin    ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}    name=MN    AND
    ...        oam.Perform Delta Recommissioning
    ...        delta_file=${test_path}/resources/delta_scf/NIDD_CB008717-T_B1a.json    connection=MN

    @{message_sequence}=    Create List    SgNBAdditionRequest    SgNBAdditionRequestAcknowledge    "physCellId": 300
    ...    SgNBReconfigurationComplete   SNStatusTransfer

    @{mnCells}=    Create List    NRCELL_R-300
    @{mn_logs}=    Create List    cp_5g    pmFiles
    @{bts_profile}=    Create List    pmFiles
    @{gnb_profile}=    Create List    condor5gSyslog    cp_5g

    Set RF Attenuation    radio_module_id=1    value=0
    Start UTF Lab Tracing
    ...    gnb_id=0    cells=${mnCells}
    ...    bts_custom_profile=${bts_profile}    gnb_custom_profile=${gnb_profile}
    ...    alias=MN_1
    Sleep    5s
    ${TIMESTAMP}=    Get Current Date    result_format=%Y%m%d.%H%M%S    time_zone=UTC
    ute_ue.Attach UE    UE_2
    ute_ue.Start data transfer    dt_name=DT_DL_UE_2    ue_alias=UE_2
    ...    direction=dl    protocol=tcp    throughput=5Mbits/sec    duration=60s
    ...    parallel_streams=1    max_segment_size=1350
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_2
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_2
    ...    tput_min=3Mbits/sec
    ute_ue.Detach UE    UE_2
    Wait Until Next PM Interval    ${measurement_interval}
    Stop UTF Lab Tracing    alias=MN_1
    Start UTF Lab Tracing    gnb_id=0    cells=${mnCells}    alias=MN
    ute_ue.Attach UE    UE_2
    ute_ue.Start data transfer    dt_name=DT_DL_UE_2    ue_alias=UE_2
    ...    direction=dl    protocol=tcp    throughput=600Mbits/sec    duration=60s
    ...    parallel_streams=1    max_segment_size=1350
    ute_ue.Await Data Transfer Finish    dt_name=DT_DL_UE_2
    Run Keyword and Continue On Failure
    ...    ute_ue.Verify Average Throughput    dt_name=DT_DL_UE_2
    ...    tput_min=300Mbits/sec
    ute_ue.Detach UE    UE_2
    Stop UTF Lab Tracing    alias=MN
    ${mn_log_files}=    Prepare Logs For Analysis
    ...    requested_logs=${mn_logs}
    ...    source_dir=MN_1
    ...    target_dir=_extracted
    ${json_file_path}=    Get From Dictionary    ${mn_log_files}    cp_5g
    Verify Message Sequence In Json    ${json_file_path}    ${message_sequence}
    Verify M55350C00043 SUM>20000 in BTS-50895.NRCELL-300 from ${TIMESTAMP}       # NSA_DL_VOL_SNT_CU_F1
    Verify M55350C00045 SUM<8000 in BTS-50895.NRCELL-300 from ${TIMESTAMP}        # NSA_DL_VOL_SNT_CU_X2

    [Teardown]    Run Keywords
    ...           Set RF Attenuation    radio_module_id=1    value=90    AND
    ...           oam.Perform Delta Recommissioning
    ...           delta_file=${test_path}/resources/delta_scf/NIDD_CB008717-T_B1a_R.json    connection=MN    AND
    ...           oam.Teardown Admin    connection=MN    AND
    ...           Run Keyword And Ignore Error    Teardown UTF Lab Collector    alias=MN    AND
    ...           Run Keyword And Ignore Error    Add Scout Scf Id To Test Data
