CELL_502 = "GNB_1_CELL_502"
CELL_602 = "GNB_1_CELL_602"

snapshot_vCU_vDU1_vDU_2 = ['10.42.93.184', '10.42.38.208', '10.42.38.209']
vdu_ips = ['10.42.38.208', '10.42.38.209']

SOURCE_CELL = '502'
TARGET_CELL = '602'
CELL_PORTS = {
    '602': {
        'attenuator_id': 2,
        'ports': [9, 10, 11, 12],
    },
    '502': {
        'attenuator_id': 0,
        'ports': [9, 10, 11, 12]
    }
}
