*** Settings ***
Documentation
...    Author:  yuguo.hou@nokia-sbell.com
...    Contact: yuguo.hou@nokia-sbell.com
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../resources/common_resources.robot

*** Variables ***
@{ALLOWED_FAULT}
${scf_file}      CB009170_ABIP_AVQL_AVQC_NRTDD_100M_A1_gscn_636666_2xNRCELL_${bts_id}.xml

&{bts_PA_dict}    10386=&{PA_dict_10386}    11148=&{PA_dict_11148}    37667=&{PA_dict_37667}
&{PA_dict_10386}    ip=10.108.241.5     init_value=1:10;2:10;3:10;4:10;5:40;6:40;7:40;8:40    target_value=1:60;2:60;3:60;4:60
&{PA_dict_11148}    ip=10.108.241.44    init_value=1:35;3:35;5:35;7:35     target_value=1:85;3:85;5:85;7:85
&{PA_dict_37667}    ip=10.108.228.28    init_value=1:20;2:20;3:20;4:20     target_value=1:85;2:85;3:85;4:85

*** Test Cases ***
ASIM_ABIP_AVQL_NRTDD_72e
    [Tags]    ABIP    SMAwave    72a    INIT
    ${bts_id}    Convert To String    ${bts_id}
    Run Keyword And Continue On Failure     Adjust TOPYOUNG attenuation values    ${bts_PA_dict}[${bts_id}][ip]
    ...    ${bts_PA_dict}[${bts_id}][init_value]
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}/CB009170/${scf_file}
