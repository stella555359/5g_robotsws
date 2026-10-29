*** Settings ***
Documentation
    ...    Author: kefang.sheng
    ...    Contact: kefang.sheng@nokia-sbell.com
    ...    Description: The test case is to verify Stability Customer basic configration. The content of this case is site reset, RF reset, cell lock.


Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC

Force Tags
...                CRT
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22


Resource    ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${index}                0
${loop_vDU_reset}           20
${loop_vCU_reset}           20
${loop_RF_reset}           20
${loop_Cell_lock}           20

*** Test Cases ***
[1]Stability_Lock_Unlock_Cell
    [Tags]    CRT
    [Documentation]
    ...    Author: kefang.sheng
    ...    Contact: kefang.sheng@nokia-sbell.com
    ...    1.9.2022,kefang.sheng@nokia-sbell.com

     Log to Console    \n*** Stability_Lock_Unlock_Cell***
  	FOR   ${index}   IN RANGE   1    ${loop_Cell_lock}
         Log to Console    \n*** The ${index} time to run the function***
         Lock Cell
         sleep    10s
         Unlock Cell
	     Check both vDU and vCU cells should be onair
    END

[2]Stability_RF_Reset
    [Tags]    CRT
    [Documentation]
    ...    Author: kefang.sheng
    ...    Contact: kefang.sheng@nokia-sbell.com
    ...    1.9.2022,kefang.sheng@nokia-sbell.com

     Log to Console    \n*** Stability_RF_Reset***
  	FOR   ${index}   IN RANGE   1    ${loop_RF_reset}
         Log to Console    \n*** The ${index} time to run the function***
         Reset RU With Check Cell On Air
	     Check both vDU and vCU cells should be onair
    END

[3]Stability_vDU_Reset
    [Tags]    CRT
    [Documentation]
    ...    Author: kefang.sheng
    ...    Contact: kefang.sheng@nokia-sbell.com
    ...    1.9.2022,kefang.sheng@nokia-sbell.com

     Log to Console    \n*** Stability_vDU_Reset***
  	FOR   ${index}   IN RANGE   1    ${loop_vDU_reset}
         Log to Console    \n*** The ${index} time to run the function***
         Reset vDU With Check Cell On Air    need_check_on_air=${True}
	     Check both vDU and vCU cells should be onair
    END

[4]Stability_vCU_Reset
    [Tags]    CRT
    [Documentation]
    ...    Author: kefang.sheng
    ...    Contact: kefang.sheng@nokia-sbell.com
    ...    1.9.2022,kefang.sheng@nokia-sbell.com

     Log to Console    \n*** Stability_vCU_Reset***
  	FOR   ${index}   IN RANGE   1    ${loop_vCU_reset}
         Log to Console    \n*** The ${index} time to run the function***
         Reset vCU With Check Cell On Air
	     Check both vDU and vCU cells should be onair
    END

[5]Stability_Make_Call
    [Tags]    CRT
    [Documentation]
    ...    Author: kefang.sheng
    ...    Contact: kefang.sheng@nokia-sbell.com
    ...    1.9.2022,kefang.sheng@nokia-sbell.com

     Log to Console    \n*** Stability_Make_Call***
     Prepare UE0
     Attach UE0 And Start DL TPUT
     Check DL Tput By K8s Log

*** Keywords ***
Lock Cell
    ${cell_id_list}    Create List    1
    Lock Cell In vDU    cell_id_list=${cell_id_list}

Unlock Cell
    ${cell_id_list}    Create List    1
    Unlock Cell In vDU    cell_id_list=${cell_id_list}

Check both vDU and vCU cells should be onair
    Log To Console    \n*** check on air state in cu ***
    wait until keyword succeeds    900    20
    ...        Check All Cells On Air In vCU
    Log To Console    \n*** check on air state in du ***
    wait until keyword succeeds    900    20
    ...        vDU Check All Cells Status Should Be Onair

Prepare UE0
    Log to Console    \n***start to Prepare UE***
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Test Variable    ${ue0_type}
    Prepare UE    ${ue0_type}    ue_index=${0}
    sleep    60s

Attach UE0 And Start DL TPUT
    Log to Console    \n***start to UE Attach***
    UE Attach    ${ue0_type}    ue_index=${0}
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=800M    duration=120
    sleep    20s


Check DL Tput By K8s Log
    Log to Console    \n***start to check Tput***
    ${dl_l2rt_tput_local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}
    ...                                      container_name=l2rt    pod_name=up   timeout=${10}
    Set Test Variable    ${dl_l2rt_tput_local_file_path}
    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${dl_l2rt_tput_local_file_path}
    should be true  ${max_dl_tput}>=0
    sleep    30s
