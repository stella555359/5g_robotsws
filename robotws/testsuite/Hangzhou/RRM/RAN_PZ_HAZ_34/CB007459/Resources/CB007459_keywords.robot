*** Settings ***
Documentation
...   This is template of automation testing
...   squad group: MMW_SG1

Variables   ./../TestData/NIDD_modify.py
Resource    ./CB007459_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot


*** Keywords ***
Upload enable and config script to gnb and run script
    [Documentation]    Author:Wang Yixiang
    ...    Descrition： Script to enable and configure feature CB007459 for specific UE
    ...    rdSktPlmnId:26203=>262f03=>62f230=>6484528
    [Arguments]        ${script_path}=${CURDIR}
    ...                ${script_name}=7459_ON_V3.sh
    ...                ${gnb_script_path}=/ffs/run/
    ...                ${connection}=ASIK Master
    ...                ${sleep_time}=5s
    Connect to Common Unit Master    alias=${connection}
    csn.upload_file     local_path=${script_path}${/}${script_name}
    ...                 remote_path=${gnb_script_path}${/}${script_name}
    ...                 connection=${connection}
    ${output1}    csn.execute         command=chmod +x ${gnb_script_path}${/}${script_name}  connection=${connection}
    Should be empty    ${output1}    msg=Fail to change file permission, output message is: ${output1}

    csn.send_command    command=sh /ffs/run/${script_name}    connection=${connection}
    Sleep    ${sleep_time}
    Wait until cluster is on cell on air status

Recover HashContainer files
    [Documentation]    Author:Wang Yixiang
    ...    Descrition： coppy files from /ffs/run/config/toor4nsn/HashContainer_bk/HashContainer* to /ffs/run/
    ...    if not recover HashContainer* files will result in rollback failure
    ...    PR673782: [SBTS22R4][AEWD][Classical][CRT]Rollback failed after upgrading
    [Arguments]        ${connection}=ASIK Master
    Connect to Common Unit Master    alias=${connection}
    ${output1}    csn.execute         command=cp /ffs/run/config/toor4nsn/HashContainer_bk/HashContainer* /ffs/run/
    ...    connection=${connection}
    Should be empty    ${output1}    msg=Fail to recover HashContainer* files
    ${output1}    csn.execute         command=cp /ffs/run/config/toor4nsn/sm6-snowfish_bk/cp-ue_*.txz /ffs/run/swpool/CPLANE-5G/sm6-snowfish
    ...    connection=${connection}
    Should be empty    ${output1}    msg=Fail to recover sm6-snowfish cp-ue_*.txz files
    ${output1}    csn.execute    command=cp /ffs/run/config/toor4nsn/airscale5g-xeon_bk/cp-ue_*.txz /ffs/run/swpool/CPLANE-5G/airscale5g-xeon
    ...    connection=${connection}
    Should be empty    ${output1}    msg=Fail to recover airscale5g-xeon cp-ue_*.txz files
    ${output2}    csn.execute         command=crasign /ffs/run/swpool/CPLANE-5G/airscale5g-xeon/cp-ue_*.txz
    ...    connection=${connection}
    Should be empty    ${output2}    msg=Crasign success
    ${output2}    csn.execute         command=crasign /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_*.txz
    ...    connection=${connection}
    Should be empty    ${output2}    msg=Crasign success
    ${output2}    csn.execute         command=rm -rf /ffs/run/config/toor4nsn/sm6-snowfish_bk
    ...    connection=${connection}
    ${output2}    csn.execute         command=rm -rf /ffs/run/config/toor4nsn/airscale5g-xeon_bk
    ...    connection=${connection}
    ${output2}    csn.execute         command=rm -rf /ffs/run/config/toor4nsn/HashContainer_bk
    ...    connection=${connection}
    csn.send_command         command=reboot    connection=${connection}
    Sleep    10s
    Wait until cluster is on cell on air status

