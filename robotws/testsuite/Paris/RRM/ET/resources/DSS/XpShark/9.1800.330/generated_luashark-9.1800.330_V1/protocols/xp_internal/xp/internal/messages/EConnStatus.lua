-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.30.2 90a0849bf7db81e20cf10edec9ae507f92297f58
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6





local EConnStatus = {}
EConnStatus[255] = " (xp_internal_messages_EConnStatus._UNKNOWN_)"
EConnStatus[0] = " (xp_internal_messages_EConnStatus.UNAVAILABLE)"
EConnStatus[1] = " (xp_internal_messages_EConnStatus.AVAILABLE)"

return EConnStatus
