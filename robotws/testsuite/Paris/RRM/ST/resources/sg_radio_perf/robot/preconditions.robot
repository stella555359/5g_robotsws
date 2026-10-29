*** Settings ***
Documentation
...              Keywords provided for suite and testcase setup or teardown
...
...              AUTHOR (I&V):     Annie Wong            annie.wong@nokia.com
...                          last update : 27.05.2021    get type for all UEs

Library       Process
Library       OperatingSystem
Library       ../python/testline_config.py
Library       testline_config.Testline_info          WITH NAME    tl_info
Library       taf.ul.hanging_resources               WITH NAME    resources
Library       ../../../../../resources/ST/python/scout_utils.py
Library       taf.sw.scout                           WITH NAME    scout

Resource      oam.robot
Resource      Keywords_gNB.robot
Resource      Commissioning.robot
Resource      Keywords_qualcomm.robot
Resource      ute_cfg_files_mgt.robot
Resource      taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${shared_config_id}=    ${False}


*** Keywords ***
Setup Testline Suite Variables
    # number GNB
    ${_gnb}=    tl_info.get_nb_gNBs
    import resource               ${CURDIR}/var_test_suite_gnb_source.robot
    run keyword if      ${_gnb}>1
    ...       import resource     ${CURDIR}/var_test_suite_gnb_target.robot

    # gt parameters from custom.yaml
    # TL_Number, GNB_Friendly_TL_Name, MRBTS, GNB_nr_bts, GNB_Architecture, UE_Architecture removed from custom.yaml
    ${list_keys_custom}=      Get dictionary Keys     ${custom}
    # DEBUG_MODE_CONSOLE is now set in var_test_suite_gnb_source.robot
    ${_log_mode}=    run keyword if     '${DEBUG_MODE_CONSOLE}'=='True'   set variable     ${True}
    ...                             ELSE                                  set variable     ${False}
    set suite variable      ${DEBUG_MODE_CONSOLE}     ${_log_mode}
    # but could be overwritten by custom.yaml
    ${index}=       Get Index From List     ${list_keys_custom}         DEBUG_MODE_CONSOLE
    run keyword if   ${index}>=0    set suite variable     ${DEBUG_MODE_CONSOLE}     ${custom['DEBUG_MODE_CONSOLE']}
    # iPerf_version_preference set in custom.yaml
    ${index}=       Get Index From List     ${list_keys_custom}     iPerf_version_preference
    ${IPERF_VERSION_PREFERENCE}=   run keyword if   ${index}>=0    set variable    ${custom['iPerf_version_preference']}
    ...                           ELSE                             set variable    ${2}
    set suite variable     ${IPERF_VERSION_PREFERENCE}
    # attenuator_ports_list and attenuator_ports_default_value :
    ${index}=       Get Index From List     ${list_keys_custom}     attenuator_ports_list
    run keyword if   ${index}>=0
    ...       set suite variable     ${attenuator_ports_list}    ${custom['attenuator_ports_list']}
    ${index}=       Get Index From List     ${list_keys_custom}     attenuator_ports_default_value
    run keyword if   ${index}>=0
    ...       set suite variable     ${attenuator_ports_default}     ${custom['attenuator_ports_default_value']}
    # ${is_HO_in_TL_config}    Run keyword and return status  dictionary should contain key
    #...           dictionary=${custom}    key=HO_Configuration

    # Ther can be multiple UEs:
    ${_num_ues}    Get Length    ${tl.ues}
    FOR   ${_num}     IN RANGE     ${_num_ues}
         ute_cfg_files_mgt.Fetch UE architecture    ue_id=${_num}
    END
    # UE_Architecture usage is only for UE_0
    ${UE_Architecture}=     ute_cfg_files_mgt.Get UE architecture     ue_id=${0}
    set suite variable      ${UE_Architecture}
    run keyword if      '${UE_Architecture}'=='QCT'       import variables        %{ABSTRACT_LIB_CONFIG}
    run keyword if      '${UE_Architecture}'=='QCT'       Keywords_qualcomm.Set Qualcomm UE Variables
    run keyword if      '${UE_Architecture}'=='QCT'
    ...      import resource      ${CURDIR}/var_test_suite_qct_iperf_ul.robot
    run keyword if      '${UE_Architecture}'=='PRISMA'
    ...      import resource      ${CURDIR}/var_test_suite_prisma.robot

    # run keyword if      '${UE_Architecture}'=='VIAVI'
    # ...        import resource      ${CURDIR}/../../resources/sg_radio_perf/robot/var_test_suite_Viavi.robot

    #GNB0:
    ${GNB_Architecture}      ute_cfg_files_mgt.Get gNB type     gnb_id=${0}
    set suite variable      ${GNB_Architecture}

    ${_oam_type}     ute_cfg_files_mgt.Get OAM type    gnb_id=${0}
    ${_card_type}    set variable      ${tl.gnbs[0].dus[0].airscale.common_units[0].hardware_type}

    Log        DEBUG_MODE_CONSOLE=${DEBUG_MODE_CONSOLE}                 console=${DEBUG_MODE_CONSOLE}
    Log        nb of gnb=${_gnb}                                        console=${DEBUG_MODE_CONSOLE}
    Log        nb of UEs defined in the TL=${_num_ues}                  console=${DEBUG_MODE_CONSOLE}
    Log        iPerf_version_preference=${IPERF_VERSION_PREFERENCE}     console=${DEBUG_MODE_CONSOLE}
    Log        UE_0_Architecture=${UE_Architecture}                       console=${DEBUG_MODE_CONSOLE}
    Log        GNB_Architecture(gnb0)=${GNB_Architecture}               console=${DEBUG_MODE_CONSOLE}
    Log        _oam_type=${_oam_type}                                   console=${DEBUG_MODE_CONSOLE}
    Log        _card_type=${_card_type}                                 console=${DEBUG_MODE_CONSOLE}
    Log        MRBTS=${MRBTS}                                    console=${DEBUG_MODE_CONSOLE}
    Log        NRBTS=${NRBTS}                                    console=${DEBUG_MODE_CONSOLE}


