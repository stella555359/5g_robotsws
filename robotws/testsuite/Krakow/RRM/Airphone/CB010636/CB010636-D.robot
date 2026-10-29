*** Settings ***
Documentation
...   author: Anna Bien, Przemysław Herian, Kamil Pokusa
...   maintainer: Anna Bien, Przemysław Herian, Kamil Pokusa
...   contact: anna.bien@nokia.com

Resource    resources/CB010636_resources.robot

Suite Setup      Suite Setup
Test Setup       Test Setup
Test Teardown    Test Teardown

*** Test Cases ***
CB010636-SR-D-B101_01_BWP_added_to_the_HiUserDu_BearerSetupReq_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_D_B101_01}
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${D_B101_01_UE_CFG_1}
    #1 Strat bursty trafficues_conf=${D_B101_01_UE_CFG}
    #2 Check if the value of the BWP is added to the HiUserDu_BearerSetupReq in the syscom captured message

CB010636-SR-D-B102_01_L2HI_counters_for_UE_throughput_per_Mhz_BW_in_intra_CA_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_D_B102_01}
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${D_B102_01_UE_CFG}
    #1 Attach UE ${D_B102_01_UE_CFG}
    #1 Strat bursty trafficues_conf=${D_B102_01_UE_CFG}
    #2 Check following counters. TTI traces will be helpful.

CB010636-SR-D-B103_01_L2HI_counters_for_UE_throughput_per_Mhz_BW_in_inter_CA_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_D_B103_01}
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${D_B103_01_UE_CFG}
    #1 Strat bursty trafficues_conf=${D_B103_01_UE_CFG}
    #2 Check following counters. TTI traces will be helpful.

