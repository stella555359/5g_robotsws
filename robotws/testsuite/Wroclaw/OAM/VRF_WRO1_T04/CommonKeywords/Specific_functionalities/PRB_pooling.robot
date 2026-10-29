*** Settings ***
Documentation
...    Author:          Jakub Klein & Pawel Gorczynski
...    Maintainer:      Jakub Klein & Pawel Gorczynski
...    Contact:         jakub.klein@nokia.com
...    Team in charge:  I_EXT_PZ_1_WRO_3
...    Description:     The following keywords are responsible for PRB pooling operations

Resource    ../Commissioning_preparation/Commissioning.robot
Library     taf.sbts.oam.coam.admin    WITH NAME    admin_cli
Library     taf.config.scf    WITH NAME    scf
Library     SSHLibrary

*** Variables ***
${UE_control_pc}    ${tl.ues[0].ssh_connection_details.addr}
${UE_control_pc_user}    ${tl.ues[0].ssh_connection_details.username}
${UE_control_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${APPSERVER_IP}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
${APPS_USERNAME}    ${tl.appserver.iperf_details.ssh_connection_details.username}
${APPS_PASSWORD}    ${tl.appserver.iperf_details.ssh_connection_details.password}
${APPS_NETWORK_IF}    ${tl.appserver.iperf_details.network_interface_address}

${ENB_ID}    ${tl.gnbs[0].global_bts_id}
${PrbPath}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/NRCELL-3
${BwpDN}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/NRCELL-3
${Bwp4Path}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/BWP_PROFILE-4
${Bwp31Path}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/BWP_PROFILE-31
${Bwp33Path}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/BWP_PROFILE-33
${Bwp141Path}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/BWP_PROFILE-141
${Bwp153Path}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/BWP_PROFILE-153

${actLteNrDSS}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}
${actRateMatchedCsiIm}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/NRCELL-3/NRDSSLTE-1
${lteNrDssMode}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/NRCELL-3
${actLteNrDssFastAlloc}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/NRCELL-3/NRDSSLTE-1

${chBw}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/NRCELL-3/NRCELL_FDD-1
${nrarfcn}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/NRCELL-3/NRCELL_FDD-1
${actAsymBwGuardband}    MRBTS-${ENB_ID}/NRBTS-${ENB_ID}/NRCELL-3/NRCELL_FDD-1

${HOST}=    192.168.255.129
${USERNAME}=     toor4nsn
${PASSWORD}=    oZPS0POrRieRtu

&{expected_statuses}    operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked

