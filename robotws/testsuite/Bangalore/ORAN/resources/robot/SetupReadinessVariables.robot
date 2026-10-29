*** Settings ***

Documentation
...   author: Kuldeep Kastuv and Rubina Nath and Rajarshi Mandal
...   contact: kuldeep.kastuv@nokia.com or rubina.nath@nokia.com or rajarshi.mandal@nokia.com
...   Description: Variables for Smart Software Update in Legacy and O-RAN Customer Testlines

*** Variables ***

#BTSRelatedParameters
${bts_id}=                111111
${BTS_ADDRESS} =          192.168.255.129
${btsusername}=           Nemuadmin
${btspassword}=           nemuuser
${ssh_username}=          toor4nsn
${ssh_password}=          oZPS0POrRieRtu
${connection}=            default
${BTS_path}=              /home/ute/logs
${port}=                  443
@{faultslist}=            61652    61649    4681    4655    4654    61524

#BuildRelatedParameters#
###Precondition to create a folder with base build name (eg. SBTS25R2 or SBTS24R3)###
###Precondition to keep base release SCF and RFM plugin in the path###
###If dedicated base build is available for downgrade variable is yes,
...    else Mention it as "no" to download a new base build###

###Source Software ###
${sourcebasebuildavailable}=     yes
${fullsourcebasebuild}=          SBTS25R2_ENB_0000_000562_000000   #Build name if a dedicated base build is available#
${sourceRelease}=                SBTS00     #SourceRelease#
${sourceScfpath}=                /home/ute/${sourceRelease}/SCF.xml   #Path of base build SCF#
${rfmpluginpath}=                /home/ute/${sourceRelease}/RFMPlugin_O-RU_FJ_TA08029-B311-01_0003.zip    #RFM plugin for FJT#
${fdsw_version}=                 FDSW25A
###Example: FDWS25A is the FDWS for SBTS25R2 release builds,find it in sub-builds section of WFT link for base release build###

###Target Software ###
${targetRelease}=         SBTS00    #TargetRelease#
${SWpromTAG}=             REGRESSION     #TagtoDownloadBuildfromCoops(eg.REGRESSION/CDRT)#
${currentTrunk}=          SBTS26R1       #SetCurrentTrunk,example:"SBTS00"NowEquals"SBTS26R1"
### Update below parameters for your Choice of Build to Download
### yes : Download the build by the choice of user
### no  : download latest released build from coops link ###
${DownloadSWBuildbyUserChoice}=        no  ##If yes, provide Build in ${SWBuildID_UserChoice}##
${SWBuildID_UserChoice}=               SBTS00_ENB_9999_250722_000005

#O-RANRelatedParameters
&{FJsw_compatibility}=    SBTS24R3=02
...                       SBTS25R1=03
...                       SBTS25R2=04
...                       SBTS25R3=05
...                       SBTS26R1=06
${FJTusername}=           ca_fujitsu_nok
${FJTpasswd}=             Fujitsu@123
${AWHusername}=           nath
${AWHpasswd}=             cmVmdGtuOjAxOjE4MTI1NDQ2NTE6cGtNbGRDNldJWkdvd0NKZ05wamF6T05pRExK
@{vendorcodes}=           @{EMPTY}
@{protocols}=             @{EMPTY}

#NetconfCredentialsRelatedParameters
&{default_user_fj}=    	  defaultNetconfAccountName=fjncuser0
...                    	  defaultNetconfAccountPwd=ncCl2fjRu+autH0
&{authenticationfj}  	  id=1    defaultNetconfAccount=&{default_user_fj}
@{fjt_oru_creds}=      	  &{authenticationfj}
&{default_user_nk}=    	  defaultNetconfAccountName=nkoranuser
...                    	  defaultNetconfAccountPwd=FZYYERJkStMK7LQWwjHerkbldhO03LPb47NQtkftbm9Z
&{authenticationnk}  	  id=2    defaultNetconfAccount=&{default_user_nk}
@{NK_oru_creds}=      	  &{authenticationnk}
@{mix_oru_creds}=         &{authenticationfj}    &{authenticationnk}

#Mantaray Operations Variables
${mo_id}=    			PLMN-PLMN/MRBTS-${bts_id}/MNL-1
${mo_dist_name}=	        PLMN-PLMN/MRBTS-${bts_id}
${actual_plan1}=     		Plan_SWUpload_MantaRay${bts_id}
${BackupPlan}=    		BackupPlan_SWUpload_MantaRay${bts_id}
${PLAN_DESCRIPTION}=    	requestedSW_test
${web_url}=    			https://${clab_netact}lbwas.srnblr.nsn-rdnet.net/authentication/Login
${web_user}=   			test2
${web_pwd}=    			Qwer_1234
${clab_netact}=    		srnclab1042
${fm_cm_itsmwas_hostIp}=   	10.43.48.16
${node_Username_fmwas}=	        omc
${node_password_fmwas}=         Medsql!_1893
${NETACT_NAME}=                 netact