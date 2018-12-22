ARG arch=i386
ARG BASE=$arch/openjdk:8-slim

FROM ubuntu as builder
ARG arch=i386
ENV ARCH=$arch

RUN apt update && \
    apt -y install curl

RUN curl -s https://api.github.com/repos/eq-3/occu/releases/latest| grep '"tag_name":'|sed -E 's/.*"([^"]+)".*/\1/'>OCCU_VERSION && \
    export OCCU_VERSION=$(cat OCCU_VERSION) && \
    echo "Downloading OCCU version: $OCCU_VERSION" && \
    mkdir -p /dependencies && \
    cd /dependencies && \
    curl -L https://github.com/eq-3/occu/archive/${OCCU_VERSION}.tar.gz | tar xvz && \
    mv occu* occu

ENV OVERLAY=/overlay
ADD prepare.sh /
ADD debian_all /debian_all
RUN ./prepare.sh



FROM $BASE

#COPY qemu/qemu-$ARCH-static* /usr/bin/

#ADD bin /bin
#ADD boot /boot
#ADD etc /etc
#ADD firmware /firmware
#ADD lib /lib
#ADD opt /opt
#ADD sbin /sbin
#ADD usr /usr
#ADD www /www
COPY --from=builder /overlay /

#RUN update-usbids
RUN apt update && \
    mkdir -p /usr/share/man/man1 && \
    apt install -y busybox-syslogd libssl1.0.2 usbutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm -rf /usr/local/* && \
      mkdir -p /usr/local/tmp && \
      mkdir -p /usr/local/etc/config && \
      mkdir -p /usr/local/etc/config/crRFD && \
      mkdir -p /usr/local/etc/config/rc.d && \
      mkdir -p /usr/local/etc/config/addons/www && \
      mkdir -p /var/status && \
      ln -s ../usr/local/etc/config /etc/config && \
      ln -s /usr/lib/*-linux-gnu/libssl.so.1.0* /usr/lib/libssl.so.1.0.0 && \
      ln -s /usr/lib/*-linux-gnu/libcrypto.so.1.0* /usr/lib/libcrypto.so.1.0.0 && \
      mkdir /opt/hm && \
      touch /var/rf_address && \
      ln -s /bin /opt/hm/bin && \
      ln -s /etc /opt/hm/etc && \
      ln -s /www /opt/hm/www && \
      ln -s ../init.d/ccu2-logging /etc/rc3.d/S00ccu2-logging && \
      ln -s ../init.d/ccu2-dccu2SystemStart /etc/rc3.d/S01ccu2-dccu2SystemStart && \
      ln -s ../init.d/ccu2-eQ3SystemStart /etc/rc3.d/S02ccu2-eQ3SystemStart && \
      ln -s ../init.d/ccu2-hs485dloader /etc/rc3.d/S49ccu2-hs485dloader && \
      ln -s ../init.d/ccu2-eq3configd /etc/rc3.d/S50ccu2-eq3configd && \
      ln -s ../init.d/ccu2-lighttpd /etc/rc3.d/S50ccu2-lighttpd && \
      ln -s ../init.d/ccu2-FirmwareUpdate /etc/rc3.d/S58ccu2-FirmwareUpdate && \
      ln -s ../init.d/ccu2-SetLGWKey /etc/rc3.d/S59ccu2-SetLGWKey && \
      ln -s ../init.d/ccu2-hs485d /etc/rc3.d/S60ccu2-hs485d && \
      ln -s ../init.d/ccu2-rfd /etc/rc3.d/S61ccu2-rfd && \
      ln -s ../init.d/ccu2-HmIPServer /etc/rc3.d/S62ccu2-HmIPServer && \
      ln -s ../init.d/ccu2-ReGaHss /etc/rc3.d/S70ccu2-ReGaHss && \
      ln -s ../init.d/ccu2-eQ3SystemStarted /etc/rc3.d/S99ccu2-eQ3SystemStarted && \
      #echo 'root:root'|chpasswd && \
      #sed -i -e 's/^PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
      #if grep -Fxq "PermitRootLogin" /etc/ssh/sshd_config; then echo ""; else echo "\nPermitRootLogin yes" >>/etc/ssh/sshd_config; fi
      echo done

ADD entrypoint.sh /

CMD ["/entrypoint.sh"]

#ssh
EXPOSE 22
#webui
EXPOSE 80
#minissdpd
EXPOSE 1900
#regahss
EXPOSE 1999
#hs485d
EXPOSE 2000
#rfd
EXPOSE 2001
#hmiprf
EXPOSE 2010
#rega
EXPOSE 8181
#virtualdevices
EXPOSE 9292
