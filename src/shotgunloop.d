#!/bin/bash
#
# svnserve        Startup script for the Subversion svnserve daemon
#
# chkconfig: - 85 15
# description: The svnserve daemon allows access to Subversion repositories \
#              using the svn network protocol.
# processname: shotgunloop
# config: /etc/sysconfig/shotgunloop
# pidfile: /var/run/shotgunloop.pid
#
### BEGIN INIT INFO
# Provides:shotgunloop 
# Required-Start: $local_fs $remote_fs $network
# Required-Stop: $local_fs $remote_fs $network
# Short-Description: start and stop the shotgunloop daemon
# Description: The svnserve daemon allows access to Subversion
#   repositories using the svn network protocol.
### END INIT INFO

# Source function library.
. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/shotgunloop ]; then
        . /etc/sysconfig/shotgunloop
fi

exec=/var/local/shotgunLoop/src/shotgunLoop.sh
prog=shotgunloop
pidfile=${PIDFILE-/var/run/shotgunloop.pid}
lockfile=${LOCKFILE-/var/lock/subsys/shotgunloop.lock}
#args="--daemon --pid-file=${pidfile} $OPTIONS"
args=""
[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

lockfile=/var/lock/subsys/$prog

start() {
    [ -x $exec ] || exit 5
    [ -f $config ] || exit 6
    echo -n $"Starting $prog: "
    daemon --pidfile=${pidfile} $exec start $args
    retval=$?
    echo
    if [ $retval -eq 0 ]; then
        touch $lockfile || retval=4
    fi
    return $retval
}

stop() {
    echo -n $"Stopping $prog: "
    killproc -p ${pidfile} $prog
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    stop
    start
}

reload() {
    restart
}

force_reload() {
    restart
}

rh_status() {
    # run checks to determine if the service is running or use generic status
    status -p ${pidfile} $prog
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}

case "$1" in
    start)
        rh_status_q && exit 0
        $1
        ;;
    stop)
        rh_status_q || exit 0
        $1
        ;;
    restart)
        $1
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    force-reload)
        force_reload
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
        exit 2
esac
exit $?
