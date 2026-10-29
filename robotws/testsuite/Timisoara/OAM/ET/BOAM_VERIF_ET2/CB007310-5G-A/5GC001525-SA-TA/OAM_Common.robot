*** Settings ***
Documentation
...  OAM cases common keywords

Library        OperatingSystem
Library        Process
Library        Telnet
Library        DateTime
Library        XML
Library        String
Library        ute_admin_infomodel
Library        ute_fsmaccess
#Library        ute_fault
Library        ute_admin
Library        ute_wtssim
Library        ute_tshark
Library        ute_async
Library        SSHLibrary
Library        Collections
#Library        ta_wmp_alarm_checker
Library        ta_emss   host=${emss_host}  port=${emss_port}
#Library        libraries.ta_kpi_pm_report_analyzer
#Library        ta_enb

#Library        ${EXECDIR}/testsuite/WMP/SOAM3/SWM/XMLparse.py

#Resource       ${CURDIR}/../../resources/wtssim.robot
##Resource       ${EXECDIR}/resources/UTE/equipment.robot
#Resource       ${EXECDIR}/resources/UTE/faults_codes.robot
#Resource       ${EXECDIR}/resources/UTE/admin_infomodel_meta.robot
#Resource       ${EXECDIR}/testsuite/WMP/OAM/SRAN_faults/resources/fault_enums.robot
#Resource       ${EXECDIR}/testsuite/WMP/OAM/SRAN_faults/resources/general.robot
#Resource       ${EXECDIR}/testsuite/WMP/OAM/SRAN_faults/resources/verification.robot
#Resource       ${EXECDIR}/testsuite/WMP/OAM/SRAN_faults/resources/pdu.robot

*** Variables ***
${TRUNK_VERSION}                                         SBTS23R1
${TRUNK_VERSION_SEARCH}                                  5G_0.800.
${TRUNK_VERSION_DOWNLOADABLE}                            AirScale-0.800.

${SWM_path}												 /MRBTS-1/RAT-1/SWM-*
${BTS_CONF_path}										 /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*
${LNBTS_id_path}										 /MRBTS-1/RAT-1/BTS_L-*/LNBTS-1
${LNBTS_path}											 /MRBTS-1/RAT-1//LNBTS_M-1
${AlarmPath}                                             /MRBTS-1/RAT-1//LNBTS-1/ALARM_L-*
${LNBTS_fault_path}		  							 	 /MRBTS-1/RAT-1/FRI-*/ALARM-*
${LNBTS_fault_path1}		  							 /MRBTS-1/RAT-1/FRI-*/ALARM-0
${fault_path}                                            /MRBTS-1/RAT-1/LTS-1/LNBTS_L-1/LNMME_L-0
${LNCEL_fault_path}              						 /MRBTS-1/RAT-1//LNBTS_L-1/LNCEL_L-1
${Cell_alarm_path}             							 /MRBTS-1/RAT-1//LNBTS_L-1/LNCEL_L-1/ALARM_L-*
#${alarm_path}											 /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1/ALARM_L-*
${TRBLADM_path}											 /MRBTS-1/RAT-1/BSTAT-*/TRBLCADM_L-1
${POWER_GROUP_path1}                                     /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1/POWER_GROUP_L-*
${POWER_GROUP_path2}                                     /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-2/BBU_L-1/POWER_GROUP_L-*
${BBMOD_path1}                                           /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-1
${BBMOD_path2}                                           /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-2
${FAULT_SNAPSHOT_TRIGGER_path}						 	 /MRBTS-1/RAT-1/BTS_L-*/FUNC_L-1/ALARM_CONF-1/FAULT_SNAPSHOT_TRIGGER_LIST_CONF-*
${SW_UPDATE_RESULT_path}								 /MRBTS-1/RAT-1/URI-1/SW_UPDATE_IND-1/SW_UPDATE_RESULT-1
${RF_module_path}										 /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-*/RU_L-1
${MEMORY_MONITOR_path}									 /MRBTS-1/RAT-1//EQM_L-1/RMOD_L-1/RU_L-1/MEMORY_MONITOR_L-1
${RMOD_path}											 /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-1/MRBTS_A-1/EQM_A-1/APEQM_A-1/RMOD_A-*
${RESET_REQ_path}										 /MRBTS-1/RAT-1/BTS_L-*/FUNC_L-1/RESET_REQ-*

${host}                      							 192.168.200.1
${port}                      							 8023
${emss_port}                                             ${4001}
${emss_host}                                             10.0.0.10
${rf_id}            									 1
${load_t0}      										 T0
${load_t1}    	   										 T1
${load_t2}    	   										 T2
${enb_hostname}                                          192.168.255.1
${enb_username}                                          toor4nsn
${enb_password}                                          oZPS0POrRieRtu

###########################################    SWM   ######################################################################################
@{FORBIDDEN_FAULTS}        	  							 1806    1815    1873    1900    1907    2004    2011    4019    4261    6253
${jenkins_url_5G}                                        http://files.ute.nsn-rdnet.net/builds/5G/
${SW_to_download}                                        AirScale-0.800.410_ASIB_ABIO.zip

###########################################    LBT2700 Variables     ###############################################################################
${FileNumber}           						 15

${SSH_Enable_off}                                        ${CURDIR}/../resources/configurations/json/Disable systemAcctPermEnable.json
${SSH_Enable_on}                                         ${CURDIR}/../resources/configurations/json/Enable systemAcctPermEnable.json
${SSH_Enable_off_right_core}                             ${CURDIR}/../resources/configurations/json/Disable systemAcctPermEnable_right_core.json

#${workflow_url}                                         https://wft.int.net.nokia.com/5G:WMP/5G_Central/builds/
${DW_HOST}                                       https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
${destination_dir}           							 /opt/ute/


*** Keywords ***
OAM_Common Setup
	Setup admin    bts_host=192.168.255.129
	...            bts_port=443
	...            use_ssl=True
	Setup eNB Fsm Access
	admin_infomodel_meta.Setup and connect to infomodel
    OAM_Common.Start syslog for 'enb_syslog' and 'iphy_syslog'
    run_keyword_and_ignore_error        perform_delta_recommissioning    delta_file=${SSH_Enable_off}     skip_parameter_relation_errors=${True}

OAM_Common Setup for real TL
	Setup admin    bts_host=192.168.255.129
	...            bts_port=443
	...            use_ssl=True
	Setup eNB Fsm Access
	admin_infomodel_meta.Setup and connect to infomodel
    OAM_Common.Start syslog for 'enb_syslog' only
    run_keyword_and_ignore_error        perform_delta_recommissioning    delta_file=${SSH_Enable_off}     skip_parameter_relation_errors=${True}

OAM_Common Setup For EMSsim
	OAM_Common Setup
	Setup Emss
    perform_delta_recommissioning    delta_file=${MPLANENE_oamTls_off}    skip_parameter_relation_errors=${True}

OAM_Common Setup for SWM
    OAM_Common Setup
    Rewrite FileDirectory.xml for SBTS CLOUD Environment

OAM_Common Teardown
    Sleep    60s
	run_keyword_and_ignore_error        Save Snapshot to result folder
	run_keyword_and_ignore_error		Recover fault 6450 auto trigger snapshot
	Teardown admin
    Teardown Enb Fsm Access
	admin_infomodel_meta.Stop infomodel
	OAM_Common.Stop syslog for 'enb_syslog' and 'iphy_syslog'
	run_keyword_and_ignore_error        general.Teardown wtssim

OAM_Common Teardown for real TL
#    Sleep    60s
#	Save Snapshot to result folder
	run_keyword_and_ignore_error		Recover fault 6450 auto trigger snapshot
	Teardown admin
    Teardown Enb Fsm Access
	admin_infomodel_meta.Stop infomodel
	OAM_Common.Stop syslog for 'enb_syslog' only

OAM_Common Teardown with rollback
	Rollback to passive partition
	OAM_Common Teardown

OAM_Common Setup for R4 uboot
    OAM_Common Setup
	Disable the netboot

OAM_Common Teardown for R4 uboot
	Enable the netboot
	OAM_Common Teardown

S1 link Teardown
    ute_wtssim.Stop and Collect Wts logs
	Teardown all aliases for egate
    Teardown all aliases for edaemon

Trigger Snapshot Collection Setup
    OAM_Common Setup For EMSsim
    ute_fault.Setup Fault Trigger             192.168.255.1               ${12345}
    start Process  sudo su -l flexi1 -c "rm -rf /home/flexi1/UPLOADS/SNAPSHOT/BTS*"    shell=yes
    Sleep    60s

Trigger Snapshot Collection Teardown
    OAM_Common Teardown
	ute_fault.Teardown Fault Trigger

Save Snapshot to result folder
	ute_admin.Collect Snapshot     snapshot.zip   full
	Run     mv snapshot.zip ${OUTPUT DIR}

Start syslog for '${enb_syslog}' and '${iphy_syslog}'
    ute_syslog.Start syslog
    ...     log_dir=/tmp
    ...     log_name=${enb_syslog}_syslog.log
    ...     ip=192.168.255.126
    ...     alias=${enb_syslog}
    ute_syslog.Start syslog
    ...     log_dir=/tmp
    ...     log_name=${iphy_syslog}_syslog.log
    ...     ip=192.168.200.126
    ...     alias=${iphy_syslog}

Start syslog for '${enb_syslog}' only
    ute_syslog.Start syslog
    ...     log_dir=/tmp
    ...     log_name=${enb_syslog}_syslog.log
    ...     ip=192.168.255.126
    ...     alias=${enb_syslog}

Stop syslog for '${enb_syslog}' and '${iphy_syslog}'
    Collect Syslog Results   unzip=false  destination=/tmp/syslog_enb.tar.gz   alias=${enb_syslog}
    Collect Syslog Results   unzip=false  destination=/tmp/syslog_iphy.tar.gz   alias=${iphy_syslog}
    Move File   /tmp/syslog_enb.tar.gz   ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/syslog_enb.tar.gz
    Move File   /tmp/syslog_iphy.tar.gz   ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/syslog_iphy.tar.gz

Stop syslog for '${enb_syslog}' only
    Collect Syslog Results   unzip=false  destination=/tmp/syslog_enb.tar.gz   alias=${enb_syslog}
    Move File   /tmp/syslog_enb.tar.gz   ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/syslog_enb.tar.gz

Disable the netboot
	Setup Enb Fsm Access            alias=enb1
	Log To Console   \ \ \ \ Delete the netboot
	Execute Command on enb  	 cmd=uboot_env del netboot
	Execute Command on enb 		 cmd=uboot_env del netboot_interface
	Teardown Enb Fsm Access         alias=enb1

Enable the netboot
	Setup Enb Fsm Access            alias=enb2
	Sleep   60
	Log To Console   \ \ \ \ Set the netboot for the environment recovery
	Execute Command on enb       cmd=uboot_env set netboot=netboot_first
    Execute Command on enb       cmd=uboot_env set netboot_interface=lmp
	Teardown Enb Fsm Access         alias=enb2

Rewrite FileDirectory.xml for SBTS CLOUD Environment
	Setup Enb Fsm Access            alias=enb1
	Execute Command On Enb      cmd=rm /ffs/run/FileDirectory.xml    alias=enb1
	Reboot enb
	Wait for eNB configure and RF swCheckDone status
	Teardown Enb Fsm Access         alias=enb1

