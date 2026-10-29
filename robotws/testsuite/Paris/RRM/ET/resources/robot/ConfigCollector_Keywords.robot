*** Settings ***

Documentation
...               Dependences (user/contributor):
...               user: testsuite/Paris/RRM/ET/CB009384/resources/robot/CB009384_SR_A_RedCap_UE_20Mhz_SA_FDD_n1_keywords.robot
...               user: <your int>

Resource           ../../../../resources/SWENG/robot/Oam.robot
Resource           ../../../../resources/SWENG/robot/Connect.robot


*** Keywords ***

Collect
    [Documentation]     Scf collector

    [Arguments]          ${param}
    ${FTS_SCF}           Set Variable    ${param}.xml
    #Dated Log  FTS_Debug ${FD_ALL}

    ${timestamp}                    Get Current Date    result_format=%Y%m%d_%H%M%S%f
    Dated Log  Collect of ${FTS_SCF} => Time stamp: ${timestamp}

    Set Suite Variable              ${LOG_PATH_fts}
    ...                             ${OUTPUT DIR}/Logs/bkp_${param}_${timestamp}
    Create Directory                ${LOG_PATH_fts}

    OAM Get SCF File                 dir=${LOG_PATH_fts}    file=scfc-${FTS_SCF}
    Backup Files FTS                ${FD_ALL}    ${LOG_PATH_fts}

Backup Files FTS
    [Documentation]               Backup all configuration files (as described in listFileDesc)
    ...                           used also by testsuite/Paris/RRM/ET/CB009384/resources/robot/CB009384_SR_A_RedCap_UE_20Mhz_SA_FDD_n1_keywords.robot
    ...                           
    [Arguments]                     ${listFileDesc}=${FD_ALL}    ${targetDir}=none
    FOR    ${fd}   IN               @{listFileDesc}
        #    Dated log                Backup:${fd.name} ${fd.host.alias}:${fd.path}/${fd.fileName}
           Backup Type File FTS     ${fd}    ${targetDir}
    END

Backup Type File FTS
    [Documentation]                 Backup a file (type is a file) into an <name>.ori one and create a link on a <name>.<testSuite>
    ...                             which is a copy of <name>.ori
    [Arguments]                     ${fileDesc}    ${targetDir}
    ${alias}                        SSH Wait For Connect                    ${fileDesc.host}
    ${backupPath}                   Get Backup Path                         ${fileDesc}
    ${status}                       File Status
    ...                                 host=${fileDesc.host}
    ...                                 path=${fileDesc.path}/${fileDesc.fileName}

    ${qualif}                       set variable if    '${alias}'=='AP_DU_C1_M'     AP-
    ...                                                '${alias}'=='TGNB_DU0_C2_M'    5gnb-        wts-

    run keyword if                  '${status.type}'=='FILE'
    ...                             SSH Download File     ${fileDesc.host}
    ...                                                   ${fileDesc.path}/${fileDesc.fileName}
    ...                                                   ${targetDir}/${qualif}${fileDesc.fileName}
    ...     ELSE                     SSH Download File    ${fileDesc.host}
    ...                                                   ${fileDesc.path}/${fileDesc.fileName}
    ...                                                   ${targetDir}/${qualif}${fileDesc.fileName}

TestSuiteFolderCreation
    [Documentation]    create test suite folder
    ...                "Step" arg help eventally to tag the repository as you need 
    [Arguments]        ${step}=${None}
    ${timeStamp}          get current date    result_format=%Y%m%d_%H%M%S

    Set Suite Variable    ${testSuiteDir}    ${OUTPUT DIR}/Logs/${step}${timeStamp}
    #Cette expression régulière va retirer tous les caractères qui ne sont pas des lettres (majuscules et minuscules), 
    #des chiffres, des caractères de soulignement (_), des points (.), des tirets (-) et des slashs (/). Ces caractères
    #sont couramment utilisés pour les noms de fichiers et de répertoires en Linux.
    ${testSuiteDir}       Replace String Using Regexp    ${testSuiteDir}    [^a-zA-Z0-9/_.-]      ${EMPTY}
    Dated log             \n out of regex: ${testSuiteDir}

    create directory      ${testSuiteDir}

    Set Suite Variable    ${ConfigDir}        ${testSuiteDir}/Config_${timeStamp} 
    Create Directory      ${ConfigDir}
    Set Suite Variable    ${logsDir}          ${testSuiteDir}/logs 
    Create Directory      ${logsDir}
    Run Keyword If        ${VMmonitoring}     Run keywords
    ...                                       Set Global Variable   ${MoniDir}          ${testSuiteDir}/MONITORING
    ...                   AND                 Create Directory      ${MoniDir}

Collect_Configfiles
    [Documentation]                 Save current scf/iphy/swconfig/basic files used for the test in ${testSuiteDir}
    [Arguments]                     ${step}=${None}
    Dated Log                       *** CollectConfigfilesUsedForTest step

    ${target}             set Variable    ${ConfigDir}
    Run Keyword If        '${step}' != '${None}'    set Variable          ${target}    ${target}/${step}
    Scf Backup             ${target}
    Backup Files FTS      ${FD_ALL}     ${target}

    #previou KW collect only original .cfg, not cfg modified by the test => correction of this:
    SSH_SessionManagment
    SSH Exec              rm ${target}/*.cfg                                                          alias=${alias_epcsim}
    ${cmd}                set variable    cp -p ${tl.core.dir_path}/${tl.core.cfg_filename} ${target}/${tl.core.cfg_filename}
    Dated Log             ${cmd}
    SSH Exec              ${cmd}                                                                         alias=${alias_epcsim}

    Set Suite Variable    ${LOG_PATH_bu}      ${LOG_PATH}
    Set Suite Variable    ${LOG_PATH}         ${target}
    # Get Data From Gnb TargetBD File           card_name=${param.RU}
    Set Suite Variable    ${LOG_PATH}         ${LOG_PATH_bu}

Scf Backup 
    [Documentation]                 Save the current SCF
    [Arguments]    ${dir}=${LOG_PATH}
    ${timeStamp}       get current date    result_format=%Y%m%d_%H%M%S
    ${g_backup_scf}    OAM Get SCF File    dir=${dir}    file=SCF_ofTheTest_${timeStamp}.xml
    Set Suite Variable    ${g_backup_scf}
    Dated Log    SCF backup file = ${g_backup_scf}

SSH_SessionManagment
    ${alias_epcsim}                      SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable                   ${alias_epcsim}
    Dated Log                            alias sur ssh wait For Connect ${alias_epcsim}

