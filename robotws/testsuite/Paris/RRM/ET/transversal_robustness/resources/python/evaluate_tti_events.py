import json
import math
import sys

persistent_data = {}
nb_slot_per_sfn = 80
error_list = []
silent_errors = {}
current_event_data = None
fifo_tti_level = 2


def set_event_data(event_data):
    global current_event_data
    current_event_data = event_data


def append_error(error):
    header = current_event_data["body"]["eventHeader"]
    error_string = f"xsfn {header['sfn']}/{header['slot']}: {error}"
    # print(error_string)
    if len(error_list) < 10:
        error_list.append(error_string)
    else:
        error_list[9] = "Other errors occured but list is full"


def check_error(locals, expression):
    if eval(expression, None, locals):
        append_error(expression)


def silent_error(reason, locals, expression):
    global silent_errors
    if eval(expression, None, locals):
        if expression not in silent_errors:
            silent_errors[expression] = 0
        silent_errors[expression] += 1


def get_xsfn(event_data):
    header = event_data["body"]["eventHeader"]
    xsfn = header["sfn"] * nb_slot_per_sfn + header["slot"]
    return xsfn


def check_slot_incrementation(context):
    previous_xsfn = get_xsfn(context["previous_event_data"])
    expected_xsfn = (previous_xsfn + 1) % (1024 * nb_slot_per_sfn)
    current_xsfn = get_xsfn(current_event_data)
    check_error(locals(), "current_xsfn != expected_xsfn")


def check_numOfEventsInFifoQueue_consistency_with_timeStampOfEventId(numOfEventsInFifoQueue):
    lastEventProcessingTimeInSlot = current_event_data["body"]["measurementInfo"]["lastEventProcessingTimeInSlot"]
    timeStampOfEventId = lastEventProcessingTimeInSlot["timeStampOfEventId"]
    if timeStampOfEventId > 30:
        check_error(locals(), 'numOfEventsInFifoQueue != 0')


def check_measurementInfoPerQueues():
    measurementInfoPerQueues = current_event_data["body"]["measurementInfo"]["measurementInfoPerQueues"]
    check_error(locals(), "len(measurementInfoPerQueues) != 4")
    for measurementInfoPerQueue in measurementInfoPerQueues:
        numOfEventsInFifoQueue = measurementInfoPerQueue["numOfEventsInFifoQueue"]
        # Action 404 check_numOfEventsInFifoQueue_consistency_with_timeStampOfEventId(numOfEventsInFifoQueue)
        if fifo_tti_level == 1:
            check_error(locals(), 'measurementInfoPerQueue["numberOfReceivedEventsInPreviousSlot"] != 0')
            check_error(locals(), 'len(measurementInfoPerQueue["numOfRemainingEventsPerAge"]) != 0')
        elif fifo_tti_level == 2:
            check_error(locals(),
                        'numOfEventsInFifoQueue != sum(measurementInfoPerQueue["numOfRemainingEventsPerAge"])')
            check_error(locals(), 'len(measurementInfoPerQueue["numOfRemainingEventsPerAge"]) != 10')
            calculated_oldestAgeInFifoQueue = 0
            calculated_numOfEventsOfOldestAgeInFifoQueue = 0
            for age in range(1, len(measurementInfoPerQueue["numOfRemainingEventsPerAge"]) + 1):
                if measurementInfoPerQueue["numOfRemainingEventsPerAge"][age - 1] != 0:
                    calculated_oldestAgeInFifoQueue = age
                    calculated_numOfEventsOfOldestAgeInFifoQueue = \
                        measurementInfoPerQueue["numOfRemainingEventsPerAge"][age - 1]
            check_error(locals(),
                        'measurementInfoPerQueue["oldestAgeInFifoQueue"] != calculated_oldestAgeInFifoQueue')
            check_error(locals(), 'measurementInfoPerQueue["numOfEventsOfOldestAgeInFifoQueue"] != ' +
                        'calculated_numOfEventsOfOldestAgeInFifoQueue')


def check_total_numberOfHits_consistency_with_measurementInfoPerQueues(context, total_numberOfHits_of_previous_slot):
    previous_event_data = context["previous_event_data"]
    previous_measurementInfoPerQueues = previous_event_data["body"]["measurementInfo"]["measurementInfoPerQueues"]
    measurementInfoPerQueues = current_event_data["body"]["measurementInfo"]["measurementInfoPerQueues"]
    total_numOfEventsInFifoQueue_at_start_of_previous_slot = 0
    total_numOfEventsInFifoQueue_at_start_of_current_slot = 0
    total_numberOfReceivedEventsInPreviousSlot = 0
    for measurementInfoPerQueue in measurementInfoPerQueues:
        total_numOfEventsInFifoQueue_at_start_of_current_slot += measurementInfoPerQueue["numOfEventsInFifoQueue"]
        total_numberOfReceivedEventsInPreviousSlot += measurementInfoPerQueue["numberOfReceivedEventsInPreviousSlot"]
    for measurementInfoPerQueue in previous_measurementInfoPerQueues:
        total_numOfEventsInFifoQueue_at_start_of_previous_slot += measurementInfoPerQueue["numOfEventsInFifoQueue"]
    check_error(locals(), 'total_numOfEventsInFifoQueue_at_start_of_current_slot != ' +
                'total_numOfEventsInFifoQueue_at_start_of_previous_slot + total_numberOfReceivedEventsInPreviousSlot' +
                ' - total_numberOfHits_of_previous_slot')


