*** Settings ***
Library         taf.sbts.oam.coam.admin   WITH NAME    enb_snap

*** Variables ***
${enb_ip}    192.168.255.129
${target_file_name}    /home/cus/logs/enb_gui_snapshot.zip

*** Test Cases ***
Capture ENB GUI Snapshot
    enb_snap.teardown_all_aliases_for_admin
    enb_snap.setup_admin  bts_host=${enb_ip}
    enb_snap.collect_snapshot    target_file_name=${target_file_name}
    enb_snap.teardown_all_aliases_for_admin