###########################################  Common  ######################################################################################
Update delta recommissioning file version according runtime version ${recommsioningfile}
         Setup Enb Fsm Access            alias=enb1
         Execute Command on Enb      cp /ffs/run/AdaptationVersions_*.xml /ffs/run/temp.xml    alias=enb1
         Get Enb File            /ffs/run/temp.xml   ${CURDIR}/AdaptationVersions.xml      alias=enb1
         Run Keyword And Ignore Error    Run   sed -i -e '10,$d' ${CURDIR}/AdaptationVersions.xml       ##
		 Execute Command on Enb      rm /ffs/run/temp.xml    alias=enb1
         Teardown Enb Fsm Access         alias=enb1

         ${versionfile}=        Parse XML       ${CURDIR}/AdaptationVersions.xml

         ${Recomm_file}=             Parse XML       ${recommsioningfile}
         @{elements}=                Get elements        ${Recomm_file}            .//managedObject
        FOR                        ${element}          IN                 @{elements}
		                ${classname}=           Get Element Attribute         ${element}     class
		                ${class}=               Fetch From Left            ${classname}     :
                        ${class_version_element}=    Get Element     ${versionfile}     adaptation[@name="${class}"]
		                ${class_version}=    Get Element Attribute    ${class_version_element}      version
		                Set Element Attribute     ${element}       version        ${class_version}
        END
         Save XML                ${Recomm_file}     ${recommsioningfile}
         Remove File                                 ${CURDIR}/AdaptationVersions.xml

Rel4 Update delta recommissioning file version according runtime version ${recommsioningfile}
    Setup Enb Fsm Access            alias=enb1
	Execute Command on Enb      cp /ffs/run/AdaptationVersions_*.xml /ffs/run/temp.xml    alias=enb1
	Get Enb File            /ffs/run/temp.xml   ${CURDIR}/AdaptationVersions.xml      alias=enb1
	Run Keyword And Ignore Error    Run   sed -i -e '10,$d' ${CURDIR}/AdaptationVersions.xml       ##
    Execute Command on Enb      rm /ffs/run/temp.xml    alias=enb1
	Teardown Enb Fsm Access         alias=enb1

	${versionfile}=        Parse XML       ${CURDIR}/AdaptationVersions.xml

	${Recomm_file}=             Parse XML       ${recommsioningfile}
	@{elements}=                Get elements        ${Recomm_file}            .//managedObject
	FOR                        ${element}          IN                 @{elements}
                    ${classname}=           Get Element Attribute         ${element}     class
                    ${class}=               Fetch From Left      	${classname}     :
	                ${class_version_element}=    Get Element     ${versionfile}     adaptation[@name="${class}"]
                    ${class_version}=    Get Element Attribute    ${class_version_element}      version
                    Set Element Attribute     ${element}       version        ${class_version}
    END
	Save XML                ${Recomm_file}     ${recommsioningfile}
	Remove File				${CURDIR}/AdaptationVersions.xml

SSH Enable off for Dual Core
   Setup admin    bts_host=192.168.255.129
	...            bts_port=443
	...            use_ssl=True
    ...            alias=comm_left
   run_keyword_and_ignore_error        perform_delta_recommissioning    delta_file=${SSH_Enable_off}
   ...     skip_parameter_relation_errors=${True}  alias=comm_left

   Teardown admin    alias=comm_left

   Setup admin    bts_host=192.168.255.129
	...            bts_port=443
	...            use_ssl=True
	...            remote_host=${tl[2].host[1].addr}   remote_ssh_user=ute     remote_ssh_pass=ute
    ...            alias=comm_right
   run_keyword_and_ignore_error        perform_delta_recommissioning    delta_file=${SSH_Enable_off_right_core}
   ...     skip_parameter_relation_errors=${True}   alias=comm_right
   Teardown admin    alias=comm_right

###########################################  Prepare build  ######################################################################################
Get software version type
    ${active_software}=    Get enb sw version
    ${split_active_software}=    Split string          ${active_software}    separator=\_
    ${active_software_version_flag}=   Get from list         ${split_active_software}     0
    [Return]              ${active_software_version_flag}

