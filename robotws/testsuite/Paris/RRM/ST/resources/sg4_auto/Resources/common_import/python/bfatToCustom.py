# ##########################################################################################
#
#    7_20_CLOUD5GPSIV258  -  IV_PS_258  -  CV258
#
#    2023-10-09
#
# ##########################################################################################

__maintainer__ = "MN 5G&SC Pz 5G I&V 1 NPS 4 SG"
__team__ = "MN 5G&SC Pz 5G I&V 1 NPS 4 SG"
__email__ = "alberto.fernandez_vila@nokia.com"

import os
from robot.libraries.BuiltIn import BuiltIn

custom = {
  'TL_Number': BuiltIn().get_variable_value("${system_under_test.custom.1.TL_number}"),
  'GNB_Friendly_TL_Name': BuiltIn().get_variable_value("${system_under_test.custom.1.GNB_Friendly_TL_Name}"),
  'GNB_Architecture': BuiltIn().get_variable_value("${system_under_test.custom.1.GNB_Architecture}"),
  'UE_Architecture': BuiltIn().get_variable_value("${system_under_test.custom.1.UE_Architecture}"),
  'GNB_nr_bts': BuiltIn().get_variable_value("${system_under_test.custom.1.GNB_nr_bts}"),
  'MRBTS': BuiltIn().get_variable_value("${system_under_test.custom.1.MRBTS}"),
  'GNB_First_CellID': BuiltIn().get_variable_value("${system_under_test.custom.1.GNB_First_CellID}"),
  'GNB_First_Cell_nrArfcn': BuiltIn().get_variable_value("${system_under_test.custom.1.GNB_First_Cell_nrArfcn}"),
  'Cell_list': [
    {
      'CellID': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.1.CellID}"),
      'nrArfcn': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.1.nrArfcn}")
    },
    {
      'CellID': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.2.CellID}"),
      'nrArfcn': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.2.nrArfcn}")
    },
    {
      'CellID': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.3.CellID}"),
      'nrArfcn': BuiltIn().get_variable_value("${system_under_test.custom.1.custom_cell.3.nrArfcn}")
    }
  ],
  'yaml_prisma_filename_path': BuiltIn().get_variable_value("${system_under_test.custom.1.yaml_prisma_filename_path}"),
  'yaml_prisma_filename': BuiltIn().get_variable_value("${system_under_test.custom.1.yaml_prisma_filename}"),
  'prisma_S1_present': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_S1_present}"),
  'prisma_UU_create_5G_cell': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_UU_create_5G_cell}"),
  'prisma_ppu_cell_5G': [
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_prisma_ppu_cell_5g.1.ppu}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_prisma_ppu_cell_5g.2.ppu}")
  ],
  'prisma_ppu_rach': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_ppu_rach}"),
  'Ul_gain': int(BuiltIn().get_variable_value("${system_under_test.custom.1.Ul_gain}")),
  'Dl_gain': int(BuiltIn().get_variable_value("${system_under_test.custom.1.Dl_gain}")),
  'prisma_tstm_X2_present': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_tstm_X2_present}"),
  'prisma_UU_start_script': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_UU_start_script}"),
  'prisma_cli_path': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_cli_path}"),
  'airmosaic_cfg_path': BuiltIn().get_variable_value("${system_under_test.custom.1.airmosaic_cfg_path}"),
  'sid_filename': BuiltIn().get_variable_value("${system_under_test.custom.1.sid_filename}"),
  'prisma_enable_amm': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_enable_amm}"),
  'prisma_clock_timer': BuiltIn().get_variable_value("${system_under_test.custom.1.prisma_clock_timer}"),
  'iPerf_VM_DL_ipaddress': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_DL_ipaddress}"),
  'iPerf_VM_DL_login': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_DL_login}"),
  'iPerf_VM_DL_passwd': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_DL_passwd}"),
  'iPerf_VM_DL_Network_Interface_Address': BuiltIn().get_variable_value(
    "${system_under_test.custom.1.iPerf_VM_DL_Network_Interface_Address}"),
  'iPerf_VM_DL_Port': [
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.1.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.2.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.3.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.4.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.5.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.6.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.7.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.8.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.9.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.10.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.11.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.12.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.13.port}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_dl_port.14.port}")
  ],
  'iPerf_VM_UL_ipaddress': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_UL_ipaddress}"),
  'iPerf_VM_UL_login': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_UL_login}"),
  'iPerf_VM_UL_passwd': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_UL_passwd}"),
  'iPerf_VM_UL_Network_Interface_Address': [
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.1.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.2.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.3.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.4.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.5.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.6.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.7.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.8.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.9.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.10.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.11.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.12.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.13.ip}"),
    BuiltIn().get_variable_value("${system_under_test.custom.1.custom_iperf_vm_ul_network_interface_address.14.ip}")
    ],
  'iPerf_VM_UL_Port': BuiltIn().get_variable_value("${system_under_test.custom.1.iPerf_VM_UL_Port}")
}

__all__ = ["custom"]
