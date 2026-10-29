*** Settings ***

Documentation
...    Author: jun.6.ma
...    Contact: jun.6.ma@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for 26R1 branch CRT for CB010846-SR-D-53 capacity unit reset uncontrolled case

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
${host}                   10.56.201.215
${usrname}                toor4nsn
${pwd}                    oZPS0POrRieRtu
${fingerprint}            fingerprint
${yes_no}                 yes
#${RU_IP}                  172.22.56.2       # eCPRI RU AZHL  SN:YK203400037
${RU_SN}                  YK203400037  # eCPRI RU AZHL
#${RU_SN}        BL2236V082K

*** Test Cases ***
Case_CB010846-D#53_eCPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_reset-Uncontrolled_case
    [Tags]    QC_251336    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
     ...    Author: jun.6.ma@nokia-sbell.com
     ...    23.10.2025,jun.6.ma@nokia-sbell.com, draft
     ...    this is draft for RU resiliency via Capacity Unit crash with FID: 4383 in uncontrolled scenarios
    [Setup]    Common Test Setup For RRM
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n Site and Cells are onair
    ${uptime_before}     RRU_uptime
    log to console    \n the RU of SN: ${RU_SN}, now has uptime: ${uptime_before} --> Start to perform capacity unit reset
    Capacity_Unit_Reset_Uncontrolled
    ${status}=     Run Keyword And Return Status   Check_CellandSite_Status
    ${uptime_after}     RRU_uptime
    Run Keyword IF      '${status}' == 'False' or ${uptime_after} <= ${uptime_before}
    ...     log to console      \n >>>RU reset, need to analysis !!!
    ...     ELSE    log to console     \n>>>Case done and passed

    sleep    10s
    log to console    \n Start to collect Snapshot
    Collect Coam Snapshot    name=RU_Resiliency_CB010846-SR-DU_Capacity_Unit_reset_Uncontrolled
    log to console    \n Snapshot collected... Case END
    [Teardown]    Teardown_for_OAM

*** Keywords ***
Teardown_for_OAM
    Get SCF Internal Id By Scout    no_ute=False
    #Common Test Teardown For RRM
Check_CellandSite_Status
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR+CELL_ONAIR
Capacity_Unit_Reset_Uncontrolled
    ${cmd0}    Set Variable    ssh toor4nsn@fct-4a
    ${cmd1}    Set Variable    bsh 1:0 #ssh toor4nsn@fsp5s0icom  #bsh 1:0
    ${cmd2}    Set Variable    ps -aux | grep CCS
    ${cmd3}    Set Variable    pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe --startup=nid=0x2730'
    ${fingerprint}      Set Variable    fingerprint
    ${yes_no}       Set Variable    yes

    SSHLibrary.Open Connection    ${host}
    SSHLibrary.Login    ${usrname}    ${pwd}   # oZPS0POrRieRtu
    SSHLibrary.Write    ${cmd0}
    ${output0}    Wait Until Keyword Succeeds    5x    5s    SSHLibrary.Read Until    Password:
    SSHLibrary.Write    ${pwd}
    SSHLibrary.Write    ${cmd1}
    # to ssh into right bbmod-loki 1:0
    ${output0}      SSHLibrary.Read     delay=5s
    ${contains}=    Run Keyword And Return Status    Should Contain    ${output0}    ${fingerprint}
    Run Keyword IF      ${contains}
    ...     SSHLibrary.Write    ${yes_no}
    ...     ELSE    log to console      \n login to the 2nd core's 1st BBMOD's 1st loki
    sleep   5s
    SSHLibrary.Write    ${pwd}
    sleep   5s
    SSHLibrary.Write    ${cmd2}
    sleep   5s
    SSHLibrary.Write    ${cmd3}
    sleep       60s
    SSHLibrary.Close Connection

RRU_uptime
    ${output}   RU Operation   product_type=gnb    operation=get_ru_measuments    ru_sn=${RU_SN}
    # output: {'uptime': {'seconds': 119931, 'dd:hh:mm:ss': '1d 9h 18m 51s'}, 'voltage': '52.4', 'power': '603.2'}
    ${RU_uptime}    Set Variable    ${output["uptime"]["seconds"]}
    log to console      \n the RRU uptime is ${RU_uptime}
    #${RRU_uptime}       Convert To Integer       ${RU_uptime}   # no need to convert
    #log to console      \n ${RRU_uptime}
    [Return]        ${RU_uptime}