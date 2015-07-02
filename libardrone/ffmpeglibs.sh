#!/bin/bash
# this script fixes its companion scripts, turning them from MS-DOS format to unix format
# to get rid of MSDOS format do this to this file: 
#  sudo sed -i s/\\r//g ./filename
# References
# http://www.raspberrypi.org/forums/viewtopic.php?f=43&t=53936
# http://www.jeffreythompson.org/blog/2014/11/13/installing-ffmpeg-for-raspberry-pi/
# https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html
# http://owenashurst.com/?p=242
#
#========================
# http://www.cmake.org/pipermail/cmake/2009-April/028853.html
# for cmake, either 
#   THIS DOES NOT WORK FOR OPENCV set the environment variables CFLAGS and CPPFLAGS 
#   before running cmake initially, AFAIK cmake will pick them up then.
# or
#   set the cmake variables CMAKE_C_FLAGS and CMAKE_CXX__FLAGS in your cmake commandline
# NOTE:
# http://answers.opencv.org/question/4934/setting-cflags-and-cxxflags-for-opencv-243/
# As of OpenCV 2.4.3 the CMake scripts seem to be 
# actively ignoring/resetting the user specified CFLAGS
# So ... set the cmake variables CMAKE_C_FLAGS and CMAKE_CXX__FLAGS in your 
# cmake commandline like this
# sudo cmake -G "Unix Makefiles" ../../ -DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_NEON:BOOL=ON -DINSTALL_TESTS:BOOL=ON -DWITH_FFMPEG:BOOL=ON -DCMAKE_C_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm" -DCMAKE_CXX_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm"
#========================

set +x

# http://community.arm.com/groups/tools/blog/2013/04/15/arm-cortex-a-processors-and-gcc-command-lines
# 
## fp only
#themfpu=vfpv4
## fp plus simd
themfpu=neon-vfpv4

# ask someone about
# sudo ./configure --host=arm-unknown-linux-gnueabi 
# versus
# sudo ./configure --host=armv71-unknown-linux-gnueabihf 
# versus
# sudo ./configure --host=arm-unknown-linux-gnueabihf 
#
# as at 2015.02.21 gcc is version 4.6.3
#
echo "#"
echo "# Start building some external libraries for ffmpeg on Raspberry Pi 2"
echo "#"
echo "# This is a COMPLETE source download and rebuild of some ffmpeg external libraries on Raspberry Pi 2"
echo "#"
echo "# Once day, ask someone about which if these works and is *the best* for the Pi2"
echo "# sudo ./configure --host=arm-unknown-linux-gnueabi "
echo "#   versus"
echo "# sudo ./configure --host=armv71-unknown-linux-gnueabihf "
echo "#   versus"
echo "# sudo ./configure --host=arm-unknown-linux-gnueabihf "
echo "#"
#echo "# NOTE:"
#echo "# THERE WILL BE SOME INTERACTIVE PROMPTING from time to time"
#echo "# FROM AUTOGEN ETC. We can't do anything about that."
echo "#"

set +x
read -p "Do you wish to re-download every Source library as we go ? [y/n,default=n]" dlYN
# [[ "$dlYN" =~ ^([yY]) ]] && ( statement ; separated ; by ; semicolons ; )
# or
# if [[ "$dlYN" =~ ^([yY]) ]] ; then
#   echo "Yes"
# elif [[ "$dlYN" =~ ^([nN]) ]] ; then
#   echo "No"
# else
#   echo "unknown"
# fi
#
read -p "Do you wish to press Enter between each library build ? [y/n,default=n]" pressenterYN
checkPressEnterYN() { [[ "$pressenterYN" =~ ^([yY]) ]] && ( set +x; echo "#"; read -p "Press Enter to continue..." xx ; echo "#"; set -x; ) }
# OK now use this statement ...
checkPressEnterYN
set -x
#--------
## from zeranoe windows build. 
## those with a single # we will attempt to include progressively 
##
##--enable-avisynth 
##--enable-frei0r (cant compile, opencv dependency) https://www.dyne.org/software/frei0r/   http://ffmpeg.zeranoe.com/builds/source/external_libraries/frei0r-20130909-git-10d8360.tar.xz
##--enable-gnutls (cant compile ... try again) http://gnutls.org/  http://ffmpeg.zeranoe.com/builds/source/external_libraries/gnutls-3.2.20.tar.xz
##--enable-libbluray 
#--enable-libbs2b dependency: libsndfile which wont compile   http://bs2b.sourceforge.net/  http://ffmpeg.zeranoe.com/builds/source/external_libraries/libbs2b-3.1.0.tar.xz
##--enable-libcaca 
##--enable-libgme 
##--enable-libgsm 
##--enable-libilbc 
#--enable-libmodplug http://modplug-xmms.sourceforge.net/#download   http://ffmpeg.zeranoe.com/builds/source/external_libraries/libmodplug-0.8.8.5.tar.xz
##--enable-libopencore-amrnb 
##--enable-libopencore-amrwb 
#--enable-libopus  http://opus-codec.org/   http://ffmpeg.zeranoe.com/builds/source/external_libraries/opus-1.1.tar.xz
##--enable-libschroedinger 
##--enable-libspeex 
#--enable-libvidstab http://public.hronopik.de/vid.stab/    http://ffmpeg.zeranoe.com/builds/source/external_libraries/vid.stab-0.98.tar.xz
##--enable-libvo-aacenc 
##--enable-libvo-amrwbenc 
##--enable-libxavs 
##--enable-decklink 
##--extra-libs=-ldl 
#--------
# Our build, in the order the libraries are built below
#--enable-libfaac 
#--enable-libx265
#--enable-libx264
#--enable-libmp3lame 
#--enable-libvpx 
#--enable-librtmp 
#--enable-libfdk-aac
#--enable-libxvid 
#--enable-libwebp
#--enable-libogg
#--enable-libvorbis
#--enable-libtheora 
#--enable-fontconfig 
#--enable-libass
#--enable-bzlib 
#--enable-libfreetype 
#--enable-libopenjpeg 
#--enable-libsoxr 
#--enable-libtwolame 
#--enable-libwavpack 
#--enable-lzma 
#--enable-zlib 
#--enable-iconv

