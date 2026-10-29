*** Settings ***

Documentation   :copyright: Nokia
    ...             :author   : Pradeep Kumar K L
    ...             :contact  : pradeep.kumar_k_l@nokia.com
    ...             The aim of the feature is to verify the V17 version of ORAN suported radio functionality along with
    ...             Backward compatibilty of V12 and V7.
    ...             Testing steps: 1. Bring the 3 cells on air with V17,V12,V7 ORUs.
    ...                            2. Attach the UE and start the data traffic and verify.

Library    OperatingSystem    WITH NAME     os
Library    taf.ul.sc.perf.testline.TestLineLoader
Library    taf.ul.sc.uesim.cus.Executor
Library    taf.sbts.oam.coam.admin
Library    taf.selenium.sbts    WITH NAME    sbts
Library    DateTime
Library    ta_uexgate
Library    taf.file.pack
Library    taf.ul.ue.sim.env_setup
Library    ta5g_throughput
Library    OperatingSystem
Library    taf.sw.wtssim
Library    Collections
Library    taf.sw.reporting_portal
Library    ute_wtssim
Library    ute_common_store
Library    BuiltIn
Library    String

Resource    ../CB014100/resources/CB014100_keyword.robot
Library     ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library     ./testsuite/Bangalore/ORAN/T11/CB014100/resources/test_cus.py
Library     ./testsuite/Bangalore/ORAN/T11/CB014100/resources/cus_executor_commands.py
Resource    ./testsuite/Bangalore/ORAN/T11/resources/Reporting_Portal_Keywords.robot

Suite Setup       Suite setup
Force Tags    CLOUD_MOPQ_CUS_LOOO    CUS_ORAN     SBTS00

*** Variables ***
${config_catalog}                  ${CURDIR}/resources
${coco1_yaml}                       ${CURDIR}/config/coco_CB014100_lte_v17_v12_v7.yaml
${scf1_xml}                         ${CURDIR}/config/SBTS/scf_CB014100_lte_V17_V12_v7.xml
${WEBUI_URL}                       https://192.168.255.129
${WEBUI_NAME}                      Nemuadmin
${WEBUI_PWD}                       nemuuser
${REDUCE_S1_RECONNECTION_TIME}=    0x0015001B=15
@{swconfig_flags}=                 0x340000 = 5
${local_cell_id_1}=                DN:NE-LNBTS-1/LNCEL-1/MCC-244/MNC-08
@{sudo_list}=                      &{authentication}
${snapshotfilename}=               Snapshot.zip
${snapshottimeout}=                400s
${snapshotfilename_unzip}          Snapshot_unzipped
&{authentication}                  id=1    defaultNetconfAccount=&{default_user}
&{default_user}=                   defaultNetconfAccountName=xranuser
...                                defaultNetconfAccountPwd=xran-password
${BTS_path}=                       /home/ute/logs/CB014100
@{swconfig_flags2}=                 ${REDUCE_S1_RECONNECTION_TIME}
${expected_dl_tput}                150
${expected_ul_tput}                65
${margin}                          2
${expected_tcp_dl_tput}            8
${expected_tcp_ul_tput}            8
#${EXPECTED_TPUT_DL}          200
#${EXPECTED_TPUT_UL}          80
*** Test Cases ***
CB014100_TC7_SR_BackwardCompat_LTE_CUS_V17_V12_V7_CUS
    Testline reconfiguration for ORAN     ${scf1_xml}     ${coco1_yaml}    @{swconfig_flags}
	Get ActiveAlarms
    Sleep     10s
    Attach 3UEs with capabilities
    start udp data traffic for all UEs
    Sleep    5s
    Check UDP Tput For UEs
    stop the data traffic for all UEs
    start tcp data traffic for all UEs
    Sleep    5s
    Check TCP Tput For UEs
    stop the data traffic for all UEs
    detach UE
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
start udp data traffic for all UEs
     Run Uex command   trf_data_start ue=1 dir=dl_and_ul protocol=udp Mbps_dl=400 Mbps_ul=200 stats=true trf_id=1
     Run Uex command   trf_data_start ue=2 dir=dl_and_ul protocol=udp Mbps_dl=400 Mbps_ul=200 stats=true trf_id=2
     Run Uex command   trf_data_start ue=3 dir=dl_and_ul protocol=udp Mbps_dl=400 Mbps_ul=200 stats=true trf_id=3

