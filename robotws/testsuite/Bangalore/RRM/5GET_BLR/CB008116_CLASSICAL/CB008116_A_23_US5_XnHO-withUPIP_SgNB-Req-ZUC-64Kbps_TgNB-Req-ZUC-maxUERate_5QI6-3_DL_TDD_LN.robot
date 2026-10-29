*** Settings ***
Force Tags      CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R2     CONFIGURED

Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ./python/update_delta_and_create.py
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ./CB008941_resource.robot
Library          SSHLibrary

##Resource        ta5g_setups_and_teardowns
#Resource         ./basic_resource.robot
Resource         resources/CB008225_resource.robot


#Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            kavya kavya, kavya.kavya@nokia.com
...             maintainer:        kavya kavya, kavya.kavya@nokia.com
...             INTRODUCTION:      This test case describes the behaviour of Nokia gNB in SA mode
...                                during Xn based handover of a SA call with active UP IP in
...                                downlink direction with IP IP Indication as Preferred.
...             TEST SET NAME:    CB008116_A_23_US5_XnHO-withUPIP_SgNB-Req-ZUC-64Kbps_TgNB-Req-ZUC-maxUERate_5QI9_DL_TDD_LN
...             TESTING SPLIT:    See CB008116 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008116 CFAM
...             Requirement ID:  5G_RAN_USR_RRM_16602

*** Variables ***
#${wts_cfg_file_1}     ${CURDIR}/config/wts/basic_setup_gen.cfg
${wts_cfg_file_1}     ${CURDIR}/config/wts/basic_setup_gen_rjio.cfg
${wts_cfg_file_2}     ${CURDIR}/config/wts/basic_setup_2CC_gABIP-apLO_tdd_ref_tmo.cfg
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_NSA_CB008941.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${start_ue_id}      ${1}
${end_ue_id}      ${2}
${delta}       30
${tp_duration}      40
${inactivity_timer}      100
${TEST_NAME}        TC2
${IPHY_FILE}                    ${CURDIR}/config/wts/Conf_7752-B-SANSA-TDD-iphy.xml
${TRF_ID}    1
${TRF_ID2}    2
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd

#${CURDIR}/config/wts/basic_setup.cfg
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile_1}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
${epc_log_path}    /tmp/
&{ciph}         nea0=1      nea1_128=2  nea2_128=4  nea3_128=3
&{intgr}        nia0=1      nia1_128=2  nia2_128=4  nia3_128=3
${ip_prof}      null
${ip_prof1}      snow3g
${ip_prof2}      aes
${ip_prof3}      zuc
&{ue_profile}    ${1}=${ip_prof3}    ${2}=${ip_prof3}       ${3}=${ip_prof3}    ${4}=${ip_prof3}
...                 ${5}=${ip_prof3}    ${6}=${ip_prof3}       ${7}=${ip_prof3}    ${8}=${ip_prof3}
...                 ${9}=${ip_prof3}    ${10}=${ip_prof3}

&{ip_ie}    ${1}=required      ${2}=preferred       ${3}=required      ${4}=preferred       ${5}=required
...         ${6}=preferred     ${7}=preferred       ${8}=required      ${9}=preferred       ${10}=required


&{max_ip_rate}    ${1}=maximum-UE-rate     ${2}=maximum-UE-rate     ${3}=maximum-UE-rate     ${4}=maximum-UE-rate
...               ${5}=maximum-UE-rate     ${6}=maximum-UE-rate     ${7}=maximum-UE-rate     ${8}=maximum-UE-rate
...               ${9}=maximum-UE-rate     ${10}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate      ${2}=maximum-UE-rate     ${3}=maximum-UE-rate      ${4}=maximum-UE-rate
...                  ${5}=maximum-UE-rate      ${6}=maximum-UE-rate     ${7}=maximum-UE-rate      ${8}=maximum-UE-rate
...                  ${9}=maximum-UE-rate      ${10}=maximum-UE-rate
&{ip_result}      ${1}=performed     ${2}=not-performed     ${3}=performed     ${4}=not-performed
...               ${5}=performed     ${6}=not-performed     ${7}=performed     ${8}=not-performed
...               ${9}=performed     ${10}=not-performed

${st_ue_id}      ${1}
${en_ue_id}      ${10}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof1}                1           5
@{QOS_Prof1_speed_ul}       2           6
@{QOS_Prof1_speed_dl}       2           6
@{QOS_Prof1_unit}           mbps        mbps

