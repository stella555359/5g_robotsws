*** Settings ***
Resource   Common.robot

*** Variables ***
${taf_git}   https://gitlabe1.ext.net.nokia.com/5gpci/CIT/Pipelines/raw/master/workflows/InstallPackageOnly/common/init_taf.sh
${taf_private_token}   P4rj-r7_NZZmRJZZaBTk

*** Keywords ***
UUF Install TAF
    @{install_taf_sequence}   Create List   @{ALL_ENB_LIST}
    FOR   ${testline}   IN   @{install_taf_sequence}
        Single Testline Install TAF   testline=${testline}
    END

Single Testline Install TAF
    [Arguments]   ${testline}
    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    FOR   ${common_unit}   IN   @{common_units}
        ${common_unit_index}   Set Variable   ${common_unit['index']}
        ${test_pc_addr}   Set Variable   ${common_unit['test_pc_addr']}
        ${test_pc_username}   Set Variable   ${common_unit['test_pc_username']}
        ${test_pc_password}   Set Variable   ${common_unit['test_pc_password']}
        ${status}   Run Keyword And Return Status
        ...   Single Common Unit Install TAF
        ...      test_pc_addr=${test_pc_addr}
        ...      test_pc_username=${test_pc_username}
        ...      test_pc_password=${test_pc_password}
        ...      connection=test_pc_${testline}_unit_${common_unit_index}
        run keyword if  not ${status}
        ...   Single Common Unit Install TAF
        ...      test_pc_addr=${test_pc_addr}
        ...      test_pc_username=${test_pc_username}
        ...      test_pc_password=${test_pc_password}
        ...      connection=test_pc_${testline}_unit_${common_unit_index}
    END

Single Common Unit Install TAF
    [Arguments]   ${test_pc_addr}   ${test_pc_username}   ${test_pc_password}   ${connection}
    csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${connection}
    ${python_status}   csn.File Exists   remote_path=/home/ute/CIENV/${TESTLINE_NAME}/bin/activate   connection=${connection}

    ${output}   Run Keyword If   ${python_status}
    ...   csn.Execute   command=node -v
    ...   connection=${connection}
    ...   ELSE   Set Variable   ${EMPTY}
    ${nodejs_status}   Run Keyword And Return Status   Should Contain   ${output.strip()}   v16.5.0

    ${output}   Run Keyword If   ${python_status} and ${nodejs_status}
    ...   csn.Execute   command=source /home/ute/CIENV/${TESTLINE_NAME}/bin/activate; pip list | grep taf.sbts.oam.coam.admin
    ...   connection=${connection}
    ...   ELSE   Set Variable   ${EMPTY}
    ${taf_status}   Run Keyword And Return Status   Should Not Be Empty   ${output}

    Run Keyword If   ${python_status} and ${taf_status} and ${nodejs_status}
    ...   Log To Console   TAF Lib Already Installed In ${connection}. Skip Install TAF.
    Return From Keyword If   ${python_status} and ${taf_status} and ${nodejs_status}

    Fatal Error   msg=TAF Lib Or NodeJS(v16.5.0) Not Installed in ${connection}, Please Install TAF Lib Or NodeJS(v16.5.0) Manually...

    # Log To Console   TAF Lib Not Installed in ${connection}, Start To Install TAF Lib...
    # csn.Execute   command=mkdir -p /home/ute/UUF4ALL   connection=${connection}
    # csn.Execute   command=cd /home/ute/UUF4ALL; curl ${taf_git}?private_token=${taf_private_token} -s -o init_taf.sh   connection=${connection}
    # csn.Execute   command=cd /home/ute/UUF4ALL; bash init_taf.sh /home/ute/CIENV ${TESTLINE_NAME} 3.6.10 master   connection=${connection}
    # ${output}   csn.Execute   command=source /home/ute/CIENV/${TESTLINE_NAME}/bin/activate; pip list | grep taf.sbts.oam.coam.admin
    # ...   connection=${connection}
    # Should Not Be Empty   ${output}
    # Log To Console   Install TAF Lib Finished.
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


# Download SCF Project
Download Golden SCF Project
    Log To Console   Download Golden SCF Project...
    ${scf_link}   Set Variable   git@gitlabe1.ext.net.nokia.com:SG8/golden_scf.git
    ${GOLDEN_SCF_DIR}   OperatingSystem.Join Path   ${OUTPUT_DIR}   ..   golden_scf
    Set Suite Variable   ${GOLDEN_SCF_DIR}

    ${testline_golden_scf_dir}   Set Variable   ${GOLDEN_SCF_DIR}/TL${TESTLINE_IDENTITY}
    ${golden_scf_dir_not_empty}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Be Empty   path=${testline_golden_scf_dir}
    Run Keyword If   ${golden_scf_dir_not_empty}   Log To Console   Golden SCF Project Exist, Skip Downloading.
    Return From Keyword If   ${golden_scf_dir_not_empty} and "${SUITE_NAME}"!="UUF_Precheck"

    OperatingSystem.Run    sudo rm -rf ${GOLDEN_SCF_DIR}
    ${output}    OperatingSystem.Run   git clone --depth 1 ${scf_link} ${GOLDEN_SCF_DIR} --progress --verbose
    Should Contain   ${output}   Receiving objects: 100%
    Should Contain   ${output}   Resolving deltas: 100%
    Log To Console   Download Golden SCF Project Finished.


# Check VM Space
Check VM Available Space
    Log To Console   Check VM Available Space
    ${Taf_Space}   OperatingSystem.Run   df -hx nfs -x nfs4 | grep /dev/vda2
    @{Split_Taf_Space}   Split String   ${Taf_Space}
    ${Available_Space}   Set Variable   ${Split_Taf_Space[3]}
    Log To Console    Available Size of TAF is ${Available_Space}
    Run Keyword And Ignore Error   Should Be True    ${${Available_Space[:-1]}} > ${10}
    ...   msg=[WARN] TAF Space is Less Then 10G!!


# Wait Until Keyword Succeeds, If want to exit this keyword, please return UUF_FATAL_ERROR
UUF Wait Until Keyword Succeeds
    [Arguments]   ${retry}   ${retry_interval}   ${name}   ${args}=&{EMPTY}
    ${isCount}   Evaluate   ${retry.find("times")}!=-1 or ${retry.find("x")}!=-1
    ${timeout_time}   run keyword if  not ${isCount}   Get Time   epoch   NOW + ${retry}

    ${retry}   Remove String   ${retry}   x   times   ${SPACE}
    ${loop_count}   Set Variable If   ${isCount}   ${retry}   ${100}

    FOR   ${i}   IN RANGE   ${loop_count}
        ${status}   ${return}   Run Keyword And Ignore Error   Run Keyword   ${name}   &{args}
        Run Keyword If   "${return}"=="UUF_FATAL_ERROR"   FAIL   msg=Keyword Fatal Error: ${name}

        Exit For Loop If   "${status}"=="PASS"

        ${after_time}   run keyword if  not ${isCount}   Get Time   epoch
        run keyword if  not ${isCount}   Run Keyword If   ${after_time} >= ${timeout_time}   FAIL

        Run Keyword If   ${isCount}   Run Keyword If   ${${i}}==${${loop_count} - 1}   FAIL

        Sleep   ${retry_interval}
    END
