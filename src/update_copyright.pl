#!/usr/bin/perl -w

# Copyright 2016 BitMover, Inc

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

sub dateRange {
    my($file) = @_;
    my($s, $e);

    my($ret) = "";
    open(PRS, "bk prs -fhnd:Dy: '$file' |");
    while (<PRS>) {
	chomp;
	$s = $_ unless $s;
	$e = $_ unless $e;
	if ($_ > $e + 1) {
	    $ret .= $s;
	    $ret .= "-$e" if $e != $s;
	    $ret .= ",";
	    $s = $e = 0;
	} else {
	    $e = $_;
	}
    }
    if ($s) {
	$ret .= $s;
	$ret .= "-$e" if $e != $s;
    }
    $ret;
}


open(S, "bk -U grep -l 'Copyright [0-9,]+ BitMover, Inc' |");
while (<S>) {
    chomp;
    my($file) = $_;

    my($r) = dateRange($file);
    print "$file: $r\n";
    system("bk edit -qS '$file'") == 0 or die $file;

    system("sed -i 's/Copyright [0-9,]\\+ BitMover, Inc/Copyright $r BitMover, Inc/' '$file'") == 0 or die;
}
close(S);