set -x
sudo apt-get update -y
sudo apt-get upgrade -y
# some googling indicated these should be installed first
sudo apt-get -y install wget
sudo apt-get -y install git-core
#- sudo apt-get install -y git  # no, use git-core
sudo apt-get -y install gcc 
sudo apt-get -y install make 
sudo apt-get -y install bc
sudo apt-get -y install screen
sudo apt-get -y install ncurses-dev
sudo apt-get -y install autoconf
sudo apt-get -y install automake 
sudo apt-get -y install autogen
sudo apt-get -y install checkinstall
sudo apt-get -y install libtool
sudo apt-get -y install gettext
sudo apt-get -y install texinfo
sudo apt-get -y install texi2html 
sudo apt-get -y install build-essential
sudo apt-get -y install cmake
sudo apt-get -y install pkg-config 
sudo apt-get -y install texinfo
sudo apt-get -y install doxygen
sudo apt-get -y install lzip
# mercurial for h265
sudo apt-get -y install mercurial cmake-curses-gui 

checkPressEnterYN

#-- none of these ---
#sudo apt-get install -y libavcodec-dev
#sudo apt-get install -y libtool
#sudo apt-get install -y libtool-dev
#sudo apt-get install -y libmp3lame-dev
#sudo apt-get install -y libasound2-dev 
#sudo apt-get install -y libssl-dev
#sudo apt-get install -y libass-dev
#sudo apt-get install -y libpq-dev
#sudo apt-get install -y zlib1g-dev 
#sudo apt-get install -y libgpac-dev 
#sudo apt-get install -y fftw3-dev 
#sudo apt-get install -y libfftw3-dev
#sudo apt-get install -y libavutil-dev
#sudo apt-get install -y libavformat-dev
#sudo apt-get install -y libbz2-dev
#sudo apt-get install -y libfreetype6-dev 
#or sudo apt-get install -y freetype-devel
#sudo apt-get install -y libsdl1.2-dev 
#sudo apt-get install -y libtheora-dev 
#sudo apt-get install -y libvdpau-dev 
#sudo apt-get install -y libvorbis-dev 
#sudo apt-get install -y libva-dev 
#sudo apt-get install -y libva1 
#sudo apt-get install -y libva1-dev 
#sudo apt-get install -y libavutil51
#sudo apt-get install -y libavformat53
#sudo apt-get install -y libavcodec53
#sudo apt-get install -y libavcodec-extra-53
#sudo apt-get install -y libavfilter2
#sudo apt-get install -y libavdevice53
##sudo apt-get install -y libpq5
##sudo apt-get install -y libmysqlclient18 libmysqlclient-dev
#sudo apt-get install -y gpac
#sudo apt-get install -y gpac-dev
#- but not these since I want to build them myself if i can
#sudo apt-get install -y libx264-dev
#sudo apt-get install -y libvpx-dev
#sudo apt-get install -y libxvid-dev
#sudo apt-get install -y libaacplus-dev
#sudo apt-get install -y librtmp-dev
#sudo apt-get install -y ffmpeg-dev
#-
#?????????? newer packages, check them out later
#old:
#sudo apt-get install -y libjpeg62 
#sudo apt-get install -y libjpeg62-dev
#new:
#sudo apt-get install -y libjpeg-dev
#sudo apt-get install -y libjpeg8
#sudo apt-get install -y libjpeg8-dev
#?????????? newer packages, check them out later
#old:
#sudo apt-get install -y libc6
#sudo apt-get install -y libc6-dev
#new:
#sudo apt-get install -y libc6.1
#sudo apt-get install -y libc6.1-dev
#-
#-----
#checkPressEnterYN

sudo apt-get remove -y ffmpeg-dev
sudo apt-get remove -y ffmpeg

#------------------------------
# build sources in /usr/src. 
sudo mkdir /usr/src
sudo chmod -R 777 /usr/src
cd /usr/src
#
#-----
# build the FAAC aac LC module
# --libfaac
# It installes the resulting library in /usr/local/lib/libfaac.
sudo apt-get remove -y libfaac-dev
sudo apt-get remove -y libfaac 
sudo apt-get remove -y libaacplus-dev
sudo apt-get remove -y libaacplus 
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir faac-1.28
   sudo chmod -R 777 faac-1.28
   sudo rm -rf faac-1.28
   sudo mkdir faac-1.28
   sudo chmod -R 777 faac-1.28
   sudo curl -#LO http://downloads.sourceforge.net/project/faac/faac-src/faac-1.28/faac-1.28.tar.gz
   sudo tar xzvf faac-1.28.tar.gz
else
   sudo chmod -R 777 faac-1.28
fi
cd /usr/src/faac-1.28
# there HAS to be a way to automate this. I don;t know how, yet.
set +x
echo "#When you’re in the nano editor, you will need to go to line 126. "
echo "#Once you’re at that line, make the below code THE SAME as below … COPY THIS TEXT FIRST"
echo "#Once you’re at that line, make the below code THE SAME as below … COPY THIS TEXT FIRST"
echo "#Once you’re at that line, make the below code THE SAME as below … COPY THIS TEXT FIRST"
echo "#ifdef __cplusplus"
echo "extern \"C\" {"
echo "#endif"
echo "#ifndef _STRING_H"
echo "char *strcasestr(const char *haystack, const char *needle);"
echo "#endif"
echo "#ifdef __cplusplus"
echo "}"
echo "#endif"
echo " "
read -p "Press Enter to EDIT the file using sudo nano common/mp4v2/mpeg4ip.h   " xx 
set -x
sudo nano common/mp4v2/mpeg4ip.h
read -p "Press Enter to continue AFTER your editing  sudo nano common/mp4v2/mpeg4ip.h" xx 
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --disable-asm --host=arm-unknown-linux-gnueabi --enable-static --disable-shared  
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN 
#
#-----
# --enable-libx265
#FFmpeg can make use of the x265 library for HEVC encoding.
#Go to http://x265.org/developers.html and follow the instructions for installing the library. 
#Then pass --enable-libx265 to configure to enable it.
#x265 is under the GNU Public License Version 2 or later 
#(see http://www.gnu.org/licenses/old-licenses/gpl-2.0.html for details), 
#you must upgrade FFmpeg’s license to GPL in order to use it.
#
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir x265-1.5
   sudo chmod -R 777 x265-1.5
   sudo rm -rf x265-1.5
   sudo mkdir x265-1.5
   sudo chmod -R 777 x265-1.5
   #sudo hg clone https://bitbucket.org/multicoreware/x265 
   sudo wget http://ffmpeg.zeranoe.com/builds/source/external_libraries/x265-1.5.tar.xz
   sudo tar xf x265-1.5.tar.xz
