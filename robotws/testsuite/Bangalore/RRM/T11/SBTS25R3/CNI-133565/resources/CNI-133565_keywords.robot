
*** Settings ***
Documentation    :copyright: Nokia
Library                     ta_messaging

*** Variables ***
${1}=    1::a|2::a|3::a|4::a|5::a|6::a|7::a|8::a|9::a|10::a|11::a|12::a|13::a|14::a|17::a|18::a|19::a
${2}=    20::a|21::a|22::a|23::a|24::a|25::a|26::a|27::a|28::a|30::a|31::a|46::a|64::a
${ca_supported_bands}=    ${1}|${2}
*** Keywords ***

Setup testline_A
    [Arguments]    ${coco}    ${scfc}
#    Backup And Modify Swconfig File     parameters_list=@{SWCONFIG_FLAGS}
    Add Simulator   sim_type=cus    config=${coco}
    Add Enb Configuration        scfc=${scfc}  #  @{swconfig_flags}
    Configure environment
    setup egate    egate_port=20000    alias=TC1
    Create Alias
    Execute Egate commands

Setup testline_B
    [Arguments]    ${coco}    ${scfc}
#    Backup And Modify Swconfig File     parameters_list=@{SWCONFIG_FLAGS}
    Add Simulator   sim_type=cus    config=${coco}
    Add Enb Configuration        scfc=${scfc}  #  @{swconfig_flags}
    Configure environment
    setup egate    egate_port=20000    alias=TC2
    Create Alias for B
    Execute Egate commands for B

Setup testline_Cplane_modification
    [Arguments]    ${coco_m}
    Add Simulator   sim_type=cus    config=${coco_m}
    Configure environment

Execute Egate commands
    execute egate command        cmd=enb_timer T_SN_STATUS_TRANSFER=5000ms    alias=TC1
    execute egate command        cmd=enb_timer T_DC_Overall=5000ms    alias=TC1
    execute egate command    cmd=gnb_endc_param id=3 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true    alias=TC1
    execute egate command        cmd=gnb_endc_param id=3 scg_dl_dist_percent=0    alias=TC1
    execute egate command    cmd=gnb_endc_param id=4 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true    alias=TC1
    execute egate command        cmd=gnb_endc_param id=4 scg_dl_dist_percent=0    alias=TC1

Execute Egate commands for B
    execute egate command        cmd=enb_timer T_SN_STATUS_TRANSFER=5000ms    alias=TC2
    execute egate command        cmd=enb_timer T_DC_Overall=5000ms    alias=TC2
    execute egate command    cmd=gnb_endc_param id=2 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true    alias=TC2
    execute egate command        cmd=gnb_endc_param id=2 scg_dl_dist_percent=0    alias=TC2
    execute egate command    cmd=gnb_endc_param id=3 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true    alias=TC2
    execute egate command        cmd=gnb_endc_param id=3 scg_dl_dist_percent=0    alias=TC2


Create Alias
    Create UE Alias    UE_1    ue_id=51    id_type=cus
    Create UE Alias    UE_2    ue_id=52    id_type=cus
    Create UE Alias    UE_3    ue_id=53    id_type=cus
    Create Enb Alias    MeNB    enb_id=1    id_type=wts
    Create ENB alias      alias=SgNB_1     enb_id=3     id_type=wts
    Create ENB alias      alias=SgNB_2     enb_id=4     id_type=wts
    Create ENB alias      alias=SgNB_3     enb_id=5     id_type=wts
    Create ENB alias      alias=SgNB_4     enb_id=6     id_type=wts
    Create ENB alias      alias=SgNB_5     enb_id=7     id_type=wts
    Create ENB alias      alias=SgNB_6     enb_id=8     id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Create Alias for B
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    MeNB    enb_id=1    id_type=wts
    Create ENB alias      alias=SgNB_1     enb_id=2     id_type=wts
    Create ENB alias      alias=SgNB_2     enb_id=3     id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Trigger sim_eNB to inform MME-1 about connected gNB
    [Arguments]   ${gnb_id}    ${alias}
    Execute egate command  cmd=enb_x2_link_up enb=10 target=${gnb_id}     alias=${alias}
    Sleep  3
    Execute egate command  cmd=enb_conf_update enb=10 mme=1 connected_en_gnb_to_add=${gnb_id}    alias=${alias}

Attach UE${ue_id:\d+} to CELL${cell_id:\d} and check SgNBAdditionRequest
    Log To Console  ${\n}Attach UE${ue_id} to CELL${cell_id} and check SgNBAdditionRequest
    Set UE parameters for ENDC Capability for UE_${ue_id}
    Start observing for MeNB addition message
