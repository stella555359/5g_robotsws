
*** Settings ***
Documentation            Add and Remove UEs from Basic_wts_step2.cfg File

Resource                            ../Connect.robot
Resource                            ../Setup.robot
Resource                            ../SetConfig.robot
Variables                           Constants-addremoveUEs.py

Suite Setup                         Suite setup         listBackupFiles=${FD_ALL}
Suite Teardown                      Suite teardown

*** Variables ***

&{dict_settings_ue_1}                                               ue=1
...                                                                 target_cells=1                  # original cell for call establishment
...                                                                 DL_throughput=100               # DL_throughput nonGBR
...                                                                 DL_throughput_GBR=0             # DL_throughput GBR
...                                                                 UL_throughput=0                 # UL_throughput nonGBR
...                                                                 ue_nr_capa=${SA_TDD_RANK4}
&{dict_settings_ue_2}                                               ue=2
...                                                                 target_cells=2
...                                                                 DL_throughput=100
...                                                                 DL_throughput_GBR=0
...                                                                 UL_throughput=0
...                                                                 ue_nr_capa=${SA_TDD_RANK4}
&{dict_settings_ue_3}                                               ue=3
...                                                                 target_cells=3
...                                                                 DL_throughput=100
...                                                                 DL_throughput_GBR=0
...                                                                 UL_throughput=0
...                                                                 ue_nr_capa=${SA_TDD_RANK4}
&{dict_settings_ue_4}                                               ue=4
...                                                                 target_cells=4
...                                                                 DL_throughput=100
...                                                                 DL_throughput_GBR=0
...                                                                 UL_throughput=0
...                                                                 ue_nr_capa=${SA_TDD_RANK4}
@{ues_list}                                                         ${dict_settings_ue_1}
...                                                                 ${dict_settings_ue_2}
...                                                                 ${dict_settings_ue_3}
...                                                                 ${dict_settings_ue_4}

*** Test Cases ***

Add UEs
    [Documentation]                 Add a UEs list to Basic_wts_step2.cfg File
    ${cfg_file}                     set variable                ${tl.core.dir_path}/${tl.core.cfg_filename}
    Dated log                       \nSTART - adding UEs
    Add listed UEs to Cfg File      ${ues_list}    4
    ${check_ues}                    Count Item in Cfg File    ue_nr_capa    ${cfg_file}
    Dated log                       UEs nr in file ${check_ues}
    Dated log                       Removing UEs
    Remove All listed UEs from Cfg File
    ...                             ${ues_list}               ${tl.core.dir_path}/${tl.core.cfg_filename}
    ${check_ues}                    Count Item in Cfg File    ue_nr_capa    ${cfg_file}
    Dated log                       UEs nr in file ${check_ues}

*** keywords ***

Count Item in Cfg File
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${item}
    ...                             ${cfg_file}
    ${nb_item} =                    Run                         grep ${item} ${cfg_file} | wc -l
    [Return]                        ${nb_item}