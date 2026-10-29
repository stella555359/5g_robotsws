*** Settings ***

Documentation                       Suite description

Resource                            ../GenericTest.robot
Resource                            ../Tools.robot
Resource                            ../Setup.robot
Resource                            ../Restart.robot
Resource                            ../CallSetup.robot
Resource                            ../Capture.robot
Resource                            ../Sherpa.robot
Resource                            ../Traffic.robot
Resource                            ../Scf.robot
Resource                            BackupRestoreCfgFiles.robot
Resource                            PMNonRegression.robot
Library                             ../../../../RRM/ET/resources/python/luashark_tools.py
Library                             luashark_tools.analyzer       WITH NAME       analyzer
Variables                           NonRegression.py

Suite Setup                         Suite setup
# Suite Teardown                      Suite Teardown

Test Teardown                       Test Teardown

*** Test Cases ***

Test OK
    Dated log                       Start

Test KO
    Dated Log                       Test KO
    ${tmp_test_name}                replace string                  ${TEST_NAME}    ${SPACE}    ${EMPTY}
    ${sosReportExpected}            set variable                    ${LOG_PATH}/SosReport_${tmp_test_name}.tgz
    Dated Log                       Check that Sos Report is created here:${sosReportExpected}
    Test Teardown if Fail
    ${alias}                 SSH Connect           ${HOST_EPCSIM}
    ${sos_exists}=           SSH Exec              command=test -f ${sosReportExpected} && echo -n "ok" || echo -n "nok"
    ...                                            alias=${alias}
    Should be equal                 ${sos_exists}         ok
