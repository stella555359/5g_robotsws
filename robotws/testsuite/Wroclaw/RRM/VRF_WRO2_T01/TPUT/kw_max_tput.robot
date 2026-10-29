*** Settings ***
Documentation
...  contact:       pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com, wiktor.jarosinski@nokia.com
...  description:   Keywords for MaxTput Tests.
Library         taf.ue
Library         taf.hw.rf_attenuator   WITH NAME   att
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/DeltaStore.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/AdminHelper.py
Library         taf.sw.reporting_portal
Library         taf.rfrl.common_resources.python.report_to_rep
Library         OperatingSystem

*** Variables ***

# 108 Mbps without bler and iperf match
${tput_dl_5Mhz}          95 Mbits/sec
# for 256qam 38 Mbits/sec
${tput_ul_5Mhz}          33 Mbits/sec  # UE doesn't support 256 qam ul
# normal 155 without bler and iperf match
${tput_dl_10MHz}         140 Mbits/sec
# for 256qam ${tput_ul_10MHz}         60 Mbits/sec
${tput_ul_10MHz}         55 Mbits/sec  # UE doesn't support 256 qam ul
${tput_dl_20MHz}         246 Mbits/sec
#for 256qam ${tput_ul_20MHz}  110 Mbits/sec  without bler and iperf match
${tput_ul_20MHz}         88 Mbits/sec  # UE doesn't support 256 qam ul

#To be added TCP

${max_tput_ue_alias}     UE
# tput_dl_15MHz_SPLIT 205
${tput_dl_15MHz_SPLIT}    238 Mbits/sec
# ${tput_ul_15MHz_SPLIT}    89 Mbits/sec without bler and iperf match
${tput_ul_15MHz_SPLIT}    67 Mbits/sec   # UE doesn't support 256 qam ul

${tput_dl_15MHz_SPLIT_with_bler}    205 Mbits/sec
${tput_ul_15MHz_SPLIT_with_bler}    67 Mbits/sec

${tput_dl_15MHz_SPLIT_udp}    238 Mbits/sec
# ${tput_ul_15MHz_SPLIT}    89 Mbits/sec without bler and iperf match
${tput_ul_15MHz_SPLIT_udp}    67 Mbits/sec  # UE doesn't suport 256 qam ul


#add current bler 0%
${tput_deviation}       10%

@{lines_AHLOA_1}        1   2    3    4
@{lines_AHLOA_2}        5   6    7    8
@{lines_AHLOA_3}        9   10   11   12
@{lines_AHFIB_1}        13  14
# it should be changed
@{lines_AHFIB_2}        15  16  17  18  19  20  21  22  23  24
${SCF_SPLIT_FILE_PATH}     commissionings/RRM/WRO_RRM9/maxTput/scf_REG_maxTpup_SPLIT.xml

*** Keywords ***
Set attenuation AhloaS1
    Set attenuation and check  lines=${lines_AHLOA_1}   value=0
    Set attenuation and check  lines=${lines_AHLOA_2}   value=90
    Set attenuation and check  lines=${lines_AHLOA_3}   value=90
    Set attenuation and check  lines=${lines_AHFIB_2}   value=0

Set attenuation AhloaS2
    Set attenuation and check  lines=${lines_AHLOA_1}   value=90
    Set attenuation and check  lines=${lines_AHLOA_2}   value=0
    Set attenuation and check  lines=${lines_AHLOA_3}   value=90
    Set attenuation and check  lines=${lines_AHFIB_2}   value=0


Set attenuation AhloaS3
    Set attenuation and check  lines=${lines_AHLOA_1}   value=90
    Set attenuation and check  lines=${lines_AHLOA_2}   value=90
    Set attenuation and check  lines=${lines_AHLOA_3}   value=0
    Set attenuation and check  lines=${lines_AHFIB_2}   value=0


# Soon in common KWs
Set BTS id as suite variable
    WebUI.create_session
    ${bts_id}=   WebUI.get_bts_info   attribute=id
    set suite variable                ${bts_id}
    [Teardown]  WebUI.teardown_session

# Soon in common KWs

Cells setup 5MHz 256QAM
    Cells setup with given parameters 5Mhz


Cells setup 10MHz 256QAM
    Cells setup with given parameters   bandwidth=10MHz


Cells setup 15MHz 256QAM
    Cells setup with given parameters   bandwidth=15MHz


Cells setup 20MHz 256QAM
    Cells setup with given parameters   bandwidth=20MHz

