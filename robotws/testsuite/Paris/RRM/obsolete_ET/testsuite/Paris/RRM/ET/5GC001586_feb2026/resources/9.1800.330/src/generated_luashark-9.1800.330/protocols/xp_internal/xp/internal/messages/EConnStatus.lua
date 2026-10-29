-- Copyright 2020 Nokia
-- Created with MuLTI version: v0.24.3 f49d755d2a606bfb2c44b20709ef7342a02f7078 EXPERIMENTAL!
-- Type repository checksum:   0a26cb0ac27ecf8a57b68bb0fb5af4f52b134846


local EConnStatus = {}
EConnStatus[255] = " (xp_internal_messages_EConnStatus._UNKNOWN_)"
EConnStatus[0] = " (xp_internal_messages_EConnStatus.UNAVAILABLE)"
EConnStatus[1] = " (xp_internal_messages_EConnStatus.AVAILABLE)"

return EConnStatus
