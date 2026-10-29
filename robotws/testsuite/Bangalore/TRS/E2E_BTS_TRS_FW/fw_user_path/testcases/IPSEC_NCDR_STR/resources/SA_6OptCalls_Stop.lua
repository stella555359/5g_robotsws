-- Copyright (c) 2019 Nokia. All rights reserved.
--1.0 Handling pduSize as optional parameter when generating traffic

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'
require 'ext_traffic'


exec('ue_deregister id=1 ue_deregister_type=switch_off')

--[[
sleep(5)

exec('ue_deregister id=2 ue_deregister_type=switch_off')

sleep(5)

exec('ue_deregister id=3 ue_deregister_type=switch_off')

sleep(5)

exec('ue_deregister id=4 ue_deregister_type=switch_off')

sleep(5)

exec('ue_deregister id=5 ue_deregister_type=switch_off')

sleep(5)

exec('ue_deregister id=6 ue_deregister_type=switch_off')

]]--