else
   sudo chmod -R 777 x265-1.5
fi
cd /usr/src/x265-1.5/build/linux
#echo "Make sure shared is OFF in the settings for ./make-Makefiles.bash"
#echo "Then press the letter c"
#echo "Then press the letter g"
#checkPressEnterYN 
# The instructions to build, say do this
#sudo ./make-Makefiles.bash
# that line above actually does 
#   cmake -G "Unix Makefiles" ../../source && ccmake ../../source
# so instead we will do them manually ourselves 
# so we can set the static flag using -DENABLE_SHARED:BOOL=OFF
# About   sudo ccmake ../../source
# wiki says  (ccmake is curses cmake (curses is the terminal gui))
# and seems likely only used to check/set variables, so lets not do it
# since we can setup for static using -DENABLE_SHARED:BOOL=OFF 
# Also, oh joy, configure does not exist so we cannot do this
#sudo ./configure --disable-asm --host=arm-unknown-linux-gnueabi --enable-static --disable-shared   
# somehow add these 
#--host=arm-unknown-linux-gnueabi 
#--enable-static 
# http://www.cmake.org/Wiki/CMake_Cross_Compiling 
# http://stackoverflow.com/questions/5139403/whats-the-difference-of-configure-option-build-host-and-target
# so we will not do sudo ccmake ../../source
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo cmake -G "Unix Makefiles" ../../source -DENABLE_SHARED:BOOL=OFF -DCMAKE_SYSTEM_NAME:STRING=Linux
sudo cmake -G "Unix Makefiles" ../../source -DENABLE_SHARED:BOOL=OFF -DCMAKE_C_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm" -DCMAKE_CXX_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo ccmake  ../../source 
# Oh joy it won't build properly for the raspberry pi2 since it spits out this error ...
#   -- CMAKE_SYSTEM_PROCESSOR value `armv7l` is unknown
#   -- Please add this value near /usr/src/x265-1.5/source/CMakeLists.txt:55
# but looking at it, instead we can add the missing bits with CFLAGS !
#cd ../../source
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN 
#
#-----
# advice from one post :-
# I first built the assembler YASM, but I now believe this step is unnecessary.
# So, it is important to include the flag to disable the use of the assembler.
# ie skip this YASM step below
## an assembler used by x264 and ffmpeg
#cd /usr/src
#wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
#tar xzvf yasm-1.2.0.tar.gz
#cd yasm-1.2.0
#./configure
#make
#sudo make install
# So, it is important to include the flag to disable the use of the assembler.
#
#-----
# --libx264
# build x264
sudo apt-get remove -y libx264-dev
sudo apt-get remove -y libx264 
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir x264
   sudo chmod -R 777 x264
   sudo rm -rf x264
   sudo mkdir x264
   sudo chmod -R 777 x264
   sudo git clone git://git.videolan.org/x264
else
   sudo chmod -R 777 x264
fi
cd /usr/src/x264
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --disable-asm --host=arm-unknown-linux-gnueabi --enable-static --disable-opencl  --extra-cflags="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations"
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
# --libmp3lame
# build a lame MP3 encoder. 
# It installs the resulting library in /usr/local/lib/libmp3lame
sudo apt-get remove -y libmp3lame-dev
sudo apt-get remove -y libmp3lame
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir lame-3.99
   sudo chmod -R 777 lame-3.99
   sudo rm -rf lame-3.99
   sudo mkdir lame-3.99
   sudo chmod -R 777 lame-3.99
   sudo wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.tar.gz
   sudo tar xzvf lame-3.99.tar.gz
else
   sudo chmod -R 777 lame-3.99
fi
cd /usr/src/lame-3.99
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN 
#
#-----
# --libvpx
# build a LIBVPX video encoder 
# It installs the resulting library in /usr/local/lib/libvpx ??
# libvpx is an emerging open video compression library which is gaining popularity for distributing high definition video content on the internet. 
# FFmpeg supports using the libvpx library to compress video content. To acquire and build libvpx, perform the following:
sudo apt-get remove -y libvpx-dev
sudo apt-get remove -y libvpx
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir libvpx
   sudo chmod -R 777 libvpx
   sudo rm -rf libvpx
   sudo mkdir libvpx
   sudo chmod -R 777 libvpx
   sudo git clone http://git.chromium.org/webm/libvpx.git
else
   sudo chmod -R 777 libvpx
fi
cd /usr/src/libvpx
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --enable-static --disable-shared --disable-examples --enable-vp8 --enable-vp9 --enable-webm-io --enable-libyuv --extra-cflags="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo make -j4
#sudo make install
sudo checkinstall --pkgname=libvpx --pkgversion="1:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
sudo ldconfig
checkPressEnterYN 
#
#-----
#The GnuTLS (TLS security) Transport Layer Security Library
# note: do not bother ... gmplib will NOT configure before the make
# note: do not bother ... gmplib will NOT configure before the make
#   dependencies: nettle gmplib
#http://www.lysator.liu.se/~nisse/nettle/
#The public git repository for Nettle is located at git.lysator.liu.se. 
# After checkout, you need to run the .bootstrap script before the standard ./configure && make.
#https://ftp.gnu.org/gnu/nettle/nettle-3.0.tar.gz
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir nettle-3.0
   #sudo chmod -R 777 nettle-3.0
   #sudo rm -rf nettle-3.0
   #sudo mkdir nettle-3.0
   #sudo chmod -R 777 nettle-3.0
   #sudo wget https://ftp.gnu.org/gnu/nettle/nettle-3.0.tar.gz
   #sudo tar xzvf nettle-3.0.tar.gz
