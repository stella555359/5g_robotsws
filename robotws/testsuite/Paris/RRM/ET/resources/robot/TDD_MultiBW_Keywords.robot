*** Settings ***
# --------------------------------------------------------------------------------------------------------------------------------------------------
Documentation     File containing common keywords that can be used by all MultiBW test suites
...               Modified Date               : 2024-03-27
...               Version   Date      Author                             Notes
...               n/a       n/a       n/a                                Creation
...               n/a       n/a       vincent.boulet@nokia.com           Update for supporting vRAN2.0 Cloud topology
...               n/a       n/a       vincent.boulet@nokia.com           Update gscn value for vRAN2.0 into IPHY for NRCELL1 only
...               1.0       FB2407    vincent.boulet@nokia.com           Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...               1.1       FB2419    richard.duthu@nokia.com            Scout data
# --------------------------------------------------------------------------------------------------------------------------------------------------

Library             taf.rfrl.common_resources.python.SWConfig

Variables           ../../../../resources/SWENG/python/ReadConfig.py

Resource            ../../../../resources/SWENG/robot/GenericTest.robot
Resource            ../../../../resources/SWENG/robot/SetConfig.robot
Resource            ../../../../resources/SWENG/robot/Tools.robot
Resource            ../../../../resources/SWENG/robot/Connect.robot
Resource            ../../../../resources/SWENG/robot/Restart.robot
Resource            ../../../../resources/SWENG/robot/CallSetup.robot
Resource            ../../../../resources/SWENG/robot/Traffic.robot
Resource            ../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource            ../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource            ../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource            ../../../../resources/SWENG/robot/Oam.robot
Resource            ../../../../resources/SWENG/robot/Scf.robot
Resource            ../../../../resources/SWENG/robot/Sherpa.robot


*** Keywords ***

Suite Setup From Scratch And Set Universal SCF
    [Documentation]    Run "Suit Setup From Scratch" then setup an "universal SCF" by removing some elements
    ...                from the original SCF and run a comissionning with the updated SCF
    ...                The configType parameter is used to perform a workaround in case of SA : currently
    ...                the WTS config files (Basic.cfg and Airphone.xml) cannot be donwnoaded directly from
    ...                Gerrit --> they will be copied from the local resources directory

    [Arguments]    ${configType}=NSA

    Dated Log    Start Suite Setup From Scratch And Set Universal SCF

    # WA - for sa : copy config files provided by UTE
    Run Keyword If    '${configType}'=='SA'    Copy Wts Cfg Files

    Suite Setup From Scratch

    # remove some elements from the SCF
    #  --------------------------------

    # list of dist names associated with objects where to remove elements
    @{obj_list}=    Create List    MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-2    MRBTS-${MRBTS_ID}/EQM-1/HWTOP-1/CABLINK-3

    # list of elements to be removed
    @{elt_list}=    Create List    secondEndpointLabel    secondEndpointPortId

    ${remove_ok}=    Scf Remove Elements From Objects    ${obj_list}    ${elt_list}

    Return From Keyword If     ${remove_ok}==${False}    ${False}


Set MRBTSID and NRBTSID
    [Documentation]    Author: Wolfgang VELASQUEZ [PRIVATE]
    ...                Description: Reads MrbtsID and NrbtsID from Element Manager and sets it as distinguished name for the entire test suite
    ${scfFilePath}=              OAM Get SCF File                    dir=${LOG_PATH}    file=SCF_DU_Setup.xml
    ${bwp_id}=                   Get Bwp Profile Dedicated           scf_file_path=${scfFilePath}
    ${dist_name} =               Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${TDD_Cell_list[0].nrCellId}
    ${dist_name_fdd} =           Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRCELL_FDD-1
    ${nrsysinfo_dist_name} =     Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRSYSINFO_PROFILE-1/NRIRFIM-1
    ${nrcelch_dist_name} =       Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/${NRCELL_GRP}
    ${RadioModule_name} =        Set Variable    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ${PDCCH_configDedicated} =   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${bwp_id}/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    Dated Log                    ===> PDCCH dedicated configuration to update is: ${PDCCH_configDedicated}

    Set Suite Variable          ${dist_name}
    Set Suite Variable          ${dist_name_fdd}
    Set Suite Variable          ${nrsysinfo_dist_name}
    Set Suite Variable          ${nrcelch_dist_name}
    Set Suite Variable          ${RadioModule_name}
    Set Suite Variable          ${PDCCH_configDedicated}


