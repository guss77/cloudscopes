Cloudscopes
===========

Ruby gem to report system statistics to web based monitoring services such as CloudWatch

Features:

 * Easy to extend with additional metrics, using system classes or ruby experssions
 * Easily readable configuration using YAML
 * Metric conditions (only evaluate and publish metric if condition is met) allowing single simple configuration for hetrogenous environments
 * Conditions and value calculation done using Ruby expressions, allowing infinite customizability

Supported monitoring providers:

 * Amazon Cloudwatch

Supported metrics to monitor:

  * Linux /proc/meminfo data
  * Linux /proc/cpuinfo data
  * Linux /proc/loadavg data
  * Linux /proc/diskstats data
  * Linux SysV service status
  * Bluepill service status
  * Redis queue size (for Resque, but may possible work with other protocols)
  * Network port listen status

## Installation

1. Install the gem into your system's Ruby:
   `$ sudo gem install cloudscopes`
1. Setup the system with the default configuration and cron job:
   `$ sudo cloudscopes-setup`
1. Edit the configuration file according to your requirements:
   `$ sudo editor /etc/cloudscopes-monitoring.yaml`

## Usage

Cloudscopes monitoring script will be run every minute using the cron system, and will publish all specified metrics to the monitoring
service. Alternatively, the cloudscopes-monitor command can be called directly, by providing the path to the cloudscopes configuration file and one of the following options:

  * -t : instead of publishing the calculated metrics, dump them to the console. Useful for testing

If no additional options are specified, the default behavior of the monitor command is to publish the metrics using the configured provider.

## Contributing

1. Fork it ( https://github.com/guss77/cloudscopes/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

