*** Settings ***
Documentation    author:Liu Tiffany
...              contact: n5liu@nokia-sbell.com
...               feature : CB010636-CDE
Suite Setup        Run Keyword And Ignore Error       robot_common_operations.Common Suite Setup
Suite Teardown     Run Keyword And Ignore Error       robot_common_operations.Common Suite Teardown
Force Tags        CRT
Resource          ./Resources/CB010636_CDE.robot
Resource          ./Resources/CB010636_common_keywords.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Variables    ./Resources/BTS_info.py


*** Variables ***
${SSH_FSP}   FSP Conn
${package_web_service_SBTS}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
#counter
@{MAC_PM_LIST}                         M55309C00002    M55309C00003
&{COUNTER_INFO_MAC_577}              bts_id=${tl.gnbs[0].instance_id}    cell_id=1    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}    PCI=577
&{COUNTER_INFO_MAC_574}             bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}     PCI=574
&{COUNTER_INFO_MAC_575}             bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}     PCI=575
&{COUNTER_INFO_MAC_576}             bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NMSDU    counter_ids_list=${MAC_PM_LIST}     PCI=576
@{RLC_M55349_PM_LIST}                    M55349C03002    M55349C04002
...                               M55349C00026    M55349C00029    M55349C00027    M55349C00028    M55349C00030
...                               M55349C00032    M55349C00033    M55349C00034    M55349C00035    M55349C00036
...                               M55349C00046    M55349C00022    M55349C00023
&{COUNTER_INFO_RLC_M55349_577}         bts_id=${tl.gnbs[0].instance_id}    cell_id=1    MO_name=NHRRC
...      counter_ids_list=${RLC_M55349_PM_LIST}    PCI=577
&{COUNTER_INFO_RLC_M55349_574}        bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NHRRC
...      counter_ids_list=${RLC_M55349_PM_LIST}     PCI=574
&{COUNTER_INFO_RLC_M55349_575}        bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NHRRC
...      counter_ids_list=${RLC_M55349_PM_LIST}     PCI=575
&{COUNTER_INFO_RLC_M55349_576}        bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NHRRC
...      counter_ids_list=${RLC_M55349_PM_LIST}     PCI=576
#these counters is not in -C
@{RLC_M55310_PM_LIST}                    M55310C02021    M55310C02022    M55310C02024    M55310C20001
...                                      M55310C20000   M55310C01022    M55310C01021
&{COUNTER_INFO_RLC_M55310_577}         bts_id=${tl.gnbs[0].instance_id}    cell_id=1     MO_name=NLRLC
...      counter_ids_list=${RLC_M55310_PM_LIST}           PCI=577
&{COUNTER_INFO_RLC_M55310_576}        bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NLRLC
...      counter_ids_list=${RLC_M55310_PM_LIST}           PCI=574
&{COUNTER_INFO_RLC_M55310_575}        bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NLRLC
...      counter_ids_list=${RLC_M55310_PM_LIST}           PCI=575
&{COUNTER_INFO_RLC_M55310_574}        bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NLRLC
...          counter_ids_list=${RLC_M55310_PM_LIST}        PCI=576
#these counters is not in -C  ----end
@{RLC_PMQAP_PM_LIST}              M55353C00002    M55353C00003
&{COUNTER_INFO_PMQAP1_577}       bts_id=${tl.gnbs[0].instance_id}    cell_id=1    MO_name=NRPMQAP-5/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=577
&{COUNTER_INFO_PMQAP1_574}      bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NRPMQAP-5/HRLCQ
...     counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=574
&{COUNTER_INFO_PMQAP1_575}      bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NRPMQAP-5/HRLCQ
...     counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=575
&{COUNTER_INFO_PMQAP1_576}      bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NRPMQAP-5/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=576
&{COUNTER_INFO_PMQAP2_577}       bts_id=${tl.gnbs[0].instance_id}    cell_id=1    MO_name=NRPMQAP-7/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=577
&{COUNTER_INFO_PMQAP2_574}      bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NRPMQAP-7/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=574
&{COUNTER_INFO_PMQAP2_575}      bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NRPMQAP-7/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=575
&{COUNTER_INFO_PMQAP2_576}      bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NRPMQAP-7/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=576
&{COUNTER_INFO_PMQAP3_577}       bts_id=${tl.gnbs[0].instance_id}    cell_id=1    MO_name=NRPMQAP-8/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}     PCI=577
&{COUNTER_INFO_PMQAP3_574}      bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NRPMQAP-8/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=574
&{COUNTER_INFO_PMQAP3_575}      bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NRPMQAP-8/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=575
&{COUNTER_INFO_PMQAP3_576}      bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NRPMQAP-8/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=576
&{COUNTER_INFO_PMQAP4_577}       bts_id=${tl.gnbs[0].instance_id}    cell_id=1    MO_name=NRPMQAP-9/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}     PCI=577
&{COUNTER_INFO_PMQAP4_574}      bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NRPMQAP-9/HRLCQ
...      counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=574
&{COUNTER_INFO_PMQAP4_575}      bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NRPMQAP-9/HRLCQ
...     counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=575
&{COUNTER_INFO_PMQAP4_576}      bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NRPMQAP-9/HRLCQ
...     counter_ids_list=${RLC_PMQAP_PM_LIST}    PCI=576
##new add for -CDE
@{PDCP_PMQAP_PM_LIST}              M55352C01002    M55352C01003    M55352C01004    M55352C01005
&{COUNTER_PDCP_PMQAP1_577}       bts_id=${tl.gnbs[0].instance_id}    cell_id=1    MO_name=NRPMQAP-7/PDCPQ
...      counter_ids_list=${PDCP_PMQAP_PM_LIST}     PCI=577
&{COUNTER_PDCP_PMQAP1_574}      bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NRPMQAP-7/PDCPQ
...      counter_ids_list=${PDCP_PMQAP_PM_LIST}    PCI=574
&{COUNTER_PDCP_PMQAP1_575}      bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NRPMQAP-7/PDCPQ
...      counter_ids_list=${PDCP_PMQAP_PM_LIST}    PCI=575
&{COUNTER_PDCP_PMQAP1_576}      bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NRPMQAP-7/PDCPQ
...     counter_ids_list=${PDCP_PMQAP_PM_LIST}    PCI=576
&{COUNTER_PDCP_PMQAP2_577}       bts_id=${tl.gnbs[0].instance_id}    cell_id=1    MO_name=NRPMQAP-8/PDCPQ
...      counter_ids_list=${PDCP_PMQAP_PM_LIST}      PCI=577
&{COUNTER_PDCP_PMQAP2_574}      bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NRPMQAP-8/PDCPQ
...     counter_ids_list=${PDCP_PMQAP_PM_LIST}    PCI=574
&{COUNTER_PDCP_PMQAP2_575}      bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NRPMQAP-8/PDCPQ
...      counter_ids_list=${PDCP_PMQAP_PM_LIST}    PCI=575
&{COUNTER_PDCP_PMQAP2_576}      bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NRPMQAP-8/PDCPQ
...      counter_ids_list=${PDCP_PMQAP_PM_LIST}    PCI=576
&{COUNTER_PDCP_PMQAP3_577}       bts_id=${tl.gnbs[0].instance_id}    cell_id=1    MO_name=NRPMQAP-9/PDCPQ
...      counter_ids_list=${PDCP_PMQAP_PM_LIST}      PCI=577
&{COUNTER_PDCP_PMQAP3_574}      bts_id=${tl.gnbs[1].instance_id}    cell_id=1    MO_name=NRPMQAP-9/PDCPQ
...      counter_ids_list=${PDCP_PMQAP_PM_LIST}    PCI=574
&{COUNTER_PDCP_PMQAP3_575}      bts_id=${tl.gnbs[1].instance_id}    cell_id=2    MO_name=NRPMQAP-9/PDCPQ
...     counter_ids_list=${PDCP_PMQAP_PM_LIST}    PCI=575
&{COUNTER_PDCP_PMQAP3_576}      bts_id=${tl.gnbs[1].instance_id}    cell_id=3    MO_name=NRPMQAP-9/PDCPQ
...     counter_ids_list=${PDCP_PMQAP_PM_LIST}    PCI=576
##new add for -CDE end
@{PM_COUNTER_LIST}                M55309C00002   M55309C00003
...                               M55349C03002    M55349C04002
...                               M55353C00002    M55353C00003
...                               M55352C01002    M55352C01003    M55352C01004    M55352C01005
...                               M55349C00026    M55349C00029    M55349C00027    M55349C00028    M55349C00030
...                               M55349C00032    M55349C00033    M55349C00034    M55349C00035    M55349C00036
...                               M55349C00046    M55349C00022    M55349C00023
...                               M55310C02021    M55310C02022    M55310C02024    M55310C20001
...                               M55310C20000   M55310C01022    M55310C01021