*** Keywords ***
Download And Compare Current Counters With Previous Measurement If Exist And Save Current Counters
    [Arguments]    ${current_counters}    ${path_on_ue_pc}=/home/wro5goam/counter/    ${path_on_vm}=/home/ute/
    ...    ${file_name}=counters.csv    ${path_to_actual_counters}=${OUTPUTDIR}/current_counters.csv
    ${active_SW}=    admin_cli.Get Sw Version
    Connect To UE PC    ${UE_control_pc}    ${UE_control_pc_user}    ${UE_control_pc_password}    cpc
    ${exist}    ${file_name}=    Check Whether Counters File Exist On UE Pc    ${path_on_ue_pc}    cpc
    Run Keyword If    ${exist}    Download Previous Counters    ${path_on_ue_pc}${file_name}    ${path_on_vm}    ${file_name}    cpc
    ${previous_counters}=    Run Keyword If    ${exist}    Open Counter File    ${path_on_vm}${file_name}
    Run Keyword If    ${exist}    ssh.Download File    ${path_on_ue_pc}${file_name}    ${OUTPUTDIR}/${file_name}    cpc
    Run Keyword If    ${exist}    Compare Counters From Two Measurements    ${previous_counters}    ${current_counters}
    Run Keyword If    ${exist}    ssh.Send Command    command=rm /home/wro5goam/counter/*    connection=cpc
    Send Counter File To Ue Pc    ${path_to_actual_counters}    counters_${active_SW}.csv
    [Teardown]    Disconnect From UE PC

Send Counter File To Ue Pc
    [Arguments]    ${path_to_actual_counters}    ${counter_file_name}=counters.csv
    ssh.Send Command    command=mkdir /home/wro5goam/counter    connection=cpc
#    ssh.Send Command    command=type nul >/home/wro5goam/counter/counter.csv    connection=cpc
    Sleep    5s
    ssh.Upload File    ${path_to_actual_counters}    /home/wro5goam/counter/${counter_file_name}    connection=cpc

Download Previous Counters
    [Arguments]    ${path_on_pc}    ${path_on_vm}    ${file_name}    ${connection}=cpc
    ssh.Download File    ${path_on_pc}    ${path_on_vm}${file_name}    ${connection}

Check Whether Counters File Exist On UE Pc
    [Arguments]    ${path_on_ue_pc}=/home/wro5goam/    ${connection}=cpc
    ssh.send command    cd /home/wro5goam/counter/ && ls counters*    connection=cpc
    ${file_name}=    ssh.read output    connection=cpc
    ${file_name}=    Run Keyword And Ignore Error    Should Match Regexp    ${file_name}    counters.+.csv    msg=False    values=False
    ${file_name}=    Set Variable    ${file_name}[1]
    ${exist}=    Run Keyword And Return Status    Should not be equal as strings    ${file_name}    False
#    ${exist}=    ssh.File Exists    /home/wro5goam/counter/counter*    cpc
    [Return]    ${exist}    ${file_name}

Check stability of counters
    [Arguments]  ${condition}  ${number_of_PMs}  ${PM_file_path}=None  @{counters_list}
    ${PM_list}  ${index_name}=  Download PMs  ${number_of_PMs}
    ${current_counters}  ${path}=  Check Counter Condition On Each Object    ${condition}    ${index_name}    ${counters_list}    ${PM_file_path}
    [Return]    ${current_counters}    ${path}

Download PMs
    [Arguments]  ${expected_number_of_PMs}=3
    ${result}=  Run  find /home/ute/ -name 'PMs' | grep -q PMs && echo 'True' || echo 'False'
    Run Keyword If  '${result}'=='True'  Run  rm -r /home/ute/PMs
    Run  mkdir /home/ute/PMs
    Connect Ssh To Asix
    ${PM_list}=  ssh.Execute  command=find /tmp/PM.BTS*ANY.xml.gz  connection=asik
    ${PM_list}=  Strip String  ${PM_list}  mode=right  characters=\r\n
    @{PM_list}=  Split String  ${PM_list}  \r\n
    ${number_of_PMs}=  Get Length  ${PM_list}
    ${result}=  Evaluate  ${number_of_PMs}>=2
    Should be True  ${result}
    ssh.Download_File   remote_path=${PM_list[-${expected_number_of_PMs}:]}
    ...     local_path=/home/ute/PMs
    ...     connection=asik
    Run  gunzip /home/ute/PMs/*
    ${PM_list}=  Run  find /home/ute/PMs/ -name 'PM.*'
    @{PM_list}=  Split String  ${PM_list}
    ${index_name}=  Get Index From PM File Name  ${PM_list}
    [Teardown]  Disconnect Ssh From Asix
    [Return]  ${PM_list}  ${index_name}

Get index from PM file name
    [Arguments]    ${PM_list}
    ${index_path}=  Create Dictionary
    FOR  ${PM_file}  IN  @{PM_list}
        ${name}=  Fetch from right  ${PM_file}  /
        ${name}=  Get Regexp Matches  ${name}  \\d+(?=.ANY)
        Set To Dictionary  ${index_path}  ${PM_file}  ${name[0]}
    END
    [Return]  ${index_path}

Prepare TL662
    [Arguments]    ${scf_7113}
    Wait Until Keyword Succeeds    1 min    30 sec    admin_cli.Perform Commissioning
    ...     scf_file=${scf_7113}    #/home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM1/CB007113/7113_Resources/CB007113_CIT.xml
    ...     skip_parameter_relation_errors=${False}
    ...     should_activate=${True}
    ...     timeout=900
    Wait Until Keyword Succeeds    900    10    component_states_checker.Check if BTS is OnAir state

Activate base SCF without Pooling
    ${SW}=      admin_cli.get_sw_version
    ${SW1}=     fetch from left    ${SW}    _
#    Run Keyword If    "${SW1}" == 'SBTS24R2'
#    ...    Prepare TL662    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM1/CB007113/7113_Resources/SCF_TL662_PoolingOFF_Trunk.xml
    Prepare TL662    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM1/CB007113/7113_Resources/SCF_TL662_PoolingOFF.xml

Activate SCF with Pooling and two cells
    ${SW}=      admin_cli.get_sw_version
    ${SW1}=     fetch from left    ${SW}    _
    Run Keyword If    "${SW1}" == 'SBTS24R2'
    ...    Prepare TL662
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM1/CB007113/7113_Resources/SCF_TL662_two_cells_PoolingON_Trunk.xml
    ...    ELSE    Prepare TL662
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM1/CB007113/7113_Resources/SCF_TL662_two_cells_PoolingON.xml

Crash BBRM
    Open connection         ${HOST}
    Login                   ${USERNAME}         ${PASSWORD}
    SSHLibrary.Start Command  bsh 1:1 ps ax | grep l1_application_n | grep -v grep | awk '{print $1}'
    ${pid}=  Read Command Output
    SSHLibrary.Execute Command  bsh 1:1 kill -9 ${pid}
    wait until keyword succeeds   100   2   Wait For Fault with Alarm to appear   2087    7101
    [Teardown]  Close Connection

Check 7113 Feature State
    Get SCF file from BTS
    ${7113_status}=  Get value from SCF  MRBTS-50928/NRBTS-50928	 actBbPoolTddFr1
    [Return]  ${7113_status}

Deactivate Feature 7113
    Set BBPooling Parameters    false    skip_parameter_relation_errors=False
    Wait Until Keyword Succeeds    900    10    component_states_checker.Check if BTS is OnAir state
#    Remove Flag From Swconfig File cOAM1    0x420068=4     #flag no longer in use

Activate BBPooling Parameters
    Wait Until Keyword Succeeds    900    10    component_states_checker.Check if BTS is OnAir state
#    Add Flag In Swconfig File cOAM1    0x420068=4
#    Wait Until Keyword Succeeds    900    10    component_states_checker.Check if BTS is OnAir state
    Set BBPooling Parameters    true    skip_parameter_relation_errors=false
    Wait Until Keyword Succeeds    900    10    component_states_checker.Check if BTS is OnAir state

#Set BBPooling Parameters
#    [Arguments]    ${set}    ${skip_parameter_relation_errors}=False
#    ${scf_file}=     admin_cli.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=basic_SCF.xml
#    scf.load_scf    ${scf_file}
#    scf.modify_scf_element  value=${set}  dist_name=MRBTS-50928/NRBTS-50928  p_name=actBbPoolTddFr1  #false
#    Set Algorithm Enhancement
#    scf.save_scf  file_path=${scf_file}
#    admin_cli.perform_commissioning    scf_file=${scf_file}
#    ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}
#    ...     should_activate=True

Set BBPooling Parameters
    [Arguments]    ${set}=None    ${LBT}=False    ${skip_parameter_relation_errors}=False
    ${scf_file}=     admin_cli.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=basic_SCF.xml
    scf.load_scf    ${scf_file}
    Run Keyword Unless    ${LBT}    Set actBbPoolTddFr1    ${set}
#    scf.modify_scf_element  value=${set}  dist_name=MRBTS-50928/NRBTS-50928  p_name=actBbPoolTddFr1  #false
    Set Algorithm Enhancement
    scf.save_scf  file_path=${scf_file}
    admin_cli.perform_commissioning    scf_file=${scf_file}
    ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...     should_activate=True
    Wait Until Keyword Succeeds    900    10    component_states_checker.Check if BTS is OnAir state

Set actBbPoolTddFr1
    [Arguments]    ${set}    ${skip_parameter_relation_errors}=False
    scf.modify_scf_element  value=${set}  dist_name=MRBTS-50928/NRBTS-50928  p_name=actBbPoolTddFr1  #false

Set actBbPoolTddFr1AlgEnh
    [Arguments]    ${set}    ${skip_parameter_relation_errors}=False
    scf.modify_scf_element  value=${set}  dist_name=MRBTS-50928/NRBTS-50928  p_name=actBbPoolTddFr1AlgEnh    #false

Set tmpActFeat2
    [Arguments]    ${set}    ${skip_parameter_relation_errors}=False
    scf.modify_scf_element  value=${set}  dist_name=MRBTS-50928/NRBTS-50928  p_name=tmpActFeat2    #false

Set Algorithm Enhancement
    [Documentation]    Parameter introduced with LBT27586 for activation algorithm enhancement varies batween branches.
    ...    For 23R3, 23R4 it is tmpActFeat2 and for 24R1 and further realases it is actBbPoolTddFr1AlgEnh.
    ${SW}=      admin_cli.get_sw_version
    ${SW1}=     fetch from left    ${SW}    _
    Run Keyword If    "${SW1}" == 'SBTS23R4'    Set tmpActFeat2    1    skip_parameter_relation_errors=False
    ...    ELSE IF    "${SW1}" == 'SBTS23R3'    Set tmpActFeat2    1    skip_parameter_relation_errors=False
    ...    ELSE    Set actBbPoolTddFr1AlgEnh    true    skip_parameter_relation_errors=False

Set parameter to expected value
    [Arguments]   ${parameters_dict}  ${skip_parameter_relation_errors}=False
    ${scf_file}=     admin_cli.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=basic_SCF.xml
    scf.load_scf    ${scf_file}
    FOR  ${key}  IN  @{parameters_dict.keys()}
        Log  ${key}
        Log  ${parameters_dict["${key}"]}
        scf.modify_scf_element  value=${parameters_dict["${key}"]}  dist_name=MRBTS-50928/NRBTS-50928  p_name=${key}
    END
    scf.save_scf  file_path=${scf_file}
    admin_cli.perform_commissioning    scf_file=${scf_file}
    ...     skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...     should_activate=True

Activate delta with BBPooling feature
    ${SW}=      admin_cli.get_sw_version
    ${SW1}=     fetch from left    ${SW}    _
    Run Keyword If    "${SW1}" == 'SBTS23R4'
    ...    Activate CB008940 Parameters
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM1/CB008940/Resources/delta_with_pooling_parameters.json
    ...    ELSE IF    "${SW1}" == 'SBTS23R3'
    ...    Activate CB008940 Parameters
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM1/CB008940/Resources/delta_with_pooling_parameters.json
    ...    ELSE    Activate CB008940 Parameters
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/cOAM1/CB008940/Resources/delta_with_pooling_parameters_trunk.json

Activate CB008940 Parameters
    [Arguments]  ${delta_path}
    admin_cli.perform_delta_recommissioning
    ...     delta_file=${delta_path}
    ...     skip_parameter_relation_errors=False
    ...     should_activate=True
    ...     timeout=1800

Prepare And Upload Vendor File
    [Arguments]    ${DL}=${False}
    admin_cli.download_vendor_file    /home/ute/Downloads/vendor_file_test
    ${xml}=    Parse XML    /home/ute/Downloads/vendor_file_test
    Set Element To Proper Value    ${xml}    ${DL}
    Save Xml    ${xml}    /home/ute/Downloads/vendor_file_new

Set Element To Proper Value
    [Arguments]    ${xml}    ${DL}
    ${xpath_main_1}=    Set Variable
    ...    .//item[p[@name="bbHwVariant"][contains(text(), "ABIO")] and p[@name="csSize"][contains(text(), "64")] and
    ${xpath_main_2}=    Set Variable
    ...    p[@name="direction"][contains(text(), "UL")] and p[@name="l1PoolType"][contains(text(), "NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm")]]
    ${xpath1}=    Set Variable    /p[@name="maxNumStreamPrbL1Sp"]
    ${xpath2}=    Set Variable    /p[@name="maxNumLayerPrbL1Sp"]
    ${stream}=    Catenate    ${xpath_main_1}    ${xpath_main_2}    ${xpath1}
    ${layer}=    Catenate    ${xpath_main_1}    ${xpath_main_2}    ${xpath2}
    Set Element Text    ${xml}    1000    xpath=${stream}
    Set Element Text    ${xml}    500    xpath=${layer}
    ${xpath_main}=    Set Variable
    ...    .//item[p[@name="bbHwVariant"][contains(text(), "ABIO")] and p[@name="csSize"][contains(text(), "32")] and
    ${xpath_main_2}=    Set Variable
    ...    p[@name="direction"][contains(text(), "UL")] and p[@name="l1PoolType"][contains(text(), "NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm")]]
    ${xpath1}=    Set Variable    /p[@name="maxNumStreamPrbL1Sp"]
    ${xpath2}=    Set Variable    /p[@name="maxNumLayerPrbL1Sp"]
    ${stream}=    Catenate    ${xpath_main}    ${xpath_main_2}    ${xpath1}
    ${layer}=    Catenate    ${xpath_main}    ${xpath_main_2}    ${xpath2}
    Set Element Text    ${xml}    500    xpath=${stream}
    Set Element Text    ${xml}    250    xpath=${layer}
    Set Element Text    ${xml}    50    xpath=.//p[@name="bbPoolEvalPeriod"]
    Set Element Text    ${xml}    load-metric    xpath=.//p[@name="bbPoolMode"]
    Run Keyword If    ${DL}==${True}    Set Vendor File For DL    ${xml}

Set Vendor File For DL
    [Arguments]    ${xml}
    ${xpath_main_1}=    Set Variable
    ...    .//item[p[@name="bbHwVariant"][contains(text(), "ABIO")] and p[@name="csSize"][contains(text(), "48")] and
    ${xpath_main_2}=    Set Variable
    ...    p[@name="direction"][contains(text(), "DL")] and p[@name="l1PoolType"][contains(text(), "NR_L1_Loki_TDD_FR1_eCPRI_IQF_Asymm")]]
    ${xpath1}=    Set Variable    /p[@name="maxNumStreamPrbL1Sp"]
    ${xpath2}=    Set Variable    /p[@name="maxNumLayerPrbL1Sp"]
    ${stream}=    Catenate    ${xpath_main_1}    ${xpath_main_2}    ${xpath1}
    ${layer}=    Catenate    ${xpath_main_1}    ${xpath_main_2}    ${xpath2}
    Set Element Text    ${xml}    1200    xpath=${stream}
    Set Element Text    ${xml}    1200    xpath=${layer}

Activate SCF
    [Arguments]    ${scfpath}
    wait until keyword succeeds  2 min   30 sec   admin_cli.Perform Commissioning
        ...     scf_file=${scfpath}
        ...     skip_parameter_relation_errors=${True}
        ...     connection=default
        ...     timeout=900

Activate PRB pooling if not activated
    [Arguments]    ${connection}=default
    ${state}    Check PRB pooling activation status    ${connection}
    Run Keyword If    "${state}"!="True"
    ...    Activate PRB pooling with 8 cells

Deactivate PRB pooling if is activated
    [Arguments]    ${connection}=default
    ${state}    Check PRB pooling activation status    ${connection}
    Run Keyword If    "${state}"=="True"
    ...    Restoring correct commissioning    ${connection}

Check PRB pooling activation status
    [Arguments]    ${connection}=default
    ${cur_scf_content}    admin_cli.get_scf    connection=${connection}
    ${pooling_state}      Run keyword and return status
    ...                   should contain    ${cur_scf_content}    "actSlowPrbPooling">true
    ${pooling_state}      convert to string    ${pooling_state}
    Run keyword if        "${pooling_state}"=="False"
    ...                   should contain    ${cur_scf_content}    "actSlowPrbPooling">false
    [Return]    ${pooling_state}

Verify If is less than max
    [Arguments]    ${cell1}    ${cell2}    ${cell3}    ${sfn_list}    ${item}    ${1_tg}    ${2_tg}    ${3_tg}
    ${high_PRB}=    Create List
    Run Keyword If    ${cell1}==${1_tg} and ${cell2}==${2_tg} and ${cell3}==${3_tg}
    ...    Append To List    ${high_PRB}    ${cell1}
    Run Keyword If    ${cell1}==${1_tg} and ${cell2}==${3_tg} and ${cell3}==${2_tg}
    ...    Append To List    ${high_PRB}    ${cell1}
    Run Keyword If    ${cell1}==${2_tg} and ${cell2}==${1_tg} and ${cell3}==${3_tg}
    ...    Append To List    ${high_PRB}    ${cell2}
    Run Keyword If    ${cell1}==${2_tg} and ${cell2}==${3_tg} and ${cell3}==${1_tg}
    ...    Append To List    ${high_PRB}    ${cell3}
    Run Keyword If    ${cell1}==${3_tg} and ${cell2}==${2_tg} and ${cell3}==${1_tg}
    ...    Append To List    ${high_PRB}    ${cell3}
    Run Keyword If    ${cell1}==${3_tg} and ${cell2}==${1_tg} and ${cell3}==${2_tg}
    ...    Append To List    ${high_PRB}    ${cell2}
    ${licznik}=     Get Length    ${high_PRB}
    Run Keyword If    ${licznik}==1
    ...     Append To List    ${sfn_list}    ${item}

L1L2 Sherpa Verifier
    [Arguments]    ${l1l2sherpa}     ${sfn}    ${target}    ${0_tg}    ${1_tg}    ${2_tg}    ${3_tg}
    ${sfn_list}      Create List
    FOR     ${item}    IN    @{sfn}
         ${bbrm}=         Get From Dictionary    ${l1l2sherpa}    ${item}
         ${subcell}=      Get From Dictionary    ${bbrm}    id_0
         ${cell0}=         Get From Dictionary    ${subcell}    834158592
         ${cell0}=         Convert To Integer     ${cell0}
         ${cell1}=         Get From Dictionary    ${subcell}    834158594
         ${cell1}=         Convert To Integer     ${cell1}
         ${cell2}=         Get From Dictionary    ${subcell}    834158596
         ${cell2}=         Convert To Integer     ${cell2}
         ${cell3}=         Get From Dictionary    ${subcell}    834158598
         ${cell3}=         Convert To Integer     ${cell3}
         Run Keyword If    ${cell0}==${0_tg}
         ...     Verify If is less than max    ${cell1}    ${cell2}    ${cell3}    ${sfn_list}
         ...                                   ${item}     ${1_tg}     ${2_tg}     ${3_tg}
    END
    ${size_with_proper_PRB}=     Get Length    ${sfn_list}
    ${size_of_sfn}=              Get Length    ${sfn}
    ${eval}=     Evaluate    ${size_of_sfn}*${target}
    Should Be True    ${size_with_proper_PRB} > ${eval}

L1L2 Sherpa Verifier 9cell
    [Arguments]    ${l1l2sherpa}     ${sfn}    ${target}    ${0_tg}    ${1_tg}    ${2_tg}
    ${sfn_list}      Create List
    FOR     ${item}    IN    @{sfn}
         ${bbrm}=         Get From Dictionary    ${l1l2sherpa}    ${item}
         ${subcell}=      Get From Dictionary    ${bbrm}    id_0
         ${cell0}=         Get From Dictionary    ${subcell}    834158592
         ${cell0}=         Convert To Integer     ${cell0}
         ${cell1}=         Get From Dictionary    ${subcell}    834158594
         ${cell1}=         Convert To Integer     ${cell1}
         ${cell2}=         Get From Dictionary    ${subcell}    834158597
         ${cell2}=         Convert To Integer     ${cell2}
         ${cell3}=         Get From Dictionary    ${subcell}    834158598
         ${cell3}=         Convert To Integer     ${cell3}
         ${cell4}=         Get From Dictionary    ${subcell}    834158600
         ${cell4}=         Convert To Integer     ${cell4}
         Run Keyword If    ${cell0}==${0_tg}
         ...     Verify If is less than max 9 cell    ${cell1}    ${cell2}    ${cell3}    ${cell4}
         ...     ${sfn_list}    ${item}   ${1_tg}    ${2_tg}
    END
    ${size_with_proper_PRB}=     Get Length    ${sfn_list}
    ${size_of_sfn}=              Get Length    ${sfn}
    ${eval}=     Evaluate    ${size_of_sfn}*${target}
    Should Be True    ${size_with_proper_PRB} > ${eval}

Verify If is less than max 9 cell
    [Arguments]    ${cell1}    ${cell2}    ${cell3}    ${cell4}    ${sfn_list}    ${item}    ${1_tg}    ${2_tg}
    ${high_PRB}=    Create List
    Run Keyword If    ${cell1}==${1_tg} and ${cell2}==${2_tg} and ${cell3}==${2_tg} and ${cell4}==${2_tg}
    ...    Append To List    ${high_PRB}    ${cell1}
    Run Keyword If    ${cell1}==${2_tg} and ${cell2}==${1_tg} and ${cell3}==${2_tg} and ${cell4}==${2_tg}
    ...    Append To List    ${high_PRB}    ${cell2}
    Run Keyword If    ${cell1}==${2_tg} and ${cell2}==${2_tg} and ${cell3}==${1_tg} and ${cell4}==${2_tg}
    ...    Append To List    ${high_PRB}    ${cell3}
    Run Keyword If    ${cell1}==${2_tg} and ${cell2}==${2_tg} and ${cell3}==${2_tg} and ${cell4}==${1_tg}
    ...    Append To List    ${high_PRB}    ${cell4}
    ${licznik}=     Get Length    ${high_PRB}
    Run Keyword If    ${licznik}==1
    ...     Append To List    ${sfn_list}    ${item}

Upload SCF and check validation error
    ${comm_status}    ${comm_results}    run keyword and ignore error    admin_cli.Perform Commissioning
    ...     scf_file=${scf}
    ...     skip_parameter_relation_errors=${False}
    ...     should_activate=${False}
    ...     connection=default
    ...     timeout=900
    should contain    '${comm_status}'    FAIL
    ${comm_results}    Fetch From Right    ${comm_results}    'pdlValidationResult'
    ${msg_part}    set variable    actSlowPrbPooling} (value: true) equal to true, it is required that
    should contain   ${comm_results}    ${msg_part} \${NRDSSLTE-1.ssbPosition} (value: pos6) equal to pos1

Prepare SCF with SlowPrBPooling
    ${scf_disp}    ${scf}    Start Delta preparation
    ${version}    scf.get_mo_attribute    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1    version
    scf.add_object_to_scf    com.nokia.srbts.nrbts:NRDSSLTE
    ...                      MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1/NRDSSLTE-1    ${version}
    Add Cell parameter       MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1/NRDSSLTE-1    ${additional_changes1}
    Modify Cell parameter    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}    ${additional_changes2}
    scf.save_scf    ${scf}
    set test variable    ${scf}

Reset Site and wait for onAir
    log to console      performing Site Reset
    admin_cli.reset_site
    Wait Until Keyword Succeeds    500    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

#Assymetrical Cell Keywords
AsymON
    ${scf_disp}    ${scf}    Start Delta preparation
    Modify Element in string    ${chBw}    chBwUl    10MHz
    Modify Element in string    ${nrarfcn}    nrarfcnDl    436000
    Modify Element in string    ${nrarfcn}    nrarfcnUl    355000
    Modify Element in string    ${actAsymBwGuardband}    actAsymBwGuardband    true
    Create and upload Delta    ${scf_disp}    ${scf}
    &{expected_status}    create dictionary    availabilityStatus=online
    ...                                        operationalState=enabled
    ...                                        administrativeState=unlocked
    Wait Until Keyword Succeeds    20min    15sec
    ...    Check specific status on selected component    NRCELL-All    ${expected_status}
    Update bwpDN    ${BwpDN}    ${Bwp4Path}    0    ${Bwp31Path}    1

AsymOFF
    ${scf_disp}    ${scf}    Start Delta preparation
    Modify Element in string    ${chBw}    chBwUl    20MHz
    Modify Element in string    ${nrarfcn}    nrarfcnDl    437280
    Modify Element in string    ${nrarfcn}    nrarfcnUl    353260
    Modify Element in string    ${actAsymBwGuardband}    actAsymBwGuardband    false
    Create and upload Delta    ${scf_disp}    ${scf}
    &{expected_status}    create dictionary    availabilityStatus=online
    ...                                        operationalState=enabled
    ...                                        administrativeState=unlocked
    Wait Until Keyword Succeeds    20min    15sec
    ...    Check specific status on selected component    NRCELL-All    ${expected_status}
    Update bwpDN    ${BwpDN}    ${Bwp4Path}    0    ${Bwp33Path}    1

#Asym Parameters
Setup chBwUl
    [Arguments]    ${dist_name}    ${value}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=chBwUl
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            should_activate=${True}
    ...                                            skip_parameter_relation_errors=${True}

Setup nrarfcn
    [Arguments]    ${dist_name}    ${value1}    ${value2}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=nrarfcnDl
    ...                                            value=${value1}
    ...                                            operation=update
    ...                                            should_activate=${True}
    ...                                            skip_parameter_relation_errors=${True}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=nrarfcnUl
    ...                                            value=${value2}
    ...                                            operation=update
    ...                                            should_activate=${True}
    ...                                            skip_parameter_relation_errors=${True}

Setup actAsymBwGuardband
    [Arguments]    ${dist_name}    ${value}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=actAsymBwGuardband
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            should_activate=${True}
    ...                                            skip_parameter_relation_errors=${True}

#DSS keywords
DSSON
#    Setup actLteNrDSS    ${actLteNrDSS}    true
    Setup lteNrDssMode    ${lteNrDssMode}    DSS_Phase_3
    Setup actRateMatchedCsiIm    ${actRateMatchedCsiIm}    true
    Setup actLteNrDssFastAlloc     ${actLteNrDssFastAlloc}    true
    Update bwpDN    ${BwpDN}    ${Bwp141Path}    0    ${Bwp153Path}    1

DSSOFF
    Setup actLteNrDssFastAlloc     ${actLteNrDssFastAlloc}    false
    Setup actRateMatchedCsiIm    ${actRateMatchedCsiIm}    false
    Setup lteNrDssMode    ${lteNrDssMode}    none
#    Setup actLteNrDSS    ${actLteNrDSS}    false
    Update bwpDN    ${BwpDN}    ${Bwp4Path}    0    ${Bwp33Path}    1

#DSS Parameters
Setup actLteNrDSS
    [Arguments]    ${dist_name}    ${value}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=actLteNrDss
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}

Setup actRateMatchedCsiIm
    [Arguments]    ${dist_name}    ${value}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=actRateMatchedCsiIm
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}

Setup lteNrDssMode
    [Arguments]    ${dist_name}    ${value}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=lteNrDssMode
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}

Setup actLteNrDssFastAlloc
    [Arguments]    ${dist_name}    ${value}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=actLteNrDssFastAlloc
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}

#PRB Blanking keywrods
PRBON
    Setup PRB Blanking    ${PrbPath}    true
    Setup Edges    ${PrbPath}    0    0    1    1

PRBOFF
    Setup PRB Blanking    ${PrbPath}    false
    Setup Edges    ${PrbPath}    0    0    0    0

BothEdge
    Setup PRB Blanking    ${PrbPath}    true
    Setup Edges    ${PrbPath}    3    3    1    1
    Update BWP Profiles    ${Bwp133Path}    n102    crb1
    Update bwpDN    ${BwpDN}    ${Bwp133Path}   0    ${Bwp130Path}    1

LowEdge
    Setup PRB Blanking    ${PrbPath}    true
    Setup Edges    ${PrbPath}    0    0    1    1
    Update BWP Profiles    ${Bwp133Path}    n105    crb1
    Update bwpDN    ${BwpDN}    ${Bwp133Path}   0    ${Bwp130Path}    1

HighEdge
    Setup PRB Blanking    ${PrbPath}    true
    Setup Edges    ${PrbPath}    3    3    0    0
    Update BWP Profiles    ${Bwp133Path}    n103    crb0
    Update bwpDN    ${BwpDN}    ${Bwp133Path}   0    ${Bwp130Path}    1

#PRB Parameters
Setup PRB Blanking
    [Arguments]    ${dist_name}    ${value}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=actPRBBlanking
    ...                                            value=${value}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}

Setup Edges
    [Arguments]    ${dist_name}    ${highdl}    ${highul}    ${lowdl}    ${lowul}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=nbrOfBlankedPRBsHighEdgeDL
    ...                                            value=${highdl}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=nbrOfBlankedPRBsHighEdgeUL
    ...                                            value=${highul}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=nbrOfBlankedPRBsLowEdgeDL
    ...                                            value=${lowdl}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=nbrOfBlankedPRBsLowEdgeUL
    ...                                            value=${lowul}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}

#BWP Profiles
Update BWP Profiles
    [Arguments]    ${dist_name}    ${cRbSizeUl}    ${cRbStartUl}
    ${list_param_to_change}=    Create Dictionary    cRbSizeUl    ${cRbSizeUl}
    Set To Dictionary    ${list_param_to_change}    cRbStartUl=${cRbStartUl}
    @{list}=    create list    ${list_param_to_change}
    admin_cli.perform_parameter_recommissioning    dist_name=${dist_name}
    ...                                            parameter=locationAndBandwidthUl
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            should_activate=${True}
    ...                                            skip_parameter_relation_errors=${True}

Update bwpDN
    [Arguments]    ${dist_name}    ${S1bwpDN}    ${S1cellBwpId}    ${S2bwpDN}    ${S2cellBwpId}
    ${list_param_to_change1}=    Create Dictionary    bwpDN=${S1bwpDN}    cellBwpId=${S1cellBwpId}
    ...                                               actPdcchCceFragmentControl=False
    ...                                               actUpperThrAckNackFiltering=False
    ...                                               actUpperThrAckNackHrFiltering=False
    ...                                               pdcchResourcePreference=peakRate
    ${list_param_to_change2}=    Create Dictionary    bwpDN=${S2bwpDN}    cellBwpId=${S2cellBwpId}
    ...                                               actPdcchCceFragmentControl=False
    ...                                               actUpperThrAckNackFiltering=False
    ...                                               actUpperThrAckNackHrFiltering=False
    ...                                               pdcchResourcePreference=peakRate
    @{list}=    create list    ${list_param_to_change1}    ${list_param_to_change2}
    admin_cli.perform_parameter_recommissioning    dist_name=${dist_name}
    ...                                            parameter=cellBwpList
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            should_activate=${True}
    ...                                            skip_parameter_relation_errors=${True}

#DlTotalLoad
TargetTotalLoadOFF
    [Arguments]    ${dist_name}    ${targetTotalLoad}    ${maxNumPdschAllocationPerSlot}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=targetTotalLoad
    ...                                            value=${targettotalload}
    ...                                            operation=delete
    ...                                            skip_parameter_relation_errors=${True}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=maxNumPdschAllocationPerSlot
    ...                                            value=${maxNumPdschAllocationPerSlot}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}

SetTotalLoadOFF
    TargetTotalLoadOFF   ${PrbPath}    0    1

TargetTotalLoadON
    [Arguments]    ${dist_name}    ${targetTotalLoad}    ${maxNumPdschAllocationPerSlot}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=targetTotalLoad
    ...                                            value=${targettotalload}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}
    admin_cli.perform_parameter_recommissioning        dist_name=${dist_name}
    ...                                            parameter=maxNumPdschAllocationPerSlot
    ...                                            value=${maxNumPdschAllocationPerSlot}
    ...                                            operation=update
    ...                                            skip_parameter_relation_errors=${True}

SetTotalLoadON
    TargetTotalLoadON   ${PrbPath}    100    2

Check Cells Size
    [Arguments]    ${l1l2sherpa}     ${sfn}    ${cellid0}  ${cellid01}  ${cellid1}  ${cellid2}  ${cellid3}  ${cellid4}
    ${SW}=      admin_cli.get_sw_version
    ${SW1}=     fetch from left    ${SW}    _
    #    ${id}=    Run Keyword If  '${SW1}'=='SBTS22R4'  Set Variable  id_65535  ELSE  Set Variable  id_0
    ${id}=    Set Variable  id_0
    FOR     ${item}    IN    @{sfn}
         ${bbrm}=         Get From Dictionary    ${l1l2sherpa}    ${item}
         ${subcell0}=      Get From Dictionary    ${bbrm}    id_0
         ${subcell1}=      Get From Dictionary    ${bbrm}    id_1
         &{subcell}=       Create Dictionary      &{subcell0}    &{subcell1}

         ${exist}=  Run Keyword And Return Status    Dictionary Should Contain Key    ${subcell}    ${cellid0}
         ${sizearg0}=         Run Keyword If  ${exist}  Get From Dictionary    ${subcell}    ${cellid0}
         ...    ELSE    Get From Dictionary    ${subcell}    ${cellid01}
         ${sizearg0}=         Convert To Integer     ${sizearg0}
         ${sizearg1}=         Get From Dictionary    ${subcell}    ${cellid1}
         ${sizearg1}=         Convert To Integer     ${sizearg1}
         ${sizearg2}=         Get From Dictionary    ${subcell}    ${cellid2}
         ${sizearg2}=         Convert To Integer     ${sizearg2}
         ${sizearg3}=         Get From Dictionary    ${subcell}    ${cellid3}
         ${sizearg3}=         Convert To Integer     ${sizearg3}
         ${sizearg4}=         Get From Dictionary    ${subcell}    ${cellid4}
         ${sizearg4}=         Convert To Integer     ${sizearg4}
    END
    Set Test Variable    ${sizearg0}
    Set Test Variable    ${sizearg1}
    Set Test Variable    ${sizearg2}
    Set Test Variable    ${sizearg3}
    Set Test Variable    ${sizearg4}

Check Cells Size With DSS
    [Arguments]    ${l1l2sherpa}     ${sfn}
    FOR     ${item}    IN    @{sfn}
         ${bbrm}=         Get From Dictionary    ${l1l2sherpa}    ${item}
         ${subcell}=      Get From Dictionary    ${bbrm}    id_0
         ${sizearg0}=         Get From Dictionary    ${subcell}    834158594
         ${sizearg0}=         Convert To Integer     ${sizearg0}
         ${sizearg1}=         Get From Dictionary    ${subcell}    834158595
         ${sizearg1}=         Convert To Integer     ${sizearg1}
         ${sizearg2}=         Get From Dictionary    ${subcell}    834158598
         ${sizearg2}=         Convert To Integer     ${sizearg2}
         ${sizearg3}=         Get From Dictionary    ${subcell}    834158602
         ${sizearg3}=         Convert To Integer     ${sizearg3}
         ${sizearg4}=         Get From Dictionary    ${subcell}    834158604
         ${sizearg4}=         Convert To Integer     ${sizearg4}
    END
    Set Test Variable    ${sizearg0}
    Set Test Variable    ${sizearg1}
    Set Test Variable    ${sizearg2}
    Set Test Variable    ${sizearg3}
    Set Test Variable    ${sizearg4}

Verify Cells Size Without PRB Blanking
    [Arguments]    ${sizearg0}     ${sizearg1}    ${sizearg2}    ${sizearg3}    ${sizearg4}
    ${sumsize}=    Evaluate    4*${sizearg0}+4*${sizearg1}+4*${sizearg2}+4*${sizearg3}+4*${sizearg4}
    Log To Console    ${sumsize}
    Pass Execution If  ${sizearg1}==106 and ${sumsize}>=1406
                        ...    Good PRB Allocation
    Fail    Wrong PRBs allocation

Verify Cells Size With PRB Blanking
    [Arguments]    ${sizearg0}     ${sizearg1}    ${sizearg2}    ${sizearg3}    ${sizearg4}
    ${sumsize}=    Evaluate    4*${sizearg0}+4*${sizearg1}+4*${sizearg2}+4*${sizearg3}+4*${sizearg4}
    Log To Console    ${sumsize}
    Pass Execution If  ${sizearg1}==105 and ${sumsize}>=1406
                        ...    Good PRB Allocation
    Fail    Wrong PRBs allocation

Verify Cells Size With Asymmetric
    [Arguments]    ${sizearg0}     ${sizearg1}    ${sizearg2}    ${sizearg3}    ${sizearg4}
    ${sumsize}=    Evaluate    4*${sizearg0}+4*${sizearg1}+4*${sizearg2}+4*${sizearg3}+4*${sizearg4}
    Log To Console    ${sumsize}
    Pass Execution If  ${sizearg1}==102 and ${sumsize}>=1406
                        ...    Good PRB Allocation
    Fail    Wrong PRBs allocation


#LokiRecovery
Trigger LokiA recovery and check 2087 fault
    set test variable    ${FaultID}      2087
    set test variable    ${AlarmID}      7101
    set test variable    ${waiting_interval_for_fault}      120
    Check specific status on selected component  NRCELL-All            ${expected_statuses}
    Trigger LokiA recovery
    wait until keyword succeeds   ${waiting_interval_for_fault}   2   Wait For Fault with Alarm to appear   ${FaultID}    ${AlarmID}
    Wait For Fault with Alarm to disappear   ${FaultID}      ${AlarmID}
    Wait Until Keyword Succeeds    500    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

Trigger LokiA recovery
    Open connection         ${HOST}
    Login                   ${USERNAME}         ${PASSWORD}
    SSHLibrary.Write     bsh 1:1
    SSHLibrary.Write     ps aux | grep l1_application > /tmp/ps_l1_result.txt
    SSHLibrary.Write     head -2 /tmp/ps_l1_result.txt
    SSHLibrary.Write     clear
    ${ps_aux}=  SSHLibrary.Read   delay=1s
    @{trash_list}=     Split String  ${ps_aux}
    ${application_nrt_index_in_trash}=   Get Index From List   ${trash_list}    /usr/bin/l1_application_nrt
    ${pidIndex}=        Evaluate     ${application_nrt_index_in_trash} - 9
    ${pidToKill}=      Get from list   ${trash_list}     ${pidIndex}
    log to console     --- Killing process PID: ${pidToKill}
    SSHLibrary.Write    kill -11 ${pidToKill}

Wait For Fault with Alarm to appear
    [Arguments]  ${FaultID}     ${AlarmID}    ${Fault_name}=None  #'RAT autonomous reset as recovery action
    Fault Should Be Present   ${FaultID}  ${Fault_name}
    Alarm Should Be Present   ${AlarmID}

#Wait For Fault with Alarm to appear
#    [Arguments]  ${FaultID}     ${AlarmID}
#    Fault Should Be Present   ${FaultID}
#    Alarm Should Be Present   ${AlarmID}

Wait For Fault with Alarm to disappear
    [Arguments]  ${FaultID}     ${AlarmID}
    wait until keyword succeeds  300      20    Fault Should Not Be Present   ${FaultID}

Fault Should Be Present
    [Arguments]    ${fault_id}  ${Fault_name}
    Log To Console    KW - Fault Should Not Be Present fault_id=${fault_id}
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    ${fault_name_list}  Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
        ${fault_name_list}=  Run Keyword If  '${Fault_name}'!='None'  Get From Dictionary  ${active_alarms[${i}]}  faultName
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain    ${list}    ${fault_id}
    Run Keyword If  '${Fault_name}'!='None'  Should Be Equal As Strings  ${fault_name_list}  ${Fault_name}

Fault Should Not Be Present
    [Arguments]    ${fault_id}
    Log To Console    KW - Fault Should Not Be Present fault_id=${fault_id}
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Not Contain    ${list}    ${fault_id}

Alarm Should Be Present
    [Arguments]    ${alarm_id}
    Log To Console    KW - Alarm Should Be Present alarm_id=${alarm_id}
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain    ${list}    ${alarm_id}

Alarm Should Not Be Present
    [Arguments]    ${alarm_id}
    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    ${list}     convert to string  ${alarm_id_list}
    Should Not Contain    ${list}    ${alarm_id}
