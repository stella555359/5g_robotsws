# -*- coding: utf-8 -*-
"""
:author: Yonna
:contact: yonna.yao@nokia.com
"""

# used in keyword : cell_should_be_onair
IM_CELL_ONAIR = ['/MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-* is [stateInfo.procedural \
                 State=regex"[oO]nAir"]']
# used in keyword : bts_should_be_onair
IM_BTS_ONAIR = ['/MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTSS_M-* is [stateInfo.proceduralState=regex"[oO]nAir"]',
                '/MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-* is [stateInfo.proceduralState=regex"[oO]nAir"]']
# used in keyword : enb_get_physical_cell_id  \  enb_get_cell_number
IM_PHY_CELL_ID = ['/MRBTS-1/RAT-2/LTS-*/LNBTS_L-*/LNCEL_L-',
                  '/MRBTS-1/RAT-3/LTS-*/LNBTS_L-*/LNCEL_L-',
                  '/MRBTS-1/RAT-1/LTS-*/LNBTS_L-*/LNCEL_L-']
