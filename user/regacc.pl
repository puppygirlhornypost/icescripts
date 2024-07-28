#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Request();
use JSON::MaybeXS qw(encode_json decode_json);
use LWP::UserAgent();

# USER MODIFIABLE SETTINGS
my $username = '';
my $password = '';
my $invite = '';
# Instance URL is just something like "https://ice.puppygirl.sale"
my $instance = '';
# instance url without https:// (arccording to docs this is used for register 
# endpoint.) "ice.puppygirl.sale"
my $host = '';
# END USER MODIFIABLE SETTINGS

my $auth = '/api/iceshrimp/auth';
my $reg = $auth.'/register';

# If you really want to remove the invite, you can hack this script together 
# yourself. I am not really sure how to add on to a perlobj, ideally i'd like 
# to append invite => $invite if the invite string is empty.

my $data = {
  username => $username,
  password => $password,
  invite => $invite
};
my $encoded_data = encode_json($data);

# Create the request with appropriate headers
my $req = HTTP::Request->new('POST', $instance.$reg);
$req->content($encoded_data);
my $ua = LWP::UserAgent->new();
$ua->default_header('Content-Type' => 'application/json');
$ua->default_header('Host' => $host);
$ua->agent('amber reg script');

# Send the request
my $res = $ua->request($req);

if ($res->code != 200) {
  print("shit is fucked.\n");
  die $res->as_string;
}

my $token = decode_json($res->decoded_content)->{token};
print("Server responded with `$token`, verifying...\n");

$ua->default_headers->remove_header('Content-Type');
$ua->default_header('Accept' => 'application/json');
$ua->default_header('Authorization' => "Bearer $token");
my $authreq = $ua->request(HTTP::Request->new('GET', $instance.$auth));

if ($authreq->code != 200) {
  print("shit is fucked.\n");
  die $authreq->as_string;
}

print("Success! Token: `$token`\n");

