import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pa1_address = str(tl.attenuator[0].ip_addr)
_pa2_address = str(tl.attenuator[1].ip_addr)

__maintainer__ = 'Jack Zeng'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jack.zeng@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-' + _gnb_id
_MRBTSname2 = 'MRBTS-' + _gnb_id2
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb_id2

_XNLINK1_gnb1 = _NRBTSname + '/XNLINK-1'

_XNLINK1_gnb2 = _NRBTSname2 + '/XNLINK-1'

_NRADJGNB_gnb1 = _NRBTSname + '/NRADJGNB-1'
_NRADJGNB_gnb2 = _NRBTSname2 + '/NRADJGNB-1'
_NRADJNRCELL_gnb1 = _NRBTSname + '/NRADJNRCELL-12288'
_NRADJNRCELL1_gnb2 = _NRBTSname2 + '/NRADJNRCELL-12287'
_NRADJNRCELL2_gnb2 = _NRBTSname2 + '/NRADJNRCELL-12288'

_NRREL1_gnb1 = _NRBTSname + '/NRCELL-1/NRREL-256'
_NRREL2_gnb1 = _NRBTSname + '/NRCELL-301/NRREL-255'

_NRREL1_gnb2 = _NRBTSname2 + '/NRCELL-401/NRREL-255'
_NRREL2_gnb2 = _NRBTSname2 + '/NRCELL-401/NRREL-256'

_NRDLMUMIMO_1 = _NRBTSname + '/NRCELL-301/NRDLMUMIMO-1'
_NRDLMUMIMO_2 = _NRBTSname + '/NRCELL-302/NRDLMUMIMO-1'
_NRDLMUMIMO_3 = _NRBTSname + '/NRCELL-303/NRDLMUMIMO-1'
_NRDLMUMIMO_4 = _NRBTSname + '/NRCELL-311/NRDLMUMIMO-1'
_NRDLMUMIMO_5 = _NRBTSname + '/NRCELL-312/NRDLMUMIMO-1'
_NRDLMUMIMO_6 = _NRBTSname + '/NRCELL-313/NRDLMUMIMO-1'


ObjectToDelete_gnb1 = [
    dict(dist_name=_XNLINK1_gnb1),
    dict(dist_name=_NRADJGNB_gnb1),
    dict(dist_name=_NRREL1_gnb1),
    dict(dist_name=_NRREL2_gnb1),
    dict(dist_name=_NRADJNRCELL_gnb1)
]

ObjectToDelete_gnb2 = [
    dict(dist_name=_NRREL2_gnb2),
    dict(dist_name=_NRREL1_gnb2),
    dict(dist_name=_NRADJNRCELL1_gnb2),
    dict(dist_name=_NRADJNRCELL2_gnb2)
]

PARAMToModify_gnb1_NRDLMUMIMO = [
    dict(value='1', dist_name=_NRDLMUMIMO_1, parameter='dlMuMimoSpectralEffThd'),
    dict(value='1', dist_name=_NRDLMUMIMO_2, parameter='dlMuMimoSpectralEffThd'),
    dict(value='1', dist_name=_NRDLMUMIMO_3, parameter='dlMuMimoSpectralEffThd'),
    dict(value='1', dist_name=_NRDLMUMIMO_4, parameter='dlMuMimoSpectralEffThd'),
    dict(value='1', dist_name=_NRDLMUMIMO_5, parameter='dlMuMimoSpectralEffThd'),
    dict(value='1', dist_name=_NRDLMUMIMO_6, parameter='dlMuMimoSpectralEffThd')
]

PARAMToModify_gnb1 = [
    dict(value='XnHoNotAllowed', dist_name=_NRREL1_gnb1, parameter='handoverAllowedSA')
]

PARAMToModify_gnb2 = [
    dict(value='XnHoNotAllowed', dist_name=_NRREL1_gnb2, parameter='handoverAllowedSA')
]

_gnb1_cell1_pa_port = [int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no),
                       int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no),
                       int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no)]
_gnb1_cell2_pa_port = [int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no),
                       int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no),
                       int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no)]
# _gnb1_cell3_pa_port = [int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no),
#                        int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no),
#                        int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no),
#                        int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no)]
_gnb1_cell301_pa_port = [int(tl.gnbs[0].dus[0].rus[6].attenuation_ports[0].port_no),
                         int(tl.gnbs[0].dus[0].rus[6].attenuation_ports[1].port_no),
                         int(tl.gnbs[0].dus[0].rus[6].attenuation_ports[2].port_no),
                         int(tl.gnbs[0].dus[0].rus[6].attenuation_ports[3].port_no)]
_gnb2_cell401_pa_port = [int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no),
                         int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no),
                         int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no),
                         int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no)]
_gnb1_cell23_pa_port = [int(tl.gnbs[0].dus[0].rus[5].attenuation_ports[0].port_no),
                        int(tl.gnbs[0].dus[0].rus[5].attenuation_ports[1].port_no),
                        int(tl.gnbs[0].dus[0].rus[5].attenuation_ports[2].port_no),
                        int(tl.gnbs[0].dus[0].rus[5].attenuation_ports[3].port_no)]
