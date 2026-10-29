require 'wrapper'
require 'ping'
require 'stats'
require 'ext_traffic'
require 'asn_rrc'

--*******************************************************************
-- detach_all_ue function
--*******************************************************************
function nsa_detach_all_ue(interval, timeout)
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