#!/usr/bin/perl
# Perl key deployer
# Usage: sshDeploy.pl serverlist

# I generally always use strict and warnings when developing scripts you can remove warnings to potentially get better performance
use strict;
use warnings;

# We will be using expect to manage the login process for copying the SSH keys
use Expect;

# Fancy password prompt
use Term::ReadKey;

print "Enter your password: ";
ReadMode('noecho');
my $password = ReadLine(0);

chomp $password;
ReadMode('normal');

open('FH', "./serverlist") or die "can't open ./serverlist: $!";

# Loop through the file of hostnames one at a time
while (defined (my $host = <FH>)) {
  chomp $host;

  # Check to see if key authentication is already working so we don't copy the key twice
  if(system("ssh -o BatchMode=yes -o ConnectTimeout=5 $host uptime 2>&1 | grep -q average") != "0")
  {
    # Set up the command to copy the ssh key
    my $cmd = "ssh-copy-id -i $host";

    # Print comfort text
    print "Now copying key to $host";

    # Set up expect and spawn a command
    my $timeout = '10';
    my $ex = Expect->spawn($cmd) or die "Cannot spawn $cmd\n";

    # Look for the password prompt and send the password
    $ex->expect($timeout, ["[pP]assword:"]);
    $ex->send("$password\n");
    $ex->soft_close();
  } else { print "Key already deployed on $host\n" }
}
close('FH');
