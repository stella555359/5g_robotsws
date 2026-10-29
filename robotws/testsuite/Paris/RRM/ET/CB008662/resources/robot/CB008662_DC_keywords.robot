*** Settings ***
Documentation     [SUITE PURPOSE]  KWs of CB008662 step DC
...
...               Test Case Scenario author   : Nasmoudine TOYB
...               Test Case Scenario contact  : nasmoudine.toyb@nokia.com
...               Test Case automation author : Nasmoudine TOYB
...               Test Case automation contact: nasmoudine.toyb@nokia.com
...               Creation Date               : 28-September-2022
...               Modified Date               : 06-October-2022
...               Last Modified by            : nasmoudine.toyb@nokia.com



Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource          ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/RdCounters.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot

Resource          ./CB008662_keywords.robot

Library           taf.config.scf                WITH NAME      scf
Library           Collections
Library           ute_fsmaccess
Library           taf.wts.runner                WITH NAME      wtsemu
Library           ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME     coam_parameter
Library           taf.sbts.oam.coam.admin           WITH NAME   sbts_coam


*** Variables ***
${UL_traffic_duration_DC}           300
${TTI_trace_duration_DC}            10

${UL_troughput_DC}                  70

${gnb_alias_DC}                     gnb_under_test


${MaxAdaptiveReTxErrorRatio_DC}     3

${min_nbr_OK_pusch_trans_mcs30_DC}          3500
${min_nbr_NOK_pusch_trans_mcs30_DC}         100

#Parameters to set in SCF
&{TDD_DC_1}
...    actAdaptiveReTxResMcs=true
...    actDynUlResAlloc=true
...    minPctResourceReservedMcsDl=50
...    minPctResourceReservedMcsUl=50
...    targetPctResourceReservedMcsDl=100
...    targetPctResourceReservedMcsUl=100
...    actDlPtrs=false
...    csiReportPeriodicity=slots80
...    actUl256Qam=false

# Hardcode the MCS to 16 in gNB swconfig.txt
${UL_MCS_RDPARAM}        0x580010
${MCS_16}                0x00010000

*** Keywords ***

TC 8662 TDD Interaction 6878 Traffic MUes
    [Documentation]                 This test check the interaction of the adptative retransmission with 6878 feature.
	...                             The aim is to verify that MCS reserved is used when the number of 
	...                             available UL REs decreases
    ...                             because the pCSI PUCCH area increase because of more connected UEs. 
	[Arguments]         ${param}
	
	Init Sequence       ${param}
	
	Critical Step       Set Context TDD 8662
    Critical Step       Update Gnb Swconfig File
	Critical Step       Restart TL
	Step                Init Capture
	Critical Step       Cell Setup Multi UE
    Critical Step       Register Multi UE                         depends=UE Cell Setup Check
    Critical Step       Launch PDU Session Multi UE               depends=CallSetup.UE Attach Check
	Run Keyword If      ${enable_sherpa} == ${True}               Activate Sherpa
	Step                Start Capture L1L2                        depends=Launch PDU Session Multi UE
	Step                Launch Traffic UL UE1                     depends=Launch PDU Session Multi UE
	Step                Add BLER With SINR Test Mode To UE1       sinr_target_pusch=-359     noise_pusch=-759
	${zoi}              ZOI Start
	#05/10/22 : Issue with TTI trace "No keyword with name 'ttitrace_tools.get source IP address'"	
	#Run Keyword If      ${enable_sherpa} == ${False}     Step     Start TTI Traces      depends=Launch PDU Session Multi UE
	#Run Keyword If      ${enable_sherpa} == ${False}     Step     Stop TTI Traces       depends=Start TTI Traces
	Step                Stop Capture L1L2                         depends=Start Capture L1L2
	Run Keyword if      ${enable_sherpa}==${True}                 Deactivate Sherpa and Stop Collect
	#Step                Convert TTI Traces                        depends=Stop TTI Traces
	ZOI Wait End        zoi=${zoi}
    Step                Stop Traffic UL UE1                       depends=Launch Traffic UL UE1
    Step 	            Return Counter Values 
    Step                Validation TC DC01	                      depends=Return Counter Values
	
	[Teardown]                      Display diagnosis