def check_mostConsumingEvents(context):
    mostConsumingEvents = current_event_data["body"]["measurementInfo"]["mostConsumingEvents"]
    if fifo_tti_level == 1:
        check_error(locals(), "len(mostConsumingEvents) != 0")
    elif fifo_tti_level == 2:
        check_error(locals(), "len(mostConsumingEvents) == 0")
        total_numberOfHits_of_previous_slot = 0
        for mostConsumingEvent in mostConsumingEvents:
            check_error(locals(), 'mostConsumingEvent["eventId"] == 0')  # Action 347
            check_error(locals(), 'mostConsumingEvent["numberOfHits"] == 0')
            check_error(locals(), 'mostConsumingEvent["varOfEventId"] > 900')
            total_numberOfHits_of_previous_slot += mostConsumingEvent["numberOfHits"]
        check_total_numberOfHits_consistency_with_measurementInfoPerQueues(context,
                                                                           total_numberOfHits_of_previous_slot)


def check_eventId_is_in_mostConsumingEvents(eventId):
    eventId_found_in_mostConsumingEvents = False
    mostConsumingEvents = current_event_data["body"]["measurementInfo"]["mostConsumingEvents"]
    for mostConsumingEvent in mostConsumingEvents:
        if mostConsumingEvent["eventId"] == eventId:
            eventId_found_in_mostConsumingEvents = True
    check_error(locals(), 'eventId_found_in_mostConsumingEvents == False')


def check_lastEventProcessingTimeInSlot():
    lastEventProcessingTimeInSlot = current_event_data["body"]["measurementInfo"]["lastEventProcessingTimeInSlot"]
    check_error(locals(), 'lastEventProcessingTimeInSlot["timeStampOfEventId"] > 125')
    if fifo_tti_level == 2:
        check_error(locals(), 'lastEventProcessingTimeInSlot["eventId"] == 0')
        check_eventId_is_in_mostConsumingEvents(lastEventProcessingTimeInSlot["eventId"])


def check_dlLoadControlDataFifoEnhancement(context):
    check_slot_incrementation(context)
    check_measurementInfoPerQueues()
    check_mostConsumingEvents(context)
    check_lastEventProcessingTimeInSlot()


def check_fifoQueueStatusIndications():
    # DTN 04/08/2025 : this function is no more called as NOOVERLOAD is no more reported in the logs
    # [CB014680-SR-C-B1_5G_L2_PS] Remove FifoQueue 2.2 (Ib60bc8a3) · Gerrit Code Review
    # according to 12460884 and 12460883 in DOORS
    #   -------------------------------------------------------------------------------------------------
    # BHR begin 30/09/2024 : key name "fifoQueueStatusIndications" replaced by "fifoQueuesInfo" and
    # "fifoQueuesInfo": [{
    #     "fifoQueueStatusValue":"NOOVERLOAD",
    #     ...
    # },{
    #     "fifoQueueStatusValue":"NOOVERLOAD",
    # },{
    # ...
    # }]
    # -------------------------------------------------------------------------------------------------
    # fifoQueueStatusIndications = current_event_data["body"]["csListInfo"]["fifoQueueStatusIndications"]   # BHR
    fifoQueuesInfo = current_event_data["body"]["csListInfo"]["fifoQueuesInfo"]
    check_error(locals(), "len(fifoQueuesInfo) != 4")
    # check_error(locals(), "fifoQueueStatusIndications[0] != 'NOOVERLOAD'")                                # BHR
    for i in range(len(fifoQueuesInfo)):
        check_error(locals(), f"fifoQueuesInfo[{i}]['fifoQueueStatusValue'] != 'NOOVERLOAD'")
    # BHR end


def store_lastSlotDelay():
    if "lastSlotDelay" not in persistent_data["dlLoadControlData"]:
        persistent_data["dlLoadControlData"]["lastSlotDelay"] = {}
    emCoreId = current_event_data["body"]["eventHeader"]["emCoreId"]
    if emCoreId not in persistent_data["dlLoadControlData"]["lastSlotDelay"]:
        persistent_data["dlLoadControlData"]["lastSlotDelay"][emCoreId] = []
    lastSlotDelay = current_event_data["body"]["measurementInfo"]["lastSlotDelay"]
    persistent_data["dlLoadControlData"]["lastSlotDelay"][emCoreId].append(lastSlotDelay)


