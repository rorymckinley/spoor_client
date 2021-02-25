# frozen_string_literal: true
require 'spec_helper'

RSpec.describe SpoorClient::MetadataBuilder do
  let(:maxmind_client) { instance_double(MaxMind::GeoIP2::Client, insights: maxmind_insights) }
  let(:maxmind_insights) do
    instance_double(
      MaxMind::GeoIP2::Model::Insights,
      country: instance_double(MaxMind::GeoIP2::Record::Country, iso_code: 'US'),
      location: instance_double(MaxMind::GeoIP2::Record::Location, time_zone: 'America/Chicago'),
      registered_country: instance_double(MaxMind::GeoIP2::Record::Country, iso_code: 'DE'),
      represented_country: instance_double(MaxMind::GeoIP2::Record::RepresentedCountry, iso_code: 'ES'),
      traits: instance_double(
        MaxMind::GeoIP2::Record::Traits,
        autonomous_system_number: 112233,
        autonomous_system_organization: 'FOO_ASO',
        isp: 'FOO_ISP',
        organization: 'FOO ORG',
        static_ip_score: 19.5,
        user_type: 'residential',
      )
    )
  end
  let(:record) do
    {
      ip_address: ip_address,
    }
  end

  let(:subject) do
    described_class.new(ip_lookup: maxmind_client)
  end

  describe 'public V4 address' do
    let(:ip_address) { '1.1.1.1' }

    it 'looks up insights from MaxMind' do
      expect(maxmind_client).to receive(:insights).with(IPAddr.new(ip_address))

      subject.metadata_for(record)
    end

    it 'provides metadata related to the IP address' do
      expect(subject.metadata_for(record)).to eql({
        ip_address: {
          country: {
            iso_code: 'US',
          },
          location: {
            time_zone: 'America/Chicago',
          },
          provider: {
            autonomous_system_number: 112233,
            autonomous_system_organisation: 'FOO_ASO',
            isp: 'FOO_ISP',
            organisation: 'FOO ORG',
            static_ip_score: 19.5,
            user_type: 'residential',
          },
          registered_country: {
            iso_code: 'DE',
          },
          represented_country: {
            iso_code: 'ES',
          },
        }
      })
    end
  end

  describe 'private IPV4 address' do
    let(:ip_address) { '10.10.10.10' }

    it 'does not look up insights from MaxMind' do
      expect(maxmind_client).to_not receive(:insights)

      subject.metadata_for(record)
    end

    it 'returns no metadata' do
      expect(subject.metadata_for(record)).to eql({})
    end
  end

  describe 'IPV6 address' do
    let(:ip_address) { '2002:a05:6512:b28:0:0:0:0' }

    it 'does not look up insights from MaxMind' do
      expect(maxmind_client).to_not receive(:insights)

      subject.metadata_for(record)
    end

    it 'returns no metadata' do
      expect(subject.metadata_for(record)).to eql({})
    end
  end
end
