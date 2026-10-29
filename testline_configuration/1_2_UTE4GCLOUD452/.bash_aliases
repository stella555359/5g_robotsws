alias pubs_emss_start='pgrep -f fbox | sudo xargs kill -9 ;  sudo su root -c "/opt/emssim/proxy/fbox_dual.pl" ; sleep 3 ; sudo su - flexi1 -c "cd /home/flexi1 && ./start"'
alias pubs_emss_pc_start='pubs_checker -lact emssim1 -k ; pubs_checker -lact emssim1'

alias pubs_pp="echo oZPS0POrRieRtu"
alias pubs_sshenb="/home/ute/robotlte/config/Bangalore/1_2_CLOUD452/ivk_fixssh.sh ; sshenb"
alias pubs_sshrtg="sshpass -p "rtg" ssh -t rtg@10.60.0.10"

alias pubs_penb="ping 192.168.255.129"
alias pubs_prtg="ping 10.60.0.10"
alias pubs_pfrtg="fping -aqg 10.60.0.0/24"
alias pubs_rtgrf10='sshpass -p "rtg" ssh -t rtg@10.60.0.10 "/rom/bin/rtg/mmi 1 -c adr"'

alias pubs_rtg_update='sudo /usr/rtg/bin/rtg-update'

alias pubs_reload='source /home/ute/.bash_aliases ; echo Aliases reloaded'
alias pubs_vimbash='vim /home/ute/.bash_aliases'

alias pubs_remount='cd / ; sudo umount /mnt/pubs ; mount /mnt/pubs ; cd -'
alias pubs_pybotkill='echo Before: ; ps aux | grep pybot ; ps aux | pgrep -f pybot | sudo xargs kill -9 ; echo After: ; ps aux | grep pybot'

alias pubs_vmip='ip r get 1 | rev | cut -d" " -f2 | rev | head -1'

alias ls='ls --color=auto'
