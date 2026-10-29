*** Settings ***
Documentation
...   author: Karolina Pawlik
...   contact: karolina.pawlik.ext@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/connections.robot
Library     Collections
Library     OperatingSystem
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.collectors.btslog  WITH NAME   btslog
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Library     taf.config.scf.scf_operations.SCFOperations  WITH NAME   scf_op
Library     taf.config.scf     WITH NAME  scf
Library     ute_ue
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.py
Library     taf.transport.ssh      WITH NAME   csn
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/ta_ue_custom_keywords.py   WITH NAME   tptp
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_kw.py
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Library     taf.converters.pcaptopdml    WITH NAME    pcaptopdml
Library     taf.ul.parser.pcap     WITH NAME    parser
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/coam_parameter.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/coam_gNB_operations.robot

*** Variables ***
${truput_pdsch_off}
${truput_pdsch_on}
${bts_id}
${resource_path_2534}=       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources
${tput_DL_bandwith}     200Mbits/sec
${tput_UL_bandwith}     15MBits/sec
${tput_duration}        30s
${packet_size}          1024
${pdsch}                actPdschAtSsbSlots
${LOG_PATH}             ${OUTPUT DIR}
${SCF_15MHZ}            SCF_15MHZ.xml
${SCF_20MHZ}            SCF_20MHZ.xml
${SCF_basic}            SCF_basic.xml
${mplane_lte_ipaddr}    ${tl.enbs[0].x2_link_addr.v4}

*** Keywords ***

Connecting To Coam
    [Arguments]  ${alias}=cOAM

    Log to console      Connect to cOAM.
    coam.Connect to    name=${alias}


Disconnecting from Coam
    [Arguments]  ${alias}=cOAM
    coam.Teardown     connection=${alias}


Provided precondition
    Setup system under test


Get SCF Before Test
    [Arguments]                     ${name}=${SCF_basic}    ${alias}=cOAM
    coam.Get current scf file       local_dir_path=${resource_path_2534}
    ...                             file_name=${name}
    ...                             connection=${alias}


Load SCF After Test
    ${result}           coam.perform_commissioning      scf_file=${resource_path_2534}/${SCF_basic}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=cOAM


# Reserve UEs MTK For tests
#     log to console      Reserver Ues MTK_NSA, MTK_SA_NSA  and MTK_SA
#     ute_ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE_NSA
#     ute_ue.Require Ue    UE_2     capabilities=REAL_ANDROID_UE_SA
#     ute_ue.Require Ue    UE_3       capabilities=REAL_ANDROID_UE_SA_NSA


Attach UE NSA
    log to console     Attach UE UE_1
    ute_ue.Attach Ue   UE_1


Attach UE SA
    log to console     Attach UE UE_2
    ute_ue.Attach Ue   UE_2

Attach UE NSA SA
    log to console     Attach UE UE_3
    ute_ue.Attach Ue   UE_3


Detach UE NSA
    log to console      Detach Ue UE_1
    ute_ue.Detach Ue    UE_1


Detach UE SA
    log to console      Detach Ue UE_2
    ute_ue.Detach Ue    UE_2


Detach UE NSA SA
    log to console      Detach Ue UE_3
    ute_ue.Detach Ue    UE_3


Verify Cells Availability
    log to console      Checking Cells Availability
    ${cells_status}     Get Cells Availability
    should be equal     ${cells_status}    Online


Compare Truput
    [Arguments]         ${tput_pdsch_on}     ${tput_pdsch_off}
    log to console      Compare Trughputs
    log to console      Troughput for PDSCH ON      ${tput_pdsch_on}
    log to console      Troughput for PDSCH OFF     ${tput_pdsch_off}
    ${result}=          Compare Truputs         ${tput_pdsch_on}        ${tput_pdsch_off}
    should be true      ${result}


Start Throughput DLUL NSA UDP       #NOTE: zrobic kiedys eksperymentalna wersja z aliasem DT_DL_NSA jako argumentem
    [Arguments]       ${used_ue}=UE_1
