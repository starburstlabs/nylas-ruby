# frozen_string_literal: true

module Nylas
  # Structure to represent a Nylas Timespan.
  # @see https://docs.nylas.com/reference#section-timespan
  class Timespan
    extend Forwardable

    include Model::Attributable
    attribute :object, :string
    attribute :start_time, :unix_timestamp
    attribute :end_time, :unix_timestamp
    attribute :time, :unix_timestamp
    attribute :date, :unix_timestamp
    attribute :start_date, :unix_timestamp
    attribute :end_date, :unix_timestamp

    def_delegators :range, :cover?

    def range
      @range ||= Range.new(start_time, end_time)
    end
  end
end
