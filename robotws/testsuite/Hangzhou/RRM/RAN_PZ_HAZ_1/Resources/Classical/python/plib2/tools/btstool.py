#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import os
from pprint import pprint
from taf.sbts.oam.coam.admin import admin


class BtsTool(object):

    def __init__(self, args):
        self.args = args
        self.admin = None
        self.connection = None

    def _admin_setup(self):
        self.admin = admin()
        self.connection = self.admin.setup_admin(
            bts_host=self.args.host,
            name='ute_btstool',
            admin_api_log_dir='/tmp',
            use_ssl=True)

    def _admin_teadown(self):
        if self.admin:
            self.admin.teardown_admin(connection=self.connection)
            self.admin = None
            self.connection = None

    def dump_scf(self):
        print('导出基站的SCF文件...')
        try:
            self._admin_setup()
            local_dir_path, file_name = os.path.split(self.args.filename)
            self.admin.get_current_scf_file(local_dir_path=local_dir_path,
                                            file_name=file_name,
                                            export_type='configurationAndRuntimeObjects',
                                            connection=self.connection)
        finally:
            self._admin_teadown()
        print('导出成功。')

    def apply_scf(self):
        print('应用基站的SCF文件...')
        try:
            self._admin_setup()
            self.admin.perform_commissioning(scf_file=self.args.filename,
                                             skip_parameter_relation_errors=True,
                                             timeout=900,
                                             connection=self.connection)
        finally:
            self._admin_teadown()
        print('应用成功。')

    def reset(self):
        print('重启基站...')
        try:
            self._admin_setup()
            self.admin.reset(connection=self.connection)
        finally:
            self._admin_teadown()
        print('重启基站成功。')

    def run(self):
        if hasattr(self, self.args.operation):
            getattr(self, self.args.operation)()
        else:
            raise Exception(f'不支持的基站操作：{self.args.operation}')


if __name__ == "__main__":
    choices = [
        'apply_scf',
        'delta_commission',
        'dump_scf',
        'reset',
    ]

    import argparse
    parser = argparse.ArgumentParser(description='BTS 访问工具',  epilog='如果有问题，请和开发联系。')
    parser.add_argument("--host",
                        dest="host",
                        default='192.168.255.129',
                        help='指定基站的AdminAPI地址，缺省是192.168.255.129')

    parser.add_argument("-o", "--operation",
                        dest="operation",
                        choices=choices,
                        help='指定你的操作')

    parser.add_argument("--file",
                        dest="filename",
                        help='指定文件名')

    args = parser.parse_args()
    pprint(args)
    BtsTool(args).run()
