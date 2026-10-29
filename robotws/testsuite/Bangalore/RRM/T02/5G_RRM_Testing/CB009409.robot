*** Settings ***
Documentation    Author: Mujeeba farheen
...              Maintainer:  MN RAN Pz BLR 2 SG
...              MRT
Library   String
Library   Collections
Library   DateTime
Library   OperatingSystem    WITH NAME    os
Library   Process
Library   Screenshot
Library   XML
Library   Telnet
Library   taf.sbts.oam.coam.admin    WITH NAME    admin
Library   taf.collectors.core   WITH NAME   core
Library   taf.collectors.btslog  WITH NAME   btslog
Library   taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Library    testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    uc
Library    ../resources/python/Test_Verification_Handler.py    WITH NAME    Validation
Library    testsuite/Bangalore/ORAN/resources/python/Tshark_Validation.py
Resource   ../resources/robot/Common_keywords.resource
Resource   ../resources/robot/Rjio_Operation_keywords.resource
Library    taf.sw.reporting_portal    WITH NAME    rp
Resource   taf/rfrl/common_resources/common_step/interface.robot
Library   taf.selenium.sbts    WITH NAME  Selenium_Sbts
Library   taf.hw.rf_attenuator.attenuator    WITH NAME   attenuator
Library   OperatingSystem
Test Setup        Test_Setup_keywords
Test Teardown     Test_Teardown_Keywords

*** Variables ***
${folder}                          /home/ute
${file}                            Enable.txt
${dfile}                           Disable.txt
@{UE_alias}                        UE_4
@{capabilities}                    Legacy_4
@{udpcalltype}=                    FTP
${protocol}=                       FTP
@{direction_dl}=                   dl
${timeout}=                        200
${Attenuator_ip_addr}              10.45.153.211
${Attenuator_com_port}             3001
@{attenuation_ports}               11    12
${Attenuator_vendor}               TOPYOUNG
${Attenuator_model}                TAS16T16-51-120-1N-DEJS
@{PVA_Port_1_2}    		   11   12
${PVA_Value_40}    		   35dB
${PVA_Value_0}			   0dB
${Dict_MOC_PATH}                   MRBTS-11008/NRBTS-11008/NRCELL-4
${PARAMETER_KEY}                   actTcpBoostPug
${9409_Disable}                    disabled
${9409_allUes}                     allUes
${CS_Entry_validation}             CS1 Entry for TCP PUG
${NO_CS_Entry}                     RlcStatusPdu grant req received tcpBoost:0
${RF_threshold}                    RF threshold elegibility check fail
${Sinr_less}                       Sinr less than Thresh for Non Skippable Ue
${scf_commission_file_1}          /home/ute/Downloads/TCP_9409_enable.xml
${scfconf}=                       /home/ute/testline_configuration/7_2_UTE5GCLOUD1008/ta_ue_config.yaml
${BTS_ID}                          MRBTS-11008
${BTSLOG} =                        btslog
${SCF_PATH}                        /home/ute/Downloads
&{BTS_Details}                     bts_host=192.168.255.129
...                                bts_port=443
...                                username=Nemuadmin
...                                password=nemuuser
...                                use_ssl=True
...                                update_interval=5000
...                                admin_api_log_dir=${EXECDIR}
...                                name=default
...                                bundle_path=None
...                                release=SBTS00
...                                timeout=30
&{Dcap_Server_Details}             host=10.41.209.120
...                                port=443    secure=True    Alias=GNB_1
...                                username=dcapuser    password=dcapadmin!
&{Dcap_User_Details}               host=10.58.239.183    port=443
...                                username=Nemuadmin    password=nemuuser



&{Verification of TCP Boost PUG should be stopped for UEs in poor RF that do not support skippable grants}    QC_ID_FL00=QC_552593

&{Comparison for TCP Short File Transfer Performance - NR TDD Single Cell}    QC_ID_FL00=QC_552593


