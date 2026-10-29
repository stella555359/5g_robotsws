import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pa1_address = str(tl.attenuator[0].ip_addr)
_pa2_address = str(tl.attenuator[1].ip_addr)

_gnb1_cell1_pa_port = [int(tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[1].port_no),
                       int(tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[2].port_no),
                       int(tl.gnbs[0].dus[0].fhgws[0].rus[0].attenuation_ports[3].port_no)]
_gnb1_cell2_pa_port = [int(tl.gnbs[0].dus[0].fhgws[0].rus[1].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].fhgws[0].rus[1].attenuation_ports[1].port_no),
                       int(tl.gnbs[0].dus[0].fhgws[0].rus[1].attenuation_ports[2].port_no),
                       int(tl.gnbs[0].dus[0].fhgws[0].rus[1].attenuation_ports[3].port_no)]
_gnb1_cell3_pa_port = [int(tl.gnbs[0].dus[1].fhgws[0].rus[0].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[1].fhgws[0].rus[0].attenuation_ports[1].port_no),
                       int(tl.gnbs[0].dus[1].fhgws[0].rus[0].attenuation_ports[2].port_no),
                       int(tl.gnbs[0].dus[1].fhgws[0].rus[0].attenuation_ports[3].port_no)]
_gnb2_cell4_pa_port = [int(tl.gnbs[1].dus[0].fhgws[0].rus[0].attenuation_ports[0].port_no),
                       int(tl.gnbs[1].dus[0].fhgws[0].rus[0].attenuation_ports[1].port_no),
                       int(tl.gnbs[1].dus[0].fhgws[0].rus[0].attenuation_ports[2].port_no),
                       int(tl.gnbs[1].dus[0].fhgws[0].rus[0].attenuation_ports[3].port_no)]
_enb1_cell1_pa_port = [int(tl.gnbs[0].dus[0].fhgws[0].rus[2].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].fhgws[0].rus[2].attenuation_ports[1].port_no)]
_enb1_cell2_pa_port = [int(tl.gnbs[0].dus[0].fhgws[0].rus[3].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].fhgws[0].rus[3].attenuation_ports[1].port_no)]
_enb2_cell1_pa_port = [int(tl.gnbs[0].dus[0].fhgws[0].rus[4].attenuation_ports[0].port_no),
                       int(tl.gnbs[0].dus[0].fhgws[0].rus[4].attenuation_ports[1].port_no)]

gnb1_cell1_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell1_pa_port, 'step': [6, 6]}
gnb1_cell2_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell2_pa_port, 'step': [6, 6]}
gnb1_cell3_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb1_cell3_pa_port, 'step': [6, 6]}
gnb2_cell4_pa_info = {'pa_ip': _pa1_address, 'pa_ports': _gnb2_cell4_pa_port, 'step': [6, 6]}
enb1_cell1_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _enb1_cell1_pa_port, 'step': [6, 6]}
enb1_cell2_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _enb1_cell2_pa_port, 'step': [6, 6]}
enb2_cell1_pa_info = {'pa_ip': _pa2_address, 'pa_ports': _enb2_cell1_pa_port, 'step': [6, 6]}

all_cell_pa_name = [gnb1_cell1_pa_info, gnb1_cell2_pa_info, gnb1_cell3_pa_info, gnb2_cell4_pa_info,
                    enb1_cell1_pa_info, enb1_cell2_pa_info, enb2_cell1_pa_info]

gnb1_cell1_pa_value = {'setup': [[15] * 4, [20] * 4, [26] * 4, [10] * 4, [30] * 4, [32] * 4], 'initial': [0] * 4,
                       'recover': [0] * 4, 'min': [10] * 4, 'max': [127] * 4}
gnb1_cell2_pa_value = {'setup': [[15] * 4, [0] * 4, [30] * 4, [6] * 4, [30] * 4, [32] * 4], 'initial': [127] * 4,
                       'recover': [127] * 4, 'min': [10] * 4, 'max': [127] * 4}
gnb1_cell3_pa_value = {'setup': [[0] * 4, [0] * 4, [30] * 4, [6] * 4, [30] * 4, [32] * 4], 'initial': [127] * 4,
                       'recover': [127] * 4, 'min': [10] * 4, 'max': [127] * 4}
gnb2_cell4_pa_value = {'setup': [[12] * 4, [0] * 4, [30] * 4, [6] * 4, [30] * 4, [32] * 4], 'initial': [127] * 4,
                       'recover': [127] * 4, 'min': [10] * 4, 'max': [127] * 4}
enb1_cell1_pa_value = {'setup': [[20] * 2, [10] * 2, [45] * 2, [10] * 2, [30] * 2, [32] * 2], 'initial': [127] * 2,
                       'recover': [0] * 2, 'min': [15] * 2, 'max': [127] * 2}
enb1_cell2_pa_value = {'setup': [[10] * 2, [0] * 2, [30] * 2, [10] * 2, [30] * 2, [32] * 2], 'initial': [127] * 2,
                       'recover': [0] * 2, 'min': [10] * 2, 'max': [127] * 2}
enb2_cell1_pa_value = {'setup': [[10] * 2, [0] * 2, [30] * 2, [10] * 2, [30] * 2, [32] * 2], 'initial': [127] * 2,
                       'recover': [0] * 2, 'min': [10] * 2, 'max': [127] * 2}

all_cell_pa_initial_values = [gnb1_cell1_pa_value['initial'], gnb1_cell2_pa_value['initial'],
                              gnb1_cell3_pa_value['initial'], gnb2_cell4_pa_value['initial'],
                              enb1_cell1_pa_value['initial'], enb1_cell2_pa_value['initial'],
                              enb2_cell1_pa_value['initial']]

all_cell_pa_max_values = [gnb1_cell1_pa_value['max'], gnb1_cell2_pa_value['max'],
                          gnb1_cell3_pa_value['max'], gnb2_cell4_pa_value['max'],
                          enb1_cell1_pa_value['max'], enb1_cell2_pa_value['max'],
                          enb2_cell1_pa_value['max']]

gnb1_cell1_pa_value_8227 = [24, 24, 24, 24]
