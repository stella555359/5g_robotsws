*** Settings ***
Library   taf.transport.ssh    WITH NAME    csn
Variables   ../libraries/nms_vars.py

Documentation
    ...    Author: I_MN_5G_RAN_IV4_LINE_HZG_8_IV@internal.nsn.com

*** Variables ***

*** Keywords ***
CM Upload in Backend
    Set Test Variable    ${DN}    PLMN-PLMN/MRBTS-${BTS_ID}
    ${upload_command}=   set variable  racclimx.sh -v -op Upload -DN ${DN}
    ${expect_output}=   set variable   Operation upload completed successfully
    Connect to NetAct WasNode and execute command   ${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    ...   ${LAB_INFO['CLAB737']['SERVICE_USER']}   ${LAB_INFO['CLAB737']['SERVICE_PASSWORD']}  ${upload_command}   ${expect_output}

#    Connect to NetAct WasNode and execute command   wasNode_IP=10.106.161.25
#    ...   omc_uername=omc   omc_passowrd=Nokia126_  command=${upload_command}   expect_output=${expect_output}

Connect to NetAct WasNode and execute command
    [Arguments]  ${wasNode_IP}   ${omc_uername}   ${omc_passowrd}   ${command}   ${expect_output}=default
    ${connect_NetAct}=  csn.connect_to    ${wasNode_IP}
    ...   ${omc_uername}    ${omc_passowrd}    alias=WasNode   timeout=60
    ${output}=   csn.execute   command=${command}   connection=WasNode   timeout=300
    run keyword if  '${expect_output}'!='default'   should match regexp  ${output}   ${expect_output}
    [Return]  ${output}
    [Teardown]  run keyword and ignore error  csn.disconnect    connection=${connect_NetAct}

