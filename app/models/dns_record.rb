class DnsRecord < ActiveRecord::Base

  has_and_belongs_to_many :hostnames_attrs

  validates_presence_of :ip
  validate :ip_valid

  def ip_valid
  	if !IPAddress.valid? self.ip
  		errors.add(:ip, "Invalid IP format")
  	end
  end
end