@{MAC_COUNTER_INFO_LIST_577}          ${COUNTER_INFO_MAC_577}
@{RLCH_COUNTER_INFO_LIST_577}         ${COUNTER_INFO_RLC_M55349_577}
@{RLCL_COUNTER_INFO_LIST_577}         ${COUNTER_INFO_RLC_M55310_577}
@{MAC_COUNTER_INFO_LIST_Scell}          ${COUNTER_INFO_MAC_576}
...                                     ${COUNTER_INFO_MAC_575}    ${COUNTER_INFO_MAC_574}
@{RLCH_COUNTER_INFO_LIST_Scell}         ${COUNTER_INFO_RLC_M55349_576}
...                                     ${COUNTER_INFO_RLC_M55349_575}     ${COUNTER_INFO_RLC_M55349_574}
#these counters is not in -C
@{RLCL_COUNTER_INFO_LIST_Scell}         ${COUNTER_INFO_RLC_M55310_576}
...                                     ${COUNTER_INFO_RLC_M55310_575}     ${COUNTER_INFO_RLC_M55310_574}
#these counters is not in -C  ----end
@{RLC_PMQAP_COUNTER_INFO_LIST_577}    ${COUNTER_INFO_PMQAP1_577}     ${COUNTER_INFO_PMQAP2_577}
...                                     ${COUNTER_INFO_PMQAP3_577}    ${COUNTER_INFO_PMQAP4_577}
@{RLC_PMQAP_COUNTER_INFO_LIST_Scell}    ${COUNTER_INFO_PMQAP1_576}
...                                     ${COUNTER_INFO_PMQAP1_575}     ${COUNTER_INFO_PMQAP1_574}
...                                     ${COUNTER_INFO_PMQAP2_576}
...                                     ${COUNTER_INFO_PMQAP2_575}     ${COUNTER_INFO_PMQAP2_574}
...                                     ${COUNTER_INFO_PMQAP3_576}
...                                     ${COUNTER_INFO_PMQAP3_575}     ${COUNTER_INFO_PMQAP3_574}
...                                     ${COUNTER_INFO_PMQAP4_576}
...                                     ${COUNTER_INFO_PMQAP4_575}     ${COUNTER_INFO_PMQAP4_574}

