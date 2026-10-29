*** Settings ***

Documentation
...        [Author]         "P.Dineshkumar"
...        [Maintenance]    "TRS I & V Tools Bangalore Team"
...        [Procedure]     "After triggering Primary core sw rollback, both primary & secondary core get sync and TL is up"
...        [Date]          "12-06-2023"
...        [Feature_ID]    "CB007310"
...        [DELTA_FILE_DEPENDENCY]  "ssh_key_root.json,ssh_key_service.json"
...        [Validated_TestLine]     "MRBTS-2306"
...        [Precondition]           "Primary and secondary core's should be in sync"

variables		ta_e2e_bts_trs_fw
Resource		taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/resources/5G_Common_SOE.robot
Resource        ${CURDIR}/../resources/common_keywords.robot
Library        taf.sw.scout    WITH NAME    scout
Library			Collections
Library         ute_fsmaccess
Library			SSHLibrary
Library			OperatingSystem
Library			String

Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops    dut=chained_bts     alias=secondary
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops     dut=chained_bts     alias=secondary

*** Test Cases ***
[1.0] CB007310-Dual-ASIL-bringup-SW-upgrade-test

    Sofware downgrade and upgrade the build
    Verify build and load SCF
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting        ${Hostname}
	Verify Bts Status	should_be_onair=${True}		req_rat=nr
    Perform Recommissioning     type=param      rat=lte     param_path=MRBTS-2353/MNL-1/MNLENT-1/FEATCADM-1:actFaultSignature   operation=update
    ...     value=true      timeout=300
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm    faultid=6450    should_exist=${false}   alias=default
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm    faultid=4352    should_exist=${false}   alias=default
    Verify Webem login on both cores
    Verify SSH on both cores
    Verify R&D ports on both cores
    SSH and R&D should not have any impact
    Collect snapshot in both cores
    Reset Bts   wait_for=240
    Sleep   180
    Verify Bts Status   should_be_onair=${True}     req_rat=nr
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm    faultid=6450    should_exist=${false}   alias=default
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm    faultid=4352    should_exist=${false}   alias=default
    Verify Webem login on both cores
    Verify SSH on both cores
    Verify R&D ports on both cores
    SSH and R&D should not have any impact
    Collect snapshot in both cores
    Perform BBMOD lock unlock

*** Keywords ***
Collect snapshot in both cores
     ${snapshot_primary}=  Collect Snapshot    timeout=600
     ${snapshot_secondary}=  Collect Snapshot    timeout=600    alias=secondary

Verify build and load SCF
    ${active_sw}    ${passive_sw} =    Get Sw Version    timeout=30    alias=default
    ${split}=    Split String    ${active_sw}    _
    ${build_version}=  Set Variable    ${split[0]}
    Log    ${build_version}
    Run Keyword If      '${build_version}' == 'SBTS26R1'     Load Trunk SCF      ELSE    Load Branch SCF

Load Trunk SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${7310_tr_scf}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   180
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=false
    ...   occurrences=0

Load Branch SCF
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${7310_br_scf}   verify_bts_status=False
    ...      timeout=400     alias=default     skip_parameter_relation_errors=${True}
    Sleep   180
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm   faultid=${Core_dump}  severity=major  should_exist=false
    ...   occurrences=0

Verify R&D ports on both cores
    Disable R&D port
    Enable R&D port

Disable R&D port
    Change Rnd Port Security   enable=${False}  alias=default
    Sleep    60
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm   faultid=${R&D_Service_Port_enabled}     alarm_type=history
    ...      severity=major       should_exist=${False}      occurrences=0
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm   faultid=${R&D_Service_Port_enabled}     alarm_type=history
    ...      severity=major       should_exist=${False}      occurrences=0     alias=secondary

Enable R&D port
    Change Rnd Port Security   enable=${True}  alias=default
    Sleep    60
    Verify Alarm   faultid=${R&D_Service_Port_enabled}     should_exist=${True}      occurrences=1
    Verify Alarm   faultid=${R&D_Service_Port_enabled}     should_exist=${True}      occurrences=1    dut=chained_bts     alias=secondary
    SSH and R&D should not have any impact

Lock and unlock BBMOD
    Perform Recommissioning     type=param		param_path=BBMOD-1:administrativeState  operation=update    value=Locked
	Verify Bts Status   req_rat=lte       should_be_onair=${False}
	Verify Alarm 	faultid=6450  	should_exist=${false} 	alias=default
	Perform Recommissioning     type=param		param_path=BBMOD-1:administrativeState  operation=update    value=Unlocked
	Verify Bts Status   req_rat=lte       should_be_onair=${False}
	Verify Alarm 	faultid=6450  	should_exist=${false} 	alias=default

Sofware downgrade and upgrade the build
	Setup Oamops	dut=bts    bts_port=443		use_ssl=True
	Perform Software Download And Update	package=/home/ute/Downloads/SBTS00_ENB_9999_250911_000002_release_BTSSM_downloadable_A54.zip
    ...	activate_sw=True	update_timeout=1800
    Sleep   400

