require 'open-uri'

class IndexManager
  def self.create_index(options={})
    client = Nsadoc.gateway.client
    index_name = Nsadoc.index_name

    client.indices.delete index: index_name rescue nil if options[:force]

    settings = Nsadoc.settings.to_hash
    mappings = Nsadoc.mappings.to_hash

    client.indices.create index: index_name,
    body: {
      settings: settings.to_hash,
      mappings: mappings.to_hash }
  end

  def self.import_from_json(options={})
    create_index force: true if options[:force]

    doc = JSON.parse(open("https://raw.githubusercontent.com/TransparencyToolkit/NSAAPI-Data/master/nsadocs.json").read, symbolize_names: true)
    nsadocs = doc.map { |nsadoc_hash| process_nsadoc_info nsadoc_hash}
    inc = 1
    nsadocs.each do |d|
      Nsadoc.create d, id: inc
      inc += 1
    end
  end

  def self.process_nsadoc_info(nsadoc_hash)
    if nsadoc_hash[:creation_date] == "Unknown" || nsadoc_hash[:creation_date] == "Date unknown"
      nsadoc_hash[:creation_date] = nil
    end
    nsadoc_hash[:programs_analyzed] = nsadoc_hash[:programs]
    nsadoc_hash[:codewords_analyzed] = nsadoc_hash[:codewords]
    nsadoc_hash[:type_analyzed] = nsadoc_hash[:type]
    nsadoc_hash[:records_collected_analyzed] = nsadoc_hash[:records_collected]
    nsadoc_hash[:legal_authority_analyzed] = nsadoc_hash[:legal_authority]
    nsadoc_hash[:countries_analyzed] = nsadoc_hash[:countries]
    nsadoc_hash[:sigads_analyzed] = nsadoc_hash[:sigads]
    nsadoc_hash[:released_by_analyzed] = nsadoc_hash[:released_by]
    nsadoc_hash
  end
end
