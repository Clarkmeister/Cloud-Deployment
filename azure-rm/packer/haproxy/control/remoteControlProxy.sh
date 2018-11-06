#!/bin/sh

#
#There are helper functions to start haproxy
#
PARAM1=""
IPTARGET="10.83.160.171"
start() {
    # we need to validate config file before starting
    ssh -p 22 vagrant@$IPTARGET "sudo /tmp/haproxyHelper.sh start"
    RETVAL=$?
    return $RETVAL
}
stop() {
    # we need to validate config file before starting
    ssh -p 22 vagrant@$IPTARGET "sudo /tmp/haproxyHelper.sh stop"
    RETVAL=$?
    return $RETVAL
}
restart(){
    # we need to validate config file before starting
    ssh -p 22 vagrant@$IPTARGET "sudo /tmp/haproxyHelper.sh restart"
    RETVAL=$?
    return $RETVAL
}
reload() {
    # we need to validate config file before starting
    ssh -p 22 vagrant@$IPTARGET "sudo /tmp/haproxyHelper.sh reload"
    RETVAL=$?
    return $RETVAL
}
update() {
    ssh -p 22 vagrant@$IPTARGET "sudo /tmp/haproxySetup.sh"
    RETVAL=$?
    return $RETVAL
}
pushFile() 
{
    sftp -o StrictHostKeyChecking=no vagrant@$IPTARGET:/tmp/ <<< $'put /export/home/e09174/'$PARAM2'' 
}

case "$1" in
start)
        start
        ;;
stop)
        stop
        ;;
reload)
        reload
        ;;
restart)
        restart
        ;;
update)
	update
	;;
pushFile)
	PARAM2=$2 
	pushFile 
	;;	
esac
