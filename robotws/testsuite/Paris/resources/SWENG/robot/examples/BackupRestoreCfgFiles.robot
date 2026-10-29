*** Settings ***
Documentation                   This file contains keywords to check that the "original" file was correctly backup
...                             the compare its content with the restored file

Resource                            ../Tools.robot
Resource                            ../Connect.robot
Resource                            ../WtsCfgConfig.robot
Resource                            ../Backup.robot
Resource                            ../Scf.robot
Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py
Library                             ../../python/Backup.py


*** Variables ***

${TestData}                            SWENG CI TEST
${TestDataForTextFile}                 \\n\# ${TestData} \#
${TestDataForXmlFile}                  \\n<!-- ${TestData} -->
${PmTestPeriod}                            5min

*** Keywords ***

Check Restored Config File
    [Documentation]                 Check that the "original" file was correctly backup the compare its content
    ...                             with the restored file

    [Arguments]                     ${fileDesc}

    ${fullPath}                     Set Variable                            ${fileDesc.path}/${fileDesc.fileName}
    ${backupPath}                   Set Variable                            ${fileDesc.path}/${fileDesc.fileName}${ORI_EXT}

    # check file type

    Dated log                       \tCheck:<F>.ori has the good type
    ${fileType}                     Get File Type                        host=${fileDesc.host}
    ...                             path=${backupPath}
    Should be equal                 ${fileType}                          ${fileDesc.type}

    # Currently, there is no way to check "link" content (as for "iphy.xml", the backup file was "new_iphy.xml.ori" and
    # the file content comparison was done with "iphy.xml.ori" file

    Return From Keyword If          '${fileType}'=='${TYPE_LINK}'

    # Check file content

    Dated log                       \tCheck diff <F> <F>.ori is null
    ${alias}                        SSH Connect                             ${fileDesc.host}

    ${diffStr}                      Backup CMD                              alias=${alias}
    ...                             command=diff ${fullPath} ${backupPath} | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              0


Get File Type
    [Documentation]                 Get the type (FILE or LINK) of the provided "path"
    [Arguments]                     ${host}                                 ${path}
    ${status}                       File status                             host=${host}
    ...                             path=${path}
    Dated log                       \t\tStatus[${path}]:Type=${status.type} Linked=${status.linked}

    ${fileType}                     Set Variable If                         '${status.type}'=='FILE'
    ...                             ${TYPE_FILE}
    ...                             ${TYPE_LINK}

    [Return]                        ${fileType}


UpdateGnbSwconfigFile
    [Documentation]                 Update swconfig.txt on GNB with some extra comments at the end of files
    #${fd}                           Set Variable                                                    ${FD_GNB_SWCONFIG}
    ${fd}                           getFileDescByName                                               name=TGNB0_SWCONFIG
    ${filePath}                     Set Variable                                                    ${fd.path}/${fd.fileName}
    ${alias}                        SSH Connect                                                     ${fd.host}
    Backup CMD                      command=echo -e \"${TestDataForTextFile}\" >> ${filePath}       alias=${alias}


Update Config Files
    [Documentation]                 Update swconfig.txt on AP and GNB with some extra comments at the end of files
    ...                             Update WTS .cfg file (basic_wts_step2.cfg) on the VM with some extra comments at the end of file
    ...                             Remark: no need to update WTS .xml file as it's not used anymore

    # Adding comments at the end of AP swconfig.txt file
    ${fd}                           getFileDescByName                                               name=AP_SWCONFIG
    ${filePath}                     Set Variable                                                    ${fd.path}/${fd.fileName}
    ${alias}                        SSH Connect                                                     ${fd.host}
    Backup CMD                      command=echo -e \"${TestDataForTextFile}\" >> ${filePath}       alias=${alias}

    # Adding comments at the end of GNB swconfig.txt file (not applicable for AIC)
    Run Keyword if                  not ${isAIC}                                                    UpdateGnbSwconfigFile
    ${fd}                           getFileDescByName                                               name=AP_PHY_XML
    ${filePath}                     Set Variable                                                    ${fd.path}/${fd.fileName}
    ${alias}                        SSH Connect                                                     ${fd.host}
    Backup CMD                      command=echo -e \"${TestDataForXmlFile}\" >> ${filePath}        alias=${alias}


Check Restored Config Files
    FOR    ${fd}    IN    @{FD_ALL}
        Dated Log    "Checking ${fd.path}/${fd.fileName}
        Check Restored Config File    fileDesc=${fd}
    END


Update Scf And Perform Full Commissioning
    IF          ${isAic}
                Aic Update Scf And Perform Full Commissioning
    ELSE
                Classical Update Scf And Perform Full Commissioning
    END


