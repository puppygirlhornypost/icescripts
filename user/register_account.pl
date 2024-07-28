#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Request();
use JSON::MaybeXS qw(encode_json decode_json);
use LWP::UserAgent();

my $username = '';
my $password = '';
my $invite = '';

my $instance = 'https://ice.puppygirl.sale';
my $endpoint = '/api/iceshrimp/auth/register';

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
my $req = HTTP::Request->new('POST', $instance.$endpoint);
$req->content($encoded_data);
my $ua = LWP::UserAgent->new();
$ua->default_header('Content-Type' => 'application/json');
$ua->default_header('Host' => 'ice.puppygirl.sale');
$ua->agent('amber reg script');

# Send the request
my $res = $ua->request($req);

# Handle the result
if ($res->code == 200) {
  my $token = decode_json($res->decoded_content)->{token};
  print("Success! Bearer token: $token\n");
} else {
  print("shit is fucked.\n");
  print($res->as_string);
}