*** Test Cases ***

Comparison for TCP Short File Transfer Performance - NR TDD Single Cell

    Log To Console   \n ___________________FEATURE ENABLE!!!!
    start Btslogs from Local machine    ${BTSLOG}
    admin.Connect to    bts_host=${BTS_Details.bts_host}   username=${BTS_Details.username}
    ...    password=${BTS_Details.password}    admin_api_log_dir=${BTS_Details.admin_api_log_dir}    release=${BTS_Details.release}
    Get_Feature_Activation    ${Dict_MOC_PATH}    ${PARAMETER_KEY}    value=${9409_allUes}
    Sleep    120 s    #BTS may need some time to update scf file
    admin.start_ip_capture_file  measurement_point=NE_Terminated  uplane_capturing=True  password=nemuuser    timeout=240
    uc.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    initial ue attach via ultracaller
    FTP_dl_data_transfer
    verify TCP boost PUG             #verify that TCP Boost PUGs initiated to UE
    detach ue via ultracaller        #detach the UE from GNB
    Sleep    50 s
    admin.stop_ip_capture_file   timeout=240    detailed_output=False
    admin.generate_ip_capture_file   password='nemuuser'  timeout=240  detailed_output=False
    admin.download_ip_capture_file    detailed_output=True    target_file_name=Enable.pcap
    Feature_Enable_Validation
    Find_file    ${folder}    ${file}
    ${FeatureEnable}=    Filter first and last Three lines
    Stops Btslogs from Local machine    ${BTSLOG}
    Log To Console   \n ___________________FEATURE DISABLE!!!!
    start Btslogs from Local machine    ${BTSLOG}
    admin.Connect to    bts_host=${BTS_Details.bts_host}   username=${BTS_Details.username}
    ...     password=${BTS_Details.password}    admin_api_log_dir=${BTS_Details.admin_api_log_dir}    release=${BTS_Details.release}
    Get_Feature_Activation    ${Dict_MOC_PATH}    ${PARAMETER_KEY}    value=${9409_Disable}
    Sleep    120 s    #BTS may need some time to update scf file.
    admin.start_ip_capture_file  measurement_point=NE_Terminated  uplane_capturing=True  password=nemuuser  timeout=240
    uc.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    initial ue attach via ultracaller
    FTP_dl_data_transfer               ##tcp data transfer, ##verify the data transfer is started or not
    verify No TCP boost PUG  	         ##verify that no TCP Boost PUGs initiated to UE}
    detach ue via ultracaller          ##detach the UE from GNB
    Sleep   50 s
    admin.stop_ip_capture_file   timeout=240    detailed_output=False
    admin.generate_ip_capture_file   password='nemuuser'  timeout=240  detailed_output=False
    admin.download_ip_capture_file    detailed_output=True    target_file_name=Disable.pcap
    Feature_Disable_Validation
    DFind_file    ${folder}    ${dfile}
    ${FeatureDisable}=    DFilter first and last Three lines
    Stops Btslogs from Local machine    ${BTSLOG}
    Result    ${FeatureDisable}    ${FeatureEnable}

Verification of TCP Boost PUG should be stopped for UEs in poor RF that do not support skippable grants

    start Btslogs from Local machine    ${BTSLOG}
    Get_Feature_Activation    ${Dict_MOC_PATH}    ${PARAMETER_KEY}    value=${9409_allUes}
    Sleep    120 s  							 #BTS may need some time to update scf file.
    uc.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    initial ue attach via ultracaller
    FTP_dl_data_transfer_with_attenuation
    uc.await_data_transfer_finish    ${UE_alias}    ${direction_dl}    ${timeout}
    verify TCP boost PUG
    Verify NO PUG when RF condition is worse                 ##Verify TCP Boost PUG when RF condition is better
    Stops Btslogs from Local machine    ${BTSLOG}


*** Keywords ***

initial ue attach via ultracaller
    Wait Until Keyword Succeeds    3 times    180ms    uc.Attach UE    ue_alias=${UE_alias}

FTP_dl_data_transfer
    uc.start_data_transfer    ${UE_alias}     ${udpcalltype}      direction=${direction_dl}
    uc.await_data_transfer_finish     ${UE_alias}     ${direction_dl}     ${timeout}

FTP_dl_data_transfer_with_attenuation
    uc.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
    Sleep    20 s
    taf_attenuator_objects    attenuation_ports=${PVA_Port_1_2}    set_value=${PVA_Value_40}
    Sleep    50 s
    Verify NO PUG when RF condition is worse
    Sleep    10 s
    taf_attenuator_objects    attenuation_ports=${PVA_Port_1_2}    set_value=${PVA_Value_0}

verify TCP boost PUG
    Validation.validate_syslog_file_contents    dir_path=/tmp/btslog2    search_string=${CS_Entry_validation}

verify No TCP boost PUG
    Validation.validate_syslog_file_contents    dir_path=/tmp/btslog2    search_string=${NO_CS_Entry}

Verify NO PUG when RF condition is worse
     Validation.validate_syslog_file_contents    dir_path=/tmp/btslog2    search_string=${RF_threshold}
     Validation.validate_syslog_file_contents    dir_path=/tmp/btslog2    search_string=${Sinr_less}

detach ue via ultracaller
    Wait Until Keyword Succeeds    3 times    180ms    uc.Detach UE    ue_alias=${UE_alias}

SCF_Commission
    [Documentation]    Keyword can fetch user input as xml file and does full commission
    [Arguments]      ${Commission_file}=${scf_commission_file_1}
    Directory Should Exist    ${SCF_PATH}
    admin.perform_commissioning    ${BTS_ID}    skip_parameter_relation_errors=true
    ...        scf_file=${Commission_file}   timeout=2000

Get_Pre_Active_alarms
    [Documentation]    Active Alarms
    ${Pre_Active_Alarm}    admin.get_active_alarms
    Log    ${Pre_Active_Alarm}

Get_Post_Active_alarms
    [Documentation]    Keyword is feature purpose for alarm validation.
    ${Post_Active_Alarm}    admin.get_active_alarms
    Log    ${Post_Active_Alarm}

Get_Feature_Activation
    [Documentation]    Scope of the keyword to disable tcpboostpug.
    [Arguments]    ${Dict_Name}=${None}
    ...            ${parameter}=${None}
    ...            ${operation}=update    ${value}=${None}
    ...            ${should_activate}=True    ${timeout}=350
    admin.perform_parameter_recommissioning
    ...    dist_name=${Dict_Name}
    ...    parameter=${parameter}
    ...    operation=${operation}
    ...    value=${value}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}

Test_Setup_keywords
    [Documentation]    Test Pre condition
    os.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${scfconf}
    admin.Connect to    bts_host=${BTS_Details.bts_host}   username=${BTS_Details.username}
    ...    password=${BTS_Details.password}    admin_api_log_dir=${BTS_Details.admin_api_log_dir}     release=${BTS_Details.release}
#    Run Keyword And Ignore Error    Start_Dcap
    Get_Pre_Active_alarms


Test_Teardown_Keywords
    [Documentation]    Test post condition
#    Run Keyword And Ignore Error    Stop_Dcap
    Get_Post_Active_alarms
    Run Keyword And Continue On Failure    interface.Common step trigger
    admin.teardown_admin

Feature_Enable_Validation
   Validate_Tshark    folder_path=/home/ute/    filter= tcp.stream
    os.run      my_array < <(awk '{ print $0 }' Enable.txt)
    ${result} =    Run Process    awk { print $0 } /home/ute/Enable.txt    shell=True    stdout=PIPE
    Log    ${result.stdout}

