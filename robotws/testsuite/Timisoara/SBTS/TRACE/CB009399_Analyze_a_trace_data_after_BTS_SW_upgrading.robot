*** Settings ***
Documentation     [PURPOSE]
Library      SSHLibrary
Library      DateTime
Library      String
#Library		 JSONLibrary
Library      OperatingSystem
Library		 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/PaClient.py
... 	host=10.97.92.221	port=1000
Library           ute_admin_infomodel
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SQL.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/GUIKeywords.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationCellTraceKeywords.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/ActivationSubscriberTraceKeywords.robot
#Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/gui-keywords/CellTraceAnalysisWindowKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/IPTraffic.robot
Resource	 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/SyveCmKeywords.robot
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/ConnectionKeywords.robot
Library      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Library		 ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/emil_decoder.py
... 	host_name=10.56.111.77	username=hoam-tester	password=Nokia123!
...    emil_path=C:\\\"Program Files\"\\Emil\\Emil.exe  	host_name_l3dc=10.97.92.238  	username_l3dc=dcapuser
...	   password_l3dc=T@dmin@123
...    log_dir_l3dc=/sharedvolume/ntracer/_data/


*** Variables ***
${active_trace_before}		8
${type}						CellTrace
${trace_reference}			630637
@{trace_reference_list}
@{trace_list}
${mrbts_distname}
${lnbts_fqdn}
${lncel_name}
${mrbts_id}   22210
${lnbts_id}     5065
${lncel_id}     1
${plan_name}=	PLAN_5
${UE1}			Huawei_P10


*** Keywords ***
TC_CB009399_Analyze_a_trace_data_after_BTS_SW_upgrading
    [Documentation]    Short description.
    Set Library Search Order    admin
    Suite Setup For Trace

    Precondition
	Step 1:create cell trace on downgrade release, make a call, check cell trace
	Step 2:SW upgrade to target release
	Step 3:Trace can be stop

Create MTRACE for each cell
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${trace_reference}: <description>
    ...        ${trace_num}: <description>
    ...        ${lcrId}: <description>
    ...        ${lnbts_id}: <description>
    [Arguments]   ${trace_reference}   	  ${trace_num}     ${lcrId}       ${lnbts_id}=5065

    ${plan_name}=   Generate Plan Name
    ${actConf}=	taf.nms.netact.get_actual_configuration	alias=netact_allias
	${obj}=			taf.nms.netact.get_managed_object		${actConf}		${MRBTS_DN}/LNBTS-${lnbts_id}
	... 	alias=netact_allias
	Log		${obj}
	Log		${obj.meta_class}
	Log		${obj.meta_version}
    ${plan}=     taf.nms.netact.create_plan_configuration  ${plan_name}    alias=netact_allias
    taf.nms.netact.create_managed_object
        ...     plan=${plan}    meta_class=NOKLTE:MTRACE
        ...     meta_version=${obj.meta_version}   mo_id=${MRBTS_DN}/LNBTS-${lnbts_id}/CTRLTS-1/MTRACE-${trace_num}
        ...     operation=create      alias=netact_allias
        ...     eutranTraceIdMcc=262	eutranTraceIdMnc=03	traceId=${trace_reference}	trcRecSessionRef=65535
        ...     cellTrcMode=true	tceIpAddress=10.97.92.238	traceRrcSetting=0	traceS1Setting=0	traceX2Setting=0
        ...     actPCMDReporting=false  actUeThroughputMR=false     cellMaxActiveUEsTraced=60   cellTaTracing=false
        ...     jobType=1   maxBufferingTime=2000   tceCellTracePortNum=49151  lcrId=${lcrId}
    taf.nms.netact.Upload Configuration   PLMN-PLMN/MRBTS-${mrbts_id}		alias=netact_allias
    taf.nms.netact.Provision Plan		plan_name=${plan_name}		dist_names=${MRBTS_DN}
    ...	    backup_plan_name=${plan_name}_backup
    ...     create_backup_plan=${True}		provisioning_operation=activate	    alias=netact_allias

