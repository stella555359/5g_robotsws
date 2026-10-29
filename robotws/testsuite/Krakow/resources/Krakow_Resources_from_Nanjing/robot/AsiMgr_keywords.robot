*** Settings ***
Documentation
...    author: Agnieszka Bylica, Adam Moszczynski
...    contact: agnieszka.bylica@nokia.com, adam.1.moszczynski@nokia.com
...    Common Robot keywords for AsiMgr.

Library    taf.ul.sc.gnb.airscale.AirScale    oam_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}    WITH NAME    AirScale

*** Variables ***
${config_dir}=  ${OUTPUT DIR}/config/hub1/


*** Keywords ***

Get Current Commissioning File From AsiMgr
    ${path_to_asimgr_scf_file}    AsiMgr.collect_commissioning_file    ${config_dir}
    Set Suite Variable    ${path_to_asimgr_scf_file}

Perform Commissioning For AsiMgr
    AsiMgr.Send commission fullfile   ${path_to_asimgr_scf_file}

Commission changes to gNB and wait
    [Arguments]  ${path_to_SCF_file}
    Send commission fullfile  ${path_to_SCF_file}
    RestAPI.Reset And Wait For Site
    Check AsiR Container Status
    sleep  60

Modify AsiMgr Parameter And Check
    [Arguments]  ${param_name}    ${new_value}    ${path_to_delta_file}    ${path_to_scf_file}
    ${path_to_delta_file}  Adjust Version In Asimgr Delta Scf  path_to_scf=${path_to_scf_file}  outputdir=${config_dir}
    ...  path_to_delta=${path_to_delta_file}
    Modify Parameter On Asimgr    p_name=${param_name}    p_value=${new_value}    path_to_delta_scf=${path_to_delta_file}
    Check Asimgr Parameter Value  p_name=${param_name}    p_value=${new_value}    outputdir=${config_dir}

Perform AsiMgr Full Commissioning
    [Arguments]  ${path_to_scf_file}
    AsiMgr.send_commission_fullfile    ${path_to_scf_file}
