***Settings ***
Documentation
...     [Author]        "Asha P"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

#Force Tags    CLOUD_R4P_IPSEC    FL00    SBTS18A    CRT
#Force Tags        CLOUD_F       CA_E2ET_BTSTRSPZ        SBTS00     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_ET        CRT

variables      ta_e2e_bts_trs_fw
Resource       taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource       ${CURDIR}/../resources/Common_Twamp.robot
Resource       ${CURDIR}/../resources/common_keywords.robot

Suite Setup        Run Keywords    	Pre-conditions for testsuite
Suite Teardown     Run Keywords         Post-conditions for testteardown


***Variable****
${sbh_filter_file}				   SBH_traffic_filter.json
${sbh_lock_filter_file}			   SBH_TWAMP_lock_traffic_filter.json
${counter_analysis_file_name}      SBH_counter_analysis.json
${pcap_dir}                        ${EXECDIR}
${mplane_ipv4}                     10.0.1.2

*** Test Cases ***
[1][1.0] CB006886_994C_To verify upgrade and rollback for max TWAMP sessions

    Pre_condition
    Perform Recommissioning    type=delta    delta_file=CMP_RSA.xml    timeout=100
    Sleep   30
    Certificate Configure    operation=install_cmp_certificate    key_pool_type=RSA       timeout=600
    Perform Recommissioning     type=delta       delta_file=${IPIF_IPRT}        skip_parameter_relation_errors=${True}      timeout=300
    Run     sudo ipsec start --debug-all --nofork > Ipsec_status.txt &
    Sleep   60
    Perform Recommissioning     type=delta       delta_file=${IPv4_IPv6_IPsec_conf}        skip_parameter_relation_errors=${True}      timeout=300
    Call Setup  lte=Plain_config:data    parallel=${False}    verify_attach=${False}    attach=          timeout=300
    Perform Recommissioning     type=delta       delta_file=${100_Twamp_sender_IPv4_IPv6}        skip_parameter_relation_errors=${True}
    ...     timeout=300
    ${twampy_command}=    Set Variable    sudo python /home/ute/Downloads/Base_SCF/New_TWAMPY/twampy.py responder --load_json
    ...     /home/ute/Downloads/Base_SCF/New_TWAMPY/sample.json --section 1 2 3 4 --padding 100 -d >twamp.txt & echo $! > pid.txt
    Run     ${twampy_command}
    Sleep   60
    Pm Counters Start     analysis=Verify_twamp_counters_1_hour         counter_analysis_file=${CB006886_Counter_20_pps}
    Verify Pm Counters      analysis=Verify_twamp_counters_1_hour       counter_analysis_file=${CB006886_Counter_20_pps}


    setup oamops    bts_host=${mplane_ipv4}    alias=upgrade_mplane
#@    Perform software download and update     wft_profile=sbtstrunk_00     package=auto     activate_sw=true    update_timeout=4500
    ...     alias=upgrade_mplane
    Perform software download and update     wft_profile=branch_SBTS25R2     package=auto     activate_sw=true    update_timeout=4500
    ...     alias=upgrade_mplane
#@    Perform software download and update     wft_profile=branch_SBTS25R3     package=auto     activate_sw=true    update_timeout=4500
    ...     alias=upgrade_mplane
    Sleep   30
    Run     sudo ipsec stop
    Sleep   10
    Run     sudo ipsec start --debug-all --nofork > Ipsec_status.txt &
    Sleep   30
    ${twampy_command2}=    Set Variable    sudo python /home/ute/Downloads/Base_SCF/New_TWAMPY/twampy.py responder --load_json
    ...     /home/ute/Downloads/Base_SCF/New_TWAMPY/sample.json --section 1 2 3 4 --padding 100 -d >twamp.txt & echo $! > pid.txt
    Run     ${twampy_command2}
    Wait Until Keyword Succeeds  10 min     1 min    Verify Bts Status       req_rat=lte
    Verify Alarm    faultid=6450    should_exist=
    Sleep   120
    Pm Counters Start     analysis=Verify_twamp_counters_1_hour         counter_analysis_file=${CB006886_Counter_20_pps}
    Verify Pm Counters      analysis=Verify_twamp_counters_1_hour       counter_analysis_file=${CB006886_Counter_20_pps}
    Sleep   60

    Teardown Oamops     alias=upgrade_mplane
    Sleep   60

    setup oamops    bts_host=${mplane_ipv4}    alias=upgrade_mplane
    Rollback Software    timeout=600    alias=upgrade_mplane
	Sleep   30
    Run     sudo ipsec stop
    Sleep   10
    Run     sudo ipsec start --debug-all --nofork > Ipsec_status.txt &
    Sleep   30
    ${twampy_command3}=    Set Variable    sudo python /home/ute/Downloads/Base_SCF/New_TWAMPY/twampy.py responder --load_json
    ...     /home/ute/Downloads/Base_SCF/New_TWAMPY/sample.json --section 1 2 3 4 --padding 100 -d >twamp.txt & echo $! > pid.txt
    Run     ${twampy_command3}
    Wait Until Keyword Succeeds  10 min     1 min    Verify Bts Status       req_rat=lte
    Verify Alarm    faultid=6450    should_exist=
    Sleep   120
    Pm Counters Start     analysis=Verify_twamp_counters_1_hour         counter_analysis_file=${CB006886_Counter_20_pps}
    Verify Pm Counters      analysis=Verify_twamp_counters_1_hour       counter_analysis_file=${CB006886_Counter_20_pps}
    Sleep   60

    Teardown Oamops     alias=upgrade_mplane
    [Teardown]    Keywords to run at end

