*** Settings ***
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Resource          ../../resources/DevHZ5_resource.robot
Library           ./lib/modify_golden_scfs.py

*** Variables ***
${PATH_SPECIFIED}    ${EMPTY}
@{PARAMS_TO_MODIFY}
...    @{PARAMS_FOR_CB008140}

@{PARAMS_FOR_CB008140}
...    NRBTS/NRDU-1:actInterGnbCa=DLOnly
...    NRBTS:iGnbCaXnCfUpBackOffTmr=0
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=5
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1

*** Test Cases ***
Modify SCF Files
    ${config_path}=    decide configurate files path
    ${golden_path}=    set variable if    '${PATH_SPECIFIED}'==''    ${config_path}    ${PATH_SPECIFIED}
    log    modify all scf files under ${golden_path}    level=WARN
    log to console    \n
    modify_golden_scf_files    ${golden_path}   ${PARAMS_TO_MODIFY}

*** Keywords ***
Suite Setup
    Common Suite Setup
    _Get Iphy Info

Suite Teardown
    Common Suite Teardown
    Execute Cmd On Pc    rm -rf ${SAVE LOG DIRECTORY}
