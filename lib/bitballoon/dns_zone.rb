require "bitballoon/dns_records"

module BitBalloon
  class DnsZone < Model
    fields :id, :name, :user_id, :created_at, :updated_at

    def dns_records
      DnsRecords.new(client, path)
    end
  end
end