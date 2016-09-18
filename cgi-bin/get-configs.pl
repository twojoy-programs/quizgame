#!/usr/bin/perl
# Short 2-line description
# goes here.
'
Copyright (c) 2016, twojoy-programs
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of twojoy-programs nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
';
use strict;
use warnings;
use utf8;
use v5.14;

use CGI::Carp qw(fatalsToBrowser);
use YAML;
use JSON;
use File::Spec::Functions qw(rel2abs);
use File::Basename;

my $j         = JSON->new->utf8(1)->pretty(1);
my $configfh;
my $rawconfig;
my $configfile = dirname(rel2abs($0)) . "/../data/config.yaml";

open($configfh, "<", $configfile);
{ # Slurp data
    local $/;
    $rawconfig = <$configfh>;
}
my $configs   = Load($rawconfig); # Outputs a hashref.
my $finaljson = $j->encode($configs);

print "Content-Type: text/plain;charset=UTF-8\n\n";
print "$finaljson";