@{QOS_Prof1_1}               1     #5QI 6
@{QOS_Prof1_speed_dl_1}      1
@{QOS_Prof1_speed_ul_1}      1
@{QOS_Prof1_unit_1}          mbps

${split}        resume
@{QOS_Prof2}               1       5            #5QI 3
@{QOS_Prof2_speed_dl}      1       5
@{QOS_Prof2_speed_ul}      1       5
@{QOS_Prof2_unit}          mbps     mbps
${duration}      60
&{nwslices}    ${1}=1    ${2}=2    ${3}=2
${NOKIA_LOGIN}    toor4nsn
${NOKIA_PASS}     oZPS0POrRieRtu
${radparam}                SEPARATOR=${EMPTY}    0x890073=0



*** Test Cases ***
[1][1.0] CB008116_A_23_US5_XnHO-withUPIP_SgNB-Req-ZUC-64Kbps_TgNB-Req-ZUC-maxUERate_5QI6-3_DL_TDD_LN
    [Setup]         Run keywords     Suite setup from scratch
    ...                 AND     Update bsr package
    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
    ...                 AND     Add RadParam to swconfig      ${radparam}
    ...                 AND     Perform SCF Delta Commissioning with 8116_A23_gmc_rjio.json
    ...                 AND     sleep    120
#    ...                 AND     update_delta_and_create.update_and_gen    ${CURDIR}/config/SBTS26R1/basic_delta.json   ${intgr}    ${ciph}
#    ...                 AND     sleep     60
    ...                 AND     Perform SCF Delta Commissioning with delta_gen.json
    ...                 AND     sleep     60
    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...     AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_2CC_tdd_XnHO_5QI6-3_ZUC_rjio.cfg      ${ue_profile}
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_1}
    ...                 AND     start log    btslog
    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}

#    Increase Buffer Size for VM and IPHY
#    X2AP Link Should be UP
#    Establish Xn Link To UPIP gNB3

#    FOR    ${i}    in range      ${1}    ${10}
#    ue location change      ${i}
#    END
#    Sleep   20

    FOR    ${i}    IN RANGE    1    11
    ue location change    ${i}
    END
    Sleep    20

    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}              ${2}=${QOS_Prof1}
    ...                          ${3}=${QOS_Prof1}        ${4}=${QOS_Prof1}     ${5}=${QOS_Prof1}     ${6}=${QOS_Prof1}
    ...                          ${7}=${QOS_Prof1}        ${8}=${QOS_Prof1}     ${9}=${QOS_Prof1}     ${10}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}     ${2}=${QOS_Prof1_speed_ul}
    ...                          ${3}=${QOS_Prof1_speed_ul}     ${4}=${QOS_Prof1_speed_ul}
    ...                          ${5}=${QOS_Prof1_speed_ul}     ${6}=${QOS_Prof1_speed_ul}
    ...                          ${7}=${QOS_Prof1_speed_ul}     ${8}=${QOS_Prof1_speed_ul}
    ...                          ${9}=${QOS_Prof1_speed_ul}     ${10}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}     ${2}=${QOS_Prof1_speed_dl}
    ...                          ${3}=${QOS_Prof1_speed_dl}     ${4}=${QOS_Prof1_speed_dl}
    ...                          ${5}=${QOS_Prof1_speed_dl}     ${6}=${QOS_Prof1_speed_dl}
    ...                          ${7}=${QOS_Prof1_speed_dl}     ${8}=${QOS_Prof1_speed_dl}
    ...                          ${9}=${QOS_Prof1_speed_dl}     ${10}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}         ${2}=${QOS_Prof1_unit}
    ...                           ${3}=${QOS_Prof1_unit}         ${4}=${QOS_Prof1_unit}
    ...                           ${5}=${QOS_Prof1_unit}         ${6}=${QOS_Prof1_unit}
    ...                           ${7}=${QOS_Prof1_unit}         ${8}=${QOS_Prof1_unit}
    ...                           ${9}=${QOS_Prof1_unit}         ${10}=${QOS_Prof1_unit}

    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ... 	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1  ho=${1}

    Create Modify PDU session_ho   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}  ho=${1}
    ${duration}      Set Variable    500
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${60}s

#     Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=6   pdu_id=1   qfi_id=2
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=6   pdu_id=1   qfi_id=2
#### above lines are commented becoz with intergrity protection request high throughput will not be achieved maximum 10
### encryption ad decryption will take time due to this reason with Airphone it can not be verified

    Establish Xn Link To UPIP gNB3
    sleep   ${3}s
    Enable Max integrity dat rate       path_switch    ${ip_ie[${st_ue_id}]}    ${ip_ie[${st_ue_id}]}

    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    wtsrunner.gnb_xn_handover_preparation_param    id=1    ue_sec_algos_first_bit_reserved_xn=on
    HO SA A3 UE measurements
    sleep   ${180}s
    Stop CPRT capture  ${CaptureCPRT}

