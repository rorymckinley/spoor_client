# frozen_string_literal: true
require 'spec_helper'

RSpec.describe SpoorClient::Sanitiser do
  describe 'sanitise' do
    let(:base_record) do
      {
        additional_recipients: [],
        event_time: nil,
        event_type: nil,
        ip_address: nil,
        target: {
          mailbox: {
            provided: nil,
            canonical: nil,
            host: nil
          }
        },
      }
    end
    let(:record) do
      {
        ip_address: '10.0.0.1'
      }
    end

    it 'sanitises an ip address and hashes it' do
      expect(subject.sanitise({ip_address: '10.0.0.1'})).to eql(
        base_record.merge(ip_address: Digest::SHA512.base64digest('10.0.0.1'))
      )

      expect(subject.sanitise({ip_address: '  10.0.0.1   '})).to eql(
        base_record.merge(ip_address: Digest::SHA512.base64digest('10.0.0.1'))
      )

      expect(subject.sanitise({ip_address: '2002:A05:6512:B28:0:0:0:0'})).to eql(
        base_record.merge(ip_address: Digest::SHA512.base64digest('2002:a05:6512:b28:0:0:0:0'))
      )

      expect(subject.sanitise({ip_address: nil})).to eql(base_record)
    end

    it 'sanitises a target mailbox' do
      expect(subject.sanitise({target: 'victim+sprinkles@test.zzz'})).to eql(
        base_record.merge(
          target: {
            mailbox: {
              provided: Digest::SHA512.base64digest('victim+sprinkles@test.zzz'),
              canonical: Digest::SHA512.base64digest('victim@test.zzz'),
              host: Digest::SHA512.base64digest('test.zzz')
            }
          }
        )
      )

      expect(subject.sanitise({target: '  victim+sPrinkles@tEst.zzz    '})).to eql(
        base_record.merge(
          target: {
            mailbox: {
              provided: Digest::SHA512.base64digest('victim+sprinkles@test.zzz'),
              canonical: Digest::SHA512.base64digest('victim@test.zzz'),
              host: Digest::SHA512.base64digest('test.zzz')
            }
          }
        )
      )

      expect(subject.sanitise({target: nil})).to eql(base_record)
    end

    it 'includes event time data unchanged' do
      expect(subject.sanitise({event_time:{timestamp: 1614270417, offset_seconds: 7200}})).to eql(
        base_record.merge({event_time:{timestamp: 1614270417, offset_seconds: 7200}})
      )
    end

    it 'includes the event type unchanged' do
      expect(subject.sanitise({event_type: 'additonal_recipient_added'})).to eql(
        base_record.merge({event_type: 'additonal_recipient_added'})
      )
    end

    it 'sanitises additional recipients' do
      expect(subject.sanitise({additional_recipients: ['foo+bar@dodgy.zzz', 'bar+baz@alsododgy.zzz']})).to eql(
        base_record.merge({
          additional_recipients: [
            {
              mailbox: {
                provided: Digest::SHA512.base64digest('foo+bar@dodgy.zzz'),
                canonical: Digest::SHA512.base64digest('foo@dodgy.zzz'),
                host: Digest::SHA512.base64digest('dodgy.zzz'),
              },
            },
            {
              mailbox: {
                provided: Digest::SHA512.base64digest('bar+baz@alsododgy.zzz'),
                canonical: Digest::SHA512.base64digest('bar@alsododgy.zzz'),
                host: Digest::SHA512.base64digest('alsododgy.zzz'),
              },
            },
          ]
        })
      )

      expect(subject.sanitise({additional_recipients: ['   bar+baz@aLsodoDgy.zzz']})).to eql(
        base_record.merge({
          additional_recipients: [
            {
              mailbox: {
                provided: Digest::SHA512.base64digest('bar+baz@alsododgy.zzz'),
                canonical: Digest::SHA512.base64digest('bar@alsododgy.zzz'),
                host: Digest::SHA512.base64digest('alsododgy.zzz'),
              }
            },
          ]
        })
      )
    end
  end
end
