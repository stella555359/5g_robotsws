*** Settings ***
# https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=5GFTPARIS&title=ET+Coding+Rules
#
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     [SUITE PURPOSE]   CB012738-A Test Suite
...               \nPrerequisite : gNB configured with x Cells T+F & RU detected
#                   Scope        :
#
...               \nTest Case Scenario author : vincent.boulet@nokia.com
...               \nCreation Date             : 2025-02-10
...               \nModified Date             : 2025-02-10
#
#                 Version    Date       Author                          Notes
...               \n0.1      FB2503     vincent.boulet@nokia.com        Creation robot and test cases
# --------------------------------------------------------------------------------------------------------------------------------------------------

#STOP_TEST#       > code to stop test execution by forcing an error:
#   Should Be True                    ${True} == ${False}    or    Return From Keyword
#DEBUG_LOG#       >> temporarily commented out so as not to execute the corresponding debugging command
#TEST#            > code marked for internal testing
#TEMP#            > official code to restitute after debug
#OBSOLETE#
#PB_DETECTED_241129#
#KEY_ERROR_NOT_IN_INDEX#

# Libraries

# Resources
Resource                              ./resources/robot/CB012738-A-Keywords.robot

# Suites
Suite Setup                           Suite Setup Common Private    keep_all_data_in_file=${True}
Suite Teardown                        Suite Teardown
Test Teardown                         Test Teardown Common Private    is_snapshot=${is_capture}[is_capture_snapshot]

*** Variables ***
# tests settings
&{CB012738_A_01_SA_F}
...                                   set_suite_dist_name_variables=Set Suite Dist Name Variables For CB0012738
...                                   capture_duration=0            # capture duration during traffic starting phase
...                                   deviation=0                   # default deviation for throughput and double for uplink
...                                   dir=${None}                   # direction for supported traffic
...                                   duration=3                    # traffic duration during declaration phase
...                                   pm_waiting_period=1           # number of waiting periods added for observation
...                                   target_gnb=2                  # gnb target id
...                                   test_name=TC_CB012738_A_01_SA_FDD
...                                   total_nb_cell=4               # total number of cell used for ue's dispatching
...                                   total_nb_ue=5                 # total number of ue's to configure
...                                   nb_sa_ue=5                    # number of SA ue's to configure
...                                   csi_override_cqi=${None}      # cqi value to fix via csi_override testmode
...                                   ue_measurement_nr=${None}     # ue measurement nr support

&{CB012738_A_02_T}
...                                   set_suite_dist_name_variables=Set Suite Dist Name Variables For CB0012738
...                                   test_name=TC_CB012738_A_02_TDD
...                                   total_nb_cell=4               # total number of cell used for ue's dispatching
...                                   total_nb_ue=0                 # total number of ue's to configure
...                                   nb_sa_ue=0                    # number of SA ue's to configure

&{TEST_SETTINGS_1}
...                                   set_suite_dist_name_variables=Set Suite Dist Name Variables For CB0012738
...                                   capture_duration=0            # capture duration during traffic starting phase
...                                   deviation=10                  # default deviation for throughput and double for uplink
...                                   dir=DL+UL                     # direction for supported traffic
...                                   duration=3                    # traffic duration during declaration phase
...                                   pm_waiting_period=1           # number of waiting periods added for observation
...                                   target_gnb=2                  # gnb target id
...                                   test_name=TC_TEST_SETTINGS_1
...                                   total_nb_cell=4               # total number of cell used for ue's dispatching
...                                   total_nb_ue= 0                # total number of ue's to configure
...                                   nb_sa_ue=0                    # number of SA ue's to configure
...                                   csi_override_cqi=${None}      # cqi value to fix via csi_override testmode
...                                   ue_measurement_nr=${None}     # ue measurement nr support

# ue's settings # configuration SA
#&{dict_ue_x}                         ue_id=                        # e.g. 1st SA_UE_ID TDD cell 1 or ${Dict_1st_SA_UE_Id[NRCELL-1]}
#...                                  call_type=                    # SA or NSA
#...                                  original_cell=                # original cell id for call establishment
#...                                  throughput=                   # dl throughput nonGBR
#...                                  throughput_ul=                # ul throughput nonGBR
#UE Id=1 SA cell 1
&{dict_A_ue_1}                        ue_id=1      call_type=SA     original_cell=1    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_2}                        ue_id=2      call_type=SA     original_cell=1    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_3}                        ue_id=3      call_type=SA     original_cell=1    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_4}                        ue_id=4      call_type=SA     original_cell=1    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_5}                        ue_id=5      call_type=SA     original_cell=1    throughput=0    throughput_ul=0    paging=${False}
#UE Id=21 SA cell 2
&{dict_A_ue_21}                       ue_id=21     call_type=SA     original_cell=2    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_22}                       ue_id=22     call_type=SA     original_cell=2    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_23}                       ue_id=23     call_type=SA     original_cell=2    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_24}                       ue_id=24     call_type=SA     original_cell=2    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_25}                       ue_id=25     call_type=SA     original_cell=2    throughput=0    throughput_ul=0    paging=${False}
#UE Id=51 SA cell=3
&{dict_A_ue_51}                       ue_id=51     call_type=SA     original_cell=3    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_52}                       ue_id=52     call_type=SA     original_cell=3    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_53}                       ue_id=53     call_type=SA     original_cell=3    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_54}                       ue_id=54     call_type=SA     original_cell=3    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_55}                       ue_id=55     call_type=SA     original_cell=3    throughput=0    throughput_ul=0    paging=${True}
#UE Id=71 SA cell=4
&{dict_A_ue_71}                       ue_id=71     call_type=SA     original_cell=4    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_72}                       ue_id=72     call_type=SA     original_cell=4    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_73}                       ue_id=73     call_type=SA     original_cell=4    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_74}                       ue_id=74     call_type=SA     original_cell=4    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_75}                       ue_id=75     call_type=SA     original_cell=4    throughput=0    throughput_ul=0    paging=${False}
# ue's settings # configuration NSA
#UE Id=101 NSA cell=1
&{dict_A_ue_101}                      ue_id=101    call_type=NSA    original_cell=1    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_102}                      ue_id=102    call_type=NSA    original_cell=1    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_103}                      ue_id=103    call_type=NSA    original_cell=1    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_104}                      ue_id=104    call_type=NSA    original_cell=1    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_105}                      ue_id=105    call_type=NSA    original_cell=1    throughput=0    throughput_ul=0    paging=${False}
#UE Id=121 NSA cell=2
&{dict_A_ue_121}                      ue_id=121    call_type=NSA    original_cell=2    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_122}                      ue_id=122    call_type=NSA    original_cell=2    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_123}                      ue_id=123    call_type=NSA    original_cell=2    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_124}                      ue_id=124    call_type=NSA    original_cell=2    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_125}                      ue_id=125    call_type=NSA    original_cell=2    throughput=0    throughput_ul=0    paging=${False}
#UE Id=151 NSA cell=3
&{dict_A_ue_151}                      ue_id=151    call_type=NSA    original_cell=3    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_152}                      ue_id=152    call_type=NSA    original_cell=3    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_153}                      ue_id=153    call_type=NSA    original_cell=3    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_154}                      ue_id=154    call_type=NSA    original_cell=3    throughput=5    throughput_ul=0    paging=${False}
&{dict_A_ue_155}                      ue_id=155    call_type=NSA    original_cell=3    throughput=0    throughput_ul=0    paging=${False}
#UE Id=171 NSA cell=4
&{dict_A_ue_171}                      ue_id=171    call_type=NSA    original_cell=4    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_172}                      ue_id=172    call_type=NSA    original_cell=4    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_173}                      ue_id=173    call_type=NSA    original_cell=4    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_174}                      ue_id=174    call_type=NSA    original_cell=4    throughput=0    throughput_ul=5    paging=${False}
&{dict_A_ue_175}                      ue_id=175    call_type=NSA    original_cell=4    throughput=0    throughput_ul=0    paging=${False}
# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Keywords ***
CB012738-A_02 Check PDL Rules SANSA TDD
    [Arguments]             ${param}
    ...                     ${list_position_nrcell_tdd}
    ...                     ${is_capture}

    Dated Log New Line                ----CB012738-A_02 Check PDL Rules SANSA TDD-----------------------------------
    # Capture SYSLOG logs during commissioning
    ${syslog}=    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${is_capture}[is_capture_syslog]    Syslogs.SYSLOG Start
    ...                                                             host=${GNB_DU.sys[0].M}    name=_commissioning
    #
    Dated Log New Line                ----Check PDL rule------------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             alSelection=static
    ...                                                             nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${False}
    #
    Run Keyword If    ${AUTO_SAVE_DEBUG_DATA} and ${is_capture}[is_capture_syslog]    Step    Syslogs.SYSLOG Stop    syslog=${syslog}
