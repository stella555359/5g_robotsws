"""
:copyright: Nokia Networks
:author: Dawid Krawczuk <dawid.krawczuk@nokia.com>
:maintainer: Dawid Krawczuk <dawid.krawczuk@nokia.com>
"""
from robot.libraries.BuiltIn import BuiltIn


class mock_stop_and_fix(object):

    def dummy_stop_and_fix(self):
        print('hello, I am dummy')

    def stop_and_fix_procedure_do_not_sleep(self):
        inst = BuiltIn().get_library_instance('uuf_rfrl_common')
        inst.stop_and_fix_procedure = self.dummy_stop_and_fix
