-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6





-- The purpose of the cause information element is to indicate the reason for a particular event for the DSS related procedures.
local EnDssFailureCause = {}
EnDssFailureCause[0] = " (xp_dss_EnDssFailureCause._UNKNOWN_)"
EnDssFailureCause[1] = " (xp_dss_EnDssFailureCause.IncompatibleMessageSet)"
EnDssFailureCause[2] = " (xp_dss_EnDssFailureCause.NotEnoughRessources)"
EnDssFailureCause[3] = " (xp_dss_EnDssFailureCause.DssAlreadySetUp)"
EnDssFailureCause[4] = " (xp_dss_EnDssFailureCause.TimeOut)"
EnDssFailureCause[5] = " (xp_dss_EnDssFailureCause.KeepAliveTimeOut)"
EnDssFailureCause[6] = " (xp_dss_EnDssFailureCause.NotMatchingCellIds)"
EnDssFailureCause[7] = " (xp_dss_EnDssFailureCause.NonMatchingResourceReservations)"
EnDssFailureCause[8] = " (xp_dss_EnDssFailureCause.DssConfigurationError)"
EnDssFailureCause[9] = " (xp_dss_EnDssFailureCause.OutOfRangeOfTheAllowedMbsfnSubframes)"
EnDssFailureCause[10] = " (xp_dss_EnDssFailureCause.MbsfnAllocationFailure)"
EnDssFailureCause[11] = " (xp_dss_EnDssFailureCause.DecodingProblem)"
EnDssFailureCause[12] = " (xp_dss_EnDssFailureCause.LogicalError)"
EnDssFailureCause[13] = " (xp_dss_EnDssFailureCause.Unspecified)"
EnDssFailureCause[14] = " (xp_dss_EnDssFailureCause.ResourceConflict)"
EnDssFailureCause[15] = " (xp_dss_EnDssFailureCause.SubframeAllocationFailure)"
EnDssFailureCause[16] = " (xp_dss_EnDssFailureCause.SubcarrierAllocationFailure)"
EnDssFailureCause[17] = " (xp_dss_EnDssFailureCause.RoundTripTimeExceeded)"

return EnDssFailureCause
