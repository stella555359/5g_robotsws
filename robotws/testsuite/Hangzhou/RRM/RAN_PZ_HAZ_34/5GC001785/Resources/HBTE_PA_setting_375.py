import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pa1_address = str(tl.attenuator[0].ip_addr)
_pa2_address = str(tl.attenuator[1].ip_addr)

_gnb1_cell1_pa_port = [int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no),
                       int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no),
                       int(tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no)]
_gnb1_cell2_pa_port = [int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no),
                       int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no),
                       int(tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no)]
_gnb1_cell21_pa_port = [int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no),
                        int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no),
                        int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[2].port_no),
                        int(tl.gnbs[0].dus[0].rus[2].attenuation_ports[3].port_no)]
_gnb1_cell23_pa_port = [int(tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no),
                        int(tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no),
                        int(tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no),
                        int(tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no)]
_gnb1_cell301_pa_port = [int(tl.gnbs[0].dus[0].rus[6].attenuation_ports[0].port_no),
                         int(tl.gnbs[0].dus[0].rus[6].attenuation_ports[1].port_no),
                         int(tl.gnbs[0].dus[0].rus[6].attenuation_ports[2].port_no),
                         int(tl.gnbs[0].dus[0].rus[6].attenuation_ports[3].port_no)]
_gnb1_cell302_pa_port = [int(tl.gnbs[0].dus[0].rus[7].attenuation_ports[0].port_no),
                         int(tl.gnbs[0].dus[0].rus[7].attenuation_ports[1].port_no),
                         int(tl.gnbs[0].dus[0].rus[7].attenuation_ports[2].port_no),
                         int(tl.gnbs[0].dus[0].rus[7].attenuation_ports[3].port_no)]
_gnb2_cell11_pa_port = [int(tl.gnbs[0].dus[0].rus[8].attenuation_ports[0].port_no),
                        int(tl.gnbs[0].dus[0].rus[8].attenuation_ports[1].port_no),
                        int(tl.gnbs[0].dus[0].rus[8].attenuation_ports[2].port_no),
                        int(tl.gnbs[0].dus[0].rus[8].attenuation_ports[3].port_no)]
_gnb2_cell401_pa_port = [int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no),
                         int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no),
                         int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no),
                         int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no)]
# _enb2_cell24_pa_port = [int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no),
#                         int(tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no)]

gnb1_cell1_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell1_pa_port, 'step': [6, 6]}
gnb1_cell2_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell2_pa_port, 'step': [6, 6]}
gnb1_cell21_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell21_pa_port, 'step': [6, 6]}
gnb1_cell23_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell23_pa_port, 'step': [6, 6]}
gnb1_cell301_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _gnb1_cell301_pa_port, 'step': [6, 6]}
gnb1_cell302_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _gnb1_cell302_pa_port, 'step': [6, 6]}
gnb2_cell11_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _gnb2_cell11_pa_port, 'step': [6, 6]}
gnb2_cell401_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _gnb2_cell401_pa_port, 'step': [6, 6]}
# enb2_cell24_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _enb2_cell24_pa_port, 'step': [6, 6]}

all_cell_pa_name = [gnb1_cell1_pa_info, gnb1_cell2_pa_info, gnb1_cell21_pa_info, gnb1_cell23_pa_info,
                    gnb1_cell301_pa_info, gnb1_cell302_pa_info, gnb2_cell11_pa_info, gnb2_cell401_pa_info]

gnb1_cell1_pa_value = {'setup': [[20]*4, [1]*4, [34]*4, [1]*4, [34]*4, [35]*4],
                       'initial': [1]*4, 'recover': [0]*4, 'min': [0]*4, 'max': [127]*4}
gnb1_cell2_pa_value = {'setup': [[30]*4, [4]*4, [40]*4, [0]*4, [36]*4, [32]*4], 'initial': [127]*4,
                       'recover': [127]*4, 'min': [0]*4, 'max': [127]*4}
gnb1_cell21_pa_value = {'setup': [[20]*4, [1]*4, [34]*4, [6]*4, [30]*4, [18]*4],
                        'initial': [0]*4, 'recover': [0]*4, 'min': [0]*4, 'max': [127]*4}
gnb1_cell23_pa_value = {'setup': [[25]*4, [0]*4, [30]*4, [0]*4, [24]*4, [32]*4], 'initial': [127]*4,
                        'recover': [127]*4, 'min': [0]*4, 'max': [127]*4}
gnb1_cell301_pa_value = {'setup': [[35]*4, [6]*4, [42]*4, [6]*4, [42]*4, [45]*4], 'initial': [25]*4,
                         'recover': [127]*4, 'min': [0]*4, 'max': [127]*4}
gnb1_cell302_pa_value = {'setup': [[35]*4, [17]*4, [53]*4, [17]*4, [53]*4, [32]*4], 'initial': [127]*4,
                         'recover': [127]*4, 'min': [0]*4, 'max': [127]*4}
gnb2_cell11_pa_value = {'setup': [[5]*4, [13]*4, [42]*4, [6]*4, [42]*4, [32]*4], 'initial': [127]*4,
                        'recover': [127]*4, 'min': [0]*4, 'max': [127]*4}
gnb2_cell401_pa_value = {'setup': [[25]*4, [0]*4, [42]*4, [6]*4, [30]*4, [32]*4], 'initial': [127]*4,
                         'recover': [127]*4, 'min': [0]*4, 'max': [127]*4}
# enb2_cell24_pa_value = {'setup': [[15]*2, [10]*2, [40]*2, [6]*2, [30]*2, [32]*2], 'initial': [127]*2,
#                         'recover': [127]*2, 'min': [0]*2, 'max': [127]*2}

all_cell_pa_initial_values = [gnb1_cell1_pa_value['initial'], gnb1_cell2_pa_value['initial'],
                              gnb1_cell21_pa_value['initial'], gnb1_cell23_pa_value['initial'],
                              gnb1_cell301_pa_value['initial'], gnb1_cell302_pa_value['initial'],
                              gnb2_cell11_pa_value['initial'], gnb2_cell401_pa_value['initial']]

all_cell_pa_max_values = [gnb1_cell1_pa_value['max'], gnb1_cell2_pa_value['max'],
                          gnb1_cell21_pa_value['max'], gnb1_cell23_pa_value['max'],
                          gnb1_cell301_pa_value['max'], gnb1_cell302_pa_value['max'],
                          gnb2_cell11_pa_value['max'], gnb2_cell401_pa_value['max']]