Feature_Disable_Validation
    Validate_Tshark    folder_path=/home/ute/    filter= tcp.stream
    os.run      my_array < <(awk '{ print $0 }' Disable.txt)
    ${result} =    Run Process    awk { print $0 } /home/ute/Disable.txt    shell=True    stdout=PIPE
    Log    ${result.stdout}

Find_file
    [Documentation]  Author: Vinayak Katwa
    [Arguments]    ${folder}    ${file}
    ${folder}=    Strip String    ${folder}
    ${file}=      Strip String    ${file}
    ${full_path}=    Set Variable    ${folder}/${file}
    Log    Checking for file at: ${full_path}
    ${files}=    os.List Files In Directory    ${folder}    pattern=${file}
    ${file_count}=    Get Length    ${files}
    Run Keyword If    ${file_count} == 0    Fail    File ${file} does not exist at ${full_path}
    Log    File ${file} found at ${full_path}
    ${file_content}=    os.Get File    ${full_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}
        ${match}=    Get Regexp Matches    ${line}    GTP <TCP>\s+(\d+)
        Run Keyword If    ${match}    Log    Found value: ${match[0]}
    END

Filter First and Last Three Lines
    [Documentation]  Author: Vinayak Katwa  |  Filtering the first and last three lines to get slow start time.
    ${file_content}=    os.Get File    ${folder}/${file}
    @{List of lines}=   String.Split To Lines    ${file_content}
    ${total_lines}=    BuiltIn.Get Length    ${List of lines}
    @{first_three_lines}=    BuiltIn.Create List
    @{last_three_lines}=     BuiltIn.Create List
    @{out_list}=    BuiltIn.Create List
    FOR    ${first_index}    IN RANGE    ${0}    ${3}
        ${line}=    Get From List    ${List of lines}    ${first_index}
        Collections.Append To List    ${first_three_lines}    ${line}
        ${out} =    Get Substring    ${line}    8    16
        Collections.Append To List    ${out_list}    ${out}
        Log    ${out}
        Log To Console    \nFirst 3 OUTPUT's ${first_index}/2: ${out}
    END
    ${first}=    Get From List    ${out_list}    0
    ${first_value}=    Convert To Number    ${first}
    ${second}=    Get From List    ${out_list}    1
    ${second_value}=    Convert To Number    ${second}
    ${third}=    Get From List    ${out_list}    2
    ${third_value}=    Convert To Number     ${third}

    ${F1}=    Evaluate    ${second_value} - ${first_value}
    ${F2}=    Evaluate    ${third_value} - ${first_value}

    IF    ${F2} > ${F1}
        Log To Console    PASS
    ELSE
        Fail
    END
    #${comparison_result}=    Evaluate    ${F1} < ${F2}
    #Log To Console    \nComparison Result (F1 < F2): ${comparison_result}
    ${FeatureEnable}=    Set Variable    ${0}
    ${FeatureEnable}=    Evaluate    (${first_value}+${Second_value}+${third_value})/3
    Log To Console    The Average Time for Feature Enable is: ${FeatureEnable}
    Return From Keyword    ${FeatureEnable}

DFind_file
    [Documentation]  Author: Vinayak Katwa
    [Arguments]    ${folder}    ${dfile}
    ${folder}=    Strip String    ${folder}
    ${file}=      Strip String    ${dfile}
    ${full_path}=    Set Variable    ${folder}/${dfile}
    Log    Checking for file at: ${full_path}
    ${files}=    os.List Files In Directory    ${folder}    pattern=${dfile}
    ${file_count}=    Get Length    ${files}
    Run Keyword If    ${file_count} == 0    Fail    File ${dfile} does not exist at ${full_path}
    Log    File ${dfile} found at ${full_path}
    ${file_content}=    os.Get File    ${full_path}
    ${lines}=    Split To Lines    ${file_content}
    FOR    ${line}    IN    @{lines}
        ${match}=    Get Regexp Matches    ${line}    GTP <TCP>\s+(\d+)
        Run Keyword If    ${match}    Log    Found value: ${match[0]}
    END

