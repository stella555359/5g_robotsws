*** Settings ***

Documentation
...    Author: jun.6.ma
...    Contact: jun.6.ma@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for 25R2 CDRT for CB010846-SR-D 23 l1soc reset uncontrolled case

Force Tags
...      TRUNK             #Tag Item
...      RAN_RD_VRF_HAZ1             #Competence Area
...      RAN_RD_VRF_HAZ1_T02     #Organization
...      TA_LEVEL_23                 #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22, TA_LEVEL_23]

Test Timeout           6h

Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM

Resource    ../../../Resources/Classical/RRM_Common_Resource.robot
Resource    ../../../T02/Common_Case/common_resource_new.robot
Library     taf.sw.scout    WITH NAME    scout
Library     SSHLibrary
Library     Collections

*** Variables ***

${TestLine_Name}          10_5_UTESRAN028T36955
${SELECTED_SW_VERSION}    SBTS00_ENB_9999_241016_000001
&{UE_INFO}                R3CRC011CQD=350166285465436    RFCNC0RNFJH=353158260231187
${serials}                R3CRC011CQD
${host}    10.56.201.215
${usrname}      toor4nsn
${pwd}      oZPS0POrRieRtu
${fingerprint}            fingerprint
${yes_no}                 yes
#${RU_IP}        172.22.56.2       # eCPRI RU AZHL  SN:YK203400037
${RU_SN}        YK203400037

*** Test Cases ***
Case_CB010846-D#23_eCPRI_RU_resiliency_to_BTS-DU_L1Soc_reset-Uncontrolled_case
    [Tags]    QC_145818    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     Author: jun.6.ma@nokia-sbell.com
    ...     this is the case run in TMO-58 testline whose BTS ID is 37548 for CB010846-SR-D L1SoC_Reset_Uncontrolled
    ...     this is the case run in AZHL for CB010846-SR-D L1SoC_Reset_Uncontrolled with FD: 2087
    [Setup]    Common Test Setup For RRM
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    ${uptime_before}     Check_RU_Uptime

    log to console    \n Start to perform l1soc reset
    L1SoC_Reset_Uncontrolled
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n L1SoC reset Done and Cells onAir
    ${uptime_after}     Check_RU_Uptime

    ${uptime_compare}=      Evaluate    ${uptime_after} - ${uptime_before}
    IF      ${uptime_compare}>0 or ${uptime_compare}==0
        log to console      \n >>>RU not reset.
    ELSE
        log to console      \n >>>RU reset, need to analysis !!!
    END

    sleep    10s
    log to console    \n Start to collect Snapshot
    Collect Coam Snapshot    name=RU_Resiliency_CB010846-SR-DU_L1Soc_reset-CDRT
    log to console    \n Snapshot collected... Case END
    [Teardown]    Teardown_for_OAM

*** Keywords ***
Teardown_for_OAM
    Get SCF Internal Id By Scout    no_ute=False
    Common Test Teardown For RRM

L1SoC_Reset_Uncontrolled
    ${cmd1}    Set Variable    ssh toor4nsn@fct-4a
    ${cmd2}    Set Variable    ssh toor4nsn@fsp5s2icom  # bsh 1:2
    ${cmd3}    Set Variable    ps aux | grep l1_application
    ${fingerprint}      Set Variable    fingerprint
    ${yes_no}       Set Variable    yes

    #ps -eaf | grep -i l1_application
    SSHLibrary.Open Connection    ${host}
    SSHLibrary.Login    ${usrname}    ${pwd}
    SSHLibrary.Write    ${cmd1}
    ${output0}    Wait Until Keyword Succeeds    5x    5s    SSHLibrary.Read Until    Password:
    SSHLibrary.Write    ${pwd}
    Wait Until Keyword Succeeds    3x    3s    SSHLibrary.Read Until     >
    sleep   5s

    # to ssh into right bbmod-loki 1:2
    SSHLibrary.Write    ${cmd2}
    ${output0}      SSHLibrary.Read     delay=5s
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output0}    ${fingerprint}
    Run Keyword IF      ${contains}
    ...     SSHLibrary.Write    ${yes_no}
    ...     ELSE    log to console      \n login to the 2nd core's 1st BBMOD's 3rd loki
    sleep   5s
    SSHLibrary.Write    ${pwd}
    sleep   5s
    #Wait Until Keyword Succeeds    3x    1s    SSHLibrary.Read Until    :~#
    SSHLibrary.Write    ${cmd3}
    ${output}    SSHLibrary.Read    delay=2s
    #here use  ${output}   SSHLibrary.Execute Command    ${cmd3} is incorrect, the output is not actually what output after cmd3
    log to console      ${output}
    ${list}    split string    ${output}    root         # output is string, split with 'root', take the 2nd one
    ${PID0}=    Get Substring    ${list}[1]    0    12   # the first 12 str from ${list}
    ${PID}=    Remove String    ${PID0}    ${SPACE}      # remove the space
    log to console      \n the first process ID is ${PID}
    SSHLibrary.Write    kill -11 ${PID}
    sleep       60s

    SSHLibrary.Close Connection

