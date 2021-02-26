require 'ipaddr'

module SpoorClient
  class MetadataBuilder
    def initialize(ip_lookup:)
      @ip_lookup = ip_lookup
    end

    def metadata_for(record)
      ip_address = IPAddr.new(record[:ip_address])
      {
        ip_address: {
          address_properties: {
            public: !ip_address.private?,
            ipv4: ip_address.ipv4?,
          }
        }.merge(
          if ip_address.ipv4? && !ip_address.private?
            ip_data = @ip_lookup.insights(ip_address)

            {
              country: {
                iso_code: ip_data.country.iso_code,
              },
              location: {
                time_zone: ip_data.location.time_zone,
              },
              provider: {
                autonomous_system_number: ip_data.traits.autonomous_system_number,
                autonomous_system_organisation: ip_data.traits.autonomous_system_organization,
                isp: ip_data.traits.isp,
                organisation: ip_data.traits.organization,
                static_ip_score: ip_data.traits.static_ip_score,
                user_type: ip_data.traits.user_type,
              },
              registered_country: {
                iso_code: ip_data.registered_country.iso_code,
              },
              represented_country: {
                iso_code: ip_data.represented_country.iso_code,
              },
            }
          else
            {}
          end
        )
      }
    end
  end
end
