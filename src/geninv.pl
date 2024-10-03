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
    bearer => undef
);

# END USER MODIFIABLE SETTINGS

GetOptions(
    'instance=s' => \$config{instance},
    'username=s' => \$config{username},
    'password=s' => \$config{password},
    'bearer=s' => \$config{bearer}
);

if (!$config{instance}) {
    die "instance is undefined";
}

my $client = IceClient->new($config{instance});
$client->setUserAgent('amber geninvite script');

if (!$config{bearer}) {
    if (!$config{username} && !$config{password}) {
        die "need a bearer token or a username and password!";
    }
    $config{bearer} = $client->generateToken($config{username}, $config{password});
}

$client->login($config{bearer});

if (!$client->verifyAdmin()) {
    die "This endpoint requires you to be an admin!";
}

print($client->generateInvite());