TC 8662 TDD Interaction 6878 Traffic MUes OFF
	[Arguments]         ${param}
	
	Init Sequence       ${param}
	Step                Init Capture
	Step                Start Capture L1L2
	Traced Sleep        5s
	Step                Stop Capture L1L2                         depends=Start Capture L1L2
	
	
Validation TC DC01
    [Documentation]              With the feature CB006878 the number of available PRBs on PUSCH may change 
	...                          per slot depending on the Format 3 REs (pCSI), which are allocated 
	...                          by the RRC Connected UEs.
    ...                          This test aims at checking that MCS reserved is used in case the number of available
	...                          UL REs decreases 3 REs (pCSI) because the pCSI PUCCH area increase
    ...                          because of more connected UEs.	
    Dated Log    [Evaluating the counters to valid the test]

    Should Be True     ${nbr_OK_pusch_trans_mcs30} > ${min_nbr_OK_pusch_trans_mcs30_DC}
	Should Be True     ${nbr_NOK_pusch_trans_mcs30} <= ${min_nbr_NOK_pusch_trans_mcs30_DC}

Return Counter Values
    [Documentation]              Return the values of following counters:
	...                          M55302C05030=Successful PUSCH transmissions by any transmission using MCS 30
	...                          M55302C03030=Unsuccessful PUSCH transmissions by last HARQ reTx using MCS 30
    ${pm_path}    Counters.Collect PM files from BTS    ${LOG_PATH}/PM

    ${count_5030_value}    Retrieve Earliest Single Counter Value From Pm File         pm_path=${pm_path}    
	...                                              counter_name=M55302C05030  
	${count_3030_value}    Retrieve Earliest Single Counter Value From Pm File         pm_path=${pm_path}    
	...                                              counter_name=M55302C03030  
	Set Suite Variable    ${nbr_OK_pusch_trans_mcs30}    ${count_5030_value}
	Set Suite Variable    ${nbr_NOK_pusch_trans_mcs30}    ${count_3030_value}
	
	Dated Log      M55302C05030 (Successful any PUSCH retransmission with MCS30) = ${nbr_OK_pusch_trans_mcs30}
	Dated Log      M55302C03030 (Unsuccessful last PUSCH retransmission with MCS30) = ${nbr_NOK_pusch_trans_mcs30}

Cell Setup Multi UE
    CallSetup.Setup Wtsemu SA    nbUe=6   nbSaUe=6    shouldUseLua=True

Register Multi UE
	FOR    ${i}     IN RANGE    1    7
	    CallSetup.UE Register   ue=${i} 
	
	END

Launch PDU Session Multi UE
	FOR    ${i}     IN RANGE    1    7
	    CallSetup.Launch PDU Session              ue=${i}    pdu=${i}  
	END

Init Capture
    ${CaptureL1L2}                  Capture L1L2 Set Upon Config            airscale=${GNB_DU}
    Capture Init                    ${CaptureL1L2}                          withTN=True
    Set Suite Variable              ${CaptureL1L2}

Start Capture L1L2
    Capture Start                   capture=${CaptureL1L2}

Stop Capture L1L2
    Capture Stop                    capture=${CaptureL1L2}    additionalFilter=not eth[28:2]==e1:11
	
Update Gnb Swconfig File
    ${UL_MCS_RDPARAM_swconfig}=              Create dictionary    field=${UL_MCS_RDPARAM}    value=${MCS_16}
    ${param_list_rad_param}=         Create List                    ${UL_MCS_RDPARAM_swconfig}
    ${console_msg}                   Evaluate     "Updating RAD params on gNB ${UL_MCS_RDPARAM_swconfig}"
    Set Fields in swconfig DU        param_list=${param_list_rad_param}

Start TTI Traces
    ${TTIdir}           Get TTI Trace Path                 dir_suffix=DC_1
	Dated Log New Line              ${trcColor}=== Start TTI traces capture ${defColor}
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2
    Traced Sleep                    ${TTI_trace_duration_DC}               msg=TTI traces capture
	Set Suite Variable              ${TTIdir}