# --------------------------------------------------------------------------------------------------------------------------------------------------
*** Test Cases ***
[1] CB012738-A_01_Feature_Activation_SANSA_FDD
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${CB012738_A_01_SA_F}
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_fdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    ${current_ues_settings}=          Create List    ${dict_A_ue_51}    ${dict_A_ue_52}    ${dict_A_ue_53}    ${dict_A_ue_54}    ${dict_A_ue_55}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${False}
    ...                                                             is_capture_l1l2=${False}
    ...                                                             is_capture_tti=${False}
    ...                                                             is_capture_syslog=${True}
    ...                                                             is_capture_snapshot=${True}
    #
    Set RAD Parameters Common Private    rad_0x58046F_val=0
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             alSelection=dynamic
    ...                                                             nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    &{dico_NRDRB}=                    Create Dictionary             allowedPdcchPowerBoostALDueCce=AL2_AL4
    ...                                                             allowedPdcchPowerBoostALDueCfg=AL2_AL4
    Step                              SCF Configure NRDRB           ${dico_NRDRB}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${True}
    #
    Dated Log New Line                ----Call And Then Traffic For CB012738----------------------------------------
    Call And Then Traffic For CB012738    ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB012738-A_02_Check_PDL_Rules_SANSA_TDD_Step_1
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00    # VARIANT CMWV PDL RULE Step 1 #

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${CB012738_A_02_T}
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_tdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    Dated Log New Line                > Test name is ${param.test_name}_Step_1
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${False}
    ...                                                             is_capture_l1l2=${False}
    ...                                                             is_capture_tti=${False}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    #
    Set RAD Parameters Common Private    rad_0x58046F_val=0
    CB012738-A_02 Check PDL Rules SANSA TDD    ${param}    ${list_position_nrcell_tdd}    ${is_capture}
    # add check to control the PDL text for step 1
    #[Teardown]    # Reserved to internal testing usage


