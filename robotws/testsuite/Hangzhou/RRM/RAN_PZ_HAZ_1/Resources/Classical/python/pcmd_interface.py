# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Xiang Liang
:contact: liang.xiang@nokia-sbell.com
"""
from pcmd.rrm_pcmd import rrm_pcmd
from pcmd.lcbin_analyzer import lcbin_analyzer
from pcmd.SHBDecoder import SHBDecoder
try:
    import robot.api.logger as logging
except ImportError:
    import logging


class pcmd_interface(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        self.analyzer = None
        self._pcmd = rrm_pcmd()
        self._shb = SHBDecoder()

    def shb_download_file(self, file_path, save_path):
        return self._shb.download_file(file_path, save_path)

    def shb_find_file(self, start_path, target_folder="runtime_shb", file_pattern="cp-rt-ue-shb-thread-1.shb5.txt"):
        return self._shb.find_file(start_path, target_folder, file_pattern)

    def shb_get_time(self, filepath, search_string):
        return self._shb.get_time(filepath, search_string)

    def make_ue_bearer(self, UE_IMSI, ue_ip, QCI, QCI_server, bear_action, bear_ip='10.56.221.181'):
        """ make the dedicate QCI use the ssh command
        # server ./10_10_20_2sbear -i 460022000012627 -a 172.206.255.239 -q 5 -d 21000000 -u 10000000 -s 10.85.0.5
        # server IP 10.85.0.5 --QCI5
        """
        self._pcmd.make_ue_bearer(UE_IMSI, ue_ip, QCI, QCI_server, bear_action, bear_ip='10.56.221.181')

    def check_pcmd_record_from_mni(self, filepath, input_pcmd_array):
        """
        | Input Parameters | Man. | Description |
        | ${filepath} | no  | log path to check pcdm log, if not provided, use ${TEST_LOG_DIRECTORY}  |
        | ${input_pcmd_array}  | yes  |  pcmd fields to be checked |

        | Return Value | Description |
        | ${check_result} | True when keyword execution succeed |

        Example
        |  Example of all arguments provided:  |    |
        |  Check Pcmd Record from MNI  |  ${filepath}=${TEST_LOG_DIRECTORY}  |
        |  ...                        |  ${input_pcmd_array}=time  |
        """
        return self._pcmd.check_pcmd_record(filepath, input_pcmd_array)

    def save_pcmd_log_from_mni(self, gummei, local_log_dir, t_detach, cell_id, record_type, **kwargs):
        """
        | Input Parameters | Man. | Description |
        | local_log_dir | yes  | log path to save pcdm log, if not provided, use ${TEST_LOG_DIRECTORY}  |
        | t_detach}     | yes  | system time of ue detach |
        | cell_id       | yes  | target cell id for pcmd record |
        | record_type   | yes  | 1:normal record   2:abnormal record |
        | check_filter  | yes  |  pcmd fields to filter pcmd record |

        | Return Value | Description |
        | None | NA |

        Example
        |  Example of all arguments provided:  |    |
        |  Save Pcmd Log from MNI  |  ${local_log_dir}=${TEST_LOG_DIRECTORY}  |
        |  ...                        |  ${t_detach}=time  |
        |  ...                        |  ${cell_id}=1233409   |
        |  ...                        |  ${record_type}=1 |
        |  ...                        |  &{check_filter}=&{check_filter}  |
        """
        self._pcmd.save_pcmd_log(gummei, local_log_dir, t_detach, cell_id, record_type, **kwargs)

    def get_sys_time(self):
        """ Get the current system time
            Format time:'%Y-%m-%d %H:%M'
        """
        return self._pcmd.get_sys_time()

    def get_plmn_from_lcbin(self, path, VendorExtension, target_RecordDataType, activation_type, target_crnti):
        """
        | Input Parameters | Man. | Description |
        | path                  | yes  | log path to pass  |
        | VendorExtension       | yes  | VendorExtension type |
        | target_RecordDataType | yes  | target_RecordDataType value |
        | activation_type       | yes  | activation_type   mba |
        | target_crnti          | yes  | crnti |

        | Return Value | Description |
        | PLMN | Plmn id |

        Example
        |  Example of all arguments provided:  |    |
        |  Get PLMN From lcbin        |  gNodeB001.lcbin.ascii  |
        |  ...                        |  CuVendorExtensionRecordDataType  |
        |  ...                        |  ueDuConnectivityRecord   |
        |  ...                        |  mba |
        |  ...                        |  32434  |
        """
        self.analyzer = lcbin_analyzer(path)
        plmn_id = self.analyzer.get_plmn(VendorExtension, target_RecordDataType, activation_type, target_crnti)
        return plmn_id
