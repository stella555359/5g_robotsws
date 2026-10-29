-- Copyright 2022 Nokia
-- Created with MuLTI version: v0.30.0 fe61a41a3d1ca951588d52ace07043a6c8d792ca
-- Type repository checksum:   ea0c465c502489a725c72debad8f313f96fe7ee6


local EConnStatus = {}
EConnStatus[255] = " (xp_internal_messages_EConnStatus._UNKNOWN_)"
EConnStatus[0] = " (xp_internal_messages_EConnStatus.UNAVAILABLE)"
EConnStatus[1] = " (xp_internal_messages_EConnStatus.AVAILABLE)"

return EConnStatus
