*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB007659-A

Resource    ../../resources/cbrs_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/7659-A_variables.py

*** Variables ***
${CB007659_conf_path}    ${CURDIR}/conf
${CB007659_A_common}    ${CB007659_conf_path}/CB007659_A_common.conf
${CB007659_json_path}    ${CURDIR}/json
${modify_actcbrs}    ${CB007659_json_path}/modify_actcbrs.json
${enable_actcbrs}    ${CB007659_json_path}/enable_actcbrs.json
${modify_actcbrs_61}    ${CB007659_json_path}/modify_actcbrs_61.json
${enable_actcbrs_61}    ${CB007659_json_path}/enable_actcbrs_61.json
*** Keywords ***
Case Preparation
    Connect to eNB via ssl
    ${SCF_CB007659_4G}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB007659_4G_
    COAM Commission with scf file    scf_file_path=${SCF_CB007659_4G}    connection=enblte    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    Sleep    300s
    ${mrbtsID_enb}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF for eNB    scf_path=${SCF_CB007659_4G}
    log to console  ENB_MRBTS_ID:${mrbtsID_enb}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID_enb}
    set suite variable  ${lnbtsID}
    Enblte close down

Case Preparation CRT
    ${SCF_CB007659}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB007659_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB007659}
    Case Preparation

CB007659 CBRS Test Setup
    [Arguments]    ${enable_delta_file}=${enable_actcbrs}
    CBRS Test Setup
    CBRS 4G Test Setup    enable_delta_file=${enable_delta_file}

CB007659 Test Teardown
    [Arguments]    ${disable_delta_file}=${modify_actcbrs}
    CBRS Test Teardown
    CBRS 4G Test Teardown    disable_delta_file=${disable_delta_file}

Check CB007659 online modify CBSD parameters procedure
    [Arguments]    ${cbsdid_old}    ${cbsdid_new}
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"deregistrationRequest\":.*\"cbsdId\":\"${cbsdid_old}\".*
    Check if message is found in saslog    tag={\"deregistrationResponse\":.*\"cbsdId\": \"${cbsdid_old}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid_new}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid_new}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid_new}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid_new}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid_new}".*"responseCode": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid_new}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid_new}".*\"responseCode\": 0.*
    [Teardown]    end_to_check

