#!/bin/bash 
# A simple tool to show the time taken to boot the OS (Linux with KDE and boot with systemd only)
# Author: qpalz, realasking, 九十钩圈凯_ @ tieba.biadu.com
# Original version: http://tieba.baidu.com/p/1959641775?pid=25913711903

TEXTDOMAIN=startuptime

outputtime()
{
	t_tmp=`echo $stmp` && let tmin=t_tmp/60 && let tsec=t_tmp%60
	if [ $tmin -gt 0 ]; then
		#outpara="$tmin 分 $tsec 秒"
		outpara="$tmin "$"mins"" $tsec "$"secs"
	else
		#outpara="$t_tmp 秒"
		outpara="$tsec "$"secs"
	fi
}

outDS()
{
	DSession=`echo ${DESKTOP_SESSION}`
	if [ $DSession == "kde-plasma" ]; then
		dtmp=`kded4 -v|tail -n +2|head -n +1|cut -d"：" -f2`
		#DSession=$DSession" 运行版本："$dtmp 
		DSession="$DSession "$"Version: ""$dtmp"
	fi
}

getmac()
{
	ifconfig | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
}

getpos()
{
	wget -qO- "http://94.249.172.128/startuptime/getpos.php?time=$stt&mac=$(getmac)"
}

getnum()
{
	wget -qO- "http://94.249.172.128/startuptime/getnum.php"
}

if [ -z $_UTED ]; then
	stall=`cat /proc/uptime | cut -f1 -d'.'`
	stmp=`echo $stall`
	outputtime 
	outtpara=$outpara 
	#stt_tmp=`systemd-analyze | cut -d' ' -f13 | cut -d'm' -f1`
	stt_tmp=`systemd-analyze | cut -d' ' -f10 | cut -d'm' -f1`
	stt=`echo "$stt_tmp / 1000" | bc`
	stmp=`echo $stt` 
	outputtime
	outspara=$outpara
	stdesk=`echo "$stall - ${stt}" | bc`
	stmp=`echo $stdesk`
	outputtime
	outdpara=$outpara
	pos=$(getpos)
	num=$(getnum)
	percent=$(((num - pos) * 100 / num))
	outDS
	notify-send $"Welcome""${LOGNAME}" $"Time needed: ""${outspara}\n"\
$"Time needed to reach desktop: ""${outdpara}\n"\
$"Overall time needed: ""${outtpara}\n"\
$"Ranking: ""${pos}/${num}\n"\
$"Faster than"" ${percent}"$"% computers""\n"\
$"Desktop using: ""${DSession}\n"
fi
export _UTED=0
