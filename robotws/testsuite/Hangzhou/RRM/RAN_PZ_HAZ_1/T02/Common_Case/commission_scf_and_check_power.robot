*** Settings ***
Documentation
...   Author: mengli.yang@nokia-sbell.com
...   Contact: mengli.yang@nokia-sbell.com
...   Description: this case is used for check power


Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout   120 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot

*** Test Cases ***
Commission Full SCF And Check Power
    [Tags]    CIT    power    CDRT
    [Documentation]
    ...    Author: mengli.yang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    14.02.2022,mengli.yang@nokia-sbell.com, draft
    [Setup]    Common Test Setup For AIC
    Log to Console    \n***  Commission Full SCF For vDU ***
    Commission Full SCF For vDU    scf_file_name=${scf_file_name}
    Log to Console    \n*** vDU Check All Cells Status Should Be Onair ***
    ${vdu_status}=   run keyword and return status    wait until keyword succeeds    60min    10min
    ...                                               vDU Check All Cells Status Should Be Onair

*** Keywords ***
Case Precondition
    Create Suite Directory
    Create Case Directory

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Commission Full SCF For vDU
    [Arguments]    ${scf_file_name}=vDU_SCF_0.300.xml
    ${vdu_scf_file_name}    Get vDU Scf File From Testline Configuration    gnb_index=0
    ...                                                                     vdu_index=0
    ...                                                                     file_name=${scf_file_name}
    vDU Update Full SCF By Rest    scf_path=${vdu_scf_file_name}
    ...                            fix_errors=true

Check Power
    Log to Console    \n*** Check Power in vdu ***
    ${quantity_of_vdu_for_specified_cu}=   Get vDU Number    gnb_index=${0}
    FOR   ${vdu_index}   IN RANGE   ${quantity_of_vdu_for_specified_cu}
        Check Power On All RF   ${vdu_index}
    END


Get RF Address
    [Arguments]  ${vdu_index}=${0}    ${vDU_namespace}=cran1
    ...          ${oam_pod_name}=po-cran1-oamfh-0    ${oamfh_container_name}=ctr-cran1-oamfh
    ${RF_ip_list}    create list
    ${alias}  get unique id
    Set Test Variable    ${alias}
    Connect To K8s Master In vDU  vdu_index=${vdu_index}  alias=${alias}
    ${cmd}    Catenate    SEPARATOR=   kubectl exec -n ${vDU_namespace} ${oam_pod_name} -c ${oamfh_container_name} -- b
    ...  ash -c "{ echo \\"aasyscomgw -r\\";sleep 1;echo \\"quit\\"; } | nc 127.0.0.1 15067;" | grep 192.168.254 | g
    ...  rep UDPCP |awk '{print $7}'
    ${output}=   issh.execute   command=${cmd}   check_result=False    alias=${alias}
#    ${RF_ip_list}=   Get Regexp Matches    ${output}   (\\d+.){3}\\d+
    ${RF_ip_list}=   Get Regexp Matches    ${output}   192\.(\\d+.){2}\\d+
    Should Not Be Empty    ${RF_ip_list}    Can't get RF ip, pls check the env or check the command is still in use
    [Return]    ${RF_ip_list}

Check Power On All RF
    [Arguments]    ${vdu_index}
    ${RF_ip_list}=     Get RF Address    vdu_index=${vdu_index}
    ...                                  vDU_namespace=cran1
    ...                                  oam_pod_name=po-cran1-oamfh-0
    ...                                  oamfh_container_name=ctr-cran1-oamfh
    ${password}  set variable    bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
    : FOR    ${RF_ip}    IN    @{RF_ip_list}
    \    Check Power On RF    RF_ip=${RF_ip}   alias=${alias}   password=${password}  vdu_index=${vdu_index}

Check Power On RF
    [Arguments]    ${RF_ip}    ${alias}   ${password}   ${vdu_index}=${0}
    FOR    ${i}    IN RANGE    0    10
       ${power_sucessful_count}=    Check Power On RF For TDD    RF_ip=${RF_ip}   index=${i}   alias=${alias}
       ...    password=${password}  vdu_index=${vdu_index}
       Exit for loop if     ${power_sucessful_count} >= 1
    END


Check Power On RF For TDD
    [Arguments]    ${RF_ip}    ${index}    ${alias}   ${password}   ${vdu_index}=${0}
    ...            ${vDU_namespace}=cran1    ${oam_pod_name}=po-cran1-oamfh-0    ${oamfh_container_name}=ctr-cran1-oamfh
    Set Test Variable    ${power_sucessful_count}    ${0}
    ${cmd}    Catenate    SEPARATOR=  kubectl exec -it -n ${vDU_namespace} ${oam_pod_name} -c ${oamfh_container_name} -
    ...  - ssh serviceuser@${RF_ip} -o StrictHostKeyChecking=no -- ssh root@192.168.101.2 -- "dapd -pwr ${index};"
    ${old_prompt}  issh.set prompt   assword:    alias=${alias}
    ${output}=   issh.execute   command=${cmd}    check_result=False    alias=${alias}
    issh.set prompt    ${old_prompt}   alias=${alias}
    ${power}=   run keyword if   "assword:" in """${output}"""   issh.Execute
    ...   command=${password}   check_result=False    alias=${alias}
    ${matched}=  get regexp matches   ${power}   TX=(\(-?\\d+\)\(\\.\\d+).*FB=\(-?\\d+\)\(\\.\\d+\))
    ${len}=  get length   ${matched}
    ${power_sucessful_count}    run keyword if    ${len} >= 1    Evaluate     ${power_sucessful_count}+1
    run keyword and continue on failure      Should be true    ${len}>=1
    ...   No power detected on vdu${vdu_index}_ru_${RF_ip}+att_${index}
    [Return]    ${power_sucessful_count}