Restore GNB SCF SWCONFIG
    [Arguments]        ${source}=testcase      ${gnb}=all    ${restore_type}=all
    # this is the usual TC Basic Teardown
    # restore_type : all, scf, swconfig
    # source : testsuite, testcase
    Run Keyword If    '${gnb}'=='all'    Restore All GNBS Config     type=${restore_type}      source=${source}
    ...     ELSE                Restore GNB Config     gnb_id=${gnb}     type=${restore_type}     source=${source}


Restore All GNBS Config
    [Arguments]      ${type}=all      ${source}=testcase
    # type    : all, scf, swconfig
    # source : testsuite, testcase
    ${_id}      set variable    0
    ${gNBs}=    tl_info.get_gNBs
    FOR    ${elem}    IN    @{gNBs}
         Restore GNB Config      gnb_id=${_id}     type=${type}     source=${source}
         ${_id}   evaluate    ${_id} + 1
    END


Restore GNB Config
   [Arguments]     ${gnb_id}=0     ${type}=all     ${source}=testcase
    # type    : all, scf, swconfig
    # source : testsuite, testcase
    log        Restore the config for gNB=${gnb_id}   console=${DEBUG_MODE_CONSOLE}
    run keyword if     '${type}'!='scf' and '${source}'=='testcase'
    ...  run keyword and continue on failure       Set Swconfig
    ...                                               swconf_name=${BACKUP_SWC_FULLNAME[${gnb_id}]}  gNB=${gnb_id}
    run keyword if     '${type}'!='scf' and '${source}'=='testsuite'
    ...  run keyword and continue on failure       Set Swconfig
    ...                                               swconf_name=${ORIG_SWCONFIG[${gnb_id}]}   gNB=${gnb_id}
    run keyword if     '${type}'!='swconfig' and '${source}'=='testcase'
    ...  run keyword and continue on failure       Do Commissioning
    ...                                                ${BACKUP_SCF_FULLNAME[${gnb_id}]}      ${gnb_id}
    run keyword if     '${type}'!='swconfig' and '${source}'=='testsuite'
    ...  run keyword and continue on failure       Do Commissioning
    ...                                                ${ORIG_SCF[${gnb_id}]}     ${gnb_id}


TestSuite Basic PreConditions
    [Arguments]      ${archive_gnb_config}=${True}     ${archive_type}=all      ${gnb}=all
    Create Directory      ${LOCAL_SCF_DIR_PATH}
    run keyword if    '${archive_gnb_config}'=='True'    Archive GNB Ori Config   type=${archive_type}   gnb=${gnb}
    Run Keyword If    '${check_eda}'==${True}
    ...    ${resources_before}=    resources.get_resources_usage    node_id=0    node_type=gnb   detailed=True


