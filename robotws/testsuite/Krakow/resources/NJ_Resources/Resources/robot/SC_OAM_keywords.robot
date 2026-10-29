*** Settings ***
Documentation
...    author: Ye Dan Zhou
...    contact: ye_dan.yz.zhou@nokia.com
Library   taf.gnb.oam.coam.admin    WITH NAME    coam
Resource    ../../../Krakow_Resources_from_Nanjing/robot/Common.robot
Resource    ../../../Krakow_Resources_from_Nanjing/robot/OAM5G_keywords.robot



*** Keywords ***
Get Current Commissioning
    RestAPI.Get current commissioning   log_dir=${OUTPUT DIR}  scf_name=Current_SCF.xml

Modify Parameters and Perform Commissioning
    [Documentation]  ye_dan.yz.zhou@nokia.com: Download commissioning file, modify parameters and then perform commissioning.
    [Arguments]  ${scf_parameter_to_modify}
    RestAPI.Get current commissioning   log_dir=${OUTPUT DIR}  scf_name=Current_SCF.xml
    AirScale.Modify select parameters    param=${scf_parameter_to_modify}    scf_dir=${OUTPUT DIR}
    ...                                  current_scf_name=Current_SCF.xml    modify_scf_name=Modified_SCF.xml
    RestAPI.Perform Commissioning   ${OUTPUT DIR}/Modified_SCF.xml

Get Parameters from downloaded Commissioning
    [Documentation]  Get value of parameter in the commissioning file.
    [Arguments]    ${file_full_path}    ${param_name}
    scf.Load Scf    file_path=${file_full_path}
    ${param_value} =    scf.Get Value From Scf    p_name=${param_name}
    [Return]    ${param_value}
