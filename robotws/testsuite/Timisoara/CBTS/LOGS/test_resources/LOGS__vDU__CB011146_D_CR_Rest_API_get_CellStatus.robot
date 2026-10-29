*** Settings ***
Documentation
...  Tests for CB011146

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/common_vdu.robot
Resource  ../resources/LOGS_general.robot
Resource  ../resources/AIC_NetAct.robot
Resource  ../../common_resources/M2M_Interface.robot


Library    taf.transport.ssh  WITH NAME  csn
#Library  taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library    ../resources/python/utils.py
Library    SSHLibrary
Library    DateTime

*** Keywords ***

TC__LOGS__vDU__CB011146_D_CR_Rest_API_get_CellStatus

    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  M2M vDU & vCU cell status
    ...  ******************
    ...  *AUTHOR*: dan.moldovan@nokia.com

    Set Tags  CA-WebEM  OWNER-dan.moldovan@nokia.com  AUTHOR-dan.moldovan@nokia.com    GROUP_IN_CHARGE-TIM_7_Vrf
    ...  PHASE-CRT  SW-SBTS25R3  FEATURE-CB011146-D


    Step 0: Precondition
    Step 1: Get Cells and Rmods M2M Interface
    Step 2: Get cells vCU M2M Interface

Step 0: Precondition
   [Documentation]
    ...   In this step Precond

    Log    \nStep 0: Precondition    console=${True}

    ## Get vdu vcu cells and rmods
    ${vdu_ssh_connection_params}=  Get vDU K8s Master Node Ssh Connection Parameters From Init File
    Set Test Variable  ${ip_addr}    ${vdu_ssh_connection_params['ip_addr']}
    Set Test Variable  ${username}    ${vdu_ssh_connection_params['username']}
    Set Test Variable  ${password}    ${vdu_ssh_connection_params['password']}

#    ${nr_cells_id}  Get List Of Nr Cells Id
    ${cells_info}    Get vdu cell infos

    FOR  ${cell}  IN  @{cells_info}
        Set Test Variable    ${id}    ${cell}[id]
        Set Test Variable    ${name}    ${cell}[name]
        Set Test Variable    ${dist_names}    ${cell}[dist_names][config]
        Set Test Variable    ${operational_state}    ${cell}[operational_state]
        Set Test Variable    ${administrative_state}    ${cell}[administrative_state]
        Set Test Variable    ${availability_status}    ${cell}[availability_status]
    END

    ${vcu_cells_info}    Get vcu cell infos

    FOR  ${vcu_cell}  IN  @{vcu_cells_info}
        Set Test Variable    ${vcu_id}    ${vcu_cell}[id]
        Set Test Variable    ${vcu_name}    ${vcu_cell}[name]
        Set Test Variable    ${vcu_dist_names}    ${vcu_cell}[dist_names][config]
        Set Test Variable    ${vcu_operational_state}    ${vcu_cell}[operational_state]
        Set Test Variable    ${vcu_administrative_state}    ${vcu_cell}[administrative_state]
#        Set Test Variable    ${availability_status}    ${vcu_cell}[availability_status]
    END

    ${rmods}  vdu.Get Rmods Status
    FOR  ${current_rmod}  IN  @{rmods}
           Set Test Variable  ${RMOD_ID}  ${current_rmod}[id]
           Set Test Variable  ${Availability_Status}  ${current_rmod}[availability_status]
           Set Test Variable  ${Dist_name}  ${current_rmod}[dist_names][runtime]
    END

Step 1: Get Cells and Rmods M2M Interface

    Log    \nStep 1:Get Cells and Rmods   console=${True}

    log to console    Varcell:${id};${dist_names}

    ${cells_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/ext/api/sm/v1/cells"  Bearer  ${TOKEN}
    Should Contain  ${cells_output}  ${id}
    Should Contain  ${cells_output}  ${dist_names}
    Should Contain  ${cells_output}  ${operational_state}
    Should Contain  ${cells_output}  ${administrative_state}
    Should Contain  ${cells_output}  ${availability_status}

    ${rmods_output}  Run M2M Command  GET  "https://${VDU_OAM_IP}/ext/api/sm/v1/rmods"  Bearer  ${TOKEN}
    Should Contain  ${rmods_output}  "id":"${RMOD_ID}"
    Should Contain  ${rmods_output}  "runtime":"${Dist_name}"
    Should Contain  ${rmods_output}  ${Availability_Status}


Step 2: Get cells vCU M2M Interface

    Log    \nStep 2:Get cells vCU M2M Interface   console=${True}

#    ${current_date_time}  Get Current Time For Diagnostic Check
#    Set Test Variable  ${CURRENT_DATE_TIME}

     Login Using M2M Interface  ${VCU_OAM_IP}

    ${vcu_cells_output}  Run M2M Command  GET  "https://${VCU_OAM_IP}/ext/api/sm/v1/cells"  Bearer  ${TOKEN}
    Should Contain  ${vcu_cells_output}  ${vcu_id}
    Should Contain  ${vcu_cells_output}  ${vcu_dist_names}
    Should Contain  ${vcu_cells_output}  ${vcu_operational_state}
    Should Contain  ${vcu_cells_output}  ${vcu_administrative_state}

Get vdu cell infos
    [Documentation]
    ...  This keyword is used to get cell info

#    ${cells_id_list}  Create List
    ${cells_statuses}  vdu.Get Vdu Cells Status
#    FOR  ${cell}  IN  @{cells_statuses}
#        Set Test Variable    ${id}    ${cell}[id]
#        Set Test Variable    ${dist_names}    ${cell}[dist_names][config]
#    END
#    Set Test Variable    ${id}    ${cells_statuses}[id]
    [Return]  ${cells_statuses}

Get vcu cell infos
    [Documentation]
    ...  This keyword is used to get cell info

    ${vcu_cells_statuses}  vcu.Get Cells Statuses
    [Return]  ${vcu_cells_statuses}

Test Teardown
    [Documentation]
    ...   Teardown In this step Clear Alarms

    Log    \nTeardown: Clear Alarms    console=${True}

#    Clear faulty


TC Setup
    Common VDU Setup
    Common VCU Setup   modules_check=False
    Login Using M2M Interface  ${VDU_OAM_IP}

TC Teardown

#    Test Teardown
    Common VDU Teardown
    Logs To Rotta Copy