Test Teardown BW
    [Documentation]    Perform needed actions at the end of a test case

    Dated log                       Test teardown : start
    Produce Scout Data

    # save SOS Report, OAM snapshot if testcase failed or if ${AutoSaveDebugData} is ${True}
    Set Global Variable              ${save_debug_data}    ${False}
    Run Keyword If Test Failed      Set Global Variable    ${save_debug_data}    ${True}
    Run Keyword If                  ${AutoSaveDebugData} == ${True}    Set Global Variable    ${save_debug_data}    ${True}

    # Get_Traces_Sherpa to be added when it's OK
    Run Keyword If                  ${save_debug_data} == ${True} and not ${isAic}    Run Keywords
    ...                             Get Sos Report
    ...                             Get Snapshot

    Step                            Restore Iphy AirphoneConfig
    Step                            Restore Context_WTS CFG
    Step                            Restore SCF

    Dated log                       Test teardown : end


# IPHY Corner #################################################################################################

Set Context_AP IPHY
    Backup Iphy AirphoneConfig

    WtsXmlConfig.startSession         file=iphy
    #
    Run Keyword If    not ${isAic}    Run Keywords
    ...                               WtsXmlConfig.setTextUsingIndex    path=//GSCN                  val=${param.gscn}                 idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//cardName              val=${param.cardName}             idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//productCode           val=${param.productCode}          idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//resourceBuildKey      val=LTX_${param.RU}               idx=1
    # update iphy.xml with swVersion and swFileKey values taken fomr GNB TargetBD_*.xml
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//bldVersion            val=${g_resource_swVersion}       idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//soap-config/software/file/name
    ...                                                                                              val=${g_resource_swFileKey}       idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//soap-config/software/file/name
    ...                                                                                              val=${g_resource_swFileKey}       idx=2
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//soap-config/software/file/version
    ...                                                                                              val=${g_resource_swVersion}       idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//soap-config/software/file/version
    ...                                                                                              val=${g_resource_swVersion}       idx=2
    ...         ELSE                  Run Keywords
    ...                               WtsXmlConfig.setTextUsingIndex    path=//cardName              val=${param.cardName_isAic}       idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//bldVersion            val=${g_resource_swVersion}       idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//productCode           val=${param.productCode_isAic}    idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//resourceBuildKey      val=LTX_${param.RU_isAic}         idx=1
    #
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//GSCN                  val=${param.gscn}                 idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//name                  val=${g_resource_swFileKey}       idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//name                  val=${g_resource_swFileKey}       idx=2
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//version               val=${g_resource_swVersion}       idx=1
    ...    AND                        WtsXmlConfig.setTextUsingIndex    path=//version               val=${g_resource_swVersion}       idx=2
    #
    WtsXmlConfig.stopSession          file=iphy


Backup Iphy AirphoneConfig
    [Documentation]                 Backup current iphy file on AP

    ${alias}                        SSH Connect                          ${AP_DU.sys[0].M}

    ${file}                         SSH Cmd                              command=readlink -f /rom/simmode/iphy.xml
    ...                             alias=${alias}
    Dated log                       On Airphone, backing up file ${file}
    ${file}                         Strip String                         ${file}
    ${iphy_backup_exists}=          SSH Cmd                              command=test -f ${file}.backup && echo -n "okman" || echo -n "noway"
    ...                             alias=${alias}
    ${iphy_file_exist}              SSH Cmd                              command=test -f ${file} && echo -n "okman" || echo -n "noway"
    ...                             alias=${alias}
    run keyword if                  '${iphy_file_exist}'=='okman' and '${iphy_backup_exists}'!='okman'
    ...                             SSH Cmd                              command=cp ${file} ${file}.backup     alias=${alias}
    Dated log                       On Airphone, ${file} is backed up