#else
  #sudo chmod -R 777 nettle-3.0
 #fi
#cd /usr/src/nettle-3.0
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --disable-assembler 
#sudo make -j4
#sudo make install
#sudo ldconfig
#checkPressEnterYN 
#https://gmplib.org/
#https://gmplib.org/download/gmp/gmp-6.0.0a.tar.lz
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir gmp-6.0.0
   #sudo chmod -R 777 gmp-6.0.0
   #sudo rm -rf gmp-6.0.0
   #sudo mkdir gmp-6.0.0
   #sudo chmod -R 777 gmp-6.0.0
   #sudo wget https://gmplib.org/download/gmp/gmp-6.0.0a.tar.lz
   #sudo tar --lzip -xvf gmp-6.0.0a.tar.lz
#else
   #sudo chmod -R 777 gmp-6.0.0
#fi
#cd /usr/src/gmp-6.0.0
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo ./configure --build=arm --host=arm-unknown-linux-gnueabi --enable-static --disable-shared  --enable-fft
#sudo make -j4
#sudo make install
#sudo ldconfig
#checkPressEnterYN 
# Now build the main GnuTLS
#http://gnutls.org/
#ftp://ftp.gnutls.org/gcrypt/gnutls/v3.3/gnutls-3.3.12.tar.xz
#checkPressEnterYN 
#
#-----
# build an rtmp module
# It installs the resulting library in /usr/local/lib/librtmp ??
# librtmp provides support for the RTMP content streaming protocol developed by Adobe 
# and commonly used to distribute content to flash video players on the web. 
# FFmpeg supports using the librtmp library to stream content from RTMP sources. 
sudo apt-get remove -y rtmpdump-dev
sudo apt-get remove -y rtmpdump
sudo apt-get install -y libssl-dev
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir rtmpdump
   sudo chmod -R 777 rtmpdump
   sudo rm -rf rtmpdump
   sudo mkdir rtmpdump
   sudo chmod -R 777 rtmpdump
   sudo git clone git://git.ffmpeg.org/rtmpdump
else
   sudo chmod -R 777 rtmpdump
fi
cd /usr/src/rtmpdump
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export XCFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo make -j4 SYS=posix XCFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo checkinstall --pkgname=rtmpdump --pkgversion="2:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default
sudo ldconfig
checkPressEnterYN 
#
#-----
# 5. do NOT build an aac HC module - instead rely on libfaac which is LC
#Downloading Compiling LibaacPlus - HC
## LIBAACPLUS AAC ENCODER encoder
# cd /usr/src
# sudo mkdir libaacplus-2.0.2
# sudo chmod -R 777 libaacplus-2.0.2
# sudo rm -rf libaacplus-2.0.2
# sudo mkdir libaacplus-2.0.2
# sudo chmod -R 777 libaacplus-2.0.2
# sudo wget http://tipok.org.ua/downloads/media/aacplus/libaacplus/libaacplus-2.0.2.tar.gz
# sudo tar -xzf libaacplus-2.0.2.tar.gz
# cd libaacplus-2.0.2
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
# sudo ./autogen.sh --with-parameter-expansion-string-replace-capable-shell=/bin/bash --host=arm-unknown-linux-gnueabi --enable-static --disable-shared
# sudo make
# sudo make install
# sudo ldconfig
#
#--------------------------
# ?? --enable-libfdk-aac
# not the libfaac above
# fdk-aac
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir fdk-aac
   sudo chmod -R 777 fdk-aac
   sudo rm -rf fdk-aac
   sudo mkdir fdk-aac
   sudo chmod -R 777 fdk-aac
   sudo git clone --depth 1 git://github.com/mstorsjo/fdk-aac
else
   sudo chmod -R 777 fdk-aac
fi
cd /usr/src/fdk-aac
#sudo autoreconf -i
sudo autoreconf -fiv
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared   
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
# No, do not build the ALSA as there's no ffmpeg -- switch to enable it. Work it out another year.
# ?? --extra-libs=-lasound
#wget http://mirrors.zerg.biz/alsa/lib/alsa-lib-1.0.25.tar.bz2
#tar xjf alsa-lib-1.0.25.tar.bz2
#cd alsa-lib-1.0.25
#checkPressEnterYN
#
#-----
# build libxvid, google to find out how
sudo apt-get remove -y libxvid-dev
sudo apt-get remove -y libxvid 
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir xvidcore
   sudo chmod -R 777 xvidcore
   sudo rm -rf xvidcore
   sudo mkdir xvidcore
   sudo chmod -R 777 xvidcore
   sudo wget http://downloads.xvid.org/downloads/xvidcore-1.3.3.tar.gz
   sudo tar xzvf xvidcore-1.3.3.tar.gz
else
   sudo chmod -R 777 xvidcore
fi
#cd xvidcore
cd /usr/src/xvidcore/build/generic 
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --disable-asm --disable-avs --disable-cli --host=arm-unknown-linux-gnueabi --enable-static --disable-shared   
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
# build libwebp
# --enable-libwebp
#WebP is a new image format that provides lossless and lossy compression for images on the web
#https://developers.google.com/speed/webp/
#http://downloads.webmproject.org/releases/webp/libwebp-0.4.2.tar.gz
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/libwebp-0.4.2.tar.xz
#Install the packages needed to convert between JPEG, PNG, TIFF, GIF and WebP image formats.
sudo apt-get install -y libjpeg-dev 
sudo apt-get install -y libpng-dev
sudo apt-get install -y libtiff-dev
sudo apt-get install -y libgif-dev
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir libwebp-0.4.2
   sudo chmod -R 777 libwebp-0.4.2
   sudo rm -rf libwebp-0.4.2
   sudo mkdir libwebp-0.4.2
   sudo chmod -R 777 libwebp-0.4.2
   sudo wget http://downloads.webmproject.org/releases/webp/libwebp-0.4.2.tar.gz
   sudo tar xvzf libwebp-0.4.2.tar.gz