CB010636-SR-D-B104_01_Update_counters_for_UE_throughput_per_Mhz_BW_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_D_B104_01}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach Multiple SA UEs And Establish Pdu Session
    ...    ues_conf=${D_B104_01_UE_CFG}
    _wts.Define Pdu Session Modification
    ...    pdu_modify_info=${D_B104_01_UE_CFG_PDU_MODIFICATION_01}
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=31   bearer=2    cell_id=12    enb_id=2
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=32    bearer=2    cell_id=1    enb_id=2
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=33    bearer=2    cell_id=4    enb_id=2
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${D_B104_01_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    5
    _wts.Stop Traffic
    ...    number_of_ues=${6}
    ...    first_ue_id=${1}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${2}
    ...    first_ue_id=${7}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${5}
    ...    first_ue_id=${2}
    ...    net_arch=sa
    ...    qfi=2
    _wts.Stop Traffic
    ...    number_of_ues=${3}
    ...    first_ue_id=${31}
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    5
    _wts.Deregister Ues
    ...   sa_ues=1,2,3,4,5,6,7,8
    ...   nsa_ues=31,32,33
    _logs.Stop TTI Traces Collection
    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1

CB010636-SR-D-B104_02_Update_counters_for_UE_throughput_per_Mhz_BW_inter_CA_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_D_B104_02_GNB1}    ${DELTA_D_B104_02_GNB2}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _wts.Attach Multiple Sa Ues And Establish Pdu Session    ${D_B104_02_UE_CFG}
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=11    bearer=2    cell_id=8    enb_id=3
    _wts.Wait For Traffic Running    10
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=12    bearer=2    cell_id=7    enb_id=3
    _wts.Wait For Traffic Running    10
    _wts.Define Pdu Session Modification    ${D_B104_02_UE_CFG_PDU_MODIFICATION}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection    provided_gnb1_ip=10.0.1.2    provided_gnb2_ip=10.0.1.3
    _wts.Start Traffic Multiple Ues    ${D_B104_02_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    40
    _logs.Stop TTI Traces Collection    provided_gnb1_ip=10.0.1.2    provided_gnb2_ip=10.0.1.3
    ${pm_counters_filepath}=    _logs.Download Counters Reports
    Extract CSV From TTI Trace
    _validation.Validate PM Counters

CB010636-SR-D-B104_03_Update_counters_for_UE_throughput_per_Mhz_BW_multiple_bursts_FR1
    [Setup]    Test Setup    ${DELTA_D_B104_03}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    _wts.Attach Multiple SA UEs And Establish Pdu Session
    ...    ues_conf=${D_B104_03_UE_CFG}
    _wts.Define Pdu Session Modification
    ...    pdu_modify_info=${D_B104_03_UE_CFG_PDU_MODIFICATION_01}
    _wts.Attach Nsa Ue And Perform Sgnb Addition
    ...    ue_id=102    bearer=2    cell_id=3    enb_id=2
    _wts.Wait For Traffic Running    10
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${D_B104_03_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    10
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${4}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${3}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${102}
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    5
    _wts.Start Traffic Multiple Ues
    ...    ues_conf=${D_B104_03_UE_CFG_TRAFFIC}
    _wts.Wait For Traffic Running    10
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${4}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${3}
    ...    net_arch=sa
    ...    qfi=1
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${102}
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    5
    _wts.Deregister Ues
    ...   sa_ues=3,4
    ...   nsa_ues=102
    _logs.Stop TTI Traces Collection    provided_gnb1_ip=10.0.1.2
    ${pcapfilepath}    _logs.Download Counters Reports
    Extract Csv From TTI Trace
    _validation.Validate PM Counters
    ...    direct_pm_counters_path=${pcapfilepath}

CB010636-SR-D-B104_04_Update_counters_for_UE_throughput_per_Mhz_BW_inter_CA_discard_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_D_B104_04_GNB1}    ${DELTA_D_B104_04_GNB2}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=1
    ...    cell_id=1
    ...    enb_id=2
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=9
    ...    cell_id=2
    ...    enb_id=2
    _wts.Attach NSA UE And Perform SgNB Addition
    ...    ue_id=11
    ...    cell_id=8
    ...    enb_id=3
    _wts.Define Pdu Session Modification    ${D_B104_04_UE_CFG_PDU_MODIFICATION}
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    first_ue_id=1
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    first_ue_id=9
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    first_ue_id=11
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    5
    _wts.Get UE Throughput Stats
    ...    ue_id=1
    _wts.Get UE Throughput Stats
    ...    ue_id=11
    _wts.Get UE Throughput Stats
    ...    ue_id=9
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${1}
    ...    net_arch=sa
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${9}
    ...    net_arch=sa
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${11}
    ...    net_arch=nsa
    _wts.Deregister Ues
    ...   sa_ues=1,9
    ...   nsa_ues=11
    _wts.Wait For Traffic Running    5
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_1
    _logs.Download Counters Reports
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_1_gnb1.zip
    ...    tti_trace_filename_gnb2=utf_lab_1_gnb2.zip
    _logs.Stop Collecting Syslog And Download Files
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1
    _logs.Start Collecting Syslog
    _env.Perform Delta Recommissioning
    ...    delta_path_gnb1=${DELTA_D_B104_04_GNB1_STEP_2}
    ...    delta_path_gnb2=${DELTA_D_B104_04_GNB2_STEP_2}
    ta5g_pm_counters.Wait For Next Full PM Interval
    _logs.Start TTI Traces Collection
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=1
    ...    cell_id=1
    ...    enb_id=2
    _wts.Attach SA UE And Establish PDU Session
    ...    ue_id=9
    ...    cell_id=2
    ...    enb_id=2
    _wts.Attach NSA UE And Perform SgNB Addition
    ...    ue_id=11
    ...    cell_id=8
    ...    enb_id=3
    _wts.Define Pdu Session Modification    ${D_B104_04_UE_CFG_PDU_MODIFICATION}
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    first_ue_id=1
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    first_ue_id=9
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    common_wts.Start Traffic For Multiple UEs
    ...    number_of_ues=1
    ...    first_ue_id=11
    ...    traffic_direction=bi
    ...    ul_mbps=80
    ...    dl_mbps=100
    ...    net_arch=nsa
    _wts.Wait For Traffic Running    5
    _wts.Get UE Throughput Stats
    ...    ue_id=1
    _wts.Get UE Throughput Stats
    ...    ue_id=11
    _wts.Get UE Throughput Stats
    ...    ue_id=9
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${1}
    ...    net_arch=sa
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${9}
    ...    net_arch=sa
    _wts.Stop Traffic
    ...    number_of_ues=${1}
    ...    first_ue_id=${11}
    ...    net_arch=nsa
    _wts.Deregister Ues
    ...   sa_ues=1,9
    ...   nsa_ues=11
    _wts.Wait For Traffic Running    5
    _logs.Stop TTI Traces Collection
    ...    filename_prefix=utf_lab_2
    _logs.Download Counters Reports
    _logs.Extract CSV From TTI Trace
    ...    tti_trace_filename_gnb1=utf_lab_2_gnb1.zip
    ...    tti_trace_filename_gnb2=utf_lab_2_gnb2.zip
    _logs.Stop Collecting Syslog And Download Files
    _validation.Validate PM Counters
    ...    suffix=PM_COUNTERS_1

CB010636-SR-D-B104_05_Update_counters_for_UE_throughput_per_Mhz_BW_inter_CA_robustness_SANSA_FR1
    [Setup]    Test Setup    ${DELTA_D_B104_05}
    _wts.Register Multiple UEs And Handle Traffic
    ...    ues_conf=${D_B104_05_UE_CFG}
    #2 Strat bursty trafficues_conf=${D_B104_05_UE_CFG}
    #3 Release UEs. Wait next PM period and repeat steps 1 and 2
    ta5g_pm_counters.Wait For Next Full PM Interval
    #perform several times UE attach and detach with and without traffic. Try to add high traffic. Release some scells.