#    ${dt_alias}=DT_DL_NSA
    log to console          Started tput DLUL UDP
    Start Data Transfer     dt_name=DT_DL_NSA   ue_alias=${used_ue}      direction=dl    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    Start Data Transfer     dt_name=DT_UL_NSA   ue_alias=${used_ue}      direction=ul    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    Await Data Transfer Finish      dt_name=DT_DL_NSA       # example transfer name: DT_DL_NSA
    Await Data Transfer Finish      dt_name=DT_UL_NSA
    log to console      Data Transfer completed. Reset iperf.


Start Throughput DLUL SA UDP
    [Arguments]     ${used_ue}=UE_2
    log to console          Started tput DLUL SA UDP
    Start Data Transfer     dt_name=DT_DL_SA  ue_alias=${used_ue}      direction=dl    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    Start Data Transfer     dt_name=DT_UL_SA  ue_alias=${used_ue}      direction=ul    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    Await Data Transfer Finish      dt_name=DT_DL_SA
    Await Data Transfer Finish      dt_name=DT_UL_SA
    log to console      Data Transfer completed. Reset iperf.


Start Throughput DLUL NSA TCP
    [Arguments]          ${used_ue}=UE_1
    log to console      Started tput DLUL NSA TCP
    Start Data Transfer     dt_name=DT_DL_NSA   ue_alias=${used_ue}     direction=dl    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}          protocol=tcp    packet_size=${Packet_Size}
    Await Data Transfer Finish      dt_name=DT_DL_NSA
    Start Data Transfer     dt_name=DT_UL_NSA   ue_alias=${used_ue}     direction=ul    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}          protocol=tcp    packet_size=${Packet_Size}
    Await Data Transfer Finish      dt_name=DT_UL_NSA
    log to console      Data Transfer completed. Reset iperf.


Start Throughput DLUL SA TCP
    [Arguments]          ${used_ue}=UE_2
    log to console      Started tput DLUL SA TCP
    Start Data Transfer     dt_name=DT_DL_SA  ue_alias=${used_ue}      direction=dl    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}          protocol=tcp    packet_size=${Packet_Size}
    Start Data Transfer     dt_name=DT_UL_SA  ue_alias=${used_ue}       direction=ul    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}          protocol=tcp    packet_size=${Packet_Size}
    Await Data Transfer Finish      dt_name=DT_DL_SA
    Await Data Transfer Finish      dt_name=DT_UL_SA
    log to console      Data Transfer completed. Reset iperf.


Start Throughput DLUL NSA SA UDP
    log to console                  Started tput DLUL NSA SA UDP
    Start Data Transfer             dt_name=DT_DL_NSA   ue_alias=UE_1       direction=dl    duration=${tput_duration}
    ...                             throughput=${tput_DL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    Start Data Transfer             dt_name=DT_DL_SA   ue_alias=UE_2        direction=dl    duration=${tput_duration}
    ...                             throughput=${tput_DL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    Start Data Transfer             dt_name=DT_UL_NSA   ue_alias=UE_1       direction=ul    duration=${tput_duration}
    ...                             throughput=${tput_DL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    Start Data Transfer             dt_name=DT_UL_SA   ue_alias=UE_2        direction=ul    duration=${tput_duration}
    ...                             throughput=${tput_DL_bandwith}          protocol=udp    packet_size=${Packet_Size}
    Await Data Transfer Finish      dt_name=DT_DL_NSA
    Await Data Transfer Finish      dt_name=DT_DL_SA
    Await Data Transfer Finish      dt_name=DT_UL_NSA
    Await Data Transfer Finish      dt_name=DT_UL_SA
    log to console      Data Transfer completed. Reset iperf.


Start Throughput DLUL NSA NSA_SA TCP
    log to console          Started tput DLUL NSA NSA_SA TCP
    Start Data Transfer     dt_name=DT_DL_NSA   ue_alias=UE_1           direction=dl    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}              protocol=tcp    packet_size=${Packet_Size}
    Start Data Transfer     dt_name=DT_DL_NSA_SA   ue_alias=UE_3        direction=dl    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}              protocol=tcp    packet_size=${Packet_Size}
    Await Data Transfer Finish      dt_name=DT_DL_NSA       # example transfer name: DT_DL_NSA
    Await Data Transfer Finish      dt_name=DT_DL_NSA_SA
    Sleep   5s
    Start Data Transfer     dt_name=DT_UL_NSA   ue_alias=UE_1           direction=ul    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}              protocol=tcp    packet_size=${Packet_Size}
    Start Data Transfer     dt_name=DT_UL_NSA_SA   ue_alias=UE_3     direction=ul    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}              protocol=tcp    packet_size=${Packet_Size}
    Await Data Transfer Finish      dt_name=DT_UL_NSA
    Await Data Transfer Finish      dt_name=DT_UL_NSA_SA
    log to console      Data Transfer completed. Reset iperf.


