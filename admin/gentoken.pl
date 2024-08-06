#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Request();
use JSON::MaybeXS qw(encode_json decode_json);
use LWP::UserAgent();
use Getopt::Long;

# If you want to hard code values instead of using cli, change undef to 'value'.
# 
# example:
#   username => 'username'
# 
# Instance is the instance url, and host is the host url. 
# 
# example:
#   instance => 'https://ice.puppygirl.sale/'
#   host => 'ice.puppygirl.sale'
#
# If you want to skip verification, set skip_verify => 1

my %config = (
  username => undef,
  password => undef,
  instance => undef,
  host => undef,
  skip_verify => ''
);

# END USER MODIFIABLE SETTINGS

GetOptions(
  'username=s' => \$config{username},
  'password=s' => \$config{password},
  'instance=s' => \$config{instance},
  'host=s' => \$config{host},
  'skip-verify' => \$config{skip_verify}
);

if (!$config{username}) {
  die "username is undefined";
}

if (!$config{password}) {
  die "password is undefined";
}

if (!$config{instance}) {
  die "instance is undefined";
}

if (!$config{host}) {
  die "host is undefined";
}

# api endpoints
my $auth = '/api/iceshrimp/auth';
my $login = $auth.'/login';

# Create the request with appropriate headers
my $req = HTTP::Request->new('POST', $config{instance}.$login);

$req->content(encode_json({
  username => $config{username},
  password => $config{password}
}));

my $ua = LWP::UserAgent->new();
$ua->default_header('Content-Type' => 'application/json');
$ua->default_header('Host' => $config{host});
$ua->agent('amber token script');

# Send the request
my $res = $ua->request($req);

# Handle the result
if ($res->code != 200) {
  print("shit is fucked.\n");
  die $res->as_string;
}

my $token = decode_json($res->decoded_content)->{token};

if ('' ne $config{skip_verify}) {
  print("Success! Token: `$token`\n");
  exit;
}

print("Server responded with `$token`, verifying...\n");

$ua->default_headers->remove_header('Content-Type');
$ua->default_header('Accept' => 'application/json');
$ua->default_header('Authorization' => "Bearer $token");
my $authreq = $ua->request(HTTP::Request->new('GET', $config{instance}.$auth));

# Guard statement for unexpected http code
if ($authreq->code != 200) {
  print("shit is fucked.\n");
  die $authreq->as_string;
}

print("Success! Token: `$token`\n");
