*** Settings ***
Documentation
...    Author:          Joanna Zajdel, joanna.zajdel@nokia.com
...    Maintainer:      Joanna Zajdel, joanna.zajdel@nokia.com

Library    testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Library    taf.transport.ssh                                                    WITH NAME    ssh
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning          WITH NAME   gnb_scf
Library    taf.rfrl.bts.devices.du.sw_update.GnbSwUpdate    WITH NAME    gnbswupdate
Library    taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME    duoperations
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    taf.rfrl.bts.devices.ru.ru_operations.GenericRuOperations    WITH NAME    ruoperations

*** Keywords ***
Trigger fault 4080
    ssh.connect to    hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...               alias=alias_smod
    Log To Console    SSH to SMOD udane
    ssh.execute        command=echo '#!/bin/bash' > /tmp/temp_script.sh    connection=alias_smod
    ssh.execute        command=echo 'TIMEOUT=$1' >> /tmp/temp_script.sh    connection=alias_smod
    ssh.execute        command=echo 'while [ $TIMEOUT -ne 0 ]; do' >> /tmp/temp_script.sh
    ...                connection=alias_smod
    ssh.execute    command=echo 'echo 255 > /dev/ddal/fan/0/pwm; echo 255 > /dev/ddal/fan/1/pwm' >> /tmp/temp_script.sh
    ...                connection=alias_smod
    ssh.execute        command=echo 'sleep 1; TIMEOUT=$((TIMEOUT-1)); done' >> /tmp/temp_script.sh
    ...                connection=alias_smod
    ssh.execute        command=chmod 775 /tmp/temp_script.sh   connection=alias_smod
    ssh.execute        command=/tmp/temp_script.sh 300   connection=alias_smod
    [Teardown]      ssh.disconnect     alias_smod


Load Config1 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_branch25R2_TC_1_pkt4.xml

Load Config0 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_T01PY135/SBTS00/GNB0_SCF.xml

Load Config2 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_branch25R2_TC_7_pkt5.xml

Load Config3 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_branch25R2_TC_7_pkt13_pkt23_4710.xml

Load Config4 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_branch25R2_TC_7_pkt21_4710.xml

Load Config5 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_branch25R2_TC_7_pkt25.xml

Load Config6 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_TC_8_pkt1_moc_branch25R2.xml

Load Config7 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_TC_8_pkt1_mocDN_branch25R2.xml

Load Config8 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_TC_8_pkt5_branch25R2.xml

Load Config9 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_TC_8_pkt7_branch25R2.xml

Load Config10 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/SBTS25R2/TL013_CB010788_TC_8_pkt9_branch25R2.xml

Load Config11 For BTS
    gnb_scf.perform_bts_full_commissioning
    ...    scf_file=commissionings/Krakow/7_7_TSPY013/${SW}/TL013_CB010788_trunk_TC7_pkt19.xml

SW upgrade2
    gnbswupdate.update_software
    ...    sw_package_dir=/home/ute/SBTS25R2_ENB_0000_000202_000000_release_BTSSM_downloadable_A54.zip    timeout=2000
