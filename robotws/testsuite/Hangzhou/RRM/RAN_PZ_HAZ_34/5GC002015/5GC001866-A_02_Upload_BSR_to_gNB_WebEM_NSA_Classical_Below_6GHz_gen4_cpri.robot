*** Settings ***
Documentation     author: Ji Jian
...             contact: jian.ji@nokia-sbell.com
...             Group: HGZ_SG2
Force Tags         5G_RRM
...    PY36

Suite Setup    Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown for COAM
Test Timeout   120 minutes

Resource         Resources/5GC001655_common_keyword.robot
Variables        Resources/1866_variables.py

*** Variables ***
${scf_file}                     common_4x4.xml
${data_transfer_dl}             800M
${data_transfer_ul}             80M
${Expected_Throughput_DL}       200
${Expected_Throughput_UL}       20
${buffer_size}                  1400
${bip_filter_item}              dldata_pdcchsendreq
${BSR_file}                     BSR_AEHC_6_H5H1_ALN45_ARP45_P01_COVERAGE_00479_00001
${File_path}                    /home/ute/Downloads/BSR/BSR_AEHC_6_H5H1_ALN45_ARP45_P01_COVERAGE_00479_00001.zip
&{5GC001866_A_02}              SBTS22R2=QC_324966    SBTS22R3=QC_402739    SBTS22R4=QC_361909    SBTS23R1=QC_287499
&{5GC001866_A_03}              SBTS22R2=QC_324965    SBTS22R3=QC_402740    SBTS22R4=QC_361910    SBTS23R1=QC_287500
&{5GC001866_A_04}              SBTS22R2=QC_324964    SBTS22R3=QC_402738    SBTS22R4=QC_361904    SBTS23R1=QC_56870 

*** Test Cases ***
[1]5GC001866-A_02_Upload_BSR_to_gNB_WebEM_NSA_Classical_Below_6GHz_gen4_cpri
    [Tags]    5GC001866     CRT_22R3    ${5GC001866_A_02['${program}']}
    [Setup]    Case Setup
    "Step1" Download and update BSR package
    "Step2" Check if gNB and Cell onAir
    "Step3" Check installed BSR in beam set realization software
    "Step4" Check installed BSR in Parameter
    "Step5" Check installed BSR in command
    [Teardown]    Case Teardown

[1]5GC001866-A_03_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical_Below_6GHz_gen4_cpri
    [Tags]    5GC001866     CRT_22R3    ${5GC001866_A_03['${program}']}
    [Setup]    Case Setup
    "Step1" Download and update BSR package
    "Step2" Enable feature 1866
    "Step3" Check if gNB and Cell onAir
    "Step4" Check installed BSR in beam set realization software
    "Step5" Check installed BSR in Parameter
    "Step6" Check installed BSR in command
    "Step7" Start DLUL traffic and Capture BIP
    "Step8" Check installed BSR in Bip
    "Step9" Disable feature 1866
    [Teardown]    Case Teardown

[1]5GC001866-A_04_Delete_BSR_From_gNB_WebEM_NSA_Classical_Below_6GHz_gen4_cpri
    [Tags]    5GC001866     CRT_22R3    ${5GC001866_A_04['${program}']}
    [Setup]    Case Setup
    "Step1" Download and update BSR package
    "Step2" Check if gNB and Cell onAir
    "Step3" Check installed BSR in beam set realization software
    "Step4" Check installed BSR in Parameter
    "Step5" Check installed BSR in command
    "Step6" Disable feature 1866
    "Step7" Delete installed BSR in beam set realization software
    "Step8" Check deleted BSR not in beam set realization software
    "Step9" Check deleted BSR not in Parameter
    "Step10" Check deleted BSR not in command
    [Teardown]    Case Teardown

*** Keywords ***
"${Step}" Start DLUL traffic and Capture BIP
    Start DLUL traffic and Capture BIP
    ...     data_transfer_dl=${data_transfer_dl}
    ...     data_transfer_ul=${data_transfer_ul}
    ...     Expected_Throughput_DL=${Expected_Throughput_DL}
    ...     Expected_Throughput_UL=${Expected_Throughput_UL}
    ...     bip_log=${bip_log}

"${Step}" Enable feature 1866
    Log To Console    "${Step}" Enable feature 1866
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${Enable_feature_1866}    download_dir=${TS_CASE_LOG_PATH}

"${Step}" Disable feature 1866
    Log To Console    "${Step}" Disable feature 1866
    COAM Update several parameters via webUI    parameters_to_update_via_webui=${Disable_feature_1866}    download_dir=${TS_CASE_LOG_PATH}

"${Step}" Check if gNB and Cell onAir
    Log To Console    "${Step}" Check if gNB and Cell onAir
    COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=1min

