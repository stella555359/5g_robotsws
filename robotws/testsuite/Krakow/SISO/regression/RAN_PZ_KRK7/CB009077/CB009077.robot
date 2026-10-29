*** Settings ***
Documentation
...    Test suite for regression testing for feature CB009077
...    author: Wioleta Swies, Jakub Bialon
...    contact: wioleta.swies@nokia.com
...    contact: jakub.bialon@nokia.com
...    group: MN_RAN_RD_VRF_KRK_7

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library    ./resources/keywords.py
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    taf.rfrl.bts.devices.du.cell_operations.EnbCellOperations    WITH NAME    enbcell

Suite Setup    Common Suite Setup With OnAir Test Line Preparation    should_LTE_neighbour_be_changed=${False}
...                                                                   should_5G_neighbour_be_changed=${False}
...                                                                   increase_time_for_checking_bbmod=600
...                                                                   increase_timeout_for_update_sw=1800
...                                                                   increase_time_for_checking_radios=2100
...                                                                   increase_time_for_checking_cells=700
...                                                                   increase_time_for_checking_X2link=1800
...                                                                   swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    Common Suite Teardown
Test Setup    Custom Test Setup
Test Teardown    Common Postconditions With Watching Alarms


*** Test Cases ***
[1][1.0] CB009077_D_01_Storing location into SM_BB Black Box_after BTS_reset
    [Tags]    T1
    Change ActLocInfoStore Status    status=true
    Change AccLevSet Status    value=Low
    ${start_date}    Get Current Date
    Reset gNB
    gnbcell.Wait For All Cells To Be Onair    timeout=180
    ${end_date}    Get Current Date
    Verify Blackbox File On Smod    dedicated_folder=/ffs/run/config/lifedata
    ...                             file_size=not_empty
    ...                             start_time=${start_date}
    ...                             end_time=${end_date}
    Verify Blackbox File On BBMOD    bbmod_ip=fsp1
    ...                              dedicated_folder=/run/blackbox/
    ...                              file_size=not_empty
    ...                              start_time=${start_date}
    ...                              end_time=${end_date}

[1][1.0] CB009077_D_05_Clear_location_info_in_SM_BB_Black_Box_after_change_FR_flag_to_disable
    [Tags]    T2
    Change ActLocInfoStore Status    status=false
    ${start_date}    Get Current Date
    Reset gNB
    gnbcell.Wait For All Cells To Be Onair    timeout=180
    ${end_date}    Get Current Date
    Verify Blackbox File On Smod    dedicated_folder=/ffs/run/config/lifedata
    ...                             file_size=empty
    ...                             start_time=${start_date}
    ...                             end_time=${end_date}
    Verify Blackbox File On BBMOD    bbmod_ip=fsp1
    ...                              dedicated_folder=/run/blackbox/
    ...                              file_size=empty
    ...                              start_time=${start_date}
    ...                              end_time=${end_date}

[1][1.0] CB009077_E_03_Storing_location_into_AWPQZ_NVM_after_gNB_reset
    [Tags]    T3
    Change ActLocInfoStore Status    status=true
    Change AccLevSet Status    value=Low
    ${start_date}    Get Current Date
    Reset gNB
    gnbcell.Wait For All Cells To Be Onair    timeout=300
    ${end_date}    Get Current Date
    Verify Permanent File On Ru    file_path=/mnt/runtime/rfsw/uoam/permanent.xml
    ...                            container_name=0x2018
    ...                            ru_username=rfsw
    ...                            ru_password=KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
    ...                            ru_name=awpqz
    ...                            start_time=${start_date}
    ...                            end_time=${end_date}

[1][1.0] CB009077_E_04_Storing_location_into_APHG_NVM_after_modulePositionInformation_update
    [Tags]    T4
    ${start_date}    Get Current Date
    Update ModulePositioninformation Object    dist_name=MRBTS-81055/EQM-1/APEQM-1/ASIRMOD-1
    ...                                        actLocInfoStore=true
    ...                                        accLevSet=Low
    ...                                        altitude=270
    ...                                        latitude=499999999
    ...                                        longitude=200000000
    ${end_date}    Get Current Date
    gnbcell.Wait For All Cells To Be Onair    timeout=180
    Verify Permanent File On Ru    file_path=/ffs/run/rfsw/uoam/permanent.xml
    ...                            container_name=0x2018
    ...                            ru_username=toor4nsn
    ...                            ru_password=oZPS0POrRieRtu
    ...                            ru_name=aphg
    ...                            start_time=${start_date}
    ...                            end_time=${end_date}

