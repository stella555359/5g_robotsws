*** Settings ***
Documentation
...   author: Lukasz Adamski
...   contact: lukasz.adamski@nokia.com
...   This is the ROBOT KEYWORDS file for CNI-99270


Library      taf.ue
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py    WITH NAME    au
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      testsuite/Wroclaw/RRM/resources/scf_verification/scf_verifier.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008985/resources/test_specific_keywords_8985.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI99270/resources/test_specific_keywords_99270.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME  TcpdumpSmod
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2      WITH NAME    L1L2
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils     WITH NAME    AdminUtils
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/tti/tti_streaming.py   WITH NAME    TTI
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attach_verification.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC007949/resources/test_specific_keywords.py
Resource     testsuite/Wroclaw/RRM/resources/btslog_collecting.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/keywords_9333.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008053/resources/test_specific_keywords.robot

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI99270/resources/test_specific_keywords_99270.py

*** Variables ***

@{cells_used_in_99270_3}=     1  3
@{cells_used_in_99270_5}=     1  2

*** Keywords ***

CNI-99270_03_SA_2CC_DLCA_Supercell_Intraband_covBasedA1
    [Documentation]   The purpose of this TC is to verify if UE can be attached to Super cell
    ...               and intra band DL CA 2CC TDD in SA mode can be
    ...               set up with sCellAdditionMethod set to covBasedA1.

    ${ports_PCI_97}  Create list  1  2  3  4  5  6  7  8
    ${ports_PCI_99}  Create list  9  10  11  12
    ${ports_PCI_98_LTE}  Create list  13    14    15    16    17    18


    ${pre_change_scf}               test_specific_keywords.Backup Current SCF
#    Set Preconditions 99270 3      ${cells_used_in_99270_3     # will be written after final TL configuration
    Upload SCF    99270_03


    Log To Console                  >>>> Initialise Attenuator
    Initialise Attenuator
    ${ports}                        Combine Lists              ${ports_PCI_97}  ${ports_PCI_99}
    Set Attenuation                 value_string=0             port=${ports_PCI_97}
    Set Attenuation                 value_string=40            port=${ports_PCI_99}
    Set Attenuation                 value_string=90            port=${ports_PCI_98_LTE}

    test_specific_keywords.Start Btslog On Local Machine
    Log to Console                  >>>> Checking if actSuperCell is True
    ${actSuperCell_param_1}=        test_specific_keywords_8985.check_actSuperCell_feature_activation_param_value
    ${actSuperCell_param_2}=        test_specific_keywords_8985.check_actSuperCell_feature_activation_param_value
    Should be true                  ${actSuperCell_param_1}
    Should be true                  ${actSuperCell_param_2}
    Log to console                  >>>> actSuperCell=true for both cells

    Log to console                  >>>> Step 1 - attach UE_1 to supercell_1    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    log  >> require_ues <<          console=True
    au.require_ues                  1    capabilities=CNI_03
    log  >> 3x30s attach_ues <<     console=True
    Wait Until Keyword Succeeds     3x    30s    au.attach_ues    1
    Set Attenuation                 value_string=0            port=${ports_PCI_99}
    ${sctp_logs}=                   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=                       find_exactly_x_attached_rntis    ${sctp_logs}   1

    ${nr_cell_dns}                  Get_Multiple_Cells_Dists   ${cells_used_in_99270_3}
    L1L2.Start_Gnbmirroring         new_l1l2=True              nr_cell_dns=${nr_cell_dns}

    log  >> sleep 20s <<            console=True
    BuiltIn.Sleep                           20

    Log to console                  >>>> Steps 2, 3 - start dl, ul tput         <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    Get Logging Start Time
    Log To Console                  >>>> start DL
    au.start dl data transfer on ues   num_of_ues=1  duration=60s  throughput=4Gbits/sec  protocol=udp  custom_dt_name=1
    Log To Console                  >>>> start UL
    au.start ul data transfer on ues   num_of_ues=1  duration=60s  throughput=100Mbits/sec  protocol=udp  custom_dt_name=1
    Log To Console                  >>>> sleep 10s for call stability
    BuiltIn.Sleep                           10
    Get 1st Call Setup Time         # starting checking 1-st call tput

    Log To Console                  >>>> check if tput is alive
    Run keyword and ignore error    au.check dl transfer is alive  1
    Run keyword and ignore error    au.check ul transfer is alive  1
    Log To Console                  >>>> sleep 20s
    BuiltIn.Sleep                           20

    Log to console                  >>>> Step 4 check peak tput         <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    Get 1st Call Stop Time
    Get Logging Stop Time
    Log to console                  >>>> sleep 10s
    BuiltIn.Sleep                           10

    Log To Console                  >>>> await dl data transfer finish
    au.await dl data transfer finish   num_of_ues=1  custom_dt_name=1

    Log To Console                  >>>> await ul data transfer finish
    au.await ul data transfer finish   num_of_ues=1  custom_dt_name=1


    Log to console                  >>>> Step 6 detach UE and checking logs        <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    Log To Console                  >>>> detach ues
    au.detach_ues                   1

    Log To Console                  >>>> L1L2.stop_gnbmirroring
    ${l1l2_logs_a}                  L1L2.stop_gnbmirroring_and_download_logs
    Log To Console                  >>>> sleep 5s
    BuiltIn.Sleep                           5

    log  >> stop_and_collect_btslog 1 <<
    ${btslog_dir_1}                 test_specific_keywords.stop_and_collect_btslog    attempt_number=one


    Log To Console                  >>>> THE END - check the logs now
    Get Omit Before 1st Call
    Get End After 1st Call

    Log To Console                 >>>> checking tput <<
    ${dl-tput-value}=  Run Keyword And Return Status  au.verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=400Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}
    ...                            custom_dt_name=1
    Log To Console                 tput: ${dl-tput-value}

    ${ul-tput-value}=  Run Keyword And Return Status  au.verify average ul throughput
    ...                            num_of_ues=1
    ...                            tput_min=20Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}
    ...                            custom_dt_name=1
    Log To Console                 tput: ${ul-tput-value}

    ${check_2CC}=       Run Keyword And Return Status  test_specific_keywords_99270.Check 2CC 03    ${btslog_dir_1}

    &{the_result_dict} =           Create Dictionary
    ...                            check_2CC=${check_2CC}
    ...                            dl-tput-value=${dl-tput-value}
    ...                            ul-tput-value=${ul-tput-value}


    Log To Console                 >>>> tput values check:
    Log To Console                 the_result_dict: ${the_result_dict}

    Dictionary Should Not Contain Value
    ...                             dictionary=&{the_result_dict}
    ...                             value=${False}
    ...                             msg='Results contain value False, check dict keys to see what goes wrong'


    [Teardown]   Run Keywords
     ...         Run keyword and ignore error                     Release Attenuator                            AND
     ...         Run keyword and ignore error  au.Detach_UEs         1                                          AND
     ...         L1L2.teardown_gnbmirroring                                                                     AND
     ...         Run keyword and ignore error  ${btslog_dir_1}    test_specific_keywords.Stop_And_Collect_Btslog  attempt_number=one   AND
     ...         Run keyword and ignore error  TcpdumpSmod.teardown_tcpdump_on_smod                             AND
     ...         test_specific_keywords.Revert SCF                    ${pre_change_scf}

