This is a port of `mod_markdown` that sandboxes the underlying markdown library
(called discount) with RLBox.

1. Install apache2 and apxs (see below in the old readme).

2. Download and build [libmarkdown.so](https://github.com/PLSysSec/libmarkdown).

3. Link [RLBox](https://github.com/shravanrn/rlbox_api) header files in this project:

```
ln -s $(RLBOX_DIR)/rlbox.h
ln -s $(RLBOX_DIR)/RLBox_DynLib.h
```

2. Assuming you built the shared library in `<LIBMARKDOWN>`:

```
LIBMARKDOWN=<LIBMARKDOWN> ./build.sh
```

You may need to modify build.sh for your machine, depeding on where httpd headers and libtool are installed. You may find the old Makefile useful.

The build script will general a bunch of warnings we're going to ignore for this research prototype.

3.  Load apache module by modifying httpd.conf:

~~~
LoadModule markdown_module modules/mod_markdown.so
~~~

You need to specify full path:
~~~
LoadModule markdown_module /usr/lib/apache2/modules/mod_markdown.so
~~~

Then add markdown handler to the directory:

~~~
<Directory /var/www>
    AddHandler markdown .md
    DirectoryIndex index.md
</Directory>
~~~

4. Dump some markdown files in `/var/www`

5. Run apache: `sudo apachectl start`


# OLD README

mod_markdown
============

[![Build Status](https://travis-ci.org/hamano/apache-mod-markdown.svg?branch=master)](https://travis-ci.org/hamano/apache-mod-markdown)

mod_markdown is Markdown filter module for Apache HTTPD Server.

## Dependencies

* The [discount](http://www.pell.portland.or.us/~orc/Code/discount/) library that we sandbox. You want to get it from [here]().

For Debian/Ubuntu:

~~~
# apt install build-essential libtool automake autoconf
# apt install libmarkdown2-dev apache2 apache2-dev
~~~

## Build

~~~
% autoreconf -f -i
% ./configure --with-apxs=<APXS_PATH> --with-discount=<DISCOUNT_DIR>
% make
% make install
~~~

Note: `<DISCOUNT_DIR>` is the directory that contains the include directory that contains mkdio.h
Probably you need to specify --with-discount=/usr or --with-discount=/usr/local

## Configuration
in httpd.conf:

~~~
LoadModule markdown_module modules/mod_markdown.so
~~~

You need to specify full path on debian or ubuntu.
~~~
LoadModule markdown_module /usr/lib/apache2/modules/mod_markdown.so
~~~

~~~
<Location />
    AddHandler markdown .md

    # If you want to use stylesheet.
    # MarkdownCss style.css
    # MarkdownHeaderHtml "<p>Header</p>"
    # MarkdownFooterHtml "<p>Footer</p>"
</Location>
~~~

Or:

~~~
<Directory /var/www>
    AddHandler markdown .md
    DirectoryIndex index.md
</Directory>
~~~

### MarkdownFlags

default: MKD_TOC | MKD_AUTOLINK | MKD_FENCEDCODE

Flag | Value | Description
--- | --- | ---
MKD_FENCEDCODE   | 0x02000000 | enabled fenced code blocks
MKD_AUTOLINK     | 0x00004000 | make http://foo.com link even without &lt;&gt;s
MKD_TOC          | 0x00001000 | do table-of-contents processing
 |  |
MKD_1_COMPAT     | 0x00002000 | compatibility with MarkdownTest_1.0
MKD_CDATA        | 0x00000080 | generate code for xml ![CDATA[...]]
MKD_EMBED       MKD_NOLINKS|MKD_NOIMAGE|MKD_TAGTEXT
MKD_EXPLICITLIST  | 0x80000000 |        don't combine numbered/bulletted lists
MKD_EXTRA_FOOTNOTE  | 0x00200000 |      enable markdown extra-style footnotes
MKD_GITHUBTAGS   | 0x08000000 | allow dash and underscore in element names
MKD_IDANCHOR     | 0x04000000 | use id= anchors for TOC links
MKD_LATEX        | 0x40000000 | handle embedded LaTeX escapes
MKD_NOALPHALIST  | 0x00080000 | forbid alphabetic lists
MKD_NODIVQUOTE   | 0x00040000 | forbid >%class% blocks
MKD_NODLDISCOUNT  | 0x00800000 |        disable discount-style definition lists
MKD_NODLIST      | 0x00100000 | forbid definition lists
MKD_NO_EXT       | 0x00000040 | don't allow pseudo-protocols
MKD_NOHEADER     | 0x00010000 | don't process header blocks
MKD_NOHTML       | 0x00000008 | don't allow raw html through AT ALL
MKD_NOIMAGE      | 0x00000002 | don't do image processing, block &lt;img&gt;
MKD_NOLINKS      | 0x00000001 | don't do link processing, block &lt;a&gt; tags
MKD_NOPANTS      | 0x00000004 | don't run smartypants()
MKD_NORELAXED    | 0x00000200 | emphasis happens /everywhere/
MKD_NOSTRIKETHROUGH  | 0x00000800 |     forbid ~~strikethrough~~
MKD_NOSTYLE      | 0x00400000 | don't extract &lt;style&gt; blocks
MKD_NOSUPERSCRIPT  | 0x00000100 |       no A^B
MKD_NOTABLES     | 0x00000400 | disallow tables
MKD_SAFELINK     | 0x00008000 | paranoid check for link protocol
MKD_STRICT       | 0x00000010 | disable SUPERSCRIPT, RELAXED_EMPHASIS
MKD_TABSTOP      | 0x00020000 | expand tabs to 4 spaces
MKD_TAGTEXT      | 0x00000020 | process text inside an html tag; no
MKD_URLENCODEDANCHOR  | 0x10000000 | urlencode non-identifier chars instead of replacing with dots

