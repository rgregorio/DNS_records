
class DnsRecordsHostnamesAttr < ActiveRecord::Base
  belongs_to :dns_record
  belongs_to :hostnames_attr
end

