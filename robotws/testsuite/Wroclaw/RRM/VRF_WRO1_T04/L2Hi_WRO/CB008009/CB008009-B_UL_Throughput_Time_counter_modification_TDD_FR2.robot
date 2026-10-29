*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD

Documentation
...    author: Arkadiusz Sobejko, Magdalena Hebda
...    contact: magdalena.hebda@nokia.com
...    Description: Suite description in QC

Resource      resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot
Resource     ../resources/common_keywords.robot
Library       resources/CB008009_resources_time_counters.py

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_TDD_FR2.cfg
${ap_xml}=         ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/iphy_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml
${scfc}=           ${CURDIR}/config/TDD_mmW_eCPRI_LO_AP_LO/scfc_TDD_NSA_LO_AP_LO_2AWEUA_2cells.xml
${counters}=       M55349C00001-M55349C00020,M55349C02001,M55353C00001,M55353C01001

*** Test Cases ***
CB008009-B_UL_Throughput_Time_counter_modification_with_time_calculation_NSA

    [Setup]    Prepare test environment

    Wait for next full pm interval
    Attach UE  UE_ID=11
    SgNB Addition  UE_ID=11  CELL_ID=1
    Start data ul traffic on single UE1 in SA mode
    Verify single UE counters with iperf values
    Attach 3 additional UEs and start gNB Addition Procedure
    Start data ul traffic on three UEs in SA mode
    Verify multiple UEs counters

    [Teardown]    CB008009_resources.Detach NR-UEs and deconfigure gNB and clear environment

*** Keywords ***
Prepare test environment
    Configure NSA PMQAP Profiles
    Activate automatic PM Stats

Verify other QoS time counters are not incremented based on ${file}
    Verify Last Counters In File
    ...    M55349C00001    0    UL_RLC_TIME_UE_TPUT_QOS_01
    ...    M55349C00002    0    UL_RLC_TIME_UE_TPUT_QOS_02
    ...    M55349C00003    0    UL_RLC_TIME_UE_TPUT_QOS_03
    ...    M55349C00004    0    UL_RLC_TIME_UE_TPUT_QOS_04
    ...    M55349C00005    0    UL_RLC_TIME_UE_TPUT_QOS_05
    ...    M55349C00006    0    UL_RLC_TIME_UE_TPUT_QOS_06
    ...    M55349C00007    0    UL_RLC_TIME_UE_TPUT_QOS_07
    ...    M55349C00008    0    UL_RLC_TIME_UE_TPUT_QOS_08
    ...    M55349C00010    0    UL_RLC_TIME_UE_TPUT_QOS_10
    ...    M55349C00011    0    UL_RLC_TIME_UE_TPUT_QOS_11
    ...    M55349C00012    0    UL_RLC_TIME_UE_TPUT_QOS_12
    ...    M55349C00013    0    UL_RLC_TIME_UE_TPUT_QOS_13
    ...    M55349C00014    0    UL_RLC_TIME_UE_TPUT_QOS_14
    ...    M55349C00015    0    UL_RLC_TIME_UE_TPUT_QOS_15
    ...    M55349C00016    0    UL_RLC_TIME_UE_TPUT_QOS_16
    ...    M55349C00017    0    UL_RLC_TIME_UE_TPUT_QOS_17
    ...    M55349C00018    0    UL_RLC_TIME_UE_TPUT_QOS_18
    ...    M55349C00019    0    UL_RLC_TIME_UE_TPUT_QOS_19
    ...    M55349C00020    0    UL_RLC_TIME_UE_TPUT_QOS_20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${file}

