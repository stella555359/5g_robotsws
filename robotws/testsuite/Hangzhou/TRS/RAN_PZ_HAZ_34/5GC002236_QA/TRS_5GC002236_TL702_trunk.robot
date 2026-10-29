# #*** Settings ***
# #Documentation    author：Hongyu Jiang
# #...              contact: hongyu.jiang@nokia-sbell.com
# #...              squad group: mmw_SG_04
# #Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# #Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# #Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #Variables         ./Resources/5GC002236_modify_para.py
# #Library           ./Resources/5GC002236_common_keywords.py
# #Resource          ./Resources/5GC002236_common_keyword.robot
# #Library           BuiltIn
# #Library           taf.collectors.btslog    WITH NAME   btslog
# #Library           taf.collectors.core   WITH NAME   core
# #Library           taf.transport.ssh    WITH NAME    ssh
# #Library           ute_syslog
# #Library           taf.config.scf                WITH NAME    scf
# #Library    taf.analyzer.pcap     WITH NAME    cap
# #Library           taf.sbts.oam.coam.admin                 WITH NAME   admin
# #Resource          ../5GC002236_FA/resources/trans_comm.robot
# #Library           String
# #Library           OperatingSystem
# #
# ##Library           taf.ul.oam.selenium_megazone           WITH NAME    selenium_megazone
# #
# #Force Tags    5G_RAN    5G_RAN_TDD    CRT_UTE   CLOUD_5G_ASOD_AEUD_ENB_5GC001566    STATE_GNB_NOT_COMMISSIONED    master_pDU
# #...    PY36
# #
# #Suite Setup    CI_interface.Common Suite Setup
# #Suite Teardown
# #
# #
# #*** Test Cases ***
# #[1]5GC002236_5GC000316_01_Synchronization_Mode_Configuration
# #    [Documentation]    Synchronization Mode Configuration
# #    [Tags]    5GC002236_316    CRT_20B    CRT_TRUNK    CRT_21B
# #    [Setup]  Setup Commission SCF
# #    Modify parameters Set syncInputType And btsSyncMode    param_to_modify=${PARAMS_TO_MODIFY_TOPF_PhaseSync}    expected_error=${TOPF_PhaseSync}
# #    Modify parameters Set syncInputType And btsSyncMode    param_to_modify=${PARAMS_TO_MODIFY_TOPF_FreqSync}      expected_error=${TOPF_FreqSync}
# #    ${relation_errors}     Modify parameters online And Get Relation Error    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_TOPP_PhaseSync}
# #    Check Relation Errors When Right Config    relation_errors=${relation_errors}     excpect_list=${excpect_list}
# #    [Teardown]    CI_interface.Common Case Teardown
# #
# #[1]5GC002236_5GC000316_02_Synchronization_Mode_ReferenceSource_Switching
# #    [Documentation]    Synchronization Mode ReferenceSource Switching
# #    [Tags]    5GC002236_316    CRT_20B    CRT_TRUNK    CRT_21B
# #    [Setup]   Setup Commission SCF
# #    Run Keyword And Continue On Failure    Start btslog on ute and Check btslog    time=2min   ppb_value=20
# #    ...    ns_value_scope=500      btslog_name=bts_log1.log
# #    Modify TOP Domain Number
# #    Run Keyword And Continue On Failure    Check Information On WebUI And Check Btslog    except_topp_list=${step2_except_topp_list}
# #    ...    except_other_list=${step2_except_other_list}    except_value=False    ns_value_scope=500       btslog_name=bts_log11.log
# ##    Modify parameters online and Active Plan    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber1}
# #    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber1}
# #    sleep   3min
# #    Run Keyword And Continue On Failure    Check Information On WebUI And Check Btslog    except_topp_list=${step3_except_topp_list}
# #    ...    except_other_list=${step3_except_other_list}    except_value=True    ns_value_scope=500      btslog_name=bts_log12.log
# #    Modify TOP Domain Number
# #    Run Keyword And Continue On Failure    Start btslog on ute and Check btslog    time=2min   ppb_value=20
# #    ...     ns_value_scope=1500     btslog_name=bts_log2.log
# #    Run Keyword And Continue On Failure    COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}
# #    ...   except_other_list=${step3_except_other_list}    except_topp_list=${step3_except_topp_list}
# ##    Modify parameters online and Active Plan    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber2}
# #    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber2}
# #    sleep   3min
# #    Run Keyword And Continue On Failure    Check Information On WebUI And Check Btslog    except_topp_list=${step2_except_topp_list}
# #    ...    except_other_list=${step2_except_other_list}    except_value=False    ns_value_scope=500      btslog_name=bts_log13.log
# #    [Teardown]    CI_interface.Common Case Teardown
# #
# #[1]5GC002236_5GC000313_01_ToP_Phase_Sync_Unicast
# #     [Documentation]  ToP Phase Sync Unicast
# #     [Tags]    5GC002236_313    CRT_20B    CRT_TRUNK   CRT_21B
# #     [Setup]    Setup Commission SCF
# #     COAM Check TOP Synchronization info    bts_addr=${gNB_ip}     except_topp_list=${except_topp_list1}
# #     log to console    setup1_over
# #     Capture Wireshark Log And Download     filename=testcase1.pcap    time=8s    listen_port=Ethernet
# #     Run Keyword And Continue On Failure    Convert pcap to text And Get txt Content   pacp_filename=testcase1.pcap    txt_filename=testcase1.txt
# #     ...    except_sync_number=128    except_announce_number=2    except_dscp_number=46
# #     log to console    setup2_over
# #     Enable Test Clock    time=1min
# #     Run Keyword And Continue On Failure     Start btslog on ute and Check btslog    time=2min    ppb_value=20    ns_value_scope=500
# #     ...    btslog_name=bts_log.log
# #     log to console    setup3_over
# #
# #     Run Keyword And Continue On Failure    Modify parameters via Coam And Check Top Source Info
# #     ...    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_MessageRate}    except_topp_list=${except_topp_list1}
# ##     Run Keyword And Continue On Failure    Modify parameters And Check TOP Source Info   PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_MessageRate}
# ##     ...     except_topp_list=${except_topp_list1}     time=3min
# #
# #     log to console    setup4_over
# #     Capture Wireshark Log And Download     filename=testcase2.pcap    time=8s    listen_port=Ethernet
# #     Run Keyword And Continue On Failure    Convert pcap to text And Get txt Content   pacp_filename=testcase2.pcap    txt_filename=testcase2.txt
# #     ...    except_sync_number=64    except_announce_number=2    except_dscp_number=46
# #     Capture Wireshark Log And Download     filename=testcase3.pcap    time=5min    listen_port=Ethernet
# #     Check Signalling Message In txt    pacp_filename=testcase3.pcap    txt_filename=testcase3.txt
# #     log to console    setup5_over
# #     Run Keyword And Continue On Failure    Start btslog on ute and Check btslog    time=2min    ppb_value=20    ns_value_scope=500
# #     ...    btslog_name=bts_log.log
# #     log to console    setup6_over
# #
# #     Run Keyword And Continue On Failure    Modify parameters via Coam And Check Top Source Info
# #     ...     PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber1}    except_topp_list=${except_topp_list2}
# ##     Run Keyword And Continue On Failure    Modify parameters And Check TOP Source Info   PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber1}
# ##     ...     except_topp_list=${except_topp_list2}     time=5min
# #
# #     Check Alarm Number Is Right    alarm_number=4298    except_value=True
# #     log to console    setup7_over
# #
# #     Run Keyword And Continue On Failure    Modify parameters via Coam And Check Top Source Info
# #     ...    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber2}    except_topp_list=${except_topp_list1}
# ##     Run Keyword And Continue On Failure    Modify parameters And Check TOP Source Info   PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DomainNumber2}
# ##     ...     except_topp_list=${except_topp_list1}    time=5min
# #
# #     Check Alarm Number Is Right    alarm_number=4298    except_value=False
# #     log to console    setup8_over
# #
# #     Run Keyword And Continue On Failure    Modify parameters via Coam And Check Top Source Info
# #     ...    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DSCPvalue}    except_topp_list=${except_topp_list1}
# ##     Run Keyword And Continue On Failure    Modify parameters And Check TOP Source Info   PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY_DSCPvalue}
# ##     ...     except_topp_list=${except_topp_list1}      time=1s
# #
# #     Capture Wireshark Log And Download     filename=testcase4.pcap    time=8s    listen_port=Ethernet
# #     Run Keyword And Continue On Failure    Convert pcap to text And Get txt Content   pacp_filename=testcase4.pcap    txt_filename=testcase4.txt
# #     ...    except_sync_number=64    except_announce_number=2    except_dscp_number=63
# #     [Teardown]    CI_interface.Common Case Teardown
# #
# ##[1]5GC002236_5GC000307_01_Verification_of_IPv4_ping_application
# ##    [Tags]     5GC002236-OA    CRT_20B   CRT_21B    CRT_TRUNK   5GC000307
# ##    [Setup]    TRANS Common Setup
# ###    Set test variable    ${LOG_PATH}
# ##    start IP connectivity test
# ##    Log to console  Check Collect the wireshark
# ##    check wireshark log     ${filename_1}
# ##    check wireshark log     ${filename_2}
# ##    [Teardown]   5GC002236_307_Teardown
# #
# #[1]5GC001566-5GC000986_009_Action_trigger_shall_trigger_removing_route
# #    [Documentation]    This TC check if action trigger can modify routing table
# #    [Tags]    5G_TRS    5GC001566    CRT_20B    CRT_TRUNK   CRT_21B
# #    [Setup]
# #    ${dict_ipappid}    step1:Creat parameters for bfd and trigger    ID=${ID}    PARAMS_TRIGGER=${PARAMS_TRIGGER}
# #    step2:Modify IPRT-1 triggerDN parameter    IPRT_distname_1=${IPRT_distname_1}    PARAMS=${PARAMS_staticRoutes_3}
# #    step3:Check bfd state is up and trigger route
# #    ${bfdDestIpAddr}    step4:Modify bfdDestIpAddr Parameters    BFD_distname_1=${BFD_distname_1}    bfd_ip_notok=${bfd_ip_notok}
# #    step5:Check bfd state is down
# #    [Teardown]  Recover the test ENV    PARAMS_TRIGGER=${PARAMS_TRIGGER}    bfdDestIpAddr=${src_ip_value}
# #    ...    PARAMS=${PARAMS_recover_staticRoutes_1}    dict_ipappid=${dict_ipappid}
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
