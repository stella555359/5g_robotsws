*** Settings ***
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown 
Force Tags        QCD_MN_RAN    SBTS00    RAN_4G    RAN_4G_TDD    CLOUD_R4BO9_CUS    wennan.deng@nokia-sbell.com
Resource          ${CURDIR}/../../resources/KISS/robot/common_resource_ABIO.robot


*** Variables ***
${UE_NUMBER}      3
${CONFIG_DIR_PATH}    ${CURDIR}/config/
${scfc_name}   SCFC_1.xml
${cus_yaml}    cus_R4BO9.yaml
#common configure
@{tdd_configuration}    text|2|//*[@name\="tddFrameConf"]    text|7|//*[@name\="tddSpecSubfConf"]
${TM_mode}    text|Dynamic Open Loop MIMO|//*[@name\="dlMimoMode"]
${chBw}    text|20 MHz|//*[@name\="chBw"]
${actModulationSchemeDl}    text|64QAM|//*[@name\="actModulationSchemeDl"]
${actModulationSchemeUL}    text|16QAMHighMCS|//*[@name\="actModulationSchemeUL"]
#LTE2611 Public Safety QCI bearers
@{actPubSafetyBearers}    text|true|//*[@name\="actPubSafetyBearers"]    text|600|//*[@name\="inactivityTimer"]
${actPubSafetyVideo}    text|true|//*[@name\="actPubSafetyVideo"]
${maxNumPreEmptions}    text|20|//*[@name\="maxNumPreEmptions"]
${actConvVoice}    text|true|//*[@name\="actConvVoice"]
${actMultBearers}    text|true|//*[@name\="actMultBearers"] 
${actMultGbrBearers}    text|true|//*[@name\="actMultGbrBearers"] 
${actEnhAcAndGbrServices}    text|true|//*[@name\="actEnhAcAndGbrServices"]
${gbrCongHandling}    text|l2andl3|//*[@name\="gbrCongHandling"]
${actDrx}    text|true|//*[@name\="actDrx"]
${UE_cap}    D180042033E88001FC1A313C0050060A2A95901003F11004039C0403039C0003039C0402039C0002039C00000200007FE000002DC5000688A4C010076A
@{modify_list}    @{tdd_configuration}    ${TM_mode}    ${chBw}     ${actModulationSchemeDl}    ${actModulationSchemeUL}
...    @{actPubSafetyBearers}    ${actPubSafetyVideo}    ${maxNumPreEmptions}    ${actConvVoice}    ${actMultBearers}
...    ${actMultGbrBearers}    ${actEnhAcAndGbrServices}    ${gbrCongHandling}    ${actDrx}
@{COUNTER_LIST}    M8046C0    M8046C1    M8046C2    M8046C3    M8046C4
...               M8047C0    M8047C1    M8047C2    M8047C3    M8047C4    M8047C5    M8047C6    M8047C9    M8047C10
...               M8047C11    M8047C14    M8047C15    M8047C16    M8047C17    M8047C18    M8047C19    M8047C20    M8047C23
...               M8047C24    M8047C25    M8047C26    M8048C3    M8048C4    M8048C5    M8048C6    M8048C7    M8048C8
...               M8048C13    M8048C14    M8048C24

*** Test Cases ***
CB006274_A_08_PM_counter_check_for_QCI67_GBR_bearer
    [Tags]     QC_48573
    Step1:Set parameters as pre-condition
    Step2:3UE QCI67_69 attach and detach 3 times
    Step3:Waiting for at least 15min and get PM counter

*** Keywords ***
Step1:Set parameters as pre-condition
    Start enb and cus syslog'1'
    #${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/
    ${scfc_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}scfc.xml
    ${cus_yaml_path}    Set Variable    ${TEST LOG DIRECTORY()}${/}cus_1.yaml
    copy_file    ${CONFIG_DIR_PATH}/${scfc_name}    ${scfc_path}
    copy_file    ${CONFIG_DIR_PATH}/${cus_yaml}    ${cus_yaml_path}
    Add parameter in all cell level    ${scfc_path}    <p name="inactivityTimerPubSafety">600</p>
    Add parameter in all cell level    ${scfc_path}    <p name="volteBearerProtectTimer">8</p>
    Add parameter in all lncel_tdd level    ${scfc_path}    <p name="actMcVideoOverbooking">true</p>
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    #Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}
    Load CUS config Files And Wait BTS Onair    ${scfc_path}    ${cus_yaml_path}    enb_swconfig=${eNB_swconfig_path}
    Stop and collect enb and cus syslog