[1]Bi-Directional_Throughput_21B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw15MhzAr126900
    [Tags]    SPLIT
    Set attenuation AhloaS1
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    start max tput kpi logs
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_15MHz_SPLIT_udp}  tput_UL_bandwidth=${tput_ul_15MHz_SPLIT_udp}
    ...                 ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl
    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_15MHz_SPLIT_udp}    ${tput_deviation}    omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_15MHz_SPLIT_udp}    ${tput_deviation}    omit=25

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${OUTPUTDIR}/logs
    ...         tput_dl=${tput_dl_15MHz_SPLIT_udp}
    ...         tput_ul=${tput_ul_15MHz_SPLIT_udp}
    ...         protocol=tcp
    ...         deviation=${tput_deviation}

[1]Bi-Directional_Throughput_21B_noDss_Nsa_TputNsaSplitUDP_AhloaS2_DL4x2CL_UL2x2CL_Bw15MhzAr126900
    [Tags]    SPLIT
    Set attenuation AhloaS2
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    start max tput kpi logs
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_15MHz_SPLIT}  tput_UL_bandwidth=${tput_ul_15MHz_SPLIT}
    ...                 ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl
    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_15MHz_SPLIT}    ${tput_deviation}    omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_15MHz_SPLIT}    ${tput_deviation}    omit=25

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${OUTPUTDIR}/logs
    ...         tput_dl=${tput_dl_15MHz_SPLIT_with_bler}
    ...         tput_ul=${tput_ul_15MHz_SPLIT_with_bler}
    ...         protocol=tcp
    ...         deviation=${tput_deviation}

[1]Bi-Directional_Throughput_21B_noDss_Nsa_TputNsaSplitUDP_AhloaS3_DL4x2CL_UL2x2CL_Bw15MhzAr126900
    [Tags]    SPLIT
    Set attenuation AhloaS3
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    start max tput kpi logs
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_15MHz_SPLIT}  tput_UL_bandwidth=${tput_ul_15MHz_SPLIT}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl
    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_15MHz_SPLIT}    10%    omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_15MHz_SPLIT}    10%    omit=25

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${OUTPUTDIR}/logs
    ...         tput_dl=${tput_dl_15MHz_SPLIT}
    ...         tput_ul=${tput_ul_15MHz_SPLIT}
    ...         protocol=tcp
    ...         deviation=${tput_deviation}

[1]Bi-Directional_Throughput_21B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw15MhzAr126900
    [Tags]    SPLIT
    Set attenuation AhloaS1
    taf.ue.attach ue  ${max_tput_ue_alias}
    start max tput kpi logs
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_15MHz_SPLIT}  tput_UL_bandwidth=${tput_ul_15MHz_SPLIT}
    ...                 ue_alias=${max_tput_ue_alias}
    sleep    2m
    #stop max tput kpi logs
    stop uldl
    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_15MHz_SPLIT}    ${tput_deviation}    omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_15MHz_SPLIT}    ${tput_deviation}    omit=25

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${OUTPUTDIR}/logs
    ...         tput_dl=${tput_dl_15MHz_SPLIT}
    ...         tput_ul=${tput_ul_15MHz_SPLIT}
    ...         protocol=tcp
    ...         deviation=${tput_deviation}

[1]Bi-Directional_Throughput_21B_noDss_Nsa_TputNsaSplitTCP_AhloaS2_DL4x2CL_UL2x2CL_Bw15MhzAr126900
    [Tags]    SPLIT
    Set attenuation AhloaS2
    taf.ue.attach ue  ${max_tput_ue_alias}
    start max tput kpi logs
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_15MHz_SPLIT}  tput_UL_bandwidth=${tput_ul_15MHz_SPLIT}
    ...                 ue_alias=${max_tput_ue_alias}
    sleep    2m
    #stop max tput kpi logs
    stop uldl
    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_15MHz_SPLIT}    ${tput_deviation}    omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_15MHz_SPLIT}    ${tput_deviation}    omit=25

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${OUTPUTDIR}/logs
    ...         tput_dl=${tput_dl_15MHz}
    ...         tput_ul=${tput_ul_15MHz}
    ...         protocol=tcp
    ...         deviation=${tput_deviation}

[1]Bi-Directional_Throughput_21B_noDss_Nsa_TputNsaSplitTCP_AhloaS3_DL4x2CL_UL2x2CL_Bw15MhzAr126900
    [Tags]    SPLIT
    Set attenuation AhloaS3
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    start max tput kpi logs
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_15MHz_SPLIT}
    ...                 tput_UL_bandwidth=${tput_ul_15MHz_SPLIT}
    ...                 ue_alias=${max_tput_ue_alias}
    sleep    2m
    #stop max tput kpi logs

    stop uldl
    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_15MHz_SPLIT}    10%    omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_15MHz_SPLIT}    10%    omit=25

    [Teardown]  Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${OUTPUTDIR}/logs
    ...         tput_dl=${tput_dl_15MHz_SPLIT}
    ...         tput_ul=${tput_ul_15MHz_SPLIT}
    ...         protocol=tcp
    ...         deviation=${tput_deviation}