#    Start observing for RRC message
#    Set ROHC capabilities for UE${ue_id}
#    Set 5GIWK capabilities for UE${ue_id}
    Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}

Attach UE_${ue_id:\d+} to the Cell_${cell_id:\d} and check for SgNBadditionRequest
    Log To Console  ${\n}Attach UE${ue_id} to CELL${cell_id} and check SgNBAdditionRequest
    Set the UE parameters for ENDC Capability for UE_${ue_id}
    Start observing for MeNB addition message
#    Start observing for RRC message
#    Set ROHC capabilities for UE${ue_id}
#    Set 5GIWK capabilities for UE${ue_id}
    Run UEx command  ue_attach  id=${ue_id}  cell=${cell_id}

Set UE parameters for ENDC Capability for UE_${ue_id}
     Run UEX command    ue_param  id=${ue_id}  type=nr   release=15  supported_bands=78,7,8
     ...    supported_bands_combination=20:a:a+n78:a:a+n7:a:a+n8:a:a+3:a:a+3:a:a
     Run UEx command    ue_param id=${ue_id}  type=mrdc  supported_bands_combination=20:a:a+3:a:a+n78:a:a+n7:a:a+n8:a:a+3:a:a&0
     ...    fset_comb=eutra|1:1+eutra|1:1+nr|1:1+nr|1:1+nr|1:1+eutra|1:1
     Run UEx command    ue_param id=${ue_id} release=15 category=5 rohc=2|4 phy=on:off
     ...    supported_bands=1,2,3,4,5,6,7,8,9,10,11,12,13,14,17,18,19,20,21,22,23,24,25,26,27,28,30,31,46,64
     ...    fgi=2,3,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,22,23,24,25,27,28,31 son_rach=on extended_supported_bands=64:66
     ...    ca_supported_bands=1::a|2::a|3::a|4::a|5::a|6::a|7::a|8::a|9::a|10::a|11::a|12::a|13::a|14::a|17::a|20::a|64::a
#     ...    |18::a|19::a|20::a|21::a|22::a|23::a|24::a|25::a|26::a|27::a|28::a|30::a|31::a|46::a|64::a
     ...    rohc_continue=on in_device_coex=on category_ul=8 category_dl=14 pdcp_sn_extension=18bit supported_bands_nr=7,8,78 feature_sets_dl=0
     ...    feature_sets_dl_per_cc=4layer_tm3_tm4|mimo2 feature_sets_ul=0 feature_sets_ul_per_cc=mimo2 increased_monitoring=on extended_meas_id=on
     ...    extended_drb=on extended_lcid=on

Set the UE parameters for ENDC Capability for UE_${ue_id}
    Run UEX command    ue_param    id=${ue_id}    type=nr   release=15
    ...    supported_bands=78,7,8    supported_bands_combination=20:a:a+n78:a:a+n7:a:a+n8:a:a+3:a:a
    Run UEX command    ue_param    id=${ue_id}  type=mrdc  supported_bands_combination=20:a:a+n78:a:a+n7:a:a+n8:a:a+3:a:a&0
    ...    fset_comb=eutra|1:1+nr|1:1+nr|1:1+nr|1:1+eutra|1:1
    Run UEX command    ue_param    id=${ue_id}    release=15    category=5    rohc=2|4    phy=on:off
    ...    supported_bands=1,2,3,4,5,6,7,8,9,10,11,12,13,14,17,18,19,20,21,22,23,24,25,26,27,28,30,31,46,64
    ...    fgi=2,3,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,22,23,24,25,27,28,31
    ...    son_rach=on    extended_supported_bands=64:66
    ...    ca_supported_bands=${ca_supported_bands}    rohc_continue=on    in_device_coex=on    category_ul=8
    ...    category_dl=14    pdcp_sn_extension=18bit    supported_bands_nr=7,8,78    feature_sets_dl=0
    ...    feature_sets_dl_per_cc=4layer_tm3_tm4|mimo2    feature_sets_ul=0    feature_sets_ul_per_cc=mimo2
    ...    increased_monitoring=on    extended_meas_id=on

Handover UE${ue_id:\d+} to CELL${cell_id:\d} and check SgnbModificationRequest
    Log To Console  ${\n}Handover UE${ue_id} to CELL${cell_id} and check SgNBModificationRequest
    Start observing for Sgnb Modification
    Run UEx command    ue_ho    id=1 	cell=2

Detach all UEs
    Run UEx command  ue_detach    all

