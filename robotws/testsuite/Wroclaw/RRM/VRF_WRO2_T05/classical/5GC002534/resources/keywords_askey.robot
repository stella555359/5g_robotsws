*** Settings ***
Documentation
...   author: Karolina Pawlik
...   contact: karolina.pawlik.ext@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/connections.robot
Library     Collections
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_2534.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources/keywords_for_logs.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.collectors.btslog  WITH NAME   btslog
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/ta_ue_custom_keywords.py   WITH NAME   tptp
Library     taf.ul.parser.pcap     WITH NAME    parser
Library     taf.transport.ssh      WITH NAME   csn
Library     taf.config.scf.scf_operations.SCFOperations  WITH NAME   scf_op
Library     taf.config.scf     WITH NAME  scf


*** Variables ***
${truput_pdsch_off}
${truput_pdsch_on}
${bts_id}
${resource_path}=       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002534/resources
${tput_DL_bandwith}     200Mbits/sec
${tput_UL_bandwith}     15MBits/sec
${tput_duration}        30s
${packet_size}          1024
${pdsch}                actPdschAtSsbSlots
${LOG_PATH}             ${OUTPUT DIR}
${SCF_15MHZ}            SCF_15MHZ.xml
${SCF_20MHZ}            SCF_20MHZ.xml
${SCF_basic}            SCF_basic.xml

*** Keywords ***


Reserve UEs Askey For tests
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE_NSA
    Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA
    log to console      Reserved UEs NSA and SA

Attach UE Askey NSA
    Wait until keyword succeeds    60s    5s    Attach Ue   UE_1
    log to console     Attach UE NSA successful.

Attach UE Askey SA
    Wait until keyword succeeds    60s    5s    Attach Ue   UE_2
    log to console     Attach UE SA successful.

Attach UE Askey NSA_SA
    Attach Ue   UE_3
    log to console      Attach UE NSA_SA successful.

Detach UE Askey NSA
    Detach Ue       UE_1
    log to console      Detach complete.

Detach UE Askey SA
    Detach Ue       UE_2
    log to console      Detach complete.

Detach UE Askey NSA_SA
    Detach Ue       UE_3
    log to console      Detach complete.


Return DL Throughput Whith Pdsch Off Askey NSA UDP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE Askey NSA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL NSA UDP      UE_1
    log to console      tput DLUL UDP completed
    ${tpt}      tptp.ue_print_avg_throughput             DT_DL_NSA
    Detach UE Askey NSA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    [Return]    ${tpt}


Return DL Throughput Whith Pdsch Off Askey NSA TCP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
      Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE Askey NSA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL NSA TCP      UE_1
    log to console      tput DLUL TCP completed
    ${tpt}      tptp.ue_print_avg_throughput             DT_DL_NSA
    Detach UE Askey NSA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE Askey NSA
    Sleep   5s
    [Return]    ${tpt}


Return DL Throughput Whith Pdsch Off Askey SA UDP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE Askey SA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL SA UDP        UE_2
    log to console      tput DLUL UDP completed
    ${tpt}      tptp.ue_print_avg_throughput             DT_DL_SA
    Detach UE Askey SA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    [Return]    ${tpt}


Return DL Throughput Whith Pdsch Off Askey SA TCP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE Askey SA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL SA TCP       UE_2
    log to console      tput DLUL TCP completed
    ${tpt}      tptp.ue_print_avg_throughput             DT_DL_SA
    Detach UE Askey SA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    [Return]    ${tpt}


Return DL Throughput With Pdsch Off Askey NSA SA UDP
    [Documentation]  Keyword switches off PDSCH feature, starts throughput, checks throughput and switches on PDSCH
    log to console      Return DL Throughput when PDSCH is OFF
    ${path}         keywords_2534.Generate Dist
    ${cell_dist}    keywords_2534.Generate Cell Dist
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=false
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    Attach UE Askey NSA
    Attach UE Askey SA
    Sleep   5s
    log to console      start DLUL tpt
    Start Throughput DLUL NSA SA UDP
    ${tpt_nsa}      tptp.ue_print_avg_throughput            DT_DL_NSA
    ${tpt_sa}     tptp.ue_print_avg_throughput            DT_DL_SA
    Detach UE NSA
    Detach UE SA
    FOR    ${cell}    IN   @{cell_dist}
       Perform Object Parameter Recommission       parameter=${pdsch}     value=true
                                                    ...   dist_name=${path}${cell}        timeout=300
    END
    Sleep   50s
    [Return]    ${tpt_nsa}      ${tpt_sa}


