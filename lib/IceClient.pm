#!/usr/bin/env perl

use strict;
use warnings;

use HTTP::Request();
use LWP::UserAgent();

package IceClient;

use JSON::MaybeXS qw(encode_json decode_json);

sub new {
    my $class = shift;
    my $self = {
        _instance => shift,
        _host => shift
    };

    $self->{_userAgent} = LWP::UserAgent->new();
    $self->{_userAgent}->default_header('Host' => $self->{_host});

    bless $self, $class;
    return $self;
}

sub setUserAgent {
    my ( $self, $agent ) = @_;

    $self->{_userAgent}->agent($agent);
}

sub postRequest {
    my ( $self, $endpoint, $content) = @_;

    my $req = HTTP::Request->new('POST', $self->{_instance}.$endpoint);
    $req->content($content);

    $self->{_userAgent}->default_header('Content-Type' => 'application/json');

    my $res = $self->{_userAgent}->request($req);

    $self->{_userAgent}->default_headers->remove_header('Content-Type');

    return $res;
}

sub getRequest {
    my ( $self, $endpoint) = @_;

    $self->{_userAgent}->default_header('Accept' => 'application/json');

    my $req = $self->{_userAgent}->request(HTTP::Request->new('GET', $self->{_instance}.$endpoint));

    $self->{_userAgent}->default_headers->remove_header('Accept');

    return $req;
}

sub registerAccount {
    my ( $self, $username, $password, $invite ) = @_;

    my %payload = {
        username => $username,
        password => $password
    }

    $payload->{invite} = $invite if defined($invite);

    my $req = $self->getRequest('/api/iceshrimp/auth/register', encode_json($payload));

    if ($req->code != 200) {
        die $req->as_string;
    }

    return decode_json($req->decoded_content)->{token};
}

sub login {
    my ( $self, $token ) = @_;

    if ($self->verifyToken($token)) {
        $self->{_token} = $token;
    } else {
        die "invalid token!";
    }
}

sub generateToken {
    my ( $self, $username, $password ) = @_;

    my $req = $self->postRequest('/api/iceshrimp/auth/login', encode_json({
        username => $username,
        password => $password
    }));

    # Handle the result
    if ($req->code != 200) {
        die "invalid username and password! raw http response:\n".$req->as_string;
    }

    return decode_json($req->decoded_content)->{token};
}

sub verifyToken {
    my ( $self, $token ) = @_;
    
    $self->{_userAgent}->default_header('Authorization' => 'Bearer '.$token);
    my $req = $self->getRequest('/api/iceshrimp/auth');
    $self->{_userAgent}->default_headers->remove_header('Authorization');

    if ($req->code == 200) {
        return 1;
    } else {
        return 0;
    }
}

sub verifyAdmin {
    my ( $self ) = @_;

    my $req = $self->getRequestAuth('/api/iceshrimp/auth');

    if ($req->code == 200) {
        return decode_json($req->decoded_content)->{isAdmin};
    } else {
        return 0;
    }
}

sub postRequestAuth {
    my ( $self, $endpoint, $content) = @_;

    my $req = HTTP::Request->new('POST', $self->{_instance}.$endpoint);
    $req->content($content);

    $self->{_userAgent}->default_header('Content-Type' => 'application/json');
    $self->{_userAgent}->default_header('Authorization' => 'Bearer '.$self->{_token});

    my $res = $self->{_userAgent}->request($req);

    $self->{_userAgent}->default_headers->remove_header('Content-Type');
    $self->{_userAgent}->default_headers->remove_header('Authorization');

    return $res;
}

sub getRequestAuth {
    my ( $self, $endpoint) = @_;

    $self->{_userAgent}->default_header('Accept' => 'application/json');
    $self->{_userAgent}->default_header('Authorization' => 'Bearer '.$self->{_token});

    my $req = $self->{_userAgent}->request(HTTP::Request->new('GET', $self->{_instance}.$endpoint));

    $self->{_userAgent}->default_headers->remove_header('Accept');
    $self->{_userAgent}->default_headers->remove_header('Authorization');

    return $req;
}

sub generateInvite {
    my ( $self ) = @_;

    if (!$self->verifyAdmin()) {
        die "You must be admin to generate an invite code!";
    }

    my $req = $self->postRequestAuth('/api/iceshrimp/admin/invites/generate', '{}');

    if ($req->code != 200) {
        die $req->as_string;
    } else {
        return decode_json($req->decoded_content)->{code};
    }
}

sub changePassword {
    my ( $self, $oldpass, $newpass ) = @_;

    my $req = $self->postRequest('/api/iceshrimp/auth/change-password', encode_json({
        oldPassword => $oldpass,
        newPassword => $newpass
    }));

    if ($req->code != 200) {
        die $req->as_string;
    } else {
        return decode_json($req->decoded_content)->{token};
    }
}

1;