else
   sudo chmod -R 777 libwebp-0.4.2
fi
cd /usr/src/libwebp-0.4.2
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --enable-libwebpmux --enable-libwebpdemux --enable-libwebpdecoder
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
# build libvorbis.
# --enable-libvorbis 
# Prerequisite: libogg 
#http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir libogg-1.3.2
   sudo chmod -R 777 libogg-1.3.2
   sudo rm -rf libogg-1.3.2
   sudo mkdir libogg-1.3.2
   sudo chmod -R 777 libogg-1.3.2
   sudo wget http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
   sudo tar xzvf libogg-1.3.2.tar.gz
else
   sudo chmod -R 777 libogg-1.3.2
fi
cd /usr/src/libogg-1.3.2
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir vorbis-tools-1.4.0
   sudo chmod -R 777 vorbis-tools-1.4.0
   sudo rm -rf vorbis-tools-1.4.0
   sudo mkdir vorbis-tools-1.4.0
   sudo chmod -R 777 vorbis-tools-1.4.0
   sudo wget http://downloads.xiph.org/releases/vorbis/vorbis-tools-1.4.0.tar.gz
   sudo tar xzvf vorbis-tools-1.4.0.tar.gz
else
   sudo chmod -R 777 vorbis-tools-1.4.0
fi
cd /usr/src/vorbis-tools-1.4.0
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --enable-threads=posix --disable-oggtest --disable-vorbistest --disable-curltest 
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir libvorbis-1.3.4
   sudo chmod -R 777 libvorbis-1.3.4
   sudo rm -rf libvorbis-1.3.4
   sudo mkdir libvorbis-1.3.4
   sudo chmod -R 777 libvorbis-1.3.4
   sudo wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
   sudo tar xzvf libvorbis-1.3.4.tar.gz
else
   sudo chmod -R 777 libvorbis-1.3.4
fi
cd /usr/src/libvorbis-1.3.4
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --disable-oggtest  
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
# build libtheora, google to find out how
# --enable-libtheora 
# depends on libogg, libvorbis built first
#http://theora.org/
#The libtheora implementation depends on the following libraries...
#libogg-1.3.1
#libvorbis-1.3.3
#libSDL 1.2 or later for the playback example
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/libtheora-1.1.1.tar.xz
#http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2
#
sudo apt-get install -y libsdl1.2-dev
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir libtheora-1.1.1
   sudo chmod -R 777 libtheora-1.1.1
   sudo rm -rf libtheora-1.1.1
   sudo mkdir libtheora-1.1.1
   sudo chmod -R 777 libtheora-1.1.1
   sudo wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2
   sudo tar jxf libtheora-1.1.1.tar.bz2
else
   sudo chmod -R 777 libtheora-1.1.1
fi
cd /usr/src/libtheora-1.1.1
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --disable-asm --disable-oggtest --disable-vorbistest --disable-sdltest --disable-examples 
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
# build fontconfig
# --enable-fontconfig
# dependencies:  
#Fontconfig is a library for configuring and customizing font access.
#http://freedesktop.org/wiki/Software/fontconfig/
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir fontconfig
   sudo chmod -R 777 fontconfig
   sudo rm -rf fontconfig
   sudo mkdir fontconfig
   sudo chmod -R 777 fontconfig
   sudo git clone git://anongit.freedesktop.org/fontconfig
else
   sudo chmod -R 777 fontconfig
fi
cd fontconfig
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
./autogen.sh --sysconfdir=/etc --prefix=/usr --mandir=/usr/share/man --localstatedir=/var
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --enable-iconv --enable-libxml2
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN#
#
#-----
# build libass, google to find out how
# --enable-libass
#libass is a portable subtitle renderer for the ASS/SSA (Advanced Substation Alpha/Substation Alpha) subtitle format
#https://code.google.com/p/libass/
# dependencies:  fontconfig libfribidi gperf  iconv
# http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
sudo apt-get install -y libfribidi-dev 
sudo apt-get install -y gperf 
sudo apt-get install -y libxml2-dev
#
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir libiconv-1.14
   sudo chmod -R 777 libiconv-1.14
   sudo rm -rf libiconv-1.14
   sudo mkdir libiconv-1.14
   sudo chmod -R 777 libiconv-1.14
   sudo wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
   sudo tar xzvf libiconv-1.14.tar.gz
else
   sudo chmod -R 777 libiconv-1.14
fi
cd /usr/src/libiconv-1.14
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --disable-asm
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir libass
   sudo chmod -R 777 libass
   sudo rm -rf libass
   sudo mkdir libass
   sudo chmod -R 777 libass
   sudo git clone https://github.com/libass/libass.git
else
   sudo chmod -R 777 libass
fi
cd /usr/src/libass
export COVERITY_SCAN_TOKEN=[secure]
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./autogen.sh 
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --disable-asm 
export PROJECT_NAME=libass/libass
sudo make -j4
sudo make all-recursive
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
#--enable-bzlib 
sudo apt-get install -y libzip-dev
sudo ldconfig
# bzip2 is a freely available, patent free, high-quality data compresso
#http://bzip.org/
#http://bzip.org/1.0.6/bzip2-1.0.6.tar.gz
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir bzip2-1.0.6
   sudo chmod -R 777 bzip2-1.0.6
   sudo rm -rf bzip2-1.0.6
   sudo mkdir bzip2-1.0.6
   sudo chmod -R 777 bzip2-1.0.6
   sudo wget http://bzip.org/1.0.6/bzip2-1.0.6.tar.gz
   sudo tar xzvf bzip2-1.0.6.tar.gz