@{PDCP_PMQAP_COUNTER_INFO_LIST_577}    ${COUNTER_PDCP_PMQAP1_577}     ${COUNTER_PDCP_PMQAP2_577}
...                                     ${COUNTER_PDCP_PMQAP3_577}
@{PDCP_PMQAP_COUNTER_INFO_LIST_Scell}    ${COUNTER_PDCP_PMQAP1_576}
...                                     ${COUNTER_PDCP_PMQAP1_575}     ${COUNTER_PDCP_PMQAP1_574}
...                                     ${COUNTER_PDCP_PMQAP2_576}
...                                     ${COUNTER_PDCP_PMQAP2_575}     ${COUNTER_PDCP_PMQAP2_574}
...                                     ${COUNTER_PDCP_PMQAP3_576}
...                                     ${COUNTER_PDCP_PMQAP3_575}     ${COUNTER_PDCP_PMQAP3_574}

${exp_gap}            0.012
${call_duration}      20

*** Test Cases ***
[1]CB010636_E_03_Online_activation_DL_MAC_SDU_throughput_PM_counters_both
    [Setup]    CB010636_common_keywords.Case Setup
    FOR    ${key}    IN      @{cell_info.keys()}
       ${PCI}    set Variable   ${key}
    END
    ${reportinterval}    set Variable   ${5}
    Set Suite Variable        ${reportinterval}
    #Check cell onair for 2 gNB
    Adjust One HBTE ATT Value    ${PA_Info1}
    Adjust One HBTE ATT Value    ${PA_Info2}
    Start DCAP Collection
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    #Test Scenario1_2UE_MultiDRB
    Test Scenario2_1UE_1DRB    reportinterval=${reportinterval}
    ...      data_tranfer=700Mbits/sec      call_duration=20
    #Run keyword and ignore error    Check 4CC DLUL tput
    Run Keyword And Continue On Failure     Get logs file from DCAP
    ${Cell_RLC_Counter_dic}    ${Cell_Mac_Counter_dic}    Run Keyword And Continue On Failure
    ...    Get Counter from TTI    TTI_CSV_merged=${TTI_CSV_merged}
    ...    Emil_CSV_merged=${Emil_CSV_merged}     cell_info=${cell_info}
    Run Keyword And Continue On Failure       Calculate Wait Time For PM counter Update In WebEM
    ...      ${newest_timestamp_epoch_end}
    Run Keyword And Continue On Failure     Get Multi Cells Multi PM Counters value for CB010636-ACDE
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Ignore error     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.3      Delete_old_ERR_WRN=1
    ...       Fail_Case=False       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    Run keyword and ignore error     Check CB010636-A Counter
    Run Keyword And Continue On Failure     Check CB010636-CDE Counter
    #Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    [Teardown]        run keywords     Run Keyword And Ignore error    CB010636_common_keywords.Case Teardown
    ...        AND    run keyword and ignore error     wait until keyword succeeds      10x   1min
    ...        WEBUI.Collect snapshot
*** Keywords ***
