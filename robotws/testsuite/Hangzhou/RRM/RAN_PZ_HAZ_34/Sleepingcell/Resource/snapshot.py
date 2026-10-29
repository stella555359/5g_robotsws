# -*- coding: utf-8 -*-
"""
Author:         shenrao
Contact Mail:   shengrong.rao@nokia-sbell.com
Description:    get snapshot by background

"""
from taf.gnb.oam.coam.admin import admin
import logging
import time
import sys
coam = admin()


def get_snapshot_by_background(host, times, target_path, coverage='Full', connection_alias='snapshot_collect'):
    coam.connect_to(bts_host=host, bts_port=443, username='Nemuadmin', password='nemuuser', name=connection_alias)
    for i in range(times):
        try:
            logging.debug("{}".format(i))
            date = time.strftime("%Y-%m-%d-%H-%M-%S", time.localtime())
            print(date)
            path = coam.get_snapshot(target_file_name=target_path + '/' + 'snapshot-' + date + '.zip',
                                     coverage=coverage, connection=connection_alias)
            logging.debug("path: {}".format(path))
            time.sleep(1)
        except BaseException as e:
            raise e
    coam.teardown(connection=connection_alias)


argv1 = '{}'.format(sys.argv[1])
argv2 = '{}'.format(sys.argv[2])
argv3 = '{}'.format(sys.argv[3])
get_snapshot_by_background(host=argv1, times=int(argv2), target_path=argv3)