#switched for 836,998

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Tags]    SPLIT
    Cells setup 5MHz 256QAM
    Set attenuation AhloaS1
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_5Mhz}  tput_UL_bandwidth=${tput_ul_5Mhz}  ue_alias=${max_tput_ue_alias}
    sleep    2m

    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_5MHz}    ${tput_deviation}   omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_5MHz}    ${tput_deviation}   omit=25
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
  #  ...         tput_dl=    tput_ul=${tput_ul_5Mhz}  protocol=udp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS2_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Tags]    SPLIT
    Cells setup 5MHz 256QAM
    Set attenuation AhloaS2
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_5Mhz}  tput_UL_bandwidth=${tput_ul_5Mhz}  ue_alias=${max_tput_ue_alias}
    sleep    2m

    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_5MHz}    ${tput_deviation}   omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_5MHz}    ${tput_deviation}   omit=25
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
  #  ...         tput_dl=    tput_ul=${tput_ul_5Mhz}  protocol=udp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS3_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Tags]    SPLIT
    Cells setup 5MHz 256QAM
    Set attenuation AhloaS3
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_5Mhz}  tput_UL_bandwidth=${tput_ul_5Mhz}  ue_alias=${max_tput_ue_alias}
    sleep    2m

    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_5MHz}    ${tput_deviation}   omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_5MHz}    ${tput_deviation}   omit=25
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
  #  ...         tput_dl=    tput_ul=${tput_ul_5Mhz}  protocol=udp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Tags]    SPLIT
    Cells setup 5MHz 256QAM
    Set attenuation AhloaS1
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_5Mhz}  tput_UL_bandwidth=${tput_ul_5Mhz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl


#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=     tput_ul=${tput_ul_5Mhz}    protocol=tcp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS2_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Tags]    SPLIT
    Cells setup 5MHz 256QAM
    Set attenuation AhloaS2
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_5Mhz}  tput_UL_bandwidth=${tput_ul_5Mhz}
    ...                 ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=     tput_ul=${tput_ul_5Mhz}    protocol=tcp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS3_DL4x2CL_UL2x2CL_Bw5MhzAr126900
    [Tags]    SPLIT
    Cells setup 5MHz 256QAM
    Set attenuation AhloaS3
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_5Mhz}  tput_UL_bandwidth=${tput_ul_5Mhz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=     tput_ul=${tput_ul_5Mhz}    protocol=tcp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Tags]    SPLIT
    Cells setup 10MHz 256QAM
    Set attenuation AhloaS1
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_10MHz}  tput_UL_bandwidth=${tput_ul_10MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m

    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_10MHz}    ${tput_deviation}  omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_10MHz}    ${tput_deviation}  omit=25
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_10MHz}     tput_ul=${tput_ul_10MHz}  protocol=udp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS2_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Tags]    SPLIT
    Cells setup 10MHz 256QAM
    Set attenuation AhloaS2
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_10MHz}  tput_UL_bandwidth=${tput_ul_10MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m

    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_10MHz}    ${tput_deviation}  omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_10MHz}    ${tput_deviation}  omit=25
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal   logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_10MHz}     tput_ul=${tput_ul_10MHz}  protocol=udp  deviation=${tput_deviation

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS3_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Tags]    SPLIT
    Cells setup 10MHz 256QAM
    Set attenuation AhloaS3
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_10MHz}  tput_UL_bandwidth=${tput_ul_10MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m

    taf.ue.Verify Average Throughput With Deviation   DT_DL  ${tput_dl_10MHz}    ${tput_deviation}  omit=25
    taf.ue.Verify Average Throughput With Deviation   DT_UL  ${tput_ul_10MHz}    ${tput_deviation}  omit=25
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_10MHz}     tput_ul=${tput_ul_10MHz}  protocol=udp  deviation=${tput_deviation

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Tags]    SPLIT
    Cells setup 10MHz 256QAM
    Set attenuation AhloaS1
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_10MHz}  tput_UL_bandwidth=${tput_ul_10MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal   logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_10MHz}     tput_ul=${tput_ul_10MHz}  protocol=tcp  deviation=${tput_deviation

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS2_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Tags]    SPLIT
    Cells setup 10MHz 256QAM
    Set attenuation AhloaS2
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_10MHz}  tput_UL_bandwidth=${tput_ul_10MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_10MHz}     tput_ul=${tput_ul_10MHz}  protocol=tcp  deviation=${tput_deviation

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS3_DL4x2CL_UL2x2CL_Bw10MhzAr126900
    [Tags]    SPLIT
    Cells setup 10MHz 256QAM
    Set attenuation AhloaS3
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_10MHz}  tput_UL_bandwidth=${tput_ul_10MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_10MHz}     tput_ul=${tput_ul_10MHz}  protocol=tcp  deviation=${tput_deviation

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS1_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Tags]    SPLIT
    Cells setup 20MHz 256QAM
    Set attenuation AhloaS1
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_20MHz}  tput_UL_bandwidth=${tput_ul_20MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_20MHz}     tput_ul=${tput_ul_20MHz}  protocol=udp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS2_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Tags]    SPLIT
    Cells setup 20MHz 256QAM
    Set attenuation AhloaS2
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_20MHz}  tput_UL_bandwidth=${tput_ul_20MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_20MHz}     tput_ul=${tput_ul_20MHz}  protocol=udp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitUDP_AhloaS3_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Tags]    SPLIT
    Cells setup 20MHz 256QAM
    Set attenuation AhloaS3
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL UDP  tput_DL_bandwidth=${tput_dl_20MHz}  tput_UL_bandwidth=${tput_ul_20MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_20MHz}     tput_ul=${tput_ul_20MHz}  protocol=udp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS1_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Tags]    SPLIT
    Cells setup 20MHz 256QAM
    Set attenuation AhloaS1
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_20MHz}  tput_UL_bandwidth=${tput_ul_20MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_20MHz}     tput_ul=${tput_ul_20MHz}  protocol=tcp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS2_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Tags]    SPLIT
    Cells setup 20MHz 256QAM
    Set attenuation AhloaS2
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_20MHz}  tput_UL_bandwidth=${tput_ul_20MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_20MHz}     tput_ul=${tput_ul_20MHz}  protocol=tcp  deviation=${tput_deviation}

