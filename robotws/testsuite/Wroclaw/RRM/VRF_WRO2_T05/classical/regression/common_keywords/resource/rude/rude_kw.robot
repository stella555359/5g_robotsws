*** Settings ***
Documentation  TWAMP metrics and capacity enhancements - Rude keywords

# Resource    ../Variables.robot
# Resource    ../../../../coam_common_resources/coam_connections.robot

Library     rude.py
Library     taf.transport.ssh    WITH NAME    ssh


*** Keywords ***
Connect to RUDE
    rude.connect_to

Disconnect RUDE
    rude.disconnect

Initialize RUDE
    [Arguments]  ${exec_path}=${RUDE_EXEC_PATH}  ${rude_engine_ip}=${RUDE_ENGINE_IP}
    rude.initialize  exec_path=${exec_path}    engine_ip=${rude_engine_ip}

Start rule on RUDE
    [Arguments]  ${sfp_pair}=1  ${port}=7777
    rude.start_rule  sfp_pair=${sfp_pair}  port=${port}

Reset rule on RUDE
    [Arguments]  ${sfp_pair}=1  ${port}=7777
    rude.reset_rule  sfp_pair=${sfp_pair}  port=${port}

Set delay on RUDE
    [Arguments]  ${rule}=1  ${port}=7777  ${sfp_pair}=1  ${delay_value}=1500  ${delay_ratio}=10
    rude.set_delay   rule=${rule}  port=${port}  sfp_pair=${sfp_pair}  delay_value=${delay_value}  delay_ratio=${delay_ratio}

Set drop on RUDE
    [Arguments]  ${direction}  ${rule}=1  ${port}=7777  ${sfp_pair}=1  ${drop_mode}=constant  ${drop_ratio}=10
    &{values}=  CREATE DICTIONARY
    ...         upstream=1
    ...         downstream=2
    rude.set_drop  rule=${rule}  port=${port}  sfp_pair=${sfp_pair}  drop_direction=${values["${direction}"]}
    ...            drop_mode=${drop_mode}  drop_ratio=${drop_ratio}

Set duplication on RUDE
    [Arguments]  ${direction}  ${rule}=1  ${port}=7777  ${sfp_pair}=1  ${duplication_mode}=constant  ${duplication_ratio}=10
    &{values}=  CREATE DICTIONARY
    ...         upstream=1
    ...         downstream=2
    rude.set_duplication  rule=${rule}  port=${port}  sfp_pair=${sfp_pair}  duplication_direction=${values["${direction}"]}
    ...                   duplication_mode=${duplication_mode}  duplication_ratio=${duplication_ratio}

Set reorder on RUDE
    [Arguments]  ${direction}  ${rule}=1  ${port}=7777  ${sfp_pair}=1
    ...          ${reorder_mode}=constant  ${reorder_ratio}=10  ${reorder_offset}=1
    &{values}=  CREATE DICTIONARY
    ...         upstream=1
    ...         downstream=2
    rude.set_reorder  rule=${rule}  port=${port}  sfp_pair=${sfp_pair}  reorder_direction=${values["${direction}"]}
    ...               reorder_mode=${reorder_mode}  reorder_ratio=${reorder_ratio}  reorder_offset=${reorder_offset}

Restart RUDE managing VM
    [Arguments]  ${VM_IP}=${RUDE_VM_IP}
    Connect to RUDE
    ssh.execute    command=shutdown /r /f
    Log  VM will turn off in a minute...  console=True
    Sleep  180  reason=Time to kill all process and restart
    Wait until keyword succeeds  5 min  10 sec  Ping IP  ${VM_IP}
    log to console  IP ${VM_IP} pingable. Restart RUDE VM done.
    [Teardown]  Disconnect RUDE
