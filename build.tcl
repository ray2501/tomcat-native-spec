#!/usr/bin/tclsh

package require http
package require tls

set arch "x86_64"
set base "tomcat-native-1.2.18-src"

http::register https 443 [list ::tls::socket -ssl3 0 -ssl2 0 -tls1 1]

if {[file exists $base.tar.gz]==0} {
    puts "Dowonload file..."
    set f [open $base.tar.gz {WRONLY CREAT EXCL}]
    set token [http::geturl http://ftp.tc.edu.tw/pub/Apache/tomcat/tomcat-connectors/native/1.2.18/source/$base.tar.gz -channel $f]
    http::cleanup $token
    close $f
    puts "Done."
}

if {[file exists build]} {
    file delete -force build
}

file mkdir build/BUILD build/RPMS build/SOURCES build/SPECS build/SRPMS
file copy -force $base.tar.gz build/SOURCES
file copy -force tomcat-native-rpmlintrc build/SOURCES

set buildit [list rpmbuild --target $arch --define "_topdir [pwd]/build" -bb tomcat-native.spec]
exec >@stdout 2>@stderr {*}$buildit

file delete $base.tar.gz
