sfn_ant_group = []
possiable_cell_availability_status_macro = {"0": "degraded", "1": "failed"}
possiable_cell_operational_state_macro = {"0": "enabled", "1": "disabled"}
possiable_cell_status_asir = {"0": "yellow", "1": "red"}

cell_status_after_block_ant_macro = {"availabilityStatus": None,
                                     "operationalState": None,
                                     "blockingState": "Unblocked",
                                     "administrativeState": "Unlocked"}

avaibility_cell_status_macro = {"operationalState": "enabled",
                                "blockingState": "Unblocked",
                                "administrativeState": "Unlocked"}
avaibility_cell_status_asir = "green"
block_ant_status_asir = {"operationalState": "disabled", "localState": "blocked"}
unblock_ant_status_asir = {"operationalState": "enabled", "localState": "unblocked"}
block_ant_required_alarm_macro = "4479"
block_ant_required_alarm_asir = "4348"

allowed_faults_sbts = "61524 61648 61649 61652 4654 4655 4681 6261 6450"
