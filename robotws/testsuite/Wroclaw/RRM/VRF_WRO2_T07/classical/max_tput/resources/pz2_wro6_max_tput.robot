*** Settings ***
Documentation
...   Max tput tests

Library         taf.ue  WITH NAME  taf_ue
Library         taf.hw.rf_attenuator   WITH NAME   att
Library         taf.sw.reporting_portal
Library         taf.rfrl.common_resources.python.report_to_rep
Library         OperatingSystem
Library         Telnet
Library         String
Library         Collections
Library         pz2_wro6_max_tput.py
Resource        taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${TPUT_DL_5MHZ}        95 Mbits/sec
${TPUT_UL_5MHZ}        18 Mbits/sec
${UE_ALIAS}            UE
${TPUT_DEVIATION}      10%
${TYPE_OF_TRANSFER}    SPLIT
&{TPUT_TEST}           udp=Start Max ULDL UDP  tcp=Start Max ULDL TCP

*** Keywords ***
[1]Bi_directional_noDss_Nsa_TputNsaSplitUDP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    Max tput test setup  used_cell_number=2  type_of_transfer=${TYPE_OF_TRANSFER}
    Perform Tput Test  udp


[1]Bi_directional_noDss_Nsa_TputNsaSplitTCP_AhcaS1_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    Max tput test setup  used_cell_number=1  type_of_transfer=${TYPE_OF_TRANSFER}
    Perform Tput Test  tcp


[1]Bi_directional_noDss_Nsa_TputNsaSplitTCP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    Max tput test setup  used_cell_number=2  type_of_transfer=${TYPE_OF_TRANSFER}
    Perform Tput Test  tcp


[1]Bi_directional_noDss_Nsa_TputNsaSplitTCP_AhcaS3_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    Max tput test setup  used_cell_number=3    type_of_transfer=${TYPE_OF_TRANSFER}
    Perform Tput Test  tcp


Perform Tput Test
    [Arguments]              ${protocol}=udp
    taf_ue.Attach Ue         ${UE_ALIAS}
    start max tput kpi logs
    Run Keyword              ${TPUT_TEST}[${protocol}]
    sleep    2m
    Stop ULDL
    taf_ue.Verify Average Throughput With Deviation   DT_DL  ${TPUT_DL_5MHZ}    ${TPUT_DEVIATION}    omit=25
    taf_ue.Verify Average Throughput With Deviation   DT_UL  ${TPUT_UL_5MHZ}    ${TPUT_DEVIATION}    omit=25
    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${OUTPUTDIR}/logs
    ...         tput_dl=${TPUT_DL_5MHZ}
    ...         tput_ul=${TPUT_UL_5MHZ}
    ...         protocol=${protocol}
    ...         deviation=${TPUT_DEVIATION}


Start Max ULDL UDP
    [Documentation]  Used Only by max tputu testing
    [Arguments]      ${protocol}=udp
    ...              ${ue_alias}=${UE_ALIAS}
    ...              ${tput_duration}=300s
    ...              ${tput_DL_bandwidth}=${TPUT_DL_5MHZ}
    ...              ${tput_UL_bandwidth}=${TPUT_UL_5MHZ}
    ...              ${packet_size}=1400
    taf_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                         throughput=${tput_DL_bandwidth}  protocol=${protocol}  packet_size=${packet_size}
    Sleep    10s
    taf_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_alias}  direction=ul  duration=${tput_duration}
    ...                         throughput=${tput_UL_bandwidth}  protocol=${protocol}  packet_size=${packet_size}
    Sleep    30s


Start Max ULDL TCP
    [Documentation]  Used Only by max tputu testing
    [Arguments]      ${protocol}=tcp
    ...              ${ue_alias}=${UE_ALIAS}
    ...              ${tput_duration}=300s
    ...              ${tput_DL_bandwidth}=${TPUT_DL_5MHZ}
    ...              ${tput_UL_bandwidth}=${TPUT_UL_5MHZ}
    ...              ${packet_size}=1400
    taf_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_alias}  direction=dl  duration=${tput_duration}
    ...                         throughput=${tput_DL_bandwidth}  protocol=${protocol}  packet_size=${packet_size}
    ...                         parallel_streams=2  buffer=3M  max_segment_size=1024
    Sleep    10s
    taf_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_alias}  direction=ul  duration=${tput_duration}
    ...                         throughput=${tput_UL_bandwidth}  protocol=${protocol}  packet_size=${packet_size}
    ...                         parallel_streams=2  buffer=2M  max_segment_size=1024
    Sleep    30s


Stop ULDL
    taf_ue.Stop Data Transfer  dt_name=DT_UL
    taf_ue.Stop Data Transfer  dt_name=DT_DL
