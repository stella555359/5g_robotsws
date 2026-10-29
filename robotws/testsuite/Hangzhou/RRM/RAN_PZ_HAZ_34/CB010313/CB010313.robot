# @Time    : 2023/2/15 15:08
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB010313.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature CB010313 256 QAM for PUSCH for CPRI based TDD RF units_ABIL

Suite Setup     Run Keywords    CI_interface.Common Suite Setup
...    AND    robot_common_operations.Common Suite Setup
#...    AND    Download MCShark To UTE
Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup      Run Keywords    robot_common_operations.Common Case Setup 
...    AND    Connect to gnb coam via ssl
Test Teardown   Run Keywords    robot_common_operations.Common Case Teardown 
...    AND     CI_interface.Common Case Teardown
...    AND    Run Keyword And Ignore Error    COAM Teardown gnb connections
Force Tags      CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py

*** Variables ***
${if_commissioning}    False
#Variables defined in external files, such as
#${TS_CASE_LOG_PATH}     /home/ute/MMW_SG5
#${BIP_FILE_PATH}        ${TS_CASE_LOG_PATH}/l1l2bip
${BIP_FILTER}    3gpp.rnti!=65521&&uldata_puschreceivereq
#Update BIP_FILTER as rnti65521 impacts MCS anyalsis, this rnti is FakeUe for CB009794
@{BIP_FIELDS}    UlData_puschReceiveReqGrant_t.mcs    UlData_puschReceiveReqGrant_t.mcsTable
...    UlData_puschReceiveReqGrant_t.ulDmrsMappingType
# Cell name:	10313-2022-cell1
# Physical layer cell ID:	26
# NR cell ID:	604831745
@{NR_PHY_CELL_IDS}    26
${global_cell_id}    1
# For Case09 check MCS counter M55302C11000~27
@{MCS_COMMON_COUNTERS}    M55302C110    M55302C120    M55302C130    M55302C140
...    M55303C220    M55303C230    M55304C090    M55304C100
# For perform actUlDataDmrsFdm commission
&{ulDataDmrsFdm_Structure}    actUlDataDmrsFdm=false    ulDataDmrsFdmThres64QamMcs=5
...    ulDataDmrsFdmThres256QamMcs=5
@{ulDataDmrsFdm_list}    &{ulDataDmrsFdm_Structure}
# For perform actUlPtrs commission
&{ulPtrs_Structure}    actUlPtrs=false    ulPtrsFreqDensityThresNrb0=278
...    ulPtrsFreqDensityThresNrb1=24
@{ulPtrs_list}    &{ulPtrs_Structure}
${SCF_01}    ${CURDIR}/scf/case01.xml
${SCF_02}    ${CURDIR}/scf/case02.xml
${SCF_03}    ${CURDIR}/scf/case03.xml
${SCF_04}    ${CURDIR}/scf/case04.xml
${SCF_09}    ${CURDIR}/scf/case09.xml
${SCF_10}    ${CURDIR}/scf/case10.xml
${SCF_11}    ${CURDIR}/scf/case11.xml
${SCF_11_4D2U}    ${CURDIR}/scf/case11_4D2U.xml
${SCF_12}    ${CURDIR}/scf/case12.xml
${LNCEL_DISTNAME}    MRBTS-2031/LNBTS-10445/LNCEL-3

*** Test Cases ***
CB010313-SR-A_01_A1_256_QAM_for_PUSCH_Feature_Activation_4RX_SA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c001
    ...    peak throughput: ul(327040)
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_01}    ${CURDIR}/scf/case01_23R3.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=locked
    COAM Commission with scf file    ${SCF_01}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=actUl256Qam    value=false
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    3x    5s    Verify PUSCH Feature Activation And Check Bip
    ...    ul_tp=350M    ul_tp_threshold=300
    ...    dl_tp=100M    dl_tp_threshold=50    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/001_64qam_to_256qam.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    ...    msc_table=1    attach_mode=SA

CB010313-SR-A_02_A1_256_QAM_for_PUSCH_Feature_Activation_2RX_NSA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c002
    ...    peak throughput: ul(109168/109304)
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_02}    ${CURDIR}/scf/case02_23R3.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=unlocked
    COAM Commission with scf file    ${SCF_02}    is_pdl_checking_needed=${False}    timeout=900
    Wait until keyword succeeds    15min    30s    COAM Check X2 link status from GNB
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=actUl256Qam    value=false
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Verify PUSCH Feature Activation And Check Bip    ul_tp=150M    ul_tp_threshold=100
    ...    dl_tp=100M    dl_tp_threshold=80    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/002_64qam_to_256qam.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    ...    msc_table=1    attach_mode=NSA

