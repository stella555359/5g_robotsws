*** Settings ***
Documentation  AP_L1_log_collection
Library    BuiltIn
Library    Process
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***
&{AP_ASIK}      Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
${Reg_path}     ${CURDIR}
${RB_file_1}    Ringbuffer_1.bin
${RB_file_2}    Ringbuffer_2.bin
${Tx_file}      Tx_Reg.txt
${Rx_file}      Rx_Reg.txt
${Script}       Reg.sh
${OP_Tx_file}   OP_Tx_Reg
${OP_Rx_file}   OP_Rx_Reg

*** Keywords ***
Collect Ring Buffer Dump
    [Arguments]    ${test_case_folder}=
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    Set Address and Size
    Launch Trace
    Collect RingBuffer
    ${file1_status}    Download Logs    ${RB_file_1}    ${test_case_folder}
    Run Keyword If    '${file1_status}'=='False'    Log To Console    Download failed for ${RB_file_1}
    ${file2_status}    Download Logs    ${RB_file_2}    ${test_case_folder}
    Run Keyword If    '${file2_status}'=='False'    Log To Console    Download failed for ${RB_file_2}
    Cleanup Logs    ${RB_file_1}
    Cleanup Logs    ${RB_file_2}
    SSH.Disconnect    ${AP_ASIK.Connection}

Set Address and Size
    SSH.Execute    bsh 1:2 fpga_rw wa 0xdf400480 0x18C00000    &{AP_ASIK}[Connection]
    SSH.Execute    bsh 1:2 fpga_rw wa 0xdf400484 0x00100000    &{AP_ASIK}[Connection]

Launch Trace
    SSH.Execute    bsh 1:2 fpga_rw wa 0xdf400488 1    &{AP_ASIK}[Connection]
    Sleep    30s
    SSH.Execute    bsh 1:2 fpga_rw wa 0xdf400488 0    &{AP_ASIK}[Connection]

Collect RingBuffer
    ${start}    SSH.Execute    bsh 1:2 fpga_rw ra 0xdf40048C    &{AP_ASIK}[Connection]
    ${end}    Evaluate    hex(int(${start})+16)
    ${start}    Evaluate    hex(int(${start}))
    ${start}    Evaluate    $start[-4:]
    ${end}    Evaluate    $end[-4:]
    SSH.Execute    bsh 1:2 memdump 0x18C00000 --size 0x${start} --file /ffs/run/logs/${RB_file_1}    &{AP_ASIK}[Connection]
    SSH.Execute    bsh 1:2 memdump 0x18C00000 --size 0x${end} --file /ffs/run/logs/${RB_file_2}    &{AP_ASIK}[Connection]

Download Logs
    [Arguments]    ${file}    ${test_case_folder}
    ${status}    Run Keyword And Return Status    SSH.download file    remote_path=/ffs/run/logs/${file}
    ...                                                                local_path=${test_case_folder}/${file}
    ...                                                                connection=&{AP_ASIK}[Connection]
    [Return]    ${status}

Cleanup Logs
    [Arguments]    ${file}
    SSH.Execute    bsh 1:2 rm -rf /ffs/run/logs/${file}    connection=&{AP_ASIK}[Connection]

Collect Register Dump
    [Arguments]    ${test_case_folder}
    Collect Registers    ${Tx_file}    ${OP_Tx_file}    ${test_case_folder}
    Collect Registers    ${Rx_file}    ${OP_Rx_file}    ${test_case_folder}

Collect Registers
    [Arguments]    ${file}    ${OP_file}    ${test_case_folder}=
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    Upload File    ${script}
    Upload File    ${file}
    SSH.send_command    cd /tmp;bsh 1:2 nohup /tmp/${script} /tmp/${file} /ffs/run/logs/${OP_file} &
    ...                 connection=&{AP_ASIK}[Connection]
    ${check}    Run Keyword and Return Status    Wait Until Keyword Succeeds    3 m    30 s    Check Status
    Run Keyword If    "${check}" == "${FALSE}"
    ...    Log To Console    "Register Collection is not complete, downloaded file may have partial contents"
    Download Register Logs    ${file}    ${OP_file}    ${test_case_folder}
    SSH.Disconnect    ${AP_ASIK.Connection}

Check Status
    ${pid}=    SSH.Execute    bsh 1:2 pgrep Reg.sh    connection=&{AP_ASIK}[Connection]
    ${pid}=    Strip String    ${pid}
    Should Be Empty    ${pid}

Download Register Logs
#commented during cleanup removed file keyword as not used [Arguments]    ${file}    ${OP_file}    ${test_case_folder}
    [Arguments]    ${OP_file}    ${test_case_folder}
    SSH.Execute    chmod +x /ffs/run/logs/${OP_file}.log    &{AP_ASIK}[Connection]
    ${status}    Download Logs    ${OP_file}.log    ${test_case_folder}
    Run Keyword If    '${status}'=='False'    Log To Console    Download failed for ${OP_file}.log
    Cleanup Logs    ${OP_file}.log

Upload File
    [Arguments]    ${file}
    SSH.upload_file    local_path=${Reg_path}/${file}    remote_path=/tmp/${file}    connection=&{AP_ASIK}[Connection]
    SSH.Execute    chmod +x /tmp/${file}    &{AP_ASIK}[Connection]
    SSH.Execute    bput 1:2 /tmp/${file} /tmp/    &{AP_ASIK}[Connection]
    SSH.Execute    bsh 1:2 chmod +x /tmp/${file}    connection=&{AP_ASIK}[Connection]

Enable BIP Registers
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Execute    bsh 1:2 devmem 0xdf100060 32 0x3    &{AP_ASIK}[Connection]
    SSH.Execute    bsh 1:2 devmem 0xdf100064 32 0xffffffff    &{AP_ASIK}[Connection]
    SSH.Execute    bsh 1:2 devmem 0xdf100068 32 0xffffffff    &{AP_ASIK}[Connection]
    SSH.Execute    bsh 1:2 devmem 0xdf10006c 32 0xffffffff    &{AP_ASIK}[Connection]
    SSH.Execute    bsh 1:2 devmem 0xdf100070 32 0xffffffff    &{AP_ASIK}[Connection]

Collect BIP Registers
    [Arguments]    ${test_case_folder}
    Log to Console    \n Collecting BIP Register Logs
    ${test_folder}    Set Variable    ${EXECDIR}/logs/AP_L1_Logs_${test_case_folder}
    Create directory    ${test_folder}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    SSH.Execute    bsh 1:2 dump-bip-regs bip0 > /ffs/run/logs/bip0_reg_dump.txt    &{AP_ASIK}[Connection]
    SSH.Execute    chmod +x /ffs/run/logs/bip0_reg_dump.txt    &{AP_ASIK}[Connection]
    ${status}    Download Logs    bip0_reg_dump.txt   ${test_folder}
    Run Keyword If    '${status}'=='False'    Log To Console    Download failed for bip0_reg_dump.txt
    Cleanup Logs    bip0_reg_dump.txt

Airphone_L1_log_collection
    [Arguments]    ${test_case_folder}
    Log to Console    \n Collecting AP L1 logs - Ring Buffer and Register values
    ${test_folder}    Set Variable    ${EXECDIR}/logs/AP_L1_Logs_${test_case_folder}
    Create directory    ${test_folder}
    Collect Ring Buffer Dump    ${test_folder}
    Collect Register Dump    ${test_folder}