[1] CB012738-A_02_Check_PDL_Rules_SANSA_TDD_Step_2
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD_GMC    SBTS00                      # VARIANT MMWV PDL RULE Step 2 #

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${CB012738_A_02_T}
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_tdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    Dated Log New Line                > Test name is ${param.test_name}_Step_2
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${False}
    ...                                                             is_capture_l1l2=${False}
    ...                                                             is_capture_tti=${False}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    #
    Set RAD Parameters Common Private    rad_0x58046F_val=0
    CB012738-A_02 Check PDL Rules SANSA TDD    ${param}    ${list_position_nrcell_tdd}    ${is_capture}
    # add check to control the PDL text for step 2
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB012738-A_03_04_NSA_TDD_AL4_DL_UL
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_1}
    ${param.test_name}=               Set Variable    TC_CB012738_A_03_04_NSA_TDD
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_tdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    #@{list_ues_C1_T_NSA_C2_T_NSA}
    ${param.csi_override_cqi}=        Set Variable    3    # cqi=3 <=> dynamic AL8
    Set To Dictionary                 ${dict_A_ue_101}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_102}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_103}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_104}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_105}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_121}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_122}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_123}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_124}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_125}    csi_override_cqi    ${param.csi_override_cqi}
    ${current_ues_settings}=          Create List    ${dict_A_ue_101}
    ${current_ues_settings}=          Create List    ${dict_A_ue_101}    ${dict_A_ue_102}    ${dict_A_ue_103}    ${dict_A_ue_104}    ${dict_A_ue_105}
    ...                                              ${dict_A_ue_121}    ${dict_A_ue_122}    ${dict_A_ue_123}    ${dict_A_ue_124}    ${dict_A_ue_125}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    0
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${True}
    ...                                                             is_capture_l1l2=${True}
    ...                                                             is_capture_tti=${True}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    #
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    Step                              SCF Configure Bandwidth TDD 40MHz    list_nrcell_to_configure=${list_position_nrcell_tdd}
    ${current_bwpDN_dedicated}=       Set Variable    51
    #
    # Configure AL4 dynamic without power boost
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             cellDepType=SA+NSA
    ...                                                             actPdcchSharingWithPdsch=false
    ...                                                             actCceSplit=false
    ...                                                             alSelection=dynamic
    ...                                                             dciDedicatedAggregationLevel=AL4
    ...                                                             dciPagingAggregationLevel=AL4
    ...                                                             dciRaCompletionAggregationLevel=AL4
    ...                                                             dciRaMsg2AggregationLevel=AL4
    ...                                                             dciSiAggregationLevel=AL4
    #...                                                            downgradeAL16toAL8=notAllowed
    #...                                                            downgradeALProactive=false
    ...                                                             nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Update BWP_PROFILE_PDCCH dynamicAggregationLevelSet
    &{dico_dynamicAggregationLevelSet}=    Create Dictionary        aggregationLevelList=AL1_AL2_AL4_AL8
    ...                                                             cqiCorrectionUp=8
    ...                                                             cqiDciCssAl1=131
    ...                                                             cqiDciCssAl16=0
    ...                                                             cqiDciCssAl2=101
    ...                                                             cqiDciCssAl4=69
    ...                                                             cqiDciCssAl8=33
    ...                                                             highOlcCqiOffset=100
    ...                                                             lowOlcCqiOffset=1100
    ...                                                             pCqiErasureActTimer=160
    ...                                                             pCqiErasureReduction=10
    Step                              SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet    ${dico_dynamicAggregationLevelSet}
    ...                                                             ${list_position_nrcell_tdd}
    ...                                                             list_nrcell=${TDD_Cell_list}
    # Update BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon.numOfPdcchCandidatesInAL <= maybe not needed in this case
    # Re-create BWP_PROFILE_PDCCH CONFIG_DEDICATED to update coresetDedicated.size, searchSpaceDedicated.numOfPdcchCandidatesInAL
    &{dico_coresetDedicated}=         Create Dictionary             size=96
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             searchSpaceId=7
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             numOfPdcchCandidatesInAL2=n0    #n2
    ...                                                             numOfPdcchCandidatesInAL4=n4
    ...                                                             numOfPdcchCandidatesInAL8=n0    #n2
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_NRDRB}=                    Create Dictionary             allowedPdcchPowerBoostALDueCce=none
    ...                                                             allowedPdcchPowerBoostALDueCfg=AL4
    Step                              SCF Configure NRDRB           ${dico_NRDRB}
    &{dico_NRPMRNL}=                  Create Dictionary             miNrCellUtilization=5min
    ...                                                             miNrPdcch=5min
    ...                                                             miNrPdcch2=5min
    Step                              SCF Configure NRPMRNL         ${dico_NRPMRNL}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${True}
    #
    Dated Log New Line                ----Call And Then Traffic For CB012738 With Cqi Customization Bis-------------
    Call And Then Traffic For CB012738 With Cqi Customization Bis    ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB012738-A_05_06_NSA_FDD_AL2_DL_UL
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_1}
    ${param.test_name}=               Set Variable    TC_CB012738_A_05_06_NSA_FDD
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_fdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    #@{list_ues_C3_F_NSA_C4_F_NSA}
    ${current_ues_settings}=          Create List    ${dict_A_ue_151}    ${dict_A_ue_152}    ${dict_A_ue_153}    ${dict_A_ue_154}    ${dict_A_ue_155}
    ...                                              ${dict_A_ue_171}    ${dict_A_ue_172}    ${dict_A_ue_173}    ${dict_A_ue_174}    ${dict_A_ue_175}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    0
    Dated Log New Line                > Test name is ${param.test_name}
    ${param.csi_override_cqi}=        Set Variable    6    # cqi=6 <=> dynamic AL4
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${True}
    ...                                                             is_capture_l1l2=${True}
    ...                                                             is_capture_tti=${True}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    #
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    Step                              SCF Configure Bandwidth FDD 10MHz    list_nrcell_to_configure=${list_position_nrcell_fdd}
    ${current_bwpDN_initial}=         Set Variable    4
    ${current_bwpDN_dedicated}=       Set Variable    31
    #
    # Configure AL2 dynamic without power boost
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             cellDepType=SA+NSA
    ...                                                             actPdcchSharingWithPdsch=false
    ...                                                             actCceSplit=false
    ...                                                             alSelection=dynamic
    ...                                                             dciDedicatedAggregationLevel=AL2
    ...                                                             dciPagingAggregationLevel=AL4    # AL4 or AL8 is supported
    ...                                                             dciRaCompletionAggregationLevel=AL2
    ...                                                             dciRaMsg2AggregationLevel=AL2
    ...                                                             dciSiAggregationLevel=AL4    # AL4 or AL8 is supported
    #...                                                            downgradeAL16toAL8=notAllowed
    #...                                                            downgradeALProactive=false
    ...                                                             nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    # Update BWP_PROFILE_PDCCH dynamicAggregationLevelSet
    &{dico_dynamicAggregationLevelSet}=    Create Dictionary        aggregationLevelList=AL1_AL2_AL4_AL8
    ...                                                             cqiCorrectionUp=8
    ...                                                             cqiDciCssAl1=131
    ...                                                             cqiDciCssAl16=0
    ...                                                             cqiDciCssAl2=101
    ...                                                             cqiDciCssAl4=69
    ...                                                             cqiDciCssAl8=33
    ...                                                             highOlcCqiOffset=100
    ...                                                             lowOlcCqiOffset=1100
    ...                                                             pCqiErasureActTimer=160
    ...                                                             pCqiErasureReduction=10
    Step                              SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet    ${dico_dynamicAggregationLevelSet}
    ...                                                             ${list_position_nrcell_fdd}
    ...                                                             list_nrcell=${FDD_Cell_list}
    # Update BWP_PROFILE_PDCCH due to AL2 configuration
    &{dico_pdcch}=                    Create Dictionary             alSelection=static
    ...                                                             dciDedicatedAggregationLevel=AL2
    ...                                                             dciPagingAggregationLevel=AL4
    ...                                                             dciRaCompletionAggregationLevel=AL2
    ...                                                             dciRaMsg2AggregationLevel=AL2
    ...                                                             dciSiAggregationLevel=AL4
    #...                                                            downgradeAL16toAL8=notAllowed
    #...                                                            downgradeALProactive=false
    Step                              SCF Configure BWP_PROFILE_PDCCH    dn_bwp_pdcch=${dn_bwp_profile_base}${current_bwpDN_initial}/PDCCH-1
    ...                                                             dico_pdcch=${dico_pdcch}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             periodicity=sl1
    ...                                                             searchSpaceId=1
    &{dico_searchSpaceCommon_2}=      Create Dictionary             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL2=n2
    ...                                                             numOfPdcchCandidatesInAL4=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             periodicity=sl1
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_initial}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             periodicity=sl1
    ...                                                             searchSpaceId=4
    &{dico_searchSpaceCommon_2}=      Create Dictionary             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL2=n2
    ...                                                             numOfPdcchCandidatesInAL4=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             periodicity=sl1
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_dedicated}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Re-create BWP_PROFILE_PDCCH CONFIG_DEDICATED to update coresetDedicated.size, searchSpaceDedicated.numOfPdcchCandidatesInAL
    &{dico_coresetDedicated}=         Create Dictionary             coresetDedicated=null
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL2=n2
    ...                                                             numOfPdcchCandidatesInAL4=n0
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL2=n4
    ...                                                             numOfPdcchCandidatesInAL4=n0
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    &{dico_searchSpaceDedicated_3}=   Create Dictionary             dciFormat=formats0-0-And-1-0
    ...                                                             duration=19
    ...                                                             monitoringSymbolWithinSlot=symbol_2
    ...                                                             numOfPdcchCandidatesInAL2=n2
    ...                                                             numOfPdcchCandidatesInAL4=n0
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl20
    ...                                                             searchSpaceId=9
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=1
    &{dico_searchSpaceDedicated_4}=   Create Dictionary             dciFormat=formats0-1-And-1-1
    ...                                                             duration=19
    ...                                                             monitoringSymbolWithinSlot=symbol_2
    ...                                                             numOfPdcchCandidatesInAL2=n4
    ...                                                             numOfPdcchCandidatesInAL4=n0
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl20
    ...                                                             searchSpaceId=10
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=1
    @{list_searchSpaceDedicated}=     Create List                   ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    ...                                                             ${dico_searchSpaceDedicated_3}    ${dico_searchSpaceDedicated_4}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}    dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_NRDRB}=                    Create Dictionary             allowedPdcchPowerBoostALDueCce=none
    ...                                                             allowedPdcchPowerBoostALDueCfg=AL2
    Step                              SCF Configure NRDRB           ${dico_NRDRB}
    &{dico_NRPMRNL}=                  Create Dictionary             miNrCellUtilization=5min
    ...                                                             miNrPdcch=5min
    ...                                                             miNrPdcch2=5min
    Step                              SCF Configure NRPMRNL         ${dico_NRPMRNL}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${True}
    #
    Dated Log New Line                ----Call And Then Traffic For CB012738---------------------------------------------
    Call And Then Traffic For CB012738    ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB012738-A_15_16_NSA_FDD_AL2_DL_UL
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_1}
    ${param.test_name}=               Set Variable    TC_CB012738_A_15_16_NSA_FDD
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_fdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    #@{list_ues_C3_F_NSA_C4_F_NSA}
    ${param.csi_override_cqi}=        Set Variable    6    # cqi=6 <=> dynamic AL4
    Set To Dictionary                 ${dict_A_ue_151}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_152}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_153}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_154}    csi_override_cqi    14    # AL1
    Set To Dictionary                 ${dict_A_ue_155}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_171}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_172}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_173}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_174}    csi_override_cqi    14    # AL1
    Set To Dictionary                 ${dict_A_ue_175}    csi_override_cqi    ${param.csi_override_cqi}
    # UEs settings 3 potentials AL4 with traffic + 1 AL1 traffic
    #${current_ues_settings}=         Create List    ${dict_A_ue_151}    ${dict_A_ue_152}    ${dict_A_ue_153}    ${dict_A_ue_154}
    #...                                             ${dict_A_ue_171}    ${dict_A_ue_172}    ${dict_A_ue_173}    ${dict_A_ue_174}
    # UEs settings 4 potentials AL4 and only 3 with traffic
    ${current_ues_settings}=          Create List    ${dict_A_ue_151}    ${dict_A_ue_152}    ${dict_A_ue_153}    ${dict_A_ue_155}
    ...                                              ${dict_A_ue_171}    ${dict_A_ue_172}    ${dict_A_ue_173}    ${dict_A_ue_175}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    0
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${True}
    ...                                                             is_capture_l1l2=${True}
    ...                                                             is_capture_tti=${True}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    #
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    ${current_bwpDN_initial}=         Set Variable    4
    ${current_bwpDN_dedicated}=       Set Variable    31
    Step                              SCF Configure Bandwidth FDD 10MHz    list_nrcell_to_configure=${list_position_nrcell_fdd}
    ...                                                             current_bwpDN_initial=${current_bwpDN_initial}
    ...                                                             current_bwpDN_dedicated=${current_bwpDN_dedicated}
    #
    # Configure AL2 dynamic without power boost
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             cellDepType=SA+NSA
    ...                                                             actPdcchSharingWithPdsch=false
    ...                                                             actCceSplit=false
    ...                                                             alSelection=dynamic
    ...                                                             dciDedicatedAggregationLevel=AL2
    ...                                                             dciPagingAggregationLevel=AL4
    ...                                                             dciRaCompletionAggregationLevel=AL2
    ...                                                             dciRaMsg2AggregationLevel=AL2
    ...                                                             dciSiAggregationLevel=AL4
    ...                                                             nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    # Update BWP_PROFILE_PDCCH dynamicAggregationLevelSet
    &{dico_dynamicAggregationLevelSet}=    Create Dictionary        aggregationLevelList=AL1_AL2_AL4_AL8
    ...                                                             cqiCorrectionUp=8
    ...                                                             cqiDciCssAl1=131
    ...                                                             cqiDciCssAl16=0
    ...                                                             cqiDciCssAl2=101
    ...                                                             cqiDciCssAl4=69
    ...                                                             cqiDciCssAl8=33
    ...                                                             highOlcCqiOffset=100
    ...                                                             lowOlcCqiOffset=1100
    ...                                                             pCqiErasureActTimer=160
    ...                                                             pCqiErasureReduction=10
    Step                              SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet    ${dico_dynamicAggregationLevelSet}
    ...                                                             ${list_position_nrcell_fdd}
    ...                                                             list_nrcell=${FDD_Cell_list}
    # Update BWP_PROFILE_PDCCH due to AL2 configuration
    # Configure initial BWP_PROFILE
    &{dico_pdcch}=                    Create Dictionary             alSelection=static
    ...                                                             dciDedicatedAggregationLevel=AL2
    ...                                                             dciPagingAggregationLevel=AL4
    ...                                                             dciRaCompletionAggregationLevel=AL2
    ...                                                             dciRaMsg2AggregationLevel=AL2
    ...                                                             dciSiAggregationLevel=AL4
    Step                              SCF Configure BWP_PROFILE_PDCCH    dn_bwp_pdcch=${dn_bwp_profile_base}${current_bwpDN_initial}/PDCCH-1
    ...                                                             dico_pdcch=${dico_pdcch}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             periodicity=sl1
    ...                                                             searchSpaceId=1
    &{dico_searchSpaceCommon_2}=      Create Dictionary             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL2=n2
    ...                                                             numOfPdcchCandidatesInAL4=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             periodicity=sl1
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_initial}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             periodicity=sl1
    ...                                                             searchSpaceId=4
    &{dico_searchSpaceCommon_2}=      Create Dictionary             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL2=n2
    ...                                                             numOfPdcchCandidatesInAL4=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             periodicity=sl1
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_dedicated}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Re-create BWP_PROFILE_PDCCH CONFIG_DEDICATED to update coresetDedicated.size, searchSpaceDedicated.numOfPdcchCandidatesInAL
    # UEs settings 3 potentials AL4 with traffic + 1 AL1 traffic
    #&{dico_coresetDedicated}=        Create Dictionary             coresetDedicated=null    # NO CORESETDEDICATED IN DEFAULT BW CONFIGURATION 10MHZ
    # UEs settings 4 potentials AL4 and only 3 with traffic
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=interleaved
    ...                                                             coresetId=1
    ...                                                             cRbStart=0
    ...                                                             duration=1
    ...                                                             interleaverSize=n3
    ...                                                             regBundleSize=n2
    ...                                                             size=42
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL2=n2
    ...                                                             numOfPdcchCandidatesInAL4=n0
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    # UEs settings 3 potentials AL4 with traffic + 1 AL1 traffic
    #&{dico_searchSpaceDedicated_2}=  Create Dictionary             coresetId=0
    # UEs settings 4 potentials AL4 and only 3 with traffic
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    # UEs settings 3 potentials AL4 with traffic + 1 AL1 traffic
    #...                                                            numOfPdcchCandidatesInAL1=n1
    ...                                                             numOfPdcchCandidatesInAL2=n4
    # UEs settings 3 potentials AL4 with traffic + 1 AL1 traffic
    #...                                                            numOfPdcchCandidatesInAL4=n1    #n2
    # UEs settings 4 potentials AL4 and only 3 with traffic
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    # UEs settings 4 potentials AL4 and only 3 with traffic
    #&{dico_searchSpaceDedicated_3}=  Create Dictionary             coresetId=0
    #...                                                            dciFormat=formats0-0-And-1-0
    #...                                                            duration=19
    #...                                                            monitoringSymbolWithinSlot=symbol_2
    #...                                                            numOfPdcchCandidatesInAL2=n2
    #...                                                            numOfPdcchCandidatesInAL4=n0
    #...                                                            numOfPdcchCandidatesInAL8=n0
    #...                                                            periodicity=sl20
    #...                                                            searchSpaceId=9
    #...                                                            searchSpaceType=Type3
    #...                                                            slotOffset=1
    #&{dico_searchSpaceDedicated_4}=  Create Dictionary             coresetId=0
    #...                                                            dciFormat=formats0-1-And-1-1
    #...                                                            duration=19
    #...                                                            monitoringSymbolWithinSlot=symbol_2
    #...                                                            numOfPdcchCandidatesInAL1=n1
    #...                                                            numOfPdcchCandidatesInAL2=n4
    #...                                                            numOfPdcchCandidatesInAL4=n1    #n2
    #...                                                            numOfPdcchCandidatesInAL8=n0
    #...                                                            periodicity=sl20
    #...                                                            searchSpaceId=10
    #...                                                            searchSpaceType=UE-Specific
    #...                                                            slotOffset=1
    @{list_searchSpaceDedicated}=     Create List                   ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    # UEs settings 4 potentials AL4 and only 3 with traffic
    #...                                                            ${dico_searchSpaceDedicated_3}    ${dico_searchSpaceDedicated_4}
    SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}    dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_NRDRB}=                    Create Dictionary             allowedPdcchPowerBoostALDueCce=AL2
    ...                                                             allowedPdcchPowerBoostALDueCfg=None
    Step                              SCF Configure NRDRB           ${dico_NRDRB}
    &{dico_NRPMRNL}=                  Create Dictionary             miNrCellUtilization=5min
    ...                                                             miNrPdcch=5min
    ...                                                             miNrPdcch2=5min
    Step                              SCF Configure NRPMRNL         ${dico_NRPMRNL}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${True}
    #
    Dated Log New Line                ----Call And Then Traffic For CB012738 With Cqi Customization Bis-------------
    Call And Then Traffic For CB012738 With Cqi Customization Bis    ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB012738-A_17_SA_FDD_AL4_DL
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_1}
    ${param.test_name}=               Set Variable    TC_CB012738_A_17_SA_FDD
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_fdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    ${current_ues_settings}=          Create List    ${dict_A_ue_51}    ${dict_A_ue_52}    ${dict_A_ue_53}    ${dict_A_ue_55}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    ${param.csi_override_cqi}=        Set Variable    3    # cqi=3 <=> dynamic AL8
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${True}
    ...                                                             is_capture_l1l2=${True}
    ...                                                             is_capture_tti=${True}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    #
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    ${current_bwpDN_initial}=         Set Variable    133
    ${current_bwpDN_dedicated}=       Set Variable    130
    Step                              SCF Configure Bandwidth FDD 20MHz    list_nrcell_to_configure=${list_position_nrcell_fdd}
    ...                                                             current_bwpDN_initial=${current_bwpDN_initial}
    ...                                                             current_bwpDN_dedicated=${current_bwpDN_dedicated}
    # Configure AL4 dynamic without power boost
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             cellDepType=SA+NSA
    ...                                                             actPdcchSharingWithPdsch=false
    ...                                                             actCceSplit=false
    ...                                                             alSelection=dynamic
    ...                                                             dciDedicatedAggregationLevel=AL4
    ...                                                             dciPagingAggregationLevel=AL4
    ...                                                             dciRaCompletionAggregationLevel=AL4
    ...                                                             dciRaMsg2AggregationLevel=AL4
    ...                                                             dciSiAggregationLevel=AL4
    #...                                                            downgradeAL16toAL8=notAllowed
    #...                                                            downgradeALProactive=false
    ...                                                             actPRBBlanking=true
    ...                                                             nbrOfBlankedPRBsLowEdgeDL=12
    ...                                                             type0CoresetConfigurationIndex=7
    ...                                                             ssbScs=15KHz
    ...                                                             nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    # Update BWP_PROFILE_PDCCH dynamicAggregationLevelSet
    &{dico_dynamicAggregationLevelSet}=    Create Dictionary        aggregationLevelList=AL1_AL2_AL4_AL8
    ...                                                             cqiCorrectionUp=8
    ...                                                             cqiDciCssAl1=131
    ...                                                             cqiDciCssAl16=0
    ...                                                             cqiDciCssAl2=101
    ...                                                             cqiDciCssAl4=69
    ...                                                             cqiDciCssAl8=33
    ...                                                             highOlcCqiOffset=100
    ...                                                             lowOlcCqiOffset=1100
    ...                                                             pCqiErasureActTimer=160
    ...                                                             pCqiErasureReduction=10
    Step                              SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet    ${dico_dynamicAggregationLevelSet}
    ...                                                             ${list_position_nrcell_fdd}
    ...                                                             list_nrcell=${FDD_Cell_list}
    # Update BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon.numOfPdcchCandidatesInAL <= maybe not needed in this case
    # Re-create BWP_PROFILE_PDCCH CONFIG_DEDICATED to update coresetDedicated.size, searchSpaceDedicated.numOfPdcchCandidatesInAL
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=interleaved
    ...                                                             coresetId=1
    ...                                                             cRbStart=12
    ...                                                             duration=1
    ...                                                             interleaverSize=n3
    ...                                                             regBundleSize=n2
    ...                                                             size=90
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n2
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n2
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_3}=   Create Dictionary             coresetId=0
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=9
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_4}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n1
    ...                                                             numOfPdcchCandidatesInAL4=n1
    ...                                                             numOfPdcchCandidatesInAL8=n1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=10
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_5}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=19
    ...                                                             monitoringSymbolWithinSlot=symbol_2
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n1
    ...                                                             numOfPdcchCandidatesInAL4=n1
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             periodicity=sl20
    ...                                                             searchSpaceId=11
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=1
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    ...                                              ${dico_searchSpaceDedicated_3}    ${dico_searchSpaceDedicated_4}
    ...                                              ${dico_searchSpaceDedicated_5}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_NRDRB}=                    Create Dictionary             allowedPdcchPowerBoostALDueCce=AL4
    ...                                                             allowedPdcchPowerBoostALDueCfg=None
    Step                              SCF Configure NRDRB           ${dico_NRDRB}
    &{dico_NRPMRNL}=                  Create Dictionary             miNrCellUtilization=5min
    ...                                                             miNrPdcch=5min
    ...                                                             miNrPdcch2=5min
    Step                              SCF Configure NRPMRNL         ${dico_NRPMRNL}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${True}
    #
    Dated Log New Line                ----Call And Then Traffic For CB012738---------------------------------------------
    Call And Then Traffic For CB012738    ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB012738-A_27_IWK_WITH_CB008370_PDSCH_shared_symbol_NSA_TDD
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_1}
    ${param.test_name}=               Set Variable    TC_CB012738_A_27_NSA_TDD
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_tdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    #@{list_ues_C1_T_NSA_C2_T_NSA}
    ${param.csi_override_cqi}=        Set Variable    3    # cqi=3 <=> dynamic AL8
    Set To Dictionary                 ${dict_A_ue_101}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_102}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_103}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_104}    csi_override_cqi    ${param.csi_override_cqi}
    ${current_ues_settings}=          Create List    ${dict_A_ue_101}    ${dict_A_ue_102}    ${dict_A_ue_103}    ${dict_A_ue_104}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    0
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${True}
    ...                                                             is_capture_l1l2=${True}
    ...                                                             is_capture_tti=${True}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    #
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    Step                              SCF Configure Bandwidth TDD 40MHz    list_nrcell_to_configure=${list_position_nrcell_tdd}
    ${current_bwpDN_dedicated}=       Set Variable    51
    #
    # Configure AL4 dynamic without power boost
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             cellDepType=SA+NSA
    ...                                                             actPdcchSharingWithPdsch=true
    ...                                                             actCceSplit=false
    ...                                                             alSelection=dynamic
    ...                                                             dciDedicatedAggregationLevel=AL4
    ...                                                             dciPagingAggregationLevel=AL4
    ...                                                             dciRaCompletionAggregationLevel=AL4
    ...                                                             dciRaMsg2AggregationLevel=AL4
    ...                                                             dciSiAggregationLevel=AL4
    #...                                                            downgradeAL16toAL8=notAllowed
    #...                                                            downgradeALProactive=false
    ...                                                             nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Update BWP_PROFILE_PDCCH dynamicAggregationLevelSet
    &{dico_dynamicAggregationLevelSet}=    Create Dictionary        aggregationLevelList=AL1_AL2_AL4_AL8
    ...                                                             cqiCorrectionUp=8
    ...                                                             cqiDciCssAl1=131
    ...                                                             cqiDciCssAl16=0
    ...                                                             cqiDciCssAl2=101
    ...                                                             cqiDciCssAl4=69
    ...                                                             cqiDciCssAl8=33
    ...                                                             highOlcCqiOffset=100
    ...                                                             lowOlcCqiOffset=1100
    ...                                                             pCqiErasureActTimer=160
    ...                                                             pCqiErasureReduction=10
    Step                              SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet    ${dico_dynamicAggregationLevelSet}
    ...                                                             ${list_position_nrcell_tdd}
    ...                                                             list_nrcell=${TDD_Cell_list}
    # Update BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon.numOfPdcchCandidatesInAL <= maybe not needed in this case
    # Re-create BWP_PROFILE_PDCCH CONFIG_DEDICATED to update coresetDedicated.size, searchSpaceDedicated.numOfPdcchCandidatesInAL
    &{dico_coresetDedicated}=         Create Dictionary             size=96
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             searchSpaceId=7
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             numOfPdcchCandidatesInAL2=n0    #n2
    ...                                                             numOfPdcchCandidatesInAL4=n4
    ...                                                             numOfPdcchCandidatesInAL8=n0    #n2
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_NRDRB}=                    Create Dictionary             allowedPdcchPowerBoostALDueCce=none
    ...                                                             allowedPdcchPowerBoostALDueCfg=AL4
    Step                              SCF Configure NRDRB           ${dico_NRDRB}
    &{dico_NRPMRNL}=                  Create Dictionary             miNrCellUtilization=5min
    ...                                                             miNrPdcch=5min
    ...                                                             miNrPdcch2=5min
    Step                              SCF Configure NRPMRNL         ${dico_NRPMRNL}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${True}
    #
    Dated Log New Line                ----Call And Then Traffic For CB012738 With Cqi Customization Bis-------------
    Call And Then Traffic For CB012738 With Cqi Customization Bis    ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB012738-A_30_IWK_WITH_CCE_SPLIT_NSA_FDD
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_1}
    ${param.test_name}=               Set Variable    TC_CB012738_A_30_NSA_FDD
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_fdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    #@{list_ues_C3_F_SA}
    ${param.csi_override_cqi}=        Set Variable    3    # cqi=3 <=> dynamic AL8
    Set To Dictionary                 ${dict_A_ue_151}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_152}    csi_override_cqi    ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_152}    throughput          0
    Set To Dictionary                 ${dict_A_ue_152}    throughput_ul       5
    Set To Dictionary                 ${dict_A_ue_153}    csi_override_cqi    14    # AL1
    Set To Dictionary                 ${dict_A_ue_154}    csi_override_cqi    14    # AL1
    Set To Dictionary                 ${dict_A_ue_154}    throughput          0
    Set To Dictionary                 ${dict_A_ue_154}    throughput_ul       5
    ${current_ues_settings}=          Create List    ${dict_A_ue_151}    ${dict_A_ue_152}    ${dict_A_ue_153}    ${dict_A_ue_154}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${True}
    ...                                                             is_capture_l1l2=${True}
    ...                                                             is_capture_tti=${True}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    #
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    Step                              SCF Configure Bandwidth FDD 20MHz    list_nrcell_to_configure=${list_position_nrcell_fdd}
    ${current_bwpDN_dedicated}=       Set Variable    33
    #
    # Configure AL4 dynamic without power boost
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             cellDepType=SA+NSA
    ...                                                             actPdcchSharingWithPdsch=false
    ...                                                             actCceSplit=true
    ...                                                             alSelection=dynamic
    ...                                                             dciDedicatedAggregationLevel=AL4
    ...                                                             dciPagingAggregationLevel=AL4
    ...                                                             dciRaCompletionAggregationLevel=AL4
    ...                                                             dciRaMsg2AggregationLevel=AL4
    ...                                                             dciSiAggregationLevel=AL4
    #...                                                            downgradeAL16toAL8=notAllowed
    #...                                                            downgradeALProactive=false
    ...                                                             nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    # Update BWP_PROFILE_PDCCH dynamicAggregationLevelSet
    &{dico_dynamicAggregationLevelSet}=    Create Dictionary        aggregationLevelList=AL1_AL2_AL4_AL8
    ...                                                             cqiCorrectionUp=8
    ...                                                             cqiDciCssAl1=131
    ...                                                             cqiDciCssAl16=0
    ...                                                             cqiDciCssAl2=101
    ...                                                             cqiDciCssAl4=69
    ...                                                             cqiDciCssAl8=33
    ...                                                             highOlcCqiOffset=100
    ...                                                             lowOlcCqiOffset=1100
    ...                                                             pCqiErasureActTimer=160
    ...                                                             pCqiErasureReduction=10
    Step                              SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet    ${dico_dynamicAggregationLevelSet}
    ...                                                             ${list_position_nrcell_fdd}
    ...                                                             list_nrcell=${FDD_Cell_list}
    # Update BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon.numOfPdcchCandidatesInAL <= maybe not needed in this case
    # Re-create BWP_PROFILE_PDCCH CONFIG_DEDICATED to update coresetDedicated.size, searchSpaceDedicated.numOfPdcchCandidatesInAL
    &{dico_coresetDedicated}=         Create Dictionary             size=102
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             searchSpaceId=7
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             numOfPdcchCandidatesInAL1=n2
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n4
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_NRDRB}=                    Create Dictionary             allowedPdcchPowerBoostALDueCce=none
    ...                                                             allowedPdcchPowerBoostALDueCfg=AL4
    Step                              SCF Configure NRDRB           ${dico_NRDRB}
    &{dico_NRPMRNL}=                  Create Dictionary             miNrCellUtilization=5min
    ...                                                             miNrPdcch=5min
    ...                                                             miNrPdcch2=5min
    Step                              SCF Configure NRPMRNL         ${dico_NRPMRNL}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${True}
    #
    Dated Log New Line                ----Call And Then Traffic For CB012738 With Cqi Customization Bis-------------
    Call And Then Traffic For CB012738 With Cqi Customization Bis    ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB012738-A_31_IWK_WITH_BLANK_PRB_NSA_FDD
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_1}
    ${param.test_name}=               Set Variable    TC_CB012738_A_31_NSA_FDD
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_fdd}=      Create List    1    # 1= first nrcell, 2nd, 3rd, etc.
    ${current_ues_settings}=          Create List    ${dict_A_ue_151}    ${dict_A_ue_152}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    ${param.csi_override_cqi}=        Set Variable    3    # cqi=3 <=> dynamic AL8
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${True}
    ...                                                             is_capture_l1l2=${True}
    ...                                                             is_capture_tti=${True}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    #
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    ${current_bwpDN_initial}=         Set Variable    133
    ${current_bwpDN_dedicated}=       Set Variable    130
    Step                              SCF Configure Bandwidth FDD 20MHz    list_nrcell_to_configure=${list_position_nrcell_fdd}
    ...                                                             current_bwpDN_initial=${current_bwpDN_initial}
    ...                                                             current_bwpDN_dedicated=${current_bwpDN_dedicated}
    # Configure AL4 dynamic without power boost
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             cellDepType=SA+NSA
    ...                                                             actPdcchSharingWithPdsch=false
    ...                                                             actCceSplit=false
    ...                                                             alSelection=dynamic
    ...                                                             dciDedicatedAggregationLevel=AL4
    ...                                                             dciPagingAggregationLevel=AL4
    ...                                                             dciRaCompletionAggregationLevel=AL4
    ...                                                             dciRaMsg2AggregationLevel=AL4
    ...                                                             dciSiAggregationLevel=AL4
    #...                                                            downgradeAL16toAL8=notAllowed
    #...                                                            downgradeALProactive=false
    ...                                                             actPRBBlanking=true
    ...                                                             nbrOfBlankedPRBsHighEdgeDL=10
    ...                                                             nbrOfBlankedPRBsLowEdgeDL=10
    ...                                                             type0CoresetConfigurationIndex=7
    ...                                                             ssbScs=15KHz
    ...                                                             reqMinNumPuschPrb=92
    ...                                                             maxNumOfCaUsersNRCell=250
    ...                                                             nrcell_fdd=${list_position_nrcell_fdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_fdd    list_nrcell=${FDD_Cell_list}
    # Update BWP_PROFILE_PDCCH dynamicAggregationLevelSet
    &{dico_dynamicAggregationLevelSet}=    Create Dictionary        aggregationLevelList=AL1_AL2_AL4_AL8
    ...                                                             cqiCorrectionUp=8
    ...                                                             cqiDciCssAl1=131
    ...                                                             cqiDciCssAl16=0
    ...                                                             cqiDciCssAl2=101
    ...                                                             cqiDciCssAl4=69
    ...                                                             cqiDciCssAl8=33
    ...                                                             highOlcCqiOffset=100
    ...                                                             lowOlcCqiOffset=1100
    ...                                                             pCqiErasureActTimer=160
    ...                                                             pCqiErasureReduction=10
    Step                              SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet    ${dico_dynamicAggregationLevelSet}
    ...                                                             ${list_position_nrcell_fdd}
    ...                                                             list_nrcell=${FDD_Cell_list}
    # Configure initial BWP_PROFILE
    ###&{dico_bwp_profile}=              Create Dictionary             bwpType=initial
    ###...                                                             cRbSizeDl=coreset0
    ###...                                                             cRbStartDl=coreset0
    ###...                                                             cRbSizeUl=n96
    ###...                                                             cRbStartUl=crb10
    ###SCF Create BWP_PROFILE            profil_id=${current_bwpDN_initial}    dico_pdcch=${dico_bwp_profile}
    # Update BWP_PROFILE_PDCCH CONFIG_COMMON searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=1
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_initial}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Update BWP_PROFILE_PDCCH CONFIG_DEDICATED searchSpaceCommon
    &{dico_searchSpaceCommon_1}=      Create Dictionary             coresetId=0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=4
    &{dico_searchSpaceCommon_2}=      Create Dictionary             coresetId=0
    ...                                                             monitoringSymbolWithinSlot=symbol_0_1
    ...                                                             numOfPdcchCandidatesInAL2=n0
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             coresetId=0
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_dedicated}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Re-create BWP_PROFILE_PDCCH CONFIG_DEDICATED to update coresetDedicated.size, searchSpaceDedicated.numOfPdcchCandidatesInAL
    &{dico_coresetDedicated}=         Create Dictionary             cceToRegMapping=interleaved
    ...                                                             coresetId=1
    ...                                                             cRbStart=12
    ...                                                             duration=1
    ...                                                             interleaverSize=n3
    ...                                                             regBundleSize=n2
    ...                                                             size=84
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0    #n0
    ...                                                             numOfPdcchCandidatesInAL4=n2    #n2
    ...                                                             numOfPdcchCandidatesInAL8=n0    #n1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=7
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_0
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0    #n2
    ...                                                             numOfPdcchCandidatesInAL4=n4    #n2
    ...                                                             numOfPdcchCandidatesInAL8=n0    #n2
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_3}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-0-And-1-0
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0    #n0
    ...                                                             numOfPdcchCandidatesInAL4=n2    #n2
    ...                                                             numOfPdcchCandidatesInAL8=n1    #n1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=9
    ...                                                             searchSpaceType=Type3
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_4}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=1
    ...                                                             monitoringSymbolWithinSlot=symbol_1
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0    #n1
    ...                                                             numOfPdcchCandidatesInAL4=n2    #n1
    ...                                                             numOfPdcchCandidatesInAL8=n0    #n1
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=10
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=0
    &{dico_searchSpaceDedicated_5}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             duration=19
    ...                                                             monitoringSymbolWithinSlot=symbol_2
    ...                                                             numOfPdcchCandidatesInAL1=n0
    ...                                                             numOfPdcchCandidatesInAL16=n0
    ...                                                             numOfPdcchCandidatesInAL2=n0    #n1
    ...                                                             numOfPdcchCandidatesInAL4=n1    #n1
    ...                                                             numOfPdcchCandidatesInAL8=n0    #n0
    ...                                                             periodicity=sl20
    ...                                                             searchSpaceId=11
    ...                                                             searchSpaceType=UE-Specific
    ...                                                             slotOffset=1
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    ...                                              ${dico_searchSpaceDedicated_3}    ${dico_searchSpaceDedicated_4}
    ...                                              ${dico_searchSpaceDedicated_5}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_NRDRB}=                    Create Dictionary             allowedPdcchPowerBoostALDueCce=none
    ...                                                             allowedPdcchPowerBoostALDueCfg=AL4
    Step                              SCF Configure NRDRB           ${dico_NRDRB}
    &{dico_NRPMRNL}=                  Create Dictionary             miNrCellUtilization=5min
    ...                                                             miNrPdcch=5min
    ...                                                             miNrPdcch2=5min
    Step                              SCF Configure NRPMRNL         ${dico_NRPMRNL}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${True}
    #
    Dated Log New Line                ----Call And Then Traffic For CB012738---------------------------------------------
    Call And Then Traffic For CB012738    ${param}    ${current_ues_settings}    ${is_capture}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
