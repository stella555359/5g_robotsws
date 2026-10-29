*** Settings ***
Documentation
...            [Maintenance]    "TRS IV Test Bangalore Team"

variables       ta_e2e_bts_trs_fw
Resource    taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource    ${CURDIR}/../resources/common_keywords.robot

Suite Setup        Run Keywords    Suite Setup Preconditions
...        AND     Setup Oamops
Suite Teardown     Run Keywords        Suite Teardown Postconditions
...        AND     Teardown Oamops

Force Tags          CA_E2ET_BTSTRSPZ        SBTS00        [SBTS23R1]     RAN_4G    RAN_4G_FDD       QCD_MN_RAN        QCP_RAN_VRF        CRT

***Variables***
${reflector}        ${CURDIR}/../resources/twamp_reflector/


*** Test Cases ***
[1][1.0] SBTS_RP000360_RTT_and_PLR_Threshold_alarm_with_counter_verification

    Pre_condition
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
    Run     sudo chmod 777 ${twamp_exe_file}
    Run     sudo python ${reflector}.\/twampy.py responder ${TWAMP_Reflector}:5018 --padding 100 -d > tp_pt_5018.txt & echo $! > pid.txt
    ${pid} = 	Run     cat pid.txt
	Set Suite Variable	${pid}	${pid}
    sleep	1820
	Verify PLR Threshold Reduce
	Verify Alarm 		faultid=61611		should_exist=${False}

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
    Run     for pid in $(ps -ef | grep twamp | awk '{print $2}'); do sudo kill -9 $pid; done
    Perform Recommissioning     type=delta      delta_file=${twamp_sender_delete}      timeout=60

####100_PLR_RTT####
    Perform Recommissioning     type=delta       delta_file=${IPIF_IPRT}        skip_parameter_relation_errors=${True}      timeout=300
    Sleep   30
    Perform Recommissioning     type=delta       delta_file=${100_Twamp_sender_PLR_RTT}        skip_parameter_relation_errors=${True}      timeout=300
    Sleep   920
    Verify Alarm    faultid=61611   occurrences=100
    Sleep   20
    Run         sudo python ${twampy.py} responder --load_json ${sample.json} --section 1 2 3 4 --padding 100 -d >twamp.txt & echo $! > pid.txt
    ${pid} =    Run     cat pid.txt
    Sleep   70
    Verify Alarm    faultid=61610   occurrences=100
    Perform Recommissioning     type=delta  delta_file=${100_Twamp_sender_PLR_RTT_delete}  skip_parameter_relation_errors=${True}    timeout=300
    Sleep   30
 	Verify Alarm 		faultid=61611		should_exist=${False}
	Verify Alarm 		faultid=61610		should_exist=${False}
    [Teardown]  Kill Reflector

*** Keywords ***
Pre_condition
    Run     sudo ifconfig eth3.${vlan_ids}[0] inet add 10.0.3.209
    Run     sudo ifconfig eth3.${vlan_ids}[0] inet6 add fc00::1/126
    Run     sudo ifconfig eth3.${vlan_ids}[0] inet6 add fc00::3:6/126
    taf.ul.trs_e2e_fw.lib.oam.oam_interface.Perform Commissioning       scf_file=${base_scf}   verify_bts_status=True     timeout=400   alias=default

Verify PLR Threshold Exceeded
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

Kill Reflector
    Run     for pid in $(ps -ef | grep twamp | awk '{print $2}'); do sudo kill -9 $pid; done
