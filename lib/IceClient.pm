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
        _instance => shift
    };

    $self->{_userAgent} = LWP::UserAgent->new();
    $self->{_userAgent}->default_header('Host' => $self->{_host});

    if ('/' eq substr($self->{_instance}, -1)) {
        chop $self->{_instance};
    }

    $self->{_instance} =~ /http[s]?:\/\/(.+)/;
    $self->{_host} = $1;

    bless $self, $class;
    return $self;
}

sub setUserAgent {
    my ( $self, $agent ) = @_;

    $self->{_userAgent}->agent($agent);
}

sub postRequest {
    my ( $self, $endpoint, $content, $token) = @_;

    my $req = HTTP::Request->new('POST', $self->{_instance}.$endpoint);
    $req->content($content);

    $req->header('Content-Type' => 'application/json');

    if (defined $token) {
        $req->header('Authorization' => 'Bearer '.$token);
    }

    my $res = $self->{_userAgent}->request($req);

    return $res;
}

sub getRequest {
    my ( $self, $endpoint, $token) = @_;

    my $req = HTTP::Request->new('GET', $self->{_instance}.$endpoint);

    $req->header('Accept' => 'application/json');

    if (defined $token) {
        $req->header('Authorization' => 'Bearer '.$token);
    }

    my $res = $self->{_userAgent}->request($req);

    return $res;
}

sub registerAccount {
    my ( $self, $username, $password, $invite ) = @_;

    my %payload = (
        username => $username,
        password => $password
    );

    $payload{invite} = $invite if defined($invite);

    my $req = $self->getRequest('/api/iceshrimp/auth/register', encode_json(%payload), undef);

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
    }), undef);

    # Handle the result
    if ($req->code != 200) {
        die "invalid username and password! raw http response:\n".$req->as_string;
    }

    return decode_json($req->decoded_content)->{token};
}

sub verifyToken {
    my ( $self, $token ) = @_;
    
    my $req = $self->getRequest('/api/iceshrimp/auth', $token);

    if ($req->code == 200) {
        return 1;
    } else {
        return 0;
    }
}

sub verifyAdmin {
    my ( $self ) = @_;

    my $req = $self->getRequest('/api/iceshrimp/auth', $self->{_token});

    if ($req->code == 200) {
        return decode_json($req->decoded_content)->{isAdmin};
    } else {
        return 0;
    }
}

sub generateInvite {
    my ( $self ) = @_;

    if (!$self->verifyAdmin()) {
        die "You must be admin to generate an invite code!";
    }

    my $req = $self->postRequest('/api/iceshrimp/admin/invites/generate', '{}', $self->{_token});

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
    }), $self->{_token});

    if ($req->code != 200) {
        die $req->as_string;
    } else {
        return decode_json($req->decoded_content)->{token};
    }
}

1;