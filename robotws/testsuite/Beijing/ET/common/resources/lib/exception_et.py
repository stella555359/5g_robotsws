# -*- coding: utf-8 -*-
"""
2022/05/22 first version by @author: xiang.5.li@nokia-sbell.com
"""
try:
    from .logger_et import LoggingEt
except Exception:
    from logger_et import LoggingEt
import os


class RaiseExceptionEt(object):
    def __init__(self, log_path):
        self.log_path = log_path
        # self.log = LoggingEt(log_path).log()
        __logger_name = os.path.basename(__file__)
        self.log = LoggingEt(self.log_path, __logger_name).log()

    def make_exception_info_str(self, e, info, para):
        exception_name = ([' ' + e.__name__ + '.' + var + ' '
                           for var, value in vars(e).items()
                           if id(value) == id(info)] or [''])[0]
        if type(info) is not tuple:
            info = (info, '')
        info_str = info[0].format(**para) if para else info[0]
        info_detail = info[1].format(**para) if para else info[1]
        if info_detail:
            info_str += ':\n' + exception_name.center(100, '*') + '\n'
            info_str += info_detail
            info_str += '\n' + ''.center(100, '*') + '\n'
        return info_str

    def raise_exception_simple(self, e, info="", para=None):
        info_str = self.make_exception_info_str(e, info, para)
        raise e(info_str)

    def case_fail(self, msg=''):
        """set case fail with msg, and quit program if quit_flag is True
           and count number of different fail types
        """
        self.log.warning("[Fail] %s" % msg)
        self.log.handlers = []
        self.raise_exception_simple(CaseFail)

    def case_invalid(self, msg=''):
        """set case invalid with msg, and quit program if quit_flag is True
           and count number of different invalid types
        """
        self.log.warning("[Invalid] %s" % msg)
        self.log.handlers = []
        self.raise_exception_simple(CaseInvalid)

    def case_pass(self, msg=''):
        """set case Pass with msg
        """
        self.log.info("[Pass] %s" % msg)
        self.log.handlers = []


class CaseInvalid(Exception):
    pass


class CaseFail(Exception):
    pass
