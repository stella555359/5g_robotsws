** Settings ***
Documentation    Suite description
Library      BuiltIn
Library      DateTime
Library      OperatingSystem
Library      Process
Library      String
Library      taf.transport.ssh           WITH NAME   ssh
Library      taf.config.testline.info             WITH NAME      testlineInfo
Library      taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    ti

Resource        ${CURDIR}/configuration.robot
Resource        ${CURDIR}/gnbStatus.robot
Resource        ${CURDIR}/luashark.robot


*** Keywords ***
Suite result directory
    [Documentation]     create the Suite result repository under /home/localuser/testResults/. RobotResults repository
    ...                 is created if does not exist yet
    ...                 the name of the repository is the suite name with the date & hour of creation.
    ...                 ${suite_dir} set as suite variable accessible from anywhere in the tests suite and dependancies
    ...                 Author: EricBP

    # Evaluate Ue type
    ${is_ue_Prisma}    testlineInfo.has_Prisma      ${tl}
    ${ABSTRACT_LIB_CONFIG}    Get Environment variable    ABSTRACT_LIB_CONFIG    None
    ${status}    ${cles}=    Run keyword and ignore error    Get file    ${ABSTRACT_LIB_CONFIG}
    ${status_qc}    ${is_ue_qct}=    Run keyword and ignore error   Should match regexp    ${cles}    AndroidUePool
    ${status_viavi}    ${is_ue_viavi}=    Run keyword and ignore error   Should match regexp    ${cles}    ViaviUePool

    ${UE_Architecture}    Set Variable    None
    ${UE_Architecture}=    set variable if
    ...             '${is_ue_Prisma}' != 'False'    PRISMA
    ...             '${status_qc}' != 'FAIL'            QCT
    ...             '${status_viavi}' != 'FAIL'            VIAVI
    ...             None

    log    UE_Architecture:${UE_Architecture}

    Set suite variable    ${UE_Architecture}    ${UE_Architecture}

    import resource     ${CURDIR}/var_test_suite.robot
    run keyword if      '${UE_Architecture}'=='QCT'
    ...                 import variables        %{ABSTRACT_LIB_CONFIG}
    run keyword if      '${UE_Architecture}'=='QCT'
    ...                 import resource         ${CURDIR}/var_test_suite_QC.robot
    run keyword if      '${UE_Architecture}'=='PRISMA'
    ...                 import resource         ${CURDIR}/var_test_suite_Prisma.robot
    run keyword if      '${UE_Architecture}'=='VIAVI'
    ...                 import resource         ${CURDIR}/var_test_suite_Viavi.robot


    # Path of executables Prisma, taken from custom.yaml. Used only in case of Prisma Ue.
    # custom['PATH_TL_Config'] = directory containing TL configuration
    # custom['airmosaic_cfg_path'] = directory containing .sid and .sce files used by Prisma, and their dependancies. This
    #                          directory and its content shall be present on the VM.
    # custom['yaml_prisma_filename_path'] = directory where Prisma.yaml file is stored.
    # custom['yaml_prisma_filename'] = Prisma.yaml file that will be given to taf.ue.prisma to configure airmosaic.
    Run keyword if    '${is_ue_Prisma}' != 'False'    Run keywords
    ...               Run keyword and ignore error    Remove Directory    /home/localuser/tempconfig    true    AND
    ...               copy directory      ${custom['PATH_TL_Config']}        /home/localuser/tempconfig    AND
    ...               set suite variable  ${custom['PATH_TL_Config']}        /home/localuser/tempconfig/   AND
    ...               copy files          ${custom['airmosaic_cfg_path']}/*        /home/localuser/tempconfig/    AND
    ...               copy file           ${custom['yaml_prisma_filename_path']}/${custom['yaml_prisma_filename']}    /home/localuser/tempconfig/

    ## Determine gNB type Classical or Cloud
    ${gnb_type_detect}=        testlineInfo.has_cloudBts      ${tl}
    Log    gNB type: ${gnb_type_detect}
    ${GNB_Architecture}=    set variable if    '${gnb_type_detect}' == 'True'    CLOUD    CLASSICAL
    set suite variable   ${GNB_Architecture}     ${GNB_Architecture}

    ## Determine OAM typeM: MzOAM or cOAM
    ${is_cOAM}=          run keyword and return status     coam.connect to      bts_host=${oam_vm}    name=coamCnx
    ${is_cOAM_cu}=       run keyword and return status     coam_cu.connect to      host=${oam_vm}
    ...                  port=    username=${oamVMMzLogin}    password=${oamVMMzPassword}     cu_version=cuoam_19b    secure=${TRUE}

    ${oam_type}=         set variable if    '${is_cOAM}' == 'False' and '${is_cOAM_cu}' == 'False'     MZOAM    COAM

    set suite variable   ${oam_type}     ${oam_type}
    configuration.get du hw type
    log    ${system_module_type}
    Run keyword and ignore error    coam.teardown    coamCnx
    Run keyword and ignore error    coam_cu.disconnect
    Should contain any    ${system_module_type}    ASIK    ASOD    ASIB

    # Determine baseband module
    configuration.Create Connections

    # la liste des baseband remontes par l'asod est vide,il faut se baser sur le system_module
    #configuration.get baseband type
    run keyword and ignore error    mz.teardown session       MegaZ
    run keyword and ignore error    coam_cu.disconnect
    run keyword and ignore error    coam.teardown    coamCnx

    ${date}             get current date    result_format=%Y%m%d_%H_%M
    ${directory}        replace string      ${SUITE NAME}_${date}    ${SPACE}    _

    # If launcher is Cloud or local VM: traces shall be stored in ${PATH_Storage}
    # If launcher is Eclat: traces should be stored in ${ECLAT_STORAGE}
    ${launcher}=    get variable value    ${eclat["launcher"]}    default=Other
    log     ${launcher}
    ${result_path}=      set variable if    '${launcher}' == 'eCLAT'     %{ECLAT_STORAGE}/${directory}    ${PATH_Storage}/${directory}

    create directory    ${result_path}
    set suite variable  ${suite_dir}    ${result_path}
    set suite variable  ${suite_journal}    ${suite_dir}/testsuite_journal.txt
    configuration.Create Connections
    configuration.Create ssh
    configuration.Save SCF      path=${suite_dir}       scf_name=initial_scf.xml
    configuration.Save sw config    path=${suite_dir}       swcfg_name=initial_swconfig.txt

    ${rel}        gnbStatus.Get Software Version
    @{rel_splited}      Split String    ${rel}    separator=_
    ${cnt}=    Get length    ${rel_splited}
    ${5GRelease}    Set Variable If     ${cnt} > 0
    ...    @{rel_splited}[0]
    ...    unknown
    set suite variable  ${5GRelease}      ${5GRelease}
    log                 5G Release = ${5GRelease}

    # temporary comment pour tests unitaires
    luashark.Get Related Luashark    ${rel}

    configuration.Close Connections SSH


testcase result directory
    [Documentation]     create the testcase result repository under the suite repository created by Suite result directory
    ...                 keyword. The absolute path is set as a test variable.
    ...                 the name of the repository is the testcase name with the date & hour of creation.
    ...                 it creates also the /log, /scf, /save repositories which are set as test variables
    ...                 Author: EricBP
    append to file      ${suite_journal}    ${PREV TEST NAME}:::${PREV TEST STATUS}\n

    ${date}             get current date    result_format=%Y%m%d_%H_%M
    ${directory}        replace string      ${TEST NAME}_${date}    ${SPACE}    _
    ${res_path}         joinpath        ${suite_dir}     ${directory}
    create directory    ${res_path}
    set test variable   ${res_path}     ${res_path}
    ## other directories creation under testcase result directory
    ${logs_path}        join path       ${res_path}   logs
    create directory    ${logs_path}
    set test variable   ${logs_path}    ${logs_path}
    ## to be ported to SCF commissioning keyword
    ${scf_path}         join path       ${res_path}   scf
    create directory    ${scf_path}
    set test variable   ${scf_path}     ${scf_path}
    ## to be ported but where?
    ${save_path}        join path       ${res_path}   save
    create directory    ${save_path}

    set test variable   ${save_path}    ${save_path}
    set test variable   ${reboot}       0
    set test variable   ${partialstatus}    ${SPACE}
    ${testid}    get regexp matches      ${TEST_NAME}     (5GC\\d+_\\w{1,3}_\\d+)_     1
    Run keyword if  ${testid}       Check test already passed   ${testid}[0]
    configuration.Create Connections
    configuration.Create ssh
    configuration.Save SCF  save_initial_scf.xml
    configuration.Save sw config    save_initial_swconfig.txt
    #Update 15/12.
    ${cmd}      catenate
    ...         grep -i \\"btsName\\" ${scf_path}/save_initial_scf.xml
    ...         | awk -F ">" '{print $2}' | awk -F "<" '{print $1}'
    ${GNB_Friendly_TL_Name}=    Run    ${cmd}
    # Previous modification doesn't work in case there are spaces in btsName. Temporary fix.
    ${GNB_Friendly_TL_Name}    set variable    TL
    Set suite variable       ${GNB_Friendly_TL_Name}            ${GNB_Friendly_TL_Name}

testcase status
    append to file      ${suite_journal}    ${TEST NAME}=${TEST STATUS}:::${logs_path}


Make snapshot
    [Documentation]   request gNB snapshot
    run keyword if      '${GNB_Architecture}' == 'CLOUD' and '${oam_type}' == 'COAM'
    ...                 Make snapshot cloud coam
    run keyword if      '${GNB_Architecture}' == 'CLASSICAL'
    ...                 Make snapshot classical

Make snapshot cloud coam
    ${timeout}           set variable    600
    ${timestamp}        Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_du_path}    Join Path    ${suite_dir}    snapshot_du_${timestamp}.zip
    configuration.Create Connections
    coam_cu.get_local_snapshot    ${suite_dir}
    coam.get_snapshot     target_file_name=${snapshot_du_path}    timeout=${timeout}    connection=coamCnx
    coam.teardown        connection=coamCnx
    coam_cu.disconnect


Make snapshot classical
    coam.connect to      bts_host=${oam_vm}    name=coamCnx
    ${timeout}           set variable    600
    ${timestamp}        Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_path}    Join Path    ${suite_dir}    snapshot_${timestamp}.zip
    coam.get_snapshot     target_file_name=${snapshot_path}    timeout=${timeout}    connection=coamCnx
    coam.teardown        connection=coamCnx


Save suite report files
    [Documentation]     allows to save the output files: logs.html, output.xml, report.html in the suite result directory.
    ...                 the output files are copied from the original location ${OUTPUT_DIR}. some kind of workdaround
    ...                 to get the log.html file linked to the current script execution with ssh performed on the own
    ...                 VM where the script is launched. Moreover, the copy linux command has to be launched after the
    ...                 end execution of the robot script to be able to retrieve the relevant output files as they are
    ...                 created when the robot script ends.
    ...                 arguments:
    ...                                  ${test_vm_username} = username of the VM where the script is launched
    ...                                  ${test_vm_password} = password of the VM where the script is launched
    ...                 Author: EricBP
    ...                 Update scroquet 23/03/2020: Add Close Connections SSH (process might still run in case of failures)
    ...                 Updated Abderrahmane NEZROUK 12/01/2020
    [Arguments]         ${RestoreInitConf}=True
    append to file      ${suite_journal}    ${PREV TEST NAME}:::${PREV TEST STATUS}
    remove directory    /home/localuser/tempconfig      true

    # Eric VG  2020-01-21
    Run Keyword If     '${RestoreInitConf}'=='True'     Restore Initial Configuration

    run keyword and continue on failure      configuration.Close Connections SSH

    Start Process       sleep 120 && cp ${OUTPUT_FILE} ${suite_dir}           shell=True
    Start Process       sleep 120 && cp ${LOG_FILE} ${suite_dir}              shell=True
    Start Process       sleep 120 && cp ${REPORT_FILE} ${suite_dir}           shell=True

Save suite logs files
    [Documentation]     allows to save the output files: logs.html, output.xml, report.html in the suite result directory.
    ...                 arguments:
    ...                                  ${test_vm_username} = username of the VM where the script is launched
    ...                                  ${test_vm_password} = password of the VM where the script is launched
    ...                 Author: Abderrahmane NEZROUK 15/04/2021
    [Arguments]         ${RestoreInitConf}=True

    # Kill all old geckodriver running process
    ${cmd}      Set Variable    pkill -9 geckodriver
    ${resp}     Run             ${cmd}

    remove directory    /home/localuser/tempconfig      true
    Run Keyword If     '${RestoreInitConf}'=='True'     Restore Initial Configuration

    Start Process       sleep 120 && cp ${OUTPUT_FILE} ${suite_dir}           shell=True
    Start Process       sleep 120 && cp ${LOG_FILE} ${suite_dir}              shell=True
    Start Process       sleep 120 && cp ${REPORT_FILE} ${suite_dir}           shell=True

Save Test report files
    [Documentation]     update ${suite_journal} and close connexion
    ...                 Author: Abderrahmane NEZROUK 15/04/2021

    append to file      ${suite_journal}    ${PREV TEST NAME}:::${PREV TEST STATUS}

    run keyword and continue on failure      configuration.Close Connections SSH


Check if test already run
    [Arguments]      ${t}   # ${specificfile}=none
    [Documentation]     Check in Suite journal if one of input test list has been already run.
    ...                 If so, old logs are copied in new folder.
    ...                 If old test passed, so new one is marked Passed.
    ...                 If old test failed, ??? (should run only analysis part of test) TO BE MANAGED BY TEST
    ...                 Author: DenisV
    @{splitparam}           Split String    ${t}   ;
    :FOR                    ${element}  IN  @{splitparam}
    \                       ${resp}         Run             cat ${suite_journal} | grep -i .*${element}.*:::PASS
    \                       ${m}            get regexp matches      ${resp}     (.*):::
    \                       ${d}            Run keyword if  $m      List Directory         ${suite_dir}    *${element}*
    \                       ${lpath}        set variable            ${suite_dir}/${d}[0]
    \                       Run     cp -R ${lpath}/* ${res_path}
    \                       Append To File     ${suite_journal}    Log retrieve from test : ${lpath}
    \                       Run keyword and ignore error      configuration.Close Connections SSH
    \                       Pass Execution     Test implicitly passed by ${lpath}

    :FOR                    ${element}  IN  @{splitparam}
    \                       ${resp}         Run             cat ${suite_journal} | grep -i .*${element}.*:::FAIL
    \                       ${m}            get regexp matches      ${resp}     (.*):::
    \                       ${d}            Run keyword if  $m      List Directory         ${suite_dir}    *${element}*
    \                       ${lpath}        set variable            ${suite_dir}/${d}[0]
    \                       Run     cp -R ${lpath}/* ${res_path}
    \                       Append To File      ${suite_journal}    Log retrieve from test : ${lpath}
    \                       set test variable       ${tcexist} ${lpath}
    \                       Exit For Loop IF    "${lpath}" != None

    [Return]        ${tcexist}

Implicite passed
    [Arguments]      ${test}
    Append to file      ${suite_journal}    Test implicitly PASSED=${test}:::${res_path}\n

Check test already passed
    [Arguments]      ${test}
    ${resp}         Run     cat ${suite_journal} | grep -i 'Test implicitly PASSED=.*${test}.*:::.*'
    ${lpath}        get regexp matches      ${resp}     .*:::(.*)   1
    return from keyword if      not ${lpath}     1
    Run     cp -R ${lpath}[0]/* ${res_path}
    Append To File      ${suite_journal}    Log retrieve from test : ${lpath}
    set test variable  ${partialstatus}    fullypassed
    Pass Execution  Test implicitly passed by ${lpath}

Check implicit test passed
    [Arguments]      ${test}
    ${content}  get file   ${suite_journal}
    ${status}  evaluate    'Test implicitly PASSED=${test}:::' in """${content}"""
    run keyword if   ${status}
    ...  Pass Execution  Implicite Pass
    ...  ELSE  fail  Implicite Failed