CNI-99270_05_NSA_2CC_DLCA_Supercell_Interband_covBasedA1
    [Documentation]   The purpose of this TC is to verify if UE can be attached to Super cell (NSA)
    ...               and inter band DL CA 2CC TDD in SA mode can be
    ...               set up with sCellAdditionMethod set to covBasedA1.

    ${ports_PCI_101}  Create list  1  2  3  4  5  6  7   8
    ${ports_PCI_102}  Create list  13  14  15  16
    ${ports_PCI_103}  Create list      9  10  11  12
    ${LTE}      Create list      17    18


    ${pre_change_scf}               test_specific_keywords.Backup Current SCF
#    Set Preconditions 99270 5      ${cells_used_in_99270_5     # will be written after final TL configuration
    Upload SCF    99270_05


    Log To Console                  >>>> Initialise Attenuator
    Initialise Attenuator
    ${ports}                        Combine Lists              ${ports_PCI_101}  ${ports_PCI_102}
    Set Attenuation                 value_string=0             port=${ports_PCI_101}
    Set Attenuation                 value_string=0             port=${LTE}
    Set Attenuation                 value_string=90             port=${ports_PCI_103}
    Set Attenuation                 value_string=10            port=${ports_PCI_102}

    test_specific_keywords.Start Btslog On Local Machine
    Log to Console                  >>>> Checking if actSuperCell is True
    ${actSuperCell_param_1}=        test_specific_keywords_8985.check_actSuperCell_feature_activation_param_value
    ${actSuperCell_param_2}=        test_specific_keywords_8985.check_actSuperCell_feature_activation_param_value
    Should be true                  ${actSuperCell_param_1}
    Should be true                  ${actSuperCell_param_2}
    Log to console                  >>>> actSuperCell=true for both cells

    Log to console                  >>>> Step 1 - attach UE_1 to supercell_1    <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    TcpdumpSmod.start_tcpdump_on_smod    filename=${test_name}_L3_call    smod_master=${true}    smod_slave=${false}
    log  >> require_ues <<          console=True
    au.require_ues                  1    capabilities=MTK_NSA
    log  >> 3x30s attach_ues <<     console=True
    Wait Until Keyword Succeeds     3x    30s    au.attach_ues    1
    Set Attenuation                 value_string=0            port=${ports_PCI_102}
    ${sctp_logs}=                   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    ${rntis}=                       find_exactly_x_attached_rntis    ${sctp_logs}   1

    ${nr_cell_dns}                  Get_Multiple_Cells_Dists   ${cells_used_in_99270_5}
    L1L2.Start_Gnbmirroring         new_l1l2=True              nr_cell_dns=${nr_cell_dns}

    log  >> sleep 20s <<            console=True
    BuiltIn.Sleep                           20

    Log to console                  >>>> Steps 2, 3 - start dl, ul tput         <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    Get Logging Start Time
    Log To Console                  >>>> start DL
    au.start dl data transfer on ues   num_of_ues=1  duration=60s  throughput=4Gbits/sec  protocol=udp  custom_dt_name=1
    Log To Console                  >>>> start UL
    au.start ul data transfer on ues   num_of_ues=1  duration=60s  throughput=100Mbits/sec  protocol=udp  custom_dt_name=1
    Log To Console                  >>>> sleep 10s for call stability
    BuiltIn.Sleep                           10
    Get 1st Call Setup Time         # starting checking 1-st call tput

    Log To Console                  >>>> check if tput is alive
    Run keyword and ignore error    au.check dl transfer is alive  1
    Run keyword and ignore error    au.check ul transfer is alive  1
    Log To Console                  >>>> sleep 20s
    BuiltIn.Sleep                           20

    Log to console                  >>>> Step 4 check peak tput         <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    Get 1st Call Stop Time
    Get Logging Stop Time
    Log to console                  >>>> sleep 10s
    BuiltIn.Sleep                           10

    Log To Console                  >>>> await dl data transfer finish
    au.await dl data transfer finish   num_of_ues=1  custom_dt_name=1

    Log To Console                  >>>> await ul data transfer finish
    au.await ul data transfer finish   num_of_ues=1  custom_dt_name=1


    Log to console                  >>>> Step 6 detach UE and checking logs        <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    Log To Console                  >>>> detach ues
    au.detach_ues                   1

    Log To Console                  >>>> L1L2.stop_gnbmirroring
    ${l1l2_logs_a}                  L1L2.stop_gnbmirroring_and_download_logs
    Log To Console                  >>>> sleep 5s
    BuiltIn.Sleep                           5

    log  >> stop_and_collect_btslog 1 <<
    ${btslog_dir_1}                 test_specific_keywords.stop_and_collect_btslog    attempt_number=one


    Log To Console                  >>>> THE END - check the logs now
    Get Omit Before 1st Call
    Get End After 1st Call

    Log To Console                 >>>> checking tput <<
    ${dl-tput-value}=  Run Keyword And Return Status  au.verify average dl throughput
    ...                            num_of_ues=1
    ...                            tput_min=350Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}
    ...                            custom_dt_name=1
    Log To Console                 tput: ${dl-tput-value}

    ${ul-tput-value}=  Run Keyword And Return Status  au.verify average ul throughput
    ...                            num_of_ues=1
    ...                            tput_min=15Mbits/sec
    ...                            omit=${OMIT_BEFORE_1_CALL}
    ...                            end=${END_AFTER_1_CALL}
    ...                            custom_dt_name=1
    Log To Console                 tput: ${ul-tput-value}

    ${check_2CC}=       Run Keyword And Return Status  test_specific_keywords_99270.Check 2CC 05    ${btslog_dir_1}

    &{the_result_dict} =           Create Dictionary
    ...                            check_2CC=${check_2CC}
    ...                            dl-tput-value=${dl-tput-value}
    ...                            ul-tput-value=${ul-tput-value}


    Log To Console                 >>>> tput values check:
    Log To Console                 the_result_dict: ${the_result_dict}

    Dictionary Should Not Contain Value
    ...                             dictionary=&{the_result_dict}
    ...                             value=${False}
    ...                             msg='Results contain value False, check dict keys to see what goes wrong'


    [Teardown]   Run Keywords
     ...         Run keyword and ignore error                     Release Attenuator                            AND
     ...         Run keyword and ignore error  au.Detach_UEs         1                                          AND
     ...         L1L2.teardown_gnbmirroring                                                                     AND
     ...         Run keyword and ignore error  ${btslog_dir_1}    test_specific_keywords.Stop_And_Collect_Btslog  attempt_number=one   AND
     ...         Run keyword and ignore error  TcpdumpSmod.teardown_tcpdump_on_smod                             AND
     ...         test_specific_keywords.Revert SCF                    ${pre_change_scf}
