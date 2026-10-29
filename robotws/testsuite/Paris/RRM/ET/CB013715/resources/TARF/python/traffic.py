from logger import logger, logging
MAX_TP_PER_TRAFFIC_ID = 150


class TrafficProfile:
    def __init__(self, name):
        self._name = name
        self.traffic_protocol = None
        self._traffic_attributes = {}
        self.ue_collection = []
        self.max_traffic_id_used = 1
        self._is_alternate_udp_traffic = False
        self.default_params_udp = None
        self.default_params_rtp = None

    def __repr__(self):
        return "Traffic Profile: {0}".format(self._name)

    def identify_type_of_udp_traffic(self, traffic_profile_description):
        params_to_identify_alternate_udp = [["packets", "period_ms"], ["period_ms", "burst", "size"]]
        for params in params_to_identify_alternate_udp:
            if set(params).issubset(set(traffic_profile_description.keys())):
                self._is_alternate_udp_traffic = True
        if self._is_alternate_udp_traffic:
            logging.info("Alternate UDP Traffic detected: %s" % (self._is_alternate_udp_traffic))

    def add_default_params(self, params, default_param=0):
        for param in params:
            self.default_params_udp[param] = default_param

    def add_default_params_for_direction(self, dir, unit_x, throughput_x):
        unit = str("unit_%s" % dir)
        throughput = str("throughput_%s" % dir)
        self.add_default_params([unit], unit_x)
        self.add_default_params([throughput], throughput_x)

    def translate_direct_tp_to_template_params(self, direction, unit_x, throughput_x):
        if direction == "bi":
            for dir in ["ul", "dl"]:
                self.add_default_params_for_direction(dir, unit_x, throughput_x)
        else:
            self.add_default_params_for_direction(direction, unit_x, throughput_x)

    def construct_default_udp_params(self, traffic_profile_description):
        self.default_params_udp = {"throughput_dl": 0, "throughput_ul": 0, "unit_dl": "mbps", "unit_ul": "mbps",
                                   "traffic_type": "static", "qfi": "1", "traffic_duration_sec": 0}
        traffic_params_variants_1 = ["period_ms", "burst", "size", "packets"]
        traffic_params_variants_2 = ["period_ms", "burst", "size"]
        traffic_params_variants_3 = ["burst", "size"]
        if set(traffic_params_variants_1).issubset(traffic_profile_description.keys()):
            self.add_default_params(traffic_params_variants_1)
        elif set(traffic_params_variants_2).issubset(traffic_profile_description.keys()):
            self.add_default_params(traffic_params_variants_2)
        elif set(traffic_params_variants_3).issubset(traffic_profile_description.keys()):
            self.add_default_params(traffic_params_variants_3)
        """Remove template specific parameters for throughput if user has defined required throughput params
        like direction and throughput in the WTS accepted form, for e.g. if the user defines custom params like
        mbps:300 / kbps:250 that define the throughput or alternate forms of throughput definitions using params like
        period_ms, burst, size and packets"""
        direct_tp_defined_in_traffic_profile =\
            (list(set(["kbps", "mbps", "gbps"]).intersection(set(traffic_profile_description.keys()))))
        if len(direct_tp_defined_in_traffic_profile):
            tp = traffic_profile_description.get(direct_tp_defined_in_traffic_profile[0])
            if traffic_profile_description.get("direction"):
                self.default_params_udp["direction"] = traffic_profile_description.get("direction")
                if self.default_params_udp["direction"] == "ul":
                    self.translate_direct_tp_to_template_params(direction="ul",
                                                                unit_x=direct_tp_defined_in_traffic_profile[0],
                                                                throughput_x=tp)
                elif self.default_params_udp["direction"] == "dl":
                    self.translate_direct_tp_to_template_params(direction="dl",
                                                                unit_x=direct_tp_defined_in_traffic_profile[0],
                                                                throughput_x=tp)
            else:
                self.default_params_udp["direction"] = "bi"
                self.translate_direct_tp_to_template_params(direction="bi",
                                                            unit_x=direct_tp_defined_in_traffic_profile[0],
                                                            throughput_x=tp)
                logging.warning("param direction is not specified in traffic profile : %s "
                                " direction will default to bi" % (self._name))
            self.remove_keys_from_dict(direct_tp_defined_in_traffic_profile, traffic_profile_description)
            if traffic_profile_description.get("traffic_duration_sec"):
                self.default_params_udp["traffic_duration_sec"] =\
                    traffic_profile_description.get("traffic_duration_sec")
        if self._is_alternate_udp_traffic:
            remove_params = ["throughput_dl", "throughput_ul", "unit_dl", "unit_ul"]
            if traffic_profile_description.get("direction"):
                self.default_params_udp["direction"] = traffic_profile_description.get("direction")
            else:
                self.default_params_udp["direction"] = "bi"
                logging.warning("param direction is not specified in traffic profile : %s "
                                " direction will default to bi" % (self._name))
            self.remove_keys_from_dict(remove_params, traffic_profile_description)
            self.remove_keys_from_dict(remove_params, self.default_params_udp, log_flag=False)
        """Packets and traffic_duration_sec are incompatible with each other as they both represent the duration
        of traffic, therefore only one of them can be used. In case packets is defined by the user in the traffic
        profile then traffic_duration_sec will be ignored and only packets will be considered"""
        if set(["packets", "traffic_duration_sec"]).issubset(traffic_profile_description.keys()):
            self.remove_keys_from_dict(["traffic_duration_sec"], self.default_params_udp)
            self.remove_keys_from_dict(["traffic_duration_sec"], traffic_profile_description)
            logging.warning("Traffic profile %s incorrectly configured! %s and %s are not compatible with each other"
                            " traffic_duration_sec will be ignored"
                            % (self.name, "traffic_duration_sec", "packets"))

    def remove_keys_from_dict(self, keys_list, dict, log_flag=True):
        for item in keys_list:
            if log_flag:
                logging.warning("%s will be removed from %s as it is incompatible with the other defined parameters"
                                % (item, self.name))
            if item in dict.keys():
                del dict[item]

    @logger
    def set_default_udp_rtp_params(self, traffic_profile_description):
        """Alternate UDP Traffic Method means that the tester uses the parameters burst, size and period_ms
        to determine the throughput rather than directly using throughput_ul / throughput_dl in Mbps / kbps
        The length of the traffic (duration) is determined by the parameter packets"""
        self.construct_default_udp_params(traffic_profile_description)
        self.default_params_rtp = {"rtp_codec": "amr_wb_23_85", "direction": "dl", "qfi": "1",
                                   "traffic_duration_sec": 0, "traffic_type": "static"}

    @logger
    def update_traffic_attributes(self, traffic_profile_description):
        self.identify_type_of_udp_traffic(traffic_profile_description)
        self.set_default_udp_rtp_params(traffic_profile_description)
        self.traffic_protocol = self.identify_traffic_protocol(traffic_profile_description)
        if self.traffic_protocol == "udp":
            self._traffic_attributes.update(self.default_params_udp)
        elif self.traffic_protocol == "rtp":
            self._traffic_attributes.update(self.default_params_rtp)
        else:
            logging.error("Invalid traffic type")
        self.insert_traffic_attributes(traffic_profile_description, self._traffic_attributes)
        logging.info("Traffic Attributes:", self._traffic_attributes)

    @property
    def name(self):
        return self._name

    @property
    def throughput_dl(self):
        return self._traffic_attributes.get("throughput_dl")

    @property
    def throughput_ul(self):
        return self._traffic_attributes.get("throughput_ul")

    @property
    def unit_dl(self):
        return self._traffic_attributes.get("unit_dl")

    @property
    def unit_ul(self):
        return self._traffic_attributes.get("unit_ul")

    @property
    def size(self):
        return self._traffic_attributes.get("size")

    @property
    def traffic_duration(self):
        if self._is_alternate_udp_traffic and self._traffic_attributes.get("packets"):
            return (self._traffic_attributes.get("packets") * (self._traffic_attributes.get("period_ms") / 1000))
        else:
            return self._traffic_attributes.get("traffic_duration_sec")

    @property
    def traffic_type(self):
        return self._traffic_attributes.get("traffic_type")

    @property
    def rtp_codec(self):
        return self._traffic_attributes.get("rtp_codec")

    @property
    def rtp_voice_silence(self):
        return self._rtp_voice_silence

    @property
    def direction(self):
        return self._traffic_attributes.get("direction")

    @property
    def qfi(self):
        return self._traffic_attributes.get("qfi")

    @logger
    def clean_up_command(self, command):
        """Remove seconds from the command list if packets is present"""
        if "packets" in command.keys():
            del command["packets"]
        return command

    @logger
    def identify_traffic_protocol(self, traffic_profile_description):
        if "rtp_codec" in traffic_profile_description.keys():
            return "rtp"
        else:
            return "udp"

    @logger
    def insert_traffic_attributes(self, traffic_profile_description, traffic_attributes):
        user_defined_traffic_attibs = {}
        default_attribs_missing = []
        for attrib in traffic_profile_description:
            if attrib in traffic_attributes.keys():
                traffic_attributes[attrib] = traffic_profile_description.get(attrib)
            else:
                user_defined_traffic_attibs[attrib] = traffic_profile_description.get(attrib)
        default_attribs_missing = \
            [element for element in traffic_attributes.keys() if element not in traffic_profile_description.keys()]
        for element in default_attribs_missing:
            print("{0} not defined for {1} in JSON, "
                  "default value of {2} will be used".format(element, self.name, traffic_attributes[element]))
        traffic_attributes['user_defined_attribs'] = user_defined_traffic_attibs

    @logger
    def get_traffic_parameters(self, max_trf_id_used):
        self.max_traffic_id_used = max_trf_id_used
        traffic_parameters = []
        if self.traffic_protocol == "udp":
            traffic_parameters.extend(self._get_udp_traffic_commands())
        else:
            if self.direction == 'bi':
                traffic_parameters.append(self._generate_VoNR_traffic_commands('dl'))
                traffic_parameters.append(self._generate_VoNR_traffic_commands('ul'))
            else:
                traffic_parameters.append(self._generate_VoNR_traffic_commands(self.direction))
        return traffic_parameters

    @logger
    def _get_udp_traffic_commands(self):
        cmd_list = []
        if self._is_alternate_udp_traffic and int(self.size):
            if self.direction == "dl":
                dl_traffic_commands = self._generate_alternate_udp_ul_dl_traffic_commands("dl")
                cmd_list = cmd_list + dl_traffic_commands
            if self.direction == "ul":
                ul_traffic_commands = self._generate_alternate_udp_ul_dl_traffic_commands("ul")
                cmd_list = cmd_list + ul_traffic_commands
            if self.direction == 'bi':
                dl_traffic_commands = self._generate_alternate_udp_ul_dl_traffic_commands("dl")
                ul_traffic_commands = self._generate_alternate_udp_ul_dl_traffic_commands("ul")
                cmd_list = cmd_list + ul_traffic_commands + dl_traffic_commands
        else:
            if int(self.throughput_dl):
                dl_traffic_commands = self._generate_ul_dl_traffic_commands("dl")
                cmd_list = cmd_list + dl_traffic_commands
            if int(self.throughput_ul):
                ul_traffic_commands = self._generate_ul_dl_traffic_commands("ul")
                cmd_list = cmd_list + ul_traffic_commands
            if not int(self.throughput_dl) and not int(self.throughput_ul):
                cmd_list = cmd_list + self._generate_miscellaneous_traffic_commands()
        return cmd_list

    @logger
    def _generate_alternate_udp_ul_dl_traffic_commands(self, traffic_direction):
        cmd_list = []
        if traffic_direction == "ul":
            cmd_list.append(self._generate_traffic_commands(direction=traffic_direction,
                                                            traffic_id=self.max_traffic_id_used + 1,
                                                            throughput=None))
        elif traffic_direction == "dl":
            cmd_list.append(self._generate_traffic_commands(direction=traffic_direction,
                                                            traffic_id=self.max_traffic_id_used + 1,
                                                            throughput=None))
        else:
            logging.error("Invalid traffic direction")
        self.max_traffic_id_used += 1
        return cmd_list

    @logger
    def _generate_miscellaneous_traffic_commands(self):
        cmd_dict = {}
        try:
            cmd_dict.update(self._generate_traffic_commands(
                direction=self._traffic_attributes['user_defined_attribs']['direction'],
                throughput=None,
                traffic_id=self.max_traffic_id_used + 1))
        except KeyError:
            logging.error("If you are using traffic like burst"
                          "you need to also specify the traffic 'direction' in the json under traffic profiles")
        self.max_traffic_id_used += 1
        return [cmd_dict]

    @logger
    def _generate_ul_dl_traffic_commands(self, traffic_direction):
        total_traffic = 0
        cmd_list = []
        """Traffic split is not needed when throughput is in Kbps, only needed when required throughput exceeds
        MAX_TP_PER_TRAFFIC_ID"""
        traffic_id_split_needed = True
        if traffic_direction == "dl":
            total_traffic = self.throughput_dl
            traffic_id_split_needed = False if self.unit_dl == "kbps" else True
        if traffic_direction == "ul":
            total_traffic = self.throughput_ul
            traffic_id_split_needed = False if self.unit_ul == "kbps" else True
        if traffic_id_split_needed:
            necessary_traffic_streams, remainder_traffic = divmod(total_traffic,
                                                                  MAX_TP_PER_TRAFFIC_ID)
        else:
            necessary_traffic_streams = 0
            remainder_traffic = total_traffic
        for traffic_id in range(1, necessary_traffic_streams+1):
            cmd_list.append(self._generate_traffic_commands(direction=traffic_direction,
                                                            traffic_id=traffic_id + self.max_traffic_id_used,
                                                            throughput=MAX_TP_PER_TRAFFIC_ID))
        if remainder_traffic:
            cmd_list.append(self._generate_traffic_commands(direction=traffic_direction,
                                                            traffic_id=necessary_traffic_streams +
                                                            self.max_traffic_id_used + 1,
                                                            throughput=remainder_traffic))
        self.max_traffic_id_used = necessary_traffic_streams + self.max_traffic_id_used + 1
        return cmd_list

    @logger
    def _generate_traffic_commands(self, direction, traffic_id, throughput):
        traffic_commands = {}
        exclude_in_traffic_commands = ['traffic_duration_sec', 'traffic_type', 'direction', 'throughput_dl',
                                       'throughput_ul', 'unit_dl', 'unit_ul', 'user_defined_attribs', 'kbps', 'mbps'
                                       'gbps']
        traffic_commands['trf_id'] = traffic_id
        traffic_commands['protocol'] = "udp"
        traffic_commands['direction'] = direction
        if throughput:
            if direction == "ul":
                traffic_commands[self.unit_ul] = throughput
            else:
                traffic_commands[self.unit_dl] = throughput
        for param, value in self._traffic_attributes.items():
            if param not in exclude_in_traffic_commands:
                traffic_commands.update({param: value})
            else:
                traffic_commands.update(self._traffic_attributes['user_defined_attribs'])
        if "packets" not in traffic_commands.keys():
            traffic_commands['seconds'] = self.traffic_duration
        return traffic_commands

    @logger
    def _generate_VoNR_traffic_commands(self, direction):
        exclude_in_traffic_commands = ['traffic_duration_sec', 'traffic_type', 'direction']
        required_traffic_command_params = ['rtp_codec', 'qfi']
        traffic_commands = {}
        for param, value in self._traffic_attributes.items():
            if (param not in exclude_in_traffic_commands) and (param in required_traffic_command_params):
                traffic_commands.update({param: value})
            elif (param not in required_traffic_command_params) and (param not in exclude_in_traffic_commands):
                traffic_commands.update(self._traffic_attributes['user_defined_attribs'])
        traffic_commands['trf_id'] = '1'
        traffic_commands['protocol'] = "udp"
        traffic_commands['seconds'] = self.traffic_duration
        traffic_commands['direction'] = direction
        return traffic_commands

    @logger
    def get_traffic_dict(self):
        logging.debug('collecting throughput information for %s', self.name)
        traffic_dict = {'ul': 0, 'dl': 0}
        if self.throughput_dl:
            traffic_dict['dl'] = self.throughput_dl * get_unit_multiplier(self.unit_dl)
        if self.throughput_ul:
            traffic_dict['ul'] = self.throughput_ul * get_unit_multiplier(self.unit_ul)
        return traffic_dict


def get_unit_multiplier(unit):
    multi = 1
    if unit == 'kbps':
        multi = 0.001
    if unit == 'mbps':
        multi = 1
    logging.debug('selected multiplier for unit %s is %s', unit, multi)
    return multi
