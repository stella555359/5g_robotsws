-- Copyright 2021 Nokia
-- Created with MuLTI version: v0.27.1 aa1f9b4ca0ac779706ce54adc873c585cfe4dc52 EXPERIMENTAL!
-- Type repository checksum:   100182fedaadec7651a8ab34708d388f03513b4b


local EConnStatus = {}
EConnStatus[255] = " (xp_internal_messages_EConnStatus._UNKNOWN_)"
EConnStatus[0] = " (xp_internal_messages_EConnStatus.UNAVAILABLE)"
EConnStatus[1] = " (xp_internal_messages_EConnStatus.AVAILABLE)"

return EConnStatus
