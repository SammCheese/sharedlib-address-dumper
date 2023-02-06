#!/usr/bin/env bash

# Verify that we are root
if [ ! $(id -u) -eq 0 ]; then
    echo -e "\033[1;33m \n \nThis script must be ran as root!\n\033[0m"
    exit 1
fi

line=$(pgrep native_client)
arr=($line)

# rename since some programs dont like foreign shared libs
library=libdevmapper.so

if [ $# == 1 ]; then
    proc=$1
else
    if [ ${#arr[@]} == 0 ]; then
        echo Process isn\'t running!
        exit 1
    fi
    proc=${arr[0]}
fi

echo -e "\033[1;33m \n \nProcess found!\n\033[0m"
echo Attaching to process $proc


# pBypass for crash dumps being sent
# You may also want to consider using -nobreakpad in your launch options.
sudo rm -rf /tmp/dumps # Remove if it exists
sudo mkdir /tmp/dumps # Make it as root
sudo chmod 000 /tmp/dumps # No permissions

sudo cp "../target/debug/libderanged.so" "/lib/i386-linux-gnu/${library}"


sudo gdb -n -q -batch \
  -ex "set logging on" \
  -ex "set logging file /dev/null" \
  -ex "set logging redirect on" \
  -ex "attach $proc" \
  -ex "echo Calling dlopen" \
  -ex "call ((void*(*)(const char*, int))dlopen)(\"/lib/i386-linux-gnu/${library}\", 1)" \
  -ex "echo Calling dlerror" \
  -ex "call ((char*(*)(void))dlerror)()" \
  -ex "detach" \
  -ex "quit"


last_line="${input##*$'\n'}"

if [ "$last_line" != "\$1 = (void *) 0x0" ]; then
    /bin/echo -e "\\e[32mSuccessfully injected!\\e[0m"
else
    /bin/echo -e "\\e[31mInjection failed, make sure you have compiled correctly...\\e[0m"
fi