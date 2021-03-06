#!/usr/bin/env perl
# Spits out various information about the installation, including the version
# and config options.
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
use HTML::Template;
use File::ReadBackwards;
use File::Spec::Functions qw(rel2abs);
use File::Basename;
use Config;

sub tail
{
    my ($file, $num_lines) = @_;

    my $bw = File::ReadBackwards->new($file) or die "Can't read '$file': $!";

    my ($lines, $count);
    while (defined(my $line = $bw->readline) && $num_lines > $count++) {
        $lines .= $line;
    }

    $bw->close;
    return $lines;
}
# tail() is from http://stackoverflow.com/a/29267540.

sub gitversion
{
  my $currentdir = dirname(rel2abs($0));
  my $git_dir = "$currentdir/../.git";
  my $lastcommit = tail("$git_dir/logs/HEAD", 1);
  my @lastcommit_split = split(/ /, $lastcommit);
  my $output = substr($lastcommit_split[1], 0, 6);
  return $output;
}
my $configfh;
my $rawconfig;
my $configfile = dirname(rel2abs($0)) . "/../conf/config.yaml";

open($configfh, "<", $configfile);
{ # Slurp data
    local $/;
    $rawconfig = <$configfh>;
}
close($configfh);
my %config   = %{(Load($rawconfig))}; # Outputs a hash.

my $tm = HTML::Template->new(filename => dirname(rel2abs($0)) .
$config{"about-template"});

my $srvscore  = $config{"srvsidescore"}?"Yes":"No";
my $scrambleq = $config{"scrambleq"}   ?"Yes":"No";

$tm->param("revnum",        gitversion());
$tm->param("srvscore",      $srvscore);
$tm->param("scrambleq",     $scrambleq);
$tm->param("showsysconf",   $config{"showsysconfig"});
$tm->param("pversion",      $Config{"version"});
$tm->param("oversion",      $Config{"osvers"});
$tm->param("oname",         $Config{"osname"});
$tm->param("uname",         $Config{"myuname"});
$tm->param("aname",         $Config{"archname"});
$tm->param("wsname",        $ENV{"SERVER_NAME"});
$tm->param("wname",         $ENV{"SERVER_SOFTWARE"});

print "Content-Type: text/html;charset=utf8\n\n";
print $tm->output . "\n";