Verify other QoS volume counters are not incremented based on ${file}
    Verify Last Counters In File
    ...    M55349C01001    0    UL_RLC_VOL_UE_TPUT_QOS_01
    ...    M55349C01002    0    UL_RLC_VOL_UE_TPUT_QOS_02
    ...    M55349C01003    0    UL_RLC_VOL_UE_TPUT_QOS_03
    ...    M55349C01004    0    UL_RLC_VOL_UE_TPUT_QOS_04
    ...    M55349C01005    0    UL_RLC_VOL_UE_TPUT_QOS_05
    ...    M55349C01006    0    UL_RLC_VOL_UE_TPUT_QOS_06
    ...    M55349C01007    0    UL_RLC_VOL_UE_TPUT_QOS_07
    ...    M55349C01008    0    UL_RLC_VOL_UE_TPUT_QOS_08
    ...    M55349C01010    0    UL_RLC_VOL_UE_TPUT_QOS_10
    ...    M55349C01011    0    UL_RLC_VOL_UE_TPUT_QOS_11
    ...    M55349C01012    0    UL_RLC_VOL_UE_TPUT_QOS_12
    ...    M55349C01013    0    UL_RLC_VOL_UE_TPUT_QOS_13
    ...    M55349C01014    0    UL_RLC_VOL_UE_TPUT_QOS_14
    ...    M55349C01015    0    UL_RLC_VOL_UE_TPUT_QOS_15
    ...    M55349C01016    0    UL_RLC_VOL_UE_TPUT_QOS_16
    ...    M55349C01017    0    UL_RLC_VOL_UE_TPUT_QOS_17
    ...    M55349C01018    0    UL_RLC_VOL_UE_TPUT_QOS_18
    ...    M55349C01019    0    UL_RLC_VOL_UE_TPUT_QOS_19
    ...    M55349C01020    0    UL_RLC_VOL_UE_TPUT_QOS_20
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${file}

Get throughput and time variable based on ${iperf_log}
    ${total_time}=  Get total time             iperf_log=${OUTPUT_DIR}/${iperf_log}
    ${total_vol}=   Get total volume in kbits  iperf_log=${OUTPUT_DIR}/${iperf_log}
    ${total_time}=  Convert To String  ${total_time}
    ${total_vol}=  Convert To String  ${total_vol}
    Set test variable  ${total_time}
    Set test variable  ${total_vol}

Verify counters
    ${pm_counters}=  Wait for next pm interval and get counters
    Set test variable  ${pm_counters}
    Verify value of counter  counter_id=M55349C04001  pm_counter_file=${pm_counters}  expected_value=${total_time}  margin=7
    Verify value of counter  counter_id=M55353C01001  pm_counter_file=${pm_counters}  expected_value=${total_time}  margin=7
    Verify value of counter  counter_id=M55349C00009  pm_counter_file=${pm_counters}  expected_value=${total_time}  margin=7
    Verify value of counter  counter_id=M55349C01009  pm_counter_file=${pm_counters}  expected_value=${total_vol}  margin=5

    Verify other QoS time counters are not incremented based on ${pm_counters}
    Verify other QoS volume counters are not incremented based on ${pm_counters}
    Get counters value and report to rp  counters=${counters}  filepath=${pm_counters}  localmoid=NRCELL-1

Start data ul traffic on single UE1 in SA mode
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=25m  duration=30  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=40m  duration=30  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=60m  duration=30  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=80m  duration=30  logfile=iperf_single_ue.log
    Start throughput on single ue  tput_type=NSA_UL  ue=UE11  tput=100m  duration=30  logfile=iperf_single_ue.log

Verify single UE counters with iperf values
    Get throughput and time variable based on iperf_single_ue.log
    Verify counters
    Verify Last Counters In File
    ...    M55349C02001    100000-116000      MAX_UL_RLC_UE_TPUT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Kill Iperf Processes
    Wait for next full pm interval

Start data ul traffic on three UEs in SA mode
    Start throughput on three ues  tput_type=NSA_UL  tput1=20m  tput2=23m  tput3=28m  duration=40  logfile=iperf_multiple_ues.log

Verify multiple UEs counters
    Get throughput and time variable based on iperf_multiple_ues.log
    Verify counters
    Verify Last Counters In File
    ...    M55349C02001    26000-29000      MAX_UL_RLC_UE_TPUT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Detach NR-UEs and deconfigure gNB and clear environment
    Detach UEs and clear up test environment
    Teardown egate
