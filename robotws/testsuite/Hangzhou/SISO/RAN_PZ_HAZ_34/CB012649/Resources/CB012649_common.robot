*** Settings ***
Documentation    This is for feature CB009275 related common keywords.
...              Please do not modify the file without notification to author
...              Author:stella.lin@nokia-sbell.com
...              Squard: HZ SG6

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[1].instance_id}

*** Keywords ***
[1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    Initial PA Value Setting For All Attenuators
    Wait Until Keyword Succeeds    5X    5sec
        ...    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU
        ...    value=${20}   RU_id=${1}    gnb_id=${1}
    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    Set Suite Variable    ${stream_version}
    Run Keyword And Continue On Failure    Perform Commission    scf_file_path=/home/ute/SCF/GNB1_BASIC_GOLDEN_SCF_12649_${STREAM_VERSION}.xml
    ...                   gnb_index=${gnb_index}
    ...                   timeout_for_commission=450
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${True}
    connect to gnb coam via ssl    connection=${coam_connection}
    Wait until keyword succeeds    20min    20 sec    COAM Check GNB RU status    connection=${coam_connection}
    Wait until keyword succeeds    20min    20 sec    Verify all cells should be onair    connection=${coam_connection}
    ${ue_type}    translate_power_ue_type_from_testline
    Set Test Variable    ${ue_type}
    Procedures.UE Prepare    ue_type=${ue_type}
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=ca_attach
    ...                                       ue_type=${ue_type}
    ...                                       sleep_interval=45 sec
    ...                                       4G_check=${False}
    ...                                       gnb_index=${gnb_index}
    Start L3 Call Data Transfer    ul_data_transfer=10M
    ...                            dl_data_transfer=100M
    ...                            duration=300
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${attach_info['cpif_log_path']}
    ...                            ue_iperf_path=/data/local/tmp/iperf
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=90
    ...                                                                expect_ul_tput=5
    ...                                                                expect_dl_tput=30
    ...                                                                cellid=3
    ...                                                                gnb_index=${gnb_index}
    ...                                                                target_avg_percent=0.60
    ...                                                                ue_type=${ue_type}
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    [Teardown]    Run Keyword And Ignore Error    MTK_common_keywords.Do UE Detach    ue_index=${0}
