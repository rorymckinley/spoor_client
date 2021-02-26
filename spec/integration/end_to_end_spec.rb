# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'end-to-end' do
  # A dummy end-to-end implementation for ease of testing
  class TestRig
    def initialize
      maxmind_client = MaxMind::GeoIP2::Client.new(
        account_id: ENV.fetch('MAXMIND_USER_ID'),
        license_key: ENV.fetch('MAXMIND_LICENCE_KEY')
      )
      @metadata_builder = SpoorClient::MetadataBuilder.new(ip_lookup: maxmind_client)
      @sanitiser = SpoorClient::Sanitiser.new
    end

    def run(record)
      {
        record: record,
        metadata: @metadata_builder.metadata_for(record),
        sanitised_record: @sanitiser.sanitise(record)
      }
    end
  end

  let(:output) do
    {
      record: record,
      metadata: {
        ip_address: {
          address_properties: {
            public: true,
            ipv4: true,
          },
          country: {
            iso_code: 'US'
          },
          location: {
            time_zone: 'America/Chicago'
          },
          provider: {
            autonomous_system_number: 15169,
            autonomous_system_organisation: 'GOOGLE',
            isp: 'Google',
            organisation: 'Google',
            static_ip_score: nil,
            user_type: 'hosting',
          },
          registered_country: {
            iso_code: 'US'
          },
          represented_country: {
            iso_code: nil,
          }
        }
      },
      sanitised_record: {
        event_time: record[:event_time],
        event_type: 'traffic_routed_to_additional_recipients',
        ip_address: Digest::SHA512.base64digest('172.217.170.78'),
        additional_recipients: [
          {
            mailbox: {
              provided: Digest::SHA512.base64digest('foo+bar@dodgy.zzz'),
              canonical: Digest::SHA512.base64digest('foo@dodgy.zzz'),
              host: Digest::SHA512.base64digest('dodgy.zzz'),
            },
          },
        ],
        target: {
          mailbox: {
            provided: Digest::SHA512.base64digest('victim+sprinkles@test.zzz'),
            canonical: Digest::SHA512.base64digest('victim@test.zzz'),
            host: Digest::SHA512.base64digest('test.zzz'),
          },
        },
      }
    }
  end
  let(:record) do
    {
      ip_address: '172.217.170.78',
      target: 'victim+sprinkles@test.zzz',
      event_time: {
        timestamp: 1614270417, offset_seconds: 7200
      },
      event_type: 'traffic_routed_to_additional_recipients',
      additional_recipients: ['foo+bar@dodgy.zzz']
    }
  end

  subject { TestRig.new }

  it 'everything works when chained together' do
    VCR.use_cassette('end_to_end', match_requests_on: [:uri, :method, :headers]) do
      rig = TestRig.new
      expect(rig.run(record)).to eql output
    end
  end
end
