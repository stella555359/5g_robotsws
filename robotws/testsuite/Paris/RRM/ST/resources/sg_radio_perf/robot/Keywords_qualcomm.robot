*** Settings ***
Documentation        Annie Wong, common keywords for classical coam Qualcomm TL

Library            taf.transport.ssh                WITH NAME       ssh
Library            ute_ue                           WITH NAME       taf_ue


*** Keywords ***
# source : /home/localuser/TafProject/robotws5g/testsuite/OAM/Nanjing/Resources/robot/SC_UE_keywords.robot
Set Qualcomm UE Variables
    # import variables   %{ABSTRACT_LIB_CONFIG}  is done in keyword Setup Testline Suite Variables
    ${UEPC_DICT_LIST}    Create List
    ${ue_inline}    Set Variable     ${UE_POOLS.AndroidUePool['inline_config']}
    ${UE_NUM}=      Get length     ${ue_inline}
    FOR    ${i}    IN RANGE    ${UE_NUM}
        ${index}=   Evaluate   ${i}+1
        ${ue_name}    Set Variable    UE_${index}
        ${ue_details}         Set Variable    ${ue_inline['${ue_name}']}
        ${ue_capabilities}    Set Variable    ${ue_inline['${ue_name}']['CAPABILITIES']}
        ${ue_constr}          Set Variable    ${ue_inline['${ue_name}']['CONSTRUCTOR_PARAMETERS']}
        ${ue_serial_number}   Set Variable    ${ue_constr['serial_number']}
        ${ue_config}          Set Variable    ${ue_constr['configuration']}
        ${cpc_ip}     Set Variable    ${ue_config['ue_pc_ip']}
        ${cpc_usr}    Set Variable    ${ue_config['login']}
        ${cpc_pwd}    Set Variable    ${ue_config['password']}
        ${pyro_dir}   Set Variable    ${ue_config['server_dir']}
        &{UEPC_DICT}=    Create Dictionary
        ...    capabilities=${ue_capabilities}
        ...    cpc_ip=${cpc_ip}
        ...    cpc_usr=${cpc_usr}
        ...    cpc_pwd=${cpc_pwd}
        ...    serial_number=${ue_serial_number}
        ...    cpc_pyrodir=${pyro_dir}
        Append to List    ${UEPC_DICT_LIST}    ${UEPC_DICT}
    END
    Set Suite Variable    ${UEPC_DICT_LIST}
    Log     UEPC_DICT_LIST = ${UEPC_DICT_LIST}     console=${DEBUG_MODE_CONSOLE}
    Set Suite Variable    ${UE_NUM}
    Log     UE_NUM = ${UE_NUM}     console=${DEBUG_MODE_CONSOLE}


Ue reserve with index
    [Documentation]  This keyword is used to detect ue that connect to control PC by USB.
    ...  It will read the ue_config.yaml file
    ...  If you put the keyword in the testcase scope, ue.teardown will automatically called when exiting the scope.
    ...  Important: this keyword support multi ue , but need to config the tl.ues[xx].capability[] at least with one different value.
    ...  :param ue_index is the list index from tl.ues[], it will use the index UE for reserve
    [Arguments]     ${ue_index}=${0}     ${capabilities}=REAL_ANDROID_UE
    ${ue_cap} =    set variable    ${UEPC_DICT_LIST[${ue_index}]['capabilities']}
    should contain      ${ue_cap}      ${capabilities}
    taf_ue.require Ue     ue_alias=MYUE${ue_index}     capabilities=${capabilities}


Ue attach with index
    [Documentation]  This keyword's behavior are different when using different plugins.
    ...  If UE_CAPABILITIES is REAL_ANDORID_UE, the keyword will send adb command to turn off the airplane mode.
    [Arguments]      ${ue_index}=${0}
    taf_ue.attach_ue      ue_alias=MYUE${ue_index}


Ue detach with index
    [Arguments]      ${ue_index}=${0}
    taf_ue.detach_ue      ue_alias=MYUE${ue_index}


Ue reserve with index and ensure detach
    [Arguments]     ${ue_index}=${0}     ${capabilities}=REAL_ANDROID_UE
    Ue reserve with index     ue_index=${ue_index}   capabilities=${capabilities}
    #Detach the UE in case the UE is already attached.
    taf_ue.detach_ue      ue_alias=MYUE${ue_index}
