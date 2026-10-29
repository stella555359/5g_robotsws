import socket
from dataclasses import dataclass
from taf.rfrl.utilities.robot.general import get_builtin_value

_tl = get_builtin_value(param_name="tl")
_btsid = _tl.gnbs[0].instance_id


@dataclass
class Counter:
    id: str
    label: str
    localmoid: str


samples_cell_avail_counter = Counter(
    id='M55601C00002',
    label='SAMPLES_CELL_AVAIL',
    localmoid=f'PLMN-PLMN/MRBTS-{_btsid}/NRBTS-{_btsid}/NRCELL-1'
)

samples_cell_planned_unavail_counter = Counter(
    id='M55601C01001',
    label='NR_CELL_PLAN_UNAVAIL_SAMPLES',
    localmoid=f'PLMN-PLMN/MRBTS-{_btsid}/NRBTS-{_btsid}/NRCELL-1'
)

energy_consumption_in_radio_modules_counter = Counter(
    id='M40002C1',
    label='ENERGY_CONSUMPTION_IN_RF',
    localmoid=f'PLMN-PLMN/MRBTS-{_btsid}'
)

energy_consumption_in_sbts_counter = Counter(
    id='M40002C2',
    label='ENERGY_CONSUMPTION_IN_BTS',
    localmoid=f'PLMN-PLMN/MRBTS-{_btsid}'
)

energy_consumption_in_single_radio_counter = Counter(
    id='M40003C2',
    label='RU_ENERGY_CONSUMPTION',
    localmoid=f'PLMN-PLMN/MRBTS-{_btsid}/EQM-1/APEQM-1/RMOD-1'
)

vm_hostname = socket.gethostname().upper()