else
   sudo chmod -R 777 bzip2-1.0.6
fi
cd /usr/src/bzip2-1.0.6
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
# do NOT try to make this
# --enable-libbluray 
#http://www.videolan.org/developers/libbluray.html
# do NOT try to make this
#
#-----
#--enable-libbs2b 
# dependency: libsndfile
#http://sourceforge.net/projects/bs2b/files/libbs2b/3.1.0/
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/libbs2b-3.1.0.tar.xz
#http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz
# git clone git://github.com/erikd/libsndfile.git
#
# first the dependency
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir libsndfile
   #sudo chmod -R 777 libsndfile
   #sudo rm -rf libsndfile
   #sudo mkdir libsndfile
   #sudo chmod -R 777 libsndfile
   #sudo git clone git://github.com/erikd/libsndfile.git
#else
   #sudo chmod -R 777 libsndfile
#fi
#cd /usr/src/libsndfile
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo ./autogen.sh
## configure will tell us this.  we don't care, for now.
## * External libs (FLAC, Ogg, Vorbis) disabled.
## * configure: WARNING: *** One or more of the external libraries (ie libflac, libogg and
## * configure: WARNING: *** libvorbis) is either missing (possibly only the development
## * configure: WARNING: *** headers) or is of an unsupported version.
## * Unfortunately, for ease of maintenance, the external libs are an all or nothing affair. 
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --enable-stack-smash-protection --disable-sqlite --disable-alsa --disable-external-libs --enable-sanitizer 
## results in 
##Compiling some other packages against libsndfile may require
##the addition of '/usr/local/lib/pkgconfig' to the
##PKG_CONFIG_PATH environment variable.
#sudo make -j4
#sudo make -j4 check
#sudo make install
#sudo ldconfig
#checkPressEnterYN
## now for libbs2b
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir libbs2b-3.1.0
   #sudo chmod -R 777 libbs2b-3.1.0
   #sudo rm -rf libbs2b-3.1.0
   #sudo mkdir libbs2b-3.1.0
   #sudo chmod -R 777 libbs2b-3.1.0
   #sudo wget http://ffmpeg.zeranoe.com/builds/source/external_libraries/libbs2b-3.1.0.tar.xz
   #sudo tar xf libbs2b-3.1.0.tar.xz
#else
   #sudo chmod -R 777 libbs2b-3.1.0
#fi
#cd /usr/src/libbs2b-3.1.0
### PKG_CONFIG_PATH from libsndfile above
#export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export LIBS="-lm"
#sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
#sudo make -j4
## well, this make fails and I dont know why
##gcc -g -O2 -o bs2bconvert bs2bconvert.o  -lsndfile ./.libs/libbs2b.a
##./.libs/libbs2b.a(bs2b.o): In function `init':
##/usr/src/libbs2b-3.1.0/src/bs2b.c:161: undefined reference to `pow'
##/usr/src/libbs2b-3.1.0/src/bs2b.c:162: undefined reference to `pow'
##/usr/src/libbs2b-3.1.0/src/bs2b.c:163: undefined reference to `log10'
##/usr/src/libbs2b-3.1.0/src/bs2b.c:163: undefined reference to `pow'
##/usr/src/libbs2b-3.1.0/src/bs2b.c:170: undefined reference to `exp'
##/usr/src/libbs2b-3.1.0/src/bs2b.c:174: undefined reference to `exp'
##/usr/src/libsndfile/src/pcm.c:2587: undefined reference to `lrint'
#sudo make install
#sudo ldconfig
#export -n PKG_CONFIG_PATH
#export -n LIBS
#checkPressEnterYN
#
#-----
#--enable-libfreetype 
#http://freetype.sourceforge.net/freetype2/index.html
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/freetype-2.5.4.tar.xz
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir freetype-2.5.4
   sudo chmod -R 777 freetype-2.5.4
   sudo rm -rf freetype-2.5.4
   sudo mkdir freetype-2.5.4
   sudo chmod -R 777 freetype-2.5.4
   sudo wget http://ffmpeg.zeranoe.com/builds/source/external_libraries/freetype-2.5.4.tar.xz
   sudo tar xf freetype-2.5.4.tar.xz
else
   sudo chmod -R 777 freetype-2.5.4
fi
cd /usr/src/freetype-2.5.4
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
#The OpenJPEG library is an open-source JPEG 2000 codec
#--enable-libopenjpeg 
#http://www.openjpeg.org/
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/openjpeg-1.5.2.tar.xz
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir openjpeg-1.5.2
   sudo chmod -R 777 openjpeg-1.5.2
   sudo rm -rf openjpeg-1.5.2
   sudo mkdir openjpeg-1.5.2
   sudo chmod -R 777 openjpeg-1.5.2
   sudo wget http://ffmpeg.zeranoe.com/builds/source/external_libraries/openjpeg-1.5.2.tar.xz
   sudo tar xf openjpeg-1.5.2.tar.xz
else
   sudo chmod -R 777 openjpeg-1.5.2
fi
cd /usr/src/openjpeg-1.5.2
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./bootstrap.sh
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --enable-mj2 --enable-jpwl --enable-jpip
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
#--enable-libsoxr 
#http://sourceforge.net/projects/soxr/
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/soxr-0.1.1.tar.xz
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir soxr-0.1.1
   sudo chmod -R 777 soxr-0.1.1
   sudo rm -rf soxr-0.1.1
   sudo mkdir soxr-0.1.1
   sudo chmod -R 777 osoxr-0.1.1
   sudo wget http://ffmpeg.zeranoe.com/builds/source/external_libraries/soxr-0.1.1.tar.xz
   sudo tar xf soxr-0.1.1.tar.xz
else
   sudo chmod -R 777 osoxr-0.1.1
