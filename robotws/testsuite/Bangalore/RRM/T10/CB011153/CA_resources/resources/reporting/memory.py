"""Utilities for reading memory usage on BTS from aashell output"""
import uuid
from contextlib import contextmanager

from taf.ccs.aashell import aashell

NODE_SLOT = {
    "0x1011": 0,
    "0x2011": 4,
}


@contextmanager
def aashell_cli(alias):
    cli = aashell()
    cli.create_aashell_cli(alias, hops=dict(host="192.168.255.129"))
    cli.setup(alias)
    try:
        yield cli
    finally:
        cli.teardown(alias)


def get_measurements() -> list[dict]:
    """
    Returns list of memory usage measurements for system and cgroup level.
    """
    alias = str(uuid.uuid4())
    with aashell_cli(alias) as cli:
        info_groups = cli.get_sysinfo(alias)

    system_info = cli.system_info(info_groups)
    try:
        cgroup_info = cli.cgroup_info(info_groups)
    except IndexError:
        # sw build does not support reporting cgroups
        cgroup_info = []

    measurements = []
    for metric in system_info:
        if metric.Name == "System used memory [kB]" and metric.NID in [
            "0x1011",
            "0x2011",
        ]:
            slot = NODE_SLOT[metric.NID]
            sample = {
                "name": f"{slot}:system",
                "value": metric.get("Value [kB]"),
                "description": "System used memory",
            }
            measurements.append(sample)

    for metric in cgroup_info:
        sample = {
            "name": f"{metric.NID}:{metric.Cgroup}",
            "value": metric.get("memory total [kB]"),
            "description": "Cgroup alloc memory",
        }
        measurements.append(sample)

    return measurements
