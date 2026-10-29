*** Settings ***
Documentation
...   author: kefang.sheng
...   contact: kefang.sheng@nokia-sbell.com
...   this is a robot case about TOP DTAC customer basic configuration.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Library   taf.selenium.sbts    WITH NAME    selenium_coam_rrm

Force Tags        RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG02_ST_RRM    TA_LEVEL_21    RAN_5G
...               CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIAB1_ASIBR_ABILB1_ABILB2_AHPDA_RFS    STAT_SKIP_AGENT    SBTS00
Suite Setup       Common Suite Setup For RRM
#Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
#Test Teardown     Common Test Case Teardown with Scout
*** Variables ***
${NRCELL_1}             MRBTS-4/NRBTS-10068/NRCELL-72
${LNCE_1}             MRBTS-4/LNBTS-5082/LNCEL-12
${BBMOD_name}           BBMOD_R-2
${RMOD_name}            RMOD_R-1
${index}                1
${call_loop}                 60

*** Test Cases ***

[1]RRM_Check_Counter_After_Multi_Call
    Precondition counter
    FOR   ${index}   IN RANGE   1    ${call_loop}
        Log to console    ******************************************************************
        Log to console    Start to the call: ${index}
        Log to console    ******************************************************************
        UE_Attach_Detach_Onetime
    END
    Check Counter For Stablitity



*** Keywords ***
Precondition counter
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    rm -rf /tmp/PM*    connection=First_ASIB
    ssh.execute    rm -rf /tmp/RD*    connection=First_ASIB
    [Teardown]    ssh.Disconnect    connection=First_ASIB


UE_Attach_Detach_Onetime
    run keyword and ignore error   ute_ue.Require UE    UE_0    capabilities=Qualcomm
    Adjust PA Signal To Attach for 4G
    ute_ue.Attach UE    UE_0
    ute_ue.Log Ue Info    UE_0
    sleep    10s

    Adjust PA Signal To Attach for 5G
    sleep    10s
    ute_ue.Log Ue Info    UE_0
    ute_ue.Start Data Transfer    DT_1    UE_0    DL
    ...   duration=60s    throughput=80Mbits/sec    protocol=udp    packet_size=1024B
    ute_ue.Start Data Transfer    DT_2    UE_0    UL
    ...   duration=60s    throughput=20Mbits/sec    protocol=udp    packet_size=1024B
    ute_ue.Await Data Transfer Finish    DT_1
    ute_ue.Await Data Transfer Finish    DT_2
    ute_ue.get average throughput    DT_1
    ute_ue.get average throughput    DT_2


    ute_ue.verify average throughput    DT_1    1Mbits/sec
    ute_ue.verify average throughput    DT_2    1Mbits/sec
    ute_ue.Detach Ue  UE_0
    sleep    10s

#Check Counter For Stablitity
#    Log to console    Start to Check Counter
#    Sleep    100s
#    ${pi_list}=  Create List    M55350C04001    M55306C09006    M55349C02001    M55601C00002    M55601C00001    M55601C01001    M55309C12001
#    ...    M55350C02001    M55320C18001    M55114C00010    M55308C10009    M55308C18002    M55112C05502    M55112C03001    M55308C10001
#    ...    M55308C10015    M55308C10011    M55308C10003    M55308C10002    M55308C10004    M55115C00005    M55115C00002    M55306C09008
#    ...    M55306C06001    M55116C00012    M55112C00002    M55112C00010    M55112C00004    M55112C00003    M55112C00012    M55112C00002
#    ...    M55112C00010    M55112C05501
#    ${expect_value}    Set Variable    0
#    FOR  ${counter_ID}  IN  @{pi_list}
#           ${counter_id_value_list}    Check counter value   counter_ID=${counter_ID}
#           ...                                               expect_value=${expect_value}
#    END
Check Counter For Stablitity
    Log to console    Start to Check Counter
    Sleep    100s
    ${pi_list}=  Create List    M55350C04001    M55306C09006    M55349C02001    M55601C00002    M55601C00001    M55601C01001    M55309C12001
    ...    M55350C02001    M55320C18001    M55114C00010    M55308C10009    M55308C18002    M55112C05502    M55112C03001    M55308C10001
    ...    M55308C10015    M55308C10011    M55308C10003    M55308C10002    M55308C10004    M55115C00005    M55115C00002    M55306C09008
    ...    M55306C06001    M55116C00012    M55112C00002    M55112C00010    M55112C00004    M55112C00003    M55112C00012    M55112C00002
    ...    M55112C00010    M55112C05501
    ${expect_value}    Set Variable    0
    ${counter_value_list}     Check counter list value     pi_list=${pi_list}
