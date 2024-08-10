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
#   bearer => 'bearer'
# 
# Instance is the instance url, and host is the host url. 
# 
# example:
#   instance => 'https://ice.puppygirl.sale/'
#   host => 'ice.puppygirl.sale'
#

my %config = (
  bearer => undef,
  instance => undef,
  host => undef
);

# END USER MODIFIABLE SETTINGS

GetOptions(
  'bearer=s' => \$config{bearer},
  'instance=s' => \$config{instance},
  'host=s' => \$config{host}
);

if (!$config{bearer}) {
  die "bearer is undefined";
}

if (!$config{instance}) {
  die "instance is undefined";
}

if (!$config{host}) {
  die "host is undefined";
}

my $gen = '/api/iceshrimp/admin/invites/generate';
my $auth = '/api/iceshrimp/auth';

my $ua = LWP::UserAgent->new();
$ua->default_header('Accept' => 'application/json');
$ua->default_header('Host' => $config{host});
$ua->default_header('Authorization' => "Bearer $config{bearer}");
$ua->agent('amber inv script');

my $authreq = $ua->request(HTTP::Request->new('GET', $config{instance}.$auth));

# Guard statement for unexpected http code.
if ($authreq->code != 200) {
  print("shit is fucked.\n");
  die $authreq->as_string;
}

# Guard for if they're not an admin.
if (!decode_json($authreq->decoded_content)->{isAdmin}) {
  die "This endpoint requires isadmin=true on your account.";
}

# Create the request with appropriate headers
my $req = HTTP::Request->new('POST', $config{instance}.$gen);
$req->content(encode_json({}));
$ua->default_headers->remove_header('Accept');

# Send the request
my $res = $ua->request($req);

# Handle the result
if ($res->code != 200) {
  print("shit is fucked.\n");
  die $res->as_string;
}

my $code = decode_json($res->decoded_content)->{code};
print("Success! Code: `$code`\n");