CB010313-SR-A_03_A2_256_QAM_for_PUSCH_Feature_Deactivation_4RX_SA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c003
    ...    peak throughput(256qam): ul(299904)
    ...    peak throughput(64qam): ul(223368)
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_03}    ${CURDIR}/scf/case03_23R3.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=locked
    COAM Commission with scf file    ${SCF_03}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    3x    5s    Verify PUSCH Feature Deactivation And Check Bip
    ...    ul_tp=350M    ul_tp_threshold=280
    ...    dl_tp=100M    dl_tp_threshold=50    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/003_256qam.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    ...    msc_table=1    duration=1200    attach_mode=SA
    Verify PUSCH Feature Deactivation In UE Idle And Check Bip
    ...    ul_tp=350M    256qam_ul_tp_threshold=280
    ...    64qam_ul_tp_threshold=200
    ...    dl_tp=100M    dl_tp_threshold=50    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/003_64qam.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    ...    msc_table=1    duration=1200    attach_mode=SA

CB010313-SR-A_04_A2_256_QAM_for_PUSCH_Feature_Deactivation_2RX_NSA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c004
    ...    peak throughput(256qam): ul(93496/93648)
    ...    peak throughput(64qam): ul(81952)
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_04}    ${CURDIR}/scf/case04_23R3.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=unlocked
    COAM Commission with scf file    ${SCF_04}    is_pdl_checking_needed=${False}    timeout=900
    Wait until keyword succeeds    15min    30s    COAM Check X2 link status from GNB
    Verify PUSCH Feature Deactivation And Check Bip    ul_tp=150M    ul_tp_threshold=85
    ...    dl_tp=100M    dl_tp_threshold=80    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/004_256qam.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    ...    msc_table=1    duration=1200    attach_mode=NSA
    Verify PUSCH Feature Deactivation In UE Idle And Check Bip    ul_tp=350M    256qam_ul_tp_threshold=85
    ...    64qam_ul_tp_threshold=75
    ...    dl_tp=100M    dl_tp_threshold=80    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/004_64qam.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    ...    msc_table=1    duration=1200    attach_mode=NSA

CB010313-SR-A_05_A3_Switching_between_64QAM_mode_and_256QAM mode_4RX_VONR
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Tags]    c005
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_03}    ${CURDIR}/scf/case03_23R3.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=locked
    COAM Commission with scf file    ${SCF_03}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online

    #10313 05 Retry
    Wait Until Keyword Succeeds    5x    30s    10313 05 Retry

CB010313-SR-B_09_B1_PUSCH_mapping_typeA_co-existence_with_PUSCH_256QAM_for_TDD_2RX_SA_TCP_counters
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    peak throughput: typeA ul(174952/176672) dl(807072)
    ...    peak throughput: typeB ul(177720/176672) dl(810568)
    [Tags]    c009
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_09}    ${CURDIR}/scf/case09_23R3.xml
    Run Keyword If    '${release}'=='SBTS23R4'    Set Suite Variable    ${SCF_09}    ${CURDIR}/scf/case09_23R4.xml
    Run Keyword If    '${release}'=='SBTS24R1'    Set Suite Variable    ${SCF_09}    ${CURDIR}/scf/case09_24R1.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=locked
    COAM Commission with scf file    ${SCF_09}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip
    ...    puschMappingType=TypeA    ul_tp=210M
    ...    dl_tp=850M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/009_typea.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip
    ...    puschMappingType=TypeB    ul_tp=210M
    ...    dl_tp=850M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/009_typeb.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}

