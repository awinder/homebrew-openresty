require 'formula'

class NgxOpenresty < Formula
  homepage 'http://openresty.org/'

  stable do
    url 'http://openresty.org/download/ngx_openresty-1.7.10.2.tar.gz'
    sha256 '5e8beafb7b32ba62fd34b323b2e9cf49884b4f0491fccf189f0b88b3e25dd0e4'
  end

  devel do
    url 'http://openresty.org/download/ngx_openresty-1.7.4.1rc2.tar.gz'
    sha256 '5daab35e41395fe964b10055f83b798415ca6a3d7921ba7cbaa28707aad50888'
  end

  depends_on 'pcre'
  depends_on 'postgresql' => :optional
  depends_on 'geoip' => :optional

  # openresty options
  option 'without-luajit', "Compile *without* support for the Lua Just-In-Time Compiler"
  option 'with-postgresql', "Compile with support for direct communication with PostgreSQL database servers"
  option 'with-iconv', "Compile with support for converting character encodings"

  option 'with-debug', "Compile with support for debug logging but without proper gdb debugging symbols"

  # nginx options
  option 'with-webdav', "Compile with ngx_http_dav_module"
  option 'with-gunzip', "Compile with ngx_http_gunzip_module"
  option 'with-geoip', "Compile with ngx_http_geoip_module"
  option 'with-stub_status', "Compile with ngx_http_stub_status_module"

  skip_clean 'logs'

  def install
    args = ["--prefix=#{prefix}",
      "--with-http_ssl_module",
      "--with-pcre",
      "--with-pcre-jit",
      "--with-openssl=/usr/local/opt/openssl",
      "--sbin-path=#{bin}/openresty",
      "--conf-path=#{etc}/openresty/nginx.conf",
      "--pid-path=#{var}/run/openresty.pid",
      "--lock-path=#{var}/openresty/nginx.lock"
    ]

    args << "--with-http_dav_module" if build.with? 'webdav'
    args << "--with-http_gunzip_module" if build.with? 'gunzip'
    args << "--with-http_geoip_module" if build.with? 'geoip'
    args << "--with-http_stub_status_module" if build.with? 'stub_status'

    # Debugging mode, unfortunately without debugging symbols
    if build.with? 'debug'
      args << '--with-debug'
      args << '--with-dtrace-probes'
      args << '--with-no-pool-patch'

      # this allows setting of `debug.sethook` in luajit
      unless build.without? 'luajit'
        args << '--with-luajit-xcflags=-DLUAJIT_ENABLE_CHECKHOOK'
      end

      opoo "Openresty will be built --with-debug option, but without debugging symbols. For debugging symbols you have to compile it by hand."
    end

    # OpenResty options
    args << "--with-lua51" if build.without? 'luajit'

    args << "--with-http_postgres_module" if build.with? 'postgresql'
    args << "--with-http_iconv_module" if build.with? 'iconv'

    system "./configure", *args

    system "make"
    system "make install"
  end
end
