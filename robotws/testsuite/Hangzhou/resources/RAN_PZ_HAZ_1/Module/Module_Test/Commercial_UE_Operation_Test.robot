*** Settings ***
Documentation
...   Author: Du Ning
...   Contact: ning.du@nokia-sbell.com
...   Description: This is the module test cases

Library    ../Commercial_UE_Operation.py

Force Tags        RAN_VRF_HAZ1

Test Timeout      30 minutes

*** Variables ***

${serials}     8885dec7


*** Test Cases ***
TC01_General_Commercial_UE_Operation_Test
    [Tags]    CRT    TC01

    # Commercial UE Operation    attach    serialno=${serials}
    # Commercial UE Operation    attach    serialno=${serials}    forced=${True}
    # Commercial UE Operation    attach    serialno=${serials}    expected_pci=101
    # Commercial UE Operation    attach    serialno=${serials}    expected_pci=101  expected_cellid=2817893
    # ${ueip}=    Commercial UE Operation    get   serialno=${serials}    item=ueip
    # log to console   \nFound UEIP: ${ueip}

    # Commercial UE Operation    start traffic    serialno=${serials}
    # ...  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=dl
    # ...  remote_hostname=10.69.9.57    remote_username=ute    remote_password=qqwweeRR0-

    # sleep  10s

    # Commercial UE Operation    stop traffic    serialno=${serials}  direction=dl
    # ...  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
    # ...  remote_hostname=10.69.9.57    remote_username=ute    remote_password=qqwweeRR0-

    Commercial UE Operation    start traffic    serialno=${serials}
    ...  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001  direction=ul
    ...  remote_hostname=10.69.9.57    remote_username=ute    remote_password=qqwweeRR0-

    sleep  10s

    Commercial UE Operation    stop traffic    serialno=${serials}  direction=ul
    ...  IperfOptions=-u -i 1 -t 300 -b 10M -p 50001
    ...  remote_hostname=10.69.9.57    remote_username=ute    remote_password=qqwweeRR0-

    # ${naastatus}=    Commercial UE Operation    get   serialno=${serials}    item=naastatus
    # log to console     ${naastatus["data"][0]["location"]["signalInfo"]["rsrp"]}

    # Commercial UE Operation    ui_operation   serialno=8885dec7    item=wakeup
    # Commercial UE Operation    ui_operation   serialno=8885dec7    item=launch_setting
    # Commercial UE Operation    ui_operation   serialno=8885dec7    item=launch_naa

    # ${ueip}=  Commercial UE Operation    get   serialno=8885dec7    item=ueip
    # log to console   \nFound UEIP: ${ueip}

    # ${naastatus}=  Commercial UE Operation    get   serialno=8885dec7    item=naastatus
    # log to console   \n${naastatus}

    # ${ultput}=  Commercial UE Operation    get   serialno=8885dec7    item=ultput
    # ${dltput}=  Commercial UE Operation    get   serialno=8885dec7    item=dltput
    # log to console   \nUL TPUT: ${ultput}
    # log to console   \nDL TPUT: ${dltput}
    # Commercial UE Operation    start uc test or sequence   serialno=8885dec7    test_name=Iperf3Server
    # sleep    10s
    # Commercial UE Operation    stop uc test or sequence   serialno=8885dec7    test_name=Iperf3Server

    # Commercial UE Operation    start uc test or sequence   serialno=8885dec7    sequence_name=tq
    # sleep    10s
    # Commercial UE Operation    stop uc test or sequence   serialno=8885dec7    sequence_name=tq

    # Commercial UE Operation    import uc test from file    serialno=8885dec7    test_file=/home/ute/test.uct
    # ...    test_name=jutest

    # Commercial UE Operation    import uc sequence from file    serialno=8885dec7    sequence_file=/home/ute/seq.uct
    # ...    sequence_name=jutestSeq    replace=True

    # Commercial UE Operation    import uc sequence from file    serialno=8885dec7    sequence_file=/home/ute/seq.uct
    # ...    sequence_name=jutestSeq