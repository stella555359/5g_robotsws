*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS23R1    SBTS23R2    CONFIGURED

Documentation
...
...				author       : B,Padmashree <padmashree.b@nokia.com>
...             maintainer   : B,Padmashree <padmashree.b@nokia.com>
...             Introduction : This testcase describes the gNB behavior for UE in RRC_INACTIVE state that is successfully 
...								transitioned from RRC_INACTIVE to RRC_CONNECTED state and resume of SRBs and DRBs. 
...							Successful Resume procedure.  
...             Test Set Name: CB008225_D_B1_9 Successful RESUME procedure for UE in RRC Inactive State - Inactivity based
...					on UE is configured per slice  slice1 is ranAC enabled  Slice2 is ranAC disabled  DL User Data_5QI6_TDD_ASOE 
...             Testing Split: CB008225 Split D testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008225 CFAM
...             RequirementID: 5G_RAN_USR_RRM_19071

Resource         resources/CB008225_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Add RD Parameters To GNB Swconfig File      ${radparam}
...                 AND     Perform SCF Delta Commissioning with Delta_Config_NonRANsha_InactBased-DRBlevel-PerSlice_gASOE-apLO_TDD.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces       ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...					AND		kill_ue
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/basic_setup_db1_9_2CC_gOE-apLO_ref.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TEST_NAME}        test_case

${start_ue_id}      ${1}
${end_ue_id}      ${1}
${delta}       30
${inactivity_timer}      120
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6
@{QOS_Prof1_speed_dl}      1
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps
&{nwslices}    ${1}=1    ${2}=2    ${3}=2
@{cause_list}       8   8
${duration}          60
${trf_id}          ${1}
${radparam}                SEPARATOR=${EMPTY}    0x890073 = 0

*** Test Cases ***
[1][1.0] CB008225_D_B1_9 Successful RESUME procedure for UE Inactive State UE configured per slice slice1 rannAC enabled Slice2 ranAC 5QI6_TDD_ASOE
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof1}             ${3}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof1_speed_ul}    ${3}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof1_speed_dl}    ${3}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof1_unit}        ${3}=${QOS_Prof1_speed_dl}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on                       ${3}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=inactive                  ${3}=inactive
	${state2}                  Create Dictionary          ${1}=idle               ${2}=idle                  ${3}=idle
	${state1}                  Create Dictionary          ${1}=INACTIVE               ${2}=IDLE                  ${3}=inactive
	${state3}				 Create Dictionary          ${1}=ACTIVE               ${2}=ACTIVE                  ${3}=inactive
	${trigger}             Create Dictionary             ${1}=dldata_ranpaging                  ${2}=dldata_ranpaging       ${3}=dldata_ranpaging
	Set Suite Variable    ${nwslice_ID}      &{nwslices}
	Modify NIDD parameters     paramName=drbInactivityTimerSA       paramValue=60       operation=update       paramDst=MRBTS-1/NRBTS-1
	
    set test variable      ${LOG_PATH}
    #Verify RRCInactive_IE from SIB1     ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    log to console   UE attach trigerring now ${end_ue_id}....
	
	Start Log      btslog     cprt
	${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI Multi Slice     ${start_ue_id}    ${end_ue_id}   
    ...     ${nwslice_ID}   cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
	Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}
    ...        state=${state}
	Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
	Modify NIDD parameters     paramName=ranAC       paramValue=0       operation=delete       paramDst=MRBTS-1/NRBTS-1/NRCELL-2
    ${output}   Read WTS Output For Pattern And Print matching Lines     .*SystemInformationBlockType1-NR updated*.    ${Timeout_SA}
    Trigger_rna_update_to_cell      ${end_ue_id}    2   resume_request_1    rna_Update
	Comment		Sleep till drbinactive timer expires
	Sleep	60s
    Check MultiUE RRC State Idle        ${end_ue_id}
	Check MultiUE UE State Display       ${start_ue_id}    ${end_ue_id}        state=${state1}
	Trigger_AMF_initiated_paging	1	${end_ue_id}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    dl   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
	Check MultiUE UE State Display       ${start_ue_id}    ${end_ue_id}        state=${state3}
	${scen1}     Stop Log      btslog     cprt
    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap        ${start_ue_id}      ${start_ue_id}   ${qos_profile}
    ...       ${full_rnti_list}     cause_list=${cause_list}		state=${state}        activityNotify=dRB		split=resume    cipher=on
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
kill_ue
	wtsrunner.ue_kill		id=1-2
	

Trigger_rna_update_to_cell
    [Arguments]        ${ue_idx}    ${cell_idx}     ${message}      ${cause}
    wtsrunner.ue_nr_rrc_resume_request_param    id=${ue_idx}    gnb=2   cell=${cell_idx}     msg=${message}   cause=${cause}
    wtsrunner.ue_nr_rrc_resume        id=${ue_idx}
	${output}   Read WTS Output For Pattern And Print matching Lines     .*rna-Update*.    ${Timeout_SA}
	${output}   Read WTS Output For Pattern And Print matching Lines     .*UE${ue_idx}: UE performed Registration*.    ${Timeout_SA}
	
Trigger_AMF_initiated_paging
	[Arguments]		${paging_id}		${ue_idx}
	wtsrunner.amf_paging_param		default_drx=256		id=${paging_id}
	wtsrunner.amf_paging_start		id=${paging_id}		ueid=${ue_idx}
	Sleep	10s
    ${output}   Read WTS Output For Pattern And Print matching Lines     .*UE${ue_idx}: RrcState: NR CONNECTED*.    ${Timeout_SA}
