*** Settings ***
Force Tags      CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CIT    CDRT   RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS24R1    SBTS23R2    CONFIGURED

Documentation
...
...				author       : B,Padmashree <padmashree.b@nokia.com>
...             maintainer   : B,Padmashree <padmashree.b@nokia.com>
...             Introduction : This testcase describes the gNB behaviour for UE in RRC_INACTIVE state that internal 
...		           timer.NRBTS.maxUeRrcInactTime timer is expired. Inactive UE Context is silently released (UE is not notified) 
...             Test Set Name: CB008225_D_E6_2 Silent UE Context Release - NRBTS.maxUeRrcInactTime timer 
...							expiry for RRCINACTIVE UE_5QI6_TDD_ASOE 
...             Testing Split: CB008225 Split D testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008225 CFAM
...             RequirementID: 5G_RAN_USR_RRM_19071

Resource         resources/CB008225_resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Add RD Parameters To GNB Swconfig File      ${radparam} 
...                 AND     Perform SCF Delta Commissioning with Delta_Config_NonRANsha_InactBased-Uelevel_gOE-apLO_TDD.json
...                 AND     sleep    180
...                 AND     gnb.Perform gNB reboot
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces       ${wts_cfg_file}

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
#...                 AND     Link SCOUT SCF to Configuration ID for Reporting
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Variables ***
${wts_cfg_file}     /opt/iphy/latest/basic_setup.cfg
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

${duration}          60
${trf_id}          ${1}
${radparam}                SEPARATOR=${EMPTY}    0x890073 = 0

*** Test Cases ***
[1][1.0] CB008225_D_E6_2 Silent UE Context Release - NRBTS.maxUeRrcInactTime timer expiry for RRCINACTIVE UE_5QI6_TDD_ASOE
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof1}             ${3}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof1_speed_ul}    ${3}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof1_speed_dl}    ${3}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof1_unit}        ${3}=${QOS_Prof1_speed_dl}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on                       ${3}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=inactive                  ${3}=inactive 
	${trigger}             Create Dictionary             ${1}=dldata_ranpaging      ${2}=dldata_ranpaging                   ${3}=dldata_ranpaging
	
	##### Enable t380 to 5min and maxUErrcInacttime to 1min
    Modify NIDD parameters      t380      5min        update      MRBTS-1/NRBTS-1
    Modify NIDD parameters      maxUeRrcInactTime      1        update      MRBTS-1/NRBTS-1
	
    set test variable      ${LOG_PATH}
    #Verify RRCInactive_IE from SIB1     ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    log to console   UE attach trigerring now...
	
	Start Log      btslog     cprt
	${cpnrtb4}		${cprtb4}		${cpnbb4}			Get current resources	ASOE
	${ue_to_bearer_list}      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
	Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}
    ...        state=${state}
	Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
	Comment		Wait till maxuerrcinactivity timer expiry
	Sleep	60s
	# verify if ue release response is seen but ue status is still inactive
    ${max_ue_inac_end}    Verify silent release of ue        ${start_ue_id}       ${end_ue_id}
    ${scen1}     Stop Log      btslog     cprt  snapshot
	${cpnrtaft}		${cprtaft}		${cpnbaft}			Get current resources	ASOE	
	${max_ue_inac_start}    Set Variable    ${inactivity_stop}
	
	#verify time between ue inact to ue release matches MAx UE rrc inactive timer
    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${max_ue_inac_start}        ${max_ue_inac_end}        ${delta}        60
    Verify MultiUE release Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap        ${start_ue_id}      ${end_ue_id}
	Silent Release Resource Validation	${cpnrtaft}		${cpnrtb4}	${cprtaft}		${cprtb4}	${cpnbaft}		${cpnbb4}
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting
