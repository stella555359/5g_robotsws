#!/bin/bash
readOptionsFromConfigFile() {
    source $directory/gnbMirroring_ASIB_ABIOConfig.sh
    if [ $? -eq 0 ]; then 
        echo -e "\n${YELLOW}Read options from gnbMirroring_ASIB_ABIOConfig.sh${NC}"
    else 
        echo -e "\n${RED}Config file (gnbMirroring_ASIB_ABIOConfig.sh) not found${NC}"
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
    if [ "$BB_SLOT_1" = "true" ]; then
        #L1-L2 traffic
    	/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C1B1(2)" -s 1 -l eths3 -v 303
    	sleep 1
    	/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C1B1(2))" -s 1 -l eths3 -v 304
    	#L2HI_L2RT traffic
    	sleep 1
    	/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C1B1(2)" -s 1 -l eths3 -v 305
    
    	echo 3 both > /var/run/cpss/ports/5/mirroring_port 
    	echo 3 both > /var/run/cpss/ports/6/mirroring_port
    
    fi
	if [ "$BB_SLOT_2" = "true" ]; then
    #L1-L2 traffic
    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C1B2(2)" -s 2 -l eths3 -v 306
    
    sleep 1
    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C1B2(2))" -s 2 -l eths3 -v 307
    
    #L2HI_L2RT traffic
    sleep 1
    /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C1B2(2)" -s 2 -l eths3 -v 308
    
    echo 3 both > /var/run/cpss/ports/9/mirroring_port 
    echo 3 both > /var/run/cpss/ports/10/mirroring_port

    fi
	if [ "$BB_SLOT_3" = "true" ]; then
		#L1-L2 traffic
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C1B3(2)" -s 3 -l eths3 -v 309
		
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C1B3(2))" -s 3 -l eths3 -v 310
		
		#L2HI_L2RT traffic
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C1B3(2)" -s 3 -l eths3 -v 311
		
		echo 3 both > /var/run/cpss/ports/13/mirroring_port 
		echo 3 both > /var/run/cpss/ports/14/mirroring_port
	fi
	if [ "$BB_SLOT_5" = "true" ]; then
        #L1-L2 traffic
        /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C2B4(2)" -s 5 -l eths3 -v 303
        
        sleep 1
        /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C2B4(2))" -s 5 -l eths3 -v 304
        
        #L2HI_L2RT traffic
        sleep 1
        /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B4(2)" -s 5 -l eths3 -v 305
        
        echo 3 both > /var/run/cpss/ports/5/mirroring_port 
        echo 3 both > /var/run/cpss/ports/6/mirroring_port
	fi	
	if [ "$BB_SLOT_6" = "true" ]; then
        #L1-L2 traffic
        /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C2B5(2)" -s 6 -l eths3 -v 306
        sleep 1
        /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C2B5(2)" -s 6 -l eths3 -v 307
        #L2HI_L2RT traffic
        sleep 1
        /usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B5(2)" -s 6 -l eths3 -v 308
        
        echo 3 both > /var/run/cpss/ports/9/mirroring_port 
        echo 3 both > /var/run/cpss/ports/10/mirroring_port
	fi		
	if [ "$BB_SLOT_7" = "true" ]; then
		#L1-L2 traffic
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_UL -b "C2B6(2)" -s 7 -l eths3 -v 309
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L1_L2_DL -b "C2B6(2)" -s 7 -l eths3 -v 310
		#L2HI_L2RT traffic
		sleep 1
		/usr/bin/lfs-nw_switch-mirror-tool.sh -p 0 -d ethsei02 -f L2HI_L2RT -b "C2B6(2)" -s 7 -l eths3 -v 311
		
		echo 3 both > /var/run/cpss/ports/13/mirroring_port 
		echo 3 both > /var/run/cpss/ports/14/mirroring_port
	fi			
	echo "**********Mirroring to ASIB netdriver"
	ncp_portmirror -p xgmac96 -r
	ncp_portmirror -d netdriver -p xgmac96
	ncp_l2 -p XGMAC96 -I -senableSwitching.false
	ncp_l2 -p XGMAC96 -i -sdiscardInvalidVlanidPackets.false
	ncp_l2 -p XGMAC96 -i -sdiscardBadLengthPackets.false
	echo "**********Dump file will be stored in /tmp/"
	
	tcpdump -i eths3 -C 500 -W 5 -vvv -w /tmp/tcpdump_L2L1_bip_filtering_off.pcap

}


directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo -e "\n${YELLOW}gnbMirroring_ASIB_ABIO.sh ${NC}"
readOptionsFromConfigFile
parseCommandLineOptions "$@"
printOptions
captureData