Check If Truput Is Higher With Pdsch On Askey NSA UDP
    Set test variable  ${test_filename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-B_31.pcap
    ${truput_pdsch_off}  Return DL Throughput Whith Pdsch Off Askey NSA UDP
    Attach UE Askey NSA
    Sleep   5s
    Start L1L2 Logs
    log to console      start tpt with pdsch on
    Start Throughput DLUL NSA UDP         UE_1
    Sleep  5s
    log to console      stop L1L2 logs
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on}  tptp.ue_print_avg_throughput     DT_DL_NSA
    Compare Truputs     ${truput_pdsch_on}      ${truput_pdsch_off}


Check If Truput Is Higher With Pdsch On Askey NSA TCP
    ${truput_pdsch_off}  Return DL Throughput Whith Pdsch Off Askey NSA TCP
    Start L1L2 Logs
    log to console      start tpt with pdsch on
    Start Throughput DLUL NSA TCP     UE_1
    Sleep  5s
    log to console      stop L1L2 logs
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on}  tptp.ue_print_avg_throughput     DT_DL_NSA
    Compare Truputs     ${truput_pdsch_on}      ${truput_pdsch_off}


Check If Truput Is Higher With Pdsch On Askey SA UDP
    Set test variable  ${test_filename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-B_38.pcap
    ${truput_pdsch_off}  Return DL Throughput Whith Pdsch Off Askey SA UDP
    Attach UE Askey SA
    Sleep   5s
    Start L1L2 Logs
    log to console      start tpt with pdsch on
    Start Throughput DLUL SA UDP    UE_2
    Sleep  5s
    log to console      stop L1L2 logs
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on}  tptp.ue_print_avg_throughput     DT_DL_SA
    Compare Truputs     ${truput_pdsch_on}      ${truput_pdsch_off}


Check If Truput Is Higher With Pdsch On Askey SA TCP
    Set test variable  ${test_ilename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-B_36.pcap
    ${truput_pdsch_off}  Return DL Throughput Whith Pdsch Off Askey SA TCP
    Attach UE Askey SA
    Sleep   5s
    log to console      start L1L2 logs
    Start L1L2 Logs
    Start Throughput DLUL SA TCP      UE_2
    Sleep  5s
    log to console      stop L1L2 logs
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on}  tptp.ue_print_avg_throughput     DT_DL_SA
    Compare Truputs     ${truput_pdsch_on}      ${truput_pdsch_off}


Check If Truput Is Higher With Pdsch On Askey NSA SA UDP
    Set test variable  ${test_filename}  ${OUTPUT DIR}/PCAPs/tcpdumpL2L1_filtering_on_2534-B_43.pcap
    ${truput_pdsch_off_nsa}      ${truput_pdsch_off_sa}      Return DL Throughput With Pdsch Off Askey NSA SA UDP
    Attach UE Askey NSA
    Attach UE Askey SA
    Sleep   5s
    log to console      start tpt with pdsch on
    Start L1L2 Logs
    Start Throughput DLUL NSA SA UDP
    Sleep  5s
    common_keywords.Stop L1L2 Logs And Download PCAP    dir=${test_filename}
    ${truput_pdsch_on_nsa}      tptp.ue_print_avg_throughput        DT_DL_NSA
    ${truput_pdsch_on_sa}       tptp.ue_print_avg_throughput        DT_DL_SA
    Compare Truputs             ${truput_pdsch_on_nsa}              ${truput_pdsch_off_nsa}
    Compare Truputs             ${truput_pdsch_on_sa}               ${truput_pdsch_off_sa}
