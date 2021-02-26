# frozen_sring_literal: true

module SpoorClient
  class Sanitiser
    def sanitise(record)
      {
        additional_recipients: (record[:additional_recipients] || []).map { |ar| sanitise_mailbox(ar) },
        event_time: record[:event_time],
        event_type: record[:event_type],
        ip_address: sanitise_ip_address(record[:ip_address]),
        target: sanitise_mailbox(record[:target]),
      }
    end

    private

    def sanitise_ip_address(ip_address)
      ip_address && Digest::SHA512.base64digest(ip_address.strip.downcase)
    end

    def sanitise_mailbox(mailbox_address_string)
      {
        mailbox: {
          provided: nil,
          canonical: nil,
          host: nil
        }.merge(
          if mailbox_address_string
            email_address = EmailAddress.new(mailbox_address_string)

            {
              provided: Digest::SHA512.base64digest(email_address.normal),
              canonical: Digest::SHA512.base64digest(email_address.canonical),
              host: Digest::SHA512.base64digest(email_address.host.name)
            }
          else
            {}
          end
        )
      }
    end
  end
end