DFilter First and Last Three Lines
    [Documentation]  Author: Vinayak Katwa | Filtering the first and last three lines to get slow start time.
    ${file_content}=    os.Get File    ${folder}/${dfile}
    @{List of lines}=   String.Split To Lines    ${file_content}
    ${total_lines}=    BuiltIn.Get Length    ${List of lines}
    @{first_three_lines}=    BuiltIn.Create List
    @{last_three_lines}=     BuiltIn.Create List
    @{out_list}=    BuiltIn.Create List
    FOR    ${first_index}    IN RANGE    ${0}    ${3}
        ${line}=    Get From List    ${List of lines}    ${first_index}
        Collections.Append To List    ${first_three_lines}    ${line}
        ${out} =    Get Substring    ${line}    8    16
        Collections.Append To List    ${out_list}    ${out}
        Log    ${out}
        Log To Console    \nFirst 3 OUTPUT's ${first_index}/2: ${out}
    END
    ${first}=    Get From List    ${out_list}    0
    ${first_value}=    Convert To Number    ${first}
    ${second}=    Get From List    ${out_list}    1
    ${second_value}=    Convert To Number    ${second}
    ${third}=    Get From List    ${out_list}    2
    ${third_value}=    Convert To Number     ${third}
    ${F1}=    Evaluate    ${second_value} - ${first_value}
    ${F2}=    Evaluate    ${third_value} - ${first_value}
    IF    ${F2} > ${F1}
        Log To Console    PASS
    ELSE
        Fail
    END

    #${comparison_result}=    Evaluate    ${F1} < ${F2}
    #Log To Console    \nComparison Result (F1 < F2): ${comparison_result}
    ${FeatureDisable}=    Set Variable    ${0}
    ${FeatureDisable}=     Evaluate    (${first_value}+${Second_value}+${third_value})/3
    Log To Console    The Average Time for Feature Disable is: ${FeatureDisable}
    Return From Keyword    ${FeatureDisable}

Result
    [Documentation]  Author: Vinayak Katwa || Comparision of Slow Start time
    [Arguments]    ${FeatureDisable}    ${FeatureEnable}
    IF    ${FeatureDisable} > ${FeatureEnable}
        Log To Console    PASS
    ELSE
        Log To Console    Enable time is more then Disable Time
        Fail
    END

start Btslogs from Local machine
    [Arguments]    ${log_alias}
    btslog.create_btslog_collector    ${log_alias}
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias}
    core.Set Suite Alias    ${log_alias}

Stops Btslogs from Local machine
    [Arguments]    ${log_alias}
    core.stop_collectors      names=${log_alias}
    core.collect_collectors      names=${log_alias}
    core.teardown_collectors      names=${log_alias}

taf_attenuator_objects
	[Documentation]  Author: Arunkumar A
    ...    Integrated along with https://taf-hw-rf-attenuator.docs.taf.ute.nsn-rdnet.net/
    [Arguments]   ${attenuation_ports}   ${set_value}
    ${Attenuator_device_config}  attenuator.setup_attenuator   ip_addr=${Attenuator_ip_addr}  port=${Attenuator_com_port}
    ...    attenuation_port_numbers=${attenuation_ports}  vendor=${Attenuator_vendor}   model=${Attenuator_model}
    FOR  ${port}  IN  @{attenuation_ports}
        ${port_value}  attenuator.read_attenuation  port=${port}
        Run keyword    Run Keyword If   "${port_value}dB"!="${set_value}"  attenuator.set_attenuation
        ...    port=${port}  value=${set_value}    confirm=${True}    confirmation_delay=5
        ...    ELSE    BuiltIn.Log To console    [ INFO ]: Port Number: ${port} and value: ${port_value}
    END


