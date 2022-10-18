require "aws-sdk-ses"

class SESEmailer

  def initialize
    @client = Aws::SES::Client.new
  end

  def send_email(subject, html_body, from_address, from_name, to_addresses, to_names)

    str = html_body

    data = {
      destination: {
        bcc_addresses: [
        ],
        to_addresses: to_addresses.zip(to_names).map {|x| "\"#{x[1]}\" <#{x[0]}>"},
      },
      message: {
        body: {
          html: {
            charset: "UTF-8",
            data: str
          },
          text: {
            charset: "UTF-8",
            data: str
          },
        },
        subject: {
          charset: "UTF-8",
          data: subject,
        },
      },
      source: "\"#{from_name}\" <#{from_address}>",
    }

    resp = @client.send_email(data)

  end
end