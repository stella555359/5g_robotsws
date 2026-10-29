*** Settings ***

Documentation
...    author: Magdalena Hebda
...    contact: magdalena.hebda@nokia.com
...    Description: Suite description in QC

Resource       resources/CB008009_resources.robot
Resource     ../resources/common_configuration.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_FDD    SBTS00    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup       Setup test environment
Test Teardown    Send Configuration ID To Scout
Suite Teardown    Clean suite environment

*** Variables ***
${lua_cfg_file}=   ${CURDIR}/config/basic_setup_FDD.cfg
${ap_xml}=         ${CURDIR}/config/FDD_CPRI_LO_AP_LO/iphy_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml
${scfc}=           ${CURDIR}/config/FDD_CPRI_LO_AP_LO/scfc_FDD_SANSA_LO_AP_LO_2AWEUA_2cells.xml

*** Test Cases ***
CB008009-B_UL_Throughput_Time_counter_modification_without_time_calculation_SA

    [Setup]  Prepare test environment
    Register UE  UE_ID=1  CELL_ID=1
    Establish PDU session  UE_ID=1
    Start data ul traffic on single UE1 in SA mode
    Verify single UE counters with iperf values
    Register 3 additional UEs and establish PDUs sessions
    Start data ul traffic on three UEs in SA mode
    Verify multiple UEs counters
    [Teardown]    Deregister UEs and clear up test environment

*** Keywords ***
Prepare test environment
    Configure SA PMQAP Profiles
    Set feature flag NRBTS-1/thpTimeCalc to disabled

Start data ul traffic on single UE1 in SA mode
    Wait for next full pm interval
    Start throughput on single ue  tput_type=SA_UL  ue=UE1  tput=150M   duration=10  logfile=iperf_single_ue.log

Verify single UE counters with iperf values
    ${pm_counters}=  Wait for next pm interval and get counters
    Run keyword and continue on failure
    ...    Verify Last Counters In File
    ...    M55349C02001    98000-108000      MAX_UL_RLC_UE_TPUT
    ...    M55353C01001    9000-11000        UL_RLC_TIME_UE_TPUT_PMQAP
    ...    M55349C04001    9000-11000        UL_RLC_TIME_UE_TPUT
    ...    M55349C00006    9000-11000        UL_RLC_TIME_UE_TPUT_QOS_06
    ...    M55349C01006    950000-1100000    UL_RLC_VOL_UE_TPUT_QOS_06
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}
    Verify other QoS time counters are not incremented based on ${pm_counters}
    Verify other QoS volume counters are not incremented based on ${pm_counters}

Start data ul traffic on three UEs in SA mode
    Start throughput on three ues  tput_type=SA_UL  tput1=20M   tput2=30M  tput3=40M  duration=10  logfile=iperf_multiple_ues.log

Verify multiple UEs counters
    ${pm_counters2}=  Wait for next pm interval and get counters
    Run keyword and continue on failure
    ...    Verify Last Counters In File
    ...    M55349C02001    38000-50000      MAX_UL_RLC_UE_TPUT
    ...    M55353C01001    28000-32000      UL_RLC_TIME_UE_TPUT_PMQAP
    ...    M55349C04001    28000-32000      UL_RLC_TIME_UE_TPUT
    ...    M55349C00006    28000-32000      UL_RLC_TIME_UE_TPUT_QOS_06
    ...    M55349C01006    880000-1000000   UL_RLC_VOL_UE_TPUT_QOS_06
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters2}

Verify other QoS time counters are not incremented based on ${file}
    Verify Last Counters In File
    ...    M55349C00001    0    UL_RLC_TIME_UE_TPUT_QOS_01
    ...    M55349C00002    0    UL_RLC_TIME_UE_TPUT_QOS_02
    ...    M55349C00003    0    UL_RLC_TIME_UE_TPUT_QOS_03
    ...    M55349C00004    0    UL_RLC_TIME_UE_TPUT_QOS_04
    ...    M55349C00005    0    UL_RLC_TIME_UE_TPUT_QOS_05
    ...    M55349C00007    0    UL_RLC_TIME_UE_TPUT_QOS_07
    ...    M55349C00008    0    UL_RLC_TIME_UE_TPUT_QOS_08
    ...    M55349C00009    0    UL_RLC_TIME_UE_TPUT_QOS_09
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
    ...    M55349C01007    0    UL_RLC_VOL_UE_TPUT_QOS_07
    ...    M55349C01008    0    UL_RLC_VOL_UE_TPUT_QOS_08
    ...    M55349C01009    0    UL_RLC_VOL_UE_TPUT_QOS_09
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