[1] CB012738-A_41_IWK_HANDOVER_SA_TDD_AL2_DL
    #USELESS#[Tags]    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    SBTS00

    Dated Log New Line                ----Test Initialization-------------------------------------------------------
    GenericTest.Init Sequence         param=${TEST_SETTINGS_1}
    ${param.test_name}=               Set Variable    TC_CB012738_A_41_SA_TDD_AL2
    Step                              ${param.set_suite_dist_name_variables}
    @{list_position_nrcell_tdd}=      Create List    1    2    # 1= first nrcell, 2nd, 3rd, etc.
    #@{list_ues_C1_T_SA_C2_T_SA}
    ${param.csi_override_cqi}=        Set Variable    6    # cqi=6 <=> dynamic AL4
    ${param.ue_measurement_nr}=       Set Variable    ${True}
    Set To Dictionary                 ${dict_A_ue_1}    csi_override_cqi     ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_1}    ue_measurement_nr    ${False}
    Set To Dictionary                 ${dict_A_ue_2}    csi_override_cqi     ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_2}    ue_measurement_nr    ${False}
    Set To Dictionary                 ${dict_A_ue_3}    csi_override_cqi     ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_3}    target_handover      2    # target cell id (not position of the cell into the list)
    Set To Dictionary                 ${dict_A_ue_3}    ue_measurement_nr    ${True}
    Set To Dictionary                 ${dict_A_ue_21}   csi_override_cqi     ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_21}   ue_measurement_nr    ${False}
    Set To Dictionary                 ${dict_A_ue_21}   throughput           5
    Set To Dictionary                 ${dict_A_ue_21}   throughput_ul        0
    Set To Dictionary                 ${dict_A_ue_22}   csi_override_cqi     ${param.csi_override_cqi}
    Set To Dictionary                 ${dict_A_ue_22}   ue_measurement_nr    ${False}
    Set To Dictionary                 ${dict_A_ue_22}   throughput           5
    Set To Dictionary                 ${dict_A_ue_22}   throughput_ul        0
    ${current_ues_settings}=          Create List    ${dict_A_ue_1}    ${dict_A_ue_2}    ${dict_A_ue_3}    ${dict_A_ue_21}    ${dict_A_ue_22}
    ${param.total_nb_ue}=             Get Length    ${current_ues_settings}
    ${param.nb_sa_ue}=                Set Variable    ${param.total_nb_ue}
    Dated Log New Line                > Test name is ${param.test_name}
    #
    Dated Log New Line                ----Test Configuration--------------------------------------------------------
    &{is_capture}=                    Create Dictionary             is_capture_core=${False}
    ...                                                             is_capture_cprt=${True}
    ...                                                             is_capture_l1l2=${True}
    ...                                                             is_capture_tti=${True}
    ...                                                             is_capture_syslog=${False}
    ...                                                             is_capture_snapshot=${True}
    Dated Log New Line                ----Test Commissioning--------------------------------------------------------
    ${scf_file}=                      Start Session Full Commissioning For Pdcch Power Boost    test_name=${param.test_name}
    # Configure intra frequency handover SA
    &{dico_intra_frequency_handover_SA}=    Create Dictionary       actIntraFreqHoSA=true
    ...                                                             timerXnDataFwdGuard=250
    ...                                                             a3MeasEnabled=rsrp
    ...                                                             miNrRelReportCu=5min
    ...                                                             absThreshSsbRsrpConsolidation=10
    ...                                                             sMeasConfigSsbRsrp=10
    ...                                                             a3HysteresisSsbRsrp=2
    ...                                                             a3OffsetSsbRsrp=4
    ...                                                             a3TimeToTriggerSsbRsrp=ms40
    ...                                                             nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure Intra Frequency Handover SA    ${dico_intra_frequency_handover_SA}
    ...                                                             nrcell_key=nrcell_tdd
    ...                                                             list_nrcell=${TDD_Cell_list}
    # Configure bandwidth
    Step                              SCF Configure Bandwidth TDD 40MHz    list_nrcell_to_configure=${list_position_nrcell_tdd}
    ${current_bwpDN_initial}=         Set Variable    5
    ${current_bwpDN_dedicated}=       Set Variable    51
    #
    # Configure AL2 dynamic without power boost
    &{dico_nrcell}=                   Create Dictionary             actPdcchPowerBoost=enabled
    ...                                                             cellDepType=SA+NSA
    ...                                                             actPdcchSharingWithPdsch=false
    ...                                                             actCceSplit=false
    ...                                                             alSelection=dynamic
    ...                                                             dciDedicatedAggregationLevel=AL2
    ...                                                             dciPagingAggregationLevel=AL4    # AL4 or AL8 is supported
    ...                                                             dciRaCompletionAggregationLevel=AL2
    ...                                                             dciRaMsg2AggregationLevel=AL2
    ...                                                             dciSiAggregationLevel=AL4    # AL4 or AL8 is supported
    ...                                                             nrcell_tdd=${list_position_nrcell_tdd}
    Step                              SCF Configure NRCELL          ${dico_nrcell}    nrcell_key=nrcell_tdd    list_nrcell=${TDD_Cell_list}
    # Update BWP_PROFILE_PDCCH dynamicAggregationLevelSet
    &{dico_dynamicAggregationLevelSet}=    Create Dictionary        aggregationLevelList=AL1_AL2_AL4_AL8
    ...                                                             cqiCorrectionUp=8
    ...                                                             cqiDciCssAl1=131
    ...                                                             cqiDciCssAl16=0
    ...                                                             cqiDciCssAl2=101
    ...                                                             cqiDciCssAl4=69
    ...                                                             cqiDciCssAl8=33
    ...                                                             highOlcCqiOffset=100
    ...                                                             lowOlcCqiOffset=1100
    ...                                                             pCqiErasureActTimer=160
    ...                                                             pCqiErasureReduction=10
    Step                              SCF Configure BWP_PROFILE_PDCCH dynamicAggregationLevelSet    ${dico_dynamicAggregationLevelSet}
    ...                                                             ${list_position_nrcell_tdd}
    ...                                                             list_nrcell=${TDD_Cell_list}
    # Update BWP_PROFILE_PDCCH due to AL2 configuration
    &{dico_pdcch}=                    Create Dictionary             alSelection=static
    ...                                                             dciDedicatedAggregationLevel=AL2
    ...                                                             dciPagingAggregationLevel=AL4
    ...                                                             dciRaCompletionAggregationLevel=AL2
    ...                                                             dciRaMsg2AggregationLevel=AL2
    ...                                                             dciSiAggregationLevel=AL4
    #...                                                            downgradeAL16toAL8=notAllowed
    #...                                                            downgradeALProactive=false
    Step                              SCF Configure BWP_PROFILE_PDCCH    dn_bwp_pdcch=${dn_bwp_profile_base}${current_bwpDN_initial}/PDCCH-1
    ...                                                             dico_pdcch=${dico_pdcch}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             duration=3
    ...                                                             searchSpaceId=1
    &{dico_searchSpaceCommon_2}=      Create Dictionary             numOfPdcchCandidatesInAL2=n1
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=2
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             duration=3
    ...                                                             searchSpaceId=3
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_initial}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    &{dico_searchSpaceCommon_1}=      Create Dictionary             duration=3
    ...                                                             searchSpaceId=4
    &{dico_searchSpaceCommon_2}=      Create Dictionary             numOfPdcchCandidatesInAL2=n1
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             periodicity=sl1
    ...                                                             searchSpaceId=5
    ...                                                             searchSpaceType=Type1
    &{dico_searchSpaceCommon_3}=      Create Dictionary             duration=3
    ...                                                             searchSpaceId=6
    ...                                                             searchSpaceType=Type2
    @{list_searchSpaceCommon}=        Create List    ${dico_searchSpaceCommon_1}    ${dico_searchSpaceCommon_2}    ${dico_searchSpaceCommon_3}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_COMMON    profil_id=${current_bwpDN_dedicated}
    ...                                                             list_searchSpace=${list_searchSpaceCommon}
    # Re-create BWP_PROFILE_PDCCH CONFIG_DEDICATED to update coresetDedicated.size, searchSpaceDedicated.numOfPdcchCandidatesInAL
    &{dico_coresetDedicated}=         Create Dictionary             size=66    # size limited to support only 11 CCEs instead of 16
    &{dico_searchSpaceDedicated_1}=   Create Dictionary             coresetId=0
    ...                                                             numOfPdcchCandidatesInAL2=n1
    ...                                                             numOfPdcchCandidatesInAL4=n2
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             searchSpaceId=7
    &{dico_searchSpaceDedicated_2}=   Create Dictionary             coresetId=1
    ...                                                             dciFormat=formats0-1-And-1-1
    ...                                                             numOfPdcchCandidatesInAL2=n2
    ...                                                             numOfPdcchCandidatesInAL4=n4
    ...                                                             numOfPdcchCandidatesInAL8=n0
    ...                                                             searchSpaceId=8
    ...                                                             searchSpaceType=UE-Specific
    @{list_searchSpaceDedicated}=     Create List    ${dico_searchSpaceDedicated_1}    ${dico_searchSpaceDedicated_2}
    Step                              SCF Create BWP_PROFILE_PDCCH_CONFIG_DEDICATED    profil_id=${current_bwpDN_dedicated}
    ...                                                             dico_coreset=${dico_coresetDedicated}
    ...                                                             list_searchSpace=${list_searchSpaceDedicated}
    &{dico_NRDRB}=                    Create Dictionary             allowedPdcchPowerBoostALDueCce=AL2
    ...                                                             allowedPdcchPowerBoostALDueCfg=None
    Step                              SCF Configure NRDRB           ${dico_NRDRB}
    &{dico_NRPMRNL}=                  Create Dictionary             miNrCellUtilization=5min
    ...                                                             miNrPdcch=5min
    ...                                                             miNrPdcch2=5min
    Step                              SCF Configure NRPMRNL         ${dico_NRPMRNL}
    ${result}    ${pdlValidation}     Stop Session Full Commissioning For Pdcch Power Boost    updated_scf=${scf_file}    skip_errors=${False}
    Should Be True                    ${result} == ${True}
    #
    Dated Log New Line                ----Call And Then Traffic For CB012738 With Handover--------------------------
    Call And Then Traffic For CB012738 With Handover    ${param}    ${current_ues_settings}    ${is_capture}    ${list_position_nrcell_tdd}
    #
    #[Teardown]    # Reserved to internal testing usage
# --------------------------------------------------------------------------------------------------------------------------------------------------
