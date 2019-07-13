#!/usr/bin/env perl

use Config::IniFiles;
use Cwd qw(cwd);
use File::Basename;
use POSIX qw(strftime);
use Log::Log4perl;
use FindBin;
use Net::FTP;

my $date_now                       = strftime "%Y%m%d", localtime;
my $month                          = strftime "%Y%m", localtime;
my $prev_month			           = $month - 1;
my ( $scriptName, $path, $suffix ) = fileparse( $0, qr{\.[^.]*$} );

my $cfg                            = Config::IniFiles->new( -file => $FindBin::Bin.'/'.$ARGV[0] );
my $dir_log                        = $cfg->val('LOGS', 'folder');
my $dir_back                       = $cfg->val('BACKUP', 'path_archives');
my @dbname_to_back                 = $cfg->val('BACKUP', 'db_name');

my $db_host                        = $cfg->val('DATABASE', 'host');
my $db_user                        = $cfg->val('DATABASE', 'user');
my $db_pass                        = $cfg->val('DATABASE', 'pass');

unless (-d$dir_back)
{
    print 'Establishment of the backup directory', $/;
    mkdir $dir_back;
}

unless (-d$dir_log)
{
    print 'Establishment of the log directory', $/;
    mkdir $dir_log;
}

Log::Log4perl->init(\<<CONFIG);
log4perl.rootLogger                               = INFO, screen, file
log4perl.appender.screen                          = Log::Log4perl::Appender::Screen
log4perl.appender.screen.stderr                   = 0
log4perl.appender.screen.layout                   = PatternLayout
log4perl.appender.screen.layout.ConversionPattern = %d{yyyy-MM-dd HH:mm:ss.SSS} %5p %5P --- %m%n
log4perl.appender.file                            = Log::Log4perl::Appender::File
log4perl.appender.file.filename                   = ${dir_log}/${date_now}_${scriptName}.log
log4perl.appender.file.mode                       = append
log4perl.appender.file.layout                     = PatternLayout
log4perl.appender.file.layout.ConversionPattern   = %d{yyyy-MM-dd HH:mm:ss.SSS} %5p %5P --- %m%n
CONFIG
our $logger = Log::Log4perl->get_logger();

$logger->info('== Starting '.$0.' ==');

foreach my $db_name (@dbname_to_back)
{
    my $backup = $dir_back.'/backup-db-'.$date_now.'-'.$db_name.'.sql';
    $logger->info('Establishment of the database backup: ', $db_name);
    `mysqldump -h ${db_host} -u ${db_user} -p${db_pass} ${db_name} > ${backup}`;

    $logger->info('Connect to FTP server and send: ', $db_name);
    my $ftp_host = $cfg->val('FTP', 'host');
    my $ftp_user = $cfg->val('FTP', 'user');
    my $ftp_pass = $cfg->val('FTP', 'pass');
    my $ftp_path = $cfg->val('FTP', 'path');
    my $ftp = Net::FTP->new($ftp_host) or $logger->error($ftp->message) and die($ftp->message);
    $ftp->login($ftp_user, $ftp_pass) or $logger->error($ftp->message) and die($ftp->message);
    $ftp->passive(1);
    $ftp->cwd($ftp_path) or $logger->error($ftp->message) and die($ftp->message);
    my @results = $ftp->ls();
    $logger->info('[ftp] Put: ', $backup);
    $ftp->put($backup) or $logger->error($ftp->message) and die($ftp->message);
    foreach my $file (@results)
    {
        if ($file =~ /$prev_month\d{2}-$db_name/)
        {
            $logger->info('[ftp] Delete: ', $file);
            $ftp->delete($file) or $logger->error($ftp->message) and die($ftp->message);
        }
    }

    $logger->info('Remove local backup: ', $db_name);
    unlink ($backup) or $logger->error($!) and die($!);
}

$logger->info('== End ==');