Classical Update Scf And Perform Full Commissioning
    [Documentation]          Donload current SCF, update some data (which should not cause any side effect on subsequent tests)
    ...                      then perform full comissionning and ait for GNB to come back properly

    # get the current SCF

    Dated Log                Download SCF ...
    ${scfPath}               OAM Get SCF File                        file=sweng_ci_scf_1.xml

    # update "location" parameter in the SCF

    Dated Log                Update SCF ...
    ${apeqmDistName}         Set Variable                            MRBTS-${MRBTS_ID}/EQM-1/APEQM-1
    SCF StartSession         scf_file=${scfPath}
    SCF Set element          dist_name=${apeqmDistName}
    ...                      element_name=location
    ...                      element_value=***** Planet Mars ****
    # for PM
    ${dist_name}       Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    SCF Set element    dist_name=${dist_name}    element_name=reportingIntervalPm   element_value=${PmTestPeriod}
    SCF StopSession          scf_file=${scfPath}

    # commissioning the updated SCF

    Dated Log                Commissioning SCF ...
    OAM Perform Full Commissioning    ${scfPath}

    # If gNB was rebooted after re-commissioning, wait until it's ready again.
    Airscale Wait for Ready    ${GNB_DU}
    sleep                      60s


Aic Update Scf And Perform Full Commissioning
    [Documentation]          Donload current SCF, update some data (which should not cause any side effect on subsequent tests)
    ...                      then perform full comissionning and ait for GNB to come back properly

    # get the current SCFs, the results files are ${SCF_SETUP_PATH} and  ${SCF_CU_SETUP_PATH}
    Dated Log                Download SCFs ...
    OAM Get SCF Files

    Dated Log                Update SCF ...

    # Create temporary SCFs

    ${duScf}                 Set Variable                            ${SCF_SETUP_PATH}.tmp
    run                      cp ${SCF_SETUP_PATH} ${duScf}

    ${cuScf}                 Set Variable                            ${SCF_CU_SETUP_PATH}.tmp
    run                      cp ${SCF_CU_SETUP_PATH} ${cuScf}

    # update "location" parameter in the SCF
    SCF StartSession         scf_file=${duScf}                       second_scf_file=${cuScf}

    ${apeqmDistName}         Set Variable                            MRBTS-${MRBTS_ID}/EQM-1/APEQM-1
    SCF Set element          dist_name=${apeqmDistName}
    ...                      element_name=location
    ...                      element_value=***** Planet Mars ****
    ...                      aicListEntity=vduvcu
    ...                      scope=both
    ...                      bestEffort=${True}

    # for PM
    ${dist_name}             Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    SCF Set element          dist_name=${dist_name}
    ...                      element_name=reportingIntervalPm
    ...                      element_value=${PmTestPeriod}
    ...                      aicListEntity=vduvcu
    ...                      scope=both
    ...                      bestEffort=${True}

    SCF StopSession          scf_file=${duScf}    second_scf_file=${cuScf}

    # commissioning the updated SCF

    Dated Log                Commissioning SCF ...

    OAM Perform Full Commissioning          scf_file=${duScf}        oam=${GNB_DU.oam}

    OAM Perform Full Commissioning          scf_file=${cuScf}        oam=${GNB_CU.oam}

    Wait Vcu And Vdu Available

    # set suite variable for other tests using SCF

    Set Suite Variable       ${MODIFIED_SCF_SETUP_PATH}              ${duScf}

    Set Suite Variable       ${MODIFIED_SCF_CU_SETUP_PATH}           ${cuScf}


Classical Check Restored Scf
    # Check backup was done
    ${initialScf}             Set Variable                           ${SCF_SETUP_PATH}
    Run Keyword If            '${initialScf}'=='${EMPTY}'            Run Keywords
    ...                       Dated Log                              Initial backup SCF does not exist --> no check can be done
    ...                       AND                                    Return From Keyword

    # get the current SCF
    Dated Log                 Download SCF ...
    ${currentScf}                OAM Get SCF File                       file=sweng_ci_scf_2.xml

    # Compare the downloaded SCF with the initial backup SCF
    # If more than 8 lines in diff --> SCF was changed (TBC !)
    ${nbDiff}                 Run                                    diff ${currentScf} ${initialScf} | wc -l
    ${nbTestData}             Run                                    grep ${TestData} ${currentScf} | wc -l
    Run keyword if            ${nbDiff}>${8} or ${nbTestData}>0      Run keywords
    ...                       Dated log                              The original SCF was not correctly restored
    ...                       AND                                    Return From Keyword    ${False}

    # SCF was correctly restored
    Dated Log                 SCF was correctly restored


Aic Check Restored Scf
    Dated Log                 KW to be implemented


Check Restored Scf
    IF            ${isAic}
                    Aic Check Restored Scf
    ELSE
                    Classical Check Restored Scf
    END
