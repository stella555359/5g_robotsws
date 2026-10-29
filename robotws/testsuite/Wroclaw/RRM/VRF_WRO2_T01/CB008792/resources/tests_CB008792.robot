# robocop: disable=not-allowed-char-in-name
*** Settings ***
Documentation
...  author:        Maciej Cupial, Mateusz Cieciura
...  contact:       maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  maintainer:    maciej.cupial@nokia.com, mateusz.cieciura@nokia.com
...  feature lead:  Katarzyna Meinhardt (katarzyna.meinhardt@nokia.com)
...  description:   CB008792

Library         taf.ue
Library         BuiltIn
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB008792/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot

*** Variables ***
@{lines_cell1_5G}          1    2    3    4
@{lines_cell2_5G}          5    6    7    8
@{lines_cell3_5G}          9    10   11   12
@{SA_CALL_1}               SA_CALL_1
@{SA_CALL_2}               SA_CALL_2
@{SA_CALL_3}               SA_CALL_3
@{UE_SA}                   UE_SA
${SA_CAPA}                 CONDUCTED_UE_SA
${NSA_CAPA}                CONDUCTED_UE_NSA
${DL_DURATION_ACDW}        300s
${UL_DURATION_ACDW}        165s
${DURATION}                120s
${UL_DURATION_1}           60s
${UL_DURATION_2}           120s
${UL_DURATION_B1}          60s
${UL_DURATION_B2}          180s
${UL_THROUGHPUT}           300 Mbits/sec
${DL_THROUGHPUT}           2000 Mbits/sec
${UL_THROUGHPUT_1}         300 Mbits/sec
${UL_THROUGHPUT_2}         100 kbits/sec
@{UL_THRESHOLDS}           ${209}   ${203}
@{DL_THRESHOLDS}           ${1522}  ${1357}
@{DL_THRESHOLDS_ACDW}      ${1522}  ${1357}  ${1357}
@{UL_THRESHOLDS_SA_ACDW}   ${209}   ${203}   ${188}
@{UL_THRESHOLDS_NSA_ACDW}  ${104}   ${101}   ${94}
${MARGIN}                  ${0.85}

*** Keywords ***
[1]CB008792-5G-A_1_Activation_and_Deactivation_for_PUSCH_two_additional_DMRS_SA
    [Tags]       8792    sa    trunk
    [Documentation]
    ...  This user scenario describes the common gNB behaviour at activation and deactivation
    ...  for PUSCH two additional DMRS SA mode
    Set ulDMRSAdditionalPosition    ulDMRS=Two additional DMRS  dlDMRS=Two additional DMRS  actHighSpeedCell=true
    Get UEs               ${SA_CALL_1}  ${SA_CAPA}
    Detach UEs from cell  ${SA_CALL_1}
    Start tcpdump on gnb ASIK master
    sleep  5s
    Attach UEs to cell    ${SA_CALL_1}
    Start UL for UEs      ${SA_CALL_1}  ${UL_DURATION_1}  ${UL_THROUGHPUT}  udp
    sleep  10s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
    Verify cplane logs for two dmrs  pcap_file_path=${pcap_path}
    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_1}
    Stop using UEs        ${SA_CALL_1}
    Delete pyro_server UEPC
    Set ulDMRSAdditionalPosition    ulDMRS=One additional DMRS  dlDMRS=One additional DMRS  actHighSpeedCell=false
    Get UEs               ${SA_CALL_2}  ${SA_CAPA}
    Detach UEs from cell  ${SA_CALL_2}
    Start tcpdump on gnb ASIK master
    sleep  5s
    Attach UEs to cell    ${SA_CALL_2}
    Start UL for UEs      ${SA_CALL_2}  ${UL_DURATION_1}  ${UL_THROUGHPUT}  udp
    sleep  10s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
    Verify cplane logs for one dmrs  pcap_file_path=${pcap_path}
    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_2}
    Stop using UEs        ${SA_CALL_2}

[1]CB008792-5G-A_4-PUSCH_two_additional_DMRS_for_normal_cell_SA_PUSCH_mapping_type_A_pos2_FDM_ON_PUSCH_256QAM_0kmh
    [Tags]    8792  sa
    [Documentation]
    ...  This test verifies the user's throughput under different propagation conditions with both one additional DMRS
    ...  and two additional DMRS for normal cell
