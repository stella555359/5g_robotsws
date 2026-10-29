*** Settings ***
Documentation   This library includes the keywords for killing all running iperf process on Appservers and UE PC
...             Team: 'MN 5G&SC 5G Pz ULM 2 SqdGp63'
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com'


Resource    ../../resources/Common/connect.robot
Resource    ../../resources/Common/testline.robot

Library    taf.transport.ssh                  WITH NAME    ssh


*** Keywords ***
Kill all iperf processes on Appserver and UE PC
    Kill all running iperf processes on Appserver
    Kill all iperf processes on UE PC


Kill all running iperf processes on Appserver
    [Documentation]   :Author: Fiordi Doma. Edited by: Mathis Rost.
    ...     Setup ssh connection to the Appserver
    ...     Run the command to check for any running
    ...     iperf process(es)
    ...     Kill the iperf process(es) found

    ${appserv}=    connect.Connect to core application server    ${tl.appserver}
    ${output}=    ssh.execute    ps -ef | grep iperf | grep -v grep    connection=${appserv}

    IF    """${output}""" != '${EMPTY}'
    ...    ssh.execute    sudo pkill -9 iperf*    connection=${appserv}

    ssh.disconnect     connection=${appserv}


Kill all iperf processes on UE PC
    [Documentation]   :Author: Fiordi Doma
    ...     Get the number of the available UE PCs in the TL
    ...     Setup ssh connection to the UE PC(s)
    ...
    ...     :param UEid: (optional) the specific UE id on which
    ...     the user would like to kill the iperf process(es) on.
    ...     There is only one UE per UE_PC in all testlines.
    ...
    ...     Identify the UE type (Askey, Qualcomm...) through the iperf path
    ...     and run the corresponding command to identify running iperf process(es)
    ...     for the UE type
    ...     Kill the iperf process(es) found
    [Arguments]    ${UEid}=${EMPTY}

    ${ue_count}=   Get Length   ${tl.ues}

    ${UE_start}    ${UE_end}=   IF   """${UEid}"""=='${EMPTY}'
    ...                         Set Variable     0          ${ue_count}    # range = all ue
    ...   ELSE IF               ${UEid}>${ue_count-1}
    ...                         Fail  '${UEid}' isn't defined
    ...   ELSE                  Set Variable     ${UEid}    ${UEid+1}    # range = only given ue

    FOR   ${UE}   IN RANGE   ${UE_start}   ${UE_end}
        ${uePC}=       connect.Connect to UE PC   ${UE}
        ${output}=     ssh.execute   tasklist | findstr "iperf"         connection=${uePC}
        ${output2}=    ssh.execute   adb shell ps -ef | findstr iperf   connection=${uePC}

        IF      "iperf" in """${output}"""
        ...   ssh.execute   Taskkill /IM iperf* /F          connection=${uePC}

        IF      "iperf" in """${output2}"""
        ...   ssh.execute   adb shell "su 0 pkill iperf*"   connection=${uePC}

        ssh.disconnect      connection=${uePC}
    END
