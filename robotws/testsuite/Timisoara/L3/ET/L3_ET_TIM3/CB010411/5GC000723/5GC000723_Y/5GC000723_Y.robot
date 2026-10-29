*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    CRT
...           PY36    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage


Documentation    :author: Radu Turcu
...              :email: radu.turcu@nokia.com
...              :Description: parity of 723-Y in RINLAN2
...                            Refined to match ET Scope


Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/krk3_common/aic/aic_common_resources.robot
#Resource     RM_5GC0001944_WA_Keywords.robot
Library      ta5g_tshark
#Library      ta5g_setups_and_teardowns
#Variables    ta5g_global_var
Library      ta5g_ue_mobility
Library     ute_tshark
Variables    ta5g_global_var

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes

*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_EXAMPLE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU}   delta_vdu=${DELTA_VDU}
${DELTA_VCU}     ${CURDIR}/configs/delta_vcu.xml
${DELTA_VDU}     ${CURDIR}/configs/delta_vdu.json
${du_updated_phrConfig_delta}       ${CURDIR}/configs/updated_phrConfig_10sf_50sf_6dB.json
${du_default_phrConfig_delta}       ${CURDIR}/configs/default_phrConfig_0sf_20sf_3dB.json
${CU_SCF}     /home/ute/Downloads/scfc_cu.xml
${DU_SCF}     /home/ute/Downloads/scfc_du.xml
${RRC_SETUP}    nr-rrc.rrcSetup_element
${DEFAULT_phrConfig_IN_RRCSETUP}=    ${RRC_SETUP} && f1ap.GNB_DU_UE_F1AP_ID == 1 &&
...                      nr-rrc.phr_ProhibitTimer == 0 && nr-rrc.phr_PeriodicTimer == 1 && nr-rrc.phr_Tx_PowerFactorChange == 1
${UPDATED_phrConfig_IN_RRCSETUP}=    ${RRC_SETUP} && f1ap.GNB_DU_UE_F1AP_ID != 1 &&
...                      nr-rrc.phr_ProhibitTimer == 1 && nr-rrc.phr_PeriodicTimer == 2 && nr-rrc.phr_Tx_PowerFactorChange == 2

*** Test Cases ***
5GC000723_Y_Online_Modification_of_Parameters_Power_Headroom
    [Documentation]   This is Optimized TC, and covers following legacy scenarios:
    ...               5GC000723_Y
    ...               Requirement ID  : config=&{CONFIG_EXAMPLE}
    [Setup]    Test Case Setup    reach_on_air=without_x2_link     config=&{CONFIG_EXAMPLE}   reboot_after_config=no
#    Upload delta vdu    ${du_default_phrConfig_delta}
    Log to console     start test
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    10s

    ta5g_ue_mobility.Attach Ue    ue_id=1
    sleep    10s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${DEFAULT_phrConfig_IN_RRCSETUP}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s

    Upload delta vdu    ${du_updated_phrConfig_delta}
    sleep    2s
    ta5g_ue_mobility.Attach Ue    ue_id=2
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${UPDATED_phrConfig_IN_RRCSETUP}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    stop tcpdump on remote interface

	Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s