Start Throughput DLUL SA SA_NSA UDP
    log to console          Started tput DLUL SA_NSA SA UDP
    Start Data Transfer     dt_name=DT_DL_SA   ue_alias=UE_2            direction=dl    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}              protocol=udp    packet_size=${Packet_Size}
    Start Data Transfer     dt_name=DT_DL_SA_NSA   ue_alias=UE_3        direction=dl    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}              protocol=udp    packet_size=${Packet_Size}
    Start Data Transfer     dt_name=DT_UL_SA   ue_alias=UE_2            direction=ul    duration=${tput_duration}
    ...                     throughput=${tput_DL_bandwith}              protocol=udp    packet_size=${Packet_Size}
    Start Data Transfer     dt_name=DT_UL_SA_NSA   ue_alias=UE_3        direction=ul    duration=${tput_duration}
    Await Data Transfer Finish      dt_name=DT_DL_SA       # example transfer name: DT_DL_NSA
    Await Data Transfer Finish      dt_name=DT_DL_SA_NSA
    Await Data Transfer Finish      dt_name=DT_UL_SA
    Await Data Transfer Finish      dt_name=DT_UL_SA_NSA
    log to console      Data Transfer completed. Reset iperf.


Return DL Throughput With Pdsch Off NSA NSA TCP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   30s
    Attach UE NSA
    Attach UE NSA SA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL NSA NSA_SA TCP
    ${tpt_nsa}          tptp.ue_print_avg_throughput            DT_DL_NSA
    ${tpt_nsa_sa}       tptp.ue_print_avg_throughput            DT_DL_NSA_SA
    Detach UE NSA
    Detach UE NSA SA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   100s
    [Return]    ${tpt_nsa}      ${tpt_nsa_sa}


Return DL Throughput With Pdsch Off SA SA UDP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF   #NOTE: wyciagnac to perform&PDSCH do osobnej funkcji
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE SA
    Attach UE NSA SA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL SA SA_NSA UDP
    ${tpt_sa}      tptp.ue_print_avg_throughput            DT_DL_SA
    ${tpt_nsa_sa}     tptp.ue_print_avg_throughput            DT_DL_SA_NSA
    Detach UE SA
    Detach UE NSA SA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   60s
    [Return]    ${tpt_sa}      ${tpt_nsa_sa}


Return DL Throughput With Pdsch Off NSA SA UDP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    keywords_2534.Delta commissioning 2534_AA CIT false
    Wait until keyword succeeds    5 min    1 min    Verify all cells are onair with admin
    Attach UE NSA
    Attach UE SA
    Sleep   5s
    Start Throughput DLUL NSA SA UDP
    ${tpt_nsa}      tptp.ue_print_avg_throughput            DT_DL_NSA
    ${tpt_sa}     tptp.ue_print_avg_throughput            DT_DL_SA
    Detach UE NSA
    Detach UE SA
    keywords_2534.Delta commissioning 2534_AA CIT true
    Wait until keyword succeeds    5 min    1 min    Verify all cells are onair with admin
    [Return]    ${tpt_nsa}      ${tpt_sa}


Return DL Throughput With Pdsch Off NSA TCP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE NSA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL NSA TCP
    ${tpt}      tptp.ue_print_avg_throughput             DT_DL_NSA
    Detach UE NSA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE NSA
    Sleep   5s
    [Return]    ${tpt}