Restore Iphy AirphoneConfig
    [Documentation]                 Restores iphy file on AP
    Dated log                       On Airphone, Restoring up file ${iphy_file_path}/iphy.xml
    ${alias}                        SSH Connect                          ${AP_DU.sys[0].M}
    ${file}                         SSH Cmd                              command=readlink -f /rom/simmode/iphy.xml
    ...                             alias=${alias}
    ${file}                         Strip String                         ${file}
    ${iphy_backup_exists}=          SSH Cmd                              command=test -f ${file}.backup && echo -n "okman" || echo -n "noway"
    ...                             alias=${alias}

    # ADT - remove below codes (unuseful)
    # ${iphy_file_exist}              SSH Cmd                              command=test -f ${file} && echo -n "okman" || echo -n "noway"
    # ...                             alias=${alias}

    SSH Cmd                         command=cp ${file} ${file}.modified    #vbo#for comparing configuration between topologies#
    ...                             alias=${alias}
    run keyword if                 '${iphy_backup_exists}'=='okman'
    ...                             SSH Cmd                              command=mv ${file}.backup ${file}
    ...                             alias=${alias}
    Dated log                      On AP, backed up ${file} file restored


# WTS corner ##################################################################################################


Restore Context_WTS CFG
    [Documentation]                 Erase  AirphoneConfig basic  "modified" file on ePCSim

    ${alias}                        SSH Connect                       ${HOST_EPCSIM}

    # ADT - the file check should not be done using a generic name otherwise the result will always be "false"

    ${modified_file}=               Set variable     ${tl.core.dir_path}/basic_wts_step2.modified.cfg

    ${file_exists}=                 SSH Cmd
    ...                             command=test -f ${modified_file} && echo -n "okman" || echo -n "noway"
    ...                             alias=${alias}

    Dated log                       file_exists:${file_exists}

    # ADT - Restore WTS cfg file
    # (the tl.core.cfg_filename was modified in WtsCfgConfig.stopSession --> need to reset it to the original value)
    #vbo#for comparing configuration between topologies#Run Keyword If                  '${file_exists}'=='okman'    Run Keywords
    #vbo#...                             SSH Cmd        command=rm ${modified_file}               alias=${alias}
    #vbo#...                             AND    restoreFilename


Set Scf Modification Indicator
    [Documentation]                 Update variable "g_scf_updated" with the value given as argument
    ...                             ${val} should be ${True} or ${False}

    [Arguments]                     ${val}

    Set Suite Variable              ${g_scf_updated}    ${val}


Is Scf Modification Indicator Set
    [Documentation]                 Return the value of the "SCF modification indicator"
    ...                             ${True} = the local SCF was modified
    ...                             ${False} = the local SCF was not modified

    [Return]                        ${g_scf_updated}


Scf Remove Elements From Objects
    [Documentation]    Remove elements provided in the @{elt_list} from the object list provided by ${obj_list}
    ...                If some element could be removed then the updated SCF is automatically commissioned
    ...                at the end
    ...                Parameters to be provided : 1st param = the object list, 2nd param = the element list
    ...                Usage example: Scf Remove Elements From Objects    @{MyObjList}    @{MyEltList}

    [Arguments]    @{args}

    @{obj_list}=    Get From List    ${args}    0

    @{elt_list}=    Get From List    ${args}    1

    # copy SCF to local VM
    # --------------------

    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S

    ${tmp_scf_name}=    Set Variable    SCF_GNB_${timestamp}.xml

    ${tmp_scf_file}=    OAM Get SCF File    dir=${LOG_PATH}    file=${tmp_scf_name}

    Dated Log    Temporary SCF file = ${tmp_scf_file}

    # remove elements given by elt_list from objects provided in obj_list
    # -------------------------------------------------------------------

    SCF StartSession    scf_file=${tmp_scf_file}

    Set Scf Modification Indicator    ${False}

    FOR    ${obj}    IN    @{obj_list}
         ${elt_removed}=    SCF Remove Element List   ${obj}    @{elt_list}
         Run keyword if    ${elt_removed}    Set Scf Modification Indicator    ${True}

    END
    SCF StopSession    scf_file=${tmp_scf_file}

    # commissioning the updated SCF
    # -----------------------------

    ${scf_updated}=    Is Scf Modification Indicator Set

    Run keyword if    ${scf_updated} == ${True}    Run Keywords
    ...        Dated Log    Start commissioning with the updated SCF file ${tmp_scf_file}
    ...        AND    OAM Perform Full Commissioning     ${tmp_scf_file}
    ...        AND    Dated Log    End commissioning, wait for OAM to come back
    ...        AND    OAM wait available    wait_time=600
    ...        AND    Wait Testline To Be Ready
    ...    ELSE
    ...        Dated Log    SCF file was not update --> no commissionning needed