def store_skippedUes():
    if "skippedUes" not in persistent_data["dlLoadControlData"]:
        persistent_data["dlLoadControlData"]["skippedUes"] = {}
    emCoreId = current_event_data["body"]["eventHeader"]["emCoreId"]
    if emCoreId not in persistent_data["dlLoadControlData"]["skippedUes"]:
        persistent_data["dlLoadControlData"]["skippedUes"][emCoreId] = []
    skippedUes = 0
    for onefdSchedInfo in current_event_data["body"]["fdSchedInfo"]:
        skippedUes += onefdSchedInfo["skippedUes"]
    persistent_data["dlLoadControlData"]["skippedUes"][emCoreId].append(skippedUes)


def analyze_dlLoadControlData(event_data):
    set_event_data(event_data)
    if "dlLoadControlData" not in persistent_data:
        persistent_data["dlLoadControlData"] = {}
    # commented as no more reported since [CB014680-SR-C-B1_5G_L2_PS] Remove FifoQueue 2.2
    # check_fifoQueueStatusIndications()
    store_lastSlotDelay()
    store_skippedUes()


def analyze_ulLoadControlData(event_data):
    set_event_data(event_data)
    # commented as no more reported since [CB014680-SR-C-B1_5G_L2_PS] Remove FifoQueue 2.2
    # check_fifoQueueStatusIndications()


def analyze_dlLoadControlDataFifoEnhancement(event_data):
    global persistent_data
    set_event_data(event_data)
    if "dlLoadControlDataFifoEnhancement" not in persistent_data:
        persistent_data["dlLoadControlDataFifoEnhancement"] = {}
    else:
        check_dlLoadControlDataFifoEnhancement(persistent_data["dlLoadControlDataFifoEnhancement"])
    persistent_data["dlLoadControlDataFifoEnhancement"]["previous_event_data"] = event_data


def init_global_variables(fifo_debug):
    global persistent_data
    global error_list
    global silent_errors
    global current_event_data
    global fifo_tti_level
    persistent_data = {}
    error_list = []
    silent_errors = {}
    current_event_data = None
    fifo_tti_level = int(fifo_debug)


def percentile(serie, percent):
    sorted_serie = sorted(serie)
    print(f"percentile calc - len:{len(sorted_serie)}, min:{sorted_serie[0]}, max:{sorted_serie[-1]}")
    target_idx = (len(sorted_serie) - 1) * percent
    floor_idx = math.floor(target_idx)
    ceil_idx = math.ceil(target_idx)
    if floor_idx == ceil_idx:
        return sorted_serie[int(target_idx)]
    d0 = sorted_serie[int(floor_idx)] * (ceil_idx - target_idx)
    d1 = sorted_serie[int(ceil_idx)] * (target_idx - floor_idx)
    return d0 + d1


def get_measurements():
    measurements = []
    for emCoreId in persistent_data["dlLoadControlData"]["lastSlotDelay"]:
        p95_slot_delay = percentile(persistent_data["dlLoadControlData"]["lastSlotDelay"][emCoreId], 0.95)
        measurements.append(f"slot_delay_p95[{emCoreId}]: {p95_slot_delay}")
    for emCoreId in persistent_data["dlLoadControlData"]["skippedUes"]:
        avg_skipped_ues = sum(persistent_data["dlLoadControlData"]["skippedUes"][emCoreId]) / \
                          len(persistent_data["dlLoadControlData"]["skippedUes"][emCoreId])
        measurements.append(f"avg_skipped_ues[{emCoreId}]: {avg_skipped_ues}")
    return measurements


def evaluate_tti_events(tti_file_name, fifo_debug):
    init_global_variables(fifo_debug)
    is_fifo_enhancement = (int(fifo_debug) >= 1)

    measurements = []
    if "FR2" not in tti_file_name:
        return error_list, measurements

    tti_file = open(tti_file_name, "r")
    tti_data = json.load(tti_file)
    tti_file.close()

    presence_dlLoadControlData = False
    presence_ulLoadControlData = False
    presence_dlLoadControlDataFifoEnhancement = False
    presence_ulLoadControlDataFifoEnhancement = False

    for event in tti_data["events"]:
        if "dlLoadControlData" in event:
            presence_dlLoadControlData = True
            analyze_dlLoadControlData(event["dlLoadControlData"])

        if "ulLoadControlData" in event:
            presence_ulLoadControlData = True
            analyze_ulLoadControlData(event["ulLoadControlData"])

        if "dlLoadControlDataFifoEnhancement" in event:
            presence_dlLoadControlDataFifoEnhancement = True
            analyze_dlLoadControlDataFifoEnhancement(event["dlLoadControlDataFifoEnhancement"])

        if "ulLoadControlDataFifoEnhancement" in event:
            presence_ulLoadControlDataFifoEnhancement = True

    check_error(locals(), "presence_dlLoadControlData != True")
    check_error(locals(), "presence_ulLoadControlData != True")
    check_error(locals(), "presence_dlLoadControlDataFifoEnhancement != is_fifo_enhancement")
    check_error(locals(), "presence_ulLoadControlDataFifoEnhancement != False")

    measurements = get_measurements()

    print(f"measurements: {measurements}")
    print(f"silent_errors: {silent_errors}")
    print(f"error_list: {error_list}")

    return error_list, measurements


if __name__ == '__main__':
    evaluate_tti_events(sys.argv[1], sys.argv[2])
