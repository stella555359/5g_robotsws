*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD

Documentation
...
...             author:            Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...             maintainer:        Kiran Vilas Gawade, kiran.vilas_gawade@nokia.com
...
...             INTRODUCTION:     This testcase describes RAN Paging for the UEs in RRC_INACTIVE state for
...                               DL user plane data arrival from UPF. Failure scenario
...             TEST SET NAME:    Use case of the Test case is to verify Failure RAN Paging due to RAN-Paging guard timer
...                         NRBTS.tRanPagingGuard expires at gNBs CU-CP for RRC Inactive mode UE and UE should ignore paging
...             TESTING SPLIT:    See CB008225 testplan split C
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008225 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_18056

Resource         resources/CB008225_resource.robot
Library    taf.rfrl.utilities.utf_lab.ute_utf_lab.UteUtfLab  WITH NAME  ute_utf_lab
Library        SSHLibrary

Suite Setup         Run keywords    Suite setup from scratch
...                 AND          download_scf     ./
...                 AND     Update bsr package
...                 AND    Add RadParam to swconfig     "0x890073=0"      IP=192.168.255.129
...                 AND     sleep   6
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.101/24 dev eth3
...                 AND     sleep    6
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
...                 AND     sleep    6

Suite Teardown      Run Keywords
...                 Sleep   1s
...                 AND     Kill WTS processes Using WTS_Runner

*** Variables ***
${NOKIA_LOGIN}    toor4nsn
${NOKIA_PASS}     oZPS0POrRieRtu
${IPHY_FILE6}        ${CURDIR}/config/wts/CB008954_A_B_4_IPHY.xml
${wts_cfg_file6}     ${CURDIR}/config/wts/basic_setup_fdd.cfg
${initial_location_bwp}     14026
${r&d_parameter}    0x890073=0
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_2CC_gLN-apLO_tdd_ref.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TEST_NAME}        test_case
${split}     C
${start_ue_id}      ${1}
${end_ue_id}      ${3}
${delta}       30
${tp_duration}      40
${inactivity_timer}      100
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       5            #5QI 3
@{QOS_Prof2_speed_dl}      1       5
@{QOS_Prof2_speed_ul}      1       5
@{QOS_Prof2_unit}          mbps     mbps

@{QOS_Prof3}               1        6            #5QI 4
@{QOS_Prof3_speed_dl}      1        30
@{QOS_Prof3_speed_ul}      1        30
@{QOS_Prof3_unit}          mbps     mbps

@{QOS_Prof4}               1      2       3                            #5QI 1
@{QOS_Prof4_speed_dl}      1      32      amr_wb_18_25
@{QOS_Prof4_speed_ul}      1      32      amr_wb_18_25
@{QOS_Prof4_unit}          mbps   kbps    rtp_codec

${duration}      60
${trf_id}      ${1}
${scffile_name}     Delta_config_Inact_based_drblevel_Subscriber_trace_gLO_apLO_FDD.json
${scf_file_path}    ${CURDIR}/config/SBTS25R3

*** Test Cases ***

[1] CB008225_C_E1_10 Failure RAN Paging for UE in RRC Inactive State - DL User Plane data from UPF_5QI6_TDD_LN

    Perform SCF Delta Commissioning with Delta_Config_NonRANsha_InactBased-Uelevel_gLN-apLO_TDD.json
    sleep    180
    gnb.Perform gNB reboot
    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}


    set test variable      ${LOG_PATH}
#   Cb3_5
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof2}             ${3}=${QOS_Prof3}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof2_speed_ul}    ${3}=${QOS_Prof3_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof2_speed_dl}    ${3}=${QOS_Prof3_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof2_unit}        ${3}=${QOS_Prof3_unit}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on                       ${3}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=inactive                  ${3}=inactive
    ${trigger}       Create Dictionary                  ${1}=dldata_ranpaging                ${2}=dldata_ranpaging                ${3}=data_ranpaging

    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts  additional_time=${0}
    Start Log      btslog     cprt
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp      ${start_ue_id}    ${end_ue_id}     ${qos_profile}     state=${state}
    ${tp_read}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    Trigger DL Data split-C       ${start_ue_id}       ${end_ue_id}        ${state}
    ${scen1}     Stop Log      btslog     cprt
    sleep   300s
    Wait until the current Measurement Period stops  additional_time=${0}
    Get Paging counters and validate       M55331C00004     M55124C00007     M55306C06002     value_expected=3      cellid=1
    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
    ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    MultiUE Deregister should be Successful   ${start_ue_id}    ${end_ue_id}
#C_e1_10
    Start Log      btslog     cprt
    ${ue_to_bearer_list}       MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp     ${start_ue_id}    ${end_ue_id}    ${qos_profile}     state=${state}
    ${tp_read}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Set ignore paging        ${start_ue_id}    ${end_ue_id}

    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    Trigger DL Data split-C        ${start_ue_id}       ${end_ue_id}        ${state}
    Check Paging Response from egate     ${start_ue_id}    ${end_ue_id}     ${state}
    ${scen1}     Stop Log      btslog     cprt

    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
    ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap       ${start_ue_id}      ${end_ue_id}
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       ${split}        activityNotify=uE
     MultiUE Deregister should be Successful   ${start_ue_id}    ${end_ue_id}
