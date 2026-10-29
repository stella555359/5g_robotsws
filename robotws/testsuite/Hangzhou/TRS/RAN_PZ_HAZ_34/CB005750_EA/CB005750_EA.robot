# *** Settings ***
# Documentation    author：Hongyu Jiang
# ...              contact: hongyu.jiang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource          ./Resources/CB005750_common_keyword.robot
# Library           ./Resources/CB005750_common_keywords.py
# Variables         ./Resources/CB005750_modify_para.py
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# Suite Setup       CI_interface.Common Suite Setup
# 
# Force Tags         5G_RAN_TDD    STATE_SW_UPLOADED     SBTS00    CRT_UTE   5G_RAN
# ...    PY36
# ...    RAN_5G_TDD    RAN_5G
# 
# *** Variables ***
# ${LOG_PATH}               ${OUTPUT DIR}
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${Test_Case_Name}         5GC000313_01
# ${luashark_path}          /opt/luashark/luashark.lua
# ${gnb_id}                 ${tl.gnbs[0].instance_id}
# ${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T708
# ${gNB_lmp_ip}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${SLAVE_DU_OAM_IP}        ${tl.gnbs[0].slave[0].airscale.common_units[0].lmp_connection.addr}
# ${SLAVE_BTS_ID}           ${tl.gnbs[0].slave[0].instance_id}
# ${SHM_IP}                 ${tl.gnbs[0].slave[0].f1_m_ip_addr}
# ${source}                 /${OUTPUT DIR}/${Test_Case_Name}/bts_log.log
# ${GPS_only}               GPS only
# ${GLONASS_only}           GLONASS only
# ${Beidou_only}            Beidou only
# ${GLONASS_Beidou}         GLONASS-Beidou
# ${GPS_GLONASS}            GPS-GLONASS
# ${GPS_Beidou}             GPS-Beidou
# 
# 
# *** Test Cases ***
# [1]CB005750-5G-EAAE_5GC000313_01_ToP_Phase_Sync_Unicast
#      [Documentation]  ToP Phase Sync Unicast
#      [Tags]    CB005750-5G-EAAE_5GC000313    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB
#      [Timeout]    2 hour
#      [Setup]    Setup Commission SCF
#      Run Keyword And Continue On Failure      Check Top Source Info and Capture wireshark   except_topp_list=${except_topp_list1}
#      ...    is_commission=${False}    file_name=testcase1   except_sync_number=128    except_announce_number=2    except_dscp_number=46
#      ...    PARAMS_TO_MODIFY=${None}
#      Enable Test Clock    time=1min
#      Run Keyword And Continue On Failure     Start btslog on ute and Check btslog    time=120s    ppb_value=20   ns_value_scope=500
#      Run Keyword And Continue On Failure     Check Top Source Info and Capture wireshark   except_topp_list=${except_topp_list1}
#      ...    is_commission=${True}    file_name=testcase2    except_sync_number=64    except_announce_number=2    except_dscp_number=46
#      ...    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_MessageRate}
#      Run Keyword And Continue On Failure     Capture Wireshark Log And Download     filename=testcase3.pcap    time=5min    listen_port=Ethernet
#      Run Keyword And Continue On Failure     Check Signalling Message In txt    pacp_filename=testcase3.pcap    txt_filename=testcase3.txt
#      Run Keyword And Continue On Failure     Start btslog on ute and Check btslog    time=2min    ppb_value=20   ns_value_scope=500
#      Modify parameters and Check Alarm    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber1}   except_topp_list=${except_topp_list2}
#      ...    except_value=${True}
#      Modify parameters and Check Alarm    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber2}   except_topp_list=${except_topp_list1}
#      ...    except_value=${False}
#      Check Top Source Info and Capture wireshark   except_topp_list=${except_topp_list1}    is_commission=${True}    file_name=testcase4
#      ...    except_sync_number=64    except_announce_number=2    except_dscp_number=63    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DSCPvalue}
#      [Teardown]    Clear Log And Dir
# 
# 
# [1]CB005750-5G-EAAE_5GC000313_03_ToP_Phase_Sync_TOP_Detailed_Info
#     [Documentation]  ToP Phase Sync TOP Detailed Info
#     [Tags]    CB005750-5G-EAAE_5GC000313    CRT_21A   CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB
#     [Timeout]    2 hour
#     [Setup]   Setup Commission SCF
#     Check BTS TOP Synchronization Detail info On WebUi    expect_detail_list=${GM_expect_list0}    except_topp_list=${except_topp_list1}
#     log to console  setp——1
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber1}    connection=GNB_connection
#     Check BTS TOP Synchronization Detail info On WebUi    expect_detail_list=${GM_expect_list1}    except_topp_list=${except_topp_list2}
#     log to console  setp——2
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber2}    connection=GNB_connection
#     Check BTS TOP Synchronization Detail info On WebUi    expect_detail_list=${GM_expect_list0}    except_topp_list=${except_topp_list1}
#     [Teardown]    Clear Log And Dir
# 
# [1]CB005750-5G-EAAH_5GC000316_02_Synchronization_Mode_ReferenceSource_Switching
#     [Documentation]    Synchronization Mode ReferenceSource Switching
#     [Tags]    CB005750-5G-EAAH_5GC000316    CRT_21A    CRT_TRUNK    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB
#     [Timeout]    2 hour
#     [Setup]   Setup Commission SCF
#     Start btslog on ute and Check btslog    time=2min   ppb_value=20  ns_value_scope=500
#     Modify Domain Number and Check WebUI and Btslog    except_topp_list=${step2_except_topp_list}    except_other_list=${step2_except_other_list}
#     ...    except_value=${False}    ns_value_scope=500    time_control=${False}
#     Modify Domain Number and Check WebUI and Btslog    except_topp_list=${step3_except_topp_list}    except_other_list=${step3_except_other_list}
#     ...    except_value=${True}    ns_value_scope=500    input_list=${PARAMS_TO_MODIFY_DomainNumber1}
#     Modify Domain Number and Check WebUI and Btslog    except_topp_list=${step3_except_topp_list}    except_other_list=${step3_except_other_list}
#     ...    except_value=${True}    ns_value_scope=1500    time_control=${False}    fault_id=${False}
#     Modify Domain Number and Check WebUI and Btslog    except_topp_list=${step2_except_topp_list}    except_other_list=${step2_except_other_list}
#     ...    except_value=${False}    ns_value_scope=500    input_list=${PARAMS_TO_MODIFY_DomainNumber2}
#     [Teardown]    Clear Log And Dir
# 
# [1]CB005750-5G-EAAK_5GC000319_008_Selection_of_Sync_Hub_as_sync_input_with_phase
#     [Documentation]  Selection of Sync Hub as sync input with phase
#     [Tags]  CB005750-5G-EAAE_5GC000319    CRT_21A    CRT_TRUNK   CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB
#     [Timeout]    1 hour
#     [Setup]    Setup Commission SCF
#     ${fault_id_list}    Check TOP SynInfo Alarm Number    except_topp_list=${step2_except_topp_list}   except_other_list=${step2_except_other_list}
#     Modify Parameters and check TOP SyncInfo and Alarm Number    modify_list=${case319_modify_sync1}    keywords_list=${modify_keywords_list1}
#     ...    index=${index_list}    except_topp_list=${step4_except_topp_list}    except_other_list=${step4_except_other_list}
#     ...    input_alarm_list=${fault_id_list}
#     Modify Parameters and check TOP SyncInfo and Alarm Number    modify_list=${case319_modify_sync2}    keywords_list=${modify_keywords_list1}
#     ...    index=${index_list}    except_topp_list=${step2_except_topp_list}    except_other_list=${step2_except_other_list}
#     ...    input_alarm_list=${fault_id_list}
#     [Teardown]    CI_interface.Common Case Teardown
# 
# [1]CB005750-5G-EAAF_5GC000314_TC4_Provide_1pps_Synchronization_Output_for_Collocated_BTS
#     [Documentation]
#     ...    The goal of this test is to check that 5gNB shares the synchronization source with 1PPS/TOD GNSS.
#     ...    -23.02.2021,zheyuan.chen@nokia-sbell.com
#     [Tags]    CRT_21A    CRT_TRUNK    CB005750_314   CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB
#     [Timeout]    2 hour
#     [Setup]    5GC000314_case_setup
#     Change Clock Output and Check Sync Status    Actual_value=Disabled    DU_IP=${SLAVE_DU_OAM_IP}   expect_isActive=${F
# ...alse}   expect_fault=${1898}
#     ...    expect_availability=Unavailable    expect_usability=Unusable    expect_tuningMode=Adaptive holdover    contain_flag=${True}
#     Change Clock Output and Check Sync Status     Actual_value=EnabledWithBtsInputReference    DU_IP=${SLAVE_DU_OAM_IP}    expect_isActive=${True}
#     ...    expect_availability=Available    expect_usability=Usable   expect_tuningMode=Normal tuning   expect_fault=${1898}  contain_flag=${False}
#     Start BTSLog and Check Phase Error    time=40s
#     Change Sync Type and Check Sync Status    DU_IP=${SLAVE_DU_OAM_IP}    expect_isActive=${True}    expect_availability=Available
#     ...    expect_usability=Usable    expect_tuningMode=Normal tuning    expect_fault=${1898}    contain_flag=${False}
#     Start BTSLog and Check Phase Error    time=40s
#     Change Clock Output and Check Sync Status    Actual_value=Disabled    DU_IP=${SLAVE_DU_OAM_IP}   expect_isActive=${False}  expect_fault=${1898}
#     ...    expect_availability=Unavailable    expect_usability=Unusable    expect_tuningMode=Adaptive holdover    contain_flag=${True}
#     wait until keyword succeeds    150s    30s    Check Alarm Contain Target FaultID    DU_IP=${SLAVE_DU_OAM_IP}    expect_fault=${4405}
#     [Teardown]    5GC000314_case_teardown
# 
# [1]CB005750-5G-ECAA_5GC000352_A_001_FYGC startup_automatic_self_survey_with_manual_location_mode
#     [Documentation]
#     ...    The purpose of this test is to check the correct FYGC startup in automatic location mode.
#     ...    -03.02.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_21A    CRT_TRUNK    CB005750_352    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB
#     [Timeout]    2 hour
#     [Setup]    5GC000352_case_setup
#     Check GNSS Product Name And status    expect_product_name=FYGM
#     Change Sync Input Type    DU_IP=${gnb_ip}    BTS_ID=${gnb_id}    synctype=1pps/ToD from external GNSS receiver
#     Change GNSS Operation Mode And Check Sync Stutas    gnss_mode=${gnss_mode_all}
#     [Teardown]    5GC000352_case_teardown
# 
# [1]CB005750-5G-EAAG_TC01_5GC000315_5GC000317_Sync _Hub_Master_and_Slave_Phase_Tuning_and_Phase_accuracy_reports
#     [Documentation]    Hub Master and Slave Phase Tuning and Phase accuracy reports
#     [Tags]    CB005750-EAAG    CRT_21A    CRT_TRUNK    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB
#     [Timeout]    2 hour
#     [Setup]    Prepare GPS and TOPP status
#     GNSS Check and BTSlog    parameter1=${parameter5_315}    parameter2=${parameter3_315}
#     [Teardown]    Run keywords    5GC000315 case Teardown    AND    CI_interface.Common Case Teardown
# 
# [1]CB005750-5G-ECAE_5GC000662_A_001_FYGM_startup_automatic self_survey_with_automatic_location_mode
#     [Documentation]
#     [Tags]     CB005750-5G    CRT_21A  CRT_TRUNK    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB
#     [Timeout]    2 hour
#     Setup Commission SCF
#     Modify parameters and check GNSS status   input_list=${GLONASS_Beidou1}    GNSS_mode=${GLONASS_Beidou}    BeiDou=Yes    GLONASS=Yes    GPS=No
#     Modify parameters and check GNSS status   input_list=${GPS_GLONASS1}    GNSS_mode=${GPS_GLONASS}    BeiDou=No    GLONASS=Yes    GPS=Yes
#     Modify parameters and check GNSS status   input_list=${GPS_Beidou1}    GNSS_mode=${GPS_Beidou}    BeiDou=Yes    GLONASS=No    GPS=Yes
#     Modify parameters and check GNSS status   input_list=${Beidou_only1}    GNSS_mode=${Beidou_only}    BeiDou=Yes    GLONASS=No    GPS=No
#     Modify parameters and check GNSS status   input_list=${GPS_only1}    GNSS_mode=${GPS_only}    BeiDou=No    GLONASS=No    GPS=Yes
#     Modify parameters and check GNSS status   input_list=${GLONASS_only1}    GNSS_mode=${GLONASS_only}    BeiDou=No    GLONASS=Yes    GPS=No
#     [Teardown]
# 
# [1]CB005750-5G-EAAL_5GC000320_03_Phase_Synchronization_Holdover_Performance_No_Sufficient_TuningHistory
#     [Documentation]    Phase_Synchronization_Holdover_Performance_No_Sufficient_TuningHistory
#     [Tags]    CB005750_320    CRT_21A    CRT_TRUNK    CLOUD_5G_CLASSICAL_ASILR_ABIOB4_AEQN_ENB
#     [Timeout]    2 hour
#     [Setup]    Setup Commission SCF
#     Start btslog on ute and Check btslog    time=2min   ppb_value=20  ns_value_scope=500
#     Modify TOP Domain Number1
#     Check Information On WebUI And Check Btslog    except_topp_list=${step2_except_topp_list}
#     ...    except_other_list=${step2_except_other_list}    except_value=False    ns_value_scope=500
#     Modify Common parameter via Coam   input_list=${PARAMS_TO_MODIFY_DomainNumber1}
#     Check Information On WebUI And Check Btslog    except_topp_list=${step3_except_topp_list}
#     ...    except_other_list=${step3_except_other_list}    except_value=True    ns_value_scope=500
#     Modify Common parameter via Coam   input_list=${PARAMS_TO_MODIFY_DomainNumber2}
#     Check Information On WebUI And Check Btslog    except_topp_list=${step2_except_topp_list}
#     ...    except_other_list=${step2_except_other_list}    except_value=False    ns_value_scope=500
#     [Teardown]    CI_interface.Common Case Teardown
# 