Backup Scf
    [Documentation]                 Save the current SCF

    ${g_backup_scf}    OAM Get SCF File    dir=${LOG_PATH}    file=SCF_backup.xml

    Set Suite Variable    ${g_backup_scf}

    Dated Log    SCF backup file = ${g_backup_scf}


Restore Scf
    [Documentation]                 Restore the saved SCF

    ${backup_scf}=    Get Variable Value    ${g_backup_scf}    None

    Run keyword if    """${backup_scf}""" != 'None'    Run Keywords
    ...        Dated Log    Start commissioning with the backup SCF file ${backup_scf}
    ...        AND    OAM Perform Full Commissioning     ${backup_scf}
    ...        AND    Dated Log    End commissioning, wait for OAM to come back
    ...        AND    OAM wait available    wait_time=600
    ...        AND    Wait Testline To Be Ready


Wait Testline To Be Ready
    [Documentation]                 Wait for the TL to be ready after having been rebooted
    ...                             (test line may be rebooted after SCF comissioning)
    ...                             If ${waitF1} is ${True} then wait until F1 is up

    [Arguments]                     ${waitF1}=${False}

    Sleep    1m    Waiting for 1 minute
    WA Airscale Wait For Ready                   ${GNB_DU}
    WA Airscale Wait For Ready                   ${AP_DU}
    Return From Keyword If                       ${waitF1}==${False}    ${True}
    Get TL Info Struct
    WA DCI Wait for service                      ${AP_DU}
    F1 Wait Link Classical
    GNSS Check and run
    IRfHead Check Service


Copy Wts Cfg Files

    Dated Log        *** WA *** Copying SA WTS configuration files from the ones provided by UTE ${CURDIR}

    ${src_file}      Set Variable    /opt/iphy/latest/basic_setup.cfg

    ${dst_file}      Set Variable    /opt/iphy/latest/basic_wts_step2.cfg

    ${output}        run              cp ${src_file} ${dst_file}
    Dated Log        ${output}

    Run Keyword If    not ${isAic}
    ...    ${src_file}    Set Variable    /opt/iphy/latest/AirphoneConfig.xml
    ...    ${dst_file}    Set Variable    /opt/iphy/latest/Airphone.xml
    ...    ${output}      run             cp ${src_file} ${dst_file}
    ...    Dated Log      ${output}

#=======Keyword for passing eGATE commands on WTS=========================
Wts_command
    [Arguments]          @{varargs}    &{kwargs}      #les non named vont dans la suite @{varargs} les named argument vont dans le dico &{kwargs}
    Dated Log    ----> wtsemu.${varargs[0]} &{kwargs}
    Run Keyword    wtsemu.${varargs[0]}    &{kwargs}

#=======WA For decresing PUSCH RX_Power/RSSI/SINR/NOISE for AIC===========
Reduce_Pusch_RX_Power_AND_SINR
    Wts_command    ul_sinr_testmode_nr    profile_id=1    sinr_target_pusch=-250
    Wts_command    ue_testmode_set_nr    id=1    testmode=ul_sinr    action=activate    profile_id=1

