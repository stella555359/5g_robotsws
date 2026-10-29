-- Copyright (c) 2019 Nokia. All rights reserved.

require 'endc_utility_functions'
require 'log_mgmt'
require 'stats'
require 'wrapper'

function sim_log_set_flush()
    local func_name = "sim_log_set_flush"
    printStep(func_name .. ": sending egate prints to egate_console.log file")
    exec("sim_log_set flush")
end

function sim_log_re()
    local func_name = "sim_log_re"
    printStep(func_name .. ": sending egate prints to egate_console.log file")
    exec("re")
end
