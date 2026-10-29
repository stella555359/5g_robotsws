*** Settings ***
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot


Documentation
...     [Procedure]     "CB010792: Introduction of O-RAN fronthaul specification baseline v12"

*** Variables ***
${tc_variables}     testcase_variables.json

***Keywords***

Trigger O-RU common fault from O-RU simulator
        Setup Remote Access     remote_device=ORU_simulator     alias=conn26
        Execute Interactive Remote Command  command=${sudo}  alias=conn26
        Execute Interactive Remote Command  command=${password}   alias=conn26
        ${container}=   Execute Interactive Remote Command    command=${ORU1_container}    alias=conn26
        ${container_ID}=    Get Line   ${container}     2
        Execute Interactive Remote Command      command=cd /root    exit_prompt=#     alias=conn26
        Execute Interactive Remote Command      command=${command}      exit_prompt=#      alias=conn26
        Execute Interactive Remote Command      command=${generate_alarm}    return_rc=${True}     alias=conn26

Verify alarm on BTS
        Verify Alarm     faultid=34    occurrences=1      should_exist=${True}

Verify alarm via Netact
        Setup Ems  config_device=netact   alias=lab1042
        Cm Upload   config_device=netact   alias=lab1042
        Verify Ems Alarm    config_device=netact    alarmid=7240    should_exist=${True}    occurrences=1   alias=lab1042
        [Teardown]      Run Keyword     Teardown Ems      config_device=netact       alias=lab1042


Clear Alarm and verify via Netact
        Execute Interactive Remote Command      command=${command}      exit_prompt=#      alias=conn26
        Execute Interactive Remote Command   command=${clear_alarm}  alias=conn26
        Execute Interactive Remote Command   command=${exit}  alias=conn26
        Setup Ems  config_device=netact   alias=lab1042
        Cm Upload   config_device=netact   alias=lab1042
        Verify Ems Alarm    config_device=netact   alarmid=7240    should_exist=${False}    alias=lab1042
        [Teardown]      Run Keyword     Teardown Ems      config_device=netact       alias=lab1042

Clear Alarm and verify on BTS
        Execute Interactive Remote Command      command=${command}      exit_prompt=#      alias=conn26
        Execute Interactive Remote Command   command=${clear_alarm}  alias=conn26
        Verify Alarm     faultid=34    occurrences=1      should_exist=${False}

Verfiy option125 with ORANV12
       Setup Remote Access     remote_device=bts    alias=bbmod
       Execute Interactive Remote Command     command=${bbmod_login_primary}   alias=bbmod
#       Execute Interactive Remote Command  command=${sudo}  alias=ssh
       Execute Interactive Remote Command  command=${password1}  alias=bbmod
       Execute Interactive Remote Command     command=${traffic_capture}        alias=bbmod
       Setup Remote Access     remote_device=ORU_simulator     alias=ssh
       Execute Interactive Remote Command  command=${sudo}  alias=ssh
       Execute Interactive Remote Command  command=${password}   alias=ssh
       ${oru}=   Execute Interactive Remote Command    command=${oru}    alias=ssh
       Sleep     600
       Teardown Remote Access  alias=ssh
       Execute Interactive Remote Command     command=${BBMOD_copy_1}       alias=bbmod
       Execute Interactive Remote Command     command=${SMOD_pwd}       alias=bbmod
       Execute Interactive Remote Command     command=${exit_command}       alias=bbmod
       Get File From Remote Host       source=${path}         destination=/home/ute    alias=bbmod
       Analyse Pcap        pcap_filename=${filename}        analysis=verify_ORU_option125   alias=bbmod
       Analyse Pcap        pcap_filename=${filename}        analysis=verify_ODU_option125   alias=bbmod
       Analyse Pcap        pcap_filename=${filename}        analysis=verify_ORU_SZTPoption   alias=bbmod
       Analyse Pcap        pcap_filename=${filename}        analysis=verify_ORU_SZTPoption  alias=bbmod
       Teardown Remote Access  alias=bbmod

Verfiy option43 with ORANV12
#       Check SSH Login         Secondarybts       alias=bbmod
      Setup Remote Access     remote_device=secondary_vm    alias=bbmod
      Execute Interactive Remote Command     command=${dut_login}     alias=bbmod
       Execute Interactive Remote Command     command=${bbmod_login_sec}   alias=bbmod
        Execute Interactive Remote Command  command=${password1}  alias=bbmod
       Execute Interactive Remote Command     command=${traffic_capture2}        alias=bbmod
       Setup Remote Access     remote_device=ORU_simulator     alias=ssh
       Execute Interactive Remote Command  command=${sudo}  alias=ssh
#       Execute Interactive Remote Command  command=${password}   alias=ssh
       ${oru}=   Execute Interactive Remote Command    command=${oru2}   alias=ssh
       Sleep     400
      Teardown Remote Access  alias=ssh
       Execute Interactive Remote Command     command=${exit_command}       alias=bbmod
       Execute Interactive Remote Command     command=${copy_bbmodRM_to_secboard}       alias=bbmod
#       Execute Interactive Remote Command     command=${exit_command}       alias=bbmod
#       Execute Interactive Remote Command     command=${pcap}       alias=bbmod
        Execute Interactive Remote Command     command=${password1}       alias=bbmod
#       Execute Interactive Remote Command     command=${exit_command}       alias=bbmod
       Execute Interactive Remote Command     command=${copy_board_to_vm}       alias=bbmod
        Execute Interactive Remote Command     command=${vm_password}       alias=bbmod
          Execute Interactive Remote Command     command=${exit_command}       alias=bbmod
       Execute Interactive Remote Command     command=${copy_sec_to_pri_vm}       alias=bbmod
       Execute Interactive Remote Command     command=${vm_password}       alias=bbmod
#       Get File From Remote Host       source=${path2}         destination=/home/ute    alias=bbmod
       Analyse Pcap        pcap_filename=${filename2}       analysis=verify_ORU_option43    alias=bbmod
       Analyse Pcap        pcap_filename=${filename2}       analysis=verify_ODU_option43    alias=bbmod
       Teardown Remote Access  alias=bbmod


Check SSH Login
    [Arguments]     ${bts}
    Setup Remote Access     remote_device=${bts}
    [Teardown]  Teardown Remote Access

Reload BTS
    Run Keyword And Ignore Error       Perform Recommissioning    type=delta    delta_file=${DisableFLAG}        timeout=200

