# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import sys
import logging
import datetime

try:
    from pet_db import Db
except Exception:
    from .pet_db import Db

above_path = os.sep.join(os.path.dirname(os.path.abspath(__file__)).split(os.sep)[:-1])
if above_path not in sys.path:
    sys.path.append(above_path)


class LockManager(object):

    def __init__(self):
        self.db = Db()

    def lock_resource(self, resource_name, people):
        sql = f'select * from tblresource where resource_name="{resource_name}";'
        rows = self.db.query(sql)
        if len(rows) > 0:
            used_time = datetime.datetime.now() - rows[0].reversed_time
            if used_time.seconds >= 4 * 3600:  # 锁了超过8个小时，强行解锁；
                logging.info(f'锁 {resource_name} 已经占用了超过8小时，这里强行解锁；')
                self.unlock_resource(resource_name)
            else:
                hours = used_time.seconds // 3600
                minutes = (used_time.seconds % 3600) // 60
                seconds = (used_time.seconds % 3600) % 60
                logging.info(f'锁 {resource_name} 已经占用了 {hours} 小时 {minutes} 分钟 {seconds} 秒')
                raise Exception(f'Resource {resource_name} already been locked by {rows[0].reversed_user}')
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        sql = f'insert into tblresource values("{resource_name}", "{ts}", "{people}");'
        self.db.execute(sql)
        sql = f'insert into tblresource_log values("Lock", "{resource_name}", "{ts}", "{people}");'
        self.db.execute(sql)

    def unlock_resource(self, resource_name):
        ts = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        sql = f'delete from tblresource where resource_name="{resource_name}";'
        self.db.execute(sql)
        sql = f'insert into tblresource_log values("Unlock", "{resource_name}", "{ts}", "ute");'
        self.db.execute(sql)


if __name__ == '__main__':
    logging.basicConfig(format='%(name)s-%(asctime)s [%(levelname)s] %(message)s',
                        datefmt="%Y-%m-%d %H:%M:%S", level=logging.INFO)
    lm = LockManager()
    # lm.lock_resource('bts1122', 'ute_10131')
    lm.lock_resource('1125', 'jufei')
    # lm.unlock_resource('1125')
