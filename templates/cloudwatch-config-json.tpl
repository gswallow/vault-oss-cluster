{
	"agent": {
		"metrics_collection_interval": 60,
		"run_as_user": "cwagent"
	},
	"metrics": {
		"namespace": "${organization}/${environment}/${project}/CWAgent",
		"aggregation_dimensions": [
      [ "Organization", "Environment", "Project", "ClusterId", "AutoScalingGroupName" ],
      [ "AutoScalingGroupName" ],
      [ "InstanceId" ]
		],
		"append_dimensions": {
			"AutoScalingGroupName": "$${aws:AutoScalingGroupName}"
		},
		"metrics_collected": {
			"cpu": {
				"measurement": [
					"cpu_usage_idle",
					"cpu_usage_iowait",
					"cpu_usage_user",
					"cpu_usage_system"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				],
				"totalcpu": false,
				"append_dimensions": {
					"Organization": "${organization}",
					"Environment": "${environment}",
					"Project": "${project}",
					"ClusterId": "${cluster_id}"
				}
			},
			"disk": {
				"measurement": [
					"used_percent",
					"inodes_free"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				],
				"ignore_file_system_types": [
					"sysfs",
					"devtmpfs",
					"tmpfs",
					"debugfs",
					"rpc_pipefs",
					"hugetlbfs"
				],
				"drop_device": true,
				"append_dimensions": {
					"Organization": "${organization}",
					"Environment": "${environment}",
					"Project": "${project}",
					"ClusterId": "${cluster_id}"
				}
			},
			"diskio": {
				"measurement": [
					"io_time"
				],
				"metrics_collection_interval": 60,
				"resources": [
					"*"
				],
				"append_dimensions": {
					"Organization": "${organization}",
					"Environment": "${environment}",
					"Project": "${project}",
					"ClusterId": "${cluster_id}"
				}
			},
			"mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 60,
				"append_dimensions": {
					"Organization": "${organization}",
					"Environment": "${environment}",
					"Project": "${project}",
					"ClusterId": "${cluster_id}"
				}
			},
			"statsd": {
				"metrics_aggregation_interval": 60,
				"metrics_collection_interval": 60,
				"service_address": ":8125"
			},
			"swap": {
				"measurement": [
					"swap_used_percent"
				],
				"metrics_collection_interval": 60,
				"append_dimensions": {
					"Organization": "${organization}",
					"Environment": "${environment}",
					"Project": "${project}",
					"ClusterId": "${cluster_id}"
				}
			},
			"procstat": [
				{
					"pattern": "/usr/bin/vault",
					"measurement": [
						"cpu_time",
						"cpu_time_system",
						"cpu_time_user",
						"cpu_usage",
						"memory_data",
						"memory_locked",
						"memory_rss",
						"memory_stack",
						"pid_count",
						"involuntary_context_switches",
						"rlimit_cpu_time_hard",
						"rlimit_memory_data_hard",
						"rlimit_memory_locked_hard",
						"rlimit_memory_rss_hard",
						"rlimit_memory_stack_hard"
					],
					"append_dimensions": {
						"Organization": "${organization}",
						"Environment": "${environment}",
						"Project": "${project}",
						"ClusterId": "${cluster_id}"
					}
				},
				{
					"pattern": "/usr/bin/consul",
					"measurement": [
						"cpu_time",
						"cpu_time_system",
						"cpu_time_user",
						"cpu_usage",
						"memory_data",
						"memory_locked",
						"memory_rss",
						"memory_stack",
						"pid_count",
						"involuntary_context_switches",
						"rlimit_cpu_time_hard",
						"rlimit_memory_data_hard",
						"rlimit_memory_locked_hard",
						"rlimit_memory_rss_hard",
						"rlimit_memory_stack_hard"
					],
					"append_dimensions": {
						"Organization": "${organization}",
						"Environment": "${environment}",
						"Project": "${project}",
						"ClusterId": "${cluster_id}"
					}
				}
			]
		}
	}
}
