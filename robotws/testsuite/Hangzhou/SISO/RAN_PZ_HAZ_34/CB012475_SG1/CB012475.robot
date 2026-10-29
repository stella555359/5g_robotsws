*** Settings ***
Documentation      author: Taotao Shi
...                 contact: taotao.shi@nokia-sbell.com


Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    KW.TestSuilt.Start_12475
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND    KW.TestSuilt.Stop_12475
Force Tags               SG_01   5G_RAN  CLOUD_5G_CLASSICAL_SA_ASIML_ABINB1_ABIQB2B3_AWHNA_3xAWHQ_AWPTD

Library             taf.selenium.sbts     WITH NAME   selenium_coam
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource           ./Resource/CB012475_Resource.robot

*** Test Cases ***
[1]CB012475_SR_A_13_SiSo_Site_Reset_KPI_with_Supercell_active
    [Documentation]
    [Tags]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup
    ...    AND    TestCase.Start_12475    scf_file=${CFGFILE_PATH}1Supercell_6subcells.xml
    [Teardown]  Run Keywords    TeardownCase_12475    AND    robot_common_operations.Common Case Teardown
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    abbr=Activate NR CBRS	    value=true
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
    sleep   3min
    Reset Site    loop_times=${CASE_INPUT_CB012475['site_reset_times']}
    ...           duration_target=${CASE_INPUT_CB012475['site_reset_duration']}


[1]CB012475_SR_B_19_06_SiSo_Supercell_setup_with_one_radiol_not_detected_1Supercell_3subcells_MixedConfig
    [Documentation]    PR763331
    ...                Step1: commission with 1supercell_3subcells and noramllcell mixed, CBRS flag is deactive
    ...                Step2: power off CBSD which constitue supercell
    ...                Step3: active CBRS flag, check fault 10, NRCBSDCELL grant info
    ...                Step4: power on CBSD, check fault, NRCBSDCELL grant info, supercell and normalcell state
    ...                Step5: power off CBSD which constitue supercell
    ...                Step6: check fault 10, NRCBSDCELL grant info, supercell and normalcell state
    ...                Step7: power on CBSD, check fault, NRCBSDCELL grant info, supercell and normalcell state
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup
    ...    AND    TestCase.Start_12475  scf_file=${CFGFILE_PATH}Supercell_Normalcell_Mix.xml
    ...    sasconf=${CFGFILE_PATH}SAS_Sim.conf
    [Teardown]  TeardownCase_12475
    TC.CB012475_SR_B_19_06_SiSo_Supercell_setup_with_one_radiol_not_detected_1Supercell_3subcells_MixedConfig
    ...    ru_Index=${CASE_INPUT_CB012475['CB012475_SR_B_19_06']['ru_index']}






[1]CB012475_SR_B_20_03_SiSo_one_subcell_degraded_after_Supercell_setup_1Supercell_3subcells_MixedConfig
   [Documentation]   Precondition: 1.set spectrum table:3550-3590 GAA, 3600-3640 PAL in SAS Simulator
   ...               2.3600-3610 maxEirp=10 for first request in SAS Simulator
   ...               3.add flag LockCellTimer 0x7a000d=180 in swconfig.txt
#   ...               4.set supercell1 cbrsFreqPriority=top priority, supercell2 cbrsFreqPriority=2nd priority
   ...               Step1: commission with 1supercells_2subcells and noramllcell mixed, CBRS flag is deactive
   ...               Step2: active CBRS flag, check NRCBSDCELL grant info, supercell and normalcell state
   ...               Step3: wait SAS server response HB code 500, check fault and supercell state
   ...               Step4: wait querySasServerPeriod expired, check fault and supercell state
   ...               Step5: Block supercell CBSD and normalcell CBSD, wait LockCellTimer expired
   ...               Step6: check NRCBSDCELL grant info, supercell and normalcell state
   ...               Step7: unBlock supercell CBSD and normalcell CBSD
   [Setup]    Run Keywords    robot_common_operations.Common Case Setup
   ...    AND    TestCase.Start_12475  scf_file=${CFGFILE_PATH}Supercell_Normalcell_Mix.xml
   ...                                 sasconf=${CFGFILE_PATH}SAS_Sim_500.conf
   [Teardown]  TeardownCase_12475
   TC.CB012475_SR_B_20_03_SiSo_one_subcell_degraded_after_Supercell_setup_1Supercell_3subcells_MixedConfig

#[1]CB012475_SR_B_19_01_SiSo_Supercell_setup_with_one_subcell_degraded_1Supercell_6subcells
#  [Documentation]    PR764846

Test_Case
#    COAM_WebEM.Login
#    ${CellNum}    selenium_coam.get_number_of_cells
#
#    #${cell_subGrantInfo}=    selenium_coam.get_parameter_details    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-1/NRCBSDCELL-0
#    #...     filter_param=Subset of Grant Information
#
#    #${cell_subGrantInfo}=     selenium_coam.get_parameter_value_by_global_search
#    #...      filter_param=Subset of Grant Information
#
#    ${full_scf}=    selenium_coam.save_bts_configuration    save_configuration_type=1
#    FOR  ${cell_id}  IN  @{CellNum}
#         KW.Check_subCell_grantOperationStateSub
#         ...    file_path=${full_scf}
#         ...    dist_name=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${cell_id}/NRCBSDCELL-0
#         ...    p_name=grantOperationStateSub
#         ...    list_name=subGrantInfo
#    END
#    COAM_WebEM.Logout
     KW.RestartSAS_UTE