Start ${protocol} traffic with id ${trf_id} containing ${mbps_dl_tput}Mbps DL with packetSize ${packet_size_dl:\d+} and ${mbps_ul_tput}Mbps UL
    ...    with packetSize ${packet_size_ul:\d+} on UE${ue_id}
    Log To Console  Start ${protocol} traffic with id ${trf_id} containing ${mbps_dl_tput}Mbps DL with packetSize ${packet_size_dl} and
    ...    ${mbps_ul_tput}Mbps UL with packetSize ${packet_size_ul} on UE${ue_id}
    Run UEx command  trf_data_start  trf_id=${trf_id}  ue=${ue_id}  dir=dl_and_ul  protocol=${protocol}  size_dl=${packet_size_dl}
    ...    size_ul=${packet_size_ul}  Mbps_dl=${mbps_dl_tput}  Mbps_ul=${mbps_ul_tput}  stats=true

Verify if desired ${exp_tput}Mbps ${dir:(ul|dl|UL|DL)} traffic ${trf_id} on UE${ue_id:\d+} reaches ${min_success_rate}%
    Log To Console  Verify if desired ${exp_tput}Mbps ${dir} traffic ${trf_id} on UE${ue_id} reaches ${min_success_rate}%
    Sleep  120s
    ${tput_success_rate}=  Calculate Mbps average tput for UE  trf_id=${trf_id}  ue_id=${ue_id}  dir=${dir}  exp_tput=${exp_tput}
    Should Be True  ${tput_success_rate} >= ${min_success_rate}

Calculate Mbps average tput for UE
    [Arguments]  ${trf_id}  ${ue_id}  ${dir}  ${exp_tput}
    ${trf_stats}=  Run UEx command  get_trf_data_stats  trf_id=${trf_id}  ue=${ue_id}  unit=Mbps
    ${tputs_ue}=  Get From Dictionary  ${trf_stats}  ${dir}
    ${tput_avg}=  Get From Dictionary  ${tputs_ue}  avg
    ${tput_success_rate}=  Evaluate  ${tput_avg}/${exp_tput} * 100
    Log To Console  Achieved AVG UE${ue_id} ${dir} tput: ${tput_avg}Mbps (${tput_success_rate}%) / Expected: ${exp_tput}Mbps
    [Return]  ${tput_success_rate}


Start observing for MeNB addition message
    Log To Console  Start observing for MeNB addition message
    Expect Message Flow
    ...                 MeNB:X2AP_SgNBAdditionRequest (bandNR is present)
    ...                 MeNB:X2AP_SgNBAdditionRequestAcknowledge (CG-Config is present)
    ...                 MeNB:X2AP_SgNBReconfigurationComplete (RRCReconfigurationComplete is present)
    ...                 alias=SgNB_Addition    overall_timeout=30

Start observing for Sgnb Modification
    Log To Console  Start observing for SgNB Modification message
    Expect Message Flow
    ...                 MeNB:X2AP_SgNBModificationRequest
    ...                 MeNB:X2AP_SgNBModificationRequestAcknowledge
    ...                 MeNB:X2AP_SgNBReconfigurationComplete (RRCReconfigurationComplete is present)
    ...                 alias=SgNB_Modification    overall_timeout=30

Verify if bearer-type change from MCG to SCG-split is successfull
    Log To Console  Verify if bearer-type change from MCG to SCG-split is successfull
    Flow occurred as expected   alias=SgNB_Addition
#    Flow occurred as expected   alias=rrc

Verify if bearer-type change from MCG to SCG-split and SGNB modification is successfull
    Log To Console  Verify if bearer-type change from MCG to SCG-split is successfull
    Flow occurred as expected   alias=SgNB_Modification
#    Flow occurred as expected   alias=rrc

Unlock LNADJGNB-${gnb_id} Object
     taf.sbts.oam.coam.admin.Setup Admin
     taf.sbts.oam.coam.admin.perform_parameter_recommissioning    dist_name=MRBTS-1/LNBTS-1/LNADJGNB-${gnb_id}    parameter=administrativeState
      ...    value=unlocked    operation=update    skip_parameter_relation_errors=True     should_activate=True
     taf.sbts.oam.coam.admin.Teardown admin

Verify that LNADJGNB x2ToGnbLinkStatus is available on BTS1
#    [Arguments]    ${timeout}=300
    taf.sbts.oam.coam.admin.Setup Admin
    ${link_status}    taf.sbts.oam.coam.admin.get_parameter_by_class    class_name=LNADJGNB
    taf.sbts.oam.coam.admin.Teardown admin
    log to console    ${link_status}
    FOR    ${ITEM}    IN    @{link_status}
        ${dict}=    Get from dictionary    ${ITEM}    parameters
        ${value}=    Get from dictionary    ${dict}    x2ToGnbLinkStatus
        log to console    ${value}
        run keyword and continue on failure    should be equal    ${value}    available
    END