start tcp data traffic for all UEs
     Run Uex command   trf_data_start ue=1 dir=dl_and_ul protocol=tcp Mbps_dl=10 Mbps_ul=10 stats=true trf_id=1
     Run Uex command   trf_data_start ue=2 dir=dl_and_ul protocol=tcp Mbps_dl=10 Mbps_ul=10 stats=true trf_id=2
     Run Uex command   trf_data_start ue=3 dir=dl_and_ul protocol=tcp Mbps_dl=10 Mbps_ul=10 stats=true trf_id=3

Check UDP Tput For UEs
    Observed DL Throughput For UE_1
    Observed UL Throughput For UE_1
    Verify UDP Tputs
    Observed DL Throughput For UE_2
    Observed UL Throughput For UE_2
    Verify UDP Tputs
    Observed DL Throughput For UE_3
    Observed UL Throughput For UE_3
    Verify UDP Tputs

Check TCP Tput For UEs
    Observed DL Throughput For UE_1
    Observed UL Throughput For UE_1
    Verify TCP Tputs
    Observed DL Throughput For UE_2
    Observed UL Throughput For UE_2
    Verify TCP Tputs
    Observed DL Throughput For UE_3
    Observed UL Throughput For UE_3
    Verify TCP Tputs

stop the data traffic for all UEs
     Run Uex command    trf_data_stop ue=1..3

Observed DL Throughput For UE_${UE_ID}
    ${dltp}=      Get tput for cell      ${UE_ID}    dl_mac    Mbps    max
    Set Test Variable        ${Observed_DL_Tput}           ${dltp}

Observed UL Throughput For UE_${UE_ID}
    ${ultp}=      Get tput for cell       ${UE_ID}    ul_mac    Mbps    max
    Set Test Variable        ${Observed_UL_Tput}           ${ultp}

Get tput for cell
    [Arguments]      ${cell_id}    ${dir}    ${unit}      ${output_type}
    ${trf_stats}=  Run UEx command  get_cell_stats   id=${cell_id}    type=${dir}  unit=${unit}
    ${tput_cell}=  Get From Dictionary  ${trf_stats}  ${output_type}
#    ${tput_overall}=    get from dictionary    ${tput_ue}     ${output_type}
    [Return]  ${tput_cell}

Verify UDP Tputs
    Run Keyword And Continue On Failure    Should be True       ${Observed_DL_Tput}+${margin}>=${expected_dl_tput}
    Run Keyword And Continue On Failure    Should be True       ${Observed_UL_Tput}+${margin}>=${expected_ul_tput}

Verify TCP Tputs
    Run Keyword And Continue On Failure    Should be True       ${Observed_DL_Tput}+${margin}>=${expected_tcp_dl_tput}
    Run Keyword And Continue On Failure    Should be True       ${Observed_UL_Tput}+${margin}>=${expected_tcp_ul_tput}

Check Tput For UE
    Run UEx command  get_cell_stats  id=1  type=dl_mac  unit=Mbps
    Run Keyword And Continue On Failure      Expected Throughput For Cell Should Be Reached
    ...    cell_id=1
    ...    throughput=${EXPECTED_TPUT_DL}
    ...    direction=dl
    ...    selection_type=current
    ...    layer=mac
    ...    margin=1

    Run UEx command  get_cell_stats  id=1  type=ul_mac  unit=Mbps
    Run Keyword And Continue On Failure      expected_throughput_for_cell_should_be_reached
    ...    cell_id=1
    ...    throughput=${EXPECTED_TPUT_UL}
    ...    direction=ul
    ...    selection_type=maximum
    ...    layer=mac
    ...    margin=1

Attach 3UEs with capabilities
    Set capabilities for UE1
    Run Uex command      ue_attach     id=1 cell=1
    Set capabilities for UE2
    Run Uex command      ue_attach     id=2 cell=2
    Set capabilities for UE3
    Run Uex command      ue_attach     id=3 cell=3

Set capabilities for UE${ue_id:\d+}
    Run UEx command    ue_param
    ...                id=${ue_id}
    ...                release=15
    ...                category=12
    ...                supported_bands=1:false,2:false,3:false,4:false
    ...                ca_supported_bands=1:a:a-4|2:a:a-4|3:a:a-4|4:a:a-4
    ...                category_dl=17
    ...                category_ul=14
    ...                dl_256QAM_supported=on
    ...                ul_64QAM_supported=on
    ...                freq_gaps=true
    ...                four_layer=on
    ...                dl_256QAM_supported=on
    ...                supported_ul256qam=all

detach UE
    Run Uex command   ue_detach   all