CB010313-SR-B_10_B1_PUSCH_mapping_typeA_co-existence_with_PUSCH_256QAM_for_TDD_4RX_NSA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    peak throughput: typeA ul(137712/139384) dl(1321520/1321320) rank=1
    ...    peak throughput: typeB ul(138824/139384) dl(1321616/1318384) rank=1
    [Tags]    c010
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_10}    ${CURDIR}/scf/case10_23R3.xml
    Run Keyword If    '${release}'=='SBTS23R4'    Set Suite Variable    ${SCF_10}    ${CURDIR}/scf/case10_23R4.xml
    Run Keyword If    '${release}'=='SBTS24R1'    Set Suite Variable    ${SCF_10}    ${CURDIR}/scf/case10_24R1.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=unlocked
    COAM Commission with scf file    ${SCF_10}    is_pdl_checking_needed=${False}    timeout=900
    Wait until keyword succeeds    15min    30s    COAM Check X2 link status from GNB
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip    puschMappingType=TypeA    ul_tp=175M
    ...    dl_tp=1310M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary    ue_ul_layer=${1}
    ...    bip_file=${BIP_FILE_PATH}/010_typea.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    ...    attach_mode=NSA
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip    puschMappingType=TypeB    ul_tp=175M
    ...    dl_tp=1310M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary    ue_ul_layer=${1}
    ...    bip_file=${BIP_FILE_PATH}/010_typeb.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    ...    attach_mode=NSA

CB010313-SR-B_11_B2_PUSCH_data_and_DMRS_FDM_co-existence_with_PUSCH_256QAM_for_TDD_4RX_SA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    peak throughput: typeA ul(137712/139384) dl(1321520/1321320) rank=1
    ...    peak throughput: typeB ul(138824/139384) dl(1321616/1318384) rank=1
    [Tags]    c011
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_11}    ${CURDIR}/scf/case11_23R3.xml
    Run Keyword If    '${release}'=='SBTS23R4'    Set Suite Variable    ${SCF_11}    ${CURDIR}/scf/case11_23R4.xml
    Run Keyword If    '${release}'=='SBTS24R1'    Set Suite Variable    ${SCF_11}    ${CURDIR}/scf/case11_24R1.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=locked
    COAM Commission with scf file    ${SCF_11}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip
    ...    puschMappingType=TypeB    ul_tp=327M
    ...    dl_tp=1310M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/011_4D4U_fdm_true.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=ulDataDmrsFdm    value=${ulDataDmrsFdm_list}
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip
    ...    puschMappingType=TypeA    ul_tp=300M
    ...    dl_tp=1310M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/011_4D4U_fdm_false.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}

CB010313-SR-B_21_B2_PUSCH_data_and_DMRS_FDM_co-existence_with_PUSCH_256QAM_for_TDD_2RX_SA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    peak throughput: typeA ul(137712/139384) dl(1321520/1321320) rank=1
    ...    peak throughput: typeB ul(138824/139384) dl(1321616/1318384) rank=1
    ...    Split 4D2U part from case11
    [Tags]    c021
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_11_4D2U}    ${CURDIR}/scf/case11_4D2U_23R3.xml
    Run Keyword If    '${release}'=='SBTS23R4'    Set Suite Variable    ${SCF_11_4D2U}    ${CURDIR}/scf/case11_4D2U_23R4.xml
    Run Keyword If    '${release}'=='SBTS24R1'    Set Suite Variable    ${SCF_11_4D2U}    ${CURDIR}/scf/case11_4D2U_24R1.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=locked
    COAM Commission with scf file    ${SCF_11_4D2U}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip
    ...    puschMappingType=TypeB    ul_tp=327M
    ...    dl_tp=1310M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/011_4D2U_fdm_true.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=ulDataDmrsFdm    value=${ulDataDmrsFdm_list}
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip
    ...    puschMappingType=TypeA    ul_tp=300M
    ...    dl_tp=1310M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary
    ...    bip_file=${BIP_FILE_PATH}/011_4D2U_fdm_false.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}

CB010313-SR-B_12_B2_PUSCH_data_and_DMRS_FDM_co-existence_with_PUSCH_256QAM_for_TDD_2RX_NSA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    peak throughput: typeB ul(104944) dl(467664) rank=1
    [Tags]    c012
    ${result}    ${release}    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
    Run Keyword If    '${release}'=='SBTS23R3'    Set Suite Variable    ${SCF_12}    ${CURDIR}/scf/case12_23R3.xml
    Run Keyword If    '${release}'=='SBTS23R4'    Set Suite Variable    ${SCF_12}    ${CURDIR}/scf/case12_23R4.xml
    Run Keyword If    '${release}'=='SBTS24R1'    Set Suite Variable    ${SCF_12}    ${CURDIR}/scf/case12_24R1.xml
    Modify Parameter On ENB With Activate    dist_name=${LNCEL_DISTNAME}
    ...    parameter=administrativeState    value=unlocked
    COAM Commission with scf file    ${SCF_12}    is_pdl_checking_needed=${False}    timeout=900
    Wait until keyword succeeds    15min    30s    COAM Check X2 link status from GNB
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip    puschMappingType=TypeB    ul_tp=116M
    ...    dl_tp=850M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary    ue_ul_layer=${1}
    ...    bip_file=${BIP_FILE_PATH}/012_fdm_true.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=ulDataDmrsFdm    value=${ulDataDmrsFdm_list}
    Wait Until Keyword Succeeds    3x    5s    Verify Peak Throughput And Check Bip    puschMappingType=TypeA    ul_tp=116M
    ...    dl_tp=850M    cell_ids=${NR_PHY_CELL_IDS}    smod_location=primary    ue_ul_layer=${1}
    ...    bip_file=${BIP_FILE_PATH}/012_fdm_false.csv    bip_filter=${BIP_FILTER}    bip_fields=${BIP_FIELDS}

