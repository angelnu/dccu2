#########
# BUILD #
#########
set -xe

# prepare some dirs
RDIR="$pwd"
rm -rf $OVERLAY
mkdir $OVERLAY
mkdir -p $OVERLAY/etc/init.d
mkdir $OVERLAY/etc/config_templates
mkdir -p $OVERLAY/usr/sbin

# Set distro
if [ "$ARCH" = "i386" ]; then
  echo "Arch is $ARCH -> use X86_32_Debian_Wheezy"
  ln -s $RDIR/dependencies/occu/X86_32_Debian_Wheezy $RDIR/dependencies/occu/distro
else
  echo "Arch is $ARCH -> use arm-gnueabihf"
  ln -s $RDIR/dependencies/occu/arm-gnueabihf $RDIR/dependencies/occu/distro
fi

#clear occu repo bugs
rm -rf $RDIR/dependencies/occu/HMserver/etc/init.d

# lighttpd
echo "building lighttpd"
cp -l $RDIR/dependencies/occu/distro/packages/lighttpd/bin/* $OVERLAY/usr/sbin
cp -rl $RDIR/dependencies/occu/distro/packages/lighttpd/etc/lighttpd $OVERLAY/etc/lighttpd
cp -rl $RDIR/dependencies/occu/distro/packages/lighttpd/lib $OVERLAY/lib

# linuxbasis
echo "building linuxbasis"
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/LinuxBasis/bin $OVERLAY/bin
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/LinuxBasis/lib/* $OVERLAY/lib/

# hs485d - we love wired :-)
echo "building hs485d - we love wired :-)"
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/HS485D/bin/* $OVERLAY/bin/
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/HS485D/lib/* $OVERLAY/lib/

# rfd
echo "building rfd"
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/RFD/bin/SetInterfaceClock $OVERLAY/bin/
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/RFD/bin/avrprog $OVERLAY/bin/
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/RFD/bin/crypttool $OVERLAY/bin/
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/RFD/bin/rfd $OVERLAY/bin/
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/RFD/etc/config_templates/* $OVERLAY/etc/config_templates/
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/RFD/etc/crRFD.conf $OVERLAY/etc/
cp -rlf $RDIR/dependencies/occu/distro/packages-eQ-3/RFD/lib/* $OVERLAY/lib/

# HMIPServer
echo "building HMIPServer"
cp -rl $RDIR/dependencies/occu/HMserver/* $OVERLAY/
#rm -rf $OVERLAY/opt/HMServer/HMServer.jar

# Tante rega ;-)
echo "building ReGaHss ;-)"
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/WebUI/bin/* $OVERLAY/bin/
cp -rl $RDIR/dependencies/occu/WebUI/bin/* $OVERLAY/bin/
cp -rl $RDIR/dependencies/occu/distro/packages-eQ-3/WebUI/etc/rega.conf $OVERLAY/etc/
cp -rlf $RDIR/dependencies/occu/distro/packages-eQ-3/WebUI/lib/* $OVERLAY/lib/
cp -rlP $RDIR/dependencies/occu/WebUI/www $OVERLAY/www

#version info
export CCU2_VERSION=$(cat OCCU_VERSION)
mkdir $OVERLAY/boot
echo $CCU2_VERSION>$OVERLAY/boot/VERSION
sed -i 's/WEBUI_VERSION = ".*";/WEBUI_VERSION = "'$CCU2_VERSION'";/' $OVERLAY/www/rega/pages/index.htm
sed -i 's/product == "HM-CCU2"/product == "HM-dccu2"/' $OVERLAY/www/webui/webui.js
sed -i 's/"http:\/\/update\.homematic\.com\/firmware\/download?cmd=js_check_version&version="+WEBUI_VERSION+"&product=HM-CCU2&serial=" + serial/"https:\/\/gitcdn.xyz\/repo\/litti\/dccu2\/master\/release\/latest-release.js?cmd=js_check_version\&version="+WEBUI_VERSION+"\&product=HM-dccu2-x86_64\&serial=" + serial/' $OVERLAY/www/webui/webui.js >dada.js
#echo "homematic.com.setLatestVersion('$CCU2_VERSION', 'HM-dccu2-x86_64');" > $RDIR/release/latest-release.js

#fix devconfig
#sed -i 's/<div class=\\\"StdTableBtn CLASS21701\\\" onclick=\\\"window\.open('\''\/tools\/devconfig\.cgi?sid=\$sid'\'');\\\">devconfig<\/div>/<div class=\\\"cpButton\\\"><div class=\\\"StdTableBtn CLASS21701\\\" onclick=\\\"window\.open\('\''\/tools\/devconfig\.cgi\?sid=\$sid'\''\);\\\">devconfig<\/div><div class=\\\"StdTableBtnHelp\\\"><\/div><\/div>/' $OVERLAY/www/config/control_panel.cgi
#sed -i 's/<\/td><td class=\\\"StdTableBtnHelp\\\"><\/td>/<\/td>/' $OVERLAY/www/config/control_panel.cgi

# image specific data
echo "building image specific data"
cp -rl $RDIR/dependencies/occu/firmware $OVERLAY/firmware/

#copy patched files
#echo "copy patched files"
#cp -rlf $RDIR/debian_all/patches/WebUI/www/config/* $OVERLAY/www/config/

#hack for glitch in repo
#echo "hack for glitch in repo"
#mv $OVERLAY/firmware/HmIP-RFUSB/hmip_coprocessor_update.eq3 $OVERLAY/firmware/HmIP-RFUSB/hmip_coprocessor_update-2.8.6.eq3

# other data
echo "building other data"
#cp -rlf $RDIR/all/* $OVERLAY/
cp -rlf $RDIR/debian_all/* $OVERLAY/

#docker container rm $(docker ps -a | grep "${DOCKER_NAME}" | awk '{print $1}')
#docker rmi -f $(docker image ls |grep "${DOCKER_NAME}"| awk '{print $3}')
