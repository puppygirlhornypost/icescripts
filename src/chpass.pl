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
    oldpass => undef,
    newpass => undef,
    bearer => undef
);

# END USER MODIFIABLE SETTINGS

GetOptions(
    'instance=s' => \$config{instance},
    'username=s' => \$config{username},
    'oldpass=s' => \$config{oldpass},
    'newpass=s' => \$config{newpass},
    'bearer=s' => \$config{bearer}
);

if (!$config{instance}) {
    die "instance is undefined";
} elsif (!$config{oldpass}) {
    die "oldpass is undefined";
} elsif (!$config{newpass}) {
    die "newpass is undefined";
}

my $client = IceClient->new($config{instance});
$client->setUserAgent('amber chpass script');

if (!$config{bearer}) {
    if (!$config{username}) {
        die "must specify a username or a bearer token!";
    }

    $config{bearer} = $client->generateToken($config{username}, $config{oldpass});
}

$client->login($config{bearer});
my $token = $client->changePassword($config{oldpass}, $config{newpass});
print('Password changed, new login token: '.$token."\n");