try:
    import tti_events
except ModuleNotFoundError:
    from . import tti_events
import datetime
import logging
import sys
import traceback
from collections import defaultdict

logging.basicConfig(filename='tti_extractor_framework.log', level=logging.DEBUG)


class TTITraceDecoder:
    def __init__(self, extracted_tti_trace, dict_events_to_be_extracted, gnb_build, useMultiDecoder):
        self.frameduration_in_ms = 10
        self.gnb_branch = self.determine_gnb_branch(gnb_build)
        self.dict_event_object = {}
        self.rnti_sorted_tti_extract = {}
        self.event_extract_manager(dict_events_to_be_extracted, extracted_tti_trace, self.gnb_branch, useMultiDecoder)
        self.fuse_dictionaries()

    def event_extract_manager(self, dict_events_to_be_extracted, extracted_tti_trace, gnb_branch, useMultiDecoder):
        for event in dict_events_to_be_extracted:
            self.create_event_object(event_name=event, events=extracted_tti_trace,
                                     extract_contents=dict_events_to_be_extracted[event],
                                     gnb_branch=gnb_branch, useMultiDecoder=useMultiDecoder)

    def create_event_object(self, event_name, events, extract_contents, gnb_branch, useMultiDecoder):
        event_obj = EventExtract(event_name, events, extract_contents, gnb_branch, useMultiDecoder)
        self.dict_event_object[event_name] = event_obj

    def fuse_dictionaries(self):
        for key_event, value in self.dict_event_object.items():
            keys_rnti = value.rnti_sorted_tti_extract.keys()
            rnti_content_dict = {}
            for rnti in keys_rnti:
                try:
                    rnti_content = ((value.rnti_sorted_tti_extract[rnti]).get_extracted_content())[key_event]
                    rnti_content_dict[rnti] = rnti_content
                except KeyError:
                    print("Event %s Not Found for RNTI %s", key_event, rnti)
            self.rnti_sorted_tti_extract[key_event] = rnti_content_dict

    def retrieve_events(self, events):
        return (self.rnti_sorted_tti_extract[events])

    def retrieve_all_events(self):
        return (self.rnti_sorted_tti_extract)

    def determine_gnb_branch(self, gnb_build):
        if "SBTS22R3" in gnb_build:
            return 'Other'
        else:
            return 'Master'


