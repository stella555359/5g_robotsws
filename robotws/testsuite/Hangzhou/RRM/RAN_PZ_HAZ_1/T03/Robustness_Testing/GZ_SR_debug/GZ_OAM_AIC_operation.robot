


*** Settings ***
Documentation
...   Author: zhuo.1.gao@nokia-sbell.com
...   Contact: zhuo.1.gao@nokia-sbell.com
...   Description: This user scenario describes


Resource           ../../Resources/vran_resource.robot
Suite Setup       Common Suite Setup For AIC
# Test Setup        Common Test Setup For AIC
Test Setup        Run Keywords    Common Test Setup For AIC    AND
...     AIC Case Setup    airphone_config_tag=SA_Cloud_DC
...    base_path=${CURDIR}/Airphone
Test Teardown     Common Test Teardown For AIC
Suite Teardown    Common Suite Teardown For AIC


Test Timeout    7200 minutes

*** Variables ***
${PA_MaxValue}           ${60}
${PA_NormalValue}        ${30}
# ${DEBUG_MODE}        ${TRUE}

*** Test Cases ***
AIC_block_100times
    FOR    ${index}    IN RANGE    100
        ${percentage}=    Evaluate    round((${index}+1)/100*100, 1)
        Log To Console    \r当前进度: ${index+1}/100 (${percentage}%)    no_newline=True
        check_testline_cell_status
        Sleep    10s
    END
    Log To Console    \n100times操作已完成!
AIC_block_300times
    FOR    ${index}    IN RANGE    300
        ${percentage}=    Evaluate    round((${index}+1)/300*100, 1)
        Log To Console    \r当前进度: ${index+1}/300 (${percentage}%)    no_newline=True
        check_testline_cell_status
        Sleep    10s
    END
    Log To Console    \n300times操作已完成!
AIC_block_400times
    FOR    ${index}    IN RANGE    400
            ${percentage}=    Evaluate    round((${index}+1)/400*100, 1)
        Log To Console    \r当前进度: ${index+1}/400 (${percentage}%)    no_newline=True
        check_testline_cell_status
        Sleep    10s
    END
    Log To Console    \n400times操作已完成!
AIC_block_5000times
    FOR    ${index}    IN RANGE    5000
        ${percentage}=    Evaluate    round((${index}+1)/5000*100, 1)
        Log To Console    \r当前进度: ${index+1}/5000 (${percentage}%)    no_newline=True
        check_testline_cell_status
        Sleep    10s
    END
    Log To Console    \n5000times操作已完成!

*** Keywords ***


check_testline_cell_status
#    BTS Operation    operation=cell_block           product_type=vdu    bts_index=0    distname_id=NRCELL-ALL       need_verify=yes
#    BTS Operation    operation=cell_unblock         product_type=vdu    bts_index=0    distname_id=NRCELL-ALL       need_verify=yes

#    BTS Operation    operation=rannic_reset    product_type=vdu    bts_index=0    distname_id=RNICMOD_R-1      need_verify=True
#    BTS Operation    operation=ru_lock         product_type=vdu    bts_index=0    distname_id=RMOD-ALL         need_verify=True
#    BTS Operation    operation=ru_unlock       product_type=vdu    bts_index=0    distname_id=RMOD-ALL         need_verify=True
    BTS Operation    operation=ru_reset        product_type=vdu    bts_index=0    distname_id=RMOD-ALL         need_verify=True