fi
cd /usr/src/soxr-0.1.1
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#cmake --help
#cmake [OPTIONS] ..
#sudo ./go
cmake -G "Unix Makefiles" ./ -DCMAKE_C_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm" -DCMAKE_CXX_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm"
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo make -j4 
sudo make test
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
#TwoLAME is an optimised MPEG Audio Layer 2 (MP2) encoder
#--enable-libtwolame 
#http://twolame.org/
#http://downloads.sourceforge.net/twolame/twolame-0.3.13.tar.gz
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/twolame-0.3.13.tar.xz
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir twolame-0.3.13
   sudo chmod -R 777 twolame-0.3.13
   sudo rm -rf twolame-0.3.13
   sudo mkdir twolame-0.3.13
   sudo chmod -R 777 twolame-0.3.13
   sudo wget http://ffmpeg.zeranoe.com/builds/source/external_libraries/twolame-0.3.13.tar.xz
   sudo tar xf twolame-0.3.13.tar.xz
else
   sudo chmod -R 777 twolame-0.3.13
fi
cd /usr/src/twolame-0.3.13
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
#WavPack is a completely open audio compression format 
#--enable-libwavpack 
#http://wavpack.com/
#http://wavpack.com/wavpack-4.70.0.tar.bz2
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/wavpack-4.70.0.tar.xz
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir wavpack-4.70.0
   sudo chmod -R 777 wavpack-4.70.0
   sudo rm -rf wavpack-4.70.0
   sudo mkdir wavpack-4.70.0
   sudo chmod -R 777 wavpack-4.70.0
   sudo wget http://ffmpeg.zeranoe.com/builds/source/external_libraries/wavpack-4.70.0.tar.xz
   sudo tar xf wavpack-4.70.0.tar.xz
else
   sudo chmod -R 777 wavpack-4.70.0
fi
cd /usr/src/wavpack-4.70.0
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
#--enable-lzma 
#http://tukaani.org/xz/
#http://tukaani.org/xz/xz-5.2.0.tar.gz
#http://tukaani.org/xz/xz-5.2.0.tar.xz
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/xz-5.2.0.tar.xz
#git clone http://git.tukaani.org/xz.git
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir xz-5.2.0
   sudo chmod -R 777 xz-5.2.0
   sudo rm -rf xz-5.2.0
   sudo mkdir xz-5.2.0
   sudo chmod -R 777 xz-5.2.0
   sudo wget http://tukaani.org/xz/xz-5.2.0.tar.xz
   sudo tar xf xz-5.2.0.tar.xz
else
   sudo chmod -R 777 xz-5.2.0
fi
cd /usr/src/xz-5.2.0
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --disable-assembler --disable-scripts --disable-lzma-links --disable-doc
#sudo ./configure --host=armv71-unknown-linux-gnueabihf --enable-static --disable-shared --disable-assembler --disable-scripts --disable-lzma-links --disable-doc
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
# --enable-zlib
#http://zlib.net/
#http://ffmpeg.zeranoe.com/builds/source/external_libraries/zlib-1.2.8.tar.xz
#http://zlib.net/zlib-1.2.8.tar.xz
cd /usr/src
if [[ "$dlYN" =~ ^([yY]) ]] ; then
   sudo mkdir zlib-1.2.8
   sudo chmod -R 777 zlib-1.2.8
   sudo rm -rf zlib-1.2.8
   sudo mkdir zlib-1.2.8
   sudo chmod -R 777 zlib-1.2.8
   sudo wget http://zlib.net/zlib-1.2.8.tar.xz
   sudo tar xf zlib-1.2.8.tar.xz
else
   sudo chmod -R 777 zlib-1.2.8
fi
cd /usr/src/zlib-1.2.8
export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
sudo ./configure --static 
sudo make -j4
sudo make install
sudo ldconfig
checkPressEnterYN
#
#-----
# build frei0r -- GIVE UP, SEE BELOW OPENCV fails to compile
# --enable-frei0r
# Frei0r is a minimalistic plugin API for video effects. 
#DEPENDENCIES:
# frei0r can be built linking the following libraries:
# Gavl – required for the scale0tilt and vectorscope filters
#        http://gmerlin.sourceforge.net/
# OpenCV – required for face detection filters
#        http://gmerlin.sourceforge.net/
# Cairo – required for some fine color blending mixers
#        http://gmerlin.sourceforge.net/
#        Please download one of the latest releases in order to get an API-stable version of cairo. 
#        You'll need both the cairo and pixman packages.
#
# so ... we build all the prerequisites just to build build frei0r
#
# Gavl
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir gavl-1.4.0
   #sudo chmod -R 777 gavl-1.4.0
   #sudo rm -rf gavl-1.4.0
   #sudo mkdir gavl-1.4.0
   #sudo chmod -R 777 gavl-1.4.0
   #wget http://internode.dl.sourceforge.net/project/gmerlin/gavl/1.4.0/gavl-1.4.0.tar.gz
   #sudo tar xzvf gavl-1.4.0.tar.gz
#else
   #sudo chmod -R 777 gavl-1.4.0
