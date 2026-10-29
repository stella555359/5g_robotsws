*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Sunil
...              :contact: sunil.t_kurian@nokia.com
Resource         ../../CB008541/resources/CB008541_Keywords.robot
Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../resources/robot/Airphone.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../resources/robot/PM_Counters.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../resources/robot/Setup_Env.robot
Library          ../../resources/python/BIP_Capture.py
Library          ../../resources/python/CPRT_Capture.py
Library          ../../resources/python/avg_dl_data.py

*** Variables ***

*** Keywords ***
Start Big UL Data Transfer
	[Arguments]    ${UE_ID}
	[Documentation]     this KW will start 230 Mbps UL data for 2UL MIMO
	Trigger UL Data Traffic for SA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=100       trf_id=11
    sleep   5s    reason=Wait for successful traffic start
	Trigger UL Data Traffic for SA    ue_id=${UE_ID}     Traffic_rate=mbps     ul_rate=100       trf_id=12
	sleep   5s    reason=Wait for successful traffic start

Stop Big UL Data Transfer
	[Arguments]    ${UE_ID}
	[Documentation]     this KW will stop 230 Mbps UL data for 2UL MIMO
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=11    dir=ul     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=12    dir=ul     pdu_id=${Pdu_session_ID}
	sleep   5s    reason=Wait for successful traffic stop
