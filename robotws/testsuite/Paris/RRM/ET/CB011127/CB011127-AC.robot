*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
#
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]  CB011127-AC Test Suite for RIM-RS detection resource pooling on ABIP/ABIQ/ASOG/--- (Thor, framework -0 CB006991)
...               \nPrerequisite : CB009142 on half ABIP, with cell type of 8DL8UL or 8DL4UL or 4DL4UL, up to 6*100Mhz
#                 Scope          :
#                 Activation     : actNrRimRsResourcePooling= true
...               \nTest Case Scenario author : vincent.boulet@nokia.com
...               \nCreation Date             : 2025-09-12
...               \nModified Date             : 2025-02-03
#
#                 Version    Date       Author                          Notes
#                 0.1        FB2519     vincent.boulet@nokia.com        Robot creation and delivery
#                 0.2        FB2519     vincent.boulet@nokia.com        Noise power RI_N_PW_2 is used with frame structure 5GC001070 or 5GC001208
...             \n1.0        FB2603     vincent.boulet@nokia.com        Download BSR file by default
# --------------------------------------------------------------------------------------------------------------------------------------------------

# Libraries

# Resources
Resource                              ./resources/robot/CB011127-Common-Keywords.robot

# Suites
Suite Setup                           Suite Setup Common Private    keep_all_data_in_file=${True}
Suite Teardown                        Suite Teardown
Test Teardown                         Test Teardown Common Private    is_snapshot=${is_capture}[is_capture_snapshot]

*** Variables ***
# tests settings
&{TEST_SETTINGS_AC_1}
...                                   set_suite_dist_name_variables=Set Suite Dist Name Variables For CB011127
...                                   capture_duration=0            # capture duration during traffic starting phase
...                                   deviation=10                  # default deviation for throughput and double for uplink
...                                   dir=DL+UL                     # direction for supported traffic
...                                   duration=3                    # traffic duration during declaration phase
...                                   pm_waiting_period=1           # number of waiting periods added for observation
...                                   target_gnb=2                  # gnb target id
...                                   test_name=TC_TEST_SETTINGS_AC_1
...                                   total_nb_cell=4               # total number of cell used for ue's dispatching
...                                   total_nb_ue=0                 # total number of ue's to configure
...                                   nb_sa_ue=0                    # number of SA ue's to configure
...                                   csi_override_cqi=${None}      # cqi value to fix via csi_override testmode
...                                   ue_measurement_nr=${None}     # ue measurement nr support
...                                   bsr_folder=BSR    # https://gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr/-/tree/main/BSR?ref_type=heads
...                                   bsr_target=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
...                                   syslog_grep_target=${CURDIR}/resources/scripts/syslog_grep_results.sh

