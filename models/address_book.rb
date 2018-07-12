require_relative 'entry'
require "csv"
require 'bloc_record/base'

class AddressBook < BlocRecord::Base
  attr_reader :entries

  def initialize(options={})
     super
    @entries = []
  end

  def add_entry(name, phone_number, email)
     Entry.create(name: name, phone_number: phone, email: email, address_book_id: self.id)
  end

  def import_from_csv(file_name)
    # Implementation goes here
    csv_text = File.read(file_name)
    csv = CSV.parse(csv_text, headers: true, skip_blanks: true)
    csv.each do |row|
      row_hash = row.to_hash
      add_entry(row_hash["name"], row_hash["phone_number"], row_hash["email"])
    end
  end

  # Search AddressBook for a specific entry by name
  def binary_search(name)
    lower = 0
    upper = entries.length - 1

    while lower <= upper
      mid = (lower + upper) / 2
      mid_name = entries[mid].name

      if name == mid_name
        return entries[mid]
      elsif name < mid_name
        upper = mid - 1
      elsif name > mid_name
        lower = mid + 1
      end
    end

    return nil
  end
end
