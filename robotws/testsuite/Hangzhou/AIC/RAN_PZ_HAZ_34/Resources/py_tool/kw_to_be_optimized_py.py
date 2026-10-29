import time
import uuid
from taf.hw.fhgw.cli import cli
from pprint import pprint
from robot.libraries.BuiltIn import BuiltIn
import os.path
from utils import yaml_file_to_dictionary

try:
    from cStringIO import StringIO
except ImportError:
    try:
        from StringIO import StringIO
    except ImportError:
        from io import StringIO

"""
__all__ = [
    "dummy110",
    "get_unique_id",
    "fast_connect_to_k8s_master",
    "fast_disconnect",
    "fast_disconnect_all",
    "fast_execute",
    "get_vdu_namespace_from_testline",
    "get_k8s_admin_ssh_connection_info",
    "get_vdu_oam_http_connection_info",
    "get_vcu_oam_http_connection_info",
    "get_vcu_k8s_admin_ssh_connection_info",
    "get_cu_namespace_from_testline",
    "fast_connect_to_cu_k8s_master_with_admin",
    "fast_execute_cu",
    "get_fhgw_extra_config_yaml_from_testLine",
    "get_fhgw_extra_config_dictionary_from_testLine",
    "get_fhgw_major_version",
    "strip_prompt"
]
"""

__all__ = [
    "dummy110"
]

# issh_cli = cli()


def dummy110():
    print("dummy110")
    return None
