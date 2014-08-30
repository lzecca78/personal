#!/usr/bin/env ruby
require 'aws-sdk'

ec2_region = AWS_REGION
ec2 = AWS::EC2.new(:region => ec2_region,
  :access_key_id => AWS_ACCESS_KEY,
  :secret_access_key => AWS_SECRET_KEY )
   ec2.snapshots.with_owner(:self).select.each  do |snap_object|
   if ec2.volumes["#{snap_object.volume_id}"].exists?
      belong_instance_id = ec2.client.describe_instances(filters: [{ name: "block-device-mapping.volume-id", values: [snap_object.volume_id]}])[:reservation_set][0][:instances_set][0][:instance_id]
       puts "the snapshot #{snap_object.id} belong to #{ec2.instances[belong_instance_id].tags.each {|key,value| if key == 'Name' and !value.empty? then puts value  else puts belong_instance_id end }}"
   else
       puts "the snapshot #{snap_object.id} doesn't belong to anything right now"
       snapshots_available = ec2.snapshots.filter('volume-id', snap_object.volume_id)
       snapshots_available.each do |snap_orphan|
       puts "#{snap_orphan} can be deleted"
       end
   end
  end
