import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pa1_address = str(tl.attenuator[0].ip_addr)

_gnb1_cell1_pa_port = [int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no)]
_gnb1_cell2_pa_port = [int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no)]
_gnb1_cell3_pa_port = [int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no),
                       int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no),
                       int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no)]
_gnb2_cell1_pa_port = [int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no),
                       int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no)]
_gnb2_cell2_pa_port = [int(tl.gnbs[1].dus[0].rus[1].attenuation_ports[0].port_no),
                       int(tl.gnbs[1].dus[0].rus[1].attenuation_ports[1].port_no)]
_enb1_cell1_pa_port = [int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no)]
_enb1_cell2_pa_port = [int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no)]
_enb2_cell1_pa_port = [int(tl.gnbs[1].dus[0].rus[2].attenuation_ports[0].port_no),
                       int(tl.gnbs[1].dus[0].rus[2].attenuation_ports[1].port_no)]

gnb1_cell1_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell1_pa_port, 'step': [6, 8]}
gnb1_cell2_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell2_pa_port, 'step': [6, 8]}
gnb1_cell3_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell3_pa_port, 'step': [6, 8]}
gnb2_cell1_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb2_cell1_pa_port, 'step': [6, 8]}
gnb2_cell2_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb2_cell2_pa_port, 'step': [6, 8]}
enb1_cell1_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _enb1_cell1_pa_port, 'step': [6, 8]}
enb1_cell2_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _enb1_cell2_pa_port, 'step': [6, 8]}
enb2_cell1_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _enb2_cell1_pa_port, 'step': [6, 8]}

all_cell_pa_name = [gnb1_cell1_pa_info, gnb1_cell2_pa_info, gnb1_cell3_pa_info, gnb2_cell1_pa_info, gnb2_cell2_pa_info,
                    enb1_cell1_pa_info, enb1_cell2_pa_info, enb2_cell1_pa_info]

gnb1_cell1_pa_value = {'setup': [[0]*2, [9]*2, [26]*2, [10]*2, [30]*2, [32]*2], 'initial': [0]*2,
                       'recover': [0]*2, 'min': [0]*2, 'max': [127]*2}
gnb1_cell2_pa_value = {'setup': [[0]*2, [9]*2, [26]*2, [10]*2, [30]*2, [32]*2], 'initial': [127]*2,
                       'recover': [0]*2, 'min': [0]*2, 'max': [127]*2}
gnb1_cell3_pa_value = {'setup': [[0]*4, [9]*4, [26]*4, [10]*4, [30]*4, [32]*4], 'initial': [127]*4,
                       'recover': [0]*4, 'min': [0]*4, 'max': [127]*4}
gnb2_cell1_pa_value = {'setup': [[0]*2, [20]*2, [12]*2, [6]*2, [30]*2, [127, 35], [127, 0], [0, 127], [30, 127]],
                       'initial': [127]*2, 'recover': [127]*2, 'min': [0]*2, 'max': [127]*2}
gnb2_cell2_pa_value = {'setup': [[0]*2, [5]*2, [45]*2, [6]*2, [30]*2, [32]*2, [20, 127], [127, 15], [127, 50]],
                       'initial': [127]*2, 'recover': [127]*2, 'min': [0]*2, 'max': [127]*2}
enb1_cell1_pa_value = {'setup': [[0]*2, [8]*2, [26]*2, [6]*2, [30]*2, [32]*2], 'initial': [127]*2,
                       'recover': [127]*2, 'min': [0]*2, 'max': [127]*2}
enb1_cell2_pa_value = {'setup': [[0]*2, [20]*2, [30]*2, [6]*2, [30]*2, [32]*2], 'initial': [127]*2,
                       'recover': [127]*2, 'min': [0]*2, 'max': [127]*2}
enb2_cell1_pa_value = {'setup': [[0]*2, [16]*2, [30]*2, [6]*2, [30]*2, [32]*2], 'initial': [127]*2,
                       'recover': [127]*2, 'min': [0]*2, 'max': [127]*2}

all_cell_pa_initial_values = [gnb1_cell1_pa_value['initial'], gnb1_cell2_pa_value['initial'],
                              gnb1_cell3_pa_value['initial'],
                              gnb2_cell1_pa_value['initial'], gnb2_cell2_pa_value['initial'],
                              enb1_cell1_pa_value['initial'], enb1_cell2_pa_value['initial'],
                              enb2_cell1_pa_value['initial']]

all_cell_pa_max_values = [gnb1_cell1_pa_value['max'], gnb1_cell2_pa_value['max'],
                          gnb1_cell3_pa_value['max'],
                          gnb2_cell1_pa_value['max'], gnb2_cell2_pa_value['max'],
                          enb1_cell1_pa_value['max'], enb1_cell2_pa_value['max'],
                          enb2_cell1_pa_value['max']]
