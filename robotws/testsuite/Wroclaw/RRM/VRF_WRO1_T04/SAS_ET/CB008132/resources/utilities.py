# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek
:contact: michal.maczek@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import math

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts import (
    run_egate_cmd,
    start_data_traffic_in_egate,
    stop_data_traffic_in_egate
)


def set_internal_pdu_session(ue_id, pdu_id):
    command = "set_pdu_param ue={} pdu={} trf_type=internal".format(ue_id, pdu_id)
    run_egate_cmd(cmd=command)


def run_full_internal_traffic(ue_id, mbps, bearer=2, pdu_id=1, net_arch='sa'):
    num_of_inst = int(mbps) // 176 + 1
    if num_of_inst == 0:
        start_data_traffic_in_egate(
            ue_id=ue_id,
            pdu=pdu_id,
            bearer=bearer,
            trf_id=1,
            direction='dl',
            mbps=mbps,
            net_arch=net_arch
        )
        return
    for num in range(num_of_inst):
        start_data_traffic_in_egate(
            ue_id=ue_id,
            pdu=pdu_id,
            bearer=bearer,
            trf_id=num + 1,
            direction='dl',
            mbps=175,
            net_arch=net_arch
        )


def stop_traffic_one_ue(ue_id, tput, net_arch='sa', bearer=2):
    tput = int(tput)
    num_of_inst = math.floor(tput / 175)

    if num_of_inst == 0:
        stop_data_traffic_in_egate(
            ue_id=ue_id,
            pdu=1,
            trf_id=1,
            direction='dl',
            net_arch=net_arch,
            bearer=bearer
        )
    else:
        for num in range(1, num_of_inst + 1):
            stop_data_traffic_in_egate(
                ue_id=ue_id,
                pdu=1,
                trf_id=num,
                direction='dl',
                net_arch=net_arch,
                bearer=bearer
            )