Create LNADJGNB-1 MOC
    taf.sbts.oam.coam.admin.Setup Admin
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${delta_configuration}    skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Teardown admin

Delete LNADJGNB-1 MOC from BTS
    taf.sbts.oam.coam.admin.Setup Admin
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${delta_Remove}    skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Teardown admin


Change CPlane IP for LNADJGNB-0 Object
    taf.sbts.oam.coam.admin.Setup Admin
    taf.sbts.oam.coam.admin.perform_delta_recommissioning    delta_file=${delta_cplane_modification}    skip_parameter_relation_errors=True
    taf.sbts.oam.coam.admin.Teardown admin

Start syslog_${id}
#    [Argument]     ${id}
	[Documentation]	Start Syslog keyword
#	[Arguments]     ${output_dir}=${OUTPUT_DIR}
	taf.sw.syslog.Start Syslog	log_dir=${output_dir}/enb	log_name=default_syslog_enb	ip=192.168.255.126	alias=${id}
#   Start syslog  logs_dir=/tmp    log_name=${id}    alias=${id}  ip=192.168.255.126    ports=51000   add_line_number=True

Stop Default Logging For CUS And Compress Test Logs
	[Documentation]	Keyword to get active alarms and faults on SBTS and to stop Syslogs on SBTS
	taf.sbts.oam.coam.admin.connect_to
	get_active_alarms
	get_default_fault_list
	taf.sw.syslog.Stop Syslog	alias=default_enb

Verify if firewall_open is seen for LNADJGNB-0 in syslog_${id}
    ${regexp}=    Set Variable    .*Created 20TRSW_FirewallOpenReq with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp}     alias=${id}
#    ${regexp1}=    Set Variable    .*X2G, 2152, SCRMBL_Ip(10.0.1.2), 1*
    ${regexp1}=    Set Variable  .*X2G, 2152, SCRMBL_Ip\\\(10.0.1.2\\\), 1, { SCRMBL_Ip\\\(10.0.1.26\\\) }.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp1}     alias=${id}
    ${regexp2}=    Set Variable    .*Received TRSW_FirewallOpenResp with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp2}     alias=${id}
#    ${syslog_check_passed}=    Run Keyword And Return Status   Wait For Message In Syslog File    regexp=${regexp}    timeout=20    alias=${id}
#    Run Keyword And Continue On Failure    Should Be True    ${syslog_check_passed}    Syslog check failed
    [Teardown]    Collect Syslog Results    destination=${OUTPUT_DIR}${/}${id}.log    unzip=True    alias=${id}


Verify if firewall_open is seen for LNADJGNB-1 in syslog_${id}
    ${regexp}=    Set Variable    .*Created 20TRSW_FirewallOpenReq with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp}     alias=${id}
#    ${regexp1}=    Set Variable    .*X2G, 2152, SCRMBL_Ip(10.0.1.2), 1*
    ${regexp1}=    Set Variable  .*X2G, 2152, SCRMBL_Ip\\\(10.0.1.2\\\), 1, { SCRMBL_Ip\\\(10.0.1.27\\\) }.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp1}     alias=${id}
    ${regexp2}=    Set Variable    .*Received TRSW_FirewallOpenResp with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp2}     alias=${id}
#    ${syslog_check_passed}=    Run Keyword And Return Status   Wait For Message In Syslog File    regexp=${regexp}    timeout=20    alias=${id}
#    Run Keyword And Continue On Failure    Should Be True    ${syslog_check_passed}    Syslog check failed
    [Teardown]    Collect Syslog Results    destination=${OUTPUT_DIR}${/}${id}.log    unzip=True    alias=${id}

Verify if firewall_open is seen for LNADJGNB-3 in syslog_${id}
    ${regexp}=    Set Variable    .*Created 20TRSW_FirewallOpenReq with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp}     alias=${id}
#    ${regexp1}=    Set Variable    .*X2G, 2152, SCRMBL_Ip(10.0.1.2), 1*
    ${regexp1}=    Set Variable  .*X2G, 2152, SCRMBL_Ip\\\(10.0.1.3\\\), 1, { SCRMBL_Ip\\\(10.0.1.26\\\) }.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp1}     alias=${id}
    ${regexp2}=    Set Variable    .*Received TRSW_FirewallOpenResp with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp2}     alias=${id}
#    ${syslog_check_passed}=    Run Keyword And Return Status   Wait For Message In Syslog File    regexp=${regexp}    timeout=20    alias=${id}
#    Run Keyword And Continue On Failure    Should Be True    ${syslog_check_passed}    Syslog check failed
    [Teardown]    Collect Syslog Results    destination=${OUTPUT_DIR}${/}${id}.log    unzip=True    alias=${id}