Return DL Throughput With Pdsch Off NSA UDP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    log to console      start DLUL tpt
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE NSA
    Sleep   5s
    log to console      starttptp DLUL tpt
    Start Throughput DLUL NSA UDP
    ${tpt}      tptp.ue_print_avg_throughput             DT_DL_NSA
    Detach UE NSA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE NSA
    Sleep   5s
    [Return]    ${tpt}


Return DL Throughput With Pdsch Off SA TCP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
        Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE SA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL SA TCP
    ${tpt}      tptp.ue_print_avg_throughput             DT_DL_SA
    Detach UE SA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   150s
    Attach UE SA
    Sleep   5s
    [Return]    ${tpt}


Return DL Throughput With Pdsch Off SA UDP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE SA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL SA UDP
    ${tpt}      tptp.ue_print_avg_throughput             DT_DL_SA
    Detach UE SA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE SA
    Sleep   5s
    [Return]    ${tpt}


# Start L1L2 Logs Gathering
#   Start gnbMirroring   gnbMirroring_filtering=on   max_file_size_mbytes=50   capturing_time_seconds=40


# Stop L1L2 Logs Gathering And Download PCAP
#    [Arguments]    ${filename}=tcpdumpL2L1_filtering_on.pcap
#    Run    command=mkdir -p '${LOG_PATH}/PCAPs'
#    Stop gnbMirroring And Gather L1L2 logs    filename=${filename}


Get Cell Id To Which Ue Is Attached
    ${out}     keywords_2534.generated pcap data for subcellid
    ...        pcap_path=${test_filename}
    ${cellid}  get cell id from list  ${out}
    Sleep      10s
    Should contain any    ${cellid}    1  2  3
    [Return]    ${cellid}


Verify PM Counters
    log to console      Verify PM counters values
    Sleep  150s
    ${counters}                 Read Counters Value
    ${cell_id}                  Get Cell Id To Which Ue Is Attached
    ${SSB_SLOT_PDSCH}           Get Counter Value From Single Cell      ${counters}     ${cell_id}      M55308C00015
    ${SSB_SLOT_PDSCH_TIME}      Get Counter Value From Single Cell      ${counters}     ${cell_id}      M55308C00016
    ${DATA_SLOT_PDSCH}          Get Counter Value From Single Cell      ${counters}     ${cell_id}      M55308C00005
    ${DATA_SLOT_PDSCH_TIME}     Get Counter Value From Single Cell      ${counters}     ${cell_id}      M55308C00008
    ${TRS_SLOT_PDSCH_TIME}      Get Counter Value From Single Cell      ${counters}     ${cell_id}      M55308C00018
    Should Be True      0<=${SSB_SLOT_PDSCH}
    Should Be True      ${SSB_SLOT_PDSCH}<=${DATA_SLOT_PDSCH}
    Should Be True      0<=${SSB_SLOT_PDSCH_TIME}
    Should Be True      ${SSB_SLOT_PDSCH_TIME}<=${DATA_SLOT_PDSCH_TIME}
    Should Be True      0<=${TRS_SLOT_PDSCH_TIME}


Check If Truput Is Higher With Pdsch On NSA NSA TCP
    Set test variable  ${test_filename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-A_11.pcap
    ${truput_pdsch_off_nsa}      ${truput_pdsch_off_sa_nsa}      Return DL Throughput With Pdsch Off NSA NSA TCP
    Attach UE NSA
    Attach UE NSA SA
    Sleep   5s
    log to console      start tpt with pdsch on
    Start L1L2 Logs
    Start Throughput DLUL NSA NSA_SA TCP
    Sleep  150s
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on_nsa}      tptp.ue_print_avg_throughput        DT_DL_NSA
    ${truput_pdsch_on_sa_nsa}   tptp.ue_print_avg_throughput        DT_DL_NSA_SA
    Compare Truputs             ${truput_pdsch_on_nsa}              ${truput_pdsch_off_nsa}
    Compare Truputs             ${truput_pdsch_on_sa_nsa}           ${truput_pdsch_off_sa_nsa}