Perform UL ping and check latency
    [Documentation]    Author:Wang Yixiang
    ...    Descrition： Perform UL ping and check latency
    ...    adb -s RFCR10K046N shell ping 10.57.162.4
    [Arguments]    ${ping_latency_expect}=30
    ${ping_result}    Perform UL ping    numberofping=120
    ${ping_latency}    Get ping latency and sort from largest to smallest    ping_result=${ping_result}
    run keyword and continue on failure    should be true    ${ping_latency['avg']}<${ping_latency_expect}
    ...    msg=Average ping latency with specific UE should lower than ${ping_latency_expect}

Perform UL ping and check latency with retry
    [Documentation]    Author:Wang Yixiang
    ...    Descrition： check ping latency three times
    FOR    ${i}    IN RANGE    ${3}
        ${check_ret}    run keyword and return status    Perform UL ping and check latency
        exit for loop if    ${check_ret}==${True}
    END
    Should be true    ${check_ret}    msg=Retry ping latency with 3 times and still failed, please check ping latency

Set actEndcSpidFwd value for LTE
    [Documentation]    Author: Wang Yixiang
    ...    Set actEndcSpidFwd value for LTE    value=false
    [Arguments]    ${value}=true    ${para_update_timeout}=3 min    ${alias}=enblte
    Connect to eNB via ssl    connection=${alias}
    &{actEndcSpidFwd}    Create Dictionary    dist_name=LNBTS-${tl.enbs[0].global_bts_id}
    ...    parameter=actEndcSpidFwd    value=${value}
    @{modify_actEndcSpidFwd}    Evaluate   [&{actEndcSpidFwd}]
    ${update_status}    COAM Update several parameters via rest api
    ...    connection=${alias}     parameters_to_update_via_api=${modify_actEndcSpidFwd}    timeout=${para_update_timeout}
    Should be true    '${update_status}'=='PASS'
    [Teardown]    Enblte close down    connection=${alias}

Set actSPID value for NR
    [Documentation]    Author: Wang Yixiang
    ...    Set actEndcSpidFwd value for NR    value=false
    [Arguments]    ${value}=false    ${para_update_timeout}=3 min    ${alias}=GNB_OAM
    Connect to gnb coam via ssl    connection=${alias}
    &{actSPID}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[0].global_bts_id}
    ...    parameter=actSPID    value=${value}
    @{modify_actSPID}    Evaluate   [&{actSPID}]
    ${update_status}    COAM Update several parameters via rest api
    ...    connection=${alias}     parameters_to_update_via_api=${modify_actSPID}    timeout=${para_update_timeout}
    Should be true    '${update_status}'=='PASS'
    [Teardown]    COAM Teardown gnb connections    connection=${alias}

Check specific UE configuration take effect
    [Documentation]    Author: Wang Yixiang
    ...    Check specific UE configuration take effect
    ...    spid_expect should be equal to rdSktSpId=12 in 7459_ON_V3.sh
    [Arguments]    ${tcpdump_log}    ${spid_expect}=12
    ${filtered_packets}    Load pcap file with filter     log_path_pcap=${tcpdump_log}     filter=x2ap
    @{spid_actual}    Get field value    packets=${filtered_packets}    field_name=x2ap.SubscriberProfileIDforRFP
    ...    attribute_name=show
    should be equal as strings    ${spid_actual}[0]    ${spid_expect}

CB007459 suite setup
    [Documentation]    Author: Wang Yixiang
    ...    Define your own keywords
    [Arguments]    ${scf_modify_parameters}    ${prepare_ue}=${True}
    set suite variable     ${PARAMS_TO_DELETE}    ${ABIL_8CC_ABIO_0CC_DEL}
    Suite common setup preparation    prepare_ue=${prepare_ue}
    ...     scf_modify_parameters=${scf_modify_parameters}
    Set actEndcSpidFwd value for LTE    value=true
    Upload enable and config script to gnb and run script

CB007459 case setup
    Common case setup    is_log_required=${True}

CB007459 case teardown
    [Arguments]    ${detach_ue}=${True}
    Recover HashContainer files
    Set actEndcSpidFwd value for LTE    value=false
    Set actSPID value for NR    value=false
    Common case teardown    is_log_required=${True}    detach_ue=${detach_ue}
