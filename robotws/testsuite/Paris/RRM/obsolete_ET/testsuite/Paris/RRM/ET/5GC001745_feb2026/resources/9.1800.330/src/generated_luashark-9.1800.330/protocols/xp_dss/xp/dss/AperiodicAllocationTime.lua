-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b


-- The time a priority based allocation remains valid.
--      Note: 0 min and infinite are to start (infinite) and to stop (0 min) a priority based allocation, e.g. in case of CMAS/ETWS.
local AperiodicAllocationTime = {}
AperiodicAllocationTime[268435455] = " (xp_dss_AperiodicAllocationTime._UNKNOWN_)"
AperiodicAllocationTime[0] = " (xp_dss_AperiodicAllocationTime.ALLOCATION_TIME_0_MIN)"
AperiodicAllocationTime[1] = " (xp_dss_AperiodicAllocationTime.ALLOCATION_TIME_1_MIN)"
AperiodicAllocationTime[5] = " (xp_dss_AperiodicAllocationTime.ALLOCATION_TIME_5_MIN)"
AperiodicAllocationTime[15] = " (xp_dss_AperiodicAllocationTime.ALLOCATION_TIME_15_MIN)"
AperiodicAllocationTime[30] = " (xp_dss_AperiodicAllocationTime.ALLOCATION_TIME_30_MIN)"
AperiodicAllocationTime[60] = " (xp_dss_AperiodicAllocationTime.ALLOCATION_TIME_60_MIN)"
AperiodicAllocationTime[268435454] = " (xp_dss_AperiodicAllocationTime.ALLOCATION_TIME_INFINITE)"

return AperiodicAllocationTime
