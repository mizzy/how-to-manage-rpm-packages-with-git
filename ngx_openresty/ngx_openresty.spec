Name: ngx_openresty
Version: 1.0.15.10
Release: 1%{?dist}
Summary: a powerful web app server by extending nginx
Group: Server
License: BSD
URL: http://openresty.org/
Source0: http://agentzh.org/misc/nginx/ngx_openresty-%{version}.tar.gz
BuildRoot: n%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires: pcre-devel, openssl-devel, readline-devel
Requires: pcre, openssl, readline

%define prefix /usr/local/app/ngx_openresty-%{version}

%description
a powerful web app server by extending nginx

%prep
%setup -q

%build
perl configure                    \
  --prefix=%{prefix}              \
  --with-luajit                   \
  --with-http_realip_module       \
  --with-http_stub_status_module 
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%{prefix}/luajit/bin/*
%{prefix}/luajit/include/*
%{prefix}/luajit/lib/*
%{prefix}/luajit/share/*
%{prefix}/lualib/*
%{prefix}/nginx/conf/*
%{prefix}/nginx/html/*
%{prefix}/nginx/logs
%{prefix}/nginx/sbin/nginx
%doc

%changelog

* Tue May 08 2012 Hiroya ITo <hito@paperboy.co.jp> - 1.0.15.10-1
- upgrade
- add --with-http_stub_status_module (refs https://github.com/paperboy-sqale/sqale-app/issues/461)
* Tue May 08 2012 Hiroya ITo <hito@paperboy.co.jp> - 1.0.11.28-1
- First build
- refs http://openresty.org/