*** Keywords ***
10313 05 Retry
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Start To Capture Wireshark Log From DU
    Verify UE Voice Call Can Be Performed
    Stop To Capture Wireshark Log From DU    local_pcap_path=${TS_CASE_LOG_PATH}/005.pcap
    cap.setup    infile=${TS_CASE_LOG_PATH}/005.pcap    display_filter=ngap    alias=test0
    ${fiveQI1_packets}    cap.get_packets    filter=ngap.fiveQI==1   pcap_parser=test0
    Should Not Be Empty    ${fiveQI1_packets}
    ${ue_type}    translate power ue type from testline
    power_ue.UE Detach    ue_type=${ue_type}

Verify PUSCH Feature Activation And Check Bip
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ul_tp}    ${ul_tp_threshold}    ${dl_tp}    ${dl_tp_threshold}
    ...    ${cell_ids}    ${smod_location}    ${bip_file}    ${bip_filter}    ${bip_fields}
    ...    ${global_cell_id}=1    ${ul_duration}=600    ${dl_duration}=600    ${msc_table}=1    ${attach_mode}=SA
    UE Attach With Verify Attach    attach_mode=${attach_mode}
    UE Mobile Data Disable
    Sleep    30s
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=actUl256Qam    value=true
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Sleep    30s
    UE Mobile Data Enable
    Sleep    30s
    UE Attach And Start Check Throughput    global_cell_id=${global_cell_id}
    ...    ul_tp=${ul_tp}    ul_tp_threshold=${ul_tp_threshold}
    ...    dl_tp=${dl_tp}   dl_tp_threshold=${dl_tp_threshold}
    ...    ul_duration=${ul_duration}    dl_duration=${dl_duration}
    Collect Bip Log And Convert To CSV    ${cell_ids}    ${smod_location}    ${bip_file}
    ...    ${bip_filter}    ${bip_fields}
    Verify MSCTable Is Normal In Bip Log    ${bip_file}    ${msc_table}
    Verify MCS Is Normal In Bip Log    ${bip_file}
    ${ue_type}    translate power ue type from testline
    power_ue.UE Detach    ue_type=${ue_type}

Verify PUSCH Feature Deactivation And Check Bip
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ul_tp}    ${ul_tp_threshold}    ${dl_tp}    ${dl_tp_threshold}
    ...    ${cell_ids}    ${smod_location}    ${bip_file}    ${bip_filter}    ${bip_fields}
    ...    ${global_cell_id}=1    ${duration}=600    ${msc_table}=0    ${attach_mode}=SA
    ${ul_tp}    ${dl_tp}    UE Attach And Check Throughput Without Detach    global_cell_id=${global_cell_id}
    ...    ul_tp=${ul_tp}    ul_tp_threshold=${ul_tp_threshold}
    ...    dl_tp=${dl_tp}   dl_tp_threshold=${dl_tp_threshold}
    ...    duration=${duration}    attach_mode=${attach_mode}
    Collect Bip Log And Convert To CSV    ${cell_ids}    ${smod_location}    ${bip_file}
    ...    ${bip_filter}    ${bip_fields}
    Verify MSCTable Is Normal In Bip Log    ${bip_file}    ${msc_table}
    Verify MCS Is Normal In Bip Log    ${bip_file}
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=actUl256Qam    value=false
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    ${ue_type}    translate power ue type from testline
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    power_ue.Check throughput    ue_index=0    direction=ul    ue_type=${ue_type}
    ...    throughput=${ul_tp_threshold}    cellid=${nr_cell_identity}
    power_ue.Check throughput    ue_index=0    direction=dl    ue_type=${ue_type}
    ...    throughput=${dl_tp_threshold}    cellid=${nr_cell_identity}
    Connect To BTS Csn Via Lmp
    ${ul_tp_64qam}    Calculate UL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    ${dl_tp_64qam}    Calculate DL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=actUl256Qam    value=true
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    power_ue.Check throughput    ue_index=0    direction=ul    ue_type=${ue_type}
    ...    throughput=${ul_tp_threshold}    cellid=${nr_cell_identity}
    power_ue.Check throughput    ue_index=0    direction=dl    ue_type=${ue_type}
    ...    throughput=${dl_tp_threshold}    cellid=${nr_cell_identity}
    Connect To BTS Csn Via Lmp
    ${ul_tp_256qam}    Calculate UL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    ${dl_tp_256qam}    Calculate DL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    power_ue.UE Detach    ue_type=${ue_type}
    Verify Two Throughputs Are Similar    ${ul_tp}    ${ul_tp_64qam}
    Verify Two Throughputs Are Similar    ${ul_tp_64qam}    ${ul_tp_256qam}

