module Api
  module V1
    class DnsRecordsController < ApplicationController
      # GET /dns_records
      def index
        code_status = 200
        error = nil
        total_records = 0
        distinct_records = []
        related_hostnames = []

        begin
          if !params[:page] || params[:page].blank?
            raise "Field page is required"
          end

          records = collection[:records]
          related_hostnames = collection[:related_hostnames]
          total_records = records.size

        rescue Exception => e
          code_status = 422
          error = e.message
        end

       render json: { 
          :total_records => total_records, 
          :records => records,
          :related_hostnames => related_hostnames,
          :error => error
        }, 
        status: code_status
      end

      # POST /dns_records
      def create
        code_status = 200
        error = nil
        id_recorded = nil
        hostnames = []

        begin
          if dns_record.valid?
            load_hostnames hostnames
          else
            raise "IP not valid!"
          end

          dns_record.save
          dns_record.hostnames_attrs << hostnames

          id_recorded = dns_record.id

        rescue Exception => e
          code_status = 422
          error = e.message
        end

        render json: { :id => id_recorded, :error => error }, status: code_status
      end

      private      

      def collection
        included = params["included"] ? params["included"].split(',') : nil
        excluded = params["excluded"] ? params["excluded"].split(',') : nil

        results = DnsRecordsHostnamesAttr.joins(:hostnames_attr, :dns_record)
        results = results.where("hostnames_attrs.hostname in (?)", included) if included.present?
        results = results.where("hostnames_attrs.hostname not in (?)", excluded) if excluded.present?
        results = results.paginate(:page => params[:page], :per_page => 10)

        related_hostnames = []
        records = []
        results.each do | result |
          dns_record = DnsRecord.where(id: result.dns_record_id).first
          record_data = {
            :id => dns_record.id,
            :ip_address => dns_record.ip
          }
          records << record_data unless records.include?(dns_record)
          hostnames = HostnamesAttr.joins(:dns_records)
                                   .where("hostnames_attrs.id = ?", result.hostnames_attr_id)
          hostnames.each do | hostname |
            data = { 
              :hostname => hostname.hostname, 
              :count => hostname.dns_records.size
            }
            related_hostnames << data unless related_hostnames.include?(data)
          end
        end

        { 
          :related_hostnames => related_hostnames, 
          :records => records
        }        
      end

      def dns_record
        record = DnsRecord.where(ip: params["dns_records"]["ip"])
        if record.present?
          record = record.first
        else
          record = DnsRecord.new(ip: params["dns_records"]["ip"])
        end

        record
      end

      def get_hostname hostname_item
        hostname = HostnamesAttr.where(hostname: hostname_item)
        if hostname.present?
          hostname = hostname.first
        else
          hostname = HostnamesAttr.new(hostname: hostname_item)
        end

        hostname
      end

      def load_hostnames hostnames
        hostname_param = params["dns_records"]["hostnames_attributes"]
        if !hostname_param || hostname_param.blank?
          raise 'Missing hostname param'
        end

        hostname_param.each do |hostnames_item|
          hostname = get_hostname(hostnames_item["hostname"])
          if hostname.valid?
            hostnames << hostname
          else
            raise "Some of the hostnames are not valid"
          end
        end
      end
    end
  end
end
