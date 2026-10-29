*** Settings ***
Documentation
...    Author: shanshan zhang
...    Contact: shanshan.zhang@nokia-sbell.com
...    squad group:SG_04
...    Feature Sleeping cell

Suite Setup         Provided precondition for 09
Suite Teardown

Resource          ../CB007306_OTA/Resources/CB007306_common_keyword.robot
Resource          ./Resource/sleepingcell_cases.robot
Library           taf.hw.rf_attenuator        WITH NAME       att

*** Variables ***
${ue_type}                   ${tl.ues[0].capabilities[-1]}
${att_ipaddr}                ${tl.attenuator.ip_addr}
${att_connection_port}       ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_api_port}              ${tl.attenuator.port}
${att_port_5}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_6}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_7}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_8}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${PositionMotion_ip1}        10.71.206.245
${PositionMotion_ip2}        10.71.206.243
${total_times}               ${3}
${timeout}                   1800

*** Test Cases ***
CB007835-5G-A_09_Separately_RAT_block_unblock_ reset_then L3call
    [Tags]    CRT_TRUNK
    log to console    \ntotal times:${total_times}
    FOR    ${itime}    IN RANGE    1    ${total_times}+1
        Log to console    \n---------------------\nexecute process: ${itime}/${total_times}
        ${status}    run keyword and return status    Separately RAT Block and Unblock then L3call
        run keyword if    not ${status}    run keywords    Connect to gnb coam via ssl    AND
        ...    Save Coam Snapshot    target_dir=${output_dir}/${itime}    timeout=${timeout}
        should be true    ${status}
    END


*** Keywords ***
Provided precondition for 09
    [Arguments]      ${connection}=GNB_OAM
    Adjust the HBTE attenuation value
    Set X and Y PositionMotion       ip=${PositionMotion_ip1}     end_X=${0}       end_Y=${0}
    Set X and Y PositionMotion       ip=${PositionMotion_ip2}     if_X=${False}    end_Y=${90}
    Connect to gnb coam via ssl    connection=${connection}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    [Teardown]      COAM Teardown gnb connections    connection=${connection}