# _gnb2_cell441_pa_port = [int(tl.gnbs[1].dus[0].rus[1].attenuation_ports[0].port_no),
#                          int(tl.gnbs[1].dus[0].rus[1].attenuation_ports[1].port_no)]
_enb1_cell11_pa_port = [int(tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no),
                        int(tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no)]
# _enb1_cell222_pa_port = [int(tl.gnbs[0].dus[0].rus[4].attenuation_ports[0].port_no),
#                          int(tl.gnbs[0].dus[0].rus[4].attenuation_ports[1].port_no)]
# _enb2_cell24_pa_port = [int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no),
#                         int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no)]

gnb1_cell1_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell1_pa_port, 'step': [6, 8]}
gnb1_cell2_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell2_pa_port, 'step': [6, 8]}
# gnb1_cell3_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell3_pa_port, 'step': [6, 8]}
gnb1_cell301_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _gnb1_cell301_pa_port, 'step': [8, 10]}
gnb2_cell401_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _gnb2_cell401_pa_port, 'step': [8, 10]}
gnb1_cell23_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _gnb1_cell23_pa_port, 'step': [6, 8]}
# gnb2_cell441_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _gnb2_cell441_pa_port, 'step': [6, 6]}
enb1_cell11_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _enb1_cell11_pa_port, 'step': [6, 8]}
# enb1_cell222_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _enb1_cell222_pa_port, 'step': [6, 8]}
# enb2_cell24_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _enb2_cell24_pa_port, 'step': [6, 8]}

all_cell_pa_name = [gnb1_cell1_pa_info, gnb1_cell2_pa_info, gnb1_cell301_pa_info,
                    gnb2_cell401_pa_info, gnb1_cell23_pa_info, enb1_cell11_pa_info]

gnb1_cell1_pa_value = {'setup': [[30] * 4, [20] * 4, [10] * 4, [0] * 4, [37] * 4, [42] * 4, [18] * 4],
                       'initial': [0] * 4, 'recover': [0] * 4, 'min': [0] * 4, 'max': [127] * 4}
gnb1_cell2_pa_value = {'setup': [[15] * 4, [4] * 4, [28] * 4, [6] * 4, [30] * 4, [32] * 4], 'initial': [127] * 4,
                       'recover': [127] * 4, 'min': [0] * 4, 'max': [127] * 4}
# gnb1_cell3_pa_value = {'setup': [[15] * 4, [4] * 4, [34] * 4, [6] * 4, [30] * 4, [32] * 4],
#                        'initial': [127] * 4, 'recover': [127] * 4, 'min': [0] * 4, 'max': [127] * 4}
gnb1_cell301_pa_value = {'setup': [[28] * 4, [4] * 4, [45] * 4, [6] * 4, [48] * 4, [127] * 4], 'initial': [127] * 4,
                         'recover': [127] * 4, 'min': [0] * 4, 'max': [127] * 4}
gnb2_cell401_pa_value = {'setup': [[0] * 4, [0] * 4, [46] * 4, [6] * 4, [42] * 4, [38] * 4], 'initial': [127] * 4,
                         'recover': [127] * 4, 'min': [0] * 4, 'max': [127] * 4}
gnb1_cell23_pa_value = {'setup': [[25] * 4, [0] * 4, [36] * 4, [6] * 4, [30] * 4, [32] * 4], 'initial': [127] * 4,
                        'recover': [127] * 4, 'min': [0] * 4, 'max': [127] * 4}
# gnb2_cell441_pa_value = {'setup': [[0] * 2, [0] * 2, [36] * 2, [6] * 2, [36] * 2, [0] * 2, [36] * 2, [20] * 2],
#                          'initial': [127] * 2,
#                          'recover': [127] * 2, 'min': [0] * 2, 'max': [127] * 2}
enb1_cell11_pa_value = {'setup': [[5] * 2, [15] * 2, [26] * 2, [10] * 2, [30] * 2, [32] * 2], 'initial': [127] * 2,
                        'recover': [127] * 2, 'min': [0] * 2, 'max': [127] * 2}
# enb1_cell222_pa_value = {'setup': [[16] * 2, [0] * 2, [30] * 2, [6] * 2, [30] * 2, [32] * 2], 'initial': [127] * 2,
#                          'recover': [127] * 2, 'min': [0] * 2, 'max': [127] * 2}
# enb2_cell24_pa_value = {'setup': [[16] * 2, [10] * 2, [40] * 2, [6] * 2, [30] * 2, [32] * 2], 'initial': [127] * 2,
#                         'recover': [127] * 2, 'min': [0] * 2, 'max': [127] * 2}

all_cell_pa_initial_values = [gnb1_cell1_pa_value['initial'], gnb1_cell2_pa_value['initial'],
                              gnb1_cell301_pa_value['initial'], gnb2_cell401_pa_value['initial'],
                              gnb1_cell23_pa_value['initial'], enb1_cell11_pa_value['initial']]

all_cell_pa_max_values = [gnb1_cell1_pa_value['max'], gnb1_cell2_pa_value['max'],
                          gnb1_cell301_pa_value['max'], gnb2_cell401_pa_value['max'],
                          gnb1_cell23_pa_value['max'],  enb1_cell11_pa_value['max']]
