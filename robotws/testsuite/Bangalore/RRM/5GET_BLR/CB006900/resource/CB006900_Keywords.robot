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

Validate DL Data Traffic For SA for high data
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Maximum data rate
    ...                     timeout=30
    Check Maximum Rate     ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss for high data      ${bearer_stat_dl}    ${bearer_stat_dl}

Validate UL Data Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Maximum data rate
    ...                     timeout=30
    Check Maximum Rate     ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}


