#!/usr/bin/env bash

# replace with your own
proc_pid=$(pidof -s Xorg)
library=libdevmapper.so

if grep -q "$library" /proc/"$proc_pid"/maps; then
	echo "unloading $library"
	sudo cp "../target/debug/libderanged.so" "/lib/i386-linux-gnu/${library}"
        sudo gdb -n -q -batch \
        -ex "set logging on" \
        -ex "set logging file /dev/null" \
        -ex "set logging redirect on" \
        -ex "attach $proc_pid" \
        -ex "echo Calling dlsym" \
        -ex "call ((int(*)(void*))dlclose)(((void*(*)(const char*, int))dlopen)(\"/lib/i386-linux-gnu/${library}\", 1))" \
        -ex "echo Calling dlerror" \
        -ex "call ((char*(*)(void))dlerror)()" \
        -ex "detach" \
        -ex "quit"
    sudo rm "/lib/i386-linux-gnu/${library}"
fi

echo "Done."
