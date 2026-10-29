-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846


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

return EnDssFailureCause
