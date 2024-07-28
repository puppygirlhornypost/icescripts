#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Request();
use JSON::MaybeXS qw(encode_json decode_json);
use LWP::UserAgent();

my $username = '';
my $password = '';
# Instance URL is just something like "https://ice.puppygirl.sale"
my $instance = '';
my $endpoint = '/api/iceshrimp/auth/login';

# yeah i hate it too dw
my $data = {
  username => "$username",
  password => "$password"
};

my $encoded_data = encode_json($data);

# Create the request with appropriate headers
my $req = HTTP::Request->new('POST', $instance.$endpoint);
$req->content($encoded_data);
my $ua = LWP::UserAgent->new();
$ua->default_header('Content-Type' => 'application/json');
$ua->default_header('Host' => 'ice.puppygirl.sale');
$ua->agent('amber token script');

# Send the request
my $res = $ua->request($req);

# Handle the result
if ($res->code == 200) {
  my $token = decode_json($res->decoded_content)->{token};
  print("Success! Bearer token: `$token`\n");
} else {
  print("shit is fucked.\n");
  print($res->as_string);
}