# b_b2_8
    set test variable      ${LOG_PATH}
    Wait until the next Measurement Period starts  additional_time=${0}
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof1}             ${3}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof1_speed_ul}    ${3}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof1_speed_dl}    ${3}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof1_unit}        ${3}=${QOS_Prof1_unit}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on                       ${3}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=inactive                  ${3}=inactive

    Start Log      btslog     cprt
    ${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}

    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s

    ${tp_read}        Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}       gbr_chk=1

    sleep   5s

    ${full_rnti_list}        Set UE Assistance info and Verify UE state    ${start_ue_id}    ${end_ue_id}   uai_state=inactive
    ${scen1}     Stop Log      btslog     cprt

    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap       ${start_ue_id}      ${end_ue_id}
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       activityNotify=dRB       uai_set=true
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1] CB008225_J_B06_2 Verify Subscriber and Equipment Trace during Fallback to RRC Setup procedure_5QI6_FDD_LO
    ${qos_profile}               Create Dictionary   ${51}=${QOS_Prof1}                ${52}=${QOS_Prof1}             ${53}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${51}=${QOS_Prof1_speed_ul}       ${52}=${QOS_Prof1_speed_ul}    ${53}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${51}=${QOS_Prof1_speed_dl}       ${52}=${QOS_Prof1_speed_dl}    ${53}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${51}=${QOS_Prof1_unit}           ${52}=${QOS_Prof1_unit}        ${53}=${QOS_Prof1_speed_dl}
    ${cnai}                  Create Dictionary           ${51}=on                     ${52}=on                       ${53}=on
    ${state}                  Create Dictionary          ${51}=inactive               ${52}=inactive                  ${3}=inactive
    ${trigger}             Create Dictionary             ${51}=dldata_ranpaging		${52}=dldata_ranpaging	${53}=dldata_ranpaging
	${state1}			Create Dictionary          ${51}=active               ${52}=active                  ${53}=active

    Set Global Variable     ${wts_cfg_file2}      ${CURDIR}/config/wts/j_b6_2_basic_setup.cfg
    Set Global Variable     ${start_ue_id}      ${51}
    Set Global Variable     ${end_ue_id}      ${51}

    upload_scf      ./def_scf.xml
    sleep    300
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
	Update_tce_ip_in_delta_file     ${scf_file_path}/${scffile_name}
    Perform SCF Delta Commissioning with Delta_config_Inact_based_drblevel_Subscriber_trace_gLO_apLO_FDD.json
    sleep    180
    ute_utf_lab.Update Utf Lab
    Initiate Dcap
    Add routes
    gnb.Perform gNB reboot
    Sleep   500s    reason=wait for RMOD to comeup
    Start WTS Using WTS_Runner      ${wts_cfg_file2}
    sleep  180s   reason=wait for mib sib
#    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    DCAP Connect To gNB


    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

    Start_Dcap_Ipcapture
#    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting

    ${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
	...			subscriber_trace=True
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
	Set_action_rrc_resume_request		${start_ue_id}		cause=rna_Update		action=invalid_short_mac_i
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}
    ...        state=${state}
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    Trigger_ue_nr_rrc_resume		${start_ue_id}
    sleep   60s
    Stop Subscriber Trace
    Start Subscriber Trace  trace_session_id=2

    Stop_and_Collect_Dcap_IpCapture         ${LOG_PATH}
#    verify_subscribertraces_on_tce    pcap_filepath=${LOG_PATH}     pcap_file=ipCapture.pcap  pdml_file=ipCapture_subscribertrace.pdml
	DCAP Disconnect To gNB
#    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Set ignore paging
    [Arguments]     ${start_ue_id}    ${end_ue_id}
	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
	wtsrunner.ue_param      id=${ue_idx}         ignore_paging=on
    END

Trigger DL Data split-C
    [Arguments]     ${start_ue_id}    ${end_ue_id}       ${state}
   	FOR     ${idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
   	Run Keyword If  '${state[${idx}]}' == 'active' or '${state[${idx}]}' == 'idle'       Continue For Loop
#    wtsrunner.ue_nr_rrc_resume_request_param         id=${ue_idx}         cause=mt_Access
    wtsrunner.trf_data_start     ue=${idx}     pdu=1   qfi=1    dir=dl    trf_id=1     mbps=20
    END

Check Paging Response from egate
    [Arguments]     ${start_ue_id}    ${end_ue_id}       ${state}
   	FOR     ${idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
   	Run Keyword If  '${state[${idx}]}' == 'active' or '${state[${idx}]}' == 'idle'       Continue For Loop
	${output}    Read WTS Output Until Pattern Matches    .*eived UE Context Release Complete*.     ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    .*UE${idx}: *.
    Print Matching Lines from Output File    ${output}    .*eived UE Context Release Complete*.
    END

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   common_deal_config_file.Get GNB Swconfig File     ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin

Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage: Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}     ${IP}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
        SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