Check_RU_Uptime
    ${cmd0}    Set Variable    ssh toor4nsn@fct-4a  #oZPS0POrRieRtu
    ${cmd1}    Set Variable    lxc-attach -n 0x2018
    #${cmd2}    Set Variable    ssh serviceuser@${RU_IP}
    ${cmd3}    Set Variable    uptime
    ${cmd4}    Set Variable    cd /rom/config
    ${cmd5}    Set Variable    cat FRIps.txt

    ${fingerprint}      Set Variable    fingerprint
    ${yes_no}       Set Variable    yes
    ${RRU_PWD_input}     Set Variable    password
    ${RRU_AZHL_PWD}      Set Variable    wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=

    # to connect to S1 IP that is the left SMOD
    SSHLibrary.Open Connection    ${host}
    SSHLibrary.Login    ${usrname}    ${pwd}
    sleep   10s

    # to ssh into the right SMOD with ssh toor4nsn@fct-4a
    SSHLibrary.Write    ${cmd0}
    ${output0}      SSHLibrary.Read     delay=5s
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output0}    ${fingerprint}
    Run Keyword IF      ${contains}
    ...     SSHLibrary.Write    ${yes_no}
    ...     ELSE    log to console      \n login to the 2nd core, the right SMOD
    sleep   5s
    SSHLibrary.Write    ${pwd}

    # to get the RU IP
    ${RMOD_params}    coam.get_managed_objects    RMOD_L    timeout=600s     connection=COAM
    ${RU_IP}   Set Variable
    FOR    ${RMOD}    IN    @{RMOD_params}
        ${RU_IP}    Set Variable If    "${RMOD["parameters"]["serialNumber"]}"=="${RU_SN}"    ${RMOD["parameters"]["ipAddress"]}   ${RU_IP}
        Exit For Loop If    "${RMOD["parameters"]["serialNumber"]}"=="${RU_SN}"
    END
    log to console      \n the IP of RU AZHL with ${RU_SN} is ${RU_IP}

    # to ssh into the RU
    ${cmd2}    Set Variable    ssh serviceuser@${RU_IP}
    sleep   5s
    SSHLibrary.Write    ${cmd1}
    sleep   5s
    SSHLibrary.Write    ${cmd2}     #login RU with the ip got from above ${RU_IP}, in case RU ip changed anyhow
    sleep   5s

    # when doing ssh the RU, sometimes there is inqure yes or no and password, sometimes directly ask for password
    ${output1}      SSHLibrary.Read     delay=5s
    ${contains2}=    Run Keyword And Return Status    Should Contain    ${output1}    ${RRU_PWD_input}
    IF      ${contains2}
        SSHLibrary.Write    ${RRU_AZHL_PWD}
    ELSE
        SSHLibrary.Write    ${yes_no}
        SSHLibrary.Write    ${RRU_AZHL_PWD}
    END

    # to check the RU's uptime
    Wait Until Keyword Succeeds    3x    5s    SSHLibrary.Read Until Regexp    serviceuser@stratix
    SSHLibrary.Write    ${cmd3}
    ${output}   SSHLibrary.Read     delay=5s
    # ${output}   SSHLibrary.Execute Command    ${cmd3}
    # here use SSHLibrary.Write and SSHLibrary.Read will have quite big that is all after ssh, but not just the output of cmd3
    log to console      \n The output of uptime is: \n ${output}

    # to get the uptime number from uptime output string
    ${uptime_right}     Fetch From Right    ${output}    up                         # get the sub-string after 'up'
    ${uptime_1}    split string    ${uptime_right}    ,
    ${uptime_2}    Set Variable    ${uptime_1}[0]
    IF      'day' in "${uptime_2}"
	    ${uptime_day}       Fetch From Left     ${uptime_2}      day             # day number
	    ${uptime}=      Evaluate    ${uptime_day}*24*100
	    # if the uptime bigger than 1day
	    # the hours and mins will have different show but hard to judge: '1day, 59min,' or'2 day,  9:37'
	    # here is simple way: as if RU reset then the RU uptime won't have 'day', then we can know whether the RU reset or not base on it
	    # no matter how the hour and mins show, here will be removed, just keep the day info, and *24*100
    ELSE IF     'min' in "${uptime_2}"
	    ${uptime_min}      Fetch From left    ${uptime_2}     min        # the uptime is less than 1hour, only xx min, then use this one
	    ${uptime}=      Evaluate    ${uptime_min}
    ELSE
	    #${uptime_hour}      Fetch From left    ${uptime_2}     :        # hour
	    #${uptime_min}      Fetch From right    ${uptime_2}     :        # minute
	    #${uptime}=      Evaluate    ${uptime_hour}*100+${uptime_min}
	    # if the uptime is small than 1day, directly show as 23:59 likewards, then it can be simply output in draft as 2359

        ${uptime}     Evaluate    '${uptime_2}'.replace(':', '')
	    # this is most simple one, the {uptime_2} here is 23:59, then just remove : by using .pleace, output 2359
    END
    ${uptime_num}     Convert To Number       ${uptime}

    SSHLibrary.Close Connection
    [Return]        ${uptime_num}