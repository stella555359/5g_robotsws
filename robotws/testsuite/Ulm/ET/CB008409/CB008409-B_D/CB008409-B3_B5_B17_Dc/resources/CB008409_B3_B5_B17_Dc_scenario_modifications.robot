*** Settings ***
Documentation    Scenario specific keywords for subfeature CB008409-B17 of "CB008409-B: PowerBoostVoNR_and_SRB_transmissions"

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts     WITH NAME    wts
Resource   ./../resources/CB008409_B3_B5_B17_Dc_initial_commissioning.robot
Resource   ./../resources/CB008409_B3_B5_B17_Dc_test_cases.robot



*** Keywords ***

#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    run keyword and continue on failure    run keywords    @{scenario_specific_keywords}
    log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords before attach
    RETURN


Run Feature specific keywords after attach before traffic is started
    IF               'B17' in '${scenario_name}'    TC_B17_IWK_PRB_blanking
    ...   ELSE IF    'B3' in '${scenario_name}'     TC_B3_IWK_Enhanced_MU-MIMO
    ...   ELSE IF    'B5' in '${scenario_name}'     TC_B5_IWK_PRB_pooling
    ...   ELSE IF    'Dc2' in '${scenario_name}'    TC_Dc2_FDD_IWK_with_DL_RAT1_and_RAT_DynSwitch_and_PRB_Pooling
    ...   ELSE IF    'Dc3' in '${scenario_name}'    TC_Dc3_TDD_IWK_with_DL_RAT1_and_PRB_Pooling


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    Sleep  ${traffic_duration}


Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    RETURN


#-----------For Suite Setup----------------------------------------------------------------------------------------------------------[150 characters]

Make necessary changes to SCF
    Change RD Parameters in swconfig File for CB008409

    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.load_scf    ${original_gnb_scf}
        Change Reporting Interval for CB008409  interval_duration=${pm_reporting_interval}
        Disable some Functionality according to CFAM
        Configure Prioritised bitrate on MAC-3
        Configure GBR for SA UEs in SCF File
        Disable UL & DL 256QAM on all Cells
        Activate CB008409-B
        Activate Pooling on FDD and TDD Cells  # Pooling feature enabled for all TCs
        IF               'CB008409 B17' in '${SUITE_NAME}'      Activate PRB Blanking
        ...   ELSE IF    'CB008409 B3' in '${SUITE_NAME}'       Activate Enhanced_MU-MIMO
        ...   ELSE IF    'CB008409 Dc3' in '${SUITE_NAME}'      Run Keywords
        ...   Activate Rat1Alloc On All Cells    AND   Configure bbmodBoardConfigType On ABIP
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    # Needed here as B5 and Dc2 are currently need to run with relation errors because of not supported frequency of HW Radio module for AP
    ${skip_relation_errors}  Set Variable If    'B5' in '${SUITE_NAME}' or 'Dc2' in '${SUITE_NAME}'  ${True}  ${False}
    ${oam_alias}=    connect.Setup OAM http session
    admin.perform_commissioning  scf_file=${configuration_directory}/SCF_updated.xml  connection=${oam_alias}
    ...  skip_parameter_relation_errors=${skip_relation_errors}   timeout=300
    connect.Teardown OAM http session


#-----------For swconfig.txt Changes-------------------------------------------------------------------------------------------------[150 characters]

Change RD Parameters in swconfig File for CB008409
    @{8409_rd_params}=  create list
    ...    0x580758=0        # InterSP pooling for FDD, Default=1(enabled)
    ...    0x58066a=0        # rdSlowPrbPoolingRangeTddDl, Disable InterSP pooling for TDD, Default=1(enabled)
    Update SW Config file on System Module  param_list=${8409_rd_params}


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Update Basic Configuration File
    wts.Load Wts Cfg  ${tl.core.dir_path}/${tl.core.cfg_filename}
      run keyword and ignore error    wts.Delete    ue_param id=1 nr_usage_setting=voice_centric
      run keyword and ignore error    wts.Delete    amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
      wts.Insert    ue_param id=1 nr_usage_setting=voice_centric                                         after    ue_param id=1
      wts.Modify    set_qosflow id=3    modification=5qi=1 gfbr_dl=960 gfbr_ul=960 mfbr_dl=1024 mfbr_ul=1024
      wts.Insert    amf_param id=1 empty_pdu_session_list=on send_ics_registration=on                    after    nwslice_set id=1
