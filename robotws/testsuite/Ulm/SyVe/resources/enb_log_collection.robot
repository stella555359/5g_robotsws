*** Settings ***

Documentation     Keywords related to log collection for eNB (used by SyVe only)
...               author: Vasileios Papoutsis
...               email: vasileios.papoutsis@nokia.com

Resource   ../../resources/Common/testline.robot
Resource   enb.robot

*** Variables ***
${P_console}         ${False}


*** Keywords ***
Save configs from all eNBs
    [Documentation]    Author: Vasileios Papoutsis
    ...             Get Config files from all eNBs and save them in ${resultConfigsDir}
    ...
    ...             Collect:
    ...             - scf
    ...
    ...             :param resultConfigsDir: Folder for config files (default Testsuite config directory)
    [Arguments]    ${resultConfigsDir}=None
    IF    '${resultConfigsDir}'=='None'
        ${resultConfigsDir}=    testline.Get test suite config directory
    END
    ${enb_num}=     Get length   ${tl.enbs}
    FOR    ${enb_id}    IN RANGE    ${enb_num}
        Save configs from eNB    enb_id=${enb_id}    resultConfigsDir=${resultConfigsDir}
    END

Save configs from eNB
    [Documentation]    Author: Vasileios Papoutsis
    ...             Get Config files from specific eNB and save them in ${resultConfigsDir}
    ...
    ...             Collect:
    ...             - scf
    ...
    ...             :param resultConfigsDir: Folder for config files (default Testsuite config directory)
    [Arguments]    ${enb_id}=${0}    ${resultConfigsDir}=None
    IF    '${resultConfigsDir}'=='None'
        ${resultConfigsDir}=    testline.Get test suite config directory
    END
    Log    Save Configs from eNB${enb_id}    console=${P_console}
    enb.Get SCF from eNB    enb_id=${enb_id}    resultDir=${resultConfigsDir}
    Log    Configs from eNB${enb_id} are saved!    console=${P_console}