Download trunk t1 sw ${destination_dir}
    ${current_build}=    Get enb sw version
	${download_build}=    Replace String     ${current_build}    ${TRUNK_VERSION}      SBTS00
	${t1_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
	Wget to file          ${jenkins_url}${download_build}/${t1_relative_url}            ${destination_dir}${/}${t1_relative_url}
    [Return]              ${t1_relative_url}#a#

#Prepare build ${destination_dir} ${current_build} ${load_type}
#   ${split_build}=    Split string          ${current_build}    separator=\_
#   ${trunk_flag}=     Get from list         ${split_build}     2
#   ${version_flag}=   Get from list         ${split_build}     0
#   ${download_build}=    Run keyword if    '${trunk_flag}'=='0000'    Set Variable   ${current_build}
#					 ...     ELSE IF       '${trunk_flag}'=='1000'    Set Variable   ${current_build}
#					 ...     ELSE IF       '${trunk_flag}'=='2000'    Set Variable   ${current_build}
#                     ...     ELSE IF       '${version_flag}'=='${TRUNK_VERSION}'     Replace String
#                   ...  ${current_build}    ${TRUNK_VERSION}    SBTS00
#					 ...     ELSE IF       '${version_flag}'=='${TDD_TRUNK_VERSION}'     Replace String    .
#   ... ${current_build}    ${TDD_TRUNK_VERSION}    TL00
#					 ...     ELSE   		Set Variable   ${current_build}
#  ${t0_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable.zip
#  ${t1_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
#  ${t2_relative_url}=   Set Variable     ${download_build}_release_BTSSM_downloadable_testpackage_T2.zip
#  ${download_relative_url}   Run keyword if     '${load_type}'=='T0'     Set Variable    ${t0_relative_url}
#					 ...     ELSE IF        '${load_type}'=='T1'     Set Variable    ${t1_relative_url}
#					 ...     ELSE IF        '${load_type}'=='T2'     Set Variable    ${t2_relative_url}
#					 ...     ELSE            Log to console    		Fail  msg=Unexpected load type
#  OAM_Common_ABIO.Wget to file 	         ${jenkins_url}${download_build}/${download_relative_url}
  # ...     ${destination_dir}${/}${download_relative_url}
#  [Return]              ${download_relative_url}

Prepare build5G ${current_build} ${load_type}
   ${split_build}=    Split string          ${current_build}    separator=\_
   ${version_flag}=   Get from list         ${split_build}     0
   ${version_item}=   Get from list         ${split_build}     4
   ${active_version}=   Split string          ${version_item}    separator=\00
   ${active_version_nb}=     Get from list         ${active_version}     1
   ${version_nb}=    Get Substring    ${active_version_nb}    1    4
   ${download_build}=   Set Variable   ${TRUNK_VERSION_DOWNLOADABLE}${version_nb}
   ${project_version}=   Set Variable   ${TRUNK_VERSION_SEARCH}${version_nb}
   set test variable	  ${version_nb}
   set test variable	  ${project_version}
   ${t0_relative_url}=   Set Variable     ${download_build}_ASIB_ABIO.zip
   ${t1_relative_url}=   Set Variable     ${download_build}T1_ASIB_ABIO.zip
   ${t2_relative_url}=   Set Variable     ${download_build}T2_ASIB_ABIO.zip
   ${download_relative_url}   Run keyword if     '${load_type}'=='T0'     Set Variable    ${t0_relative_url}
			   		 ...     ELSE IF        '${load_type}'=='T1'     Set Variable    ${t1_relative_url}
					 ...     ELSE IF        '${load_type}'=='T2'     Set Variable    ${t2_relative_url}
					 ...     ELSE            Log to console    		Fail  msg=Unexpected load type
   [Return]      ${download_relative_url}

Prepare full build5G and download ${destination_dir} ${current_build}
	${t0_load}=  Prepare build5G ${destination_dir} ${current_build} T0
	${t1_load}=  Prepare build5G ${destination_dir} ${current_build} T1
	${t2_load}=  Prepare build5G ${destination_dir} ${current_build} T2
    set test variable	   ${t0_load}
	set test variable	   ${t1_load}
	set test variable	   ${t2_load}
	${build_type}=  Should Match Regexp  ${current_build}  .{2}$
    set test variable	   ${build_type}
    ${T_type}   Set Variable If
	...      "${build_type}"!="T1" and "${build_type}"!="T2"    T0
	...      "${build_type}"=="T1"    T1
	...      "${build_type}"=="T2"    T2
    ${active_build_T}=     Run Keyword If  '${T_type}' == 'T0'    Set Variable    ${t1_load}
		   		 ...     ELSE IF        '${T_type}' == 'T1'    Set Variable    ${t2_load}
		   		 ...     ELSE IF        '${T_type}' == 'T2'    Set Variable    ${t0_load}
    OAM_Common.Wget to file      ${DW_HOST}0.800.${version_nb}/${active_build_T}      ${destination_dir}${/}${active_build_T}
	set test variable      ${active_build_T}

Prepare same build5G and download ${destination_dir} ${current_build}
    ${t0_load}=  Prepare build5G ${destination_dir} ${current_build} T0
	${t1_load}=  Prepare build5G ${destination_dir} ${current_build} T1
	${t2_load}=  Prepare build5G ${destination_dir} ${current_build} T2
    ${build_type}=  Should Match Regexp  ${current_build}  .{2}$
    set test variable	   ${build_type}
    ${T_type}   Set Variable If
	...      "${build_type}"!="T1" and "${build_type}"!="T2"    T0
	...      "${build_type}"=="T1"    T1
	...      "${build_type}"=="T2"    T2
	${active_build_T}=     Run Keyword If  '${T_type}' == 'T0'    Set Variable    ${t0_load}
		   		 ...     ELSE IF        '${T_type}' == 'T1'    Set Variable    ${t1_load}
		   		 ...     ELSE IF        '${T_type}' == 'T2'    Set Variable    ${t2_load}
    OAM_Common.Wget to file      ${DW_HOST}0.800.${version_nb}/${active_build_T}      ${destination_dir}${/}${active_build_T}
	set test variable      ${active_build_T}

Prepare latest build ${destination_dir} ${current_build} ${load_type}
   ${split_build}=    Split string           ${current_build}    separator=\_
   ${version_flag}=   set variable         ${split_build[0]}${split_build[1]}${split_build[2]}
   @{load_info}=  Create List    SBTS00_FSM3_9999   SBTS00_FSM3_9999_000000_000000   24   30
   #${load_info}=  Run keyword if    '${version_flag}'=='SBTS18FSM49999'    Set Variable  SBTS00_FSM4_9999
   #                                     ...  SBTS00_FSM4_9999_000000_000000   24   30
   #              ...    ELSE IF     '${version_flag}'=='SBTS18FSM39999'    Set Variable  SBTS00_FSM3_9999
   #                                     ...    SBTS00_FSM3_9999_000000_000000   24   30
	#			 ...    ELSE         Log to console			FAIL  msg=Unexpected version flag ${version_flag}

   ${version}=       Get from list    ${load_info}    0
   ${latest_load}=   Get from list    ${load_info}    1
   ${begin_num}=     Get from list    ${load_info}    2
   ${end_num}=       Get from list    ${load_info}    3
   Log to console    'version is ${version}'
   Log to console     'load is ${latest_load}'
   Log to console    'begin is ${begin_num} '
   Log to console    'end is ${end_num}''
   ${index}=       Wget to string       ${jenkins_url}
   ${version_list}=             Find links containing    ${version}   ${index}
    FOR    ${load}    IN    @{version_list}
	           ${load}=    Remove String     ${load}  .
	           ${load}=    Replace String     ${load}  ${SPACE}  ${EMPTY}
               ${latest_load_num}=    Get Substring     ${latest_load}   ${begin_num}     ${end_num}
               ${latest_load_num}=    Convert To Integer  ${latest_load_num}
               ${load_num}=           Get Substring     ${load}   ${begin_num}     ${end_num}
               ${load_num}=    Convert To Integer  ${load_num}
               ${latest_load}   Run keyword if     ${load_num}>${latest_load_num}     Set Variable    ${load}
		        ...     ELSE      set Variable    ${latest_load_num}
    END
    ${latest_load}=        Remove String   ${latest_load}    /
    ${t0_relative_url}=   Set Variable     ${latest_load}_release_BTSSM_downloadable.zip
	${t1_relative_url}=   Set Variable     ${latest_load}_release_BTSSM_downloadable_testpackage_T1.zip
	${t2_relative_url}=   Set Variable     ${latest_load}_release_BTSSM_downloadable_testpackage_T2.zip
	${download_relative_url}   Run keyword if     '${load_type}'=='T0'     Set Variable    ${t0_relative_url}
		        ...     ELSE IF      '${load_type}'=='T1'     Set Variable    ${t1_relative_url}
				...     ELSE IF      '${load_type}'=='T2'     Set Variable    ${t2_relative_url}
				...     ELSE          Log to console		  Fail  msg=Unexpected load type
    Wget to file          ${jenkins_url}${latest_load}/${download_relative_url}            ${destination_dir}${/}${download_relative_url}
    [Return]              ${download_relative_url}

Check which load should be downloaded
    ${To_Down_Load}    Set Variable If
               ...      '${build_type}' !='T1'    ${t1_load}
               ...      '${build_type}' !='T2'    ${t2_load}
    set test variable    ${To_Down_Load}

Prepare not trunk active partition build ${destination_dir} ${current_build}
    ${relative_url}=   Set Variable     ${current_build}_release_BTSSM_downloadable.zip
    Wget to file          ${jenkins_url}${current_build}/${relative_url}            ${destination_dir}${/}${relative_url}
    [Return]              ${relative_url}

Prepare new trunk build from Cloud server ${destination_dir} for '${release}'
    ${index}=           Wget to string           ${jenkins_url}
	${SBTS00_list}=     Find links containing    FL00_${release}_9999  ${index}
     ${latest_load}=    set Variable     FL00_${release}_9999_000000_000000
    FOR    ${load}    IN    @{SBTS00_list}
	           ${load}=    Remove String     ${load}  .
	           ${load}=    Replace String     ${load}  ${SPACE}  ${EMPTY}
               ${latest_load_num}=    Get Substring     ${latest_load}   22     28
               ${latest_load_num}=    Convert To Integer  ${latest_load_num}
               ${load_num}=           Get Substring     ${load}   22     28
               ${load_num}=    Convert To Integer  ${load_num}
               ${latest_load}   Run keyword if     ${load_num}>${latest_load_num}     Set Variable    ${load}
		        ...     ELSE      set Variable    ${latest_load_num}
    END

    ${latest_load}=        Remove String   ${latest_load}    /
    ${relative_url}=   Set Variable     ${latest_load}_release_BTSSM_downloadable.zip
    Wget to file          ${jenkins_url}${latest_load}/${relative_url}            ${destination_dir}${/}${relative_url}
    [Return]              ${relative_url}

Prepare new SBTS18SP build from Cloud server ${destination_dir}
    ${index}=           Wget to string           ${jenkins_url}
	${SBTS18SP_list}=     Find links containing    SBTS18SP_ENB_0000  ${index}
     ${latest_load}=    set Variable     SBTS18SP_ENB_0000_000000_000000
    FOR    ${load}    IN    @{SBTS18SP_list}
	           ${load}=    Remove String     ${load}  .
	           ${load}=    Replace String     ${load}  ${SPACE}  ${EMPTY}
               ${latest_load_num}=    Get Substring     ${latest_load}   25     31
               ${latest_load_num}=    Convert To Integer  ${latest_load_num}
               ${load_num}=           Get Substring     ${load}   25     31
               ${load_num}=    Convert To Integer  ${load_num}
               ${latest_load}   Run keyword if     ${load_num}>${latest_load_num}     Set Variable    ${load}
		        ...     ELSE      set Variable    ${latest_load}
    END

    ${latest_load}=        Remove String   ${latest_load}    /
    ${relative_url}=   Set Variable     ${latest_load}_release_BTSSM_downloadable.zip
    Wget to file          ${jenkins_url}${latest_load}/${relative_url}            ${destination_dir}${/}${relative_url}
    [Return]              ${relative_url}


Prepare new SBTS18A build from Cloud server ${destination_dir}
    ${index}=           Wget to string           ${jenkins_url}
	${SBTS18A_list}=     Find links containing    SBTS18A_ENB_0000  ${index}
     ${latest_load}=    set Variable     SBTS18A_ENB_0000_000000_000000
    FOR    ${load}    IN    @{SBTS18A_list}
	           ${load}=    Remove String     ${load}  .
	           ${load}=    Replace String     ${load}  ${SPACE}  ${EMPTY}
               ${latest_load_num}=    Get Substring     ${latest_load}   17     23
               ${latest_load_num}=    Convert To Integer  ${latest_load_num}
               ${load_num}=           Get Substring     ${load}   17     23
               ${load_num}=    Convert To Integer  ${load_num}
               ${latest_load}   Run keyword if     ${load_num}>${latest_load_num}     Set Variable    ${load}
		        ...     ELSE      set Variable    ${latest_load}
    END

    ${latest_load}=        Remove String   ${latest_load}    /
    ${relative_url}=   Set Variable     ${latest_load}_release_BTSSM_downloadable.zip
    Wget to file          ${jenkins_url}${latest_load}/${relative_url}            ${destination_dir}${/}${relative_url}
    [Return]              ${relative_url}

Prepare new SBTS18 build from Cloud server ${destination_dir}
    ${index}=           Wget to string           ${jenkins_url}
	${SBTS18_list}=     Find links containing    SBTS18_ENB  ${index}
     ${latest_load}=    set Variable     SBTS18_ENB_0000_000000_000000
    FOR    ${load}    IN    @{SBTS18_list}
	           ${load}=    Remove String     ${load}  .
	           ${load}=    Replace String     ${load}  ${SPACE}  ${EMPTY}
               ${latest_load_num}=    Get Substring     ${latest_load}   16     22
               ${latest_load_num}=    Convert To Integer  ${latest_load_num}
               ${load_num}=           Get Substring     ${load}   16     22
               ${load_num}=    Convert To Integer  ${load_num}
               ${latest_load}   Run keyword if     ${load_num}>${latest_load_num}     Set Variable    ${load}
		        ...     ELSE      set Variable    ${latest_load}
    END

    ${latest_load}=        Remove String   ${latest_load}    /
    ${relative_url}=   Set Variable     ${latest_load}_release_BTSSM_downloadable.zip
    Wget to file          ${jenkins_url}${latest_load}/${relative_url}            ${destination_dir}${/}${relative_url}
    [Return]              ${relative_url}

Wget to file
	[Arguments]       ${url}              ${destination}
	${status}         ${output}=          Run and return rc and output    wget -O ${destination} ${url}
	Run keyword if    '${status}'!='0'    Log    ${output}
	Should be equal   '${status}'         '0'   msg=wget failed (exit code ${status})

Wget to string
    [Arguments]       ${url}
    ${status}         ${output}=          Run and return rc and output    wget -O - ${url}
    Run keyword if    '${status}'!='0'    Log    ${output}
    Should be equal   '${status}'         '0'    msg=wget failed (exit code ${status})
    [Return]          ${output}

Find links containing
    [Arguments]        ${contained_string}    ${html}
    ${found_links}=    Create list
    ${split_links}=    Split string           ${html}    separator=href\="

    FOR    ${split_link}    IN    @{split_links}
           ${link_and_rest}=  Split string         ${split_link}        separator="    max_split=1
           ${link}=           Get from list        ${link_and_rest}     0
           Run keyword if     '/*view*/' in """${link}"""               Continue for loop
           Run keyword if     '/*fingerprint*/' in """${link}"""        Continue for loop
           Run keyword if     '${contained_string}' in """${link}"""    Append to list    ${found_links}   ${link}
    END

    [Return]           ${found_links}

##################################### State Check ######################################################################################
Wait until eNB reaches configured state
    ute_admin_infomodel.Query infomodel
    ...  query=/MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/NRBTS_M-* is [stateInfo.proceduralState=regex"Configured|OnAir"]  timeout=500

Wait for eNB configure and RF swCheckDone status
	Wait till eNB will not be pingable during '300' seconds
	Wait for Site is pingable
    Wait until eNB reaches configured state
    Check if every RF module is on swCheckDone status

Wait for eNB configure and RF swCheckDone status for Dual Core
    Wait till eNB will not be pingable during '300' seconds
	Wait for Site is pingable
    Wait until eNB reaches configured state
    Check if every RF module is on swCheckDone status for Dual Core

Let eNB reach onAir status and verification
    Sleep  25s
    ${cells_number}=  ute_admin_infomodel.Query infomodel  query=get count /MRBTS-1/RAT-1//LNBTS_L-*/LNCEL_L-* is [stateInfo=regex".*"]
    ${EGATE_CONFIG_PATH}=  Set Variable   ${CURDIR}/lua_scripts/robotLuaScripts/lte_wraparound_cfg_${cells_number}_cells.lua
    OAM_Common.Check if all cells are ready
    OAM_Common.Reach OnAir status using config file '${EGATE_CONFIG_PATH}' and verification

Reach OnAir status using config file '${configuration}' and verification
    Setup egate               egate_port=20000              save_egate=True    ###
    Setup edaemon             edaemon_port=10000            alias=edaemon1
    Setup edaemon             edaemon_port=30000            alias=edaemon2
    Link edaemons to egate    edaemon1                      edaemon2
    Add Egate Lua Dirs        ${CURDIR}/lua_scripts
    Start egate process       cfg_file=${configuration}     timeout=600
    Start egate services      timeout=650
    Execute egate command    cmd=mme_param id=1 full_nas_auth=yes
    Sleep   10s
    OAM_Common.Check if state of all cells is onAir
    OAM_Common.Check if state of eNB is 'OnAir'

Reach OnAir status using config file '${configuration}' workaround for real RF
    [Documentation]
    ...   Usage: EPCsim with real RF work around, Start egate services use pass_regexp='CHANGE STATE : ACTIVE' is only for iphy configure.
    Setup egate               egate_port=20000
    Setup edaemon             edaemon_port=10000            alias=edaemon1
    Setup edaemon             edaemon_port=30000            alias=edaemon2
    Link edaemons to egate    edaemon1                      edaemon2
    Add Egate Lua Dirs        ${CURDIR}/lua_scripts
    start Process  telnet 0 20000  shell=yes
    Start egate process       cfg_file=${configuration}     timeout=120
    execute_egate_command     cmd=start    pass_regexp=S1 link is Up    timeout=650
    Sleep   10s
    Check if state of all cells is onAir

Check if all cells are ready
    ute_admin_infomodel.Query infomodel  query=every /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [bbCalcState=CalculationDone]
    ...  timeout=60

Check if state of all cells is onAir
    ute_admin_infomodel.Query infomodel  query=every /MRBTS-1/RAT-1//BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-* is [stateInfo.proceduralState=OnAirDone]
    ...  timeout=60

Check if state of eNB is '${enb_state}'
   ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1//BBTOP_M-*/MRBTS_M-*/NRBTS_M-* is [stateInfo.proceduralState=${enb_state}]  timeout=360

Check how many cells are active
    [Documentation]
    ...   Author: Pawel Cholewa
    @{cells}=    ute_admin_infomodel.Query infomodel   query=get list /MRBTS-1/RAT-1//LNBTS_M-*//CELL_M-*
    ${cells_number}         Get Length                  ${cells}
    [Return]      ${cells_number}

Choose proper wtssim config file
    ${cells_number}=                      OAM_Common.Check how many cells are active
    ${EGATE_CONFIG_PATH}=  Set Variable
    ...  ${EXECDIR}/testsuite/legacy/UTE/configuration/wtssim_config/robotLuaScripts/lte_wraparound_cfg_${cells_number}_cells.lua
    [Return]    ${EGATE_CONFIG_PATH}

S1 link is up
    ${EGATE_CONFIG_PATH} =    Choose proper wtssim config file
	Check if all cells are ready
	Reach OnAir status using config file '${EGATE_CONFIG_PATH}' workaround for real RF

Check if All Bbmods Are In Enabled State
      ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1//BBU_L-1 is [stateInfo.operationalState=Enabled]
      ...  timeout=300

########################################### Check fault/alarm ###########################################
Check if LNBTS fault '${fault_id}' exists in '${timeout}' seconds
   ute_admin_infomodel.Query infomodel  query=${LNBTS_fault_path} is [faultId=${fault_id}]  timeout=${timeout}

Check if LNBTSlist fault '${fault_id}' exists in '${timeout}' seconds
   ute_admin_infomodel.Query infomodel  query=get list /MRBTS-1/RAT-1/FRI-*/ALARM-* is [faultId=${fault_id}]  timeout=${timeout}

Check if alarm '${alarm}' exists in '${timeout}' seconds
	ute_admin_infomodel.Query infomodel  query=${LNBTS_fault_path} is [alarmNumber=${alarm}]  timeout=${timeout}

Check if LNBTS fault supplAlarmInfo '${fault_supplAlarmInfo}' exists in '${timeout}' seconds
	ute_admin_infomodel.Query infomodel  query=${LNBTS_fault_path} is [alarmText.alarmAdditionalInfo.supplAlarmInfo="${fault_supplAlarmInfo}"]
	...  timeout=${timeout}

Check if LNBTS fault '${fault_id}' disappeared in '${timeout}' seconds
    Run Keyword And Expect Error    *    Check if LNBTS fault '${fault_id}' exists in '${timeout}' seconds

Verify Info Model states for active fault
    ute_admin_infomodel.Query infomodel  query=${LNCEL_fault_path} is [stateInfo.reasoningStatus[?]="${reasoningStatus}"]     timeout=90

Verify if Alarm Object '${path}' faultSeverity '${Severity}' faultId '${fault_id}' '${presence}' in Info Model
    Run Keyword If  '${presence}'=='is'
    ...  ute_admin_infomodel.Query infomodel  query=${path} is [faultId=${fault_id}, faultSeverity=${Severity}]  timeout=300
    Run Keyword If  '${presence}'=='is not'
    ...  ute_admin_infomodel.Query infomodel  query=count ${path} is [faultId=${fault_id}] = 0  timeout=90

Verify if Alarm Managed Object '${presence}' in Info Model
    Run Keyword If  '${presence}'=='is'
    ...  ute_admin_infomodel.Query infomodel
    ...  query=${Cell_alarm_path} is [alarmInformation.faultId=${fault_id}, alarmInformation.faultSeverity="Critical"]  timeout=300
    Run Keyword If  '${presence}'=='is not'
    ...  ute_admin_infomodel.Query infomodel  query=count ${Cell_alarm_path} is [alarmInformation.faultId=${fault_id}] = 0  timeout=90

Verify '${fault_id}' '${presence}' in '${state}' RawAlarmHistory
    Run Keyword If  '${presence}'=='is not'  Is not in faults group  ${state}  ${fault_id}  ${fault_path}  ${EFaultId}  timeout=60
    Run Keyword If  '${presence}'=='is'      Is in faults group      ${state}  ${fault_id}  ${fault_path}  ${EFaultId}  timeout=60

Check if FAULT_SNAPSHOT_TRIGGER '${faultNumber}' is '${triggerType}'
	ute_admin_infomodel.Query infomodel  query=${FAULT_SNAPSHOT_TRIGGER_path} is [faultSnapshotTriggers[0].faultNumber=${faultNumber}]  timeout=50
	ute_admin_infomodel.Query infomodel  query=${FAULT_SNAPSHOT_TRIGGER_path} is [faultSnapshotTriggers[0].triggerType=${triggerType}]  timeout=50

########################################  Commissioning	######################################################################################
Parameters commissioning ${path}
	perform_delta_recommissioning    delta_file=${path}    skip_parameter_relation_errors=${True}

#######################################   File Check	 ######################################################################################
File Should Not Exist on Enb ${path}
    Run Keyword And Expect Error  ${errormsg}  OperatingSystem.File Should Exist on Enb  ${path}

#################################### LBT2522 ######################################################################################
Test Teardown
    Remove Local Files
    OAM_Common Teardown

Remove Local Files
    Remove Files      ${blackbox_file_local_path}

Get BlackBox From BTS
    Get Enb File  source=${blackbox_file_bts_path}  destination=${blackbox_file_local_path}

Check BlackBox Content
    ${result}=    OperatingSystem.Get File    ${blackbox_file_local_path}
    #${line}=      Get Line    ${result}    15
    #log to console    RESULT LINE: ${line}
    Should Contain    ${result}    ${target_string}

Recommission with '${recommission_xml_file}'
    #ute_admin.Perform Delta Recommissioning  deltafile=${recommission_xml_file}  timeout=120
	ute_admin.perform_delta_recommissioning    delta_file=${recommission_xml_file}    skip_parameter_relation_errors=${True}

Recommission with '${recommission_xml_file}' and Site reset
    Recommission with '${recommission_xml_file}'

Wait until eNB reaches commissioned state
    ute_admin_infomodel.Query infomodel  query=${LNBTS_path} is [stateInfo.proceduralState=Commissioned]  timeout=500

Wait until eNB reaches uncommissioned state
    ute_admin_infomodel.Query infomodel  query=${LNBTS_path} is [stateInfo.proceduralState=NotCommissioned]  timeout=500

Kill '${Program}' to trigger a recovery reset
	Execute Command On Enb  cmd=pgrep ${Program} |while read pid; do kill $pid; done

######################################### LBT2679 ######################################################################################
Sw Update with activation
	[Arguments]     ${build_zip_file}
	ute_admin.Update Software   ${build_zip_file}
	Sleep                500
	${out}=              Remove String Using Regexp   ${build_zip_file}         _release_BTSSM_downloadable([_testpackage_]*)
	${current_build}=    Get enb sw version
	${from_fsm}=         Remove String Using Regexp   ${current_build}   ${TRUNK_VERSION}_
	Should Contain       ${out}     ${from_fsm}

Trigger and Check Snapshot
	ute_admin.Collect Snapshot     snapshot.zip   full
	Run     unzip -o snapshot.zip -d snapshot
	${matching_lines}=    Grep file    snapshot/snapshot_file_list.txt    ${keyword}
	${BTS_name}=    Get Substring     ${matching_lines}   1     10
	Set Test Variable     ${BTS_name}
	FOR    ${index}   in range   1   ${FileNumber}
	        Run 	unzip -o snapshot/${BTS_name}_part_${index}.zip -d ${BTS_name}
    END
	Check Log Files are present in Snapshot

Check Log Files are present in Snapshot
	FOR    ${fileName}  IN  @{log_file_names}
	   OperatingSystem.File Should Exist  ${BTS_name}/${BTS_name}_${fileName}
    END

Check Log Files are present on eNB
	FOR    ${fileName}  IN  @{log_file_names}
	   File Should Exist On Enb  ${log_dir}/${fileName}
    END

Remove Local Files and SW '${t1_sw_zip_filename}'
	Remove Directory  ${CURDIR}${/}Snapshot   recursive=True
	Remove Files      ${CURDIR}${/}Snapshot.zip    ${CURDIR}${/}${t1_sw_zip_filename}

Change '${Part}' in '${active_build_T}' to make SW '${T_type}' update fail for FSM'${n}'
	Run     		        unzip -o ${destination_dir}/${active_build_T} -d ${EXECDIR}
	${split_build}=    Split string         ${active_build_T}    separator=\_
   	${trunk_flag}=     Get from list         ${split_build}     2
    ${trunk_substring}=         Get Substring   ${active_build_T}       7      29
    ${root}=    Run keyword if    '${trunk_flag}'=='9999'   Parse XML
        ...  ${EXECDIR}/bts_sw/TargetBD_${TRUNK_VERSION}_${trunk_substring}${T_type}.xml
                ...     ELSE                                Parse XML       ${EXECDIR}/bts_sw/TargetBD_${pre_update_enb_sw['active']}${T_type}.xml
	${Part}=    Run keyword if      "${n}" == "3"    Get Element  ${root}  buildElement[@name="${Part}"][@hwUnit="FCT"]
	            ...     ELSE                         Get Element  ${root}   buildElement[@name="${Part}"][@hwUnit="FCTJ"]
    Set Element Attribute   ${Part}  checksum  10
    Run keyword if    '${trunk_flag}'=='9999'   Save XML    ${root}     ${EXECDIR}/bts_sw/TargetBD_${TRUNK_VERSION}_${trunk_substring}${T_type}.xml
    ...    ELSE    Save XML    ${root}     ${EXECDIR}/bts_sw/TargetBD_${pre_update_enb_sw['active']}${T_type}.xml
    Remove File             ${destination_dir}/${active_build_T}
    Run                     zip -r ${destination_dir}/${active_build_T} ./bts_sw
    Remove Directory        ${EXECDIR}${/}bts_sw   recursive=True

Change '${Part}' in '${active_build_T}' to make SW update fail for FSM'${n}'
	Run     		   unzip -o ${destination_dir}/${active_build_T} -d ${EXECDIR}
    ${substring}=           Get Substring   ${active_build_T}   15    28
    ${root}=                Parse XML       ${EXECDIR}/bts_sw/TargetBD_${TRUNK_VERSION}_FSM${n}_9999_${substring}.xml
	${Part}=        		Run keyword if     "${n}" == "3"    Get Element  ${root}  buildElement[@name="${Part}"][@hwUnit="FCT"]
	                        ...     ELSE        Get Element  ${root}   buildElement[@name="${Part}"][@hwUnit="FCTJ"]
    Set Element Attribute   ${Part}  checksum  10
    Save XML    ${root}     ${EXECDIR}/bts_sw/TargetBD_${TRUNK_VERSION}_FSM${n}_9999_${substring}.xml
    Remove File             ${destination_dir}/${active_build_T}
    Run                     zip -r ${destination_dir}/${active_build_T} ./bts_sw
    Remove Directory        ${EXECDIR}${/}bts_sw   recursive=True

####################################### LTE2250######################################################################################
Check if TRBLCADM_L is '${substring}'
   ute_admin_infomodel.Query infomodel  query=${TRBLADM_path} is [syslogSubstringTrigger=${substring}]  timeout=50

########################################## LTE2816 ######################################################################################
Set IPHY response for ${command}
    ${connection} =  Telnet.Open connection    host=${host}  port=${port}  prompt=>   newline=LF  #timeout=10
    Telnet.Set Timeout  5s
    Telnet.Read until Prompt
    ${info} =  run keyword and ignore error  Telnet.Execute Command  ${command}
    Telnet.Close Connection  ${connection}
    Log   ${info}

Check RadioMemAbnormalThreshold of ROMD Value is ${radioMemAbnormalThreshold}
    ute_admin_infomodel.Query infomodel  query=${RMOD_path} is [radioMemAbnormalThreshold=${radioMemAbnormalThreshold}]      timeout=180

Verify Info Model usedRadioMemAbnormalThreshold is '${threshold_value}'
    ute_admin_infomodel.Query infomodel  query=${MEMORY_MONITOR_path} is [usedRadioMemAbnormalThreshold=${threshold_value}]  timeout=100

RadioMemAbnormalThreshold change to '${threshold_value}'
    Setup btssm
    Upload Bts Scfc File    timeout=50
    ${xml}=             Parse XML       source=${scfc_path}
    Set element text    source=${xml}   text=${threshold_value}
    ...    xpath=.//managedObject[@class="RMOD"][@distName="MRBTS-1/RMOD-1"]/p[@name="radioMemAbnormalThreshold"]
    Save xml    source=${xml}    path=/tmp/192.168.255.129_scf_NEW.xml
    Copy scfc xml file from virtual machine to enb '/tmp/192.168.255.129_scf_NEW.xml'
    Teardown btssm
    BTS and IPHY reset operation is executed
    Wait until eNB reaches configured state

########################################## LTE2237 ######################################################################################
Generate '${fault_state1}' for fault '${fault_id}'
    ${fault_state}=                         Create Dictionary    start    ${1}    stop    ${0}
    log to console  Sending ${fault_state1} fault ${fault_id}...
    ${fault_state_val}=  Get From Dictionary  ${fault_state}    ${fault_state1}
    ute_admin.send lom fault ind msg  ${0x10110240}  ${0x10111202}  ${${fault_id}}  ${${fault_state_val}}  ${2}
    ...    ${0x0000000A}  ${0}  ${0x0000000A}  ${0x00000004}  ${0x0A000101}

Check if alarm for '${fault_id}' and '${reasoning}' are '${status}' for fault
    ${fault_status}=                           Create Dictionary    Active    ${1}       Deactive    ${0}
    ${fault_availbility}=                      Create Dictionary    ${1}      Degraded     ${0}        Online

    log to console      Checking alarm and fault ${fault_id} is ${status} for reasoning - ${reasoning}...
    ${status_val}=  Get From Dictionary  ${fault_status}    ${status}
    ${operational_val}=    Set Variable     Enabled
    ${availbility_val}=  Get From Dictionary  ${fault_availbility}    ${status_val}
    ${object_path}=          Get path of '${FaultPath}'

    ute_admin_infomodel.Query infomodel  query=count ${AlarmPath} is [alarmInformation.faultId=${fault_id}] = ${status_val}  timeout=20
    ute_admin_infomodel.Query infomodel  query=count ${object_path} is [stateInfo.reasoningStatus[?]=${reasoning}] = ${status_val}  timeout=20
    ute_admin_infomodel.Query infomodel  ${object_path} is [stateInfo.operationalState[?]=${operational_val}]   timeout=20
    Run Keyword If  '${status_val}' == '0'
    ...    ute_admin_infomodel.Query infomodel  ${object_path} is [stateInfo.availabilityStatus[?]=regex"${availbility_val}|${EMPTY}"]   timeout=20
    ...              ELSE
    ...  ute_admin_infomodel.Query infomodel  ${object_path} is [stateInfo.availabilityStatus[?]=${availbility_val}]   timeout=20
    Run Keyword If  '${status_val}' == '1'    Is In Faults Group  active  ${fault_id}  ${object_path}  timeout=20
    ...              ELSE                     Is Not In Faults Group  active  ${fault_id}  ${object_path}  timeout=20
    Run Keyword If  '${status_val}' == '1'    Check rest '6204' 'Major' '7657'

Get path of '${path}'
    @{object_info}=     ute_admin_infomodel.Query infomodel  query=get list ${path}     timeout=20
    ${name_list}=    get_info  ${object_info}    dist_name
    ${name}=      Get From List     ${name_list}    0
    ${nr}         Fetch From Right     ${name}    -
    log to console      Full path of object is: ${name}
    [Return]    ${name}

Trigger and Check Snapshot for LTE2237
    Run  rm -rf /tmp/LTE2237_test.log
    Run  cat ${meta_file} | grep -a "${fault_id}" | grep -a "On fault cancellation" >/tmp/LTE2237_test.log
    File Should Not Be Empty  /tmp/LTE2237_test.log

Check Message '${Information}' exist in '${File_Content}'
    Should Contain	${File_Content}   ${Information}

Trigger fault 49 by block one cell
    Check LNCEL runtime path
    Block    dist_name=${LNCEL_path}

Recover BTS state
    Check LNCEL runtime path
	Unblock   dist_name=${LNCEL_path}

Check LNCEL runtime path
    ${Exist}=		ute_admin_infomodel.Check Infomodel Object    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4   timeout=10
	${LNCEL_path}=		Run Keyword If		'${Exist}'=='True'    Set Variable	/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1/LNCEL_R-1
					    ...	   ELSE IF 		'${Exist}'=='False'   Set Variable	/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1/LNCEL_R-1
	Set test Variable      ${LNCEL_path}

Generate fault
    FOR    ${INDEX}    IN RANGE    1    12    #bylo 8
        sleep  5
        ${x}=  evaluate    (${INDEX}*5)
        log to console  Time = ${x} sek
        log to console    ${0x10110240}  ${0x10111202} ${2010}   ${101}
        ute_admin.Send hwapi api2 alarm msg  ${0x10110240}  ${0x10111202}   ${2}   ${2010}   ${101}   ${1}
    END

########################################  LTE3338-G  ######################################################################################
Wait 30s and check if parameters '${triggerType}' commissioning successfully
    Sleep    30s
    Check if FAULT_SNAPSHOT_TRIGGER '49' is '${triggerType}'

Check if trigger type is substring
	ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/BSTAT-1/TRBLCADM_L-1 is [syslogSubstringTrigger="${substring}"]  timeout=50

Trigger fault 49 by block one cell in 15 mins
    Sleep    300s
    Trigger fault 49 by block one cell

Trigger fault 49 by block one cell after 15 mins
    Sleep    900s
    Trigger fault 49 by block one cell

Check if Snapshot is uploaded to EMSsim
    Sleep    2000s
    OperatingSystem.File Should Exist    ${meta_file}
	Run  rm -rf /tmp/LTE3338-G_test.log
    Run  cat ${meta_file} | grep -a "${fault_id}">/tmp/LTE3338-G_test.log
    File Should Not Be Empty  /tmp/LTE3338-G_test.log

Clear EMSsim Snapshot
    start Process  sudo su -l flexi1 -c "rm -rf /home/flexi1/UPLOADS/SNAPSHOT/BTS*;"    shell=yes

EMSsim Snapshot should not exist
    Sleep    60s
    OperatingSystem.File Should Not Exist    ${meta_file}

Collect full data snapshot and check exist
    Run keyword and ignore error    ute_admin.Collect Snapshot     snapshot.zip   full
    Log To Console    \n start to check snapshot site
    OperatingSystem.File Should Exist    ${EXECDIR}/snapshot.zip

Verify content of full data snapshot
	${size}=     Get File Size    ${EXECDIR}/snapshot.zip
    Run Keyword If    ${size}>8700000    Log To Console    \n${size} bytes is between right full Snapshot size range
    Remove Directory  /tmp/full    recursive=True
	Process.Start Process    unzip -o snapshot.zip -d /tmp/full   cwd=${EXECDIR}    shell=${TRUE}
    Process.Wait for Process    timeout=1 min    on_timeout=terminate
	OperatingSystem.File Should Exist    /tmp/full/*_metadata.txt

######################################## LTE2517-A ######################################################################################
Check the power groups in the first FSP
	 ute_admin_infomodel.Query infomodel    query=every ${POWER_GROUP_path1} is [isCritical=True]  timeout=200
	 ute_admin_infomodel.Query infomodel    query=every ${BBMOD_path1} is [priority=0]       timeout=200

Check the power groups in the second FSP
	 ute_admin_infomodel.Query infomodel    query=every ${POWER_GROUP_path2} is [isCritical=True]  timeout=200
	 ute_admin_infomodel.Query infomodel    query=every ${BBMOD_path2} is [priority=0]       timeout=200

####################################### LTE2054 & LBT3025 ######################################################################################
Get BTS Conf info data
    ${Confinfo}=     ute_admin_infomodel.Get Infomodel Object   dist_name=${BTS_CONF_path}     timeout=10
    Log  ${Confinfo}
    Set Suite Variable  ${SCF_INFO}  ${Confinfo.activeConfigurationDN}
    Set Suite Variable  ${NP_INFO}   ${Confinfo.currentNp}
    Set Suite Variable  ${ACTIVE_SW}  ${Confinfo.activeSoftwareVersion}
    Set Suite Variable  ${PASSIVE_SW}  ${Confinfo.passiveSoftwareVersion}
    ${lnbtsinfo}=   ute_admin_infomodel.Get Infomodel Object   dist_name=${LNBTS_id_path}
    Set Suite Variable  ${BTS_ID}  ${lnbtsinfo.btsId}

BTS power reset execution
    Setup Pdu           host=${tl.pdu_ip}              model=${tl.pdu_type}    alias=enb
    Pdu Outlet Reset       outlet=${tl.enb_pdu_outlet}    alias=enb
    Teardown Pdu        alias=enb
    ute_admin_infomodel.Query infomodel  query=${LNBTS_path} is [stateInfo.proceduralState=regex"initializing|Configured"]  timeout=300

Real-time KPI-monitoring enabling Setup
    ${LOGS DIR}=  Join Path  ${OUTPUT DIR}  LOGS
    ${BTS OUTPUT DIR}=  Join Path  ${OUTPUT DIR}  LOGS  BTS
    ${SYSLOG DIR}=  Join Path  ${OUTPUT DIR}  LOGS  SYSLOGS
    ${MEASUREMENTS DIR}=  Join Path  ${OUTPUT DIR}  LOGS  MEASUREMENTS
    Run Keyword And Ignore Error  Empty Directory  ${LOGS DIR}
    Create Directory  ${BTS OUTPUT DIR}
    Create Directory  ${MEASUREMENTS DIR}
    Set Suite Variable  ${LOGS DIR}
    Set Suite Variable  ${SYSLOG DIR}
    Set Suite Variable  ${MEASUREMENTS DIR}
    Set Suite Variable  ${ALARMFILE}  ${BTS OUTPUT DIR}${/}192.168.255.129_alarms.xml
    Set Suite Variable  ${BTS OUTPUT DIR}
    OAM_Common Setup

Real-time KPI-monitoring enabling Teardown
    Run Keyword If Test Failed  Download Bts File
    Run Keyword If Test Failed  Teardown In Failure
    OAM_Common Teardown

Teardown In Failure
    Run Keyword And Ignore Error  Stop Capture RT Measurement  ${CAPTURE_HANDLE}

Check RTPM-CE info
    ${RTPM_CE_object}=    ute_admin_infomodel.Get Infomodel Object   dist_name=${NP_INFO}/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-1/MNLENT_A-1/PMCADM_A-1
    Log  ${NP_INFO}/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-1/MNLENT_A-1/PMCADM_A-1
    Should Be Equal  ${RTPM_CE_object.rTPmCollEntity.rTPmCollEntityIpAddr}  ${RTPM_ADDRESS}
    Should Be Equal  ${RTPM_CE_object.rTPmCollEntity.rTPmCollEntityPortNum}  ${RTPM_PORT}

Check RTPM-CE empty info
    ${RTPM_CE_empty_object}=   ute_admin_infomodel.Get Infomodel Object   dist_name=${NP_INFO}/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-1/MNLENT_A-1/PMCADM_A-1
    Log  ${RTPM_CE_empty_object.rTPmCollEntity}
    Should Be Empty  ${RTPM_CE_empty_object.rTPmCollEntity}

Start Tshark Monitoring
    Setup Tshark  interface=eth3  log_dir=${MEASUREMENTS DIR}  log_name=${TSHARK_CAPTURE}  alias=eth3_rep
    Start Capturing  capture_filter=port ${RTPM_PORT}  alias=${TSHARK_alias}

Stop Tshark Monitoring
    Stop Capturing  alias=eth3_rep
    Analyze Tshark Capture
    Teardown Tshark  alias=eth3_rep

Analyze Tshark Capture
    ${xml_log}=  Read pcap  log_file=${MEASUREMENTS DIR}${/}${TSHARK_CAPTURE}  output_type=pdml  alias=eth3_rep
    Create File  ${OUTPUT DIR}${/}reporting_packets.xml  content=${xml_log}

Download Bts File
#    Upload bts alarms file
    Collect Scf   target_file_name=/home/ute/robotlte/results/LOGS/BTS/scf_file
	Get Enb Swconfig File   destination=/home/ute/robotlte/results/LOGS/BTS/

Add flag to swconfig to print memory data to file
    Execute Command On Enb		echo '\n0x340009\=2' >> /flash/swconfig.txt

Download memory file from eNB
    ${fetch_path}  Set Variable  scp toor4nsn@192.168.255.1:${RAM_DIR}/*memoryStatistics* ${CURDIR}/resources/.
    Run Process   ${fetch_path}  cwd=${CURDIR}  shell=True

Start Listen Reporting Interface
    Start Tshark Monitoring
    ${CAPTURE_HANDLE}=  Start Capture RT Measurement  ip_addr=${RTPM_ADDRESS}  port=${RTPM_PORT}  meas_file=${PM_REPORT_DATA_FILE}
    Set Suite Variable  ${CAPTURE_HANDLE}

Check shared memory
    ${position}=  Convert To Integer  ${shared_memory_data_position}
    ${maxValue}=  Calculate Max  ${position}
    Should Be True  ${maxValue}<=${shared_memory_max_benchmark}
    ${averageValue}=  Calculate Average  ${position}
    Should Be True  ${averageValue}<=${shared_memory_average_benchmark}

Check alloc memory
    ${position}=  Convert To Integer  ${alloc_memory_data_position}
    ${maxValue}=  Calculate Max  ${position}
    Should Be True  ${maxValue}<=${alloc_memory_max_benchmark}
    ${averageValue}=  Calculate Average  ${position}
    Should Be True  ${averageValue}<=${alloc_memory_average_benchmark}

Add PMCADM if it is not exist
	perform_delta_recommissioning    delta_file=${AddObject_PMCADM_file}       skip_parameter_relation_errors=${True}

Analyze Measurements
    Convert RT Measurement  input_file=${PM_REPORT_DATA_FILE}  output_file=${PM_MEASUREMENT}
	Collect Scf   target_file_name=/home/ute/Downloads/scf_file.xml
    ${SCFC_File}=  OperatingSystem.List Files In Directory  /home/ute/Downloads  scf_file.xml  absolute
    Setup RT Measurement  report_file=${PM_MEASUREMENT}  syslog=${SYSLOG DIR}${/}${ENB_SYSLOG_FILE}
    ...                   baseline=${BASELINE}  scfc=@{SCFC_File}[0]

########################################## SWM ######################################################################################
Get SW load and Type
	${pre_update_enb_sw}=  Get active and passive eNB sw versions
	${build_type}=  Should Match Regexp  ${pre_update_enb_sw['passive']}  .{2}$
	set test variable      ${pre_update_enb_sw}
	set test variable	   ${build_type}

Get active and passive eNB sw versions
    Setup eNB Fsm Access  alias=version
    ${hw_version}=  Get Enb HW Version  alias=version
#    ${active_sw}=  Get Enb Sw Version  partition=active  alias=version
#    Log To Console  Active SW - '${active_sw}'
#    ${passive_sw}=  Get Enb Sw Version  partition=passive  alias=version
#    Log To Console  Passive SW - '${passive_sw}'
    ${active_sw}=  set variable  ${ACTIVE_SW_VERSION}
    ${passive_sw}=  set variable  ${PASSIVE_SW_VERSION}
    ${output}=  Create Dictionary  active=${active_sw}  passive=${passive_sw}
    Teardown Enb Fsm Access  alias=version
    [Return]  ${output}

Sw Update with activation for trunk load for build '${build_zip_file}'
	ute_admin.Update Software		${build_zip_file}   timeout=1000

Sw Update without activation for trunk load for build '${build_zip_file}'
    ute_admin.Update Software       ${build_zip_file}   should_activate=False

Prepare for consistent environment
	Sleep     60
	ute_admin.update software     ${destination_dir}/${t0_load}
	Wait for eNB configure and RF swCheckDone status
	Sleep     120

Consistent sw fallback check
	[Arguments]      ${fault_id}
	${var1}= Set Variable [alarmText.alarmDetail="SW fallback",alarmText.alarmDetailNbr=${fault_id},
    ${var2}= Set Variable faultId=${fault_id},alarmNumber=7111,faultSeverity=Major]=1
	${confirmation_point}=    ute_admin_infomodel.Query infomodel
	...    query=count ${LNBTS_fault_path} is ${var1}${var2}
	...    timeout=1800
    Should Be True    ${confirmation_point}==True
    Log To Console      SW fallback, faultId=${fault_id}, alarmNumber=7111 major occures, It is consistent sw fallback
    Check if LNBTS fault '23' disappeared in '300' seconds
    Log To Console      Alarm 23 disappeared
    Check if Active SW version is the same as '${pre_update_enb_sw['active']}'

Consistent sw fallback confirm
    Log To Console      SW fallback, alarmNumber=7111 occures, It is consistent sw fallback
    Check if LNBTS fault '23' disappeared in '300' seconds
    Log To Console      Alarm 23 disappeared
    Check if Active SW version is the same as '${pre_update_enb_sw['active']}'

Inconsistent sw fallback check
	[Arguments]      ${fault_id}
	${var1}= Set Variable [alarmText.alarmDetail="SW fallback",alarmText.alarmDetailNbr=${fault_id},faultId=${fault_id},
    ${var2}= Set Variable alarmNumber=7111,faultSeverity=Critical]=1
	${confirmation_point}=    ute_admin_infomodel.Query infomodel
	...    query=count ${LNBTS_fault_path} is ${var1}${var2}
	...    timeout=1800
    Should Be True    ${confirmation_point}==True
	Log To Console      SW fallback, faultId=${fault_id}, alarmNumber=7111 Critical occures, It is inconsistent sw fallback
	Check if Active SW version is the same as '?'
	Check if LNBTS fault '23' disappeared in '300' seconds
    Log To Console      Alarm 23 disappeared
	Check if every RF module is on swCheckDone status
    Log To Console      SW download to the active software version to reach compatible SW state
    Sw Update with activation for trunk load for build '${destination_dir}/${t0_load}'
	Wait for eNB configure and RF swCheckDone status
    ${confirmation_point}=    ute_admin_infomodel.Query infomodel
    ...    query=count ${LNBTS_fault_path} is [alarmText.alarmDetail="SW fallback",alarmNumber=7111,faultSeverity=Major]=1    timeout=300
    Should Be True    ${confirmation_point}==True
    Log To Console      SW download successful, Alarm level 7111 changed to Major

Check if Active SW version is the same as '${desired_sw_ver}'
    ${Active_SW_version}=    ute_admin_infomodel.Query infomodel    query=get list /MRBTS-1/RAT-1//BTS_CONF-1    timeout=30
    ${Active_SW_version}=    Get from list    ${Active_SW_version}    0
    Log To Console    Updated SW version: ${Active_SW_version.activeSoftwareVersion} is the same as expected : ${desired_sw_ver}
    Run Keyword If    '${Active_SW_version.activeSoftwareVersion}' != '${desired_sw_ver}'    Fail
    ...    Updated SW version - ${Active_SW_version.activeSoftwareVersion} is different then desired one - ${desired_sw_ver}

Check if Active SW version is the same as '${desired_sw_ver}'for Trunk
    ${Active_SW_version}=    ute_admin_infomodel.Query infomodel    query=get list /MRBTS-1/RAT-1//BTS_CONF-1    timeout=30
    ${Active_SW_version}=    Get from list    ${Active_SW_version}    0
    Log To Console    Updated SW version: ${Active_SW_version.activeSoftwareVersion} is the same as expected : ${desired_sw_ver}
    Run Keyword If    '${Active_SW_version.activeSoftwareVersion}' != '${desired_sw_ver}'    Fail
    ...    Updated SW version - ${Active_SW_version.activeSoftwareVersion} is different then desired one - ${desired_sw_ver}

Reset Bts and '${fault_id}' did not disappeared
    Log to console   Check reset Bts can not clear the fallback alarms
    execute command on enb      reboot    return_rc=${True}
	Wait for eNB configure and RF swCheckDone status
	${var1}= Set Variable [alarmText.alarmDetail="SW fallback",alarmText.alarmDetailNbr=${fault_id},
    ${var2}= Set Variable faultId=${fault_id},alarmNumber=7111,faultSeverity=Major]=1
    ${confirmation_point}=    ute_admin_infomodel.Query infomodel
    ...  query=count ${LNBTS_fault_path} is ${var1}${var2}
    ...    timeout=300
    Should Be True    ${confirmation_point}==True
    Check InfoModel logger for unwanted faults
    Log To Console   Alarm still exists: SW fallback, faultId='${fault_id}', alarmNumber=7111
	Wait until eNB reaches configured state
    Check if every RF module is on swCheckDone status
	Sleep    60

Make iphy.xml inconformity
    Setup Wts Fsm Access           alias=wts1
    Get Wts Config File          ${CURDIR}/iphy.xml          alias=wts1
	Get Wts Config File          ${CURDIR}/iphybk.xml        alias=wts1
	${iphy}=              Parse XML           ${CURDIR}/iphy.xml
	${rf_buildversion}=                 Get Element Text          source=${iphy}       xpath=.//RRH[${rf_id}]/identity/buildversion
	${num_of_file}=   Get Element Count              source=${iphy}          xpath=.//RRH[${rf_id}]/soap-config/software/file
	FOR   ${file_id}   IN RANGE   1   ${num_of_file}+1
        Set Element Text    source=${iphy}   text=fakeversion    xpath=.//RRH[${rf_id}]/soap-config/software/file[${file_id}]/version
    END

    Save XML        source=${iphy}         path=${CURDIR}/modified_iphy.xml
	Put Wts Config File          source=${CURDIR}/modified_iphy.xml         alias=wts1
    Teardown Wts Fsm Access           alias=wts1
	execute command on enb      reboot    return_rc=${True}
	Wait till eNB will not be pingable during '150' seconds
	Wait for Site is pingable
   	Sleep    60

SW update to a new sw package and fault disappeared
	[Arguments]	   ${fault_id}  ${build_T}
    Sw Update with activation for trunk load for build '${destination_dir}/${build_T}'
	Wait for eNB configure and RF swCheckDone status
	Check if LNBTS fault '${fault_id}' disappeared in '60' seconds
    Check InfoModel logger for unwanted faults
    Log To Console   fault '${fault_id}' disappeared and no unwanted fault

Upload SW '${destination_dir}/${To_Down_Load}' and expect error
	Run Keyword And Expect Error    *    ute_admin.Update Software    ${destination_dir}${To_Down_Load}
    Check if LNBTS fault '${fault_id}' exists in '90' seconds
    Get and check swdlReport and Targetbd

Reboot 4 times to trigger the 4082 fallback
    FOR  ${i}   IN RANGE   ${4}
       Wait till eNB will not be pingable during '60' seconds
       Wait Until Host Is Available    192.168.255.1      timeout=240
       Sleep     60
       Log To Console  ENB is pingable, reboot
       execute command on enb      cmd=reboot   return_rc=${True}
    END
    Log To Console    enb reboot 4 times

Get and check swdlReport and Targetbd
    Get eNB targetbd file     destination=${OUTPUT DIR}/targetbd.xml
    Get Enb File  source=/rom/config/SWDLreport.txt  destination=${OUTPUT DIR}/
    ${passive_partition}=    Get Enb Partition Path    partition=passive   alias=default

Check InfoModel logger for unwanted faults
   ute_admin_infomodel.Save infomodel log     filename=${SUITE NAME}_infomodel.ims2
   ute_admin_infomodel.Initialize ims2 validator    ${SUITE NAME}_infomodel.ims2
    FOR    ${fault_id}    IN    @{FORBIDDEN_FAULTS}
       ute_admin_infomodel.Add expected ims2 event      //ALARM_L-* [alarmInformation.faultId:*->${fault_id}] times=0
    END
   ute_admin_infomodel.Validate ims2

Verify syslog against crashes
    Run Keyword And Expect Error    *    ute_syslog.Message Should Exist In Syslog File
    ...    'ERR/LFS/LinuxSyslog,*ERR:*fatality*:*2*(EAaErrorFatality_System)'
    Run Keyword And Expect Error    *    ute_syslog.Message Should Exist In Syslog File    'KERNEL ERROR'
    Run Keyword And Expect Error    *    ute_syslog.Message Should Exist In Syslog File    'FDAR: Unit autonomous reset as recovery action'
    Run Keyword And Expect Error    *    ute_syslog.Message Should Exist In Syslog File    'FDAR: Unit autonomous reset as recovery action'

Start measure time
    ${start_time}=    DateTime.Get Current Date
    Return From Keyword    ${start_time}

Stop measure time '${start_time}' and Log it
    ${stop_time}=       DateTime.Get Current Date
    ${result_time}=     DateTime.Subtract Date From Date    ${stop_time}     ${start_time}
    ${result_time}=     DateTime.Convert Time   ${result_time}   timer   exclude_milles=yes
    ${print_id}=        Catenate    SEPARATOR=    [    ${SUITE NAME}    .    ${TEST NAME}    ]:
    ${print_result}=    Catenate    Measured time =    ${result_time}
    ${to_print}=        Catenate    ${print_id}    ${print_result}
    Log     ${to_print}    WARN

Stop measure time '${start_time}' and Log it with message '${message}'
    ${stop_time}=       DateTime.Get Current Date
    ${result_time}=     DateTime.Subtract Date From Date    ${stop_time}     ${start_time}
    ${result_time}=     DateTime.Convert Time   ${result_time}   timer   exclude_milles=yes
    ${print_id}=        Catenate    SEPARATOR=    [    ${SUITE NAME}    .    ${TEST NAME}    ]:
    ${print_result}=    Catenate    ${message}    =    ${result_time}
    ${to_print}=        Catenate    ${print_id}    ${print_result}
    Log    ${to_print}    WARN

Remove SWDLreport.txt
    Log To Console   Remove SWDLreport.txt from ENB
    Setup Enb Fsm Access  alias=remove
    Execute Command On Enb  cmd=rm /ffs/run/config/SWDLreport.txt  alias=remove
    Teardown Enb Fsm Access  alias=remove

Query SW State and Coverage
    ute_admin_infomodel.Query Infomodel  ${SW_UPDATE_RESULT_path} is [result=Successful]     timeout=200    alias=default
	ute_admin_infomodel.Query Infomodel  ${SW_UPDATE_RESULT_path} is [resetCoverage=Site]    timeout=200    alias=default

Check SWDLReport
    Log To Console    SWDLreport.txt should not contain following prints:
	Get Enb File  source=/rom/config/SWDLreport.txt  destination=${OUTPUT DIR}/
	${rc}    ${output}    Run And Return Rc and Output   grep "Distributing file" ${OUTPUT DIR}/SWDLreport.txt | grep -v "(FRM-"
	Should Be True 	${rc} != 0
	${rc}    ${output}    Run And Return Rc and Output   grep "Downloading file" ${OUTPUT DIR}/SWDLreport.txt | grep -v "(FRM-"
	Should Be True 	${rc} != 0

Get And Display Alarms
    [Documentation]  Checks infomodel, gets list of alarms and display those that aren't white listed.

    [Arguments]  ${alias}=default  ${fail_on_fault}=False  ${additional_faults}=False

    Log To Console  Check if there are any faults / alarms
    @{default_fault_white_list}=  Create List  61631  61058  61006  4268  1816  6450
    @{split_additional_faults}=  Run Keyword If  '${additional_faults}' != 'False'  Split String  ${additional_faults}
    ...  ELSE  Create List
    ${fault_white_list}=  Combine Lists  ${default_fault_white_list}  ${split_additional_faults}
    @{query_result}=  Run Keyword And Ignore Error  ute_admin_infomodel.Query Infomodel  get list /MRBTS-1//ALARM_L-*  alias=${alias}
    Run Keyword If  '@{query_result}[0]' == 'FAIL'  Return From Keyword
    @{alarm_list}=  Set Variable  @{query_result}[1]
    FOR  ${alarm}  IN  @{alarm_list}
      ${alarm}=  Convert To String  ${alarm}
      ${fault_id}=  Should Match Regexp  ${alarm}  (?i)(?<=faultId = )\\d+
      ${fault_description}=  Should Match Regexp  ${alarm}  (?i)(?<=faultDescription = ).*
      ${fault_severity}=  Should Match Regexp  ${alarm}  (?i)(?<=faultSeverity = ).*
      ${alarm_number}=  Should Match Regexp  ${alarm}  (?i)(?<=alarmNumber = )\\d+
      ${alarm_detail}=  Should Match Regexp  ${alarm}  (?i)(?<=alarmDetail = ).*
      ${alarm_sever}=  Should Match Regexp  ${alarm}  (?i)(?<=alarmSeverity = ).*
      ${timestamp}=  Should Match Regexp  ${alarm}  (?i)(?<=observationTime = ).*
      @{ts}=  Should Match Regexp  ${timestamp}  (\\d{4})(\\d{2})(\\d{2})(\\d{2})(\\d{2})(\\d{2})
      ${string_timestamp}=  Set Variable  @{ts}[3].@{ts}[2].@{ts}[1] @{ts}[4]:@{ts}[5]:@{ts}[6]
      ${event_type}=  Should Match Regexp  ${alarm}  (?i)(?<=eventType = ).*
      ${reporting_resource}=  Should Match Regexp  ${alarm}  (?i)(?<=reportingResource = ).*
      ${alarming_resource }=  Should Match Regexp  ${alarm}  (?i)(?<=alarmingResource = ).*
      Run Keyword If  '${fault_id}' not in @{fault_white_list}  Log To Console  \#\#\#\#\#\#\#\#\#\#
      Run Keyword If  '${fault_id}' not in @{fault_white_list}  Log To Console  Fault detected - Fault: ${fault_id} || Alarm: ${alarm_number}
      Run Keyword If  '${fault_id}' not in @{fault_white_list}  Log To Console  Fault name - ${fault_description}
      Run Keyword If  '${fault_id}' not in @{fault_white_list}  Log To Console  Fault severity: ${fault_severity} || Alarm severity: ${alarm_sever}
      Run Keyword If  '${fault_id}' not in @{fault_white_list}  Log To Console  \#\#\#\#\#\#\#\#\#\#
      Run Keyword If  '${fail_on_fault}'=='True' and '${fault_id}' not in @{fault_white_list}  Fail  msg=Unexpected fault!
    END

Check passive is not mounted as written
    Setup Enb Fsm Access                 alias=enb1
    ${passive_partition_path}=           Execute Command on Enb              ls -lai /ffs/stb | awk -F' ' '{print $12}'        alias=enb1
    ${mount_settings}=                   Execute Command on Enb              grep "${passive_partition_path}" /etc/mtab        alias=enb1
    Should not contain                   ${mount_settings}                   rw,
    [Teardown]                           Teardown Enb Fsm Access             alias=enb1

Check if sw has changed
    [Arguments]  ${post_update_sw}=postUpdateSw  ${partition}=partition  ${target_sw}=targetSw

    Log To Console  Check if SW on ${partition} partition has been changed to ${target_sw}
    Should Be True  '${post_update_sw['${partition}']}' == '${target_sw}'
    ...  msg=Post update SW on ${partition} partition doesn't match target Sw.

Reboot enb
    [Documentation]  Reboots enb and waits for it to be offline.

    Log To Console  Reboot enb
    Setup Enb Fsm Access  alias=enb_reset
    Execute Command On Enb  cmd=reboot  return_rc=${True}  alias=enb_reset
    Teardown Enb Fsm Access  alias=enb_reset
    Wait for enb status  offline

Check swdlReport and syslog
    swdlReport should contain "\Additional Information : completed successfully\"
    syslog should contain all target files are in active FS

swdlReport should contain ${contain_string}
    ${rc}    ${output}    Run And Return Rc and Output   grep ${contain_string} ${OUTPUT DIR}/SWDLreport.txt
    Should Be True  ${rc} == 0

syslog should contain ${contain_string}
	Message Should Exist In Syslog File    ${contain_string}  alias=enb_syslog

Wait log and reset bts
    Wait for message in syslog file     regexp='\"Masterfile loaded and valid, start next download\"'    alias=enb_syslog    timeout=120
    Execute Command on Enb              reboot      alias=default
	Sleep   15

Wait BTS download is starting and Reset BTS
   ute_admin_infomodel.Query infomodel  query=${SWM_path} is [stateInfo.usageState=Busy]  timeout=420
	Execute Command on Enb              reboot      alias=default
	Sleep   15

Wait for Site is pingable
	Wait Until Host Is Available    192.168.255.1      timeout=240
	Log To Console		The site is pingable

Check if every RF module is on swCheckDone status
   #ute_admin_infomodel.Query Infomodel    query=every ${RF_module_path} is [stateInfo.proceduralState=swCheckDone]   timeout=400
    Wait Until Keyword Succeeds  400  50   ADMIN INFOMODEL Check Parameter Value   ${RF_module_path}   [stateInfo.proceduralState]    swCheckDone

    Log to console    Every RU_L is swCheckDone


Check that BTS has not been reseted
   ute_admin_infomodel.Save infomodel log     filename=${SUITE NAME}_infomodel.ims2
    ${change_sets} =         ute_admin_infomodel.get change sets    filename=${SUITE NAME}_infomodel.ims2     event=create ${RESET_REQ_path}
    Should Be Empty      ${change_sets}

Check passive is mounted as written
    Setup Enb Fsm Access                 alias=enb1
    ${passive_partition_path}=           Execute Command on Enb              ls -lai /ffs/stb | awk -F' ' '{print $12}'        alias=enb1
    ${mount_settings}=                   Execute Command on Enb              grep "${passive_partition_path}" /etc/mtab        alias=enb1
    Should contain                       ${mount_settings}                   rw,
    [Teardown]                           Teardown Enb Fsm Access             alias=enb1

Wait for enb status
    [Documentation]  Waits for given state of eNb. Possible options: online, offline.

    [Arguments]  ${status}  ${timeout}=600

    ${enb_status}=  Set Variable if  '${status}'=='online'  '1'  '0'
    Log To Console  Wait for enb to be ${status}
    FOR  ${i}  IN RANGE  ${timeout}
      ${ping_result}=  Run  ping -c 1 192.168.255.1
      ${match}=  Should Match Regexp  ${ping_result}  \\d\\sreceived
      ${number_received}=  Should Match Regexp  ${match}  \\d
      Exit For Loop If  '${number_received}' == ${enb_status}
      Sleep  1s
    END

Prepare different build from passive partition
	${active_build_T}=     Run Keyword If  '${build_type}' != 'T1'    Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t1}
    ...  ELSE  Prepare build ${destination_dir} ${pre_update_enb_sw['active']} ${load_t2}
	set test variable      ${active_build_T}

Check if '${partition}' SW is the same as '${desired_sw_ver}'
    Get '${partition}' SW version info from infomodel
    Should Be True  '${SW_version}' == '${desired_sw_ver}'
	...  msg=Post update SW on ${partition} partition doesn't match desired_sw_ver.

Get '${partition}' SW version info from infomodel
	${bts_conf}=     ute_admin_infomodel.Query infomodel    query=get list ${BTS_CONF_path}    timeout=30
    ${bts_conf}=      Get from list    ${bts_conf}    0
    ${SW_version}=    Set Variable    ${bts_conf.${partition}SoftwareVersion}
	set test variable			${SW_version}

Check which target sw it should be
	${target_sw}=    Run Keyword If  '${build_type}' !='T1'   Set Variable    ${pre_update_enb_sw['active']}T1
	...       ELSE    				   ${pre_update_enb_sw['active']}T2
	set test variable			${target_sw}

Check which T type it should be
	${T_type}   Set Variable If
	...      '${build_type}' !='T1'    T1
	...      '${build_type}' !='T2'    T2
	set test variable			${T_type}

RF power off
    Setup Pdu           host=${tl.pdu_ip}              model=${tl.pdu_type}    alias=iphy
    Pdu Outlet Off      outlet=${tl.iphy_pdu_outlet}   alias=iphy
    Teardown Pdu        alias=iphy

RF power on
    Setup Pdu           host=${tl.pdu_ip}              model=${tl.pdu_type}    alias=iphy
    Pdu Outlet On      outlet=${tl.iphy_pdu_outlet}   alias=iphy
    Teardown Pdu        alias=iphy

Wait for iphy is pingable
	Wait Until Host Is Available    192.168.200.1      timeout=620
	Log To Console		The IPHY is pingable

Get color of SMOD LED
    ${led_list}=   ute_admin_infomodel.Query Infomodel    query=get list /MRBTS-1/RAT-1//EQM_L-1//SMOD_L-1/LED_L-*
    FOR    ${led}    IN    @{led_list}
        ${led_found}=    Evaluate    (('${led.ledLabel}'=='FcmSys') or ('${led.ledLabel}'=='FctSys'))
        Return from keyword if    ${led_found}    ${led.ledState}
    END

Verify that System module LED is green or orange
    [Arguments]  ${load}=Rel3
    ${smod_led_color}=        Run keyword if      "${load}" == "Rel3"    Get color of SMOD LED
	                      ...     ELSE      Get Rel4 color of SMOD LED
    Log to console    'System module LED is ${smod_led_color}' in color '${smod_led_color}'
    ${status}    ${error_message}=    Run keyword and ignore error    Should be equal as strings    ${smod_led_color}    Green
    Run keyword if    "${status}" == "FAIL"    Should be equal as strings    ${smod_led_color}    RedOffB

Set IPHY Error response
    ${connection} =  Telnet.Open connection    host=${host}  port=${port}  prompt=>   newline=LF  #timeout=10
    Telnet.Set Timeout  5s
    Telnet.Read until Prompt
    ${info} =  run keyword and ignore error  Telnet.Execute Command  ${command_for_set_IPHY_Error}
    Telnet.Close Connection  ${connection}
    Log   ${info}

Cancel IPHY Error response
    ${connection} =  Telnet.Open connection    host=${host}  port=${port}  prompt=>   newline=LF  #timeout=10
    Telnet.Set Timeout  5s
    Telnet.Read until Prompt
    ${info} =  run keyword and ignore error  Telnet.Execute Command  ${command_for_cancel_IPHY_Error}
    Telnet.Close Connection  ${connection}
    Log  ${info}

Perform eNB RF block operation using admin and verify that RF module is blocked
    Check RMOD runtime path
    ute_admin.Block   ${RMOD_R}
    Check if blocking state of RF module is 'Blocked'

Check if blocking state of RF module is '${RF_blocking_state}'
  ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1//EQM_L-1/RMOD_L-*/RU_L-* is [stateInfo.blockingState=${RF_blocking_state}]  timeout=90
   Log To Console    RF blocking state is '${RF_blocking_state}'

Perform eNB RF unblock operation using admin and verify that RF module is unblocked
    Check RMOD runtime path
	ute_admin.Unblock   ${RMOD_R}
    Check if blocking state of RF module is 'Unblocked'

Check RMOD runtime path
    ${Exist}=		ute_admin_infomodel.Check Infomodel Object    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4   timeout=10
	${RMOD_R}=		Run Keyword If		'${Exist}'=='True'    Set Variable	/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
					...	   ELSE IF 		'${Exist}'=='False'   Set Variable	/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
	Set test variable       ${RMOD_R}

Wait BTS download is starting and reset RF
    ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/SWM-* is [stateInfo.usageState=Busy]  timeout=420
    setup wts fsm access    alias=iphy
    Execute Command on Wts              reboot      alias=iphy
	teardown_wts_fsm_access    alias=iphy
	Sleep   15

Turn Print level flag on
    Setup Enb Fsm Access            alias=enb10
    Get Enb Swconfig File  destination=${CURDIR}${/}old_swconfig.txt    alias=enb10
    Get Enb Swconfig File  destination=${CURDIR}${/}new_swconfig.txt    alias=enb10
    Append to file        ${CURDIR}${/}new_swconfig.txt      ${\n}0x10041=5${\n}
	Append to file        ${CURDIR}${/}new_swconfig.txt      ${\n}0x10040=1${\n}
	Append to file        ${CURDIR}${/}new_swconfig.txt      ${\n}0x1003F=1${\n}
    Put Enb Swconfig File            ${CURDIR}${/}new_swconfig.txt   alias=enb10
	Execute Command on Enb           crasign /ffs/run/swconfig.txt
    Teardown Enb Fsm Access         alias=enb10
    Reboot enb
    Wait for eNB configure and RF swCheckDone status
	sleep   100

Perform Reset Bts from admin
	ute_admin_infomodel.Query infomodel  query=/MRBTS-1/RAT-1/SWM-* is [stateInfo.usageState=Busy]  timeout=420
	Sleep    30s
	Run Keyword And Expect Error    *    ute_admin.Reset Site

Get eNB HW Platform
    ${enb_hardware_name}=	ute_admin_infomodel.check infomodel object   /MRBTS-1/EQM-1/SMOD-* is [variant=FSMF]
	Run Keyword If    '${enb_hardware_name}'=='True'    Set Suite Variable    ${FSM_num}    3
		                                ...    ELSE     Set Suite Variable    ${FSM_num}    4

##########################################  LTE1634/ LTE1656  #####################################################################################
Check a Specific LNCEL runtime path ${cell_id}
    ${Exist}=		ute_admin_infomodel.Check Infomodel Object    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4   timeout=10
	${LNCEL_path}=		Run Keyword If		'${Exist}'=='True'    Set Variable	/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1/${cell_id}
					    ...	   ELSE IF 		'${Exist}'=='False'   Set Variable	/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1/${cell_id}
	Set test Variable      ${LNCEL_path}

Block a Specific Cell ${cell_id}
    Check a Specific LNCEL runtime path ${cell_id}
    Block    dist_name=${LNCEL_path}

Unblock a Specific Cell ${cell_id}
    Check a Specific LNCEL runtime path ${cell_id}
	Unblock   dist_name=${LNCEL_path}

Check a Specific RMOD runtime path ${radio_id}
    ${Exist}=		ute_admin_infomodel.Check Infomodel Object    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4   timeout=10
	${RMOD_R}=		Run Keyword If		'${Exist}'=='True'    Set Variable	/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/${radio_id}
					...	   ELSE IF 		'${Exist}'=='False'   Set Variable	/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/${radio_id}
	Set test variable       ${RMOD_R}

Block a Specific Radio ${radio_id}
    Check a Specific RMOD runtime path ${radio_id}
    ute_admin.Block   ${RMOD_R}

Unblock a Specific Radio ${radio_id}
    Check a Specific RMOD runtime path ${radio_id}
	ute_admin.Unblock   ${RMOD_R}

Check whether RF diagnostic feature is enabled
    ute_admin_infomodel.Query infomodel  query=${ACT_Remote_RfDiag} is [actRemoteRfDiag=True]

Start Enable RF Diagnostic Feature ${Enable_RF_Diagnostic_File_Path}
    ${status}    Run Keyword And Return Status    Check whether RF diagnostic feature is enabled
    Run Keyword If    '${status}'=='False'   ute_admin.perform_delta_recommissioning  	delta_file=${Enable_RF_Diagnostic_File_Path}
    ...    skip_parameter_relation_errors=${True}

Start Disable RF Diagnostic Feature ${Disable_RF_Diagnostic_File_Path}
	ute_admin.perform_delta_recommissioning  	delta_file=${Disable_RF_Diagnostic_File_Path}    skip_parameter_relation_errors=${True}

	##########################################  Update radio type and version  #################################################################
Update Radio Type and Site Configuration file ${iphy_configuration_file} ${site_configuration_file} ${productName}
	Update And Put Iphy Xml	   ${iphy_configuration_file}  ${productName}
    Log to console    Update and put Iphy Xml Wts Config File
    Reset iphy using pdu
	Log to console    Reset IPHY
    Sleep  400
    Migration and Perform full commissioning ${site_configuration_file}
    Log to console    Do migration and full commissioning
	Log to console    Waiting for site and radio reach working status
	Wait for eNB configure and RF swCheckDone status in update radio type ${productName}

Update And Put Iphy Xml
    [Arguments]    ${input_filepath}   ${productName}   ${output_dirpath}=${destination_dir}
    ${output_filepath}=    Update Radios Sw Version In Iphy Xml Wts Config File    ${input_filepath}   ${productName}   ${output_dirpath}

    Put Iphy Xml Wts Config File   ${output_filepath}

Update Radios Sw Version In Iphy Xml Wts Config File
    [Arguments]    ${input_filepath}    ${productName}   ${output_dirpath}

    Get Enb Targetbd File    destination=${destination_dir}TargetBD.xml

    ${input_bare_filename}=    Get Filename Without Extension From Filepath    ${input_filepath}
    ${output_filepath}=    Join Path    ${output_dirpath}    ${input_bare_filename}_updated.xml

	Run Keyword if   "${productName}" != "CDIU"    Change Sw Version In Iphy     iphy_src=${input_filepath}     iphy_dst=${output_filepath}
	...     targetbd=${destination_dir}TargetBD.xml

    [Teardown]    Remove File    ${destination_dir}${/}TargetBD.xml
	${output_filepath}=   Run Keyword if   "${productName}" == "CDIU"    set variable   ${input_filepath}
	                      ...       ELSE      set variable   ${output_filepath}
    [Return]    ${output_filepath}

Get Filename Without Extension From Filepath
    [Arguments]    ${input_filepath}
    @{split_input_filepath}    Split Path    ${input_filepath}
    @{split_name_with_extension}    Safe Split Extension    @{split_input_filepath}[1]
    [Return]    @{split_name_with_extension}[0]

Safe Split Extension
    [Arguments]    ${path}
    ${has_tar_extension}=    Does Path Have Two Part Tar Extension On Last Segment    ${path}
    ${base_path}    ${extension}=    Split Extension    ${path}
    Return From Keyword If    not ${has_tar_extension}    ${base_path}    ${extension}
    ${base_path}    ${tar_ext_first_part}    ${tar_ext_second_part}=    Split String From Right    string=${path}    separator=.    max_split=2
    Return From Keyword    ${base_path}    ${tar_ext_first_part}.${tar_ext_second_part}

Does Path Have Two Part Tar Extension On Last Segment
    [Arguments]    ${path}
    @{split_path}=    Split Path    ${path}
    ${last_path_part_lower}=    Convert To Lowercase    @{split_path}[1]
    ${has_tar_extension}=    Evaluate    ".tar." in "${last_path_part_lower}"
    [Return]    ${has_tar_extension}

Put Iphy Xml Wts Config File
    [Arguments]    ${input_filepath}    ${remote_host}=${NONE}    ${iphy_lmp_ip}=${host}
    Log To Console    Putting Iphy Xml Wts Config File. Host: ${remote_host}
    Setup Wts Fsm Access    host=${iphy_lmp_ip}     remote_host=${remote_host}
    Put Wts Config File    source=${input_filepath}
    [Teardown]    Teardown Wts Fsm Access

Wait for eNB configure and RF swCheckDone status in update radio type ${productName}
 	Wait till eNB will not be pingable during '300' seconds
 	Wait for Site is pingable
    OAM_Common.Wait until eNB reaches configured state
    ute_admin_infomodel.Query Infomodel    query=every /MRBTS-1/RAT-1//EQM_L-1/RMOD_L-* is [productName=${productName}]   timeout=900
	${rmod}=    ute_admin_infomodel.Get Infomodel object    ${RF_module_path}
	${rmod_proceduralStatus}=   set variable    ${rmod.stateInfo.proceduralState}
	Run Keyword If      '${rmod_proceduralStatus}' != 'swCheckDone'
    ...                 Reset iphy and wait for swCheckDone

    Log to console    ${productName} has been detected

Reset iphy and wait for swCheckDone
    Log to console    reset iphy again
    Reset iphy using pdu
	ute_admin_infomodel.Query Infomodel    query=every ${RF_module_path} is [stateInfo.proceduralState=swCheckDone]   timeout=900

Migration and Perform full commissioning ${file_path}
    ute_admin.Perform Commissioning  bts_id=1  scf_file=${file_path}  skip_parameter_relation_errors=true


##########################################  Work around #####################################################################################
Disable fault 6450 auto trigger snapshot
	ute_admin.perform_delta_recommissioning  	delta_file=${6450_auto_trigger_delay}    skip_parameter_relation_errors=${True}

Recover fault 6450 auto trigger snapshot
	ute_admin.perform_delta_recommissioning  	delta_file=${6450_auto_trigger_recover}    skip_parameter_relation_errors=${True}

SYSTEM Open SSH Connection
    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60    alias=${alias}
    SSHLibrary.Login    username=${username}    password=${password}    delay=1s

SYSTEM Close SSH Connection
    [Arguments]    ${alias}
    SSHLibrary.Switch Connection    index_or_alias=${alias}
    SSHLibrary.Close Connection

SYSTEM Open SSH Connection To Enb
    SYSTEM Open SSH Connection    host=${SYSTEM_ENB_TRANSPORT_IP}
    ...                           port=22
    ...                           username=${SYSTEM_ENB_SSH_USERNAME}
    ...                           password=${SYSTEM_ENB_SSH_PASSWORD}
    ...                           alias=ssh_enb
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Write   echo "connection established"
