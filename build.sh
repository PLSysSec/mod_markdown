#!/bin/bash
g++ -std=c++14 `pkg-config --cflags apr-1` -fPIC -DPIC -I$LIBMARKDOWN -I/usr/include/httpd -fpermissive -Wl,--export-dynamic -lstdc++ -lsupc++ -ldl -c mod_markdown.cpp 
libtool --silent --mode=link g++ -std=c++14 -Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now -o mod_markdown.la  -lapr-1 -rpath /usr/lib/httpd/modules -lstdc++ -lsupc++ -ldl -module -avoid-version  mod_markdown.o