#    Get 5G QXDM and QCAT licenses   ${UE_ALIAS}
    Set ulDMRSAdditionalPosition    ulDMRS=One additional DMRS  dlDMRS=One additional DMRS  actHighSpeedCell=false
    Get UEs               ${SA_CALL_1}  ${SA_CAPA}
    Start syslog capture
    Attach UEs to cell    ${SA_CALL_1}
    Start UL for UEs      ${SA_CALL_1}  ${UL_DURATION_1}  ${UL_THROUGHPUT}  udp
#    ${dl}  ${ul}    QXDM tput check SA
    sleep  ${UL_DURATION_1}
    Stop syslog capture
    ${dl}  ${ul}    Get max DLUL from syslog
    Should be true  int(${ul}) > ${MARGIN}*${UL_THRESHOLDS[0]}  msg=Tput is too small
#    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_1}
    Stop using UEs        ${SA_CALL_1}
    Delete pyro_server UEPC
    Set ulDMRSAdditionalPosition    ulDMRS=Two additional DMRS  dlDMRS=Two additional DMRS  actHighSpeedCell=true
    Get UEs               ${SA_CALL_2}  ${SA_CAPA}
    Start syslog capture
    Attach UEs to cell    ${SA_CALL_2}
    Start UL for UEs      ${SA_CALL_2}  ${UL_DURATION_1}  ${UL_THROUGHPUT}  udp
#    ${dl}  ${ul}    QXDM tput check SA
    sleep  ${UL_DURATION_1}
    Stop syslog capture
    ${dl}  ${ul}    Get max DLUL from syslog
    Log to console      dl:${dl}
    Should be true  int(${ul}) > ${MARGIN}*${UL_THRESHOLDS[1]}  msg=Tput is too small
#    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_2}
    Stop using UEs        ${SA_CALL_2}

[1]CB008792-5G-C_15_Activation_and_Deactivation_for_PDSCH_two_additional_DMRS_SA
    [Tags]       8792    sa
    [Documentation]
    ...  This user scenario describes the common gNB behaviour at activation and deactivation
    ...  for PUSCH two additional DMRS SA mode
    Set ulDMRSAdditionalPosition    ulDMRS=Two additional DMRS  dlDMRS=Two additional DMRS  actHighSpeedCell=true
    Get UEs               ${SA_CALL_1}  ${SA_CAPA}
    Detach UEs from cell  ${SA_CALL_1}
    Start tcpdump on gnb ASIK master
    sleep  5s
    Attach UEs to cell    ${SA_CALL_1}
    Start DL for UEs      ${SA_CALL_1}  ${DL_DURATION_1}  ${DL_THROUGHPUT}  udp
    sleep  10s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
    Verify cplane logs for two dmrs  pcap_file_path=${pcap_path}
    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_1}
    Stop using UEs        ${SA_CALL_1}
    Delete pyro_server UEPC
    Set ulDMRSAdditionalPosition    ulDMRS=One additional DMRS  dlDMRS=One additional DMRS  actHighSpeedCell=false
    Get UEs               ${SA_CALL_2}  ${SA_CAPA}
    Detach UEs from cell  ${SA_CALL_2}
    Start tcpdump on gnb ASIK master
    sleep  5s
    Attach UEs to cell    ${SA_CALL_2}
    Start DL for UEs      ${SA_CALL_2}  ${DL_DURATION_1}  ${DL_THROUGHPUT}  udp
    sleep  10s
    ${pcap_path}  Stop pcap collection in gNB ASIK master
    Verify cplane logs for one dmrs  pcap_file_path=${pcap_path}
    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_2}
    Stop using UEs        ${SA_CALL_2}

[1]CB008792-5G-C_18_PDSCH_two_additional_DMRS_0kmh_SA
    [Tags]    8792    sa
    [Documentation]
    ...  This test verifies the user's throughput for two additional DMRS under high speed conditions
#    Get 5G QXDM and QCAT licenses   ${UE_ALIAS}
    Set ulDMRSAdditionalPosition    ulDMRS=One additional DMRS  dlDMRS=One additional DMRS  actHighSpeedCell=false
    Get UEs               ${SA_CALL_1}  ${SA_CAPA}
    Start syslog capture
    Attach UEs to cell    ${SA_CALL_1}
    Start DL for UEs      ${SA_CALL_1}  ${DL_DURATION_2}  ${DL_THROUGHPUT}  udp
#    ${dl}  ${ul}    QXDM tput check SA
    sleep  ${DL_DURATION_2}
    Stop syslog capture
    ${dl}  ${ul}    Get max DLUL from syslog
    Should be true  int(${dl}) > ${MARGIN}*${DL_THRESHOLDS[0]}  msg=Tput is too small