#    log to console    ${counter_value_list}
    Should all counter be expected    ${counter_value_list}


Check counter list value
    [Arguments]    ${pi_list}
    Wait Until Keyword Succeeds    5m    1m    Connect to First_ASIB
    ssh.execute    gunzip /tmp/PM.BTS*.xml.gz    connection=First_ASIB
    @{pi_value_list}    create list
    @{counter_ids_list}    create list
    FOR    ${counter_ID}    IN    @{pi_list}
        ${counter_info}   ssh.execute    cat /tmp/PM.BTS*.xml | grep ${counter_ID}    connection=First_ASIB
        ${counter_id_list_and_value}    get regexp matches    ${counter_info}    <${counter_ID}>(\\d+)</${counter_ID}>    0
        append to list    ${counter_ids_list}    ${counter_id_list_and_value[0]}
    END
    @{counter_values_list}    Create List
    FOR    ${counter_id_item}    IN    @{counter_ids_list}
        ${counter_id_list}    split string    ${counter_id_item}    <
        ${counter_value_item}    get from list    ${counter_id_list}    1
        ${counter_value_list}    split string    ${counter_value_item}    >
        ${counter_value}    get from list    ${counter_value_list}    1
        Append To List    ${counter_values_list}    ${counter_value}
    END
    [Teardown]    ssh.Disconnect    connection=First_ASIB
    [Return]    ${counter_values_list}

Should all counter be expected
    [Arguments]    ${counter_values_list}
    FOR    ${item}    IN    @{counter_values_list}
        Should Be True    ${item} >= 0
    END



Check Test Information
    [Arguments]    ${cell_id}
    ${test_information}    selenium_coam_rrm.get_general_test_information    cell_id=${cell_id}
    should not be empty    ${test_information}

Common Test Case Teardown with Scout
    Common Test Teardown For RRM
    scout.setup_scout    10_5_UTESRAN001T5082
    ${scf_id}    scout.request_scf    use_scout_internal_id=${False}


Adjust PA Signal To Attach for 4G
    Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port
    ${initial_att_values}    Get Initial Attenuation Values   RU_id=0    vendor=RadioRack
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=0    ${attenuation_channels[1]}=0    ${attenuation_channels[2]}=110    ${attenuation_channels[3]}=110
    ...    ${attenuation_channels[4]}=110   ${attenuation_channels[5]}=110    ${attenuation_channels[6]}=110    ${attenuation_channels[7]}=110
    Modify Attenuation Value    ${channels_to_modify}
    sleep    10s
    Log to console    attenuation change complete

Adjust PA Signal To Attach for 5G
    Log to console    Adjust PA Signal
    ${attenuation_channels}     Get Attenuation port
    ${initial_att_values}    Get Initial Attenuation Values   RU_id=0    vendor=RadioRack
    &{channels_to_modify}    create dictionary
    ...    ${attenuation_channels[0]}=0    ${attenuation_channels[1]}=0    ${attenuation_channels[2]}=110    ${attenuation_channels[3]}=110
    ...    ${attenuation_channels[4]}=110   ${attenuation_channels[5]}=110    ${attenuation_channels[6]}=0    ${attenuation_channels[7]}=0
    Modify Attenuation Value    ${channels_to_modify}
    sleep    10s
    Log to console    attenuation change complete
