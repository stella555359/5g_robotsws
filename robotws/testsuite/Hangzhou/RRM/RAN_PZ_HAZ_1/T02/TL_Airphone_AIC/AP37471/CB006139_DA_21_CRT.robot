*** Settings ***
Documentation
...    Author: Sun Shuangfeng
...    Contact: Shuangfeng.f.sun@nokia-sbell.com
...    this file is for CB013289.
...    Please do not modify the file without notification to author

#Suite Setup    Common Suite Setup For AIC
#Suite Teardown     Custom Suite Teardown For AIC
Suite Setup    Airphone Operation    operation=eth_config    product_type=${None}
...    eth_config_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/AP37471/ap_tl248.json

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_1/Module/Airphone_Operation.robot
#Resource          ../../../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
Resource          ../../../T02/Common_Case/common_resource_new.robot

*** Variables ***
${CB006139_DA_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/AP37471/APCFG/wts_37471_CB006139_DA.cfg

${ue_capability_DA_21}  FFA0F200475F7A6B5F83820960006800BB802002024107CC020248170031FFF800140F80C0301804A87E146FCC0D0
...    A82296595103C00ABFF3039006FFF9FFFE9FFF7C7E7E1FF1FF8DFFF5184DFE7FEDFE7FE31000028150FC41DF981A150452CB2A20780157
...    FE607200DFFF3FFFD3FFEF8FCFC3FE3FF1BFFEA309BFCFFDBFCFFC6280005002B66000F00066000F00002A1F89BBF30342A08A5965440F
...    002AFFCC0E401831E7FFFA7FFDF1F9F87FC7FE37FFD46137F9FFB7F9FF8C50000A0056CC001E000CC001E0000541F0637E606854114B2C
...    A881E0055FF981C8037FFCFFFF4FFFBE3F3F0FF8FFC6FFFA8C26FF3FF6FF3FF18A0001400AD98003C00198003C0000A83E236FCC0D0A82
...    296595103C00ABFF3039006FFF9FFFE9FFF7C7E7E1FF1FF8DFFF5184DFE7FEDFE7FE31400028015B300078003300078000002A2F134003
...    89A001C28000E0C000710400388C000000ADF80000000194000B80654A952A54A979795FDB02808CFDFFFFF86E003E003C00301C1601E0
...    01C0FC26007800601AEE0B00B000E035DC16016001C0800400000020010000003780322000000591000000A802C19BCA9A0093C0000A59
...    6509E000152CB2800A8345D2A8A00140401002010040080401002010020040400801010020042D04A

${ue_capability_DA_22}  FFA0F200475F7A6B5F83820960006800BB802002024107CC020248170031FFF800140F80C0301804A87E146FCC0D0
...    A82296595103C00ABFF3039006FFF9FFFE9FFF7C7E7E1FF1FF8DFFF5184DFE7FEDFE7FE31000028150FC41DF981A150452CB2A20780157
...    FE607200DFFF3FFFD3FFEF8FCFC3FE3FF1BFFEA309BFCFFDBFCFFC6280005002B66000F00066000F00002A1F89BBF30342A08A5965440F
...    002AFFCC0E401831E7FFFA7FFDF1F9F87FC7FE37FFD46137F9FFB7F9FF8C50000A0056CC001E000CC001E0000541F0637E606854114B2C
...    A881E0055FF981C8037FFCFFFF4FFFBE3F3F0FF8FFC6FFFA8C26FF3FF6FF3FF18A0001400AD98003C00198003C0000A83E236FCC0D0A82
...    296595103C00ABFF3039006FFF9FFFE9FFF7C7E7E1FF1FF8DFFF5184DFE7FEDFE7FE31400028015B300078003300078000002A2F134003
...    89A001C28000E0C000710400388C000000ADF80000000194000B80654A952A54A97978FFDB02808CFDFFFFF86E003E003C00301C1601E0
...    01C0FC26007800601AEE0B00B000E035DC16016001C0800400000020010000003780322000000591000000A802C19BCA9A0093C0000A59
...    6509E000152CB2800A8345D2A8A00140401002010040080401002010020040400801010020042D04A

${ue_capability_DA_23}  FFA0F200475F7A6B5F83820960006800BB802002024107CC020248170031FFF800140F80C0301804A87E146FCC0D0
...    A82296595103C00ABFF3039006FFF9FFFE9FFF7C7E7E1FF1FF8DFFF5184DFE7FEDFE7FE31000028150FC41DF981A150452CB2A20780157
...    FE607200DFFF3FFFD3FFEF8FCFC3FE3FF1BFFEA309BFCFFDBFCFFC6280005002B66000F00066000F00002A1F89BBF30342A08A5965440F
...    002AFFCC0E401873E7FFFA7FFDF1F9F87FC7FE37FFD46137F9FFB7F9FF8C50000A0056CC001E000CC001E0000541F0637E606854114B2C
...    A881E0055FF981C8037FFCFFFF4FFFBE3F3F0FF8FFC6FFFA8C26FF3FF6FF3FF18A0001400AD98003C00198003C0000A83E236FCC0D0A82
...    296595103C00ABFF3039006FFF9FFFE9FFF7C7E7E1FF1FF8DFFF5184DFE7FEDFE7FE31400028015B300078003300078000002A2F134003
...    89A001C28000E0C000710400388C000000ADF80000000194000B80654A952A54A97979FFDB02808CFDFFFFF86E003E003C00301C1601E0
...    01C0FC26007800601AEE0B00B000E035DC16016001C0800400000020010000003780322000000591000000A802C19BCA9A0093C0000A59
...    6509E000152CB2800A8345D2A8A00140401002010040080401002010020040400801010020042D04A

${config_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/AP37471/APCFG/CB006139


*** Test Cases ***
Update Local AP
    [Tags]    apupgrade
    Airphone Operation    operation=local_ap_upgrade    product_type=${None}
    ...                   eth_config_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/AP37471/ap_tl248.json
    ...                   ap_build=${None}
    OperatingSystem.Run    cp ${CB006139_DA_wts} /opt/wts/latest/basic_setup.cfg

CB006139_DA_21_USCB006139-DA#B3_Step-wise_SCell_Addition_accompanied_with_CSI-RS_downgrade_in_an_existing_Scell
    [Tags]    CB006139_DA_21    RAN_PZ_HAZ_1    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
    [Setup]    Case Precondition
    Start Counter For CB006139_DA_6CC_VDU
    @{para_list}      Create List    maxNumOfSCellAlloc
    @{mo_list}        Create List    MRBTS-37471/NRBTS-37471/NRCELL-2
    @{value_list}     Create List    250
    ${out}            Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}
    @{para_list1}      Create List    actCarAgPmCount
    @{mo_list1}        Create List    MRBTS-37471/NRBTS-37471/
    @{value_list1}     Create List    true
    ${out1}            Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                      para_list=@{para_list1}        value_list=@{value_list1}    mo_list=@{mo_list1}
    Log To Console    paramter update result: ${out1}
    @{para_list2}      Create List    actCarAgPmCount
    @{mo_list2}        Create List    MRBTS-37471/NRBTS-37471/
    @{value_list2}     Create List    true
    ${out2}            Parameter Operation    operation=parameter_update    product_type=vdu
    ...                                      para_list=@{para_list2}        value_list=@{value_list2}    mo_list=@{mo_list2}
    Log To Console    paramter update result: ${out2}
#      \nStart to change "maxNumOfSCellAlloc" of Cell-2 to 0
    CB006139_Change_UE_Location  ue_id=1  enb_id=2  cell_id=3
    Log To Console    \nlocation updated to eNB-2 cell 3
    CB006139_Change_UE_Capability    ${ue_capability_DA_21}    ue_id=1
    SA UE register and PDU setup    ue_id=1    ue_gw=1
    start_ue_big_data_traffic  ue_id=1  dl_rate=600  ul_rate=10
    sleep    40s
    Log To Console  \nSCells activated
    Log To Console  \nSCellIndex 1 activated successfully at airphone.
    Log To Console  \nSCellIndex 2 activated successfully at airphone.
    Log To Console  \nSCellIndex 3 activated successfully at airphone.
    Log To Console  \nSCellIndex 4 activated successfully at airphone.
    Log To Console  \nSCellIndex 5 activated successfully at airphone.
    Execute Egate Command    cmd=ue_stats_nr id=1 scell=0-6
    Log To Console  \nStart to trigger scell release due to RLQ
    trigger_scell_rlq_release  ue_id=1  scell_id=2
    sleep    10s
    Log To Console  \nsCellToReleaseList { 2 }
    Execute Egate Command    cmd=ue_stats_nr id=1 scell=0-5
    detrigger_scell_rlq_release
    sleep    10s
    stop_ue_big_data_traffic  ue_id=1
    sleep    10s
    detach_ue_with_power_off  ue_id=1
    Collect And Check Counter
    [Teardown]    Airphone_TearDown_Cloud

*** Keywords ***
Common Suite Setup For AIC
    Config Iphy Ip For Local Env_248      ap_version=4.0.31311

Case Precondition
    Case Precondition For AP    tag=37471_CB006139_DA    product_type=vdu    operation=env_setup_sa
    sleep    180s

CB006139_Change_UE_Capability
    [Arguments]  ${ue_capability_hex}  ${ue_id}=1
    Execute Egate Command
    ...    cmd=ue_param id=${ue_id} ue_nr_capabilities=${ue_capability_hex}

CB006139_Change_UE_Location
    [Arguments]  ${ue_id}=1  ${enb_id}=2  ${cell_id}=1
    Execute Egate Command
    ...    cmd=ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}