[1]Bi-Directional_Throughput_20B_noDss_Nsa_TputNsaSplitTCP_AhloaS3_DL4x2CL_UL2x2CL_Bw20MhzAr126900
    [Tags]    SPLIT
    Cells setup 20MHz 256QAM
    Set attenuation AhloaS3
    sleep  5s
    taf.ue.attach ue  ${max_tput_ue_alias}
    sleep  5s
    Start Max ULDL TCP  tput_DL_bandwidth=${tput_dl_20MHz}  tput_UL_bandwidth=${tput_ul_20MHz}  ue_alias=${max_tput_ue_alias}
    sleep    2m
    stop uldl

#    [Teardown]  Run Keyword    Report KPIs and Configuration to Reporting Portal    logs_dir=${OUTPUTDIR}/logs
#    ...         tput_dl=${tput_dl_20MHz}     tput_ul=${tput_ul_20MHz}  protocol=tcp  deviation=${tput_deviation}

Perform commisioning Max Tput
    [Arguments]
    ...                 ${ulDataPath}=ulOverNr
    ...                 ${dlDataSplitMode}=dlOverF1UX2U
    ...                 ${ulDataSplitThreshold}=infinity
    ...                 ${alias}=coam

    Log to console      __Perform commissioning with given parameters.
    &{nsaDrbParam}      Create dictionary       ulDataPath=${ulDataPath}
    ...                                         ulDataSplitThreshold=${ulDataSplitThreshold}
    ...                                         actPrioritizeX2AfterInactivity=false
    ...                                         dlDataSplitBufferBuildUpThreshold=5
    ...                                         dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
    ...                                         dlDataSplitGainThreshold=5
    ...                                         dlDataSplitMode=${dlDataSplitMode}
    ...                                         inactivityThresholdForPrioritizeX2=300
    ...                                         inactivityThresholdForRestartPrioritizeX2=100
    ...                                         initialDLTrafficRouting=initDLoverX2U
    ...                                         nsa3xBearerAllowed=true
    ...                                         prioritizeX2Period=500
    ...                                         actX2DuplicateTxNSA3x=false

    ${cell_ids}    Get cell ids
    Initialise delta store
    coam.Connect to         name=${alias}
    ${nrdrb_path}           Set variable    MRBTS-${bts_id}/NRBTS-${bts_id}/NRDRB-
    ${nrdrb_objects}        coam.Get managed objects    class_name=NRDRB_A   connection=${alias}
    FOR  ${nrdrb}  IN  @{nrdrb_objects}
        ${index}            Fetch from right  ${nrdrb['distName']}  -
        Add list parameters to delta  ${nrdrb_path}${index}          nsaDrbParam                     &{nsaDrbParam}
    END
    ${delta}            Collect delta store
    Recommission with delta from admin  ${delta}
