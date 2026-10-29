#!/bin/bash
set -x

echo "**********dumping BIP traffic for ABIO to ASIL CPU"
echo "**********mandatory parameter: ABIO slot id for mirroring"
echo "**********optional parameter: PCAP file name"

readOptionsFromConfigFile() {
    source $directory/apMirror_On_ASIL_ABIOConfig.sh
    if [ $? -eq 0 ]; then 
        echo -e "\n${YELLOW}Read options from apMirror_On_ASIL_ABIOConfig.sh${NC}"
    else 
        echo -e "\n${RED}Config file (apMirror_On_ASIL_ABIOConfig.sh) not found${NC}"
        exit
    fi
}

parseCommandLineOptions() {
    echo -e "\n${YELLOW}Parse command line options${NC}"
    for i in "$@"
    do
    case $i in
        --mirror_abil_1=*)
            MIRROR_ABIL_1="${i#*=}"
            shift
        ;;
        --mirror_abil_2=*)
            MIRROR_ABIL_2="${i#*=}"
            shift
        ;;
        --mirror_abil_3=*)
            MIRROR_ABIL_3="${i#*=}"
            shift
        ;;
        *)
            #echo -e "\n${UELLOW}No options given in command line${NC}"
        ;;
    esac
    done
}

printOptions() {
    echo -e "Mirrored BB boards"
    echo -e "  MIRROR_ABIL_1=$MIRROR_ABIL_1"
    echo -e "  MIRROR_ABIL_2=$MIRROR_ABIL_2"
    echo -e "  MIRROR_ABIL_3=$MIRROR_ABIL_3"
}

getRackPosition(){
	rackPosition=$( hostname | grep -o "fct-[0-9]a" | grep -o "[0-9]" )
}

captureData() {
	#Close ASIL MAC learning
	bcicmd -n 3msd -c "/dbg3ms/port 36 set learning 0 0 1"
	
	if [[ "$MIRROR_ABIL_1" = "true" ]] && [[ "$rackPosition" = "0" ]]; then
		fcp_id=1
		fsp_id=1
		slot_id=1
		#L1-L2 traffic
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 303
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 304
		#L2HI_L2RT traffic
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 305
		
		sleep 1
		#ASIL config vlan to port 13
		bcicmd -n 3msd -c "/dbg3ms/vlan add 303 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 304 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 305 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 303 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 304 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 305 21"
		
	fi
	
	if [[ "$MIRROR_ABIL_2" = "true" ]] && [[ "$rackPosition" = "0" ]]; then
		fcp_id=1
		fsp_id=2
		slot_id=2
		#L1-L2 traffic
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 306
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 307
		#L2HI_L2RT traffic
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 308
		
		sleep 1
		#ASIL config vlan to port 13
		bcicmd -n 3msd -c "/dbg3ms/vlan add 306 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 307 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 308 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 306 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 307 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 308 21"
	fi	
	
	if [[ "$MIRROR_ABIL_3" = "true" ]] && [[ "$rackPosition" = "0" ]]; then
		fcp_id=1
		fsp_id=3
		slot_id=3
		#L1-L2 traffic
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 309
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 310
		#L2HI_L2RT traffic
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 311
		sleep 1
		#ASIL config vlan to port 13
		bcicmd -n 3msd -c "/dbg3ms/vlan add 309 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 310 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 311 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 309 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 310 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 311 21"
	fi	
	
	if [[ "$MIRROR_ABIL_1" = "true" ]] && [[ "$rackPosition" = "4" ]]; then
		fcp_id=2
		fsp_id=4
		slot_id=5
		#L1-L2 traffic
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 303
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 304
		#L2HI_L2RT traffic
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 305
		
		sleep 1
		#ASIL config vlan to port 13
		bcicmd -n 3msd -c "/dbg3ms/vlan add 303 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 304 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 305 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 303 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 304 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 305 21"
	fi
	
	if [[ "$MIRROR_ABIL_2" = "true" ]] && [[ "$rackPosition" = "4" ]]; then
		fcp_id=2
		fsp_id=5
		slot_id=6
		#L1-L2 traffic
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 306
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 307
		#L2HI_L2RT traffic
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 308
		sleep 1
		#ASIL config vlan to port 13
		bcicmd -n 3msd -c "/dbg3ms/vlan add 306 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 307 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 308 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 306 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 307 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 308 21"
	fi	
	
	if [[ "$MIRROR_ABIL_3" = "true" ]] && [[ "$rackPosition" = "4" ]]; then
		fcp_id=2
		fsp_id=6
		slot_id=7
		#L1-L2 traffic
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_UL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 309
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L1_L2_DL -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 310
		#L2HI_L2RT traffic
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d sei11 -f L2HI_L2RT -b "C${fcp_id}B${fsp_id}(6)" -s $slot_id -v 311
		sleep 1
		#ASIL config vlan to port 13
		bcicmd -n 3msd -c "/dbg3ms/vlan add 309 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 310 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan add 311 13 untagged"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 309 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 310 21"
		bcicmd -n 3msd -c "/dbg3ms/vlan remove 311 21"
	fi	
	
	dbgnac set port 2 speed 25000
	dbgnac enable port 2
	dbgnac set port 2 loop e t
	dbgnac mirror sport 0 dport 2 e b
	dbgnac mirror sport 2 dport 20 e b
	/usr/bin/netd_uspace_lnk 2 1 25000 1
	ifconfig nac_eth2 up
	ifconfig nac_eth2 promisc
	
	echo "**********Dump file will be stored in /tmp/"
	

	tcpdump -vvv -i nac_eth2 -C 500 -W 10 -w /tmp/tcpdumpapL2L1_filtering_off.pcap


}


directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo -e "\n${YELLOW}apMirror_On_ASIL_ABIO.sh ${NC}"
readOptionsFromConfigFile
parseCommandLineOptions "$@"
getRackPosition
printOptions
captureData