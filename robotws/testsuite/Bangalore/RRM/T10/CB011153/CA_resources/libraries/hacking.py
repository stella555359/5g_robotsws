# -*- coding: utf-8 -*-
"""Collection of various hacks/workarounds for test libraries."""
import os

from robot.libraries.BuiltIn import BuiltIn, register_run_keyword

__all__ = ["dump_wts_logs_on_runtime", "run_through_proxy"]

ROBOT_LIBRARY_SCOPE = "GLOBAL"
ROBOT_LIBRARY_DOC_FORMAT = "reST"


def dump_wts_logs_on_runtime(destination):
    """Dumps WTS logs to ``destination`` path, without stopping simulation.

    Requires prior working WTS instance (with default alias), probably started
    by combination of ``start_wts_applications`` and ``start_wts_services``.

    Returns content of the ``destination`` directory.
    """
    ute_wtssim = BuiltIn().get_library_instance("ute_wtssim")
    wts = ute_wtssim.wts_store.get(None)
    unzip = None
    subdirectory = os.path.abspath(destination)
    ute_wtssim._collect_logs(wts, unzip, subdirectory)
    return [os.path.join(subdirectory, f) for f in os.listdir(subdirectory)]


def run_through_proxy(http_proxy, name, *args):
    """Injects http_proxy into environ before executing given keyword.

    Restore environ to original state afterwards.

    The keyword name and arguments work as with BuiltIn's *Run Keyword*.
    """
    orig_proxy = os.environ.get("http_proxy", None)
    os.environ["http_proxy"] = http_proxy
    try:
        inner_return = BuiltIn().run_keyword(name, *args)
    finally:
        if orig_proxy is not None:
            os.environ["http_proxy"] = orig_proxy
        else:
            del os.environ["http_proxy"]
    return inner_return


register_run_keyword(__name__, "run_through_proxy", args_to_process=1)