class EventExtract:
    def __init__(self, event_name, events, extract_contents, gnb_branch, useMultiDecoder):
        self.event_name = event_name
        self.paths = tti_events.event_discriminator_defn[gnb_branch][self.event_name]
        self.rnti_sorted_tti_extract = {}
        self.extracted_contents = []
        self.time = defaultdict(list)
        self.list_of_rnti = []
        self.slot_duration_uS = None
        self.num_slots_per_frame = None
        self.GenDictOfAttribs(events=events, extract_contents=extract_contents, useMultiDecoder=useMultiDecoder)

    def getTimeFromTimeStamp(self, event):
        time = {}
        year = event.data['utcTimestamp']['years']
        month = event.data['utcTimestamp']['months']
        day = event.data['utcTimestamp']['days']
        hour = event.data['utcTimestamp']['hours']
        minn = event.data['utcTimestamp']['minutes']
        sec = event.data['utcTimestamp']['seconds']
        microsec = event.data['utcTimestamp']['microSeconds']
        slotduration = event.data['slotDurationUs']
        time['UTCTime'] = datetime.datetime(year=year, month=month, day=day, hour=hour,
                                            minute=minn, second=sec, microsecond=microsec)
        try:
            time['SFN'] = event.data['eventHeader']['onAirTime']['sfn']
            time['SLOT'] = event.data['eventHeader']['onAirTime']['slot']
        except KeyError as e:
            logging.error("The structure of the event seems to be different than expected. "
                          "encountered KeyError: %s. Please check tti-analyzer framework.", e)
            time['SFN'] = event.data['onAirTime']['sfn']
            time['SLOT'] = event.data['onAirTime']['slot']
            traceback.print_exc()
        time['CELLID'] = event.data['eventHeader'].get('lcrId')
        if not time['CELLID']:
            time['CELLID'] = event.data['eventHeader'].get('physCellId')
        time['SLOTDURATION'] = slotduration
        return time

    def get_slotduration_set_num_slots_per_frame(self, time):
        if self.slot_duration_uS is None and int(time['SLOTDURATION']) != 0:
            self.slot_duration_uS = int(time['SLOTDURATION'])
            logging.info("Slot duration set as %suS " % int(time['SLOTDURATION']))
        elif self.slot_duration_uS is None and int(time['SLOTDURATION']) == 0:
            self.slot_duration_uS = 500
            logging.warning("Slot duration obtained from TTI Trace was 0, setting to default 500uS")
        self.num_slots_per_frame = 10000/self.slot_duration_uS

    def validate_timestamp_progression(self, last_item_timestamp, current_item_timestamp):
        if last_item_timestamp['UTCTime'] > current_item_timestamp['UTCTime']:
            logging.warning("Progressive TimeStamp validation in event utcTimestampData failed! auto-corrected")
            logging.info("Last timestamp : %s" % str(last_item_timestamp['UTCTime']))
            logging.info("Current timestamp : %s", str(current_item_timestamp['UTCTime']))
            return False
        else:
            return True

    def calculate_time_correction(self, last_item_timestamp, current_item_timestamp):
        no_of_slots = self.num_slots_per_frame
        if current_item_timestamp['SFN'] - last_item_timestamp['SFN'] >= 0:
            sfn_diff = current_item_timestamp['SFN'] - last_item_timestamp['SFN']
        else:
            sfn_diff = 1023 + current_item_timestamp['SFN'] - last_item_timestamp['SFN'] + 1
        slot_diff = (no_of_slots - 1 - current_item_timestamp['SLOT']) - (no_of_slots - current_item_timestamp['SLOT'])
        total_number_of_slots_diff = (sfn_diff * no_of_slots) + slot_diff
        total_number_of_slots_diff_in_time = total_number_of_slots_diff * current_item_timestamp['SLOTDURATION']
        time_correction = datetime.timedelta(microseconds=total_number_of_slots_diff_in_time)
        corrected_time_of_current_slot = last_item_timestamp['UTCTime'] + time_correction
        return corrected_time_of_current_slot

    def extract_contents(self, entry, extract_contents, useMultiDecoder):
        dict_contents = {}
        flag_list = False
        temp_dict_contents = {}
        for content in extract_contents:
            try:
                """extracted_discriminators = self.get_attrib(dat, self.paths[content]) -> test data"""
                extracted_discriminators = self.get_attrib(entry.data, self.paths[content])
                temp_list = []
                try:
                    if useMultiDecoder:
                        if isinstance(extracted_discriminators[0], list):
                            flag_list = True
                            for discriminator in extracted_discriminators[0]:
                                x = (discriminator[extracted_discriminators[1][0]])
                                temp_list.append(x)
                    else:
                        if isinstance(extracted_discriminators[0], list):
                            flag_list = True
                            for discriminator in extracted_discriminators[0]:
                                if discriminator is not None:
                                    x = (discriminator[extracted_discriminators[1][0]])
                                    temp_list.append(x)
                        if sys.version_info.major == 2:
                            if isinstance(extracted_discriminators, unicode):
                                dict_contents[content] = extracted_discriminators
                        if sys.version_info.major == 3:
                            if isinstance(extracted_discriminators, str):
                                dict_contents[content] = extracted_discriminators
                except TypeError:
                    dict_contents[content] = extracted_discriminators
                    temp_list.append(dict_contents[content])
            except KeyError:
                print("Info element %s not present in Event %s, check extractor if IEs are correctly configured"
                      % (content, entry.type))
            temp_dict_contents[content] = temp_list
            """Handle empty temp_list"""
            self.handle_empty_temp_list(dict_contents, temp_dict_contents, flag_list)
        try:
            """time[-1] will send the latest timestamp reterived"""
            self.add_event_to_fitered_dictionary(dict_contents)
        except KeyError:
            len_of_data = len(temp_dict_contents['RNTI'])
            list_of_temp_events = []
            # Populate Data
            for itr in range(0, len_of_data):
                temp_dict = {}
                for elem in temp_dict_contents:
                    temp_dict[elem] = temp_dict_contents[elem][itr]
                list_of_temp_events.append(temp_dict)
            """Include data into the RNTI Database. Can be removed with refactoring
            - replace with list_of_temp_events - need not be appended - directly call the method to add"""
            for dict_contents in list_of_temp_events:
                self.add_event_to_fitered_dictionary(dict_contents)

    def handle_tuple_attrib_form(self, tuple_data):
        data_to_be_extracted = tuple_data[1][0]
        data = tuple_data[0]
        for item in data:
            if item is not None:
                try:
                    return item[data_to_be_extracted]
                except KeyError:
                    logging.warning("handle_tuple_attrib_form(): Element to be extracted %s not found in %s"
                                    % (item, data_to_be_extracted))

    def determine_cells_in_tti_trace(self, events):
        cells = {}
        for entry in events:
            if entry.type == "utcTimestampData" and self.getTimeFromTimeStamp(entry)['CELLID'] not in cells:
                cell_id = self.getTimeFromTimeStamp(entry)['CELLID']
                cells[cell_id] = False
        return cells

    def record_first_event_per_cell(self, registered_events, new_data):
        cell_id = new_data['CELLID']
        if not registered_events.keys():
            registered_events[cell_id] = new_data
        elif cell_id not in registered_events.keys():
            registered_events[cell_id] = new_data
        return registered_events

    def set_initial_reference_time(self, events):
        cells_in_tti_trace = self.determine_cells_in_tti_trace(events)
        first_event_itr_num = None
        all_cell_time_stamps_found = False
        all_cell_first_event = False
        first_event_cell = {}
        timeref_sfn_slot_cell_id = {}
        for _, entry in enumerate(events):
            event_sfn_slot = {'SFN': None, 'SLOT': None}
            if all(cells_in_tti_trace.values()):
                all_cell_time_stamps_found = True
            if all_cell_time_stamps_found and all_cell_first_event:
                break
            if first_event_itr_num is None or (not all_cell_time_stamps_found):
                """First event not found or first reference time not found"""
                if entry.type == self.event_name and entry.type != "utcTimestampData" and not all_cell_first_event:
                    event_sfn_slot['SFN'] = self.get_attrib(entry.data, self.paths['SFN'])
                    event_sfn_slot['SLOT'] = self.get_attrib(entry.data, self.paths['SLOT'])
                    event_sfn_slot['CELLID'] = self.get_attrib(entry.data, self.paths['CELLID'])
                    if type(event_sfn_slot['SFN']) is tuple or type(event_sfn_slot['SLOT']) is tuple:
                        """This is to handle event dlHarqRxDataArray"""
                        event_sfn_slot['SFN'] = self.handle_tuple_attrib_form(event_sfn_slot['SFN'])
                        event_sfn_slot['SLOT'] = self.handle_tuple_attrib_form(event_sfn_slot['SLOT'])
                    if type(event_sfn_slot['CELLID']) is tuple:
                        """This is to handle event dlLaDeltaCqiArray"""
                        event_sfn_slot['CELLID'] = self.handle_tuple_attrib_form(event_sfn_slot['CELLID'])
                    first_event_cell = self.record_first_event_per_cell(first_event_cell, event_sfn_slot)
                    if len(first_event_cell) == len(cells_in_tti_trace):
                        all_cell_first_event = True
                elif entry.type == "utcTimestampData" and (not all_cell_time_stamps_found) and \
                        (not cells_in_tti_trace[self.getTimeFromTimeStamp(entry)['CELLID']]):
                    timeref_sfn_slot = {}
                    cell_id = self.getTimeFromTimeStamp(entry)['CELLID']
                    cells_in_tti_trace[cell_id] = True
                    timeref_sfn_slot['SFN'] = self.getTimeFromTimeStamp(entry)['SFN']
                    timeref_sfn_slot['SLOT'] = self.getTimeFromTimeStamp(entry)['SLOT']
                    timeref_sfn_slot['UTCTime'] = self.getTimeFromTimeStamp(entry)['UTCTime']
                    timeref_sfn_slot['SLOTDURATION'] = self.getTimeFromTimeStamp(entry)['SLOTDURATION']
                    timeref_sfn_slot['CELLID'] = cell_id
                    if cells_in_tti_trace[cell_id]:
                        timeref_sfn_slot_cell_id[cell_id] = timeref_sfn_slot
            else:
                break
        for cell in first_event_cell:
            timeref_sfn_slot = timeref_sfn_slot_cell_id[cell]
            event_sfn_slot = first_event_cell[cell]
            self.generate_calculated_time_stamp(timeref_sfn_slot, event_sfn_slot)

    def generate_calculated_time_stamp(self, timeref_sfn_slot, event_sfn_slot):
        if None not in event_sfn_slot.values():
            SFN_diff = self.calculateDifferenceWithTimeStamp(timeref_sfn_slot['SFN'], event_sfn_slot['SFN'])
            if SFN_diff >= 0:
                if int(timeref_sfn_slot['SLOTDURATION']) == 0:
                    timeref_sfn_slot['SLOTDURATION'] = 500
                    logging.warning("Setting Slot duration to 500uS as reference utcTimeStampData had value 0")
                time_diff_to_slot_0_in_time_ref = \
                    int(timeref_sfn_slot['SLOTDURATION']) * (int(timeref_sfn_slot['SLOT']))
                time_obj_at_slot_0_ref_sfn = \
                    timeref_sfn_slot['UTCTime'] - datetime.timedelta(microseconds=time_diff_to_slot_0_in_time_ref)
                time_obj_diff_event_sfn_to_ref_sfn = datetime.timedelta(microseconds=(int(SFN_diff)*10000))
                time_obj_new_ref_sfn = time_obj_at_slot_0_ref_sfn - time_obj_diff_event_sfn_to_ref_sfn
                ref_time = {'SFN': event_sfn_slot['SFN'],
                            'SLOT': 0,
                            'UTCTime': time_obj_new_ref_sfn,
                            'SLOTDURATION': timeref_sfn_slot['SLOTDURATION'],
                            'CELLID': timeref_sfn_slot['CELLID']}
                self.add_time_instance(ref_time)
            else:
                return

    def add_time_instance(self, ts):
        self.time[ts['CELLID']].append(ts)

    def GenDictOfAttribs(self, events, extract_contents, useMultiDecoder):
        """ Test Data
        dat = {'nestedArray': [{'slot': 6, 'slotForProcessing': 6, 'harqSubcellId': 0, 'sfnForProcessing': 844,
                                'physCellId': 50, 'speculativeDtxAckDtx': 0, 'pucchFormat': 0,
                                'dtxThreshold': 10445, 'sfn': 844, 'dlHarqProcessIndex': 0, 'dtx': 0,
                                'dtxMetric': 25135, 'rnti': 61, 'ackNack': 0}, {'slot': 11,
                                                                                'slotForProcessing': 10,
                                                                                'harqSubcellId': 12,
                                                                                'sfnForProcessing': 873,
                                                                                'physCellId': 51,
                                                                                'speculativeDtxAckDtx': 0,
                                                                                'pucchFormat': 1,
                                                                                'dtxThreshold': 11111,
                                                                                'sfn': 888,
                                                                                'dlHarqProcessIndex': 11,
                                                                                'dtx': 1, 'dtxMetric': 26666,
                                                                                'rnti': 62, 'ackNack': 0}],
               'eventHeader': {'rnti': 0, 'onAirTime': {'sfn': 844, 'slot': 6}, 'physCellId': 65535}}"""
        previous_item = None
        self.set_initial_reference_time(events)
        for entry in events:
            if entry.type == self.event_name or entry.type == "utcTimestampData":
                if entry.type == "utcTimestampData":
                    temp_ts = self.getTimeFromTimeStamp(entry)
                    self.add_time_instance(temp_ts)
                    if previous_item is not None:
                        result = self.validate_timestamp_progression(previous_item, temp_ts)
                        if not result:
                            var_time = self.getLatestTimeStampFromCell(temp_ts['CELLID'])['UTCTime']
                            logging.info("Before correction: %s" % (var_time.strftime("%d/%m/%Y, %H:%M:%S.%f")))
                            corrected_time = self.calculate_time_correction(previous_item, temp_ts)
                            self.getLatestTimeStampFromCell(temp_ts['CELLID'])['UTCTime'] = corrected_time
                            logging.info("After correction: %s" % (corrected_time.strftime("%d/%m/%Y, %H:%M:%S.%f")))
                        previous_item = self.getLatestTimeStampFromCell(temp_ts['CELLID'])
                    elif previous_item is None:
                        previous_item = self.getLatestTimeStampFromCell(temp_ts['CELLID'])
                        self.get_slotduration_set_num_slots_per_frame(previous_item)
                        continue
                    continue
                self.extract_contents(entry, extract_contents, useMultiDecoder)

    def getLatestTimeStampFromCell(self, cell):
        try:
            return self.time[cell][-1]
        except IndexError:
            logging.warning("UTC Time Stamp not found")

    def calculateDifferenceWithTimeStamp(self, SFNinEvent, SFNinTimeStamp):
        if (int(SFNinEvent) - int(SFNinTimeStamp)) < 0:
            SFN_diff = 1023 + int(SFNinEvent) - int(SFNinTimeStamp)
        else:
            SFN_diff = int(SFNinEvent) - int(SFNinTimeStamp)
        return SFN_diff

    def slotTimeOffsetCalculator(self, timestamp, event_trace):
        SlotinTimeStamp = timestamp['SLOT']
        SlotinTrace = event_trace['SLOT']
        timeoffset_of_timestamp = int(timestamp['SLOTDURATION']) * int(SlotinTimeStamp)
        obj_timestamp_slot_offset = datetime.timedelta(microseconds=timeoffset_of_timestamp)
        timeoffset_of_slot_in_eventtrace = int(timestamp['SLOTDURATION']) * int(SlotinTrace)
        obj_eventtrace_slot_offset = datetime.timedelta(microseconds=timeoffset_of_slot_in_eventtrace)
        return timestamp['UTCTime'] - obj_timestamp_slot_offset + obj_eventtrace_slot_offset

    def computeTimeForEvents(self, dict_contents):
        latest_time_stamp_with_sfn_slot = self.getLatestTimeStampFromCell(dict_contents['CELLID'])
        SFNinTimeStamp = latest_time_stamp_with_sfn_slot['SFN']
        SFN_diff = self.calculateDifferenceWithTimeStamp(dict_contents['SFN'], SFNinTimeStamp)
        """Multiply by 1000 to convert time adjustment to microseconds"""
        sfn_time_adjustment_uS = int(SFN_diff) * 10000
        timeobj_sfn_offset = datetime.timedelta(microseconds=sfn_time_adjustment_uS)
        timeobj_slot_offset = \
            self.slotTimeOffsetCalculator(timestamp=latest_time_stamp_with_sfn_slot, event_trace=dict_contents)
        return timeobj_slot_offset + timeobj_sfn_offset

    def handle_empty_temp_list(self, dict_contents, temp_dict_contents, flag_list):
        if flag_list:
            for discriminator in dict_contents:
                if isinstance(temp_dict_contents[discriminator], list):
                    temp_dict_contents[discriminator].append(dict_contents[discriminator])

    def get_event(self):
        return self.event_name

    def get_attributes(self):
        return self.paths

    def get_dict_contents(self):
        return self.extracted_contents

    def get_rnti_sorted_tti_trace_extract(self):
        return self.rnti_sorted_tti_extract

    def get_attrib(self, entry, path):
        try:
            try:
                return self.get_attrib(entry[path[-1]], path[:-1])
            except TypeError:
                return entry, path

        except IndexError:
            return entry

    def add_event_to_fitered_dictionary(self, dict_contents):
        time = self.computeTimeForEvents(dict_contents)
        dict_contents['TIME'] = time.strftime("%d/%m/%Y, %H:%M:%S.%f")
        if dict_contents["RNTI"] in self.list_of_rnti:
            obj = self.rnti_sorted_tti_extract[dict_contents["RNTI"]]
            obj.add_extracted_content(dict_contents, self.event_name)
        else:
            self.list_of_rnti.append(dict_contents["RNTI"])
            obj = RntiSortedContent(dict_contents, self.event_name)
            self.rnti_sorted_tti_extract[dict_contents["RNTI"]] = obj


class RntiSortedContent:
    def __init__(self, content, event):
        self.rnti = content['RNTI']
        self.events = []
        self.extracted_contents = {}
        self.add_extracted_content(content, event)

    def get_rnti(self):
        return self.rnti

    def add_extracted_content(self, content, event):
        new_event = self.add_event(event)
        if new_event:
            self.extracted_contents[event] = [content]
        else:
            self.extracted_contents[event].append(content)

    def get_extracted_content(self):
        return self.extracted_contents

    def add_event(self, event):
        if event in self.events:
            return False
        else:
            self.events.append(event)
            return True
