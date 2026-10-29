*** Settings ***
Documentation
...   Author: gcao
...   Contact: ge.cao@nokia-sbell.com



*** Keywords ***
# ------------------------------------Get Simple Parameters Of Current Plan For VCU  ----------------------------------
Common Test Case Teardown with Scout
    [Arguments]    ${TESTLINE_NAME}
    Common Test Teardown For RRM
    Get SCF Internal Id By Scout    bts_id=${TESTLINE_NAME}


Custom Suite Teardown For RRM
    Common Suite Teardown For RRM
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -name '*napshot*.zip'
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}

    ${cmd_new}=    Set Variable    ${cmd} -delete
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}

Scout_cli start
    Run Keyword And Ignore Error  OperatingSystem.Run
    ...        source /home/ute/.pyenv/versions/3.10.12/envs/agent_scout_env/bin/activate
    ${cmd}    catenate
    ...    pip install -U --trusted-host
    ...    artifactory-espoo1.int.net.nokia.com -i
    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/api/pypi/pypi-scout-local/simple
    ...    scout-cli
    OperatingSystem.Run    ${cmd}
    ${cmd}    catenate    scout-cli testline start --testline-ip 192.168.255.129 --config
    ...    /home/ute/testline_init_results/agent_scout/results/config_files/scout.conf
    OperatingSystem.Run    ${cmd}

