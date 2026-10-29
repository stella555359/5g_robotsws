*** Settings ***

Documentation     Keywords related to CB013289
Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf
Library      Process

Resource    ../../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Variables ***

#${nsetapx_plugin_addr}
#...    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/SBTS00_ENB_9990_240823_000009/
#...  mcshark-4.0-1.29.0-SBTS00_ENB_9990_240823_000009+buster.so
${plugin_folder}   /usr/lib/x86_64-linux-gnu/wireshark/plugins
${plugin_folder_utevm}   /home/ute/.local/lib/wireshark/plugins


*** Keywords ***
Download wireshark plugin
    sleep    5s
    ${nsetapx_plugin_addr} =  catenate   SEPARATOR=
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/SBTS00_ENB_9990_240823_000009/
    ...    mcshark-4.0-1.29.0-SBTS00_ENB_9990_240823_000009+buster.so
    log to console    ${nsetapx_plugin_addr}
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls mcshark*
    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls mcshark*
    Run Keyword If   ${exist.count('No such file or directory')}>0 and ${exist_utevm.count('No such file or directory')}>0   Run
    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}

Download wireshark PCMD plugin
    sleep    5s
    ${nsetapx_plugin_addr}  Catenate    SEPARATOR=
    ...  https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X/nsetapx-1.13.4/nsetapx-4.0-0.7.0-1.13.4+bookworm.so
    log to console    ${nsetapx_plugin_addr}
    ${ver}   Run   ls ${plugin_folder}/
    ${exist}   Run   cd ${plugin_folder}/${ver}/epan;ls nsetapx*
    ${exist_utevm}   Run   cd ${plugin_folder_utevm}/${ver}/epan;ls nsetapx*
    Run Keyword If   ${exist.count('No such file or directory')}>0 and ${exist_utevm.count('No such file or directory')}>0   Run
    ...   cd ${plugin_folder}/${ver}/epan;sudo wget ${nsetapx_plugin_addr}

stop tcpdump on vm
    Run Process    sudo pkill -f tcpdump   shell=True

start tcpdump on vm
    ${LONG_RUNNING_COMMAND}    set variable     sudo tcpdump -i any -w /home/ute/wts_13289.pcap
    ${result}    Start Process    ${LONG_RUNNING_COMMAND}    shell=True    stdout=stdout.txt    stderr=stderr.txt   alias=long_running

CB013289 Check Direct Path Item
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 22
    ...            ${second_filter}=s1ap.id == 78
    Log To Console    ${second_filter}
    ${direct_path_item}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.DirectForwardingPathAvailability -r ${local_file_path}
    Log To Console    ${direct_path_item}
    Should Be Equal    ${direct_path_item}    0    #'0' means Direct Path is available

CB013289 Check Data Forwarding By NG interface
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=e1ap.id == 76
    ${ranue_id}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e e1ap.RANUEID -r ${local_file_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Start With    ${ranue_id}    ff

CB013289 Check Data Forwarding By X2 interface
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=e1ap.id == 76
    ${ranue_id}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e e1ap.RANUEID -r ${local_file_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Start With    ${ranue_id}    fe

CB013289 Check Data Forwarding By XN interface
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=e1ap.id == 76
    ${ranue_id}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e e1ap.RANUEID -r ${local_file_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Be Empty    ${ranue_id}

CB013289 AB1 TC02 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 249
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_erab_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_command_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    2         5        5
    ...    2         6        6
        Should Contain    ${ho_command_erab_id_list}   ${erab_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}
    Should Be Equal     ${ho_required_erab_id_list}    ${ho_command_erab_id_list}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    2         5        5
    ...    2         6        6
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB1 TC04 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 249
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_erab_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_command_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
        Should Contain    ${ho_command_erab_id_list}   ${erab_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}
    Should Be Equal     ${ho_required_erab_id_list}    ${ho_command_erab_id_list}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB1 TC05 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 249
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_erab_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_command_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
        Should Contain    ${ho_command_erab_id_list}   ${erab_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}
    Should Be Equal     ${ho_required_erab_id_list}    ${ho_command_erab_id_list}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB1 TC06 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 249
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_erab_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_command_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    3         6        5
    ...    3         7        6
    ...    3         8        7
    ...    3         9        8
        Should Contain    ${ho_command_erab_id_list}   ${erab_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}
    Should Be Equal     ${ho_required_erab_id_list}    ${ho_command_erab_id_list}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    3         6        5
    ...    3         7        6
    ...    3         8        7
    ...    3         9        8
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB1 TC07 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 249
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_erab_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_command_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    3         2        6
        Should Contain    ${ho_command_erab_id_list}   ${erab_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    3         6        5
    ...    3         7        6
    ...    3         8        7
    ...    3         9        8
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB1 TC08 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=e1ap.id == 131
    ...            ${second_filter}=s1ap.id == 78
    ${e1ap_teid_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e e1ap.gTP_TEID -r ${local_file_path}
    Log To Console    ${e1ap_teid_list}

    FOR    ${pdu}    ${id}    ${teid_id}             IN
    ...    1         0        00000001
    ...    1         1        00000002
    ...    1         2        00000003
        Should Not Contain    ${e1ap_teid_list}   ${teid_id}
    END

    FOR    ${pdu}    ${id}    ${teid_id}             IN
    ...    2         0        00000004
    ...    2         1        00000005
    ...    3         2        00000006
    ...    3         3        00000007
    ...    3         4        00000008
    ...    3         5        00000009
        Should Contain    ${e1ap_teid_list}   ${teid_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
    ...    3         6        5
    ...    3         7        6
    ...    3         8        7
    ...    3         9        8
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB1 TC09 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 106
    ...            ${second_filter}=ngap.id == 101
    ${ho_command_erab_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_command_erab_id_list}
    Should Be Empty    ${ho_command_erab_id_list}

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    Should Be Empty    ${ho_required_erab_id_list}


CB013289 AB2 TC10 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.qosFlowIdentifier -r ${local_file_path}
    Log To Console    ${ho_command_qos_id_list}

    FOR    ${pdu}    ${id}    ${qos_id}             IN
    ...    1         0        1
    ...    1         1        2
    ...    1         2        3
    ...    2         3        1
    ...    2         4        2
        Should Contain    ${ho_command_qos_id_list}   ${qos_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB2 TC11 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.qosFlowIdentifier -r ${local_file_path}
    Log To Console    ${ho_command_qos_id_list}

    FOR    ${pdu}    ${id}    ${qos_id}             IN
    ...    1         0        1
    ...    1         1        2
    ...    1         2        3
        Should Contain    ${ho_command_qos_id_list}   ${qos_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB2 TC12 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.gTP_TEID -r ${local_file_path}
    Log To Console    ${ho_command_qos_id_list}
    Should Be Empty    ${ho_command_qos_id_list}

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.dL_Forwarding -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    Should Be Empty    ${ho_required_erab_id_list}

CB013289 AB2 TC13 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.qosFlowIdentifier -r ${local_file_path}
    Log To Console    ${ho_command_qos_id_list}

    FOR    ${pdu}    ${id}    ${qos_id}             IN
    ...    1         0        1
    ...    1         1        2
    ...    1         2        3
    ...    1         4        1
    ...    1         5        2
        Should Contain    ${ho_command_qos_id_list}   ${qos_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB2 TC14 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.qosFlowIdentifier -r ${local_file_path}
    Log To Console    ${ho_command_qos_id_list}

    FOR    ${pdu}    ${id}    ${qos_id}             IN
    ...    1         0        1
    ...    1         1        2
        Should Contain    ${ho_command_qos_id_list}   ${qos_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB1 FDD TC48 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 249
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_erab_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_command_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
        Should Contain    ${ho_command_erab_id_list}   ${erab_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}
    Should Be Equal     ${ho_required_erab_id_list}    ${ho_command_erab_id_list}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    2         3        3
    ...    2         4        4
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB3 TC23 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.qosFlowIdentifier -r ${local_file_path}
    Log To Console    ${ho_command_qos_id_list}

    FOR    ${pdu}    ${id}    ${qos_id}             IN
    ...    1         0        1
    ...    1         1        2
        Should Contain    ${ho_command_qos_id_list}   ${qos_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB4 TC28 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.qosFlowIdentifier -r ${local_file_path}
    Log To Console    ${ho_command_qos_id_list}

    FOR    ${pdu}    ${id}    ${qos_id}             IN
    ...    1         0        1
    ...    2         1        1
    ...    2         2        2
        Should Contain    ${ho_command_qos_id_list}   ${qos_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    2         1        1
    ...    2         2        2
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 AB4 TC29 Check Ponit For 24R3
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    ${ho_command_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.qosFlowIdentifier -r ${local_file_path}
    Log To Console    ${ho_command_qos_id_list}

    FOR    ${pdu}    ${id}    ${qos_id}             IN
    ...    1         0        1
    ...    1         1        2
    ...    1         2        3
    ...    2         3        1
    ...    2         4        2
        Should Contain    ${ho_command_qos_id_list}   ${qos_id}
    END

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    2         3        3
    ...    2         4        4
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 PCMD CUCP MBA Check Ponit
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=nsetapx.trigger == 2
    ...            ${second_filter}=s1ap.id == 78
    Log To Console    ${second_filter}
    ${tshark_cmd}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.traceActivationType -r ${local_file_path}
    ${PCMD_traceActivationType}=    Run    ${tshark_cmd}
    Log To Console    ${PCMD_traceActivationType}
    Should Be Equal    ${PCMD_traceActivationType}    0    #'0' means 'MBA'

    ${tshark_cmd_1}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.forwardingType -r ${local_file_path}
    ${PCMD_forwardingType}=    Run    ${tshark_cmd_1}
    Log To Console    ${PCMD_forwardingType}
    Should Be Equal    ${PCMD_forwardingType}    1    #'1' means 'Direct'

    ${tshark_cmd_2}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.forwardingTarget -r ${local_file_path}
    ${PCMD_forwardingTarget}=    Run    ${tshark_cmd_2}
    Log To Console    ${PCMD_forwardingTarget}
    Should Be Equal    ${PCMD_forwardingTarget}    1    #'1' means 'eutran'


CB013289 PCMD CUCP SBA Check Ponit
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=nsetapx.forwardingTarget == 1
    ...            ${second_filter}=s1ap.id == 78
    Log To Console    ${second_filter}
    ${tshark_cmd}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.traceActivationType -r ${local_file_path}
    ${PCMD_traceActivationType}=    Run    ${tshark_cmd}
    Log To Console    ${PCMD_traceActivationType}
#    Should Be Equal    ${PCMD_traceActivationType}    1    #'1' means 'SBA'

    ${tshark_cmd_1}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.trigger -r ${local_file_path}
    ${PCMD_trigger}=    Run    ${tshark_cmd_1}
    Log To Console    ${PCMD_trigger}
    Should Be Equal    ${PCMD_trigger}    2    #'2' means 'handover'

    ${tshark_cmd_2}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.forwardingType -r ${local_file_path}
    ${PCMD_forwardingType}=    Run    ${tshark_cmd_2}
    Log To Console    ${PCMD_forwardingType}
    Should Be Equal    ${PCMD_forwardingType}    1    #'1' means 'Direct'

CB013289 PCMD CUCP SBA Indirect Check Ponit
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=nsetapx.forwardingTarget == 1
    ...            ${second_filter}=s1ap.id == 78
    Log To Console    ${second_filter}
    ${tshark_cmd}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.traceActivationType -r ${local_file_path}
    ${PCMD_traceActivationType}=    Run    ${tshark_cmd}
    Log To Console    ${PCMD_traceActivationType}
#    Should Be Equal    ${PCMD_traceActivationType}    1    #'1' means 'SBA'

    ${tshark_cmd_1}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.trigger -r ${local_file_path}
    ${PCMD_trigger}=    Run    ${tshark_cmd_1}
    Log To Console    ${PCMD_trigger}
    Should Be Equal    ${PCMD_trigger}    2    #'2' means 'handover'

    ${tshark_cmd_2}  catenate    tshark -Y "${first_filter}" -o ntrstr.defragment:TRUE -d tcp.port==49151,ntrstr
    ...  -d tcp.port==49148,ntrstr -d tcp.port==15000-15500,ntrstr -T fields -e nsetapx.forwardingType -r ${local_file_path}
    ${PCMD_forwardingType}=    Run    ${tshark_cmd_2}
    Log To Console    ${PCMD_forwardingType}
    Should Be Equal    ${PCMD_forwardingType}    0    #'1' means 'inDirect'

CB013289 EAR TC51 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=e1ap.id == 136
    ...            ${second_filter}=s1ap.id == 78
    Log To Console    ${second_filter}
    ${e1ap_qos_id_list}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e e1ap.qoS_Flow_Identifier -r ${local_file_path}
    Log To Console    ${e1ap_qos_id_list}

    FOR    ${pdu}    ${id}    ${qos_id}             IN
    ...    1         0        1
    ...    1         1        2
    ...    1         1        3
        Should Contain    ${e1ap_qos_id_list}   ${qos_id}
    END

CB013289 NIDD TC47 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.handoverRequiredTransfer
    ...            ${second_filter}=e1ap.dL_TX_Stop == 0
    ${direct_path_item}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.DirectForwardingPathAvailability -r ${local_file_path}
    Log To Console    ${direct_path_item}
    Should Be Empty    ${direct_path_item}

    ${ranue_id}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e e1ap.RANUEID -r ${local_file_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Be Empty    ${ranue_id}

CB013289 EAR TC41 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.id == 22
    ...            ${second_filter}=e1ap.dL_TX_Stop == 0
    ${direct_path_item}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e ngap.DirectForwardingPathAvailability -r ${local_file_path}
    Log To Console    ${direct_path_item}
    Should Be Equal    ${direct_path_item}    0    #'0' means Direct Path is available

    ${ranue_id}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e e1ap.RANUEID -r ${local_file_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Be Empty    ${ranue_id}

CB013289 EC1 TC15 Check Ponit 1
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=e1ap.dL_TX_Stop == 0
    ...            ${second_filter}=ngap.id == 101
    ${ranue_id}=    Run
    ...    tshark -Y "${first_filter}" -T fields -e e1ap.RANUEID -r ${local_file_path}
    Log To Console    'ranue_id'\
    Log To Console    ${ranue_id}
    Should Be Empty    ${ranue_id}

    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END

CB013289 EC1 TC20 Check Ponit 2
    [Arguments]    ${local_file_path}=/home/ute/10.69.104.82_cran1_20230315052629.pcap
    ...            ${first_filter}=ngap.qosFlowToBeForwardedList
    ...            ${second_filter}=s1ap.id == 78
    Log To Console    ${first_filter}
    ${ho_required_erab_id_list}=    Run
    ...    tshark -Y "${second_filter}" -T fields -e s1ap.e_RAB_ID -r ${local_file_path}
    Log To Console    ${ho_required_erab_id_list}
    ${length}    Get Length    ${ho_required_erab_id_list}

    FOR    ${pdu}    ${id}    ${erab_id}             IN
    ...    1         0        0
    ...    1         1        1
    ...    1         2        2
    ...    4         3        3
    ...    4         4        4
    ...    4         5        5
    ...    4         6        6
        Should Contain    ${ho_required_erab_id_list}   ${erab_id}
    END