detrigger_scell_rlq_release
    Execute Egate Command
    ...  cmd=bler_testmode_nr profile_id=2 delete=yes

start_ue_big_data_traffic
    [Arguments]  ${ue_id}=1  ${dl_rate}=450  ${ul_rate}=10
    ${dl_num}  evaluate  ${dl_rate}//150+1
    FOR  ${i}  IN RANGE  1  ${dl_num}  1
        log to console  \nue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=dl mbps=150 seconds=360
        Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=dl mbps=150 seconds=360
        ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END
    ${ul_num}  evaluate  ${ul_rate}//10+1
    FOR  ${i}  IN RANGE  1  ${ul_num}  1
        Execute Egate Command
        ...    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=${i} dir=ul mbps=30 seconds=360
        ...    pass_regexp=Started.*Internal traffic.*on Ue:${ue_id}
    END

stop_ue_big_data_traffic
    [Arguments]  ${ue_id}=1
    Log to Console  \nUE-${ue_id} Stop Data Service
    Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=dl
    # ...    pass_regexp= Stopped .*Internal traffic on Ue:${ue_id}
    Execute Egate Command
    ...    cmd=trf_data_stop ue=${ue_id} pdu=1 qfi=1 dir=ul
    # ...    pass_regexp=Stopped .*Internal traffic on Ue:${ue_id}