Stop TTI Traces
    ${TTIpcap}                      Stop TTI Traces in Streaming mode
    ...                             tti_trace_path=${TTIdir}
    ...                             tti_trace_filename=TTITrace_DC_1
	Set Suite Variable              ${TTIpcap}
	
Convert TTI Traces
    ${TTIjson}                      Convert TTItrace from pcap to others
    ...                             input_file_path=${TTIpcap}
    ${TTIcsv}                       decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}
	...                             num_of_events=50000

Launch Traffic UL UE1    
    Traffic UE UL                   ueSetting=${BASIC_UE_SA}
    ...                             throughput=${UL_troughput_DC}
    ...                             shouldBeStop=False
    ...                             shouldBeCheck=False
    ...                             duration=5s
    ...                             deviation=5

Stop Traffic UL UE1
    Traffic Stop                    ueSetting=${BASIC_UE_SA}             dir=ul
	
Add BLER With SINR Test Mode To UE1 
    [Arguments]    ${ue_id}=1       ${sinr_target_pusch}=-350   ${noise_pusch}=-800
	Dated Log    [Adding BLER with SINR test mode to UE${ue_id}]
    wtsemu.ul_sinr_testmode_nr             profile_id=1             
	...                                    sinr_target_pusch=${sinr_target_pusch}    
	...                                    noise_pusch=${noise_pusch}
    wtsemu.ue_testmode_set_nr              id=${ue_id}      
	...                                    testmode=ul_sinr     
	...                                    action=activate      
	...                                    profile_id=1
    wtsemu.ul_sinr_testmode_nr             profile_id=1
	Sleep     10s

Set Context TDD 8662
    [Tags]                          SETUP
    Copy File                       ${SCF_SETUP_PATH}     ${SCF_SETUP_PATH}.ori
    ${scf_file_name}                Fetch from right      ${SCF_SETUP_PATH}      /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${scf_name_for_update}            catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...                               _8662_TDD.xml
    ${scf_file_update_path}          set variable    ${LOG_PATH}/${scf_name_for_update}
    SCF StartSession                scf_file=${SCF_SETUP_PATH}
    ${modify_param}                 Set Parameters SCF    ${param}
    SCF StopSession                 scf_file=${scf_file_update_path}

    ${TestName}                     getFormattedName
    Copy File                       ${LOG_PATH}/${scf_name_for_update}     ${LOG_PATH}/SCF_${TestName}.xml

    OAM Perform Full Commissioning  scf_file=${scf_file_update_path}
    Airscale Wait for Ready         ${GNB_DU}

Set Parameters SCF
    [Documentation]                 Set parameters in SCF
    [Arguments]                     ${param}
    FOR    ${i}     IN RANGE    1    3
	       ${dn}             set variable           MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${i}
			SCF Set element                 dist_name=${dn}      element_name=actAdaptiveReTxResMcs
			...                             element_value=${param.actAdaptiveReTxResMcs}
			SCF Set element                 dist_name=${dn}      element_name=actDynUlResAlloc
			...                             element_value=${param.actDynUlResAlloc}
			SCF Set element                 dist_name=${dn}      element_name=minPctResourceReservedMcsDl
			...                             element_value=${param.minPctResourceReservedMcsDl}
			SCF Set element                 dist_name=${dn}      element_name=minPctResourceReservedMcsUl
			...                             element_value=${param.minPctResourceReservedMcsUl}
			SCF Set element                 dist_name=${dn}      element_name=targetPctResourceReservedMcsDl
			...                             element_value=${param.targetPctResourceReservedMcsDl}
			SCF Set element                 dist_name=${dn}      element_name=targetPctResourceReservedMcsUl
			...                             element_value=${param.targetPctResourceReservedMcsUl}
			SCF Set element                 dist_name=${dn}      element_name=actDlPtrs
			...                             element_value=${param.actDlPtrs}
			SCF Set element                 dist_name=${dn}      element_name=csiReportPeriodicity
			...                             element_value=${param.csiReportPeriodicity}
			SCF Set element                 dist_name=${dn}      element_name=actUl256Qam
			...                             element_value=${param.actUl256Qam}
			${console_msg}                  Evaluate     "Database Modifications completed for NRCELL-${i}"
			Dated Log                       ${console_msg}
	END