Check If Truput Is Higher With Pdsch On SA SA UDP
    Set test variable  ${test_filename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-A_22.pcap'
    ${truput_pdsch_off_sa}      ${truput_pdsch_off_sa_nsa}      Return DL Throughput With Pdsch Off SA SA UDP
    Attach UE SA
    Attach UE NSA SA
    Sleep   5s
    log to console      start tpt with pdsch on
    Start L1L2 Logs
    Start Throughput DLUL SA SA_NSA UDP
    Sleep  15s
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on_sa}           tptp.ue_print_avg_throughput     DT_DL_SA
    ${truput_pdsch_on_sa_nsa}       tptp.ue_print_avg_throughput     DT_DL_SA_NSA
    Compare Truputs                 ${truput_pdsch_on_sa}            ${truput_pdsch_off_sa}
    Compare Truputs                 ${truput_pdsch_on_sa_nsa}        ${truput_pdsch_off_sa_nsa}

Check If Truput Is Higher With Pdsch On NSA SA UDP
    Set test variable  ${test_filename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-A_44.pcap
    ${truput_pdsch_off_nsa}      ${truput_pdsch_off_sa}      Return DL Throughput With Pdsch Off NSA SA UDP
    Attach UE NSA
    Attach UE SA
    Sleep   5s
    log to console      start tpt with pdsch on
    Start New L1L2 Logs
    Start Throughput DLUL NSA SA UDP
    Sleep  150s
    Stop New L1L2 Logs And Download PCAP
    ${truput_pdsch_on_nsa}      tptp.ue_print_avg_throughput        DT_DL_NSA
    ${truput_pdsch_on_sa}       tptp.ue_print_avg_throughput        DT_DL_SA
    Compare Truputs             ${truput_pdsch_on_nsa}              ${truput_pdsch_off_nsa}
    Compare Truputs             ${truput_pdsch_on_sa}               ${truput_pdsch_off_sa}


Check If Truput Is Higher With Pdsch On NSA TCP
    Set test variable  ${test_filename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-A_04.pcap
    ${truput_pdsch_off}  Return DL Throughput With Pdsch Off NSA TCP
    Start L1L2 Logs
    log to console      start tpt with pdsch on
    Start Throughput DLUL NSA TCP
    Sleep  15s
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on}  tptp.ue_print_avg_throughput     DT_DL_NSA
    Compare Truputs     ${truput_pdsch_on}      ${truput_pdsch_off}


Check If Truput Is Higher With Pdsch On NSA UDP
    Set test variable  ${test_filename}  PCAPs/tcpdumpL2L1_filtering_on_2534-A_06.pcap
    ${truput_pdsch_off}  Return DL Throughput With Pdsch Off NSA UDP
    Start L1L2 Logs
    log to console      start tpt with pdsch on
    Start Throughput DLUL NSA UDP
    Sleep  15s
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on}  tptp.ue_print_avg_throughput     DT_DL_NSA
    Compare Truputs     ${truput_pdsch_on}      ${truput_pdsch_off}


Check If Truput Is Higher With Pdsch On SA TCP
    Set test variable  ${test_filename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-A_16.pcap
    ${truput_pdsch_off}  Return DL Throughput With Pdsch Off SA TCP
    Start L1L2 Logs
    log to console      start tpt with pdsch on
    Start Throughput DLUL SA TCP
    Sleep  150s
    log to console      stop L1L2 logs
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on}  tptp.ue_print_avg_throughput     DT_DL_SA
    Compare Truputs     ${truput_pdsch_on}      ${truput_pdsch_off}


Check If Truput Is Higher With Pdsch On SA UDP
    Set test variable  ${test_filename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-A_18.pcap
    ${truput_pdsch_off}  Return DL Throughput With Pdsch Off SA UDP
    Start L1L2 Logs
    Start Throughput DLUL SA UDP
    Sleep  15s
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on}  tptp.ue_print_avg_throughput     DT_DL_SA
    Compare Truputs     ${truput_pdsch_on}      ${truput_pdsch_off}


Load SCF_15_MHZ_No_PRBBlanking
    log to console      Start commissioning
    ${result}           coam.perform_commissioning      scf_file=${resource_path_2534}/${SCF_15MHZ}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=cOAM
    log to console      Commissioning result=${result}
    Wait until keyword succeeds    20 min    30s    Verify all cells are onair with admin


Load SCF_20_MHZ_No_PRBBlanking
    log to console      Start commissioning
    ${result}           coam.perform_commissioning      scf_file=${resource_path_2534}/${SCF_20MHZ}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=cOAM
    log to console      Commissioning result=${result}
    Wait until keyword succeeds    20 min    30s    Verify all cells are onair with admin


Load scf for LTE
    [Arguments]         ${folder_name}  ${scf_lte_name}
    ${host_name}=       Get TL hostname
    ${stream_name}=     Get stream name
    log to console      Start commissioning LTE
    ${conn}=    Connect to admin    ip_address=${mplane_lte_ipaddr}
    Log    Commissioning ${mplane_lte_ipaddr} BTS with ${scf_lte_name}    console=True
    coam.perform_commissioning      scf_file=${resource_path_2534}/${folder_name}/${host_name}/${stream_name}/${scf_lte_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=${conn}
    log to console      Commissioning LTE complete
    [Teardown]    Disconnect from admin  ${conn}


Check X2 Status
    Wait until keyword succeeds    15 min    30s    X2-C is available
    log to console                 x2 link is available

Delta commissioning 2534_AA CIT false
    [Arguments]
    ...          ${cell_1_path}=MRBTS-51020/NRBTS-51020/NRCELL-1
    ...          ${cell_2_path}=MRBTS-51020/NRBTS-51020/NRCELL-2
    ${cASupportList}    Create list    none
    Initialise delta store
    Set suite variables
    IF  '${sw_release}'>'SBTS24R1'
    Run keywords
    ...    Add param to delta       ${cell_1_path}          actPdschAtSsbSlots                 value=false   AND
    ...    Add param to delta       ${cell_1_path}          actPdschRmCsirsForTracking             value=false   AND
    ...    Add param to delta       ${cell_2_path}          actPdschAtSsbSlots                 value=false   AND
    ...    Add param to delta       ${cell_2_path}          actPdschRmCsirsForTracking             value=false
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}
    ELSE
        Run keywords
    ...    Add param to delta       ${cell_1_path}          actPdschAtSsbSlots                 value=false   AND
    ...    Add param to delta       ${cell_1_path}          actPdschAllocAroundSsb            value=false   AND
    ...    Add param to delta       ${cell_2_path}          actPdschAtSsbSlots                 value=false   AND
    ...    Add param to delta       ${cell_2_path}          actPdschAllocAroundSsb             value=false
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}
    END
Delta commissioning 2534_AA CIT true
    [Arguments]
    ...          ${cell_1_path}=MRBTS-51020/NRBTS-51020/NRCELL-1
    ...          ${cell_2_path}=MRBTS-51020/NRBTS-51020/NRCELL-2
    ${cASupportList}    Create list    none
    Initialise delta store
    Set suite variables
    IF  '${sw_release}'>'SBTS24R1'
    Run keywords
    ...    Add param to delta       ${cell_1_path}          actPdschAtSsbSlots                 value=true   AND
    ...    Add param to delta       ${cell_1_path}          actPdschRmCsirsForTracking             value=true   AND
    ...    Add param to delta       ${cell_2_path}          actPdschAtSsbSlots                 value=true   AND
    ...    Add param to delta       ${cell_2_path}          actPdschRmCsirsForTracking             value=true
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}
    ELSE
        Run keywords
    ...    Add param to delta       ${cell_1_path}          actPdschAtSsbSlots                 value=true   AND
    ...    Add param to delta       ${cell_1_path}          actPdschAllocAroundSsb            value=true   AND
    ...    Add param to delta       ${cell_2_path}          actPdschAtSsbSlots                 value=true   AND
    ...    Add param to delta       ${cell_2_path}          actPdschAllocAroundSsb             value=true
    ${delta}                 Collect delta store
    AdminHelper.Recommission with delta from admin  ${delta}
    END

Set suite variables
    ${sw_release}    get stream name
    Set suite variable    ${sw_release}