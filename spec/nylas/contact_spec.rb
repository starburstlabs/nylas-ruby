require "spec_helper"

describe Nylas::Contact do
  let(:full_json) do
    '{ "id": "1234", "object": "contact", "account_id": "12345", ' \
      '"given_name":"given", "middle_name": "middle", "surname": "surname", ' \
      '"birthday": "1984-01-01", "suffix": "Jr.", "nickname": "nick", ' \
      '"company_name": "company", "job_title": "title", ' \
      '"manager_name": "manager", "office_location": "the office", ' \
      '"notes": "some notes", "emails": [' \
        '{ "type": "work", "email": "given@work.example.com" }, ' \
        '{ "type": "home", "email": "given@home.example.com" }], ' \
      '"im_addresses": [{ "type": "gtalk", "im_address": "given@gtalk.example.com" }],' \
      '"physical_addresses": [{ "format": "structured", "type": "work",' \
        '"street_address": "123 N West St", "postal_code": "12345+0987", "city": "Los Angeles", "state": "CA",' \
        '"country": "USA" }],' \
      '"web_page": {}, ' \
      '"phone_numbers": [{ "type": "mobile", "number": "+1234567890" }], ' \
      '"web_pages": [{ "type": "profile", "url": "http://given.example.com" }],' \
      '"groups": [{"id": "di", "object": "dnwi", "account_id": "doiw", "name": "nfowie", "path": "fnien"}] ' \
    "}"
  end
  let(:partial_address_json) do
    '{ "id": "1234", "object": "contact", "account_id": "12345", ' \
      '"given_name":"given", "middle_name": "middle", "surname": "surname", ' \
      '"birthday": "1984-01-01", "suffix": "Jr.", "nickname": "nick", ' \
      '"company_name": "company", "job_title": "title", ' \
      '"manager_name": "manager", "office_location": "the office", ' \
      '"physical_addresses": [{ "format": "structured", "type": "work",' \
        '"street_address": "123 N West St", "postal_code": "", "city": "", "state": "",' \
        '"country": "USA" }]' \
    "}"
  end
  let(:api) { FakeAPI.new }

  describe "#update" do
    it "Sends the serialized version of attributes to the server" do
      contact = described_class.from_json(full_json, api: api)

      contact.update(given_name: "Given", birthday: "2017-01-01",
                     emails: [
                       { type: "work", email: "given@other-job.example.com" },
                       Nylas::EmailAddress.new(type: "home", email: "given@other-home.example.com")
                     ])
      expect(contact.given_name).to eql "Given"

      expect(contact.birthday).to eql("2017-01-01")
      expect(contact.emails.first.type).to eql "work"
      expect(contact.emails.first.email).to eql "given@other-job.example.com"
      expect(contact.emails.last.type).to eql "home"
      expect(contact.emails.last.email).to eql "given@other-home.example.com"
      request = api.requests[0]

      expected_payload = JSON.dump(given_name: "Given",
                                   birthday: "2017-01-01",
                                   emails: [{ type: "work",
                                              email: "given@other-job.example.com" },
                                            { type: "home",
                                              email: "given@other-home.example.com" }])
      expect(request[:method]).to be :put
      expect(request[:path]).to eql "/contacts/1234"
      expect(request[:payload]).to eql(expected_payload)
    end
  end

  describe ".from_json" do
    it "deserializes into a fully inflated Contact object" do
      contact = described_class.from_json(full_json, api: api)

      expect(contact.id).to eql("1234")
      expect(contact.object).to eql("contact")
      expect(contact.account_id).to eql("12345")
      expect(contact.given_name).to eql("given")
      expect(contact.middle_name).to eql("middle")
      expect(contact.surname).to eql("surname")
      expect(contact.birthday).to eql("1984-01-01")
      expect(contact.suffix).to eql("Jr.")
      expect(contact.nickname).to eql("nick")
      expect(contact.company_name).to eql("company")
      expect(contact.job_title).to eql("title")
      expect(contact.manager_name).to eql("manager")
      expect(contact.office_location).to eql("the office")
      expect(contact.notes).to eql("some notes")
      expect(contact.emails[0].type).to eql("work")
      expect(contact.emails[0].email).to eql("given@work.example.com")
      expect(contact.emails[1].type).to eql("home")
      expect(contact.emails[1].email).to eql("given@home.example.com")
      expect(contact.im_addresses[0].type).to eql("gtalk")
      expect(contact.im_addresses[0].im_address).to eql("given@gtalk.example.com")
      expect(contact.physical_addresses[0].type).to eql("work")
      expect(contact.physical_addresses[0].format).to eql("structured")
      expect(contact.physical_addresses[0].street_address).to eql("123 N West St")
      expect(contact.physical_addresses[0].postal_code).to eql("12345+0987")
      expect(contact.physical_addresses[0].state).to eql("CA")
      expect(contact.physical_addresses[0].country).to eql("USA")
      expect(contact.phone_numbers[0].type).to eql("mobile")
      expect(contact.phone_numbers[0].number).to eql("+1234567890")
      expect(contact.web_pages[0].type).to eql("profile")
      expect(contact.web_pages[0].url).to eql("http://given.example.com")
    end
  end

  describe "#to_h" do
    it "serializes attributes into a hash of primitives" do
      contact = described_class.from_json(full_json, api: api)
      expect(contact.to_h).to eql(id: "1234",
                                  object: "contact",
                                  account_id: "12345",
                                  given_name: "given",
                                  middle_name: "middle",
                                  surname: "surname",
                                  suffix: "Jr.",
                                  nickname: "nick",
                                  job_title: "title",
                                  office_location: "the office",
                                  manager_name: "manager",
                                  birthday: "1984-01-01",
                                  company_name: "company",
                                  notes: "some notes",
                                  web_page: {},
                                  emails: [{ type: "work", email: "given@work.example.com" },
                                           { type: "home", email: "given@home.example.com" }],
                                  im_addresses: [{ type: "gtalk", im_address: "given@gtalk.example.com" }],
                                  phone_numbers: [{ type: "mobile", number: "+1234567890" }],
                                  physical_addresses: [{ format: "structured", type: "work",
                                                         street_address: "123 N West St",
                                                         postal_code: "12345+0987", city: "Los Angeles", state: "CA",
                                                         country: "USA" }],
                                  web_pages: [{ type: "profile", url: "http://given.example.com" }],
                                  groups: [{id: "di", object: "dnwi", account_id: "doiw", name: "nfowie", path: "fnien"}])
    end

    it "serializes attributes correctly for a contact with a partial physical address" do
      contact = described_class.from_json(partial_address_json, api: api)
      expect(contact.to_h).to eql(id: "1234",
                                  object: "contact",
                                  account_id: "12345",
                                  given_name: "given",
                                  middle_name: "middle",
                                  surname: "surname",
                                  suffix: "Jr.",
                                  nickname: "nick",
                                  job_title: "title",
                                  office_location: "the office",
                                  manager_name: "manager",
                                  birthday: "1984-01-01",
                                  company_name: "company",
                                  emails: [],
                                  groups: [],
                                  im_addresses: [],
                                  phone_numbers: [],
                                  web_page: {},
                                  web_pages: [],
                                  physical_addresses: [{ format: "structured", type: "work",
                                                         street_address: "123 N West St",
                                                         postal_code: "", city: "", state: "",
                                                         country: "USA" }])
    end
  end

  describe "#to_json" do
    it "returns a string of JSON" do
      contact = described_class.from_json(full_json, api: api)
      expect(JSON.parse(contact.to_json)).to eql(JSON.parse(full_json))
    end
  end
end