Verify if firewall_open is seen for LNADJGNB-2 and LNADJGNB-3 in syslog_${id}
    ${regexp}=    Set Variable    .*Created 20TRSW_FirewallOpenReq with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp}     alias=${id}
#    ${regexp1}=    Set Variable    .*X2G, 2152, SCRMBL_Ip(10.0.1.2), 1*
    ${regexp1}=    Set Variable  .*X2G, 36422, SCRMBL_Ip\\\(10.0.1.2\\\), 1, { SCRMBL_Ip\\\(10.0.1.25\\\) }.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp1}     alias=${id}
    ${regexp2}=    Set Variable    .*Received TRSW_FirewallOpenResp with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp2}     alias=${id}

    ${regexp3}=    Set Variable  .*X2G, 36422, SCRMBL_Ip\\\(10.0.1.2\\\), 1, { SCRMBL_Ip\\\(10.0.1.26\\\) }.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp3}     alias=${id}
    ${regexp4}=    Set Variable    .*Received TRSW_FirewallOpenResp with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp4}     alias=${id}
#    ${syslog_check_passed}=    Run Keyword And Return Status   Wait For Message In Syslog File    regexp=${regexp}    timeout=20    alias=${id}
#    Run Keyword And Continue On Failure    Should Be True    ${syslog_check_passed}    Syslog check failed
    [Teardown]    Collect Syslog Results    destination=${OUTPUT_DIR}${/}${id}.log    unzip=True    alias=${id}

Verify if firewall_close is seen in syslog_${id}
    ${regexp}=    Set Variable    .*Created 21TRSW_FirewallCloseReq with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp}     alias=${id}
#    ${regexp1}=    Set Variable    .*X2G, 2152 *
    ${regexp1}=    Set Variable  .*X2G, 2152, SCRMBL_Ip\\\(10.0.1.2\\\), 1, { SCRMBL_Ip\\\(10.0.1.27\\\) }.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp1}     alias=${id}
    ${regexp2}=    Set Variable    .*Received TRSW_FirewallCloseResp with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp2}     alias=${id}
#    ${syslog_check_passed}=    Run Keyword And Return Status   Wait For Message In Syslog File    regexp=${regexp}    timeout=20    alias=${id}
#    Run Keyword And Continue On Failure    Should Be True    ${syslog_check_passed}    Syslog check failed
    [Teardown]    Collect Syslog Results    destination=${OUTPUT_DIR}${/}${id}.log    unzip=True    alias=${id}

Verify if firewall_open is seen for new IP and firewall_close is seen for old IP in syslog_${id}
    ${regexp}=    Set Variable    .*Created 21TRSW_FirewallCloseReq with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp}     alias=${id}
#    ${regexp1}=    Set Variable    .*X2G, 2152 *
    ${regexp1}=    Set Variable  .*X2G, 36422, SCRMBL_Ip\\\(10.0.1.2\\\), 1, { SCRMBL_Ip\\\(10.0.1.26\\\) }.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp1}     alias=${id}
    ${regexp2}=    Set Variable    .*Received TRSW_FirewallCloseResp with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp2}     alias=${id}
    ${regexp3}=    Set Variable    .*Created 20TRSW_FirewallOpenReq with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp3}     alias=${id}
#    ${regexp1}=    Set Variable    .*X2G, 2152, SCRMBL_Ip(10.0.1.2), 1*
    ${regexp4}=    Set Variable  .*X2G, 2152, SCRMBL_Ip\\\(10.0.1.2\\\), 1, { SCRMBL_Ip\\\(10.0.1.27\\\) }.*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp4}     alias=${id}
    ${regexp5}=    Set Variable    .*Received TRSW_FirewallOpenResp with transactionId=*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp5}     alias=${id}
    [Teardown]    Collect Syslog Results    destination=${OUTPUT_DIR}${/}${id}.log    unzip=True    alias=${id}

Verify if firewall is already opened for LNADJGNB-3 in syslog_${id}
    ${regexp1}=    Set Variable    .*Modification of Gtp routes not required - TRSW modification will not be sent*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp1}     alias=${id}
    ${regexp1}=    Set Variable    .*Received SgNBModificationRequestAcknowledge with meNBUEX2APID*
    Run Keyword And Continue On Failure     Message should exist in syslog file   regexp=${regexp1}     alias=${id}
    [Teardown]    Collect Syslog Results    destination=${OUTPUT_DIR}${/}${id}.log    unzip=True    alias=${id}

