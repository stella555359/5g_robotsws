*** Settings ***
Documentation

Resource          ../Module.robot
Resource          ../../../../SISO/RAN_PZ_HAZ_1/resources/common_setup.robot

Force Tags        RAN_VRF_HAZ1

Test Timeout      30 minutes
Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
@{command}             cat /ram/fault_history_log.txt
&{ru_commands}         connect_type=ssh    connect_port=22    commands=${command}
&{ru_user_password}    username=rfsw    password=KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
&{ru_sw_storage}       sw_server_username=siso
...                    sw_server_password=siso
...                    sw_server_ip=10.106.211.194
...                    sw_path=/home/siso/LTE/Factory_SW
...                    sw_file=FRM-rfsw-image-install_20230316151252-multi.tar
#...                    sw_checksum=0xdaecbc67
...                    sw_checksum=0x12345679
...                    sw_version=install_20230316151251-multi
...                    build_name=RF.FRM5.23R3.20230315.005
...                    build_version=RF.FRM5.23R3.20230315.005
#...                    sw_type=LRM
#...                    sw_type=SRM
...                    sw_type=normal
...                    sw_correct=False

*** Test Cases ***
Module_Test_Send_Commands_To_RU
    RU Operation    operation=send_commands_to_ru
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    ru_commands=${ru_commands}
    ...    ru_user_password=${ru_user_password}

Module_Test_Download_File_From_RU
    &{file_path_dict}    Create Dictionary
    ...    file_name=Unit*    source_path=/ram/UnitOAM_SOAP_Runtime_Log    target_path=/home/ute/Downloads/test
    RU Operation    operation=download_file_from_ru
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    file_path_dict=${file_path_dict}
    ...    ru_user_password=${ru_user_password}
    ...    timeout=300

Module_Test_Upload_File_To_RU
    &{file_path_dict}    Create Dictionary
    ...    file_name=module_debug.zip    source_path=/home/ute/Downloads    target_path=/tmp
    RU Operation    operation=upload_file_to_ru
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    file_path_dict=${file_path_dict}
    ...    ru_user_password=${ru_user_password}

Module_Test_Get_RU_Aashell_Log
    &{ru_log_info}    Create Dictionary
    ...    log_type=aashell    log_name=module_debug.zip    target_path=/home/ute/Downloads
    RU Operation    operation=get_ru_log
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    ru_log_info=${ru_log_info}
    ...    ru_user_password=${ru_user_password}
    RU Operation    operation=check_ru_log
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    ru_log_info=${ru_log_info}

Module_Test_Get_RU_Soap_Log
    &{ru_log_info}    Create Dictionary
    ...    log_type=soap    log_name=UnitOAM_SOAP_*    target_path=/home/ute/Downloads
    RU Operation    operation=get_ru_log
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    ru_log_info=${ru_log_info}
    ...    ru_user_password=${ru_user_password}
    RU Operation    operation=check_ru_log
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    ru_log_info=${ru_log_info}

Module_Test_RU_Calibration
    ${calibration_data}    RU Operation    operation=get_calibration_data
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    ru_user_password=${ru_user_password}
    RU Operation    operation=check_calibration_result
    ...    product_type=gnb
    ...    ru_sn=AH232601217
    ...    check_point={"calibration_data": ${calibration_data}, "antenna_elements": "8/8"}

Module_Test_Upgrade_RU
    RU Operation    operation=upgrade_ru
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    ru_user_password=${ru_user_password}
    ...    ru_sw_storage=${ru_sw_storage}
    RU Operation    operation=check_ru_upgrade
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    ru_sw_storage=${ru_sw_storage}

Module_Test_AZNA_Fault_1901
    # AZNA fault 1901
    RU Operation    operation=trigger_ru_fault
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    fault_id=1901
    ...    ru_user_password=${ru_user_password}
    RU Operation    operation=clear_ru_fault
    ...    product_type=gnb
    ...    ru_sn=1M225120850
    ...    fault_id=1901
    ...    ru_user_password=${ru_user_password}
