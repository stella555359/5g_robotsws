*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[MP][MP]_AP_[LOOO]
...    team-VRF3_6        release-SBTS24R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${cfg}    wts.cfg
${rdSrsCodebookAndTas}    0x590103
${rdPriorSrsForDlBm}    0x590104
${rdEnableSym13ForCBSrs}    0x590223
${rdEnableMainSBSrsPool}    0x590224
${rdEnableOneCBSrsUePerSymbol}    0x590225
${rdSrsSymPolicy}    0x590244
@{PARAMS_IN_SWCONFIG}
...    ${rdEnableSym13ForCBSrs}=1
...    ${rdEnableMainSBSrsPool}=1
...    ${rdEnableOneCBSrsUePerSymbol}=0
...    ${rdSrsSymPolicy}=2

@{PARAMS_IN_SWCONFIG_GNB2}
...    ${rdEnableSym13ForCBSrs}=0
...    ${rdEnableMainSBSrsPool}=1
...    ${rdEnableOneCBSrsUePerSymbol}=1
...    ${rdSrsSymPolicy}=2

@{PARAMS_IN_VENDOR_GNB2}
...    actEcpri72e=Ecpri72eUL    betaEc=13    xEc=14

@{ue1_srs_checkpoint}
...    usage codebook
...    usage antennaSwitching
...    nrofSRS-Ports ports2
...    periodicityAndOffset-p sl40
...    srs-ResourceId 4

@{ue2_srs_checkpoint}
...    usage codebook
...    usage antennaSwitching
...    nrofSRS-Ports ports2
...    periodicityAndOffset-p sl40
...    srs-ResourceId 2

*** Test Cases ***
CB010887-ET-D011_72a_HO_RRE_1116_3_2sym
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:  gNB shall allocates 2 SRS symbols per special slot concurrently.
    ...    2. Test Case Steps:
    ...        1.UE register and attach to gnb 2 cell 1 .(7_2a)
    ...        2.UE HO to gnb3 cell2 .(7_2e)
    ...        3.Trigger RRE on gnb3 cell2 .
    ...        4.Trigger RRE to gnb2 cell1 .
    ...        5.UE HO to gnb3 cell2 .(7_2e)
    [Tags]    QC_364090    D011
    SA UE attach    ue_id=1    cell_id=1    enb_id=2    pass_regexp=Initial Context Setup Successful
    Inter Freq HO    phycell_id=51    ue_id=1    pass_regexp=${ue1_srs_checkpoint}
    IntraGNB Reestablish    ue_id=1    enb_id=3    cell_id=2    pass_regexp=${ue1_srs_checkpoint}
    InterGNB Reestablish    ue_id=1    enb_id=2    cell_id=1    pass_regexp=rrcReconfigurationComplete
    Inter Freq HO    phycell_id=51    ue_id=1    pass_regexp=${ue1_srs_checkpoint}

CB010887-ET-D012_72a_HO_RRE_1116_3_2sym
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:  gNB shall allocates 2 SRS symbols per special slot concurrently.
    ...    2. Test Case Steps:
    ...        1.UE register and attach to gnb 2 cell 1 .(7_2a)
    ...        2.UE HO to gnb3 cell2 .(7_2e)
    ...        3.Trigger RRE on gnb3 cell2 .
    ...        4.Trigger RRE to gnb2 cell1 .
    ...        5.UE HO to gnb3 cell2 .(7_2e)
    [Tags]    QC_364089    D012
    SA UE attach    ue_id=2    cell_id=1    enb_id=2    pass_regexp=Initial Context Setup Successful
    Inter Freq HO    phycell_id=51    ue_id=2    pass_regexp=${ue2_srs_checkpoint}
    IntraGNB Reestablish    ue_id=2    enb_id=3    cell_id=2    pass_regexp=${ue2_srs_checkpoint}
    InterGNB Reestablish    ue_id=2    enb_id=2    cell_id=1    pass_regexp=rrcReconfigurationComplete
    Inter Freq HO    phycell_id=51    ue_id=2    pass_regexp=${ue2_srs_checkpoint}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Install eNB Package via WEBEM
    Install eNB Package via WEBEM In GNB2
    Setup 2Airphone Env    tdd_sansa_cmwv/1T_gnb1_7_2a_1T_gnb2_7_2e    cfg=${cfg}    ue_count=2