Verify PUSCH Feature Deactivation In UE Idle And Check Bip
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ul_tp}    ${256qam_ul_tp_threshold}    ${64qam_ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}
    ...    ${cell_ids}    ${smod_location}    ${bip_file}    ${bip_filter}    ${bip_fields}
    ...    ${global_cell_id}=1    ${duration}=600    ${msc_table}=0    ${attach_mode}=SA
    UE Attach And Check Throughput Without Detach    global_cell_id=${global_cell_id}
    ...    ul_tp=${ul_tp}    ul_tp_threshold=${256qam_ul_tp_threshold}
    ...    dl_tp=${dl_tp}   dl_tp_threshold=${dl_tp_threshold}
    ...    duration=${duration}    attach_mode=${attach_mode}
    Collect Bip Log And Convert To CSV    ${cell_ids}    ${smod_location}    ${bip_file}
    ...    ${bip_filter}    ${bip_fields}
    Verify MSCTable Is Normal In Bip Log    ${bip_file}    1
    ${ue_type}    translate power ue type from testline
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    UE Mobile Data Disable
    Sleep    30s
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=actUl256Qam    value=false
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    Sleep    30s
    UE Mobile Data Enable
    Sleep    30s
    UE Attach And Start Check Throughput    global_cell_id=${global_cell_id}
    ...    ul_tp=${ul_tp}    ul_tp_threshold=${64qam_ul_tp_threshold}
    ...    dl_tp=${dl_tp}   dl_tp_threshold=${dl_tp_threshold}
    ...    ul_duration=${ul_duration}    dl_duration=${dl_duration}
    Collect Bip Log And Convert To CSV    ${cell_ids}    ${smod_location}    ${bip_file}
    ...    ${bip_filter}    ${bip_fields}
    Verify MSCTable Is Normal In Bip Log    ${bip_file}    0
    Verify MCS Is Normal In Bip Log    ${bip_file}
    ${ue_type}    translate power ue type from testline
    power_ue.UE Detach    ue_type=${ue_type}

Verify Peak Throughput And Check Bip
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${puschMappingType}    ${ul_tp}    ${dl_tp}
    ...    ${cell_ids}    ${smod_location}    ${bip_file}    ${bip_filter}    ${bip_fields}
    ...    ${global_cell_id}=1    ${duration}=600    ${msc_table}=1
    ...    ${attach_mode}=SA    ${ue_ul_layer}=None
    Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    parameter=puschMappingType    value=${puschMappingType}
    ${scf_file}    COAM Download scf from cluster    scf_dir_path=${TS_LOG_PATH_BASE}
    ${theoretical_dl}    ${theoretical_ul}    Get Theoretical Throughput    scf_path=${scf_file}   cell_id=${global_cell_id}
    ...    ue_ul_layer=${ue_ul_layer}
    Wait Until Keyword Succeeds    15min    15s    CI_commssion.Verify all cells should be Online
    ${ul}    ${dl}    UE Attach And Check Throughput Without Detach    global_cell_id=${global_cell_id}
    ...    ul_tp=${ul_tp}    ul_tp_threshold=${theoretical_ul}
    ...    dl_tp=${dl_tp}   dl_tp_threshold=${theoretical_dl}
    ...    duration=${duration}    attach_mode=${attach_mode}
    Collect Bip Log And Convert To CSV    ${cell_ids}    ${smod_location}    ${bip_file}
    ...    ${bip_filter}    ${bip_fields}
    Verify MSCTable Is Normal In Bip Log    ${bip_file}    ${msc_table}
    Verify MCS Is Normal In Bip Log    ${bip_file}
    Verify PuschMappingType Is Normal In Bip Log    ${bip_file}    ${puschMappingType}
    ${ue_type}    translate power ue type from testline
    power_ue.UE Detach    ue_type=${ue_type}