Step2:3UE QCI67_69 attach and detach 3 times 
    FOR    ${i}    IN RANGE    1     4
        Start enb and cus syslog'${i}' 
        3UE_attach_and_detach_with_QCI69_67 
        Stop and collect enb and cus syslog
        collect procotol log '${i}' from egate
    END

3UE_attach_and_detach_with_QCI69_67
    Run UEx command    ue_attach    id=1,2    ue_eutra_capabilities=${UE_cap}    cell=1
    wait_throughput_stable    5
    Run UEx command    trf_data_start    ue=1,2    qci=9    kbps=120000    trf_id=1    dir=dl    protocol=udp
    Run UEx command    trf_data_start    ue=1,2    qci=9    kbps=12000    trf_id=1    dir=ul    protocol=udp
    wait_throughput_stable    5
    run_keyword_and_ignore_error    Run UEx command    bearer_add    ue=1,2     qci=69
    run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1,2    qci=69    kbps=10000    trf_id=1    dir=dl    protocol=udp
    run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1,2    qci=69    kbps=1000    trf_id=1    dir=ul    protocol=udp
    wait_throughput_stable    5
    run_keyword_and_ignore_error    Run UEx command    bearer_add    ue=1,2    qci=67    mbr_ul=4096    mbr_dl=4096    gbr_ul=4096    gbr_dl=4096
    run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1,2    qci=67    kbps=5000    trf_id=1    dir=dl    protocol=udp
    run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=1,2    qci=67    kbps=4000    trf_id=1    dir=ul    protocol=udp
    wait_throughput_stable    5
    Run UEx command    ue_attach    id=3    ue_eutra_capabilities=${UE_cap}    cell=1
    wait_throughput_stable    5
    Run UEx command    trf_data_start    ue=3    qci=9    kbps=120000    trf_id=1    dir=dl    protocol=udp
    Run UEx command    trf_data_start    ue=3    qci=9    kbps=12000    trf_id=1    dir=ul    protocol=udp
    wait_throughput_stable    5
    run_keyword_and_ignore_error    Run UEx command    bearer_add    ue=3     qci=69
    run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=3    qci=69    kbps=10000    trf_id=1    dir=dl    protocol=udp
    run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=3    qci=69    kbps=1000    trf_id=1    dir=ul    protocol=udp
    wait_throughput_stable    5
    run_keyword_and_ignore_error    Run UEx command    bearer_add    ue=3    qci=67    mbr_ul=4096    mbr_dl=4096    gbr_ul=4096    gbr_dl=4096
    run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=3    qci=67    kbps=5000    trf_id=1    dir=dl    protocol=udp
    run_keyword_and_ignore_error    Run UEx command    trf_data_start    ue=3    qci=67    kbps=4000    trf_id=1    dir=ul    protocol=udp
    wait_throughput_stable    60
    Run UEx command    trf_data_stop    ue=1,2,3
    run_keyword_and_ignore_error    run_uex_command    bearer_del ue=1,2,3 qci=67
    run_keyword_and_ignore_error    run_uex_command    bearer_del ue=1,2,3 qci=69
    Run UEx command    ue_detach    id=1,2,3

Step3:Waiting for at least 15min and get PM counter
    ${remain_time}=    get_counter_file_remaining_time
    set test variable    ${remain_time}
    sleep    ${remain_time}
    ${passed}=    Run Keyword And Return Status    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/    suffix=xz
    Run Keyword If    not ${passed}    Download Latest Pmcounter    local_path=${TEST LOG DIRECTORY()}/    source_path=/tmp/    suffix=gz
    ${counter_file}    list files in directory    ${TEST LOG DIRECTORY()}/    pattern=*.ANY.*
    set test variable    ${counter_file}
    FOR    ${PM_counter}    IN    @{COUNTER_LIST}
        ${Count_serving}    get_counter_value_from_counter_file    ${TEST LOG DIRECTORY()}/${counter_file[0]}    ${PM_counter}    1
        sleep    1s
        should_be_true    ${Count_serving}>0
    END

wait_throughput_stable
    [Arguments]    ${time}
    sleep    ${time}