detach_ue_with_power_off
    [Arguments]  ${ue_id}=1
    Execute Egate Command
    ...    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    Log to Console  \nUE-${ue_id} Detached!

verify_ue_dl_scell_status
    [Arguments]    ${ue_id}=1    ${num_of_scells}=3
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    ${scell_status}=  Execute Egate Command
        ...           cmd=ue_stats_nr id=${ue_id} scell=0-${num_of_scells}
        # ...           pass_regexp=(CellIndex-[0-${num_of_scells}].*)
        ...           pass_regexp=(CellIndex-[0-${num_of_scells}][\\s][\\s][0-9].*\\n){${num_of_cells}}
    log to console  \n${scell_status}

verify_ue_ul_scell_status
    [Arguments]    ${ue_id}=1    ${num_of_scells}=3
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    ${scell_status}=  Execute Egate Command
        ...           cmd=ue_stats_nr id=${ue_id} scell=0-${num_of_scells} type=pusch
    log to console  \n${scell_status}

trigger_scell_rlq_release
    [Arguments]    ${ue_id}=1  ${scell_id}=0
    Execute Egate Command
    ...  cmd=bler_testmode_nr profile_id=2 dl_bler=800,200,100
    Execute Egate Command
    ...  cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=2 scell=${scell_id}
    ...  timeout=20

update parameter in vCU
    [Arguments]  ${delta_file_path}=${config_path}/delta_plan_DA_21_vcu.json
    Parameter Operation    operation=delta_plan_update   product_type=vcu  delta_file_path=${delta_file_path}  wait_for_completion=${True}

update parameter in vDU
    [Arguments]  ${delta_file_path}=${config_path}/delta_plan_DA_21_vdu.json
    Parameter Operation    operation=delta_plan_update   product_type=vcu  delta_file_path=${delta_file_path}  wait_for_completion=${True}

update parameter in vCU for case23
    [Arguments]  ${delta_file_path}=${config_path}/delta_plan_DA_23_vcu.json
    Parameter Operation    operation=delta_plan_update   product_type=vcu  delta_file_path=${delta_file_path}  wait_for_completion=${True}

update parameter in vDU for case23
    [Arguments]  ${delta_file_path}=${config_path}/delta_plan_DA_23_vdu.json
    Parameter Operation    operation=delta_plan_update   product_type=vcu  delta_file_path=${delta_file_path}  wait_for_completion=${True}

Airphone_TearDown_Cloud
    Airphone Operation    operation=aplog
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

Custom Suite Teardown For AIC
    Common Suite Teardown For AIC
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}

    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}


SA UE register and PDU setup
    [Arguments]    ${ue_id}=1    ${ue_gw}=1
    Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    sleep    5s    wait for all data sent
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    5s    wait for all data sent
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}
    ...                                pass_regexp=QoS Routing Table
    sleep    5s    wait for all data sent

Start Counter For CB006139_DA_6CC_VDU
    ${rule1}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55139C01001,M55139C01002;
    ...         Counter rule: max(M55139C01001)>=1 and max(M55139C01002)>=1;
    ${rule2}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55139C01001,M55139C01002;
    ...         Counter rule: max(M55139C01001)>=1 and max(M55139C01002)>=1;
    ${rule3}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-10;
    ...         Counter: M55139C01001,M55139C01002;
    ...         Counter rule: max(M55139C01001)>=1 and max(M55139C01002)>=1;
    ${rule4}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-11;
    ...         Counter: M55139C01001,M55139C01002;
    ...         Counter rule: max(M55139C01001)>=1 and max(M55139C01002)>=1;
    ${rule5}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-13;
    ...         Counter: M55139C01001,M55139C01002;
    ...         Counter rule: max(M55139C01001)>=1 and max(M55139C01002)>=1;
    ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}    ${rule4}    ${rule5}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vdu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Collect And Check Counter
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu
    ...                               bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}
