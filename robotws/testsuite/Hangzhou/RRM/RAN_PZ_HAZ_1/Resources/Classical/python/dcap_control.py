# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: winnie.he
:contact: winnie.he@nokia-sbell.com
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
pls input like:
Library             ../Resources/device_connection/DCAP/dcap_control.py
Library             dcap_control.dcap_control    WITH NAME    dcap
"""

import sys
from DCAP import BTSDcap
try:
    import robot.api.logger as logging
except ImportError:
    import logging
from taf.internal.aliasing import aliasing_scope
from functools import wraps
from robot.api import logger
from robot.libraries import BuiltIn
import os
import time


class dcap_control(object):
    """
    This library will provide keywords to capture logs by dcap

    *Usage:*

    -   *Import the library*
    | Library    ../Resources/python/DCAP/dcap_control.py |
    | Library    dcap_control.dcap_control    WITH NAME    dcap |

    -   *Example for Capture Bip Log:*
    | `Prepare Gnb Tool` |
    | `dcap.Connect To` | bts_s1_ip=10.108.151.44 | mrBtsId=${5671} | bts_type=lte |
    |                   | url_ip=10.109.2.184 | alias=dcap_test |
    | `dcap.Get Trace Profile Id List` | connection=dcap_test |
    | `dcap.Start Trace` | trace_profile=${trace_profile[0]} | tag=robot_test | connection=dcap_test |
    |                    | url_ip=10.109.2.184 | alias=dcap_test |
    | Sleep | 30 |
    | `dcap.Stop Trace` | connection=dcap_test |
    | `dcap.Get Result File` | target_dir=${TEST_LOG_DIRECTORY} | file_name=dcap_log.zip | connection=dcap_test |
    | dcap.Unzip Result File Return Paths | zipfilepath=${TEST_LOG_DIRECTORY}/dcap_log.zip | connection=dcap_test |
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    lookup_handler, store = aliasing_scope(lookup_arg='connection',
                                           lookup_type=BTSDcap)

    def __init__(self):
        self.lookup_handler.store = self.store

    def _extract_connection_from_alias(func):
        """ 4G uses alias parameter not connection """

        @wraps(func)
        def wrapper(self, *args, **kwargs):
            if "alias" in dict(kwargs):
                kwargs["connection"] = kwargs["alias"]
                kwargs.pop("alias")
            else:
                for index, arg in enumerate(list(args)):
                    if arg in [item[0] for item in self.store.all]:
                        kwargs["connection"] = arg
                        args.pop(index)

            return func(self, *args, **kwargs)

        return wrapper

    def connect_to(self,
                   bts_s1_ip,
                   mrBtsId,
                   bts_type,
                   url_ip,
                   port=BTSDcap.DCAP_SERVER_DEFAULT.port,
                   username=BTSDcap.DCAP_SERVER_DEFAULT.username,
                   password=BTSDcap.DCAP_SERVER_DEFAULT.password,
                   alias="default"):
        """
        Provides connection to DCAP-LITE.
        | Input Parameters | Man. | Description |
        | bts_s1_ip | Yes | IP address to BTS S1 |
        | mrBtsId | Yes | bts id like BTS345, mrBtsId=345 |
        | bts_type | Yes | bts type, lte or 5g |
        | url_ip | Yes | IP address to proper host, e.g. 127.0.0.1. |
        | port | No | Port for connection to DCAP.default is 8100 |
        | username | No | username, default value: None |
        | password | No | password, default value: None |
        | alias | No | Default `None`. If no alias is given, the instance alias will be set to default. |

        | Return Value | Description |
        | bts | It returns dcapConnection instance |
        """
        if alias in [item[0] for item in self.store.all]:
            raise ("Alias ({}) exists. Please remove it to reuse.".format(alias))
        bts = BTSDcap(bts_s1_ip=bts_s1_ip,
                      mrBtsId=mrBtsId,
                      url_ip=url_ip,
                      port=port,
                      username=username,
                      password=password,
                      bts_type=bts_type)
        self.store.add(bts, alias)
        return bts

    @lookup_handler.implicit_lookup
    def start_trace(self, tag="start_trace",
                    trace_profile=None,
                    custom_profile=None,
                    custom_filter_file=None,
                    connection=None):
        """
        This method is used to start trace under DCAP-LITE
        | Input Parameters | Man. | Description |
        | tag | No | the tag of this StartTraceBody. default 'start_trace' |
        | trace_profile | No |  the id or name of the bts start trace. user can get the trace profile |
        |               |    |  id or name details from `get_trace_profile_id_list`. |
        | custom_filter_file | No |  The custom_filter_file to start the trace. |
        | custom_profile | No | The gNB (5G) custom profile name list of the start trace to be started. |
        |                |    | e.g : [cp_5g, syslog_5g, immediateSnapshot_5g, |
        |                |    | L2Ps_Component, L2Lo_Component, SCF5g] |
        |                |    | The LTE (ENB) custom profile name list of the start trace to be started. |
        |                |    | e.g : [lteTracer_4g, tti_4g, aa_4g, syslog_4g, immediateSnapshot_4g, scf4g] |
        |                |    | can get all the custom profile name list by get_custom_profile_list. |
        | connection | No |  (optional) Unique identifier for a certain connections. |

        | Return Value | Description |
        | trace id | It returns trace id. |
        """
        return connection.start_trace(tag=tag,
                                      trace_profile=trace_profile,
                                      custom_profile=custom_profile,
                                      custom_filter_file=custom_filter_file)

    @lookup_handler.implicit_lookup
    def get_trace_profile_id_list(self, connection=None):
        """
        This method is used to get the trace profile id list under DCAP-LITE
        | Input Parameters | Man. | Description |
        | connection | No |  (optional) Unique identifier for a certain connections. |

        | Return Value | Description |
        | trace profile list | It returns all trace profile list. |
        """
        return connection.get_trace_profile_id_list()

    @lookup_handler.implicit_lookup
    def get_custom_profile_list(self, connection=None):
        """
        This method is used to get the custom profile id list under DCAP-LITE
        | Input Parameters | Man. | Description |
        | connection | No |  (optional) Unique identifier for a certain connections. |

        | Return Value | Description |
        | custom profile list | It returns all custom profile list. |
        """
        return connection.get_custom_profile_list()

    @lookup_handler.implicit_lookup
    def stop_trace(self, connection=None):
        """
        This method is used to get the custom profile id list under DCAP-LITE
        | Input Parameters | Man. | Description |
        | connection | No |  (optional) Unique identifier for a certain connections. |

        | Return Value | Description |
        | dict | It returns dict with operation information: custom_filter_file, force, tag, bts, trace_profiles, |
        |      | and duration. |
        """
        return connection.stop_trace()

    @lookup_handler.implicit_lookup
    def delete_trace(self, connection=None):
        """
        This method is used to delete the bts trace under DCAP-LITE
        | Input Parameters | Man. | Description |
        | connection | No |  (optional) Unique identifier for a certain connections. |

        | Return Value | Description |
        | OK | OK |
        """
        return connection.delete_trace()

    @lookup_handler.implicit_lookup
    def get_result_file(self,
                        target_dir="/tmp",
                        file_name="dcap_log.zip",
                        timeout=300,
                        connection=None):
        """
        This method is used to delete the bts trace under DCAP-LITE
        | Input Parameters | Man. | Description |
        | target_dir | No |  (optional) local storage path for collected files, default path will be /tmp. |
        | file_name | No | user can get the file_path_in_zip path log name from |
        |           |    | `get_result_file_contents` keyword e.g. "dcap_log.log" |
        | result_id | No |  result id to get the trace contents as per the file_path_in_zip arg. By default result_id |
        |           |    |  will be fetched from start_trace keyword which is called before. In case start_trace is |
        |           |    |  not called before then result_id has to be passed by user.If keyword is followed by |
        |           |    |  stop_trace do sleep for few seconds for it to package the log files. |
        | timeout | No |  to get the result timeout |

        | Return Value | Description |
        | filepath | filepath |
        """
        return connection.get_result_file(target_dir=target_dir,
                                          file_name=file_name,
                                          timeout=timeout)

    @lookup_handler.implicit_lookup
    def unzip_result_file_return_paths(self, zipfilepath="/tmp/dcap_log.zip",
                                       connection=None):
        """
        This method is used to get result file contents under DCAP-LITE
        | Input Parameters | Man. | Description |
        | target_dir | No | (optional) local storage path for collected files, default path will be /tmp. |
        | file_name | No | user can get the file_path_in_zip path log name from |
        |           |    | `get_result_file_contents` keyword e.g. "dcap_log.log" |
        | result_id | No | result id to get the trace contents as per the file_path_in_zip arg. By default result_id |
        |           |    | will be fetched from start_trace keyword which is called before. In case start_trace is |
        |           |    | not called before then result_id has to be passed by user.If keyword is followed by |
        |           |    | stop_trace do sleep for few seconds for it to package the log files. |
        | timeout | No |  to get the result timeout |

        | Return Value | Description |
        | filepath | filepath |
        """
        allfilelist = connection.unzip_dcap_log_and_get_all_file_paths(
            log_path=zipfilepath)
        return connection.get_log_path_from_result_log_paths(
            all_files_list=allfilelist)
