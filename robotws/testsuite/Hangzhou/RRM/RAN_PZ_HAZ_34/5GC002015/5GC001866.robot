*** Settings ***
Documentation     author: Chen Yin
...             contact: yin.1.chen@nokia-sbell.com
...             Group: HGZ_SG2
Force Tags         5G_RRM
...    PY36

Suite Teardown      Setup enviornment with relevant configuration
...      scf_path=SCF_SBTS24R3.xml
Resource         Resources/5GC001866_common_resource.robot
Resource         testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A/Resources/5GC002029_A_common_keywords.robot
Variables        Resources/1866_variables.py

*** Variables ***
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_4681}              faultId=${4681}    #Sanity Check Error
&{fault_61649}              faultId=${61649}    #LMP access via port 443
&{fault_4459}              faultId=${4459}    #User Account has Default Password
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}    &{fault_4681}
              ...    &{fault_61649}    &{fault_4459}
${file_path}                /home/ute/Downloads/NEWBSR/
@{nrCellIdentity}    88375299
${UL_THROUGHPUT}    200M
${DL_THROUGHPUT}    1500M
${DURATION}    1200
${DL_TDD_EXPECT_100M}    500
${UL_TDD_EXPECT_100M}    50


*** Test Cases ***
[1]5GC001866-A_02_Upload_BSR_to_gNB_WebEM_NSA_Classical_Below_6GHz_gen4_cpri
    [Setup]      5GC002029_A_common_keywords.Test Case Setup
    5GC001866_common_resource.Download and update BSR package      file_path=${file_path}
    COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=1min
    Get beam set realization file name      file_path=${full_file_path}
    Check installed BSR in beam set realization software
    Check installed BSR in configuration management Parameter
    Check installed BSR in command
    [Teardown]      Run keywords      Delete installed BSR in beam set realization software      AND
    ...      5GC002029_A_common_keywords.Test Case Teardown

[1][1.0] 5GC001866-A_03_Activate_BSR_to_gNB_through_parameter_WebEM_NSA_Classical_Below_6GHz_gen4_cpri
    [Setup]    5GC002029_A_common_keywords.Test Case Setup
    5GC001866_common_resource.Download and update BSR package      file_path=${file_path}
    COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=1min
    Get beam set realization file name      file_path=${full_file_path}
    Activate 1866 in gNB
    Check installed BSR in beam set realization software
    Check installed BSR in configuration management Parameter
    Check installed BSR in command
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    @{use_cell_list}    Create List    4
    Lock Cell and Check Status    cell_list=${use_cell_list}      gnb_type=SA
    UE Attach and Start Traffic    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
    ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
    ...                            nrCellIdentity=${nrCellIdentity}[0]    apn_address=dxdata2      ui_version=Mi12UI13.0.12
    ...                            ip_filter=172.
    Unlock Cell and Check Status    allowed_faults=${allowed_faults}    cell_list=${use_cell_list}
    deActivate 1866 in gNB
    [Teardown]      Run keywords      Delete installed BSR in beam set realization software      AND
    ...      5GC002029_A_common_keywords.Test Case Teardown

[1]5GC001866-A_04_Delete_BSR_From_gNB_WebEM_NSA_Classical_Below_6GHz_gen4_cpri
    [Setup]    5GC002029_A_common_keywords.Test Case Setup
    deActivate 1866 in gNB
    5GC001866_common_resource.Download and update BSR package      file_path=${file_path}
    COAM Wait for gnb ready and cell setup    gnb_type='SA'    timeout=1min
    Get beam set realization file name      file_path=${full_file_path}
    Delete installed BSR in beam set realization software
    Check deleted BSR not in beam set realization software
    Check deleted BSR not in command
    [Teardown]    5GC002029_A_common_keywords.Test Case Teardown
