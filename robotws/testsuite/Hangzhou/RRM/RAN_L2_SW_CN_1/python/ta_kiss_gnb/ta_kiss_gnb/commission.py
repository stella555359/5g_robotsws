# -*- coding: utf-8 -*-
"""
:created on: 2020-01-11

:copyright: Nokia
:author: Yao Yonna
:contact: yonna.yao@nokia-sbell.com
"""


import re
import logging
from taf.sbts.oam.coam.admin import admin


class Commission(object):
    """Config Gnb to expected status.
    """
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        pass

    def do_full_commissioning(self, scfc):
        """do ful lcommission wusing input scfc file"""
        try:
            bts_coam = admin()
            connection = bts_coam.connect_to(admin_api_log_dir='/tmp/')
            bts_dist = connection.get_id_for_current(class_name='BTS')
            logging.info("BTS info:{}".format(bts_dist))
            bts_id = re.findall(r'(?<=MRBTS-)\d+', bts_dist)[0]
            logging.info("bts_id:{}".format(bts_id))
            connection.perform_commissioning(bts_id=bts_id, scf_file=scfc, skip_parameter_relation_errors=True,
                                             timeout=600)
        except Exception as e:
            raise Exception(e)
        finally:
            bts_coam.teardown()


def do_full_commissioning(scfc):
    Commission().do_full_commissioning(scfc)