Check CB007659-A Relinquish Message
    [Arguments]    ${cbsdid}    ${grantId}
    ${info}    Set variable    {\"relinquishmentResponse\":.*\"cbsdId\": \"${cbsdid}\".*"grantId": \"${grantId}"\.*\"responseCode\": 0.*
    prepare_to_check_message_from_start
    Check if message is found in saslog    tag={\"registrationRequest\":.*
    Check if message is found in saslog    tag={\"registrationResponse\":.*\"cbsdId\": \"${cbsdid}\".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"spectrumInquiryRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"spectrumInquiryResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"grantRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"grantResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"heartbeatRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag={\"heartbeatResponse\":.*"cbsdId": "${cbsdid}".*\"responseCode\": 0.*
    Check if message is found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    Check if message is found in saslog    tag=${info}
    [Teardown]    end_to_check

Check No relinquishmentRequest in LTE
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if message is not found in saslog    tag={\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\".*
    [Teardown]    end_to_check

Check CB007659-A_26 No impact NR
    [Arguments]     ${cbsdid}
    prepare_to_check_message_from_start
    Check if total times of the message in log is matched
    ...    sasMessage='\"relinquishmentRequest\":.*\"cbsdId\":\"${cbsdid}\"'
    ...    totalTimes=${1}
    [Teardown]    end_to_check

Modify actCbrsEnhMeas And actNrCbrs By Coam
    [Arguments]    ${actCbrsEnhMeas}=true    ${actNrCbrs}=true    ${connection}=GNB_OAM
    ${parameters}  create list
    ${item}  create dictionary  parameterName=actNrCbrs    operation=update    value=${actNrCbrs}
    append to list  ${parameters}  ${item}
    ${item}  create dictionary  parameterName=actCbrsEnhMeas    operation=update    value=${actCbrsEnhMeas}
    append to list  ${parameters}  ${item}
    coam.perform_object_recommissioning        dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...                                        parameter=${parameters}
    ...                                        operation=update
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        connection=${connection}
    Sleep    30s

CB007659-A_11_gNB_cell_lock_unlock_when_master_is_NR
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    Check CBRS L3 call    tput=${TPUT}
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1     parameter_name=administrativeState    value=Locked
    Wait Until Keyword Succeeds    5min    30s    Cell Should Be Locked
    Verify all lte cells should be onair    connection=enblte
    Sleep    60s
    Modify the parameter on NR    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1     parameter_name=administrativeState    value=Unlocked
    Wait Until Keyword Succeeds    5min    30s    Cell Should Be Unlocked
    Wait until keyword succeeds    2min    30s    verify all cells should be onair
    Verify all lte cells should be onair    connection=enblte
    Check No relinquishmentRequest in LTE    cbsdid=${ltecbsdid}
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Sleep    120s
    Check CBRS L3 call    tput=${TPUT}

CB007659-A_14_gNB_behavior_check_when_RU_reset_master_is_NR
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Perform RU Reset
    Wait Until Keyword Succeeds    8min    30s    RU Should Be Offline
    Wait Until Keyword Succeeds    8min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Sleep    120s
    Check CBRS L3 call    tput=${TPUT}

CB007659-A_7_gNB pre-tx measurement performed when LTE onair
    Connect to eNB via ssl
    Modify actCbrsEnhMeas And actNrCbrs By Coam    actCbrsEnhMeas=false    actNrCbrs=false
    start SAS server
    Sleep    60s
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Verify all cells should be disabled
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    Sleep    35min
    Modify actCbrsEnhMeas And actNrCbrs By Coam    actCbrsEnhMeas=true    actNrCbrs=true
    Verify all lte cells should be onair    connection=enblte
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check No relinquishmentRequest in LTE    cbsdid=${ltecbsdid}
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Sleep    120s
    Check CBRS L3 call    tput=${TPUT}

CB007659-A_22_gNB_data_transfer_conducted_peak_throughput_SA
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Sleep    120s
    Check CBRS L3 call    tput=${TPUT}    target_avg_percent=0.95    min_percent=0.85

CB007659-A_8_gNB pre-tx measurement not performed when LTE onair
    Connect to eNB via ssl
    Modify actCbrsEnhMeas And actNrCbrs By Coam    actCbrsEnhMeas=false    actNrCbrs=false
    start SAS server    config_name=${CB007659_A_common}
    Sleep    60s
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    Verify all cells should be disabled
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    Change NR CBRS Flag By Coam    actNrCbrs=true
    Sleep    60s
    Verify all lte cells should be onair    connection=enblte
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check No relinquishmentRequest in LTE    cbsdid=${ltecbsdid}

CB007659-A_27_online_modify_supportedSpectrumV2_to_release_Volatile_MO
    [Arguments]    ${disable_delta_file}=${modify_actcbrs}    ${enable_delta_file}=${enable_actcbrs}
    Connect to eNB via ssl
    Change NR CBRS Flag By Coam    actNrCbrs=false
    Sleep    30s
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3550_3570}
    Sleep    30s
    coam.perform_delta_recommissioning    delta_file=${disable_delta_file}    connection=enblte
    Sleep    30s
    Modify the parameter on enblte    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1
    ...    parameter_name=supportedSpectrumV2    value=${frequency_3550_3570}
    Sleep    30s
    Change NR CBRS Flag By Coam    actNrCbrs=true
    Sleep    30s
    start SAS server    config_name=${CB007659_A_common}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_nr}    Get Grant Parameters By Coam
    Should be True    '${grant_info_nr}[grantId]'=='3550000000_3570000000'
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${enable_delta_file}    connection=enblte
    ${stamp_case_start}    Get Timestamp For Current Time
    Wait Until Keyword Succeeds    3min    5s    Check Alarm in Alarm List    type=Active    faultId=6827
    ...    stamp_case_start=${stamp_case_start}    Supplementary=No available frequency.    expect=${True}    connection=enblte
    Set Frequency Channel Value By Coam    frequency_channel=${frequency_3570_3590}
    Sleep    120s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Check CB007659-A Relinquish Message    cbsdid=${nrcbsdid}    grantId=${grant_info_nr}[grantId]
    ${grant_info_nr}    Get Grant Parameters By Coam
    Should be True    '${grant_info_nr}[grantId]'=='3570000000_3590000000'
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${grantId_lte}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId
    Should be True    '${grantId_lte}'=='3550000000_3570000000'
    [Teardown]    Run Keywords    Set Frequency Channel Value By Coam    frequency_channel=${frequency_all}    AND
    ...    Modify the parameter on enblte    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1     parameter_name=supportedSpectrumV2
    ...    value=${frequency_all}

CB007659-A_16_gNB_behavior_check_when_gNB_reset_master_is_NR
    Connect to eNB via ssl
    start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${stamp_case_start}    Get Timestamp For Current Time
    coam.reset_site   connection=GNB_OAM
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Sleep    120s
    Check CBRS L3 call    tput=${TPUT}

CB007659-A_26_CBSD_behavior_check_when_online_modify_desiredpmax
    Selenium Login And Disable Screen Lock
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Sleep    60s
    Online Change desiredPmax maxGrantPwrRed And antennaGain    desiredPmax=25    maxGrantPwrRed=5    antennaGain=5
    Connect to eNB via ssl
    start SAS server    config_name=${CB007659_A_common}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    ${grantId_lte}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantId
    ${grantmaxEirp_lte}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantMaxEirp
    ${grant_info_coam}    Get Grant Parameters By Coam
    Set test variable    ${grantId_nr}    ${grant_info_coam}[grantId]
    Should be True    '${grant_info_coam}[maxEirp]'=='23.1'
    Set desiredPmax By WEBEM    value=20
    Sleep    120s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${grant_info_coam_tmp}    Get Grant Parameters By Coam
    Should be True    '${grant_info_coam}[maxEirp]'!='${grant_info_coam_tmp}[maxEirp]'
    Check CB007659-A Relinquish Message    cbsdid=${nrcbsdid}    grantId=${grantId_nr}
    Check No relinquishmentRequest in LTE    cbsdid=${ltecbsdid}
    Sleep    20s
    Modify the parameter on enblte    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/LNCEL-11/CBSDCEL-0     parameter_name=desiredPmax    value=200
    Sleep    120s
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${grantmaxEirp_lte_new}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantMaxEirp
    Should be True    '${grantmaxEirp_lte_new}'!='${grantmaxEirp_lte}'
    Check CB007659-A Relinquish Message    cbsdid=${ltecbsdid}    grantId=${grantId_lte}
    Check CB007659-A_26 No impact NR    cbsdid=${nrcbsdid}
    Sleep    10s
    [Teardown]    Run Keywords    Selenium Logout And Close Browser    AND
    ...    Modify the parameter on enblte    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/LNCEL-11/CBSDCEL-0
    ...    parameter_name=desiredPmax    value=310

CB007659-A_30_CBRS_behavior_check_when_modify CBSD parameters
    Connect to eNB via ssl
    start SAS server    config_name=${CB007659_A_common}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    Set CBRS User Identity By Coam    userId=nokiaTL_tmp
    Sleep    120s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${nrcbsdid_new}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check CB007659 online modify CBSD parameters procedure    cbsdid_old=${nrcbsdid}    cbsdid_new=${nrcbsdid_new}
    Sleep    10s
    Set CBRS FCC identity By Coam    fccId=Nokia_tmp
    Sleep    120s
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    Check CB007659 online modify CBSD parameters procedure    cbsdid_old=${nrcbsdid_new}    cbsdid_new=${nrcbsdid}
    Sleep    10s
    Modify the parameter on enblte    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1     parameter_name=userId    value=nokia_tmp
    Sleep    120s
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${ltecbsdid_new}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    Check CB007659 online modify CBSD parameters procedure    cbsdid_old=${ltecbsdid}    cbsdid_new=${ltecbsdid_new}
    Sleep    10s
    Modify the parameter on enblte    dist_name=MRBTS-${mrbtsID_enb}/LNBTS-${lnbtsID}/CBSD-1     parameter_name=fccId    value=10086
    Sleep    120s
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    Check CB007659 online modify CBSD parameters procedure    cbsdid_old=${ltecbsdid_new}    cbsdid_new=${ltecbsdid}
    Sleep    10s

CB007659-A_20_gNB_behavior_check_when_NR_CBRS_deactivated
    Connect to eNB via ssl
    start SAS server    config_name=${CB007659_A_common}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    Selenium Login And Disable Screen Lock
    Online Change NR CBRS Flag    actNrCbrs=false
    Wait until keyword succeeds    5min    30s    Verify all cells should be disabled
    Verify all lte cells should be onair    connection=enblte
    ${register_status}  run keyword and return status  wait until keyword succeeds    2min    30s    Check Register Status By Coam
    Should be True    ${register_status} == False
    Check GrantOperationState Status Success    Status=Idle
    Check Deregister Success Message by cbsdid    cbsdid=${nrcbsdid}
    Check NO Deregister Message by cbsdid    cbsdid=${ltecbsdid}
    Sleep    10s
    [Teardown]    Selenium Logout And Close Browser

CB007659-A_19_gNB_behavior_check_when_LTE_CBRS_deactivated
    [Arguments]    ${disable_delta_file}=${modify_actcbrs}
    Connect to eNB via ssl
    start SAS server    config_name=${CB007659_A_common}
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=enblte
    ${nrcbsdid}    Get Parameter value via COAM    class_name=NRCBSD_R    pattern=assignedCbsdId    connection=GNB_OAM
    ${ltecbsdid}    Get Parameter value via COAM    class_name=CBSD_R   pattern=assignedCbsdId
    coam.perform_delta_recommissioning    delta_file=${disable_delta_file}    connection=enblte
    Wait until keyword succeeds    5min    30s    Verify all lte cells should be disabled    connection=enblte
    verify all cells should be onair
    ${GrantOperationState_LTE}    Get Parameter value via COAM    class_name=CBSDCEL_R    pattern=grantOperationState
    Should be True    '${GrantOperationState_LTE}' == 'Idle'
    Check Deregister Success Message by cbsdid    cbsdid=${ltecbsdid}
    Check NO Deregister Message by cbsdid    cbsdid=${nrcbsdid}
    Sleep    30s