#fi
#cd /usr/src/gavl-1.4.0
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
#sudo make -j4
#sudo make install
#sudo ldconfig
#checkPressEnterYN
# Opencv ... but requires prerequisites
#Prerequsites for OpenCV:  VTK
#CMake 2.6 or higher;
#Depending on target platform you need to choose gnueabi or gnueabihf tools. 
#Install command for gnueabi:
#   sudo apt-get install gcc-arm-linux-gnueabi
#Install command for gnueabihf:
#   sudo apt-get install gcc-arm-linux-gnueabihf
#pkgconfig;
#Python 2.6 for host system
#[optional] libav development packages for armeabi(hf): libavcodec-dev, libavformat-dev, libswscale-dev;
#[optional] libdc1394 2.x;
#[optional] libjpeg-dev, libpng-dev, libtiff-dev, libjasper-dev for armeabi(hf).
## ?? VTK?? # http://www.vtk.org/VTK/project/about.html
## WAS LAZY AND USED THE OLD STANDARD -dev LIBRARIES FOR THE PI
#sudo apt-get install -y libjpeg-dev
#sudo apt-get install -y libpng-dev
#sudo apt-get install -y libtiff-dev
#sudo apt-get install -y libjasper-dev
#sudo apt-get remove  -y ffmpeg
#sudo apt-get remove  -y ffmpeg-dev
## I cant get VTK to build
### OpenCV prerequisite ?? VTK??  http://www.vtk.org/VTK/project/about.html
## The Visualization Toolkit (VTK) is an open-source, freely available software system 
## for 3D computer graphics, modeling, image processing, volume rendering, 
## scientific visualization, and information visualization.
## http://www.vtk.org/Wiki/VTK/Building/Linux
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir VTK
   #sudo chmod -R 777 VTK
   #sudo rm -rf VTK
   #sudo mkdir VTK
   #sudo chmod -R 777 VTK
   #sudo git clone git://vtk.org/VTK.git
#else
   #sudo chmod -R 777 VTK
#fi
#cd /usr/src/VTK
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE:STRING="Release" -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_C_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm" -DCMAKE_CXX_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm" ./ 
#sudo make -j4
#sudo make install
#sudo ldconfig
#checkPressEnterYN
## now openCV
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir opencv
   #sudo chmod -R 777 opencv
   #sudo rm -rf opencv
   #sudo mkdir opencv
   #sudo chmod -R 777 opencv
   #sudo git clone https://github.com/itseez/opencv
#else
   #sudo chmod -R 777 opencv
#fi
#cd /usr/src/opencv
##cd /usr/src/opencv/platforms/linux
#cd platforms/linux
##========================
## http://www.cmake.org/pipermail/cmake/2009-April/028853.html
## for cmake, either 
##   THIS DOES NOT WORK FOR OPENCV set the environment variables CFLAGS and CPPFLAGS 
##   before running cmake initially, AFAIK cmake will pick them up then.
## or
##   set the cmake variables CMAKE_C_FLAGS and CMAKE_CXX__FLAGS in your cmake commandline
## NOTE:
## http://answers.opencv.org/question/4934/setting-cflags-and-cxxflags-for-opencv-243/
## As of OpenCV 2.4.3 the CMake scripts seem to be 
## actively ignoring/resetting the user specified CFLAGS
## So ... set the cmake variables CMAKE_C_FLAGS and CMAKE_CXX__FLAGS in your 
## cmake commandline like this
## sudo cmake -G "Unix Makefiles" ../../ -DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_NEON:BOOL=ON -DINSTALL_TESTS:BOOL=ON -DWITH_FFMPEG:BOOL=ON -DCMAKE_C_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm" -DCMAKE_CXX_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm"
##========================
## npr.cpp fails to compile, it says use -fPIC sp lets try the -fPIC flag above
## BUT when we add -fPIC to the compiler flags, the other stuff crashes ... we cant win.
## GIVE UP NOW
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm"
#sudo cmake -G "Unix Makefiles" ../../ -DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_NEON:BOOL=ON -DINSTALL_TESTS:BOOL=ON -DWITH_FFMPEG:BOOL=ON -DCMAKE_C_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm" -DCMAKE_CXX_FLAGS:STRING="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -fPIC -lm"
##sudo cmake -G "Unix Makefiles" ../../ -DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_NEON:BOOL=ON -DINSTALL_TESTS:BOOL=ON -DWITH_FFMPEG:BOOL=ON 
## ????????????????? CMAKE_EXE_LINKER_FLAGS set -lpthread -lrt (two extra system library needed for OpenCV)
##YES YES we know VTK is not built. Lets see if opencv builds without VTK anyway
#sudo make -j4
#sudo make install
#sudo ldconfig
#checkPressEnterYN
## Cairo – required for some fine color blending mixers
## dependencies - pixman
## To compile the clone, you need to run ./autogen.sh initially 
## and then follow the instructions in the file named INSTALL.
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir pixman
   #sudo chmod -R 777 pixman
   #sudo rm -rf pixman
   #sudo mkdir pixman
   #sudo chmod -R 777 pixman
   #sudo git clone git://anongit.freedesktop.org/git/pixman
#else
   #sudo chmod -R 777 pixman
#if
#cd /usr/src/pixman
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"#sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
#sudo make -j4
#sudo make install
#sudo ldconfig
#checkPressEnterYN
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir cairo
   #sudo chmod -R 777 cairo
   #sudo rm -rf cairo
   #sudo mkdir cairo
   #sudo chmod -R 777 cairo
   #sudo git clone git://anongit.freedesktop.org/git/cairo
#else
   #sudo chmod -R 777 cairo
#fi
#cd /usr/src/cairo
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"#sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared 
#sudo make -j4
#sudo make install
#sudo ldconfig
#checkPressEnterYN
## at last ...
## frei0r - remember to do the autogen
#cd /usr/src
#if [[ "$dlYN" =~ ^([yY]) ]] ; then
   #sudo mkdir frei0r
   #sudo chmod -R 777 frei0r
   #sudo rm -rf frei0r
   #sudo mkdir frei0r
   #sudo chmod -R 777 frei0r
   #sudo git clone git://code.dyne.org/frei0r.git
#else
   #sudo chmod -R 777 frei0r
#fi
#cd /usr/src/frei0r
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo ./autogen.sh --help
# sudo ./configure --help
#export CFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CXXFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#export CPPFLAGS="-march=armv7-a -mfpu=$themfpu -mfloat-abi=hard -funsafe-math-optimizations -lm"
#sudo ./configure --host=arm-unknown-linux-gnueabi --enable-static --disable-shared --enable-cpuflags
#sudo make -j4
#sudo make install
#sudo ldconfig
#checkPressEnterYN
##
#-----

echo "#"
echo "# do we need to REBOOT now ?"
echo "#"

read -p "Press Enter to Finish ..." xx

exit