*** Keywords ***

Pre_condition
    Run     sudo ip addr add 10.0.3.209/30 brd 10.0.3.211 dev eth3.${vlan_ids}[0]
    Run     sudo ifconfig eth3.${vlan_ids}[0] inet6 add fc00::3:6/126
    Run     sudo cp /etc/ipsec.conf /etc/ipsec_backup.conf
    Run     sudo cp ${CURDIR}/resources/TWAMP_4_ipsec.conf /etc/ipsec.conf

Read TWAMP Session IP
        ${sender_ip} =      Get Parameter           param_path=TWAMP-1:sourceIpAddressDN:localIpAddr
        ${reflector_ip} =     Get Parameter           param_path=TWAMP-1:destIpAddress
		Set Suite Variable      ${sender_ip}    ${sender_ip}
        Set Suite Variable      ${reflector_ip}        ${reflector_ip}




Keywords to run at end
        Run     sudo killall edaemon egate
        Run     sudo ipsec stop
        Run     sudo ip a d 10.0.3.209/30 dev eth3.${vlan_ids}[0]
        Run     sudo ip a d fc00::3:6/126 dev eth3.${vlan_ids}[0]
#a        Run     sudo unlink /etc/ipsec.conf
#a        certificate configure    operation=delete_cert  all_certs=${True}
        Run     for pid in $(ps -ef | grep twamp | awk '{print $2}'); do kill -9 $pid; done
        Run     rm -rf ${CURDIR}/execution_logs/*_A54.zip



Verify Basic Syslog Error Prints
    [Arguments]     ${alias}
    ${tas_err_count}=   Analyse Syslog      analysis=verify_tas_error_signature     alias=${alias}
    Should Be True  ${tas_err_count}<=10
    ${lfs_err_count}=   Analyse Syslog      analysis=verify_lfs_error_signature     alias=${alias}
    Should Be True  ${lfs_err_count}<=10
    ${wrn_err_count}=   Analyse Syslog      analysis=verify_wrn_error_signature     alias=${alias}
    Should Be True  ${wrn_err_count}<=10
    ${trswsyslog_err_count}=    Analyse Syslog      analysis=verify_trswsyslog_error_signature     alias=${alias}
     Should Be True  ${trswsyslog_err_count}<=50
    ${trs_fatal_err_count}=     Analyse Syslog      analysis=verify_trs_fatal_error_signature     alias=${alias}
    Should Be True  ${trs_fatal_err_count}<5
    ${trswsyslog_wrn_count}=          Analyse Syslog                  analysis=verify_trswsyslog_warning_signature     alias=${alias}
    Should Be True  ${trswsyslog_wrn_count}<50
    ${tem_wrn_count}=          Analyse Syslog                  analysis=verify_tem_warning_signature     alias=${alias}
    Should Be True  ${tem_wrn_count}<1
    ${tem_error_count}=          Analyse Syslog                  analysis=verify_tem_error_signature     alias=${alias}
    Should Be True  ${tem_error_count}<1
    ${tem_wrn_count}=          Analyse Syslog                  analysis=verify_tas_warning_signature     alias=${alias}
    Should Be True  ${tem_wrn_count}<1
    ${tem_error_count}=          Analyse Syslog                  analysis=verify_tas_error_signature     alias=${alias}
    Should Be True  ${tem_error_count}<1