[1][1.0] CB009077_E_08_Storing_location_into_APHA_NVM_after_accuracy_level_update
    [Tags]    T5
    [Setup]    Run Keywords    Set Test Variable
    ...        @{CUSTOM_ALLOWED_ALARMS}
    ...        Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ...        AND    Common Preconditions With Watching Alarms
    ${SCF_main_enb}    Get Scf Path From Robotws    file_name=ENB0_SCF.xml
    keywords.Perform Bts Commissioning    scf_file=${SCF_main_enb}
    ...                          bts_type=enb
    enbcell.Wait For All Cells To Be Onair    timeout=180
    gnbcell.Wait For All Cells To Be Onair    timeout=180
    ${start_date}    Get Current Date
    Change AccLevSet Status    value=High    bts_type=enb
    ${end_date}    Get Current Date
    gnbcell.Wait For All Cells To Be Onair    timeout=180
    Verify Permanent File On Ru    file_path=/ffs/run/rfsw/uoam/permanent.xml
    ...                            container_name=0x1018
    ...                            ru_username=toor4nsn
    ...                            ru_password=oZPS0POrRieRtu
    ...                            ru_name=apha
    ...                            bts_type=enb
    ...                            start_time=${start_date}
    ...                            end_time=${end_date}

[1][1.0] CB009077_E_12_Clear_location_info_in_eNB_NVM_after_change_FR_flag_to_disable
    [Tags]    T6
    ${start_date}    Get Current Date
    Change ActLocInfoStore Status    status=false    bts_type=enb
    ${end_date}    Get Current Date
    gnbcell.Wait For All Cells To Be Onair    timeout=180
    Verify Permanent File On Ru    file_path=/ffs/run/rfsw/uoam/permanent.xml
    ...                            container_name=0x1018
    ...                            ru_username=toor4nsn
    ...                            ru_password=oZPS0POrRieRtu
    ...                            ru_name=apha
    ...                            bts_type=enb
    ...                            start_time=${start_date}
    ...                            end_time=${end_date}
    ...                            file_con_expec=clean
    Verify Permanent File On Ru    file_path=/ffs/run/rfsw/uoam/permanent.xml
    ...                            container_name=0x1018
    ...                            ru_username=toor4nsn
    ...                            ru_password=oZPS0POrRieRtu
    ...                            ru_name=aphg
    ...                            bts_type=enb
    ...                            start_time=${start_date}
    ...                            end_time=${end_date}

[1][1.0] CB009077_E_13_Clear_location_info_in_gNB_NVM_after_change_FR_flag_to_disable
    [Tags]    T7
    ${SCF_main_gnb}    Get Scf Path From Robotws    file_name=GNB0_SCF.xml
    ${start_date}    Get Current Date
    keywords.Perform Bts Commissioning    scf_file=${SCF_main_gnb}
    enbcell.Wait For All Cells To Be Onair    timeout=180
    gnbcell.Wait For All Cells To Be Onair    timeout=180
    ${end_date}    Get Current Date
    @{prevented_param_list}    Create list    FEATCADM-actLocInfoStore    FEATCADM-accLevSet
    Set Restrictions Via Parameter Editor    prevent_param_type=preventParamModifList
    ...                                      operation=delete
    ...                                      prevented_param=@{prevented_param_list}
    Change ActLocInfoStore Status    status=false
    gnbcell.Wait For All Cells To Be Onair    timeout=180
    Verify Permanent File On Ru    file_path=/ffs/run/rfsw/uoam/permanent.xml
    ...                            container_name=0x2018
    ...                            ru_username=toor4nsn
    ...                            ru_password=oZPS0POrRieRtu
    ...                            ru_name=aphg
    ...                            start_time=${start_date}
    ...                            end_time=${end_date}
    ...                            file_con_expec=clean
    Verify Permanent File On Ru    file_path=/mnt/runtime/rfsw/uoam/permanent.xml
    ...                            container_name=0x2018
    ...                            ru_username=rfsw
    ...                            ru_password=KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
    ...                            ru_name=awpqz
    ...                            start_time=${start_date}
    ...                            end_time=${end_date}
    ...                            file_con_expec=without_managed_object

[1][1.0] CB009077_B_04_Update_FR_flag_and_accuracy_level_setting_gNB
    [Tags]    T8
    Change AccLevSet Status    value=Low
    Change ActLocInfoStore Status    status=true
    @{prevented_param_list}    Create list    FEATCADM-actLocInfoStore    FEATCADM-accLevSet
    Set Restrictions Via Parameter Editor    prevent_param_type=preventParamModifList
    ...                                      operation=update
    ...                                      prevented_param=@{prevented_param_list}
    ${msg}=    Run Keyword And Expect Error    *    Change AccLevSet Status    value=High
    Should Contain    ${msg}    FEATCADM-1-[accLevSet] is not allowed
    ${msg}=    Run Keyword And Expect Error    *    Change ActLocInfoStore Status    status=false
    Should Contain    ${msg}    FEATCADM-1-[actLocInfoStore] is not allowed
    Set Restrictions Via Parameter Editor    prevent_param_type=preventParamModifList
    ...                                      operation=delete
    ...                                      prevented_param=@{prevented_param_list}


*** Keywords ***
Custom Test Setup
    Common Preconditions With Watching Alarms
    @{prevented_param_list}    Create list    FEATCADM-actLocInfoStore
    Set Restrictions Via Parameter Editor    prevent_param_type=preventParamModifList
    ...                                      operation=delete
    ...                                      prevented_param=@{prevented_param_list}
    Set Restrictions Via Parameter Editor    prevent_param_type=preventParamModifList
    ...                                      operation=delete
    ...                                      prevented_param=@{prevented_param_list}
    ...                                      bts_type=enb
