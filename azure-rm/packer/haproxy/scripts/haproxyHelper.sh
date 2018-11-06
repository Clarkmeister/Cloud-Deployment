#!/bin/sh

#
#There are helper functions to start haproxy
#
start() {
    # we need to validate config file before starting  
    sudo haproxy -c -q -f /etc/haproxy/haproxy.cfg
        if [ $? -ne 0 ]; then
                echo "Errors found in configuration file."
                return 1
        fi

    echo -n "Starting HAProxy: "
    sudo haproxy -f /etc/haproxy/haproxy.cfg -D -p /var/run/haproxy.pid

    RETVAL=$?
    echo
      [ $RETVAL -eq 0 ] && sudo touch /var/lock/subsys/haproxy
      return $RETVAL
}
stop() {
      ACTUALPROCESS=$(sudo cat /var/run/haproxy.pid)
      kill $ACTUALPROCESS
      RETVAL=$?
      echo
      [ $RETVAL -eq 0 ] && sudo rm -f /var/lock/subsys/haproxy
      [ $RETVAL -eq 0 ] && sudo rm -f /var/run/haproxy.pid
      return $RETVAL
}
restart(){
      # we need to validate config file before starting
      sudo haproxy -c -q -f /etc/haproxy/haproxy.cfg
      if [ $? -ne 0 ]; then 
		echo "Errors found in configuration file."
		return 1
      fi
      stop 
      start
}
reload() {
    # we need to validate config file before starting
    sudo haproxy -c -q -f /etc/haproxy/haproxy.cfg
        if [ $? -ne 0 ]; then
                echo "Errors found in configuration file."
                return 1
        fi
    sudo haproxy -f /etc/haproxy/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)

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
esac
