# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import sys
import time
import logging
import mysql.connector

above_path = os.sep.join(os.path.dirname(os.path.abspath(__file__)).split(os.sep)[:-1])
if above_path not in sys.path:
    sys.path.append(above_path)


class Db(object):

    def __init__(self, host='10.106.200.66', logger=None):
        self.logger = logger or logging.getLogger(__file__)
        self.host = host
        self.cnx = mysql.connector.connect(user='root',
                                           password='root',
                                           host=self.host,
                                           database='ute',
                                           connection_timeout=10)
        self.cursor = self.cnx.cursor()

    def query(self, sql):
        try:
            from common import IpaMmlItem
        except Exception as E:
            from .common import IpaMmlItem
        self.cursor.execute(sql)
        rows = []
        for row in self.cursor.fetchall():
            item = IpaMmlItem()
            for col_index, column_name in enumerate(self.cursor.column_names):
                setattr(item, column_name, row[col_index])
            rows.append(item)
        return rows

    def execute(self, sql):
        self.cursor.execute(sql)
        self.cnx.commit()

    def __del__(self):
        try:
            self.cursor.close()
            self.cnx.close()
        except Exception as E:
            pass


if __name__ == '__main__':
    rows = Db().query('select * from tblresource where resource_name="f_8379";')
    print(len(rows))
    print(rows[-1])
    print(rows[0].reversed_user)
