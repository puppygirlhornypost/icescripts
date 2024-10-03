#!/usr/bin/env perl

use strict;
use warnings;

use lib '../lib';
use IceClient;

use Getopt::Long;

# If you want to hard code values instead of using cli, change undef to 'value'.
# 
# example:
#   username => 'username'
# 
# Instance is the instance url, and host is the hostname. 
# 
# example:
#   instance => 'https://ice.puppygirl.sale/'
#   host => 'ice.puppygirl.sale'

my %config = (
    instance => undef,
    username => undef,
    password => undef,
    skip_verify => ''
);

# END USER MODIFIABLE SETTINGS

GetOptions(
    'username=s' => \$config{username},
    'password=s' => \$config{password},
    'instance=s' => \$config{instance},
    'skip-verify' => \$config{skip_verify}
);

if (!$config{instance}) {
    die "instance is undefined";
} elsif (!$config{username}) {
    die "username is undefined";
} elsif (!$config{password}) {
    die "password is undefined";
}

my $client = IceClient->new($config{instance});
$client->setUserAgent('amber gentoken script');
my $token = $client->generateToken($config{username}, $config{password});

if ('' ne $config{skip_verify}) {
    print($token."\n");
    exit;
}

if ($client->verifyToken($token)) {
    print($token."\n");
} else {
    die "token was unable to be verified"
};