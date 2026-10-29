*** Settings ***
Documentation     author: Sherry Zhang
...         contact: sherry.1.zhang@nokia-sbell.com
...         Upload Image To Nom

Force Tags    SG_07    CA_5G_OAM
...    PY36

Library   BuiltIn
Library   XML   True
Library   String
Library   DateTime
Library   Collections
Library   OperatingSystem
Library     taf.nms.nom         WITH NAME   nom
Library     taf.transport.ssh   WITH NAME   csn
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/nom_swm.robot

*** Variables ***
${username}   neonetics
${nom_nodeip}    ${netact_nodeip}

*** Test Cases ***
Upload Image To Nom
    Check taget SW package exist in taf server   version=${upgrade_version}
    ${apigw_url}    ${user_mgmt_url}    ${password}    ${client_id}    Get Nom Uri and Password    ${nom_nodeip}
    ${login_status}    run keyword and return status    Nom Login    ${apigw_url}    ${user_mgmt_url}    ${password}    ${client_id}
    run keyword if  not ${login_status}    run keywords
    ...    run keyword and ignore error    Nom Logout    ${apigw_url}    ${password}    ${client_id}
    ...    AND    Nom Login    ${apigw_url}    ${user_mgmt_url}    ${password}    ${client_id}
    ${package_list}    nom.get_sw_package_list    ne_type=MRBTS
    FOR   ${each_package_detail}   IN   @{package_list}
       ${status}    run keyword and return status    dictionary should contain value   ${each_package_detail}   ${upgrade_version}
       exit for loop if    ${status}
    END
    run keyword if    ${status}    log to console    \nSW package found in Nom, skip to import sw package.
    run keyword if  not ${status}    log to console    \nStart to import sw package, please be patient with this
    run keyword if  not ${status}    nom.import_sw_package
    ...   file_path=/home/ute/${upgrade_version}.zip
    ...   ne_type=MRBTS
    ...   ne_sw_version=${upgrade_version}
    ...   file_name=${upgrade_version}.zip
    [Teardown]   run keyword and ignore error    Nom Logout    ${apigw_url}    ${password}    ${client_id}
