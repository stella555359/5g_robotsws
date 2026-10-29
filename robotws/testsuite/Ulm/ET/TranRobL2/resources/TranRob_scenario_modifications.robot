*** Settings ***
Documentation    Common keywords specific to Tranversal Robustness

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library    taf.config.wts                         WITH NAME    wts
Library    taf.sbts.oam.coam.admin                WITH NAME    admin

Resource   ../../../resources/Common/connect.robot
Resource   ../resources/TranRob_initial_commissioning.robot
Resource   ../resources/TranRob_initial_commissioning_CA.robot
Resource   ../resources/TranRob_test_cases.robot



*** Keywords ***


#-----------For Test Execution ------------------------------------------------------------------------------------------------------[150 characters]

Run Scenario specific Keywords before Scenario Execution
    [Documentation]  Allows for extra Keywords to be Executed before Test is started.
    ...    Keywords must be written in the json as as list of strings with Names corresponding to Keywords in this File.
    ...    If something goes wrong during execution of the Keywords there will be no error In the logs, so please check
    ...    yourself if everything worked as
    [Arguments]      ${scenario_specific_keywords}
    Run Keyword And Continue On Failure    Run Keywords    @{scenario_specific_keywords}
    Log    The following Keywords were Run: ${scenario_specific_keywords}


Run Feature specific keywords before attach
    IF   'Capacity' in '${SUITE_NAME}'
    ...    Run Keyword And Continue On Failure   Loop MUE Calls 330 times


Run Feature specific keywords after attach before traffic is started
    RETURN


Run Feature specific keywords during traffic before detach
    [Arguments]  ${traffic_duration}
    ${starttime_traffic}=  DateTime.Get Current Date  UTC
    Log to console  Traffic started at ${starttime_traffic} UTC
    Log to console  Traffic duration: ${traffic_duration}


Run Feature specific keywords after traffic before detach
    RETURN


Run Feature specific keywords after detach
    RETURN



#-----------For Suite Setup----------------------------------------------------------------------------------------------------------[150 characters]

Make necessary changes to SCF
    Change IPHY if needed
    Change SWCONFIG in gNB if needed
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    scf.load_scf    ${original_gnb_scf}
        Change Reporting Interval  interval_duration=${pm_reporting_interval}
        Activate CA if needed
    scf.save_scf    ${configuration_directory}/SCF_updated.xml
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    Perform Commissioning on Classical BTS    ${configuration_directory}/SCF_updated.xml


Perform Commissioning On Classical BTS
    [Arguments]  ${scf_file}
    ${oam_alias}=  connect.Setup OAM HTTP Session
    admin.Perform Commissioning     scf_file=${scf_file}
    ...                             connection=${oam_alias}
    ...                             skip_parameter_relation_errors=False
    ...                             timeout=300
    connect.Teardown OAM HTTP Session


#-----------For basic_setup.cfg Changes----------------------------------------------------------------------------------------------[150 characters]

Update Basic Configuration File
    wts . Load Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}
        wts . Modify    set_cell id=2    nr_arfcn=647666:647666 gscn=7995
        wts . Modify    set_cell id=4    nr_arfcn=342000:422000 gscn=5275
    wts . Save Wts Cfg        ${tl.core.dir_path}/${tl.core.cfg_filename}



#-----------For iphy.xml Changes-----------------------------------------------------------------------------------------------------[150 characters]

Change IPHY if needed
    ${ap_alias}    connect . Connect to Airphone Common Unit
    ssh . Download File    /rom/simmode/new_iphy.xml    ${configuration_directory}/new_iphy_orig.xml    connection=${ap_alias}
        ${contents}    get file    ${configuration_directory}/new_iphy_orig.xml
        ${all_parts}    split string      ${contents}     </RE>
        ${p0}   set variable   ${all_parts}[0]    # 1st TDD Cell
        ${p1}   set variable   ${all_parts}[1]    # 2nd TDD Cell
        ${p2}   set variable   ${all_parts}[2]    # 1st FDD Cell
        ${p3}   set variable   ${all_parts}[3]    # 2nd FDD Cell
        ${p4}   set variable   ${all_parts}[4]    # last part of the iphy.xml file
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p1}   replace string using regexp   ${p1}   GSCN>.*<\/GSCN>   GSCN>7995<\/GSCN>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${p3}   replace string using regexp   ${p3}   cardName>.*<\/cardName>   cardName>AHFIB<\/cardName>
        ${p3}   replace string using regexp   ${p3}   resourceBuildKey>.*<\/resourceBuildKey>   resourceBuildKey>LTX_AHFIB<\/resourceBuildKey>
        ${p3}   replace string using regexp   ${p3}   GSCN>.*<\/GSCN>   GSCN>5275<\/GSCN>
        #----------------------------------------------------------------------------------------------------------------------------[150 characters]
        ${new contents}      catenate         SEPARATOR=</RE>    ${p0}    ${p1}    ${p2}    ${p3}    ${p4}
        create file    ${configuration_directory}/new_iphy_updated.xml    ${new contents}
    ssh . Upload File       ${configuration_directory}/new_iphy_updated.xml    /rom/simmode/new_iphy.xml   connection=${ap_alias}



#-----------For swconfig.txt Changes-------------------------------------------------------------------------------------------------[150 characters]

Change SWCONFIG in gNB if needed
    IF   'Endurance' not in '${SUITE_NAME}'   RETURN
    @{rd_params}=  create list
    ...    0x66001b=2          # CP-NRT log level (default = 2, 0 = disable 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    0x890001=2          # CP-NB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    0x890002=2          # CP-SB log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    0x890003=2          # CP-UE log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    0x890004=2          # CP-CL log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    0x890005=2          # CP-IF log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    0x890006=2          # CP-SCTP log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    0x890008=2          # CP-E2 log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    ...    0x890009=2          # CP-VEMC log level (default = 2, 0 = trace 1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
    Update SW Config file on System Module  param_list=${rd_params}



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
