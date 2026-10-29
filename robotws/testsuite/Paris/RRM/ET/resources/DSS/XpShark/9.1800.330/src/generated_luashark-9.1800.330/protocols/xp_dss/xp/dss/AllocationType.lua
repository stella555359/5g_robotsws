-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6


-- Indicates whether the DL allocation request from CRM to CRM client was performed with minimum share, maximum share, normal share or min max equal share.
local AllocationType = {}
AllocationType[0] = " (xp_dss_AllocationType._UNKNOWN_)"
AllocationType[1] = " (xp_dss_AllocationType.NormalShare)"
AllocationType[2] = " (xp_dss_AllocationType.MinShare)"
AllocationType[3] = " (xp_dss_AllocationType.MaxShare)"
AllocationType[4] = " (xp_dss_AllocationType.MinMaxEqualShare)"

return AllocationType
