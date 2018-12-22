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
  export DISTRO="$RDIR/dependencies/occu/X86_32_Debian_Wheezy"
  export LD_PATH="$OVERLAY/lib"
else
  echo "Arch is $ARCH -> use arm-gnueabihf"
  export DISTRO="$RDIR/dependencies/occu/arm-gnueabihf"
  export LD_PATH="$OVERLAY/lib/arm-linux-gnueabihf"
fi
mkdir -p $LD_PATH

#clear occu repo bugs
rm -rf $RDIR/dependencies/occu/HMserver/etc/init.d

# lighttpd
echo "building lighttpd"
cp -l $DISTRO/packages/lighttpd/bin/* $OVERLAY/usr/sbin
cp -rl $DISTRO/packages/lighttpd/etc/lighttpd $OVERLAY/etc/lighttpd
cp -rl $DISTRO/packages/lighttpd/lib/* $LD_PATH/
test -d $OVERLAY/lib/lighttpd || mv $LD_PATH/lighttpd $OVERLAY/lib/

# linuxbasis
echo "building linuxbasis"
cp -rl $DISTRO/packages-eQ-3/LinuxBasis/bin $OVERLAY/bin
cp -rl $DISTRO/packages-eQ-3/LinuxBasis/lib/* $LD_PATH/

# hs485d - we love wired :-)
echo "building hs485d - we love wired :-)"
cp -rl $DISTRO/packages-eQ-3/HS485D/bin/* $OVERLAY/bin/
cp -rl $DISTRO/packages-eQ-3/HS485D/lib/* $LD_PATH/

# rfd
echo "building rfd"
cp -rl $DISTRO/packages-eQ-3/RFD/bin/SetInterfaceClock $OVERLAY/bin/
cp -rl $DISTRO/packages-eQ-3/RFD/bin/avrprog $OVERLAY/bin/
cp -rl $DISTRO/packages-eQ-3/RFD/bin/crypttool $OVERLAY/bin/
cp -rl $DISTRO/packages-eQ-3/RFD/bin/rfd $OVERLAY/bin/
cp -rl $DISTRO/packages-eQ-3/RFD/etc/config_templates/* $OVERLAY/etc/config_templates/
cp -rl $DISTRO/packages-eQ-3/RFD/etc/crRFD.conf $OVERLAY/etc/
cp -rlf $DISTRO/packages-eQ-3/RFD/lib/* $LD_PATH/

# HMIPServer
echo "building HMIPServer"
cp -rl $RDIR/dependencies/occu/HMserver/* $OVERLAY/
#rm -rf $OVERLAY/opt/HMServer/HMServer.jar

# Tante rega ;-)
echo "building ReGaHss ;-)"
cp -rl $DISTRO/packages-eQ-3/WebUI/bin/* $OVERLAY/bin/
cp -rl $RDIR/dependencies/occu/WebUI/bin/* $OVERLAY/bin/
cp -rl $DISTRO/packages-eQ-3/WebUI/etc/rega.conf $OVERLAY/etc/
cp -rlf $DISTRO/packages-eQ-3/WebUI/lib/* $LD_PATH/
test -d $OVERLAY/lib/tcl8.2 || mv $LD_PATH/tcl8.2 $OVERLAY/lib/
cp -rlP $RDIR/dependencies/occu/WebUI/www $OVERLAY/www

#version info
export CCU2_VERSION=$(cat OCCU_VERSION)
mkdir $OVERLAY/boot
#echo -n "VERSION=$CCU2_VERSION">$OVERLAY/boot/VERSION
echo -n "VERSION=$CCU2_VERSION">$OVERLAY/VERSION

sed -i 's/WEBUI_VERSION = ".*";/WEBUI_VERSION = "'$CCU2_VERSION'";/' $OVERLAY/www/rega/pages/index.htm
sed -i 's/product == "HM-CCU2"/product == "HM-dccu"/' $OVERLAY/www/webui/webui.js

#sed -i 's/"http:\/\/update\.homematic\.com\/firmware\/download?cmd=js_check_version&version="+WEBUI_VERSION+"&product=HM-CCU&serial=" + serial/"https:\/\/gitcdn.xyz\/repo\/litti\/dccu2\/master\/release\/latest-release.js?cmd=js_check_version\&version="+WEBUI_VERSION+"\&product=HM-dccu\&serial=" + serial/' $OVERLAY/www/webui/webui.js >dada.js
#echo "homematic.com.setLatestVersion('$CCU2_VERSION', 'HM-dccu');" > $RDIR/release/latest-release.js

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
echo "hack for glitch in repo"
mv $OVERLAY/firmware/HmIP-RFUSB/hmip_coprocessor_update.eq3 $OVERLAY/firmware/HmIP-RFUSB/hmip_coprocessor_update-2.8.6.eq3

# other data
echo "building other data"
#cp -rlf $RDIR/all/* $OVERLAY/
cp -rlf $RDIR/debian_all/* $OVERLAY/

#docker container rm $(docker ps -a | grep "${DOCKER_NAME}" | awk '{print $1}')
#docker rmi -f $(docker image ls |grep "${DOCKER_NAME}"| awk '{print $3}')