#    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=6   pdu_id=1   qfi_id=2
#    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=6   pdu_id=1   qfi_id=2
    Verify Bearer_context_setup_req     ${CaptureCPRT.path}      ${st_ue_id}
    Check Integrity failure count

    MultiUE Deregister should be Successful     ${st_ue_id}    ${en_ue_id}
    [Teardown]    Run Keywords   Link SCOUT SCF to Configuration ID for Reporting
    ...           AND        Stop CPRT capture  ${CaptureCPRT}
    ...           AND        Kill WTS processes Using WTS_Runner





[1][1.0] CB008225_D_B1_1 Successful RESUME procedure for UE in RRC Inactive State - Inactivity based - DL User Data_5QI6-3_TDD_LN
    [Tags]          D_B1
	[Setup]   		Run keywords    Suite setup from scratch
	...                 AND     Perform SCF Delta Commissioning with Delta_Config_RANsha_InactBased-Uelevel_ABIP-apLO_TDD_tmo.json
	...                 AND     sleep    180
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    600
	...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_2}

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1_1}                ${2}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul_1}       ${2}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl_1}       ${2}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit_1}           ${2}=${QOS_Prof2_unit}
    ${cnai}          Create Dictionary         ${1}=on                      ${2}=on
    ${state}         Create Dictionary         ${1}=inactive                ${2}=inactive
    ${trigger}       Create Dictionary         ${1}=dldata_ranpaging        ${2}=dldata_ranpaging
    ${qos}           Create Dictionary         ${1}=ngbr                       ${2}=gbr

    Start Log      btslog     cprt
    ${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    CB008225_basic_keywords.Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile_1}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}      ${state}
    ${tp_read}          CB008225_basic_keywords.Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Reset Bearer Stats        ${start_ue_id}        ${end_ue_id}
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    ${cause_list}       Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}        ${state}        ${trigger}     ${qos}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s
    ${tp_read1}          CB008225_basic_keywords.Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${duration}   both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    ${scen1}     Stop Log      btslog     cprt    test_scenario=SCN_1

    Wait until the current Measurement Period stops  additional_time=${0}
    ${Counters}    Create Dictionary     ${NRRCC_RRC_RESUME_REQUEST1}=${2}
    ...       ${NRRCC_RRC_RESUME_SUCC}=${2}     ${RA_MSG3_CCCH1_RECEP}=${2}
    ...       ${DL_DELAY_PAGING_RRC_INCT_CON}=${-1}
    Verify Counters    ${Counters}

    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap       ${start_ue_id}      ${end_ue_id}
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       ${split}      ${cause_list}        activityNotify=uE
    MultiUE Deregister should be Successful   ${start_ue_id}    ${end_ue_id}

    log to console   Inactivity based on UE is per slice - UL User Data
    Perform SCF Delta Commissioning with Delta_Config_NonRANsha_InactBased-DRBlevel-PerSlice_gABIP-apLO_TDD.json

    Set Suite Variable    ${nwslice_ID}      &{nwslices}
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1_1}                ${2}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul_1}       ${2}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl_1}       ${2}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit_1}           ${2}=${QOS_Prof2_unit}
    ${cnai}          Create Dictionary         ${1}=on                      ${2}=on
    ${state}         Create Dictionary         ${1}=inactive                ${2}=inactive
    ${trigger}       Create Dictionary         ${1}=uldata         ${2}=uldata

    Start Log      btslog     cprt
    ${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI Multi Slice     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    CB008225_basic_keywords.Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile_1}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}      ${state}
    ${tp_read}          CB008225_basic_keywords.Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Reset Bearer Stats     ${start_ue_id}     ${end_ue_id}
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    ${cause_list}       Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}        ${state}        ${trigger}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${duration}s
    ${tp_read1}          CB008225_basic_keywords.Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${duration}   both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    ${scen2}     Stop Log      btslog     cprt    test_scenario=SCN_2

    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Verify MultiUE Cplane messages from pcap       ${scen2}[cprt]/NODECPRT_GNB.pcap       ${start_ue_id}      ${end_ue_id}
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       ${split}      ${cause_list}        activityNotify=dRB

    [Teardown]  Run Keywords   Log To console  TCTeardown
    ...         AND        Run Keyword and Ignore Error      Link SCOUT SCF to Configuration ID for Reporting
	...         AND     Kill WTS processes Using WTS_Runner


