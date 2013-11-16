require "bitballoon/dns_zone"

module BitBalloon
  class DnsZones < CollectionProxy
    path "/dns_zones"

    def dns_records
      DnsRecords.new(client, path)
    end
  end
end