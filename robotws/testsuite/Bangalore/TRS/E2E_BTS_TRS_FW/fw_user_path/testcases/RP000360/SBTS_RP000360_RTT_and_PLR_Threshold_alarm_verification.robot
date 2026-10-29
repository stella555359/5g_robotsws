*** Settings ***
Documentation
...			   [Procedure]		"This TC needs to configure the TWAMP related parameters for both Sender And Reflector using Commissioning. The mocks
...	should be present in the SCFC file. The scripts for reflector should be present in /home/trsiv/twamp and /home/trsiv/twamp/udpecho"

...            [Maintenance]    "TRS IV Test Bangalore Team"

variables       ta_e2e_bts_trs_fw
Resource    taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    ${CURDIR}/../resources/common_keywords.robot

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops


*** Test Cases ***
[1][1.0] SBTS_RP000360_RTT_and_PLR_Threshold_alarm_with_counter_verification
    Call Setup  lte=Plain_config_CUS:data   parallel=${False}   verify_attach=${False}  attach=${False}
#a    Set Suite variable      ${Operation}    create
    Perform Recommissioning     type=delta      delta_file=${twamp_sender}      timeout=60
    Sleep   60
    ${TWAMP_Reflector} =    Get Parameter       param_path=${TWAMP_Ref}
    log     ${TWAMP_Reflector}

####PLR Verification####
    Perform Recommissioning     type=param      param_path=${twamp_session}     operation=update    value=unlocked      timeout=60
    Perform Recommissioning     type=param      param_path=${twamp_RTT}     value=20000   operation=update      timeout=60
	${Twampstatics}=	Get Twamp Session Statistics	twamp_id=1
    sleep	900
	Verify PLR Threshold Exceeded
	Verify Alarm	faultid=61611
    ${pid} = 	Run     cat pid.txt
	Set Suite Variable	${pid}	${pid}
    sleep	1820
	Verify PLR Threshold Reduce
	Verify Alarm 		faultid=61611		should_exist=${False}
#a    Verify unexpected alarms

####RTT Verification####
    Perform Recommissioning		type=param		param_path=${twamp_RTT}		value=200	operation=update
	${Twampstatics}=	Get Twamp Session Statistics	twamp_id=1
    Wait Until Keyword Succeeds     5 min	60 sec	Verify RTT Threshold Exceeded
    sleep  60
	Verify Alarm	faultid=61610
    Perform Recommissioning     type=param      param_path=${twamp_RTT}     value=20000   operation=update
	Wait Until Keyword Succeeds	5 minute	1 min	Verify RTT Threshold Reduce
	sleep	300
	Verify Alarm 		faultid=61610   should_exist=${False}

####100_PLR_RTT####
    Perform Recommissioning     type=delta       delta_file=${IPIF_IPRT}        skip_parameter_relation_errors=${True}      timeout=300
    Sleep   30
#a    Set Suite variable    ${Operation_1}    create
    Perform Recommissioning     type=delta       delta_file=${100_Twamp_sender_PLR_RTT}        skip_parameter_relation_errors=${True}     timeout=300
    Sleep   920
    Verify Alarm    faultid=61611   occurrences=100
    Sleep   70
    Verify Alarm    faultid=61610   occurrences=100
#a    Set Suite variable      ${Operation_1}    delete
    Perform Recommissioning     type=delta       delta_file=${100_Twamp_sender_PLR_RTT_delete}        skip_parameter_relation_errors=${True}
	...		timeout=300
    Sleep   30
 	Verify Alarm 		faultid=61611		should_exist=${False}
	Verify Alarm 		faultid=61610		should_exist=${False}

*** Keywords ***
Verify PLR Threshold Exceeded
##  Fetch the loss_packet and transmitted_packet from the BTS commands
	${Twampstatics}=	Get Twamp Session Statistics	twamp_id=1
	${PLRThreshold}=	Get From Dictionary	${Twampstatics}	plrAlarmThreshold
	${Statistics}=	Get From Dictionary	${Twampstatics}	twampStatistics
	${transmitted_packet}=	Get From Dictionary	${Statistics}	txTwampMessages
	${loss_packet}=	Get From Dictionary	${Statistics}	lostTwampMessages
	${avgPLR} = 	Evaluate	(${loss_packet}*100) / ${transmitted_packet}
	Should Be True	${avgPLR}>=${PLRThreshold}	msg=Average PLR threshold exceeded

Verify PLR Threshold Reduce
	${Twampstatics}=	Get Twamp Session Statistics	twamp_id=1
	${PLRThreshold}=	Get From Dictionary	${Twampstatics}	plrAlarmThreshold
	${Statistics}=	Get From Dictionary	${Twampstatics}	twampStatistics
	${transmitted_packet}=	Get From Dictionary	${Statistics}	txTwampMessages
	${loss_packet}=	Get From Dictionary	${Statistics}	lostTwampMessages
	${avgPLR} = 	Evaluate	(${loss_packet}*100) / ${transmitted_packet}
	Should Be True	${avgPLR}<${PLRThreshold}	msg=Average PLR threshold not exceeded

Verify RTT Threshold Exceeded
##  Fetch the loss_packet and transmitted_packet from the BTS commands
	${Twampstatics}=	Get Twamp Session Statistics	twamp_id=1
	${RTTThreshold}=	Get From Dictionary	${Twampstatics}	rttAlarmThreshold
	${Statistics}=	Get From Dictionary	${Twampstatics}	twampStatistics
	##${transmitted_packet}=	Get From Dictionary	${Statistics}	txTwampMessages
	${avgRTT}=	Get From Dictionary	${Statistics}	avgRTT_1Min
	##${avgPLR} = 	Evaluate	(${loss_packet}*100) / ${transmitted_packet}
	Should Be True	${avgRTT}>=${RTTThreshold}	msg=Average RTT threshold exceeded

Verify RTT Threshold Reduce
	${Twampstatics}=	Get Twamp Session Statistics	twamp_id=1
	${RTTThreshold}=	Get From Dictionary	${Twampstatics}	rttAlarmThreshold
	${Statistics}=	Get From Dictionary	${Twampstatics}	twampStatistics
	##${transmitted_packet}=	Get From Dictionary	${Statistics}	txTwampMessages
	${avgRTT}=	Get From Dictionary	${Statistics}	avgRTT_1Min
	##${avgPLR} = 	Evaluate	(${loss_packet}*100) / ${transmitted_packet}
	Should Be True	${avgRTT}<${RTTThreshold}	msg=Average RTT threshold reduced
