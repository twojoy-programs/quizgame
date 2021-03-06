#!/usr/bin/perl
# Gets questions, translates them to JSON, and sends them on their way.
#
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
no  warnings qw(void experimental);
use utf8;
use v5.14;

#use CGI::Carp qw(fatalsToBrowser);
use YAML;
use JSON;
use File::Spec::Functions qw(rel2abs);
use File::Basename;
use CGI;
use Time::Piece;
use Data::Dumper;
use Time::HiRes qw(time);

my $config = dirname(rel2abs($0)) . "/../conf/config.yaml";

my $q          = CGI->new;
my $inpnum     = $q->param("qnum");
my $j          = JSON->new->utf8(1)->pretty(1);
my $configfh;
my $rawconfig;
my $rawqfile;
my $qfilehandle;

open($configfh, "<", $config) or die "Can't open config: $!";
{ # Slurp data
    local $/;
    $rawconfig = <$configfh>;
}
my %configs = %{(Load($rawconfig))}; # Outputs a hashref.
close($configfh);
my $qfilepath = dirname(rel2abs($0)) . $configs{"quizfilepath"};
open($qfilehandle, "<", $qfilepath) or die "Can't open qfile: $!";;
{ # Slurp data
    local $/;
    $rawqfile = <$qfilehandle>;
}
my @questions = @{(Load($rawqfile))}; # Outputs an arrayref.
close($qfilehandle);
my $qnumber;
if(not defined($inpnum))
{
  my $count   = scalar(@questions);
  $qnumber    = int(rand($count));
}
else
{
  $qnumber = $inpnum;
}
my %question;
if(not $questions[$qnumber])
{
  $question{"status"}    += 2;
  $question{"message"}    = "Question not found.";
}
%question = %{$questions[$qnumber]};
$question{"status"}        = 0;
$question{"requesttime"}   = time;
$question{"answers"}->[0]  = $question{"answer0"};
$question{"answers"}->[1]  = $question{"answer1"};
$question{"answers"}->[2]  = $question{"answer2"};
$question{"answers"}->[3]  = $question{"answer3"};
delete $question{"answer0"};  delete $question{"answer1"};
delete $question{"answer2"};  delete $question{"answer3"};

$question{"qfiletime"}     =
(stat(dirname(rel2abs($0)) . $configs{"quizfilepath"}))[9];

$question{"id"}            = $qnumber;
$question{"session-id"}    = int(rand(65535));
$question{"correctanswr"}  = "" if $configs{"srvsidescore"};

if($configs{"srvsidescore"} and !$question{"status"})
{
  $question{"status"}      = 1;
  $question{"message"}     = "
  Doing score and question logic on the server side
  is currently unsupported.";
}
if($configs{"scrambleq"} and !$question{"status"})
{
  $question{"status"}      = 1;
  $question{"message"}     = "
  Scrambling question order is currently unsupported.";
}

my $finaljson = $j->encode(\%question);

print "Content-Type: text/plain;charset=UTF-8\n\n";
print "$finaljson";
