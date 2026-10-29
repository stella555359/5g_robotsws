*** Settings ***
Documentation
...   author: lixia tang
...   squad group: MMW_SG3
...   contact: lixia.tang@nokia-sbell.com
...   Feature CB009801 in 5G24R2 program
Suite Setup
Suite Teardown
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB011104_Robust_Common_Keyword.robot



*** Variables ***
${testline_name}    7_5_UTE5G402T910
${scf_file}    SCF_SBTS00.xml


*** Test Cases ***

[1]CB011104-SR-G_06_RFS_NR_NR_BTS_Startup_mixed_role_with_dual_band_2CC_n38_n78_8DL8UL_100MHz_40MHz
    [Setup]    robot_common_operations.Common Case Setup
	Scf commission and wait on-air    scf_name=SCF_SBTS00.xml
    Run Keyword and Continue on Failure    Site reset 3 times
    Run Keyword and Continue on Failure    NR reset 3 times
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown