*** Settings ***
Documentation     Keywords related to Airphone Pronto log collection

Library    OperatingSystem
Library    taf.transport.ssh    WITH NAME    ssh

Resource   connect.robot
Resource   testline.robot

*** Variables ***
@{TX_REGISTERS_LIST}         0xDF400400  0xDF400404  0xDF400408  0xDF400800  0xDF400804  0xDF400808  0xDF40080C  0xDF400810  0xDF400814  0xDF400818
...  0xDF40081C  0xDF400820  0xDF400824  0xDF400828  0xDF400830  0xDF400834  0xDF400838  0xDF40083C  0xDF400840  0xDF400844  0xDF400848  0xDF40084C
...  0xDF400850  0xDF400854  0xDF400858  0xDF40085C  0xDF400860  0xDF400864  0xDF400868  0xDF40086C  0xDF400870  0xDF400874  0xDF400878  0xDF400900
...  0xDF400904  0xDF400908  0xDF40090C  0xDF400910  0xDF400914  0xDF400918  0xDF40091C  0xDF40140C  0xDF401410  0xDF401420  0xDF401424  0xDF401428
...  0xDF401414  0xDF40142C  0xDF400100  0xDF400104  0xDF400108  0xDF40010C  0xDF400110  0xDF400114  0xDF400118  0xDF40011C

@{RX_REGISTERS_LIST}         0xDF580010  0xDF580014  0xDF580018  0xDF58001C  0xDF580020  0xDF580024  0xDF580028  0xDF58002C  0xDF580030  0xDF580058
...  0xDF58005C  0xDF580060  0xDF580064  0xDF580074  0xDF58007C  0xDF580080  0xDF580084  0xDF580088  0xDF58008C  0xDF580090  0xDF580094  0xDF580110
...  0xDF580114  0xDF580118  0xDF58011C  0xDF580120  0xDF580124  0xDF580128

*** Keywords ***

Collect FPGA register dumps for L1 analysis
    [Documentation]
    ...    Collect RX/TX FPGA register dumps from AP common unit for L1 analysis. Takes around 3min.
    ...    https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1148196514
    ...
    ...    | ue_id      | Ue Id/index according to tl.ue list |
    ...    | target_dir | path to directory the logs will be saved, uses Test Suite Log directory if not defined |
    ...    | file_name  | name of the log file |
    ...    
    [Arguments]  ${ue_id}=0    ${target_dir}=${None}    ${file_name}=ue${ue_id}_l1_register_dumps.txt
    ${resultLogDir}=    Run Keyword If   '${target_dir}'=='${None}'    testline.Get test suite log directory
    ...    ELSE         Set Variable     ${target_dir}
    ${log_file}=        Set Variable     ${resultLogDir}/${file_name}
    OperatingSystem.Run    touch ${log_file}
    ${ap_alias}=        connect.Connect to Airphone Common Unit    ue_id=${ue_id}
    OperatingSystem.Run    echo "Tx registers:\n" >> ${log_file}
    FOR    ${register}    IN   @{TX_REGISTERS_LIST}
        ${register_value}=     ssh.execute    bsh 1:2 fpga_rw ra ${register}    connection=${ap_alias}
        OperatingSystem.Run    echo "fpga_rw ra ${register} --> ${register_value}" >> ${log_file}
    END
    OperatingSystem.Run    echo "\n\nRx registers:\n" >> ${log_file}
    FOR    ${register}    IN   @{RX_REGISTERS_LIST}
        ${register_value}=     ssh.execute    bsh 1:2 fpga_rw ra ${register}    connection=${ap_alias}
        OperatingSystem.Run    echo "fpga_rw ra ${register} --> ${register_value}" >> ${log_file}
    END


Start Airphone Ring buffer trace
    [Documentation]
    ...    Start mandatory Log collection for L1 analysis.
    ...    https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1038262559
    ...
    ...    | ue_id | Ue Id/index according to tl.ue list |
    ...
    [Arguments]  ${ue_id}=0
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}
    FOR     ${register}    ${value}     IN
    ...     0xdf400480     0x18C00000
    ...     0xdf400484     0x00100000
    ...     0xdf400488     1
        ssh.execute    bsh 1:2 fpga_rw wa ${register} ${value}    connection=${ap_alias}
    END

Stop Airphone Ring buffer trace
    [Documentation]
    ...    Stop and store mandatory Logs from Airphone for L1 analysis.
    ...
    ...    | ue_id      | Ue Id/index according to tl.ue list |
    ...    | target_dir | path to directory the logs will be saved, uses Test Suite Log directory if not defined |
    ...    | file_name  | name of the log file |
    ...    
    [Arguments]  ${ue_id}=0    ${target_dir}=${None}    ${file_name}=ue${ue_id}_tx.bin
    ${resultLogDir}=    Run Keyword If    '${target_dir}'=='${None}'   testline.Get test suite log directory
    ...    ELSE         Set Variable      ${target_dir}
    ${ap_alias}=        connect.Connect to Airphone Common Unit        ue_id=${ue_id}
    ssh.execute         bsh 1:2 fpga_rw wa 0xdf400488 0                connection=${ap_alias}
    ${buffer_end}=      ssh.execute    bsh 1:2 fpga_rw ra 0xdf40048C   connection=${ap_alias}
    ${buffer_size}=     evaluate    hex(${buffer_end} - 0x18C00000)
    ssh.execute         bsh 1:2 memdump 0x18C00000 --size ${buffer_size} --file ${file_name}       connection=${ap_alias}
    ssh.execute         scp asp-1c:${file_name} /tmp/${file_name}                                  connection=${ap_alias}
    ssh.Download File   remote_path=/tmp/${file_name}    local_path=${resultLogDir}/${file_name}   connection=${ap_alias}

