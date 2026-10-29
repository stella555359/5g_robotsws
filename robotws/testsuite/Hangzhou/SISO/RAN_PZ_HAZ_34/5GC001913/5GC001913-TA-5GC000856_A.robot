# # #*** Settings ***
# # #Documentation     author: fengyi Liu
# # #...               contact: feng.y.liu@nokia-sbell.com
# # #...               squad group: mmw_SG_04
# # #
# # #Resource          ./resources/5GC001913_common_keyword.robot
# # #Library           ./resources/5GC001913_common_KW.py
# # #
# # #Force Tags              5G_RAN_TDD    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ANDROID_ASOD_AEWE_ENB    master_pDU    CRT_UTE   5G_RAN
# # #...    PY36
# # #...    RAN_5G_TDD    RAN_5G
# # #
# # #
# # #Suite Setup       CI_interface.Common Suite Setup
# # #
# # #
# # #*** Variables ***
# # #${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #${WEBUI_USER}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # #${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # #${1913_default_scf}         ${CURDIR}/../../../commissionings/HGZ/7_5_UTE5G401T721/SCF_0.400_DU.xml
# # #${dl_throughput}            200M
# # #${Expected_dl_Tput}         10
# # #${ul_throughput}            50M
# # #${Expected_ul_Tput}         30
# # #${pb_model_ru}              ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.__class__.__name__}
# # #${pb_status}                on
# # #${ue_power_port}            ${tl.ues[0].iperf_details.port}
# # #
# # #
# # #*** Test Cases ***
# # #[1][2.0] 5GC001913-TA-5GC000856_A_4_NSA L3 call with DL data traffic with TCP_above 37GHz RU
# # #    [Tags]    5GC001913    CRT_20B    CRT_TRUNK    CRT_UTE    #master_cloudbts_cuoam_int    CIT
# # #    [Setup]
# # ##    Input need scf for DL
# # #    attach multi power ue    ue_num=${1}
# # #    start multi power ue traffic ul and dl    ue_num=${1}    dl_throughput=${dl_throughput}    if_ul=${False}    protocol=tcp
# # #    sleep    10s
# # #    log    \n start check throughput    console=yes
# # #    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}
# # #    ...    Get peak and ave throughput and return result    if_dl=${True}
# # #    should be true    ${dl_average_tp}>=${Expected_dl_Tput}
# # #    [Teardown]    Case Teardown    ue_num=${1}    protocol=tcp    if_ul=${False}    if_dl=${True}
# # #
# # #[1][3.0] 5GC001913-TA-5GC000856_General_SISO_BTS_startup_with_delayed_RF_link_setup_OTA
# # #    [Tags]    5GC001913    CRT_20B    CRT_TRUNK     5GC000856     5GC000959    5GC001591    CRT_UTE
# # #    [Documentation]
# # #    ...    history change, <date>,<who>,<what and how>
# # #    ...    -28.09.2020,kaijia.chen@nokia-sbell.com,case draft
# # #    [Setup]
# # #    Check BTS Should Be Normal
# # #    Step1: Perform RU Power Off
# # #    Step2: Check BTS not Reset Site
# # #    Step3: Perform RU Power On
# # #    [Teardown]     CI_interface.Common Case Teardown
# # #
# # #[1][2.0] 5GC001913-TA-5GC000856_General_SISO_Power_off_power on_gNB_and_RU_OTA
# # #    [Tags]     5G_SISO    5GC001913    CRT_20B    CRT_TRUNK   5GC000856     5GC000959    5GC001591    CRT_UTE
# # #    [Setup]
# # #    Step1:Login and check
# # #    Step2:PB off
# # #    Step3:PB on
# # #    [Teardown]    CI_interface.Common Case Teardown
# # #
# # #[1][2.0] 5GC001913-YA-5GC000959_A_NSA_L3 call with UL data traffic with TCP_above 37GHz RU - AEWE
# # #    [Tags]    5G_TRS    5GC001913    CRT_20B    CRT_TRUNK    CRT_UTE    #master_cloudbts_cuoam_int    CIT
# # #    [Setup]
# # #    Check BTS Should Be Normal
# # #    attach multi power ue    ue_num=${1}
# # #    start multi power ue traffic ul and dl    ue_num=${1}    ul_throughput=${ul_throughput}    if_dl=${False}    protocol=tcp
# # #    sleep    10s
# # #    log    \n start check throughput    console=yes
# # #    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}
# # #    ...   Get peak and ave throughput and return result    if_ul=${True}
# # #    should be true    ${ul_average_tp}>=${Expected_ul_Tput}
# # #    [Teardown]    Case Teardown    ue_num=${1}    protocol=tcp    if_ul=${True}    if_dl=${False}
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