# ue's settings # configuration SA
#&{dict_ue_x}                         ue_id=                        # e.g. 1st SA_UE_ID TDD cell 1 or ${Dict_1st_SA_UE_Id[NRCELL-1]}
#...                                  call_type=                    # SA or NSA
#...                                  original_cell=                # original cell id for call establishment
#...                                  throughput=                   # dl throughput nonGBR
#...                                  throughput_ul=                # ul throughput nonGBR
#UE Id=X SA cell 1
&{dict_A_ue_1}   ue_id=1   call_type=SA   original_cell=1   throughput=1   throughput_ul=1   throughput_gbr=0   paging=${False}   csi_override_cqi=0
#UE Id=2X SA cell 2
&{dict_A_ue_21}  ue_id=21  call_type=SA   original_cell=2   throughput=1   throughput_ul=1   throughput_gbr=0   paging=${False}   csi_override_cqi=0
#UE Id=3X SA cell=3
&{dict_A_ue_31}  ue_id=31  call_type=SA   original_cell=3   throughput=1   throughput_ul=1   throughput_gbr=0   paging=${False}   csi_override_cqi=0
#UE Id=4X SA cell=4
&{dict_A_ue_41}  ue_id=41  call_type=SA   original_cell=4   throughput=1   throughput_ul=1   throughput_gbr=0   paging=${False}   csi_override_cqi=0
#UE Id=5X SA cell=5
&{dict_A_ue_51}  ue_id=51  call_type=SA   original_cell=5   throughput=1   throughput_ul=1   throughput_gbr=0   paging=${False}   csi_override_cqi=0
#UE Id=6X SA cell=6
&{dict_A_ue_61}  ue_id=61  call_type=SA   original_cell=6   throughput=1   throughput_ul=1   throughput_gbr=0   paging=${False}   csi_override_cqi=0
# --------------------------------------------------------------------------------------------------------------------------------------------------
#*** Keywords ***
# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Test Cases ***
[1] CB011127-SR-AC_004_Alternate3_CB009142_5GC001208
    #CB011127-SR-AC_004_Alternate3 CB009142 Half ABIP 6 cells 8DL8UL with PRB pooling_Frame structure = 5GC001208
    #USELESS#[Tags]    CLOUD_5G_I_MP_AP_LOOO    VARIANT_PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_6CC_8DL8UL_AEQE_RIM_RS_FW0

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_AC_1}
    ${param.test_name}=               Set Variable    TC_CB011127-SR-AC_004_Alternate3_CB009142_5GC001208
    Set To Dictionary                 ${param}    counter_constraint    CB011127-SR-AC_004
    Step                              ${param.set_suite_dist_name_variables}
    &{is_capture}=                    Create Dictionary    is_capture_core=${False}
    ...                                                    is_capture_cprt=${False}
    ...                                                    is_capture_l1l2=${False}
    ...                                                    is_capture_tti=${True}
    ...                                                    is_capture_syslog=${True}
    ...                                                    is_capture_snapshot=${True}
    # Check alarm presence or not, for 7114 fault 4613 in case CELL SERVICE PROBLEM due to BSR package missing
    ${is_alarm_present}=              Is Alarm Present    alarm_id=7114    fault_id=4613    iteration=1    confirm_presence=${False}
    Run Keyword If    '${param.bsr_target}' != '${None}'
    ...    Critical Step              CB011127 Download BSR file    ${param}
    Set To Dictionary                 ${dict_A_ue_1}      throughput_gbr    5
    Set To Dictionary                 ${dict_A_ue_21}     throughput_gbr    5
    Set To Dictionary                 ${dict_A_ue_31}     throughput_gbr    5
    Set To Dictionary                 ${dict_A_ue_41}     throughput_gbr    5
    Set To Dictionary                 ${dict_A_ue_51}     throughput_gbr    5
    Set To Dictionary                 ${dict_A_ue_61}     throughput_gbr    5
    ${current_ues_settings}=          Create List    ${dict_A_ue_1}
    ...                                              ${dict_A_ue_21}
    ...                                              ${dict_A_ue_31}
    ...                                              ${dict_A_ue_41}
    ...                                              ${dict_A_ue_51}
    ...                                              ${dict_A_ue_61}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Step                              Set RAD Parameters Common Private    rad_0x5801CB_val=0    rad_0x58057A_val=4    rad_0x58057F_val=64
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    @{list_position_nrcell_tdd}=      Create List    1    2    3    4    5    6    # 1= first nrcell, 2nd, 3rd, etc.
    ${scf_file}=                      Start Session Full Commissioning For CB011127    test_name=${param.test_name}
    ${current_bwpDN_initial}=         Set Variable    5
    ${current_bwpDN_dedicated}=       Set Variable    57
    # Configure Bandwidth TDD 100MHz with frame structure 5GC001208
    Step                              SCF Configure Bandwidth TDD 100MHz 5GC001208    list_nrcell_to_configure=${list_position_nrcell_tdd}
    ...                               current_bwpDN_initial=${current_bwpDN_initial}
    ...                               current_bwpDN_dedicated=${current_bwpDN_dedicated}
    # Update RIM RS configuration
    @{list_position_nrcell_for_rimrs}=    Create List    1    2    3    4    5    6    # 1= first nrcell, 2nd, 3rd, etc.
    @{list_rsType1NScId}=             Create List    1    2    3    4
    @{list_startRbForRs}=             Create List    96
    &{dico_nrcell}=                   Create Dictionary    cellDepType=SA+NSA
    ...                                                    actNrRim=framework-0
    ...                                                    actNrRimRsResourcePooling=true    # feature CB011127 ON
    ...                                                    bbmodBoardConfigType=NRFDD_NRTDD    # feature CB009142 ON, half-ABIP with 1 L1 pool
    ...                                                    factorRsSequence=1
    ...                                                    nrRimMitigationScheme=UL and DL mitigation
    ...                                                    numRbForRs=48 RBs
    ...                                                    numRsType1SetId=65536 setIDs
    ...                                                    offsetRsSequence=1
    ...                                                    repetitionRsType1=r2
    ...                                                    rsNearFarConfig=near only
    ...                                                    rsPattern1Period=2.5ms
    ...                                                    rsTransTrigger=RI trigger
    ...                                                    rsType1NScId=${list_rsType1NScId}
    ...                                                    startRbForRs=${list_startRbForRs}
    ...                                                    nrcell_tdd=${list_position_nrcell_for_rimrs}
    Step                              SCF Configure NRCELL For CB011127    ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Update NRPMRNL configuration
    &{dico_NRPMRNL}=                  Create Dictionary    miNrCellUtilization=5min
    ...                                                    miNrRim=5min
    Step                              SCF Configure NRPMRNL         ${dico_NRPMRNL}
    #
    # Capture SYSLOG during commissioning and restarting as Log1
    ${current_syslog}=    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${is_capture}[is_capture_syslog]
    ...                               SYSLOG Start    host=${GNB_DU.sys[0].M}    name=commissioning
    #
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For CB011127    updated_scf=${scf_file}    skip_errors=${False}
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${is_capture}[is_capture_syslog]
    ...                               SYSLOG Stop    syslog=${current_syslog}
    Should Be True                    ${result} == ${True}
    #
    &{dico_test}=                     Create Dictionary    rsNearFarConfig=0
    ...                                                    factorRsSequence=1
    ...                                                    offsetRsSequence=1
    ...                                                    rsType1NScId=1,2,3,4
    ...                                                    numRbForRs=48
    ...                                                    rsPattern1Period=25
    ...                                                    repetitionRsType1=2
    ...                                                    startRbForRs=96
    ...                                                    numRsType1SetId=65536
    Call And Then Traffic For CB011127 With Remote Interference     ${param}    ${current_ues_settings}    ${is_capture}
    ...                               list_position_nrcell=${list_position_nrcell_for_rimrs}    dico_testmode=${dico_test}
    ...                               noise_power_val=${RI_N_PW_2}
    #
    &{dico_rd_counters}=              Create Dictionary    AVG_RIM_RS_RSC_ALLOC=30.00    #M55308CRD52002
    ${rd_files}=                      RdCounters.Collect RD Counters
    FOR    ${position}    IN    @{list_position_nrcell_for_rimrs}
        ${internal_pos}=              Evaluate    ${position}-1
        ${victim_cell}=               Set Variable    ${TDD_Cell_list[${internal_pos}].nrCellId}
        ${rd_result}=                 RdCounters.Verify RD Counters With Criteria    counters_dir=${rd_files}
        ...                           expected_counters=${dico_rd_counters}
        ...                           cell_id=${victim_cell}
        ...                           comparison='>='
    END
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
