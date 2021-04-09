class CreateIpHostnames < ActiveRecord::Migration[6.0]
  def up

		create_table :dns_records do |t|
		  t.string :ip
		  t.timestamps
		end

		create_table :hostnames_attrs do |t|
		  t.string :hostname
		  t.timestamps
		end

		create_table :dns_records_hostnames_attrs, id: false do |t|
		  t.belongs_to :dns_record, index: true
		  t.belongs_to :hostnames_attr, index: true
		end
	end
end