#    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_1}
    Stop using UEs        ${SA_CALL_1}
    Delete pyro_server UEPC
    Set ulDMRSAdditionalPosition    ulDMRS=Two additional DMRS  dlDMRS=Two additional DMRS  actHighSpeedCell=true
    Get UEs               ${SA_CALL_2}  ${SA_CAPA}
    Start syslog capture
    Attach UEs to cell    ${SA_CALL_2}
    Start DL for UEs      ${SA_CALL_2}  ${DL_DURATION_2}  ${DL_THROUGHPUT}  udp
#    ${dl}  ${ul}    QXDM tput check SA
    sleep  ${DL_DURATION_2}
    Stop syslog capture
    ${dl}  ${ul}    Get max DLUL from syslog
    Log to console      ul:${ul}
    Should be true  int(${dl}) > ${MARGIN}*${DL_THRESHOLDS[1]}  msg=Tput is too small
#    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_2}
    Stop using UEs        ${SA_CALL_2}

[1]CB008792-5G-B_23_Activation_and_deactivation_for_uplink_DMRS+PTRS_highspeedcell_SA_NSA_ulFreqDensityTreshNrb0=279
    [Tags]           8792
    [Documentation]  This user scenario describes the common gNB behaviour at activation and deactivation for PUSCH PTRS
    ...              and partially PDSCH PTRS in highspeed cell
    Get UEs  ${UE_SA}  ${SA_CAPA}
    Perform commissioning 8792B_23
    ${cells_to_mirror}  Get global cell id of first cell
    ${cells_to_mirror}  Create List  ${cells_to_mirror}
    B23 Part A   ${UE_SA}  ${SA_CAPA}  ${cells_to_mirror}
    actUlPtrs & ulDMRSAdditionalPosition change  actUlPtrs=true  ulDMRSAdditionalPosition=Automatic
    log to console  SA UE full throughput: actUlPtrs=true, ulDMRS=Automatic
    B23 Part B   ${UE_SA}  ${SA_CAPA}  ${UL_THROUGHPUT_1}  1  4  235  ${cells_to_mirror}
    log to console  SA UE throughput 100kb/s: actUlPtrs=true, ulDMRS=Automatic
    B23 Part B   ${UE_SA}  ${SA_CAPA}  ${UL_THROUGHPUT_2}  1  2  4  ${cells_to_mirror}
    actUlPtrs & ulDMRSAdditionalPosition change
    B23 Part A   ${UE_SA}  ${SA_CAPA}  ${cells_to_mirror}

[1]CB008792-5G-B_27_PUSCH_DMRS+PTRS_SA_PUSCH_capable_0kmh
    [Tags]           8792  sa
    [Documentation]  This test verifies the static user's peak throughput in high speed cell with activated UL PTRS
#    Get 5G QXDM and QCAT licenses  ${UE_ALIAS}
    Perform commissioning 8792B_27
    ${cells_to_mirror}  Get global cell id of first cell
    ${cells_to_mirror}  Create List  ${cells_to_mirror}
    ${bip_path}  ${tput_1}  Perform B27 test  ${SA_CALL_1}  ${SA_CAPA}  ${cells_to_mirror}
    Verify bip logs for 8792B      ${bip_path}  L_PTRS_1  K_PTRS_4  235
    actHighSpeedCell & ulDMRSAdditionalPosition change
    ...    actHighSpeedCell=false
    ...    ulDMRSAdditionalPosition=One additional DMRS
    ...    dlDMRSAdditionalPosition=One additional DMRS
    ${bip_path}  ${tput_2}  Perform B27 test  ${SA_CALL_2}  ${SA_CAPA}  ${cells_to_mirror}
    Verify bip logs for 8792B      ${bip_path}  L_PTRS_1  K_PTRS_4  235
    actHighSpeedCell & actUlPtrs & ulDMRSAdditionalPosition change
    ...    actUlPtrs=false
    ...    actHighSpeedCell=true
    ...    ulDMRSAdditionalPosition=Two additional DMRS
    ...    dlDMRSAdditionalPosition=Two additional DMRS
    ${bip_path}  ${tput_3}  Perform B27 test  ${SA_CALL_3}  ${SA_CAPA}  ${cells_to_mirror}
    Verify bip logs for 8792B      ${bip_path}  L_PTRS_1  K_PTRS_4  235
    B27 compare tputs  ${tput_1}  ${tput_2}  ${tput_3}