UE attach and trigger HO bwt 2gnb
    FOR    ${I}    IN RANGE    1    3
        SA UE attach    ue_id=${I}    cell_id=1    enb_id=2
        Inter Freq HO    phycell_id=51    ue_id=${I}
        IntraGNB Reestablish    ue_id=${I}    enb_id=3    cell_id=2
        InterGNB Reestablish    ue_id=${I}    enb_id=2    cell_id=1
        Inter Freq HO    phycell_id=51    ue_id=${I}
        Release Ues    ue=all
        sleep    1min
    END


SA UE attach
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${enb_id}=2    ${pass_regexp}=EMPTY
    Log to console    -----UE${ue_id} register UE----
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=${enb_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registered state.
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 gw=1 ue=${ue_id} nwslice=1    pass_regexp=${pass_regexp}
    Send And Verify Throuput    ue_id=${ue_id}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=1 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=1 trf_id=1    UE ${ue_id}: UDP UL
    wait until keyword succeeds    2min    10s    Verify Throughput    ue_id=${ue_id}

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=63    ${Tput_ul}=9.5    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    log to console    UE${ue_id} dl: ${dl_throughput}
    log to console    UE${ue_id} ul: ${ul_throughput}

Inter Freq HO
    [Arguments]    ${phycell_id}=51    ${ue_id}=1    ${pass_regexp}=rrcReconfigurationComplete    ${carrierfreq1}=655008    ${carrierfreq2}=636576
    log to console    -----UE${ue_id} start Handover ------
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq1}    event_type=A2
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${meas_id} srsrp_nr=5 srsrq_nr=5
    ${meas_id2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq2}    event_type=A3
    ${ret2}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id2} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=${pass_regexp}
    wait until keyword succeeds    2min    10s    Verify Throughput    ue_id=${ue_id}

IntraGNB Reestablish
    [Arguments]    ${ue_id}    ${enb_id}=3    ${cell_id}=2    ${pass_regexp}=NR RRC Reestablishment sucessfully completed
    log to console    -----UE${ue_id} start RRE to ${enb_id}.${cell_id}------
    ${ret1}=    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=${enb_id} cell=${cell_id} cause=reconfigurationFailure
    ...    pass_regexp=${pass_regexp}    timeout=20s
    wait until keyword succeeds    2min    10s    Verify Throughput    ue_id=${ue_id}

InterGNB Reestablish
    [Arguments]    ${ue_id}    ${enb_id}=3    ${cell_id}=2    ${phycell_id}=50
    ...    ${carrierfreq1}=636576    ${carrierfreq2}=655008    ${pass_regexp}=rrcReconfigurationComplete
    log to console    -----UE${ue_id} start RRE to ${enb_id}.${cell_id}------
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq1}    event_type=A2
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${meas_id} srsrp_nr=5 srsrq_nr=5
    ${cmd}    Catenate    ue_nr_rrc_reconf_param id=${ue_id} if_contains=reconfiguration_with_sync action=reestablish cause=otherFailure
    ...    cell=${cell_id} gnb=${enb_id} crnti=source
    Execute Egate Command    ${cmd}
    ${meas_id2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq2}    event_type=A3
    ${ret2}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id2} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=${pass_regexp}
    wait until keyword succeeds    2min    10s    Verify Throughput    ue_id=${ue_id}

Install eNB Package via WEBEM
    [Arguments]    ${bsr_name}=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip    ${bsr_path}=/home/ute/bsr_package
    Execute Cmd On Pc    rm -rf ${bsr_path}
    Execute Cmd On Pc    mkdir ${bsr_path}
    Execute Cmd On Pc    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git ${bsr_path}
    update_software    sw_package=${bsr_path}/BSR_FILE/${bsr_name}    timeout=60

Install eNB Package via WEBEM In GNB2
    [Arguments]    ${bsr_path}=/home/ute/bsr_package    ${bsr_name}=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
    set suite variable    ${GNB2_PC_IP}    ${tl.test_pcs[1].default_ssh_connection_details.addr}
    Execute Cmd On Pc Gnb2    rm -rf /home/ute/bsr_package/
    Execute Cmd On Pc Gnb2    mkdir ${bsr_path}
    Execute Cmd On Pc Gnb2    git clone https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git ${bsr_path}
    ${bts_port}    ${use_ssl}    Define Admin Port
    Setup Admin    bts_port=${bts_port}    use_ssl=${use_ssl}    admin_api_log_dir=${SAVE LOG DIRECTORY}/gnb2/admin_logs
    ...    timeout=120    remote_host=${GNB2_PC_IP}    alias=${GNB2_ALIAS}
    update_software    sw_package=${bsr_path}/BSR_FILE/${bsr_name}    alias=${GNB2_ALIAS}    timeout=20

