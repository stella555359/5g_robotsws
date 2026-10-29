require 'wrapper'
require 'ping'
require 'stats'
require 'ext_traffic'
require 'asn_rrc'

--******************************************************************
--  disp_ue_state function
--******************************************************************
function disp_ue_state(start_id,end_id)

  for ue_id = start_id,end_id do
    ue_ = ue(ue_id)
    if ue_.state == ue.IDLE  then
      print_info(" UE"..ue_id.." in IDLE state")
    elseif ue_.state == ue.ACTIVATING  then
      print_info(" UE"..ue_id.." in ACTIVATING state")
    elseif ue_.state == ue.ACTIVE  then
      print_info(" UE"..ue_id.." in ACTIVE state")
    elseif ue_.state == ue.DEACTIVATING  then
      print_info(" UE"..ue_id.." in DEACTIVATING state")
    elseif ue_.state == ue.OFF  then
      print_info(" UE"..ue_id.." in OFF state")
    else
      print_info(" UE"..ue_id.." in state "..ue_.state)
    end
  end
end

--******************************************************************
--  mue_attach function
--******************************************************************
function mue_attach(ue_start,ue_end,interval,timeout,retry,selected_plmn,emergency)
  interval = interval or "0.1"
  wait_confirmation = wait_confirmation or false
  timeout = timeout or 30
  if tonumber(retry) == 0 then
    retry = false 
  else
    retry = true
  end
  retry_interval = retry_interval or interval
  ue_num = ue_end - ue_start + 1
  params_ = ue_attach_params()
  default_emergency_cm_bearer_id=9
  if tonumber(selected_plmn) ~= 0 then        
    params_.selected_plmn = selected_plmn
    print("params: "..tostring(params_))
  end
  if wait_confirmation == true then
    ue_attach_timeout = 0.5
  else
    ue_attach_timeout = 30
  end
  stop_on_failure = false
  if retry == false then
    stop_on_failure = true
  end

  ue_result = {}
  ue_failed = 0
  ue_attached = 0
  print_info("MULTI UE_ATTACH starting loop from "..ue_start.." to "..ue_end.." with interval of "..tonumber(interval).." seconds...")
  for ue_id = ue_start,ue_end do
    ue_ = ue(ue_id)
    --print_info("  UE_ATTACH for UE"..ue_id.." current state="..ue_.state.." "..ue.state_tostring(ue_.state))
    if ue_.state == ue.OFF then
      if tonumber(emergency) ~= 0 then
          print("emergency on")
          params_.emergency=true
          if (ue_:is_emergency_pdn_configured()) then
            if (ue_:is_emergency_pdn_configured(ue.PDN_TYPE_IPV4)) then
              print("Emergency PDN_TYPE_IPV4 is configured\n")
            end
            if (ue_:bearer(default_emergency_cm_bearer_id).cfg.is_emergency) then
              print("'ue_:bearer(default_emergency_cm_bearer_id).cfg.is_emergency' returned true\n")
            end
            if ue_:attach(params_, tonumber(timeout)) then
              print("ue_:attach(params_, tonumber(timeout)) for emergency call returned true")
              ue_info_ue_ = ue_:get_info(ue.INITIATED_BY_UE)
              print("UE info at UEC:\n-------------------\n" ..tostring(ue_info_ue_))    
              ue_info_mme_ = ue_:get_info(ue.INITIATED_BY_MME)
              print("\nUE info at MME:\n-------------------\n" ..tostring(ue_info_mme_)) 
              print("'attach_type' at UE is:" ..ue_info_ue_.attach_type)
              if (ue_info_ue_.attach_type==nas_attach_type.EPS_EMERGENCY_ATTACH) then
                print("'attach_type' at UE is: nas_attach_type.EPS_EMERGENCY_ATTACH. emergency_pgw_id=" ..ue_info_ue_.emergency_pgw_id)
              end 
              print("'attach_type' at MME is:" ..ue_info_mme_.attach_type)
              if (ue_info_mme_.attach_type==nas_attach_type.EPS_EMERGENCY_ATTACH) then
                print("'attach_type' at MME is: nas_attach_type.EPS_EMERGENCY_ATTACH. emergency_pgw_id=" ..ue_info_mme_.emergency_pgw_id)
              end
            else
              print("ue_:attach(params_, tonumber(timeout)) for emergency call returned false")
            end
          else
            print("'ue_:is_emergency_pdn_configured()' returned false for UE " ..ue_.id) 
          end
      else
          ue_:attach(params_, tonumber(timeout))
      end
      --ue_attach(ue_,tonumber(timeout))
      if ue_.state == ue.ACTIVE  then
        ue_result[ue_id-1] = true
        ue_attached = ue_attached +1
        --print_info("  UE"..ue_id.." attach passed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
      else
        ue_result[ue_id-1] = false
        ue_failed = ue_failed +1
        print_info("  UE"..ue_id.." attach failed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
        exec("ue_disp id="..ue_id)
        if stop_on_failure then
          print_warn("MULTI UE_ATTACH aborting script execution after ue_attach failure!!!")
          break
        end
      end
    else
      ue_attached = ue_attached +1
      ue_result[ue_id-1] = true
      if ue_.state == ue.ON or ue_.state == ue.ACTIVE then
        print_warn("  UE"..ue_id.." is already attached, and state="..ue_.state.." "..ue.state_tostring(ue_.state))
      elseif ue_.state == ue.IDLE then
        print_warn("  UE"..ue_id.." is already attached, and ue.state="..ue_.state.." IDLE")
      else
        print_err("  UE"..ue_id.." is not ready for the attach, and state="..ue_.state.." "..ue.state_tostring(ue_.state))
      end
    end
    --print_info("sleep interval = "..tonumber(interval))
    if tonumber(ue_num) > 1 then
      if tonumber(interval) ~= 0 then
        sleep(tonumber(interval))
      end
    end
  end

  if retry then
    print('in retry.................')
    -- re-attach UE if first attach was not successful
    for ue_id = ue_start,ue_end do
      if ue_result[ue_id-1] == false then
        ue_ = ue(ue_id)
        if ue_.state ~= ue.ACTIVE  then
          print_warn("  UE_ATTACH: retry for ue_id="..ue_id.." with state="..ue_.state.." "..ue.state_tostring(ue_.state))
          exec("ue_kill id="..ue_id)
          if tonumber(retry_interval) ~= 0 then
            sleep(tonumber(retry_interval))
          end
          if ue_attach(ue_,tonumber(timeout)) then
            ue_result[ue_id-1] = true
            ue_attached = ue_attached +1
            print_info("  UE"..ue_id.." attach passed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
          else
            ue_result[ue_id-1] = false
            print_info("  UE"..ue_id.." attach failed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
            print_info("  executing ue_kill for "..ue_id.." and skipping the UE attach!!!!")
            exec("ue_kill id="..ue_id)
          end
        else
          --ue_id is already active
          ue_result[ue_id-1] = true
          ue_attached = ue_attached +1
          ue_failed = ue_failed -1
        end
      end
    end
  end

  if ue_attached == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI UE_ATTACH loop completed: Result="..result.." #UEs_Total="..ue_num.."; #UEs_attached="..ue_attached..";  #UEs_failed="..ue_failed)
  return result
end


--******************************************************************
--  mue_detach function
--******************************************************************
function mue_detach(ue_start, ue_end, interval)
  ue_failed = 0
  ue_detached = 0
  interval = interval or "0.1"
  ue_num = ue_end - ue_start + 1
  print_info("MULTI UE_DETACH starting loop from "..ue_start.." to "..ue_end.." with interval of "..tonumber(interval).." seconds...")
  for ue_id = ue_start,ue_end do
    ue_ = ue(ue_id)
    --print_info("  UE_DETACH for UE"..ue_id.." current state="..ue_.state.." "..ue.state_tostring(ue_.state))
    if ue_.state ~= ue.OFF then
      if ue_detach(ue_,ue.INITIATED_BY_UE) then
        ue_detached = ue_detached +1
        --print_info("  UE"..ue_id.." detach passed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
      else
        ue_failed = ue_failed +1
        print_info("  UE"..ue_id.." detach failed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
        print_info("  executing ue_kill for "..ue_id)
        exec("ue_disp id="..ue_id)
        exec("ue_kill id="..ue_id)
      end
    else
      print_warn("  UE"..ue_id.." is already detached, and ue.state="..ue_.state.." "..ue.state_tostring(ue_.state))
    end
    if tonumber(interval) ~= 0 then
      sleep(tonumber(interval))
    end
  end

  if ue_detached == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI UE_DETACH loop completed: Result="..result.." #UEs_Total="..ue_num.."; #UEs_detached="..ue_detached..";  #UEs_failed="..ue_failed)
  return result
end


--******************************************************************
--  kill_activating function
--******************************************************************
function kill_activating(start_id,end_id)

  for ue_id = start_id,end_id do
    ue_ = ue(ue_id)
    if ue_.state == ue.ACTIVATING  then
      exec("ue_kill id="..ue_id)
    end
  end
end

--******************************************************************
--  mue_bearer_add function
--******************************************************************
function mue_bearer_add(start_id,end_id,drb_id,filter_id,precedence_id)
  start_id = tonumber(start_id) or 1
  end_id = tonumber(end_id) or 1
  drb_id = tonumber(drb_id) or 2
  filter_id = tonumber(filter_id) or drb_id
  precedence_id = tonumber(precedence_id) or drb_id
  ue_add_drb_passed = 0
  ue_add_drb_failed = 0
  ue_num = end_id - start_id + 1
  ue_index = 1
  for ue_id = start_id, end_id do
    ue_ = ue(ue_id)
	
	if ue_.state == ue.IDLE then
      ue_:im_exit(2)
      sleep(0.5)
    end
	
    if ue_.state == ue.ACTIVE then
      filter_ = filter()
      filter_.id = filter_id
      filter_.direction = filter.FDIR_BIDIR
      filter_.precedence = precedence_id
      filter_.proto = 17
      filter_.remote_port = filter_port(50000, 60000)
      filter_.local_port = filter_port(50000, 60000)
      --filter_.remote_port = filter_port(p_rem_port[1], p_rem_port[2])
      --filter_.local_port = filter_port(p_loc_port[1], p_loc_port[2])
      --filter_.tos.value = p_tos[1]
      --filter_.tos.mask = p_tos[2]
      --filter_.label.value = "filter1_gbr"

      bearer_ = ue_:bearer(drb_id)
      by_ = ue.INITIATED_BY_UE
      -- timeout_ = 5

      if bearer_add(bearer_, filter_, by_,timeout_) == true then
                          local timeout_= 20
                    while (timeout_ > 0)
                    do
                          local bearer_info = bearer_:get_info(initiator.UE)
                          --if bearer_info then
                          if bearer_.state == bearer.ON then
                              ue_add_drb_passed = ue_add_drb_passed + 1
                              print("UE"..ue_id.." bearer-"..drb_id.."="..tostring(bearer_info))
                              break
                          end
                          sleep(0.1)
                          timeout_ = timeout_ - 1
                    end

                    if (timeout_ == 0) then
                          print("UE"..ue_id.." bearer-"..drb_id.." create failed after 1.0 s timeout")
                          ue_add_drb_failed = ue_add_drb_failed + 1
                    end

        -- ue_add_drb_passed = ue_add_drb_passed + 1
        ue_index = ue_index + 1
      else
        ue_add_drb_failed = ue_add_drb_failed + 1
      end

    else
      print_err("  UE"..ue_id.." is NOT yet attached, and state="..ue_.state.." "..ue.state_tostring(ue_.state))
    end
  end

  if ue_add_drb_passed == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI BEARER_ADD loop completed: Result="..result.." #UEs_Total="..ue_num.."; #UEs_add_drb_ok="..ue_add_drb_passed..";  #UEs_add_drb_NOK="..ue_add_drb_failed)
  return result
end

--******************************************************************
--  mue_bearer_del function
--******************************************************************
function mue_bearer_del(start_id,end_id,drb_id)
  start_id = tonumber(start_id) or 1
  end_id = tonumber(end_id) or 1
  drb_id = tonumber(drb_id) or 2

  ue_del_drb_passed = 0
  ue_del_drb_failed = 0

  ue_num = end_id - start_id + 1
  ue_index = 1
  for ue_id = start_id, end_id do
    ue_ = ue(ue_id)
	
	if ue_.state == ue.IDLE then
      ue_:im_exit(2)
      sleep(0.5)
    end
	
    if ue_.state == ue.ACTIVE then

      bearer_ = ue_:bearer(drb_id)
      by_ = ue.INITIATED_BY_UE
      timeout_ = 5

      if bearer_del(bearer_, by_,timeout_) == true then
        ue_del_drb_passed = ue_del_drb_passed + 1
        ue_index = ue_index + 1
      else
        ue_del_drb_failed = ue_del_drb_failed + 1
      end

    else
      print_err("  UE"..ue_id.." is NOT yet attached, and state="..ue_.state.." "..ue.state_tostring(ue_.state))
    end
  end

  if ue_del_drb_passed == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI BEARER_DEL loop completed: Result="..result.." #UEs_Total="..ue_num.."; #UEs_del_drb_ok="..ue_del_drb_passed..";  #UEs_del_drb_NOK="..ue_del_drb_failed)
  return result
end


--******************************************************************
--  mue_data_start function
--******************************************************************
function mue_data_start(ue_start, ue_end, direction, protocol, ul_mbps, dl_mbps, bearerId, interval)

  direction = direction or "both"
  ul_mbps = ul_mbps or "0.5"
  dl_mbps = dl_mbps or "0.5"
  interval = interval or "0.1"
  bearerId = bearerId or 1
  protocol = protocol or "udp"

  ue_data_start_passed = 0
  ue_data_start_failed = 0

  ue_num = ue_end - ue_start + 1

  print_info("MULTI UE_DATA_START starting loop from "..ue_start.." to "..ue_end.." with interval of "..tonumber(interval).." seconds...")
  for ue_id = ue_start,ue_end do
    ue_ = ue(ue_id)
    if ue_.state == ue.ON then

      -- create bearer
      bearer_ = ue_:bearer(tonumber(bearerId))

      -- start DL data traffic
      if direction == 'both' or direction == 'dl' then

        dl_traffic_params = traffic(tonumber(dl_mbps) * 1e6) -- bps
        if protocol == 'udp' then
          dl_traffic_params.protocol = 17
        elseif protocol == 'tcp' then
          dl_traffic_params.protocol = 6
        end
        --dl_traffic_params.bps = 175000000  -- in range [1000..175000000]
        --dl_traffic_params.burst = 1
        --dl_traffic_params.period = 1
        --dl_traffic_params.size = range(90, 120)
        --dl_traffic_params.l3_size = range(1400,1400)
        --result,err = data_start(bearer_, traffic_params )
        bearer_.traffic_dl = dl_traffic_params

      end
      -- start UL data traffic
      if direction == 'both' or direction == 'ul' then

        ul_traffic_params = traffic(tonumber(ul_mbps) * 1e6) -- bps
        if protocol == 'udp' then
          ul_traffic_params.protocol = 17
        elseif protocol == 'tcp' then
          ul_traffic_params.protocol = 6
        end
        --ul_traffic_params.bps = 175000000  -- in range [1000..175000000]
        --ul_traffic_params.burst = 1
        --ul_traffic_params.period = 1
        --ul_traffic_params.size = range(90, 120)
        --ul_traffic_params.l3_size = range(1400,1400)
        --result,err = data_start(bearer_, traffic_params )
        bearer_.traffic_ul = ul_traffic_params

      end
      ue_data_start_passed = ue_data_start_passed + 1

    else
      print_warn("  UE"..ue_id.." is not attached, and ue.state="..ue_.state.." "..ue.state_tostring(ue_.state))
    end

    if tonumber(interval) ~= 0 then
      sleep(tonumber(interval))
    end
  end

  if ue_data_start_passed == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI UE_DATA_START loop completed: Result="..result.." #UEs_Total="..ue_num.."; #UEs_data_start_ok="..ue_data_start_passed..";  #UEs_data_start_NOK="..ue_data_start_failed)
  return result
end

--******************************************************************
--  mue_data_stop function
--******************************************************************
function mue_data_stop(ue_start, ue_end, direction, bearerId, interval)

  direction = direction or "both"
  interval = interval or "0.1"
  bearerId = bearerId or 1

  ue_data_stop_passed = 0
  ue_data_stop_failed = 0

  ue_num = ue_end - ue_start + 1

  print_info("MULTI UE_DATA_STOP starting loop from "..ue_start.." to "..ue_end.." with interval of "..tonumber(interval).." seconds...")
  for ue_id = ue_start,ue_end do
    ue_ = ue(ue_id)
    if ue_.state == ue.ON then

      -- create bearer
      bearer_ = ue_:bearer(tonumber(bearerId))

      -- stop DL data traffic
      if direction == 'both' or direction == 'dl' then

        bearer_.traffic_dl = nil

      end

      -- stop UL data traffic
      if direction == 'both' or direction == 'ul' then

        bearer_.traffic_ul = nil

      end

      ue_data_stop_passed = ue_data_stop_passed + 1

    else
      print_warn("  UE"..ue_id.." is not attached, and ue.state="..ue_.state.." "..ue.state_tostring(ue_.state))
    end

    if tonumber(interval) ~= 0 then
      sleep(tonumber(interval))
    end
  end

  if ue_data_stop_passed == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI UE_DATA_STOP loop completed: Result="..result.." #UEs_Total="..ue_num.."; #UEs_data_stop_ok="..ue_data_stop_passed..";  #UEs_data_stop_NOK="..ue_data_stop_failed)
  return result
end


--******************************************************************
--  mue_stats function
--******************************************************************
function mue_stats(ue_start, ue_end, scell, format, statsType, interval)

  scell = scell or "both"
  format = format or "long"
  statsType = statsType or "all"
  interval = interval or "1"

  ue_stats_passed = 0
  ue_stats_failed = 0

  if statsType == "all" then
    statsTypeStr = "pdsch,pusch,dl_harq,ul_harq,dl_mac,ul_mac,dl_rlc,ul_rlc"
  else
    statsTypeStr = statsType
  end

  ue_num = ue_end - ue_start + 1

  print_info("MULTI UE_STATS starting loop from "..ue_start.." to "..ue_end.." with interval of "..tonumber(interval).." seconds...")
  for ue_id = ue_start,ue_end do

    -- exec ue_stats command
    exec("ue_stats id="..ue_id.." scell="..scell.." format="..format.." type="..statsTypeStr)

    ue_stats_passed = ue_stats_passed + 1

    if tonumber(interval) ~= 0 then
      sleep(tonumber(interval))
    end
  end

  if ue_stats_passed == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI UE_STATS loop completed: Result="..result)
  return result
end

--******************************************************************
--  mue_bearer_stats function
--******************************************************************
function mue_bearer_stats(ue_start, ue_end, bearer, dir, statsType, interval)

  bearer = bearer or 1
  dir = dir or "bi"
  statsType = statsType or "qos"
  interval = interval or 1

  bearer_stats_passed = 0
  bearer_stats_failed = 0

  ue_num = ue_end - ue_start + 1

  print_info("MULTI UE_STATS starting loop from "..ue_start.." to "..ue_end.." with interval of "..tonumber(interval).." seconds...")
  for ue_id = ue_start,ue_end do

    -- exec ue_stats command
    exec("bearer_stats ue="..ue_id.." id="..bearer.." dir="..dir.." type="..statsType)

    bearer_stats_passed = bearer_stats_passed + 1

    if tonumber(interval) ~= 0 then
      sleep(tonumber(interval))
    end
  end

  if bearer_stats_passed == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI BEARER_STATS loop completed: Result="..result)
  return result
end


--******************************************************************
--  test_function
--******************************************************************
function test_function()
  print_text("test_function")

end


--*******************************************************************
-- validate_bearer_is_active function
--*******************************************************************
function validate_bearer_is_active(ue_id, bearer_id)
  print("debug point: validate_bearer_is_active")
  local result = "FAILED"
  local ue_ = ue(ue_id)
  if(ue_ == nil)
  then
    print("Specified ue id is not configured using set_ue command")
    result = "FAILED"
    print(result)
    return result
  end

  local bearer_ = ue_:bearer(bearer_id)
  if(bearer)
  then
    print("bearer_state ="..bearer.state_tostring(bearer_.state).."in ue="..tostring(ue_))
    if(bearer_.state == bearer.ON or bearer_.state == bearer.LOAD)
    then
      result = "PASSED"
    else
      result = "FAILED"
    end
  else
    print("No bearer"..tostring(bearer_).."in ue="..tostring(ue_))
    result = "FAILED"

  end
  print(result)
  return result
end


--*******************************************************************
-- validate_cell_is_valid function
--*******************************************************************
function validate_cell_is_valid(enb_id, cell_id)
  print("debug point: validate_cell_is_valid")
  local result = "FAILED"
  local cell_ = enb(enb_id):cell(cell_id)
  if cell_.channel.isvalid then
    print("isvalid")
    result = "PASSED"
  else
    print("not isvalid")
    result = "FAILED"
  end
  print(" channel:")
  print(" band="..cell_.channel.band)
  print(" dl_bw="..bandwidth.tostring(cell_.channel.dl_bw))
  print(" ul_bw="..bandwidth.tostring(cell_.channel.ul_bw))
  print(" dl_freq="..cell_.channel.dl_freq)
  print(" ul_freq="..cell_.channel.ul_freq)
  print(" dl_earfcn="..cell_.channel.dl_earfcn)
  print(" ul_earfcn="..cell_.channel.ul_earfcn)
  print(result)
  return result
end


--*******************************************************************
-- detach_all_ue function
--*******************************************************************
function detach_all_ue(interval, timeout)
  timeout = timeout or "2"
  interval = interval or "0.1"
  print_info("Detach all ue with interval of "..tonumber(interval).." seconds...")
  for ue_id in ue.ids_with_state(ue.ON+ue.IDLE) do
    ue(ue_id):detach(5)
    print_info("ue [ "..tonumber(ue_id).." ] detach over.")
    if tonumber(interval) ~= 0 then
      sleep(tonumber(interval))
    end
  end

  if ue.get_number_of_active() == 0 and ue.get_number_of_idle() == 0 then
    result = "PASSED"
  else
    for i= 1, timeout do
      print_info("sleep 1s and check detach again.")
      sleep(1)
      if ue.get_number_of_active() == 0 and ue.get_number_of_idle() == 0 then
        result = "PASSED"
        break
      else
        result = "FAILED"
      end
    end
  end
  print_text("DETACH_ALL_UE completed: Result="..result)
  return result
end


function validate_has_ib(enb_id,cell_id,sib_id)
  local sib = rrc.get_ib(enb_id,cell_id,sib_id)
  if sib == nil then
    print("enb:"..enb_id.." cell:"..cell_id.. " has not sib"..sib_id)
  else
    print("enb:"..enb_id.." cell:"..cell_id.." sib"..sib_id.." received")
  end
end

function wait_until_sib1_and_sib2_received(enb_id, cell_id, nb)
  local uec_1 = uec(1)
  if uec_1.state == uec_state.ACTIVE then
    local sib1 = nil
    local sib2 = nil
    nb = nb or false
    if nb == false then
      sib1 = rrc.get_ib(enb_id, cell_id, rrc.CELL_SIB1)
      sib2 = rrc.get_ib(enb_id, cell_id, rrc.CELL_SIB2)
    else
      sib1 = rrc.get_ib(enb_id, cell_id, rrc.CELL_SIB1_NB)
      sib2 = rrc.get_ib(enb_id, cell_id, rrc.CELL_SIB2_NB)
    end
    if sib1 and sib2 then
      print "PASSED"
      return
    else
      print "FAILED"
      return
    end
  end
end

--******************************************************************
--  ue_ul_power_control function
--******************************************************************
function modify_pathloss(ue_id, pathloss)
  local ue_ = ue(ue_id)
  ue_ul_pc_param_ = ue_:get_ul_pc_params(applicable_cell.CELL_CURRENT)
  print("get lu pc params:"..tostring(ue_ul_pc_param_).."\n")
  print("now pathloss_:".. tostring(ue_ul_pc_param_.dl_pathloss).."\n")
  ue_ul_pc_param_.dl_pathloss = pathloss
  ue_:set_ul_pc_params(applicable_cell.CELL_CURRENT,ue_ul_pc_param_)
  sleep(0.5)
  new_ue_ul_pc_param_ = ue_:get_ul_pc_params(applicable_cell.CELL_CURRENT)
  print("new get lu pc params:"..tostring(new_ue_ul_pc_param_).."\n")
  new_pathloss_ = new_ue_ul_pc_param_.dl_pathloss
  print_info("new pathloss_:".. tostring(new_pathloss_).."\n")
  if new_pathloss_ == pathloss then
    print "PASSED"
    return
  else
    print "FAILED"
    return
  end
end

--******************************************************************
--  mbms_start_session function
--******************************************************************
function mbms_start_session(...)
    local args = {...}
    print(tostring(args))
    mbms_params_ = mbms_params()
    for _, l in ipairs(args) do
        print_text(tostring(l))
        local paramsline = l
        for param in string.gmatch(paramsline, "%S+") do
          print_text(param)
      if string.find(param, "=") then
            for k, v in string.gmatch(param, "(%w+)=(%w+)") do
        -- analyse the parameters for mbms_params
        k = string.lower(k)
        if k == "m1_dst_addr" then mbms_params_.m1_dst_addr = v
            elseif k == "m1_teid" then mbms_params_.mi_teid = v
            elseif k == "dsp_ip" then mbms_params_.dst_ip = v
            elseif k == "dsp_ip" then mbms_params_.dst_ip = v
            elseif k == "dsp_port" then mbms_params_.dst_port = v
            elseif k == "duration" then mbms_params_.duration = v
            elseif k == "gbr" then mbms_params_.gbr = v
            elseif k == "m1_teid" then mbms_params_.mi_teid = v
            elseif k == "max_delay" then mbms_params_.max_delay = v
            elseif k == "mbmsgw_trf_tun_ip" then mbms_params_.mbmsgw_trf_tun_ip = v
            elseif k == "qci" then mbms_params_.qci = v
            elseif k == "sai" then mbms_params_.sai = v
            elseif k == "sync_period" then mbms_params_.sync_period = v
            elseif k == "sync_seq" then mbms_params_.sync_seq = v
            elseif k == "time_correction_period" then mbms_params_.time_correction_period = v
            elseif k == "tmgi" then mbms_params_.tmgi = tmgi(v)
            elseif k == "trf_adapt_scheme" then mbms_params_.trf_adapt_scheme = v
            elseif k == "trf_start_delay" then mbms_params_.trf_start_delay = v
        end
            end
      end
      end
    end

  local id=1
  local mbmsgw_id = 1
  mbmsgw_=mbmsgw(mbmsgw_id)
  local start_status_ = mbmsgw_:mbms_session_start(mbms_params_)
  print("Status of session_start command: "..mbmsgw.mbms_session_start_status_tostring(start_status_.status))
  return start_status_
end

--******************************************************************
--  mbms_stop_session function
--******************************************************************
function mbms_stop_session(tmgistr)
  local tmgi_ = tmgi(tmgistr)
  local stop_status_ = mbmsgw_:mbms_session_stop(tmgi_)
  print("Status of session_stop command: "..mbmsgw.mbms_session_stop_status_tostring(stop_status_.status))
  return stop_status_
end

--******************************************************************
--  mbms_update_session function
--******************************************************************
function mbms_update_session(mbms_, sai, tmgistr)
  update_param = mbms_session_update_params()
  update_param.sai = sai
  update_param.tmgi = tmgi(tmgistr)
  local res = mbms_:mbms_session_update(update_param)
  local status = res.status
  return status
end

--******************************************************************
--  igmp_query function
--******************************************************************
function igmp_query(mbms_, multicast_ip, enb_id, send_general_query, timeout)
  local rsp = mbms_:igmp_query(multicast_ip, enb_id, send_general_query, timeout)
  print("Result: "..rsp.specific_query_status)
  if rsp.specific_query_status == igmpv3_query_rsp_status.UNDEFINED then
          print("Status: UNDEFINED")
  elseif rsp.specific_query_status == igmpv3_query_rsp_status.SUCCESS then
          print("Status: SUCCESS")
  elseif rsp.specific_query_status == igmpv3_query_rsp_status.NO_RESPONSE then
          print("Status: NO_RESPONSE")
  elseif rsp.specific_query_status == igmpv3_query_rsp_status.NO_SUBSCRIPTION_TO_MULTICAST_IP then
          print("Status: NO SUBSCRIPTION TO MULTICAST")
  elseif rsp.specific_query_status == igmpv3_query_rsp_status.NO_MBMS_IP_IN_SOURCE_LIST then
          print("Status: NO MBMS IP IN SOURCE LIST")
  elseif rsp.specific_query_status == igmpv3_query_rsp_status.FAILURE_WRONG_TMGI then
          print("Status: WRONG TMGI")
  elseif rsp.specific_query_status == igmpv3_query_rsp_status.FAILURE_DUPLICATE_QUERY then
          print("Status: DUPLICATE QUERY")
  elseif rsp.specific_query_status == igmpv3_query_rsp_status.FAILURE_IGMP_LINK_ERROR then
          print("Status: IGMP_LINK_ERROR")
  end
  return rsp.specific_query_status
end

--******************************************************************
--  ue_ho function
--******************************************************************
function ue_handover(ue_id, enb_id, cell_id, timeout)
  local ue_ = ue(ue_id)
  print("Before HO,UE State: "..ue.state_tostring(ue_.state))
  if(ue_.state ~= ue.ON) then
    print "FAILED"
    return
  else
    local ho_target_ = ho_target(enb_id, cell_id)
    if ue_:ho(ho_target_, timeout)then
      print("HO is OK")
    else
      print("HO is FAILED")
      return
    end
    print("After HO, UE State: "..ue.state_tostring(ue_.state))
    if ue_.ho_info.ho_status.is_valid then
      print("UE_HO: UE" .. ue_.id .. ", ho info is " .. tostring( ue_.ho_info ))
      print("PASSED")
      return
    else
      print("UE_HO: UE" .. ue_.id .. ", ho info is NOT valid.")
      print("FAILED")
      return
    end
  end
end

--******************************************************************
--  get_ue_status function
--******************************************************************
function get_ue_states(ue_id)
  local ue_ = ue(ue_id)
  if ue_ then
    print('Ue_'..ue_id.." is "..ue.state_tostring(ue_.state))
    print("GET_PASSED")
  end
end
--******************************************************************
--   get cell statistics data function
--******************************************************************
function get_cell_states(cell_id, direction)
    local cell_ = enb(1):cell(cell_id)
    local dir_ = nil
    local traffic_ = nil
  local idx_ul_ = nil
  idx_ul_ = string.find(direction, "ul")
    if idx_ul_ and idx_ul_ >= 0 then
        dir_ = dir.UL
        traffic_ = cell_stats.SCH
    else
        dir_ = dir.DL
        traffic_ = cell_stats.TRAFFIC_DATA_L3
    end
    local value = cell_:get_stats(dir_, traffic_)
    print("value"..tostring(value))
    print("GET CELL STATES PASSED!")
    return value
end

--******************************************************************
--   get bearer info function
--******************************************************************
function get_bearer_info(ue_id)
    local ue_ = ue(ue_id)
    local info = {}
    for b_ in ue_:bearers(bearer.ON) do
        local uec_info = b_:get_info(initiator.UE)
        print("uec_info="..tostring(uec_info))
        info[b_.id] = tostring(uec_info)
    end
    for b_  in ue_:bearers(bearer.LOAD) do  
        local uec_info = b_:get_info(initiator.UE)
        print("uec_info="..tostring(uec_info))
        info[b_.id] = tostring(uec_info)
    end
    print("PASSED")
    return info
end

--******************************************************************
--   get ue stats function
--******************************************************************
function get_ue_stats(ue_id, direction, stats_type)
    local ue_ = ue(ue_id)
    local info = {}   
    local dir_ = nil
    local ue_statistics_ = nil
    if direction == "ul" then dir_ = dir.UL
    else dir_ = dir.DL
    end
    if stats_type == "LAST_ALLOC" then ue_statistics_ = ue_stats.LAST_ALLOC
    elseif stats_type == "SCH" then ue_statistics_ = ue_stats.SCH
    elseif stats_type == "HARQ" then ue_statistics_ = ue_stats.HARQ
    elseif stats_type == "RLC" then ue_statistics_ = ue_stats.RLC
    elseif stats_type == "MAC" then ue_statistics_ = ue_stats.MAC
    else ue_statistics_ = ue_stats.SCHEDULER
    end
    print("get_ue_stats ue_id="..ue_id.." direction="..direction.." stats_type="..stats_type.." :")
    local ue_stats_ = ue_:get_stats(dir_, ue_statistics_)    
    print("ue_stats is:\n"..tostring(ue_stats_))
    print("PASSED")
    return tostring(ue_stats_)
end

--******************************************************************
--   ue rrc reestablish
--******************************************************************
function ue_rrc_reestablish(ue_id, cell_id, enb_id)
    local ue_ = ue(ue_id)
    cell_id = cell_id or 1
    enb_id = enb_id or 1
    local info = ue_:reestablishment(ue_id, cell_id, enb_id)
    print(tostring(info))
    return tostring(info)
end

--******************************************************************
--   get scell stats function
--******************************************************************
function get_scell_stats(ue_id,scell_id)
    local ue_info = ue(ue_id):get_info(initiator.UE,1)
    exec("ue_disp id="..ue_id.." at=ue type=general_info")
    print("scells: "..ue_info.scells_num.." elems")
    if ue_info.scells_num == 0 then print "scell number is 0, FAILED"
    else
        print("ue_info.scells:"..tostring(ue_info.scell(ue_info,scell_id)))
        print "PASSED"
    end
end



  
--******************************************************************
-- 用指定字符或字符串分割输入字符串，返回包含分割结果的数组  
--@function [parent=#string] split  
-- @param string input 输入字符串  
-- @return array#array  包含分割结果的数组  
--******************************************************************
function string.split(input, delimiter)  
    input = tostring(input)  
    delimiter = tostring(delimiter)  
    if (delimiter=='') then return false end  
    local pos,arr = 0, {}  
    -- for each divider found  
    for st,sp in function() return string.find(input, delimiter, pos, true) end do  
        table.insert(arr, string.sub(input, pos, st - 1))  
        pos = sp + 1  
    end  
    table.insert(arr, string.sub(input, pos))  
    return arr  
end  


--******************************************************************
--  mue_group_attach function
--******************************************************************
function mue_group_attach(ue_group_in,interval,timeout,retry,selected_plmn,emergency)
  interval = interval or "0.1"
  wait_confirmation = wait_confirmation or false
  timeout = timeout or 30
  retry = retry or false
  retry_interval = retry_interval or interval
  ue_group =string.split(ue_group_in,':')
  ue_num = #(ue_group) 
  print_info("ue_num = "..ue_num)
  params_ = ue_attach_params()
	for i= 1, ue_num do
	    print_info("ue_num["..i.."] = "..ue_group[i])
	end

    default_emergency_cm_bearer_id=9
  if tonumber(selected_plmn) ~= 0 then        
    params_:selected_plmn(selected_plmn)
    print("params: "..tostring(params_))
  end
  if wait_confirmation == true then
    ue_attach_timeout = 0.5
  else
    ue_attach_timeout = 30
  end
  stop_on_failure = false
  if retry == false then
    stop_on_failure = true
  end

  ue_result = {}
  ue_failed = 0
  ue_attached = 0
  print_info("MULTI GROUP UE_ATTACH starting with interval of "..tonumber(interval).." seconds...")
  for i= 1, ue_num do
	ue_id = tonumber(ue_group[i])
	print_info("  UE_ATTACH for UE "..ue_id)
    ue_ = ue(ue_id)
    print_info(" current state="..ue_.state.." "..ue.state_tostring(ue_.state))
    if ue_.state == ue.OFF then
      if tonumber(emergency) ~= 0 then
          print("emergency on")
          params_.emergency=true
          if (ue_:is_emergency_pdn_configured()) then
            if (ue_:is_emergency_pdn_configured(ue.PDN_TYPE_IPV4)) then
              print("Emergency PDN_TYPE_IPV4 is configured\n")
            end
            if (ue_:bearer(default_emergency_cm_bearer_id).cfg.is_emergency) then
              print("'ue_:bearer(default_emergency_cm_bearer_id).cfg.is_emergency' returned true\n")
            end
            if ue_:attach(params_, tonumber(timeout)) then
              print("ue_:attach(params_, tonumber(timeout)) for emergency call returned true")
              ue_info_ue_ = ue_:get_info(ue.INITIATED_BY_UE)
              print("UE info at UEC:\n-------------------\n" ..tostring(ue_info_ue_))    
              ue_info_mme_ = ue_:get_info(ue.INITIATED_BY_MME)
              print("\nUE info at MME:\n-------------------\n" ..tostring(ue_info_mme_)) 
              print("'attach_type' at UE is:" ..ue_info_ue_.attach_type)
              if (ue_info_ue_.attach_type==nas_attach_type.EPS_EMERGENCY_ATTACH) then
                print("'attach_type' at UE is: nas_attach_type.EPS_EMERGENCY_ATTACH. emergency_pgw_id=" ..ue_info_ue_.emergency_pgw_id)
              end 
              print("'attach_type' at MME is:" ..ue_info_mme_.attach_type)
              if (ue_info_mme_.attach_type==nas_attach_type.EPS_EMERGENCY_ATTACH) then
                print("'attach_type' at MME is: nas_attach_type.EPS_EMERGENCY_ATTACH. emergency_pgw_id=" ..ue_info_mme_.emergency_pgw_id)
              end
            else
              print("ue_:attach(params_, tonumber(timeout)) for emergency call returned false")
            end
          else
            print("'ue_:is_emergency_pdn_configured()' returned false for UE " ..ue_.id) 
          end
      else
          ue_:attach(params_, tonumber(timeout))
      end
      --ue_attach(ue_,tonumber(timeout))
      if ue_.state == ue.ACTIVE  then
        ue_result[ue_id-1] = true
        ue_attached = ue_attached +1
        --print_info("  UE"..ue_id.." attach passed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
      else
        ue_result[ue_id-1] = false
        ue_failed = ue_failed +1
        print_info("  UE"..ue_id.." attach failed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
        exec("ue_disp id="..ue_id)
        if stop_on_failure then
          print_warn("MULTI UE_ATTACH aborting script execution after ue_attach failure!!!")
          break
        end
      end
    else
      ue_attached = ue_attached +1
      ue_result[ue_id-1] = true
      if ue_.state == ue.ON or ue_.state == ue.ACTIVE then
        print_warn("  UE"..ue_id.." is already attached, and state="..ue_.state.." "..ue.state_tostring(ue_.state))
      elseif ue_.state == ue.IDLE then
        print_warn("  UE"..ue_id.." is already attached, and ue.state="..ue_.state.." IDLE")
      else
        print_err("  UE"..ue_id.." is not ready for the attach, and state="..ue_.state.." "..ue.state_tostring(ue_.state))
      end
    end
    --print_info("sleep interval = "..tonumber(interval))
    if tonumber(interval) ~= 0 then
      sleep(tonumber(interval))
    end
  end

  if retry then
    -- re-attach UE if first attach was not successful
	for i= 1, ue_num do
		ue_id = tonumber(ue_group[i])
      if ue_result[ue_id-1] == false then
        ue_ = ue(ue_id)
        if ue_.state ~= ue.ACTIVE  then
          print_warn("  UE_ATTACH: retry for ue_id="..ue_id.." with state="..ue_.state.." "..ue.state_tostring(ue_.state))
          exec("ue_kill id="..ue_id)
          if tonumber(retry_interval) ~= 0 then
            sleep(tonumber(retry_interval))
          end
          if ue_attach(ue_,tonumber(timeout)) then
            ue_result[ue_id-1] = true
            ue_attached = ue_attached +1
            print_info("  UE"..ue_id.." attach passed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
          else
            ue_result[ue_id-1] = false
            ue_failed = ue_failed +1
            print_info("  UE"..ue_id.." attach failed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
            print_info("  executing ue_kill for "..ue_id.." and skipping the UE attach!!!!")
            exec("ue_kill id="..ue_id)
          end
        else
          --ue_id is already active
          ue_result[ue_id-1] = true
          ue_attached = ue_attached +1
          ue_failed = ue_failed -1
        end
      end
    end
  end

  if ue_attached == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI UE_ATTACH loop completed: Result="..result.." #UEs_Total="..ue_num.."; #UEs_attached="..ue_attached..";  #UEs_failed="..ue_failed)
  return result
end


--******************************************************************
--  mue_group_detach function
--******************************************************************
function mue_group_detach(ue_group_in, interval)
  ue_failed = 0
  ue_detached = 0
  interval = interval or "0.1"
  
  ue_group =string.split(ue_group_in,':')
  ue_num = #(ue_group) 
  print_info("ue_num = "..ue_num)
	for i= 1, ue_num do
	    print_info("ue_num["..i.."] = "..ue_group[i])
	end
  print_info("MULTI Group UE_DETACH starting with interval of "..tonumber(interval).." seconds...")
  for i= 1, ue_num do
	ue_id = tonumber(ue_group[i])
    ue_ = ue(ue_id)
    --print_info("  UE_DETACH for UE"..ue_id.." current state="..ue_.state.." "..ue.state_tostring(ue_.state))
    if ue_.state ~= ue.OFF then
      if ue_detach(ue_,ue.INITIATED_BY_UE) then
        ue_detached = ue_detached +1
        --print_info("  UE"..ue_id.." detach passed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
      else
        ue_failed = ue_failed +1
        print_info("  UE"..ue_id.." detach failed -> state="..ue_.state.." "..ue.state_tostring(ue_.state))
        print_info("  executing ue_kill for "..ue_id)
        exec("ue_disp id="..ue_id)
        exec("ue_kill id="..ue_id)
      end
    else
      print_warn("  UE"..ue_id.." is already detached, and ue.state="..ue_.state.." "..ue.state_tostring(ue_.state))
    end
    if tonumber(interval) ~= 0 then
      sleep(tonumber(interval))
    end
  end

  if ue_detached == ue_num then
    result = "PASSED"
  else
    result = "FAILED"
  end
  print_text("MULTI UE_DETACH loop completed: Result="..result.." #UEs_Total="..ue_num.."; #UEs_detached="..ue_detached..";  #UEs_failed="..ue_failed)
  return result
end

--*****************************************************************************
--[[[
.. function:: get_scell_id(ue_id, direction, stats_type, scell_number, stats_attribute)

]]--
function get_scell_id(ue_id, scell_index)
    local info = ue(tonumber(ue_id)):get_info(initiator.UE)
    local scell_=info:scell(tonumber(scell_index))
    local scell_id
    local result
    if scell_ and scell_.state ~= ue_scell_state.INIT then
       scell_id = scell_.cell_id
       result = "PASSED"
    else
       scell_id = "nil"
       result = "FAILED"
       print_warn("Could not fetch scell id")
    end
    print_text("get_scell_id Result="..result.." scell_id="..scell_id.." end.")
    return scell_id
end