*** Settings ***
Documentation
...   author: Adam Chamera
...   contact: adam.chamera@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB009333


Library   taf.ue
Library   taf.sbts.oam.coam.admin                                                        WITH NAME    coam
Library   taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter                               WITH NAME    GnbCounter
Library   taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                      WITH NAME    gnbcell
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Library   testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Resource  testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py                      WITH NAME    au
Library   testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod    WITH NAME    TcpdumpSmod
Library   testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2                  WITH NAME    L1L2
Library   testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils         WITH NAME    AdminUtils
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py                WITH NAME    TTI

Library    Collections
Library    DateTime
Library  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008985/resources/test_specific_keywords_8985.py  WITH NAME  8985
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008941/resources/test_specific_keywords_8941.py
Variables  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008941/resources/test_specific_keywords_8941.py
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008053/resources/test_specific_keywords.robot


*** Variables ***
${cells_used_in_TC_8941_06}               1
${subcells_used_in_TC_8941_06}            1  2  3  4  5  6


*** Keywords ***
CB008941-5G_06_Verify_SRS_triggered_with_PUSCH_mapping_type_B_on_DU_with_Loki_BB_HW_eCPRI_TDD_FR1_FD_Beamforming_RU
    [Documentation]   This user scenario validates system behavior in case when UL UP dynamic fragmentation
    ...               is activated and SRS is triggered with PUSCH mapping type B, the data transmission
    ...               in eCPRI uplink contains the NR IQ of scheduled PRBs for TDD FR1 deployments,
    ...               the NR carrier supports UL PRB dynamic fragmentation. No impact when the SRS is triggered
    ...               in last symbol with PUSCH mapping type B. This Test Case will check also counters from test 08:
    ...               M55308C10002 (PRBs used for PUSCH) and M55308C10004 (PRBs available for PUSCH)

    log  >> start btslog <<         console=True
    test_specific_keywords_8941.start btslog on local machine

    log  >> preconditions <<        console=True
    ${pre_change_scf}               test_specific_keywords_8941.Backup Current Scf
    set preconditions 8941 06       ${subcells_used_in_TC_8941_06}
    log  >> require_ues <<          console=True
    au.require_ues                  2    capabilities=SA_VONR

    Log to console                  >> Checking if SuperCell feature is activated
    ${feature_state}=               8985.check_actSuperCell_feature_activation_param_value
    Should be true                  ${feature_state}
    Log to console                  actSuperCell=true

    log  >> 3x30s attach_ues <<     console=True
    Wait Until Keyword Succeeds     3x    30s    au.attach_ues    2
    L1L2.start_gnbmirroring         filename=tput
    log  >> sleep 20s <<            console=True
    BuiltIn.Sleep                           20

    Get Logging Start Time
    log  >> start UL 1st time <<    console=True
    au.start ul data transfer on ues   num_of_ues=2  duration=480s  throughput=100Mbits/sec  protocol=udp  custom_dt_name=1
    log  >> start DL 1st time <<    console=True
    au.start dl data transfer on ues   num_of_ues=2  duration=480s  throughput=4Gbits/sec  protocol=udp  custom_dt_name=1
    log  >> sleep 10s for call stability <<       console=True
    BuiltIn.Sleep                           10

    Get 1st Call Setup Time
    Run keyword and ignore error    au.check dl transfer is alive  2
    Run keyword and ignore error    au.check ul transfer is alive  2
    log  >> sleep 20s <<            console=True
    BuiltIn.Sleep                           20
    Get 1st Call Stop Time
    Get Logging Stop Time
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           10

    log  >> await dl data transfer finish <<      console=True
    au.await dl data transfer finish   num_of_ues=2  custom_dt_name=1
    log  >> detach ues <<                         console=True
    au.detach_ues                   2

    log  >> L1L2.stop_gnbmirroring <<             console=True
    ${l1l2_logs}                    L1L2.stop_gnbmirroring_and_download_logs
    log  >> sleep 10s <<            console=True
    BuiltIn.Sleep                           10
    log  >> stop_and_collect_btslog <<            console=True
    ${btslog_dir}                   test_specific_keywords_8941.stop_and_collect_btslog

    log  >>>>>>>>>>>>>>>>>>>>>>>>> THE END - check the logs now <<        console=True
    Get Omit Before 1st Call
    Get End After 1st Call

    log  >> checking tput <<       console=True
    ${tput-value}=  Run Keyword And Return Status  au.verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=200Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}
    ...                            custom_dt_name=1
    log  tput: ${tput-value}       console=True

    ${dlUPlan_in_syslog_result}=   Run Keyword And Return Status    Check dlUPlan in syslog      ${btslog_dir}

    ${counter_ids} =  Create List    M55308C10002    M55308C10004
    ${counter_dir} =   Collect Counters    log_name=tc6_8941  target_dir=${OUTPUT DIR}/counters
    ${relevant_counters_result} =  check_8941_counters   ${counter_dir}  ${counter_ids}

    &{the_result_dict} =           Create Dictionary
    ...                            tput=${tput-value}
    ...                            dlUPlan_in_syslog_result=${dlUPlan_in_syslog_result}
    ...                            relevant_counters_result=${relevant_counters_result}

    Log  the_result_dict: ${the_result_dict}      console=True
    Dictionary Should Not Contain Value
    ...                             dictionary=&{the_result_dict}
    ...                             value=${False}
    ...                             msg='Results contain value False, check dict keys to see what goes wrong'

     [Teardown]  Run Keywords
     ...         Run keyword and ignore error  au.detach_ues         2                                      AND
     ...         L1L2.teardown_gnbmirroring                                                                 AND
     ...  Run keyword and ignore error  ${btslog_dir}  test_specific_keywords_8941.stop_and_collect_btslog  AND
     ...         test_specific_keywords_8941.Revert SCF                    ${pre_change_scf}
