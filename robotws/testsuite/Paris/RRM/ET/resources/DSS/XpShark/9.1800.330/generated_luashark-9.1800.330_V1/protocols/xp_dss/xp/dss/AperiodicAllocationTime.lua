-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6





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
