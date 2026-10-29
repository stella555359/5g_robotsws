#!/bin/bash
readOptionsFromConfigFile() {
    source $directory/gnbMirroring_ASIM_ABIO_FSConfig.sh
    if [ $? -eq 0 ]; then 
        echo -e "\n${YELLOW}Read options from gnbMirroring_ASIM_ABIO_FSConfig.sh${NC}"
    else 
        echo -e "\n${RED}Config file (gnbMirroring_ASIM_ABIO_FSConfig.sh) not found${NC}"
        exit
    fi
}

parseCommandLineOptions() {
    echo -e "\n${YELLOW}Parse command line options${NC}"
    for i in "$@"
    do
    case $i in
        --bb_slot_1=*)
            BB_SLOT_1="${i#*=}"
            shift
        ;;
        --bb_slot_2=*)
            BB_SLOT_2="${i#*=}"
            shift
        ;;
        --bb_slot_3=*)
            BB_SLOT_3="${i#*=}"
            shift
        ;;
        --bb_slot_5=*)
            BB_SLOT_5="${i#*=}"
            shift
        ;;
        --bb_slot_6=*)
            BB_SLOT_6="${i#*=}"
            shift
        ;;
        --bb_slot_7=*)
            BB_SLOT_7="${i#*=}"
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
    echo -e "  BB_SLOT_1=$BB_SLOT_1"
    echo -e "  BB_SLOT_2=$BB_SLOT_2"
    echo -e "  BB_SLOT_3=$BB_SLOT_3"
    echo -e "  BB_SLOT_5=$BB_SLOT_5"
    echo -e "  BB_SLOT_6=$BB_SLOT_6"
    echo -e "  BB_SLOT_7=$BB_SLOT_7"
}

captureData() {
    if [ "$BB_SLOT_5" = "true" ] || [ "$BB_SLOT_1" = "true" ]; then
		bsh 1:0 "dbgnac set port 5 speed 25000"
		bsh 1:0 "dbgnac enable port 5"
		bsh 1:0 "dbgnac set port 5 loop e t"
		bsh 1:0 "dbgnac mirror sport 16 dport 5 e b"
		bsh 1:0 "dbgnac mirror sport 12 dport 5 e b"
		bsh 1:0 "dbgnac mirror sport 1 dport 5 e b"
		bsh 1:0 "dbgnac mirror sport 5 dport 20 e i"
		bsh 1:0 "/usr/bin/netd_uspace_lnk 5 1 25000 1"
		bsh 1:0 "ifconfig nac_eth5 up"
		bsh 1:0 "tcpdump -i nac_eth5 -C 500 -W 5 -w /tmp/tcpdump_L2L1_bip_filtering_off.pcap"
	fi
}

copyDumpFiles() {
    echo -e "\n${YELLOW}Capturing stopped, copy dump files if needed${NC}"
	if [ "$BB_SLOT_5" = "true" ] || [ "$BB_SLOT_1" = "true" ]; then
		files=$( bsh 1:0 "ls /tmp/tcpdump_L2L1_bip*" )
		for file in $files 
		do
			bget 1:0 $file /tmp/
		done
			bsh 1:0 "rm /tmp/tcpdump_L2L1_bip*"
		echo -e "\n${YELLOW}Dump files in /tmp/ folder${NC}"
		ls -la /tmp/tcpdump_L2L1_bip*
	fi
}

directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo -e "\n${YELLOW}gnbMirroring_ASIM_ABIO_FS.sh ${NC}"
readOptionsFromConfigFile
parseCommandLineOptions "$@"
printOptions
captureData
copyDumpFiles