TestSuite Basic Teardown
    [Arguments]      ${restore_gnb_config}=${True}     ${restore_type}=all      ${gnb}=all
    # restore_type : all, scf, swconfig
    run keyword if    '${restore_gnb_config}'=='True'
    ...             Restore GNB SCF SWCONFIG     source=testsuite    gnb=${gnb}   restore_type=${restore_type}
    interface.Common step trigger
    ${resources_after}=    Run Keyword If    '${check_eda}'==${True}
    ...    resources.get_resources_usage    node_id=0    node_type=gnb   detailed=True
    Run Keyword If    '${check_eda}'==${True}
    ...    Resources Should Be Equal   ${resources_before}   ${resources_after}    exclude=//CPRT//l2resource//l2psList
    Teardown Session with alias     alias=oam_session
    Terminate All Processes              kill=True
    Log             TestSuite is completed!   console=${DEBUG_MODE_CONSOLE}


TestCase Basic PreConditions
    [Arguments]      ${gnb}=all     ${backup_type}=all
    Run Keyword If    '${gnb}'=='all'          Check All GNBS Status And Backup Config    type=${backup_type}
    ...     ELSE                               Check GNB And Backup Config     gnb_id=${gnb}    type=${backup_type}


Archive GNB Ori Config
    [Arguments]      ${gnb}=all       ${type}=all
    Run Keyword If    '${gnb}'=='all'         Archive All GNBS Config        type=${type}
    ...     ELSE                               Archive GNB Config      gnb_id=${gnb}      type=${type}


Archive All GNBS Config
   [Arguments]      ${type}=all
   #type : all, scf, swconfig
   ${_id}      set variable    0
   ${gNBs}=    tl_info.get_gNBs
   FOR    ${elem}    IN    @{gNBs}
        Archive GNB Config      type=${type}     gnb_id=${_id}
        ${_id}   evaluate    ${_id} + 1
   END


Archive GNB Config
   [Arguments]      ${type}=all    ${gnb_id}=0
    Log            Archive ori GNB config (${type}) for gNB=${gnb_id}   console=${DEBUG_MODE_CONSOLE}
    run keyword if    '${type}'!='swconfig'          Archive ORI SCF           gNB=${gnb_id}
    run keyword if    '${type}'!='scf'               Archive ORI Swconfig      gNB=${gnb_id}


Check All GNBS Status And Backup Config
   [Arguments]      ${type}=all
   #type : all, scf, swconfig
   ${_id}      set variable    0
   ${gNBs}=    tl_info.get_gNBs
   FOR    ${elem}    IN    @{gNBs}
         Keywords_gNB.Check gNB State      gNB=${_id}
         log         Backup the initial swconfig and SCF for gNB=${_id}   console=${DEBUG_MODE_CONSOLE}
         run keyword if    '${type}'!='swconfig'      Backup initial SCF           gNB=${_id}
         run keyword if    '${type}'!='scf'           Backup Initial Swconfig      gNB=${_id}
         ${_id}   evaluate    ${_id} + 1
   END


Check GNB And Backup Config
   [Arguments]      ${type}=all      ${gnb_id}=0
    Keywords_gNB.Check gNB State      gNB=${gnb_id}
    log       Backup the initial swconfig and SCF for gNB=${gnb_id}   console=${DEBUG_MODE_CONSOLE}
    run keyword if    '${type}'!='swconfig'      Backup initial SCF           gNB=${gnb_id}
    run keyword if    '${type}'!='scf'           Backup Initial Swconfig      gNB=${gnb_id}


Get Scout Bts Name
    ${SCOUT_TESTLINE_NAME}    scout_utils.get_bts_scout_name
    Set Suite Variable    ${SCOUT_TESTLINE_NAME}


# TODO Remove
Set Scout Confid Id
    Set Scout Config Id


Set Scout Config Id
    Wait Until Keyword Succeeds
    ...    2min
    ...    10s
    ...    scout_utils.set_scout_config_id_tc    ${SCOUT_TESTLINE_NAME}    timeout=600


Share Scout Config Id
    FOR    ${tag}    IN    @{TEST TAGS}
        Run Keyword If    'ute:id:' in '${tag}'    Set Suite Variable    ${shared_config_id}    ${tag}
    END