Verify MSCTable Is Normal In Bip Log
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    mcsTable=1 ---> max256QAM
    ...    mcsTable=0 ---> max64QAM
    [Arguments]    ${bip_file}    ${mcs_table}=1
    ${average_msctable}    get_the_special_item_average_value    ${bip_file}    UlData_puschReceiveReqGrant_t.mcsTable
    Should Be True    "${mcs_table}"=="${average_msctable}"

Verify PuschMappingType Is Normal In Bip Log
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    puschMappingType=1 ---> TypeB
    ...    puschMappingType=0 ---> TypeA
    [Arguments]    ${bip_file}    ${puschMappingType}
    ${average_ulDmrsMappingType}    get_the_special_item_average_value
    ...    ${bip_file}    UlData_puschReceiveReqGrant_t.ulDmrsMappingType
    Run Keyword If    "${puschMappingType}" == "TypeA"    Should Be True    "0"=="${average_ulDmrsMappingType}"
    ...    ELSE    Should Be True    "1"=="${average_ulDmrsMappingType}"

Verify MCS Is Normal In Bip Log
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${bip_file}    ${min_mcs}=20
    ${average_mcs}    get_the_special_item_average_value    ${bip_file}    UlData_puschReceiveReqGrant_t.mcs
    Should Be True    "${average_mcs}">"${min_mcs}"

Verify Target MCS Counter Update Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${mcs_value}
    ${counter_ids}    Set Variable
    FOR    ${mcs_counter}    IN    @{MCS_COMMON_COUNTERS}
        ${counter_ids}    Set Variable    ${counter_ids}${mcs_counter}${mcs_value},
    END
    ${mcs_counter}    coam.get_pm_counters    counter_ids=${counter_ids}    connection=GNB_OAM
    ${msc_counters_value}    Get Latest MCS Counters Value    ${mcs_counter}    ${mcs_value}
    [Return]    ${msc_counters_value}

Get Latest MCS CounterS Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${msc_counters}    ${mcs_value}    ${nrcell_id}=2
    ${nulhq}    Set Variable    ${msc_counters['BTS']['CELLS']['NRCELL-${nrcell_id}']['NULHQ']}
    ${nulsq}    Set Variable    ${msc_counters['BTS']['CELLS']['NRCELL-${nrcell_id}']['NULSQ']}
    ${nmpdu}    Set Variable    ${msc_counters['BTS']['CELLS']['NRCELL-${nrcell_id}']['NMPDU']}
    ${time_list}    Get Dictionary Keys    ${nulhq['M55302C110${mcs_value}']}
    ${last_timestamp}    Set Variable    ${time_list[0]}
    ${nulhq1}    Set Variable    ${nulhq['M55302C110${mcs_value}']['${last_timestamp}']}
    ${nulhq2}    Set Variable    ${nulhq['M55302C120${mcs_value}']['${last_timestamp}']}
    ${nulhq3}    Set Variable    ${nulhq['M55302C130${mcs_value}']['${last_timestamp}']}
    ${nulhq4}    Set Variable    ${nulhq['M55302C140${mcs_value}']['${last_timestamp}']}
    ${nulsq1}    Set Variable    ${nulsq['M55303C220${mcs_value}']['${last_timestamp}']}
    ${nulsq2}    Set Variable    ${nulsq['M55303C230${mcs_value}']['${last_timestamp}']}
    ${nmpdu1}    Set Variable    ${nmpdu['M55304C090${mcs_value}']['${last_timestamp}']}
    ${nmpdu2}    Set Variable    ${nmpdu['M55304C100${mcs_value}']['${last_timestamp}']}
    @{msc_counters_value}    Create List    ${nulhq1}    ${nulhq2}    ${nulhq3}    ${nulhq4}
    ...    ${nulsq1}    ${nulsq2}    ${nmpdu1}    ${nmpdu2}
    [Return]    ${msc_counters_value}
