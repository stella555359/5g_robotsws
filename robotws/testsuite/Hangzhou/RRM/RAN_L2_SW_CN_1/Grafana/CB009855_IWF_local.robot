*** Settings ***
Suite Setup
Suite Teardown
Resource          ./../CUDU_L2/common_setup_teardown.robot
*** Variables ***
${GNB_BUILD}    SBTS00_ENB_9999_231023_000005
${AP_BUILD}     4.0.27100
${WTS_DIR}      /opt/wts/latest
${wts_lua}      198_UEs_6_amf_basic_mutitraffic_IWF_200UE_72CAUE_1AMF.lua
${GNB_ID}       11816
${Node_ID}      0x2732
${TM_Event}     EO_L2_PS_CAPUCCH_PREALLOC_ATT2
${CN1}          /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/
${test_repo_python}    /home/ute/.pyenv/versions/3.6.10/envs/test_repo/bin/python
#/home/ute/.pyenv/versions/3.6.10/envs/test_repo/bin/robot
${timemarker_python}    /home/ute/.pyenv/versions/3.9.14/envs/timemarker/bin/python
#trf_data_start ue=1 pdu=1 qfi=1 mbps=175 dir=dl trf_id=1 seconds=48h
${TIMES}    96
${DURATION}    30min
${THROUGHPUT}    5000
*** Test Cases ***
Update GNB By Admin
    [Tags]    update_gnb
    Log To Console    start to update gnb...
    Update GNB

Update Airphone and WTS
    [Tags]    update_ap
    Check GNB And AP SSH Connect OK
    Log To Console    start to update airphone...
    Update Airphone
    Run    cp ${CURDIR}/myconfigs_IWF/${wts_lua} ${WTS_DIR}

TA Case For CB009855 IWF
    [Tags]    run_case
    Log To Console    start to reboot gnb and airphone...
    Reboot TL And Check Configured
    Start Egate
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}    save_egate=${True}
    ute_wtssim.Execute Egate Command    cmd=cfg file\=${WTS_DIR}/${wts_lua}    pass_regexp=SystemInformationBlockType2-NR updated    timeout=2min
    Check All Cells Received SIB2
    SA Single UE Attach    1
    Start SA UE Big DL Traffic Internal    1    ${THROUGHPUT}
    #Install Time Marker Virtualenv
    Send Time Marker For Multi Times    ${TIMES}    ${DURATION}
*** Keywords ***
Update GNB
    Run    /home/ute/test_repo/bin/robot -L trace -v gnb_v:${GNB_BUILD} -d /home/ute/logs/update_gnb/ ${CN1}/CUDU_L2/tools/update_gnb.robot
    Insert Log To Database    11816    update gnb to version ${GNB_BUILD}    TA script

Update Airphone
    Run    /home/ute/test_repo/bin/robot -L trace -v airphone_v:${AP_BUILD} -d /home/ute/logs/update_ap/ ${CN1}/CUDU_L2/tools/update_airphone.robot
    Insert Log To Database    11816    update airphone to version ${AP_BUILD}    TA script

Start Egate
    Run    ps aux|grep -E 'egate|edaemon';sudo pkill edaemon;sudo pkill egate;cd /opt/iphy/latest;sudo ./edaemon --port 22222; ./egate --port 20000;
    Sleep    5s

Insert Log To Database
    [Arguments]    ${gnb_id}    ${log}    ${executor}
    Run    ${test_repo_python} ${CURDIR}/operate_gnb_record_postgres_database.py insert '${gnb_id}' '${log}' '${executor}'

Install Time Marker Virtualenv
    Run    pyenv virtualenv-delete -f timemarker; pyenv virtualenv 3.9.14 timemarker;
    Run    pyenv activate timemarker; pip install pandas==1.3.1; pip install psycopg2; pip install packaging; pip install tzdata;pip list

Send Time Marker
    ${cmd}=  Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 '(sleep 1s; echo \"touch
    ...    /tmp/node_L2RT21/tmp/timeMarkerTrigger/trigger\"; sleep 2s; echo \"cp /tmp/node_L2RT21/tmp/L2RtCpu_TimeMarkerSnapshot.txt
    ...    /ffs/run/logs\"; sleep 1s;) | bsh 1:0'
    Run    ${cmd}
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:/ffs/run/logs/L2RtCpu_TimeMarkerSnapshot.txt /home/ute
    Run    ${timemarker_python} /home/ute/tm2chrome/tm2chrome.py -f /home/ute/L2RtCpu_TimeMarkerSnapshot.txt -c -t;
    ${cmd}=  Catenate    ${timemarker_python} /home/ute/tm2csv/csv2pg.py /home/ute/L2RtCpu_TimeMarkerSnapshot.txt.csv
    ...    $(TZ="Asia/Shanghai" date +"%Y-%m-%dT%H:%M:%S") ${GNB_BUILD} ${GNB_ID} ${Node_ID} ${TM_Event}
    Run    ${cmd}

Send Time Marker For Multi Times
    [Arguments]    ${times}=96    ${duration}=30min
    FOR    ${i}    IN RANGE    1    ${times}+1
        Log To Console    Check UE Status for ${i} times...
        #Check UE Status
        Check UE Status Every One Minute
        Log To Console    Send Timer marker for ${i} times...
        Send Time Marker
        #Sleep    ${duration}
    END

Check UE Status Every One Minute
    [Arguments]    ${duration}=1min    ${time}=30
    FOR    ${i}    IN RANGE    ${time}
        Log To Console    Check UE Status for ${i} times...
        Check UE Status
        sleep    ${duration}
    END

Check UE Status
#UE1: NR UEStats are supported only for Active UE
    [Arguments]    ${UE_ID}=1    ${ca_num}=1
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=${UE_ID} type=pdsch scell=0-31    pass_regexp=EGATE
    Log    ${output}
    ${ret}=    run keyword and return status    Should Not Contain    ${output}    UE1: NR UEStats are supported only for Active UE
    ...    ignore_case=True
    run keyword if    "${ret}"=="${False}"    Collect GNB SnapShot Via AaShell    log_dir=${OUTPUT_DIR}
    run keyword if    "${ret}"=="${False}"    Collect UTE SosReport    ${OUTPUT_DIR}
    run keyword if    "${ret}"=="${False}"    fatal error    UE is released.

#Check UE Status
#    [Arguments]    ${UE_ID}=1    ${ca_num}=1
#    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=${UE_ID} type=pdsch scell=0-31    pass_regexp=EGATE
#    Log    ${output}


Start SA UE Big DL Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${pdu_id}=1    ${trf_id}=1
    [Documentation]    This keyword is to start single UE big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        ${tmp_trf_id}    Evaluate    ${trf_id}+${t_time}-1
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=175 trf_id\=${tmp_trf_id} seconds=48h
        Log To Console    \nUE${ue_id} Start DL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    ${last_trf_id}    Evaluate    ${trf_id}+${dl_times}
    Run Keyword If    '${last_mbps}'!='0'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=dl mbps\=${last_mbps} trf_id\=${last_trf_id} seconds=48h
    Run Keyword If    '${last_mbps}'!='0'    Log To Console    \nUE${ue_id} Start DL ${last_mbps}M Traffic for trf_id=${last_trf_id}

Check All Cells Received SIB2
    [Arguments]    ${gnb_num}=1
    ${egate_file}    Set Variable    /opt/iphy/latest/egate_console.log
    Wait Until Keyword Succeeds    240s    5s    Check Egate Log With Message    ${egate_file}
    ...    SystemInformationBlockType2-NR updated    5
