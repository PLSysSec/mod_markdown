.NOTPARALLEL:
.PHONY : build check_deps clean

RLBOX_DIR := $(shell realpath ../rlbox_api)
LIBMARKDOWN := $(shell realpath ../libmarkdown)
HTTPD_DIR := $(shell \
	if [ -e "/usr/include/httpd/httpd.h" ]; then \
		echo /usr/include/httpd/; \
	elif [ -e "/usr/include/apache2/httpd.h" ]; then \
		echo /usr/include/apache2/; \
	else \
		echo ""; \
	fi \
)

CURR_DIR := $(shell realpath ./)

ifeq ($(HTTPD_DIR),)
$(error Could not find the location of httpd.h. Please edit the makefile to point to the location)
endif

LIBTOOL_DIR := $(shell \
	if [ -e "/usr/share/apr-1/build/libtool" ]; then \
		echo /usr/share/apr-1/build/; \
	elif [ -e "/usr/share/apr-1.0/build/libtool" ]; then \
		echo /usr/share/apr-1.0/build/; \
	else \
		echo "$(which libtool)"; \
	fi \
)

ifeq ($(LIBTOOL_DIR),)
$(error Could not find the location of libtool. Please edit the makefile to point to the location)
endif

SANDBOXING_NACL_DIR=$(shell realpath ../Sandboxing_NaCl)
FLAGS_WHEN_LINKING_NACL_EXAMPLES_64 = -pie -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -fPIC -Wl,-rpath=$(SANDBOXING_NACL_DIR)/native_client/scons-out-firefox/opt-linux-x86-64/lib -L$(SANDBOXING_NACL_DIR)/native_client/scons-out-firefox/opt-linux-x86-64/lib -ldyn_ldr -lsel -lnacl_error_code -lenv_cleanser -lnrd_xfer -lnacl_perf_counter -lnacl_base -limc -lnacl_fault_inject -lnacl_interval -lplatform_qual_lib -lvalidators -ldfa_validate_caller_x86_64 -lcpu_features -lvalidation_cache -lplatform -lgio -lnccopy_x86_64 -lrt -lpthread

build:
	echo $(HTTPD_DIR)
	echo $(LIBTOOL_DIR)
	g++ -O3 -std=c++14 `pkg-config --cflags apr-1` -fPIC -DPIC -I$(LIBMARKDOWN) -I$(RLBOX_DIR) -I$(HTTPD_DIR) -fpermissive -Wl,--export-dynamic -lstdc++ -lsupc++ -ldl -c mod_markdown.cpp
	$(LIBTOOL_DIR)/libtool --silent --mode=link g++ -std=c++14 -Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now -o mod_markdown.la  -lapr-1 -rpath /usr/lib/httpd/modules -lstdc++ -lsupc++ -ldl -module -avoid-version  mod_markdown.o
	g++ -O3 -std=c++14 `pkg-config --cflags apr-1` -fPIC -DPIC -DUSE_NACL -I$(LIBMARKDOWN) -I$(RLBOX_DIR) -I$(HTTPD_DIR) -I$(SANDBOXING_NACL_DIR)/native_client/src/trusted/dyn_ldr/ -fpermissive -Wl,--export-dynamic -lstdc++ -lsupc++ -ldl  $(FLAGS_WHEN_LINKING_NACL_EXAMPLES_64) -c mod_markdown.cpp -o mod_markdown_nacl.o
	$(LIBTOOL_DIR)/libtool --silent --mode=link g++ -std=c++14 -Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now -o mod_markdown_nacl.la  -lapr-1 -rpath /usr/lib/httpd/modules -lstdc++ -lsupc++ -ldl -module -avoid-version $(FLAGS_WHEN_LINKING_NACL_EXAMPLES_64) mod_markdown_nacl.o

install:
	## Terribly sorry about this install process! Research! Will fix later.
	cd install_markdown && sudo cp apache2.conf /etc/apache2/ && \
	sudo cp -r ./files/* /var/www/html/
	cp $(CURR_DIR)/libmarkdown.nexe /tmp/
	cp $(CURR_DIR)/irt_core.nexe /tmp/
	echo LoadModule markdown_rlbox_module $(CURR_DIR)/.libs/mod_markdown.so           | sudo tee -a /etc/apache2/mods-enabled/markdown.load
	echo LoadModule markdown_rlbox_nacl_module $(CURR_DIR)/.libs/mod_markdown_nacl.so | sudo tee -a /etc/apache2/mods-enabled/markdown.load

bench:
	autocannon --latency http://localhost/README.rlboxmd
	autocannon --latency http://localhost/README.rlboxnaclmd

# APACHE2_CONF_PATH:= $(shell \
# 	if [ -e "/etc/apache2/httpd.conf" ]; then \
# 		echo /etc/apache2/httpd.conf; \
# 	else \
# 		echo ""; \
# 	fi \
# )

# ifeq ($(APACHE2_CONF_PATH),)
# $(error Could not find the location of httpd.conf. Please edit the makefile to point to the location)
# endif

# MOD_MARKDOWN_ALREADY_ADDED:=$(shell cat $(APACHE2_CONF_PATH) | grep "LoadModule markdown_module")

OUTPUT_LIBS_PATH=$(shell realpath ./libs)

install_deps:
	# will be run by root repot
	sudo apt install build-essential libtool automake autoconf
	sudo apt install libmarkdown2-dev apache2 apache2-dev

# add_markdown_to_config:
# ifeq ($(MOD_MARKDOWN_ALREADY_ADDED),)
# 	echo "" | sudo tee -a $(APACHE2_CONF_PATH)
# 	echo "LoadModule markdown_module $(OUTPUT_LIBS_PATH)/mod_markdown.so" | sudo tee -a $(APACHE2_CONF_PATH)
# 	echo "<Directory /var/www>" | sudo tee -a $(APACHE2_CONF_PATH)
# 	echo "	AddHandler markdown .md" | sudo tee -a $(APACHE2_CONF_PATH)
# 	echo "	DirectoryIndex index.md" | sudo tee -a $(APACHE2_CONF_PATH)
# 	echo "</Directory>" | sudo tee -a $(APACHE2_CONF_PATH)
# endif

# check_if_md_file_exists:
# ifeq (,$(wildcard /var/www/index.md))
# 	sudo cp ./README.md /var/www/index.md
# endif

check_deps: install_deps # add_markdown_to_config check_if_md_file_exists

