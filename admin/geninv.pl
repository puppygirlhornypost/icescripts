#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Request();
use JSON::MaybeXS qw(encode_json decode_json);
use LWP::UserAgent();

# USER MODIFIABLE SETTINGS
my $bearer = '';
# Instance URL is just something like "https://ice.puppygirl.sale"
my $instance = '';
# instance url without https:// (according to docs this is used for register
# endpoint. "ice.puppygirl.sale"
my $host = '';
# END USER MODIFIABLE SETTINGS

my $gen = '/api/iceshrimp/admin/invites/generate';
my $auth = '/api/iceshrimp/auth';

my $ua = LWP::UserAgent->new();
$ua->default_header('Accept' => 'application/json');
$ua->default_header('Host' => $host);
$ua->default_header('Authorization' => "Bearer $bearer");
$ua->agent('amber inv script');

my $authreq = $ua->request(HTTP::Request->new('GET', $instance.$auth));

# Guard statement for unexpected http code.
if ($authreq->code != 200) {
  print("shit is fucked.\n");
  die $authreq->as_string)
}

# Guard for if they're not an admin.
if (!decode_json($authreq->decoded_content)->{isAdmin}) {
  die "This endpoint requires isadmin=true on your account.";
}

# Create the request with appropriate headers
my $req = HTTP::Request->new('POST', $instance.$gen);
$req->content(encode_json({}));
$ua->default_headers->remove_header('Accept');

# Send the request
my $res = $ua->request($req);

# Handle the result
if ($res->code != 200) {
  print("shit is fucked.\n");
  die ($res->as_string);
}

my $code = decode_json($res->decoded_content)->{code};
print("Success! Code: `$code`\n");

