import tti_events


class TTITraceDecoder:
    def __init__(self, extracted_tti_trace, dict_events_to_be_extracted, gnb_build, useMultiDecoder):
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
        if gnb_build.split('_')[0] == "5G19A":
            return gnb_build.split('_')[0]
        else:
            return 'Master'


class EventExtract:
    def __init__(self, event_name, events, extract_contents, gnb_branch, useMultiDecoder):
        self.event_name = event_name
        self.paths = tti_events.event_discriminator_defn[gnb_branch][self.event_name]
        self.rnti_sorted_tti_extract = {}
        self.extracted_contents = []
        self.GenDictOfAttribs(events=events, extract_contents=extract_contents, useMultiDecoder=useMultiDecoder)

    def GenDictOfAttribs(self, events, extract_contents, useMultiDecoder):
        list_of_rnti = []
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
        for entry in events:
            dict_contents = {}
            flag_list = False
            if entry.type == self.event_name:
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
                                elif isinstance(extracted_discriminators, unicode):
                                    dict_contents[content] = extracted_discriminators
                        except TypeError:
                            dict_contents[content] = extracted_discriminators
                            temp_list.append(dict_contents[content])
                    except KeyError:
                        print("Info element %s not present in Event %s, "
                              "check extractor if IEs are correctly configured"
                              % (content, entry.type))
                    temp_dict_contents[content] = temp_list
                    """Handle empty temp_list"""
                    self.handle_empty_temp_list(dict_contents, temp_dict_contents, flag_list)
                try:
                    self.add_event_to_fitered_dictionary(dict_contents, list_of_rnti)
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
                        self.add_event_to_fitered_dictionary(dict_contents, list_of_rnti)

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

    def add_event_to_fitered_dictionary(self, dict_contents, list_of_rnti):
        if dict_contents["RNTI"] in list_of_rnti:
            obj = self.rnti_sorted_tti_extract[dict_contents["RNTI"]]
            obj.add_extracted_content(dict_contents, self.event_name)
        else:
            list_of_rnti.append(dict_contents["RNTI"])
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