[1][1.0] CB008941_A3_1_UL_Fragmentaion_is_enabled_and_Successfull_NSA_call_in_UL_and_DL_with_multiple_UEs_in_TDD_with_noBF_Frame_structure_semistatic
    [Setup]        Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Set Test Variable       ${OUTPUT_DIR}         /home/ute
    ...                 AND     Set Test Variable       ${save_dir}        /home/ute
    ...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
    ...                 AND     Add RD Parameters To GNB Swconfig File     ${RD_PARAM}
    ...                 AND     Perform SCF Delta Commissioning with TC_2.json
    ...                 AND     sleep    180
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
    ...                 AND     Check gNB Bulid
#    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    Read Cellsetup msg      ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    log to console   UE attach trigerring now...
    Start Log    biptaf

#    ${capture_l1l2}      Capture L1L2 Set Upon Config
#    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
#    Start L1L2 Bip Mon on classical gNB
	${crnti_list_1}=      CB008941_resource.MultiUE Attach for NSA    11  18
#    sleep    1ms    reason=Wait for successful response from admin
#    Stop and Collect L1L2 Bip Monitoring on classical gNB     ${Log_path}
#    move file    ${Log_path}/L1L2_bipmon/l1l2_abip.pcap    ${Log_path}/L1L2_bipmon/l1l2_abip_nsa11_18.pcap
#    Set to dictionary   ${CaptureL1L2}    path=${Log_path}/L1L2_bipmon/l1l2_abip_nsa11_18.pcap

    ${scen1}     Stop Log     biptaf    test_scenario=attach1
    CB008941_resource.MultiUE DL Traffic Start for NSA    11  18    Traffic_rate=kbps     dl_rate=15        trf_id=${TRF_ID}
    CB008941_resource.MultiUE UL Traffic Start for NSA    11  18    Traffic_rate=kbps     ul_rate=15        trf_id=${TRF_ID}

#    ${capture_l1l2}      Capture L1L2 Set Upon Config
#    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
#    Start L1L2 Bip Mon on classical gNB
#    sleep    1ms    reason=Wait for successful response from admin
#    Stop and Collect L1L2 Bip Monitoring on classical gNB     ${Log_path}
#    move file    ${Log_path}/L1L2_bipmon/l1l2_abip.pcap     ${Log_path}/L1L2_bipmon/l1l2_abip_new_data.pcap
#    Set to dictionary   ${CaptureL1L2}    path=${Log_path}/L1L2_bipmon/l1l2_abip_new_data.pcap

    Start Log         ttitrace
    sleep    1s
    ${scen3}     Stop Log     ttitrace        test_scenario=data_1_15
    sleep   30s    #run for 5min


    Validate UL Traffic For MultiUE for NSA   11  18     0.015    2
    Validate DL Traffic For MultiUE for NSA   11  18     0.015    2
    CB008941_resource.MultiUE DL Traffic Stop for NSA     11  18  2   1
    CB008941_resource.MultiUE UL Traffic Stop for NSA   11  18    2   1
    CB008941_resource.MultiUE Detach for NSA     11  18
#    Decode TTI Trace   data_1_15

#    ${rc}    tti_utility.verify_sliv   ${scen3}[ttitrace]/output_ul_formated.csv    ulFdSchedData   SLIV
#    Should Contain  ${rc}   Pass
#    ${rc}    Read pucch boundary      ${Log_path}/L1L2_bipmon/l1l2_abip_nsa11_18.pcap
#    Should Contain  ${rc}   pass
#    ${rc}    Read pucch boundary      ${Log_path}/L1L2_bipmon/l1l2_abip_new_data.pcap
#    Should Contain  ${rc}   pass
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting




*** Keywords ***
Establish Xn Link To UPIP gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    wtsrunner.gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true     ciphering_disabled=6:false,3:false
    ...     integrityProtection_enabled=6:true,3:true     ciphering_algorithm=nea3     integrityprotection_algorithm=nia3
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=20
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   30s
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=GNB-${gnb}: XnAP Link with GNB-2   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    GNB-${gnb}: XnAP Link with GNB-2   partial_match=${TRUE}
    Log to Console    ${output}

Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin    bts_host=192.168.255.129
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin
#bts_host=192.168.255.129


Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage: Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    192.168.255.129
    SSHLibrary.login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
    SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection
