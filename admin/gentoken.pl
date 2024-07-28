#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Request();
use JSON::MaybeXS qw(encode_json decode_json);
use LWP::UserAgent();

# USER MODIFIABLE SETTINGS
my $username = '';
my $password = '';
# Instance URL is just something like "https://ice.puppygirl.sale"
my $instance = '';
# instance url without https:// (according to docs this is used for register
# endpoint.) "ice.puppygirl.sale"
my $host = '';
# END USER MODIFIABLE SETTINGS

my $auth = '/api/iceshrimp/auth';
my $login = $auth.'/login';

# yeah i hate it too dw
my $data = {
  username => "$username",
  password => "$password"
};

my $encoded_data = encode_json($data);

# Create the request with appropriate headers
my $req = HTTP::Request->new('POST', $instance.$login);
$req->content($encoded_data);
my $ua = LWP::UserAgent->new();
$ua->default_header('Content-Type' => 'application/json');
$ua->default_header('Host' => 'ice.puppygirl.sale');
$ua->agent('amber token script');

# Send the request
my $res = $ua->request($req);

# Handle the result
if ($res->code != 200) {
  print("shit is fucked.\n");
  print($res->as_string);
  exit 1;
}

my $token = decode_json($res->decoded_content)->{token};
print("Server responded with `$token`, verifying...\n");

$ua->default_headers->remove_header('Content-Type');
$ua->default_header('Accept' => 'application/json');
$ua->default_header('Authorization' => "Bearer $token");
my $authreq = $ua->request(HTTP::Request->new('GET', $instance.$auth));

# Guard statement for unexpected http code
if ($authreq->code != 200) {
  print("shit is fucked.\n");
  print($authreq->as_string);
  exit 1;
}

print("Success! Token: `$token`\n");
