*** Settings ***

Documentation
...    Author: jun.6.ma
...    Contact: jun.6.ma@nokia-sbell@nokia-sbell.com
...    This is a robot scripts for 25R2 CRT for CB010846-SR-A 10 online activation case

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
#${RU_IP}        172.22.56.2       # eCPRI RU AZHL  SN:YK203400037
${RU_SN}        BL2236V082K

*** Test Cases ***
Case_CB010846-A#10_RU_resiliency_to_BTS-DU_L1Soc_and_Capacity_Unit_reset-Controlled_case-on-line_activation
    [Tags]    QC_203482    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...     Author: jun.6.ma@nokia-sbell.com
    ...     this is the case run in TMO-58 testline whose BTS ID is 37548 for CB010846-SR-A online activation
    ...     verify RU relisilence with BBMOD resetting, site resetting without RU resetting, RAT hard reset
    [Setup]    Common Test Setup For RRM
    Controlled_Active
    sleep   60
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=CELL_ONAIR
    log to console    \n>>> Site and Cells are onair with feature online activation successfully
    FOR   ${index}  IN RANGE    3  # 0，1，2...  totally 3 times
        sleep   60
        ${RRU_uptime_0}     RRU_uptime
        log to console     \n>>>This is the ${${index}+1} time to reset the BBMOD, totally 3 times.
        BBMOD_Reset
        log to console     \n>>>BBMOD resetting done
        sleep   60   # need to have enough time to have time gap after cell on-air but RRU info show fully, or else '-'
        ${status}=     Run Keyword And Return Status   Check_CellandSite_Status
        ${RRU_uptime_1}     RRU_uptime
        Run Keyword If      '${status}' == 'False' or ${RRU_uptime_1} <= ${RRU_uptime_0}
        ...     Run Keywords    log to console      \n >>>RU reset, need to analysis !!!
        ...     AND     Exit For Loop
        log to console     \n>>>This is the ${${index}+1} time to do RAT Hard Reset, totally 3 times.
        RAT_Reset_Hard
        sleep   60
        ${status}=     Run Keyword And Return Status   Check_CellandSite_Status
        ${RRU_uptime_2}     RRU_uptime
        Run Keyword If  '${status}' == 'False' or ${RRU_uptime_2} <= ${RRU_uptime_1}
        ...     Run Keywords    log to console      \n >>>RU reset, need to analysis !!!
        ...     AND     Exit For Loop
        log to console     \n>>>This is the ${${index}+1} time to do site reset without RU reset, totally 3 times.
        Site_Reset_without_ru_reset
        sleep   60
        ${status}=     Run Keyword And Return Status   Check_CellandSite_Status
        ${RRU_uptime_3}     RRU_uptime
        Run Keyword If  '${status}' == 'False' or ${RRU_uptime_3} <= ${RRU_uptime_2}
        ...     Run Keywords    log to console      \n >>>RU reset, need to analysis !!!
        ...     AND     Exit For Loop
    END
    sleep    30s
    log to console    \n>>>Start to collect Snapshot...
    Collect Coam Snapshot    name=RU_Resiliency_CB010846-SR-A_online_Activation
    log to console    \n Snapshot collected... Case END
    [Teardown]    Teardown_for_OAM

*** Keywords ***
Teardown_for_OAM
    Get SCF Internal Id By Scout    no_ute=False
    Common Test Teardown For RRM
Check_CellandSite_Status
    BTS Operation    operation=verify    product_type=gnb    bts_index=0    verify_status=SITE_ONAIR+CELL_ONAIR
Controlled_Active
    @{para_list}      Create List     actRuResetResiliency        cntrldResetMplaneBreakTime
    @{mo_list}        Create List     MRBTS-37548/MNL-1/MNLENT-1/FEATCADM-1       MRBTS-37548/MNL-1/MNLENT-1/FEATCADM-1
    @{value_list}     Create List     true        220||400||600
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=${para_list}        value_list=${value_list}    mo_list=${mo_list}
    Log To Console    \n >>> Paramter update result: ${out}
RAT_Reset_Hard
    BTS Operation    operation=rat_reset            product_type=gnb    bts_index=0    distname_id=NRCELL-ALL    need_verify=True
    ...    reset_type=Hard
Site_Reset_without_ru_reset
    BTS Operation    operation=bts_reset            product_type=gnb    bts_index=0    need_verify=True    reset_without_ru=${True}
BBMOD_Reset
    BTS Operation    operation=bbmod_reset          product_type=gnb    bts_index=0    distname_id=BBMOD-1    need_verify=True
RRU_uptime
    ${output}   RU Operation   product_type=gnb    operation=get_ru_measuments    ru_sn=${RU_SN}
    # output: {'uptime': {'seconds': 119931, 'dd:hh:mm:ss': '1d 9h 18m 51s'}, 'voltage': '52.4', 'power': '603.2'}
    ${RU_uptime}    Set Variable    ${output["uptime"]["seconds"]}
    log to console      \n the RRU uptime is ${RU_uptime}
    #${RRU_uptime}       Convert To Integer       ${RU_uptime}   # no need to convert
    #log to console      \n ${RRU_uptime}
    [Return]        ${RU_uptime}