SWM setup
    [Documentation]    Short description.
    ${active_sw_version}=       Infomodel Get Active SW Version      module=MSM     im_param=activeBuildDescriptorId
    Set Test Variable     ${active_sw_version}     ${active_sw_version}
    ${release_num_for_CNI}=     Fetch From Left     ${active_sw_version}     _
	${downgrade}=    Downgrade Bts Release
	Create Directory    /home/ute/btsauto/TARGET_SW_2/
	${SW_path_T2}=    set variable    /home/ute/btsauto/TARGET_SW_2/
	${release_list}=    get_enb    SBTS${downgrade}
    set suite variable    ${release_list}
	set suite variable    ${release_list_1}    ${release_list[-1]}
	#${SW_path_T2_package}    Download_Specify_Build_By_Aria    ${release_list_1}    Basic    ${SW_path_T2}
	#set suite variable    ${SW_path_T2_package}

	${taf_config_model}=   Run keyword and return status    Variable should exist    ${tl}
    Set test variable    ${TAF_CONFIG_MODEL}    ${taf_config_model}
    set test variable    ${ENB_BRANCH}    ${downgrade}
    set test variable     ${TESTLINE_NAME}    ${host_name}
	Log    Start sw downgrade    console=True
	#update software    ${SW_path_T2_package}     timeout=80min
	Sleep     20min
	Wait Until Keyword Succeeds     20min    5sec    Verify BTS proceduralState    OnAir

	block_rat    WCDMA

get all cell id for bts
    [Documentation]    Short description.
     ${cell_list}=    Admin Get LTE CELL parameters list      default
     ${length}=     Get Length     ${cell_list}
     ${length}=    Evaluate    ${length}-1
     ${cell_id_list}=     Create List      '${cell_list}[0][3]'
     FOR      ${cell}    IN RANGE    1    ${length}
        Append To List   ${cell_id_list}     '${cell_list}[${cell}][3]'
     END
     Set Test Variable    ${cell_id_list}   ${cell_id_list}
     Log To Console    ${cell_id_list}
     Clear plans in CM    MRBTS-${mrbts_id}
     FOR      ${cell}     IN RANGE     ${length}
        Log to console    ${cell_list}[${cell}][3]
        Create MTRACE for each cell     ${cell_list}[${cell}][3]     ${cell}    ${cell_list}[${cell}][1]     ${lnbts_id}
     END

Precondition
    [Documentation]    Short description.
   Common TC Setup For Trace
   SWM setup
   Set Up UE	${UE1}

B009399_Analyze_a_trace_data_after_BTS_SW_upgrading Teardown
    [Documentation]    Short description.
    Common TC Teardown For Trace

Step 1:create cell trace on downgrade release, make a call, check cell trace
    [Documentation]    Short description.
    #taf.sbts.oam.coam.admin.connect_to     bts_host=10.97.91.19
    get all cell id for bts
    UE RRC ACTIVE with random cell   	interval=30	   UE_alias=UE1	    required_ue=${UE1}
    ${output}=    emil_decoder.decode_recent_logs    \"C:\\Sacks\\LN23.0_Cell_Trace\"     2     ${lnbts_id}
    Log    ${output}    console=True

Step 2:SW upgrade to target release
    [Documentation]    Short description.
	Create Directory    /home/ute/btsauto/TARGET_SW/
	${SW_path_now}=    set variable    /home/ute/btsauto/TARGET_SW_2/
	${release_list_now}=    get_enb    ${target_release}
    set suite variable    ${release_list_now}
	set suite variable    ${release_list_1}    ${release_list_now[-1]}
	${SW_path_package}    Download_Specify_Build_By_Aria    ${release_list_1}    Basic    ${SW_path_now}
	set suite variable    ${SW_path_package}
	Log    Start sw downgrade    console=True
	taf.sbts.oam.coam.admin.update software    ${SW_path_package}     timeout=80min
	Sleep    10min
	Wait Until Keyword Succeeds     20min    5sec    Verify BTS proceduralState    OnAir

	block_rat    WCDMA

Step 3:Trace can be stop
    [Documentation]    Short description.
    reset_admin
    Delete CTRLTS Object

Downgrade Bts Release
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${Final_release}: <description>
    #Set Test Variable    ${modify_release}   0
    ${split_to_release}=    Split string         ${active_sw_version}    separator=\_
    ${match}  ${split_build}  ${split_build_1}=    		Should Match Regexp 	 ${split_to_release[0]}	    SBTS(\\d+)R(\\d+)
    ${release_component}=    Convert To Integer      ${split_build}
    ${release_component_1}=    Convert To Integer     ${split_build_1}
    ${Final_release}=      Run Keyword if     ${release_component_1} == 1
    ...  Catenate    SEPARATOR=    ${${release_component}-1}     R	   4
    ...  ELSE    Catenate    SEPARATOR=    ${release_component}     R	   ${${release_component_1}-1}
    [return]	  ${Final_release}