CB008792-5G-D1_01_nonBF_Activation_Deactivation_PUSCH_additional_DMRS_2pos_HS_DL.256QAM_UL.64QAM
    [Tags]           8792
    [Documentation]  8792D
    log to console        Perform SA test
    Get UEs               ${SA_CALL_1}  ${SA_CAPA}
    Perform commissioning 8792D
    Detach UEs from cell  ${SA_CALL_1}
    Start tcpdump on gnb ASIK master
    sleep  5s
    Attach UEs to cell    ${SA_CALL_1}
    Start ULDL for UEs    ${SA_CALL_1}  ${DURATION}  ${DL_THROUGHPUT}  ${UL_THROUGHPUT}
    sleep  15s
    ${cplane_path}  Stop pcap collection in gNB ASIK master
#    Start L1L2 logs gathering  time=5  bb_slot_1=false  bb_slot_2=false  bb_slot_3=true  filter=${ABIO_FILTER}
#    ${bip_path}     Stop L1L2 logs gathering and download pcap
    ${cells_to_mirror}  Get global cell id of first cell
    ${cells_to_mirror}  Create List  ${cells_to_mirror}
    Start capturing interface mirroring logs  ${cells_to_mirror}
#    ${bip_path}  Collect interface mirroring logs
    Verify cplane logs for actPucchAdditionalDmrs=false  pcap_file_path=${cplane_path}
    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_1}
    Stop using UEs        ${SA_CALL_1}
    Get UEs               ${SA_CALL_2}  ${SA_CAPA}
    change actPucchAdditionalDmrs
    Detach UEs from cell  ${SA_CALL_2}
    Start tcpdump on gnb ASIK master
    sleep  5s
    Attach UEs to cell    ${SA_CALL_2}
    Start ULDL for UEs    ${SA_CALL_2}  ${DURATION}  ${DL_THROUGHPUT}  ${UL_THROUGHPUT}
    sleep  15s
    ${cplane_path}  Stop pcap collection in gNB ASIK master
#    Start L1L2 logs gathering  time=5  bb_slot_1=false  bb_slot_2=false  bb_slot_3=true  filter=${ABIO_FILTER}
#    ${bip_path}     Stop L1L2 logs gathering and download pcap
    Start capturing interface mirroring logs  ${cells_to_mirror}
#    ${bip_path}  Collect interface mirroring logs
    Verify cplane logs for actPucchAdditionalDmrs=true  pcap_file_path=${cplane_path}
    Await datatransfers finish
    Detach UEs from cell  ${SA_CALL_2}

CB008792-5G-ACDW_Peak.Tput_PDSCH_1AddDMRS_Normall.cell_Vs_2AddDMRS_HS.cell_SA/NSA_PDSCH_mapping_type_A_pos2_FDM_ON
    [Tags]           8792
    [Documentation]  Check if new functionality is working properly for uplink and dowlink and with PUCCH additional
    ...              DMRS together (A+C+D subfeautures)
    Perform commissioning 8792ACDW
    ${cells_to_mirror}  Get global cell id of first cell
    ${cells_to_mirror}  Create List  ${cells_to_mirror}
    ${cplane_path}  ACDW call test  ${SA_CALL_1}  ${1}  ${cells_to_mirror}
    Verify cplane logs for one dmrs                      ${cplane_path}
    Verify cplane logs for actPucchAdditionalDmrs=false  ${cplane_path}
    Perform commissioning 8792ACDW
    ...  ulDMRSAdditionalPosition=Two additional DMRS  #Automatic
    ...  dlDMRSAdditionalPosition=Two additional DMRS
    ...  actHighSpeedCell=true
    ACDW call test  ${SA_CALL_2}  ${2}  ${cells_to_mirror}
    Perform commissioning 8792ACDW
    ...  ulDMRSAdditionalPosition=Two additional DMRS  #Automatic
    ...  dlDMRSAdditionalPosition=Two additional DMRS
    ...  actHighSpeedCell=true
    ...  actPucchAdditionalDmrs=true
    ...  msg1FrequencyStart=27
    ...  reqMinNumPuschPrb=219
    ${cplane_path}  ACDW call test  ${SA_CALL_3}  ${3}  ${cells_to_mirror}
    Verify cplane logs for two dmrs                      ${cplane_path}
    Verify cplane logs for actPucchAdditionalDmrs=true   ${cplane_path}
