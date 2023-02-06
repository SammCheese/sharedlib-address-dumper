
# replace with your own
proc=$(pidof -s Xorg)

library=libdevmapper.so

sudo cp "../target/debug/libderanged.so" "/lib/i386-linux-gnu/${library}"

if grep -q "$library" /proc/"$proc"/maps; then
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
fi

echo "Done."