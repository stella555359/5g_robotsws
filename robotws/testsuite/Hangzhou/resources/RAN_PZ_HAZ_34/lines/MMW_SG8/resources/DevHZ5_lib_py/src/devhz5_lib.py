# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from .common_lib import common_lib
from .cm import cm
from .config import configuration
from .pm.pm import pm
from .fm.fm import fm
from .startup.startup import startup
from .features import features
from .tools import tools
from .log_analysis import log_analysis
from .call import call
from .base_lib.ute_fsmaccess import ute_fsmaccess


class devhz5_lib(common_lib, configuration, pm, cm, fm, features, tools, log_analysis, startup, call, ute_fsmaccess):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        common_lib.__init__(self)
        pm.__init__(self)
        cm.__init__(self)
        fm.__init__(self)
        features.__init__(self)
        tools.__init__(self)
        log_analysis.__init__(self)
        startup.__init__(self)
        configuration.__init__(self)
        call.__init__(self)
        ute_fsmaccess.__init__(self)


if __name__ == "__main__":
    obj = devhz5_lib()
    help(obj)
