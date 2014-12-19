#!/usr/bin/env perl
use strict;
use warnings;
 
# get slave status
sub get_status {
    my ($ip, $usr, $pass) = @_;
    my $info = `mysql -u$usr -p$pass -h$ip -e 'show slave status\\G;'`;
    if (($info =~ /Slave_IO_Running: Yes/) and ($info =~ /Slave_SQL_Running: No/)) {
        return 1;
    }
    return 0;
}
# mysql slave skip
sub slaveskip {
    my ($ip, $usr, $pass) = @_;
    print "slave error **\n";
    system("mysql -u$usr -p$pass -h$ip -e 'slave stop;'");
    system("mysql -u$usr -p$pass -h$ip -e 'set GLOBAL SQL_SLAVE_SKIP_COUNTER=1;'");
    system("mysql -u$usr -p$pass -h$ip -e 'slave start;'");
}
 
my @hosts = qw/
192.168.10.21:root:password
 
/;
foreach (@hosts) {
    my ($ip, $usr, $pass) = split ':';
    print "// ----- $ip\n";
    my $count = 1;
    while ($count < 100000) {
        my $status = get_status($ip, $usr, $pass);
        print "i: $count status: $status\n";
        last if $status == 0;
        slaveskip($ip, $usr, $pass);
        select(undef, undef, undef, 0.1);
        $count++;
    }
    print "\n";
}
 
exit;
 