Verify Webem login on both cores
    Verify Alarm   faultid=${LMP_access_via_port_443}      should_exist=${True}      occurrences=1
    Verify Alarm   faultid=${LMP_access_via_port_443}      should_exist=${True}      occurrences=1     alias=secondary
    Login webem via primary core LMP IP
    Login webem via secondary core LMP IP

Login webem via primary core LMP IP
    Setup Oamops    bts_host=192.168.255.129    bts_port=443    username=Nemuadmin    password=nemuuser    alias=default

Login webem via secondary core LMP IP
    Setup Oamops    bts_host=192.168.255.119    bts_port=443    username=Nemuadmin    password=nemuuser    alias=secondary

Verify SSH on both cores
    Check SSH Login       Primarybts
    Check SSH Login      Secondarybts
    Sleep    30
    Verify Alarm   faultid=${LMP_access_via_port_443}      should_exist=${True}      occurrences=1
    Verify Alarm   faultid=${LMP_access_via_port_443}      should_exist=${True}      occurrences=1     alias=secondary
    Disable SSH
    Enable SSH

Disable SSH
    Perform Recommissioning     type=param     param_path=${SSH_parameter}  operation=update    value=false
    ...     skip_parameter_relation_errors=${True}

Enable SSH
    Change Ssh Access    enable=${True}     alias=default
    Sleep    30
    Verify Alarm   faultid=${SSH_enabled}     should_exist=${True}      occurrences=1
    Verify Alarm   faultid=${SSH_enabled}     should_exist=${True}      occurrences=1     alias=secondary

Check SSH Login
    [Arguments]     ${bts}
    Setup Remote Access     remote_device=${bts}
    [Teardown]  Teardown Remote Access

Verify Onair status by Lock and Unlock AMF
    Traffic Capture Start  capture_device=oam_device   mode=file   measurement_point=NE_Terminated  uplane_capturing=True   timeout=120
    Perform Recommissioning     type=param   param_path=${amf_path}     operation=update    value=${amf_lock}
    Sleep   120
    Perform Recommissioning     type=param   param_path=${amf_path}     operation=update    value=${amf_unlock}
    Sleep   120
    Verify Alarm       faultid=${NG_SCTP_setup_fail}  severity=major  should_exist=${false}   occurrences=1
    Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}   occurrences=1
    ${PointA_noPwd}=   Traffic Capture Stop   mode=file    timeout=350
    Analyse Pcap    pcap_filename=${PointA_noPwd}   analysis=verify_sctp_shutdown
    Analyse Pcap    pcap_filename=${PointA_noPwd}   analysis=verify_sctp_shutdown_complete
    Analyse Pcap    pcap_filename=${PointA_noPwd}   analysis=verify_sctp_init
    Analyse Pcap    pcap_filename=${PointA_noPwd}   analysis=verify_sctp_init_ack

Suite Teardown1
    taf.ul.trs_e2e_fw.lib.utils.log_collection.log_interface.Stop Syslog      alias=collect_syslog

Perform BBMOD lock unlock
    Verify ABIO BBMOD
    Verify ABIA BBMOD
    Verify ABIL BBMOD
    Verify ABIQ BBMOD

Verify ABIO BBMOD
    Perform Recommissioning     type=param      param_path=${ABIO_bbmod}  operation=update
    ...     value=Locked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1
    Perform Recommissioning     type=param      param_path=${ABIO_bbmod}  operation=update
    ...     value=Unlocked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1

Verify ABIA BBMOD
    Perform Recommissioning     type=param      param_path=${ABIA_bbmod5}  operation=update
    ...     value=Locked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException    Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1
    Verify Bts Status	should_be_onair=${False}    req_rat=lte
    Perform Recommissioning     type=param      param_path=${ABIA_bbmod5}  operation=update
    ...     value=Unlocked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException    Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1
    Verify Bts Status   should_be_onair=${True}    req_rat=lte
    Perform Recommissioning     type=param      param_path=${ABIA_bbmod2}  operation=update
    ...     value=Locked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException    Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1
    Verify Bts Status   should_be_onair=${False}    req_rat=lte
    Perform Recommissioning     type=param      param_path=${ABIA_bbmod2}  operation=update
    ...     value=Unlocked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException    Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1
    Verify Bts Status   should_be_onair=${True}    req_rat=lte

Verify ABIL BBMOD
    Perform Recommissioning     type=param      param_path=${ABIL_bbmod}  operation=update
    ...     value=Locked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1
    Perform Recommissioning     type=param      param_path=${ABIL_bbmod}  operation=update
    ...     value=Unlocked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1

Verify ABIQ BBMOD
    Perform Recommissioning     type=param      param_path=${ABIQ_bbmod}  operation=update
    ...     value=Locked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1
    Perform Recommissioning     type=param      param_path=${ABIQ_bbmod}  operation=update
    ...     value=Unlocked    skip_parameter_relation_errors=${True}
    Sleep   30
    Run Keyword And Expect Error     AlarmNotFoundException     Verify Alarm       faultid=${Core_dump}  severity=major  should_exist=${false}
    ...   occurrences=1