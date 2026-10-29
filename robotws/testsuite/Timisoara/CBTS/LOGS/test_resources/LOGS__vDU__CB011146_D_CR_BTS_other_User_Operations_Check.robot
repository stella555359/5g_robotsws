*** Settings ***
Documentation  Tests for CB011146-D with different users

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/common_vdu.robot
Resource  ../resources/LOGS_general.robot
Resource  ../resources/AIC_NetAct.robot
Resource  ../../common_resources/M2M_Interface.robot

Library  taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library    ../resources/python/utils.py
Library    SSHLibrary
Library     DateTime

*** Variables ***

${BTS_Security_Administrator}    QlRTU2VjdXJpdHk6TmVtdUAxMjM=
${BTS_Application}    QlRTQXBwbGljYXRpb246TmVtdUAxMjM=
${BTS_Read_Only}     QlRTUmVhZDpOZW11QDEyMw==

${BTS_User_Passwd}    Nemu@123

*** Keywords ***
TC__LOGS__vDU__CB011146_D_CR_BTS_other_User_Operations_Check
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  M2M vDU & vCU cell status other users
    ...  ******************
    ...  *AUTHOR*: dan.moldovan@nokia.com

    Set Tags  CA-WebEM  OWNER-dan.moldovan@nokia.com  AUTHOR-dan.moldovan@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf
    ...  PHASE-CRT  SW-SBTS25R3  FEATURE-CB011146-D

    Step 0: Precondition
    Step 1: Activate BTS Users
    Step 2: Get and check cells and rmods vDU M2M Interface   ${BTS_Security_Administrator}
    Step 2: Get and check cells and rmods vDU M2M Interface   ${BTS_Application}
    Step 2: Get and check cells and rmods vDU M2M Interface  ${BTS_Read_Only}
#    Step 2:Get cells vCU M2M Interface
#    Step 3:Get rmods M2M Interface

Step 0: Precondition
   [Documentation]
    ...   In this step Precond

    Log    \nStep 0: Precondition    console=${True}
    ${date}  Get Current Date  result_format=datetime
    Set Test Variable  ${START_DATE}  ${date}
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${start_time}

    ${vdu_ssh_connection_params}=  Get vDU K8s Master Node Ssh Connection Parameters From Init File
    Set Test Variable  ${ip_addr}    ${vdu_ssh_connection_params['ip_addr']}
    Set Test Variable  ${username}    ${vdu_ssh_connection_params['username']}
    Set Test Variable  ${password}    ${vdu_ssh_connection_params['password']}

##   vDU cells info
    ${cells_info}    vdu.Get Vdu Cells Status

    FOR  ${cell}  IN  @{cells_info}
        Set Test Variable    ${id}    ${cell}[id]
        Set Test Variable    ${name}    ${cell}[name]
        Set Test Variable    ${dist_names}    ${cell}[dist_names][config]
        Set Test Variable    ${operational_state}    ${cell}[operational_state]
        Set Test Variable    ${administrative_state}    ${cell}[administrative_state]
        Set Test Variable    ${availability_status}    ${cell}[availability_status]
    END

    #    RMods info
    ${rmods}  vdu.Get Rmods Status
    FOR  ${current_rmod}  IN  @{rmods}
           Set Test Variable  ${RMOD_ID}  ${current_rmod}[id]
           Set Test Variable  ${Availability_Status}  ${current_rmod}[availability_status]
           Set Test Variable  ${Dist_name}  ${current_rmod}[dist_names][runtime]
    END


Step 1: Activate BTS Users

    Log  \nStep 1: Activate BTS Users  console=true

    Connect To VDU  host=${VDU_OAM_IP}
    vdu.account_users_system_patch     username=BTSSecurity
    ...    new_password=${BTS_User_Passwd}
    ...    activeStatus=active
    vdu.account_users_system_patch     username=BTSApplication
    ...    new_password=${BTS_User_Passwd}
    ...    activeStatus=active
    vdu.account_users_system_patch     username=BTSRead
    ...    new_password=${BTS_User_Passwd}
    ...    activeStatus=active

Step 2: Get and check cells and rmods vDU M2M Interface
    [Arguments]     ${bts_user_pass}
    Log    \nStep 2: Get and check cells and rmods vDU M2M Interface  console=${True}

    Login Using M2M Interface  ${VDU_OAM_IP}  ${bts_user_pass}
#    log to console    Varcell:${id};${dist_names}

    ${cells_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/ext/api/sm/v1/cells"  Bearer  ${TOKEN}
    Should Contain  ${cells_output}  ${id}
    Should Contain  ${cells_output}  ${dist_names}
    Should Contain  ${cells_output}  ${operational_state}
    Should Contain  ${cells_output}  ${administrative_state}
    Should Contain  ${cells_output}  ${availability_status}

    ${rmods_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/ext/api/sm/v1/rmods"  Bearer  ${TOKEN}
    Should Contain  ${rmods_output}  ${RMOD_ID}
    Should Contain  ${rmods_output}  ${Availability_Status}
    Should Contain  ${rmods_output}  ${Dist_name}

Step 3:Get cells vCU M2M Interface

    Log    \nStep 2:Get cells vCU M2M Interface   console=${True}

    Login Using M2M Interface  ${VCU_OAM_IP}

    ${vcu_cells_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/ext/api/sm/v1/cells"  Bearer  ${TOKEN}
    Should Contain  ${vcu_cells_output}   ${vcu_id}
    Should Contain  ${vcu_cells_output}  ${vcu_dist_names}
    Should Contain  ${vcu_cells_output}  ${vcu_operational_state}
    Should Contain  ${vcu_cells_output}  ${vcu_administrative_state}

TC Setup
    Common VDU Setup
    Common VCU Setup  modules_check=${FALSE}

TC Teardown
    Common VDU Teardown
    Logs To Rotta Copy