"${Step}" Download and update BSR package
    Log To Console    \n"${Step}" Download BSR package
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    selenium_coam.load_software_package_from_local_drive    file_path=${File_path}
    sleep    15s
    selenium_coam.software_update    is_activate=${True}
    sleep    15s
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium logout

"${Step}" Check installed BSR in beam set realization software
    Log To Console    "${Step}" Check in beam set realization software
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
	selenium_coam.enable_virtual_display
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info    timeout=${120}
    ${actCustomBsr}    selenium_coam.get_parameter_value    dist_name=${MR_NR_BTS_NAME}
    ...    filter_param=Activate custom beam set realization    abbr=actCustomBsr    timeout=${120}
    ${BSR_Status}    set variable if
    ...          '${actCustomBsr}'=='false'    Not in use
    ...          '${actCustomBsr}'=='true'    In use
    ${BSR_Used_by}    set variable if
    ...          '${actCustomBsr}'=='false'    -
    ...          '${actCustomBsr}'=='true'    NRCELL-1
    Should Be Equal    ${beam_set_realization_software[0]['Status']}    ${BSR_Status}
    Should Be Equal    ${beam_set_realization_software[0]['Used by']}    ${BSR_Used_by}
    Should Be Equal    ${beam_set_realization_software[0]['BSR package']}    ${BSR_file}
    [Teardown]    Run Keyword and ignore error    Run keywords    COAM selenium logout    AND    selenium_coam.disable_message_box

"${Step}" Check installed BSR in Parameter
    Log To Console    "${Step}" Check installed BSR in Parameter
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${beamSetInstall}    selenium_coam.get_parameter_value    dist_name=${MR_NR_BTS_NAME}
    ...  filter_param=Beam set installed    node_index=${0}
    Should Be Equal    ${beamSetInstall}    ${BSR_file}
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium logout

"${Step}" Check installed BSR in command
    Log To Console    "${Step}" Check installed BSR in command
    Connect to Common Unit Master
    ${output}    csn.execute    command=ls -l /ffs/run/config/beamforming    connection=ASIK Master
    Run Keyword and ignore error    should contain x times    ${output}    ${BSR_file}    6
    [Teardown]    Run Keyword And Continue On Failure    csn.disconnect    connection=ASIK Master

"${Step}" Check installed BSR in Bip
    Log To Console    "${Step}" Check installed BSR in Bip
    Load pcap file with filter    pcap_file=${bip_log_path}    field_name=dldata_pdcchsendreq
    ${values}    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s
    ...    pcap.get_field_value_by_xpath     xpath=.//DlData_DciInfo.patternId_item
    ${patternId}    Remove Duplicates   ${values}
    Remove Values From List    ${patternId}    0
    Sort List   ${patternId}
    ${patternId_min}    Convert To Integer    ${patternId[0]}
    Run Keyword And Continue On Failure     should be true    ${patternId_min}>=1024
    Run Keyword And Continue On Failure     log to console    patternId==${patternId}

"${Step}" Delete installed BSR in beam set realization software
    Log To Console    "${Step}" Delete installed BSR in beam set realization software
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info
    @{bsr_package_list}=    Create List    ${BSR_file}
    selenium_coam.delete_beam_set_realization_software_item    bsr_package_list=@{bsr_package_list}
    sleep    15s
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium logout

"${Step}" Check deleted BSR not in beam set realization software
    Log To Console    "${Step}" Check delete BSR not in beam set realization software
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${beam_set_realization_software}    selenium_coam.get_beam_set_realization_software_info
    ${actCustomBsr}    selenium_coam.get_parameter_value    dist_name=${MR_NR_BTS_NAME}    filter_param=Activate custom beam set realization
    ...    abbr=actCustomBsr    timeout=${120}
    Run Keyword and ignore error    Should not Be Equal    ${beam_set_realization_software[0]['BSR package']}    ${BSR_file}
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium logout

"${Step}" Check deleted BSR not in Parameter
    Log To Console    "${Step}" Check deleted BSR not in Parameter
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${para_details}   Run Keyword And Continue On Failure    selenium_coam.get_parameter_details    dist_name=${MR_NR_BTS_NAME}
    ...  filter_param=Beam set installed    abbr=beamSetInstalled
    ${beamSetInstall}    Run Keyword and ignore error    selenium_coam.get_parameter_value    dist_name=${MR_NR_BTS_NAME}
    ...  filter_param=Beam set installed    abbr=beamSetInstalled
    Should not Be Equal    ${beamSetInstall}    ${BSR_file}
    [Teardown]    Run Keyword And Continue On Failure    COAM selenium logout

"${Step}" Check deleted BSR not in command
    Log To Console    "${Step}" Check deleted BSR not in command
    Connect to Common Unit Master
    ${output}    csn.execute    command=ls -l /ffs/run/config/beamforming    connection=ASIK Master
    should not contain    ${output}    ${BSR_file}
    [Teardown]    Run Keyword And Continue On Failure    csn.disconnect    connection=ASIK Master
